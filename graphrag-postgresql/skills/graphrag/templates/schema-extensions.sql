-- =============================================================================
-- GraphRAG Extension Schema for PostgreSQL
-- =============================================================================
-- Optional tables for advanced features:
--   - Time-series support (events, edge validity)
--   - Community detection (Global Search)
-- =============================================================================

-- =============================================================================
-- Time-Series Support
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Events: Timeline management
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS events (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id     UUID REFERENCES documents(id) ON DELETE CASCADE,
    event_index     INT NOT NULL,
    name            TEXT NOT NULL,
    ref             TEXT,
    occurred_at     TIMESTAMPTZ,
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,

    UNIQUE(document_id, event_index)
);

COMMENT ON TABLE events IS 'Timeline events for time-sliced queries';
COMMENT ON COLUMN events.event_index IS 'Monotonic order (chapter, episode number)';
COMMENT ON COLUMN events.ref IS 'Reference string: Chapter 3, Episode 5, etc.';
COMMENT ON COLUMN events.occurred_at IS 'Real timestamp (if applicable)';

-- -----------------------------------------------------------------------------
-- Edge Validity: Time-based relationship validity
-- -----------------------------------------------------------------------------
-- Add columns to edges table
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'edges' AND column_name = 'valid_from_event_id'
    ) THEN
        ALTER TABLE edges ADD COLUMN valid_from_event_id UUID REFERENCES events(id);
        ALTER TABLE edges ADD COLUMN valid_to_event_id UUID REFERENCES events(id);

        COMMENT ON COLUMN edges.valid_from_event_id IS 'Event when this relationship became valid';
        COMMENT ON COLUMN edges.valid_to_event_id IS 'Event when this relationship became invalid (NULL = still valid)';
    END IF;
END $$;

-- =============================================================================
-- Community Layer (for Global Search)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Communities: Hierarchical entity clusters
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS communities (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level           INT NOT NULL,
    parent_id       UUID REFERENCES communities(id) ON DELETE SET NULL,
    name            TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb
);

COMMENT ON TABLE communities IS 'Hierarchical entity clusters (Leiden algorithm output)';
COMMENT ON COLUMN communities.level IS '0=leaf (finest), higher=more abstract';
COMMENT ON COLUMN communities.parent_id IS 'Parent community (for hierarchy)';

-- -----------------------------------------------------------------------------
-- Community Entities: Entity membership
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS community_entities (
    community_id    UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    entity_id       UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,

    PRIMARY KEY (community_id, entity_id)
);

COMMENT ON TABLE community_entities IS 'Entity membership in communities';

-- -----------------------------------------------------------------------------
-- Community Reports: Summaries for Global Search
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS community_reports (
    community_id    UUID PRIMARY KEY REFERENCES communities(id) ON DELETE CASCADE,
    report          TEXT NOT NULL,
    embedding       vector({{EMBEDDING_DIM}}),
    model_id        TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb
);

COMMENT ON TABLE community_reports IS 'Community summaries for Global Search';
COMMENT ON COLUMN community_reports.report IS 'LLM-generated summary of the community';
COMMENT ON COLUMN community_reports.embedding IS 'Vector embedding of the report';

-- =============================================================================
-- Utility Views
-- =============================================================================

-- Entity with edge count
CREATE OR REPLACE VIEW v_entity_stats AS
SELECT
    e.id,
    e.name,
    e.entity_type,
    COUNT(DISTINCT ed.id) as edge_count,
    COUNT(DISTINCT m.chunk_id) as mention_count
FROM entities e
LEFT JOIN edges ed ON e.id = ed.src_entity_id OR e.id = ed.dst_entity_id
LEFT JOIN mentions m ON e.id = m.entity_id
GROUP BY e.id, e.name, e.entity_type;

-- Edge with entity names
CREATE OR REPLACE VIEW v_edges_readable AS
SELECT
    ed.id,
    e1.name as src_name,
    e1.entity_type as src_type,
    ed.edge_type,
    e2.name as dst_name,
    e2.entity_type as dst_type,
    ed.weight,
    ed.confidence,
    ed.description
FROM edges ed
JOIN entities e1 ON ed.src_entity_id = e1.id
JOIN entities e2 ON ed.dst_entity_id = e2.id;

-- Community hierarchy
CREATE OR REPLACE VIEW v_community_hierarchy AS
WITH RECURSIVE tree AS (
    SELECT
        id,
        name,
        level,
        parent_id,
        ARRAY[id] as path,
        0 as depth
    FROM communities
    WHERE parent_id IS NULL

    UNION ALL

    SELECT
        c.id,
        c.name,
        c.level,
        c.parent_id,
        t.path || c.id,
        t.depth + 1
    FROM communities c
    JOIN tree t ON c.parent_id = t.id
)
SELECT * FROM tree;

-- Orphan entities (not in any community)
CREATE OR REPLACE VIEW v_orphan_entities AS
SELECT e.*
FROM entities e
LEFT JOIN community_entities ce ON e.id = ce.entity_id
WHERE ce.community_id IS NULL;

-- Low confidence edges (for review)
CREATE OR REPLACE VIEW v_low_confidence_edges AS
SELECT
    ed.*,
    e1.name as src_name,
    e2.name as dst_name
FROM edges ed
JOIN entities e1 ON ed.src_entity_id = e1.id
JOIN entities e2 ON ed.dst_entity_id = e2.id
WHERE ed.confidence < 0.7
ORDER BY ed.confidence;
