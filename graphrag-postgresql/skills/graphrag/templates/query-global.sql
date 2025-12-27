-- =============================================================================
-- GraphRAG Global Search Queries
-- =============================================================================
-- Global Search: Community-based retrieval for broad questions
-- Use for: "Summarize...", "What are the main topics?", "Give me an overview"
-- =============================================================================

-- =============================================================================
-- 1. Community Report Search
-- =============================================================================

-- Find relevant community reports by vector similarity
-- Parameters: $query_embedding (vector), $level (INT), $limit (INT)
WITH relevant_reports AS (
    SELECT
        cr.community_id,
        cr.report,
        c.level,
        c.name as community_name,
        cr.embedding <=> $query_embedding as distance,
        1 - (cr.embedding <=> $query_embedding) as similarity
    FROM community_reports cr
    JOIN communities c ON cr.community_id = c.id
    WHERE c.level = COALESCE($level, 1)  -- Default to mid-level
      AND cr.embedding IS NOT NULL
    ORDER BY cr.embedding <=> $query_embedding
    LIMIT COALESCE($limit, 10)
)
SELECT * FROM relevant_reports;

-- Search across all community levels
-- Parameters: $query_embedding (vector), $limit_per_level (INT)
WITH ranked_reports AS (
    SELECT
        cr.community_id,
        cr.report,
        c.level,
        c.name as community_name,
        cr.embedding <=> $query_embedding as distance,
        ROW_NUMBER() OVER (PARTITION BY c.level ORDER BY cr.embedding <=> $query_embedding) as rank_in_level
    FROM community_reports cr
    JOIN communities c ON cr.community_id = c.id
    WHERE cr.embedding IS NOT NULL
)
SELECT *
FROM ranked_reports
WHERE rank_in_level <= COALESCE($limit_per_level, 3)
ORDER BY level DESC, distance;

-- =============================================================================
-- 2. Community Details
-- =============================================================================

-- Get community members (entities)
-- Parameters: $community_id (UUID)
WITH community_members AS (
    SELECT
        e.id,
        e.name,
        e.entity_type,
        e.description,
        (SELECT COUNT(*) FROM edges ed
         WHERE ed.src_entity_id = e.id OR ed.dst_entity_id = e.id) as edge_count
    FROM community_entities ce
    JOIN entities e ON ce.entity_id = e.id
    WHERE ce.community_id = $community_id
    ORDER BY edge_count DESC
)
SELECT * FROM community_members;

-- Get internal edges within community
-- Parameters: $community_id (UUID)
WITH community_members AS (
    SELECT entity_id FROM community_entities WHERE community_id = $community_id
),
internal_edges AS (
    SELECT
        e1.name as src_name,
        ed.edge_type,
        e2.name as dst_name,
        ed.weight,
        ed.confidence
    FROM edges ed
    JOIN entities e1 ON ed.src_entity_id = e1.id
    JOIN entities e2 ON ed.dst_entity_id = e2.id
    WHERE ed.src_entity_id IN (SELECT entity_id FROM community_members)
      AND ed.dst_entity_id IN (SELECT entity_id FROM community_members)
    ORDER BY ed.weight DESC, ed.confidence DESC
)
SELECT * FROM internal_edges;

-- =============================================================================
-- 3. Hierarchical Community Traversal
-- =============================================================================

-- Get community hierarchy (ancestors)
-- Parameters: $community_id (UUID)
WITH RECURSIVE ancestors AS (
    SELECT
        id,
        name,
        level,
        parent_id,
        0 as depth
    FROM communities
    WHERE id = $community_id

    UNION ALL

    SELECT
        c.id,
        c.name,
        c.level,
        c.parent_id,
        a.depth + 1
    FROM communities c
    JOIN ancestors a ON c.id = a.parent_id
)
SELECT * FROM ancestors ORDER BY depth;

-- Get community hierarchy (descendants)
-- Parameters: $community_id (UUID)
WITH RECURSIVE descendants AS (
    SELECT
        id,
        name,
        level,
        parent_id,
        0 as depth
    FROM communities
    WHERE id = $community_id

    UNION ALL

    SELECT
        c.id,
        c.name,
        c.level,
        c.parent_id,
        d.depth + 1
    FROM communities c
    JOIN descendants d ON c.parent_id = d.id
)
SELECT * FROM descendants ORDER BY depth, level;

-- =============================================================================
-- 4. Global Search with Drill-Down
-- =============================================================================

-- Start from top-level, drill down to details
-- Parameters: $query_embedding (vector)
WITH
-- Top-level communities
top_level AS (
    SELECT
        cr.community_id,
        cr.report,
        c.level,
        c.name,
        cr.embedding <=> $query_embedding as distance
    FROM community_reports cr
    JOIN communities c ON cr.community_id = c.id
    WHERE c.level = (SELECT MAX(level) FROM communities)
    ORDER BY cr.embedding <=> $query_embedding
    LIMIT 3
),

