-- =============================================================================
-- GraphRAG Hybrid Search Queries
-- =============================================================================
-- Hybrid Search: Combines lexical (PGroonga) + semantic (pgvector) search
-- Use RRF (Reciprocal Rank Fusion) to merge results
-- Use for: Queries with specific terms + semantic meaning
-- =============================================================================

-- =============================================================================
-- 1. Basic Hybrid Search
-- =============================================================================

-- Simple hybrid search on chunks
-- Parameters: $query_text (TEXT), $query_embedding (vector), $limit (INT)
WITH
-- Lexical Search (PGroonga)
lexical_results AS (
    SELECT
        c.id as chunk_id,
        c.content,
        c.document_id,
        pgroonga_score(tableoid, ctid) as lex_score,
        ROW_NUMBER() OVER (ORDER BY pgroonga_score(tableoid, ctid) DESC) as lex_rank
    FROM chunks c
    WHERE c.content &@~ $query_text
    LIMIT 100
),

-- Semantic Search (pgvector)
semantic_results AS (
    SELECT
        ce.chunk_id,
        c.content,
        c.document_id,
        1 - (ce.embedding <=> $query_embedding) as sem_score,
        ROW_NUMBER() OVER (ORDER BY ce.embedding <=> $query_embedding) as sem_rank
    FROM chunk_embeddings ce
    JOIN chunks c ON ce.chunk_id = c.id
    ORDER BY ce.embedding <=> $query_embedding
    LIMIT 100
),

-- RRF Fusion (k=60 is standard)
rrf_combined AS (
    SELECT
        COALESCE(lr.chunk_id, sr.chunk_id) as chunk_id,
        COALESCE(lr.content, sr.content) as content,
        COALESCE(lr.document_id, sr.document_id) as document_id,
        COALESCE(1.0 / (60 + lr.lex_rank), 0) as lex_rrf,
        COALESCE(1.0 / (60 + sr.sem_rank), 0) as sem_rrf,
        COALESCE(1.0 / (60 + lr.lex_rank), 0) +
        COALESCE(1.0 / (60 + sr.sem_rank), 0) as rrf_score,
        lr.lex_rank,
        sr.sem_rank
    FROM lexical_results lr
    FULL OUTER JOIN semantic_results sr ON lr.chunk_id = sr.chunk_id
)

SELECT
    chunk_id,
    content,
    document_id,
    rrf_score,
    lex_rrf,
    sem_rrf,
    lex_rank,
    sem_rank
FROM rrf_combined
ORDER BY rrf_score DESC
LIMIT COALESCE($limit, 20);

-- =============================================================================
-- 2. Weighted Hybrid Search
-- =============================================================================

-- Hybrid search with configurable weights
-- Parameters:
--   $query_text (TEXT)
--   $query_embedding (vector)
--   $lex_weight (REAL) - default 0.4
--   $sem_weight (REAL) - default 0.6
--   $limit (INT) - default 20

WITH
lexical_results AS (
    SELECT
        c.id as chunk_id,
        ROW_NUMBER() OVER (ORDER BY pgroonga_score(tableoid, ctid) DESC) as lex_rank
    FROM chunks c
    WHERE c.content &@~ $query_text
    LIMIT 100
),
semantic_results AS (
    SELECT
        ce.chunk_id,
        ROW_NUMBER() OVER (ORDER BY ce.embedding <=> $query_embedding) as sem_rank
    FROM chunk_embeddings ce
    ORDER BY ce.embedding <=> $query_embedding
    LIMIT 100
),
rrf_combined AS (
    SELECT
        COALESCE(lr.chunk_id, sr.chunk_id) as chunk_id,
        COALESCE($lex_weight, 0.4) * COALESCE(1.0 / (60 + lr.lex_rank), 0) +
        COALESCE($sem_weight, 0.6) * COALESCE(1.0 / (60 + sr.sem_rank), 0) as weighted_rrf_score
    FROM lexical_results lr
    FULL OUTER JOIN semantic_results sr ON lr.chunk_id = sr.chunk_id
)
SELECT
    c.id as chunk_id,
    c.content,
    c.document_id,
    d.title as document_title,
    rc.weighted_rrf_score
FROM rrf_combined rc
JOIN chunks c ON rc.chunk_id = c.id
JOIN documents d ON c.document_id = d.id
ORDER BY rc.weighted_rrf_score DESC
LIMIT COALESCE($limit, 20);

-- =============================================================================
-- 3. Hybrid Search with Filters
-- =============================================================================

-- Filtered hybrid search (category, date, etc.)
-- Parameters:
--   $query_text (TEXT)
--   $query_embedding (vector)
--   $category (TEXT) - metadata filter
--   $limit (INT)

