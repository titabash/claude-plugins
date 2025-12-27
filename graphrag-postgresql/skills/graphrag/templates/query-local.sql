-- =============================================================================
-- GraphRAG Local Search Queries
-- =============================================================================
-- Local Search: Entity-centric retrieval with graph expansion
-- Use for: "Tell me about X", "How does X work?", "What is X related to?"
-- =============================================================================

-- =============================================================================
-- 1. Entity Linking: Find entities matching query
-- =============================================================================

-- Simple name match
-- Parameters: $query_text (TEXT)
WITH matched_entities AS (
    SELECT
        id,
        name,
        entity_type,
        description,
        1.0 as match_score
    FROM entities
    WHERE name ILIKE '%' || $query_text || '%'
       OR $query_text = ANY(aliases)
    LIMIT 10
)
SELECT * FROM matched_entities ORDER BY match_score DESC;

-- PGroonga full-text match (Japanese)
-- Parameters: $query_text (TEXT)
WITH matched_entities AS (
    SELECT
        id,
        name,
        entity_type,
        description,
        pgroonga_score(tableoid, ctid) as match_score
    FROM entities
    WHERE name &@~ $query_text
       OR description &@~ $query_text
    ORDER BY match_score DESC
    LIMIT 10
)
SELECT * FROM matched_entities;

-- Vector similarity match (Entity Linking with embeddings)
-- Parameters: $query_embedding (vector)
WITH matched_entities AS (
    SELECT
        e.id,
        e.name,
        e.entity_type,
        e.description,
        1 - (ee.embedding <=> $query_embedding) as similarity
    FROM entities e
    JOIN entity_embeddings ee ON e.id = ee.entity_id
    ORDER BY ee.embedding <=> $query_embedding
    LIMIT 10
)
SELECT * FROM matched_entities;

-- =============================================================================
-- 2. Graph Expansion: n-hop traversal from seed entities
-- =============================================================================

-- 1-hop expansion
-- Parameters: $seed_entity_ids (UUID[]), $min_confidence (REAL)
WITH seed AS (
    SELECT unnest($seed_entity_ids::uuid[]) as entity_id
),
one_hop AS (
    SELECT
        e.id as entity_id,
        e.name,
        e.entity_type,
        ed.edge_type,
        ed.weight,
        ed.confidence,
        ed.description as edge_description,
        1 as hop
    FROM edges ed
    JOIN entities e ON (
        (ed.src_entity_id IN (SELECT entity_id FROM seed) AND ed.dst_entity_id = e.id)
        OR
        (ed.dst_entity_id IN (SELECT entity_id FROM seed) AND ed.src_entity_id = e.id)
    )
    WHERE ed.confidence >= COALESCE($min_confidence, 0.7)
)
SELECT * FROM one_hop ORDER BY confidence DESC, weight DESC;

-- 2-hop expansion with path tracking
-- Parameters: $seed_entity_id (UUID), $max_hops (INT), $min_confidence (REAL)
WITH RECURSIVE graph_expansion AS (
    -- Base case: seed entity
    SELECT
        e.id as entity_id,
        e.name,
        e.entity_type,
        NULL::text as edge_type,
        0 as hop,
        ARRAY[e.id] as path,
        1.0 as path_weight
    FROM entities e
    WHERE e.id = $seed_entity_id

    UNION ALL

    -- Recursive case: expand edges
    SELECT
        CASE
            WHEN ed.src_entity_id = ge.entity_id THEN ed.dst_entity_id
            ELSE ed.src_entity_id
        END as entity_id,
        e2.name,
        e2.entity_type,
        ed.edge_type,
        ge.hop + 1,
        ge.path || CASE
            WHEN ed.src_entity_id = ge.entity_id THEN ed.dst_entity_id
            ELSE ed.src_entity_id
        END,
        ge.path_weight * ed.weight * ed.confidence
    FROM graph_expansion ge
    JOIN edges ed ON (ed.src_entity_id = ge.entity_id OR ed.dst_entity_id = ge.entity_id)
    JOIN entities e2 ON e2.id = CASE
        WHEN ed.src_entity_id = ge.entity_id THEN ed.dst_entity_id
        ELSE ed.src_entity_id
    END
    WHERE ge.hop < COALESCE($max_hops, 2)
      AND ed.confidence >= COALESCE($min_confidence, 0.7)
      AND NOT (CASE
          WHEN ed.src_entity_id = ge.entity_id THEN ed.dst_entity_id
          ELSE ed.src_entity_id
      END = ANY(ge.path))
)
SELECT
    entity_id,
    name,
    entity_type,
    edge_type,
    MIN(hop) as min_hop,
    MAX(path_weight) as max_path_weight
FROM graph_expansion
WHERE hop > 0
GROUP BY entity_id, name, entity_type, edge_type
ORDER BY min_hop, max_path_weight DESC;

-- =============================================================================
-- 3. Evidence Collection: Get chunks for entities
-- =============================================================================

-- Get evidence chunks for entities
-- Parameters: $entity_ids (UUID[])
WITH evidence AS (
    SELECT
        c.id as chunk_id,
        c.content,
        c.document_id,
        d.title as document_title,
        d.source_id,
        m.entity_id,
        e.name as entity_name,
        m.confidence
    FROM mentions m
    JOIN chunks c ON m.chunk_id = c.id
    JOIN documents d ON c.document_id = d.id
    JOIN entities e ON m.entity_id = e.id
    WHERE m.entity_id = ANY($entity_ids::uuid[])
    ORDER BY m.confidence DESC
)
SELECT * FROM evidence;