-- Child communities of top matches
child_level AS (
    SELECT
        cr.community_id,
        cr.report,
        c.level,
        c.name,
        c.parent_id,
        cr.embedding <=> $query_embedding as distance
    FROM community_reports cr
    JOIN communities c ON cr.community_id = c.id
    WHERE c.parent_id IN (SELECT community_id FROM top_level)
    ORDER BY cr.embedding <=> $query_embedding
),

-- Grandchild (leaf) communities
leaf_level AS (
    SELECT
        cr.community_id,
        cr.report,
        c.level,
        c.name,
        c.parent_id,
        cr.embedding <=> $query_embedding as distance
    FROM community_reports cr
    JOIN communities c ON cr.community_id = c.id
    WHERE c.parent_id IN (SELECT community_id FROM child_level)
    ORDER BY cr.embedding <=> $query_embedding
    LIMIT 10
)

SELECT 'top' as tier, * FROM top_level
UNION ALL
SELECT 'child' as tier, community_id, report, level, name, parent_id, distance FROM child_level
UNION ALL
SELECT 'leaf' as tier, community_id, report, level, name, parent_id, distance FROM leaf_level
ORDER BY tier DESC, distance;

-- =============================================================================
-- 5. Complete Global Search Pipeline
-- =============================================================================

-- Full global search with reports, entities, and evidence
-- Parameters:
--   $query_embedding (vector)
--   $target_level (INT) - default 1 (mid-level)
--   $report_limit (INT) - default 5
--   $evidence_limit (INT) - default 10

WITH
-- Step 1: Find relevant community reports
relevant_communities AS (
    SELECT
        cr.community_id,
        cr.report,
        c.level,
        c.name as community_name,
        cr.embedding <=> $query_embedding as distance
    FROM community_reports cr
    JOIN communities c ON cr.community_id = c.id
    WHERE c.level = COALESCE($target_level, 1)
      AND cr.embedding IS NOT NULL
    ORDER BY cr.embedding <=> $query_embedding
    LIMIT COALESCE($report_limit, 5)
),

-- Step 2: Get key entities from those communities
key_entities AS (
    SELECT DISTINCT
        e.id,
        e.name,
        e.entity_type,
        e.description,
        COUNT(ed.id) as edge_count
    FROM relevant_communities rc
    JOIN community_entities ce ON rc.community_id = ce.community_id
    JOIN entities e ON ce.entity_id = e.id
    LEFT JOIN edges ed ON e.id = ed.src_entity_id OR e.id = ed.dst_entity_id
    GROUP BY e.id, e.name, e.entity_type, e.description
    ORDER BY edge_count DESC
    LIMIT 20
),

-- Step 3: Get evidence chunks from those entities
evidence_chunks AS (
    SELECT DISTINCT
        c.id as chunk_id,
        c.content,
        d.title as document_title,
        d.source_id,
        ce.embedding <=> $query_embedding as distance
    FROM key_entities ke
    JOIN mentions m ON ke.id = m.entity_id
    JOIN chunks c ON m.chunk_id = c.id
    JOIN chunk_embeddings ce ON c.id = ce.chunk_id
    JOIN documents d ON c.document_id = d.id
    ORDER BY ce.embedding <=> $query_embedding
    LIMIT COALESCE($evidence_limit, 10)
)

-- Final output
SELECT json_build_object(
    'community_reports', (
        SELECT json_agg(json_build_object(
            'community_id', community_id,
            'community_name', community_name,
            'report', report,
            'distance', distance
        ) ORDER BY distance)
        FROM relevant_communities
    ),
    'key_entities', (
        SELECT json_agg(json_build_object(
            'id', id,
            'name', name,
            'type', entity_type,
            'description', description,
            'edge_count', edge_count
        ) ORDER BY edge_count DESC)
        FROM key_entities
    ),
    'evidence', (
        SELECT json_agg(json_build_object(
            'chunk_id', chunk_id,
            'content', content,
            'document_title', document_title,
            'source_id', source_id
        ) ORDER BY distance)
        FROM evidence_chunks
    )
) as global_search_result;

-- =============================================================================
-- 6. Community Statistics
-- =============================================================================

-- Overview of community structure
SELECT
    level,
    COUNT(*) as num_communities,
    AVG(member_count)::numeric(10,2) as avg_members,
    MIN(member_count) as min_members,
    MAX(member_count) as max_members
FROM (
    SELECT
        c.level,
        c.id,
        COUNT(ce.entity_id) as member_count
    FROM communities c
    LEFT JOIN community_entities ce ON c.id = ce.community_id
    GROUP BY c.level, c.id
) sub
GROUP BY level
ORDER BY level;

-- Largest communities at each level
WITH ranked_communities AS (
    SELECT
        c.id,
        c.name,
        c.level,
        COUNT(ce.entity_id) as member_count,
        ROW_NUMBER() OVER (PARTITION BY c.level ORDER BY COUNT(ce.entity_id) DESC) as rank
    FROM communities c
    LEFT JOIN community_entities ce ON c.id = ce.community_id
    GROUP BY c.id, c.name, c.level
)
SELECT *
FROM ranked_communities
WHERE rank <= 5
ORDER BY level, rank;