WITH
-- Apply filter first
filtered_chunks AS (
    SELECT c.id
    FROM chunks c
    WHERE c.metadata->>'category' = $category
       OR $category IS NULL
),
lexical_results AS (
    SELECT
        c.id as chunk_id,
        ROW_NUMBER() OVER (ORDER BY pgroonga_score(tableoid, ctid) DESC) as lex_rank
    FROM chunks c
    WHERE c.id IN (SELECT id FROM filtered_chunks)
      AND c.content &@~ $query_text
    LIMIT 100
),
semantic_results AS (
    SELECT
        ce.chunk_id,
        ROW_NUMBER() OVER (ORDER BY ce.embedding <=> $query_embedding) as sem_rank
    FROM chunk_embeddings ce
    WHERE ce.chunk_id IN (SELECT id FROM filtered_chunks)
    ORDER BY ce.embedding <=> $query_embedding
    LIMIT 100
),
rrf_combined AS (
    SELECT
        COALESCE(lr.chunk_id, sr.chunk_id) as chunk_id,
        COALESCE(1.0 / (60 + lr.lex_rank), 0) +
        COALESCE(1.0 / (60 + sr.sem_rank), 0) as rrf_score
    FROM lexical_results lr
    FULL OUTER JOIN semantic_results sr ON lr.chunk_id = sr.chunk_id
)
SELECT
    c.id as chunk_id,
    c.content,
    c.metadata,
    rc.rrf_score
FROM rrf_combined rc
JOIN chunks c ON rc.chunk_id = c.id
ORDER BY rc.rrf_score DESC
LIMIT COALESCE($limit, 20);

-- =============================================================================
-- 4. Hybrid Entity Search
-- =============================================================================

-- Search entities with hybrid approach
-- Parameters: $query_text (TEXT), $query_embedding (vector), $limit (INT)

WITH
-- Lexical match on entity names/descriptions
lexical_entities AS (
    SELECT
        e.id,
        e.name,
        e.entity_type,
        e.description,
        pgroonga_score(tableoid, ctid) as lex_score,
        ROW_NUMBER() OVER (ORDER BY pgroonga_score(tableoid, ctid) DESC) as lex_rank
    FROM entities e
    WHERE e.name &@~ $query_text
       OR e.description &@~ $query_text
    LIMIT 50
),

-- Semantic match on entity embeddings
semantic_entities AS (
    SELECT
        ee.entity_id as id,
        e.name,
        e.entity_type,
        e.description,
        1 - (ee.embedding <=> $query_embedding) as sem_score,
        ROW_NUMBER() OVER (ORDER BY ee.embedding <=> $query_embedding) as sem_rank
    FROM entity_embeddings ee
    JOIN entities e ON ee.entity_id = e.id
    ORDER BY ee.embedding <=> $query_embedding
    LIMIT 50
),

-- RRF fusion
rrf_entities AS (
    SELECT
        COALESCE(le.id, se.id) as id,
        COALESCE(le.name, se.name) as name,
        COALESCE(le.entity_type, se.entity_type) as entity_type,
        COALESCE(le.description, se.description) as description,
        COALESCE(1.0 / (60 + le.lex_rank), 0) +
        COALESCE(1.0 / (60 + se.sem_rank), 0) as rrf_score,
        le.lex_rank,
        se.sem_rank
    FROM lexical_entities le
    FULL OUTER JOIN semantic_entities se ON le.id = se.id
)

SELECT *
FROM rrf_entities
ORDER BY rrf_score DESC
LIMIT COALESCE($limit, 10);

-- =============================================================================
-- 5. Complete Hybrid Search Pipeline
-- =============================================================================

-- Full hybrid search with chunks, entities, and graph context
-- Parameters:
--   $query_text (TEXT)
--   $query_embedding (vector)
--   $lex_weight (REAL) - default 0.4
--   $sem_weight (REAL) - default 0.6
--   $chunk_limit (INT) - default 20
--   $entity_limit (INT) - default 10