-- Get evidence with vector ranking
-- Parameters: $entity_ids (UUID[]), $query_embedding (vector), $limit (INT)
WITH entity_chunks AS (
    SELECT DISTINCT c.id as chunk_id
    FROM mentions m
    JOIN chunks c ON m.chunk_id = c.id
    WHERE m.entity_id = ANY($entity_ids::uuid[])
),
ranked_evidence AS (
    SELECT
        c.id as chunk_id,
        c.content,
        c.document_id,
        d.title as document_title,
        ce.embedding <=> $query_embedding as distance
    FROM entity_chunks ec
    JOIN chunks c ON ec.chunk_id = c.id
    JOIN chunk_embeddings ce ON c.id = ce.chunk_id
    JOIN documents d ON c.document_id = d.id
    ORDER BY ce.embedding <=> $query_embedding
    LIMIT COALESCE($limit, 20)
)
SELECT * FROM ranked_evidence;

-- =============================================================================
-- 4. Complete Local Search Pipeline
-- =============================================================================

-- Full local search with entity linking, expansion, and evidence
-- Parameters:
--   $query_text (TEXT)
--   $query_embedding (vector)
--   $max_hops (INT) - default 2
--   $min_confidence (REAL) - default 0.7
--   $evidence_limit (INT) - default 20

WITH
-- Step 1: Entity Linking (hybrid: text + vector)
seed_entities AS (
    SELECT
        e.id,
        e.name,
        e.entity_type,
        GREATEST(
            CASE WHEN e.name ILIKE '%' || $query_text || '%' THEN 0.8 ELSE 0 END,
            COALESCE(1 - (ee.embedding <=> $query_embedding), 0)
        ) as match_score
    FROM entities e
    LEFT JOIN entity_embeddings ee ON e.id = ee.entity_id
    WHERE e.name ILIKE '%' || $query_text || '%'
       OR $query_text = ANY(e.aliases)
       OR (ee.embedding IS NOT NULL AND ee.embedding <=> $query_embedding < 0.5)
    ORDER BY match_score DESC
    LIMIT 5
),

-- Step 2: Graph Expansion (1-hop)
related_entities AS (
    SELECT DISTINCT
        e.id,
        e.name,
        e.entity_type,
        ed.edge_type,
        ed.weight,
        ed.confidence
    FROM seed_entities se
    JOIN edges ed ON (se.id = ed.src_entity_id OR se.id = ed.dst_entity_id)
    JOIN entities e ON e.id = CASE
        WHEN ed.src_entity_id = se.id THEN ed.dst_entity_id
        ELSE ed.src_entity_id
    END
    WHERE ed.confidence >= COALESCE($min_confidence, 0.7)
),

-- Step 3: Collect all relevant entities
all_entities AS (
    SELECT id FROM seed_entities
    UNION
    SELECT id FROM related_entities
),

-- Step 4: Get evidence chunks
evidence_chunks AS (
    SELECT DISTINCT
        c.id as chunk_id,
        c.content,
        d.title as document_title,
        d.source_id,
        ce.embedding <=> $query_embedding as distance
    FROM all_entities ae
    JOIN mentions m ON ae.id = m.entity_id
    JOIN chunks c ON m.chunk_id = c.id
    JOIN chunk_embeddings ce ON c.id = ce.chunk_id
    JOIN documents d ON c.document_id = d.id
    ORDER BY ce.embedding <=> $query_embedding
    LIMIT COALESCE($evidence_limit, 20)
)

-- Final output
SELECT json_build_object(
    'seed_entities', (SELECT json_agg(row_to_json(se)) FROM seed_entities se),
    'related_entities', (SELECT json_agg(row_to_json(re)) FROM related_entities re),
    'evidence', (SELECT json_agg(row_to_json(ec)) FROM evidence_chunks ec)
) as local_search_result;

-- =============================================================================
-- 5. Time-Sliced Local Search
-- =============================================================================

-- Local search at specific point in time
-- Parameters: $seed_entity_id (UUID), $as_of_event_index (INT)
WITH valid_edges AS (
    SELECT ed.*
    FROM edges ed
    LEFT JOIN events e_from ON ed.valid_from_event_id = e_from.id
    LEFT JOIN events e_to ON ed.valid_to_event_id = e_to.id
    WHERE (ed.valid_from_event_id IS NULL OR e_from.event_index <= $as_of_event_index)
      AND (ed.valid_to_event_id IS NULL OR e_to.event_index > $as_of_event_index)
),
related AS (
    SELECT
        e.id,
        e.name,
        e.entity_type,
        ve.edge_type,
        ve.weight
    FROM valid_edges ve
    JOIN entities e ON e.id = CASE
        WHEN ve.src_entity_id = $seed_entity_id THEN ve.dst_entity_id
        ELSE ve.src_entity_id
    END
    WHERE ve.src_entity_id = $seed_entity_id OR ve.dst_entity_id = $seed_entity_id
)
SELECT * FROM related ORDER BY weight DESC;