WITH
-- Hybrid chunk search
lexical_chunks AS (
    SELECT
        c.id as chunk_id,
        ROW_NUMBER() OVER (ORDER BY pgroonga_score(tableoid, ctid) DESC) as lex_rank
    FROM chunks c
    WHERE c.content &@~ $query_text
    LIMIT 100
),
semantic_chunks AS (
    SELECT
        ce.chunk_id,
        ROW_NUMBER() OVER (ORDER BY ce.embedding <=> $query_embedding) as sem_rank
    FROM chunk_embeddings ce
    ORDER BY ce.embedding <=> $query_embedding
    LIMIT 100
),
hybrid_chunks AS (
    SELECT
        COALESCE(lc.chunk_id, sc.chunk_id) as chunk_id,
        COALESCE($lex_weight, 0.4) * COALESCE(1.0 / (60 + lc.lex_rank), 0) +
        COALESCE($sem_weight, 0.6) * COALESCE(1.0 / (60 + sc.sem_rank), 0) as rrf_score
    FROM lexical_chunks lc
    FULL OUTER JOIN semantic_chunks sc ON lc.chunk_id = sc.chunk_id
    ORDER BY 2 DESC
    LIMIT COALESCE($chunk_limit, 20)
),

-- Get entities mentioned in top chunks
mentioned_entities AS (
    SELECT DISTINCT
        e.id,
        e.name,
        e.entity_type,
        e.description,
        COUNT(m.id) as mention_count
    FROM hybrid_chunks hc
    JOIN mentions m ON hc.chunk_id = m.chunk_id
    JOIN entities e ON m.entity_id = e.id
    GROUP BY e.id, e.name, e.entity_type, e.description
    ORDER BY mention_count DESC
    LIMIT COALESCE($entity_limit, 10)
),

-- Get relationships between mentioned entities
entity_relationships AS (
    SELECT
        e1.name as src_name,
        ed.edge_type,
        e2.name as dst_name,
        ed.weight,
        ed.confidence
    FROM edges ed
    JOIN entities e1 ON ed.src_entity_id = e1.id
    JOIN entities e2 ON ed.dst_entity_id = e2.id
    WHERE e1.id IN (SELECT id FROM mentioned_entities)
      AND e2.id IN (SELECT id FROM mentioned_entities)
      AND ed.confidence >= 0.7
)

-- Final output
SELECT json_build_object(
    'chunks', (
        SELECT json_agg(json_build_object(
            'chunk_id', hc.chunk_id,
            'content', c.content,
            'document_title', d.title,
            'rrf_score', hc.rrf_score
        ) ORDER BY hc.rrf_score DESC)
        FROM hybrid_chunks hc
        JOIN chunks c ON hc.chunk_id = c.id
        JOIN documents d ON c.document_id = d.id
    ),
    'entities', (
        SELECT json_agg(json_build_object(
            'id', id,
            'name', name,
            'type', entity_type,
            'description', description,
            'mention_count', mention_count
        ) ORDER BY mention_count DESC)
        FROM mentioned_entities
    ),
    'relationships', (
        SELECT json_agg(json_build_object(
            'src', src_name,
            'type', edge_type,
            'dst', dst_name,
            'weight', weight
        ))
        FROM entity_relationships
    )
) as hybrid_search_result;

-- =============================================================================
-- 6. Phrase Search + Semantic Expansion
-- =============================================================================

-- Exact phrase search with semantic expansion
-- Parameters:
--   $exact_phrase (TEXT) - exact match required
--   $query_embedding (vector) - for expansion
--   $limit (INT)

WITH
-- Exact phrase matches
exact_matches AS (
    SELECT
        c.id as chunk_id,
        c.content,
        1 as is_exact
    FROM chunks c
    WHERE c.content LIKE '%' || $exact_phrase || '%'
    LIMIT 50
),

-- Semantically similar to exact matches
semantic_expansion AS (
    SELECT
        ce.chunk_id,
        c.content,
        0 as is_exact,
        ce.embedding <=> $query_embedding as distance
    FROM chunk_embeddings ce
    JOIN chunks c ON ce.chunk_id = c.id
    WHERE ce.chunk_id NOT IN (SELECT chunk_id FROM exact_matches)
    ORDER BY ce.embedding <=> $query_embedding
    LIMIT 50
)

-- Combine: exact first, then semantic
SELECT
    chunk_id,
    content,
    is_exact,
    CASE WHEN is_exact = 1 THEN 0 ELSE distance END as distance
FROM (
    SELECT chunk_id, content, is_exact, 0::float as distance FROM exact_matches
    UNION ALL
    SELECT chunk_id, content, is_exact, distance FROM semantic_expansion
) combined
ORDER BY is_exact DESC, distance
LIMIT COALESCE($limit, 20);

-- =============================================================================
-- 7. RRF Parameters Reference
-- =============================================================================

-- Standard RRF formula: 1 / (k + rank)
-- k=60 is commonly used (from original RRF paper)
-- Lower k: gives more weight to top results
-- Higher k: more uniform weighting

-- Example with different k values:
-- k=30: More aggressive (top results dominate)
-- k=60: Standard (balanced)
-- k=100: Conservative (flatter distribution)
