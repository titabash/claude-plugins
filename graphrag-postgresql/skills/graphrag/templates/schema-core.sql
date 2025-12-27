-- =============================================================================
-- GraphRAG Core Schema for PostgreSQL
-- =============================================================================
-- Required Extensions:
--   - pgvector: Vector similarity search
--   - pgroonga: Japanese full-text search
--   - uuid-ossp: UUID generation
-- =============================================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pgroonga;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- Evidence Layer
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Documents: Source document metadata
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS documents (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id       TEXT NOT NULL,
    title           TEXT,
    content_type    TEXT NOT NULL DEFAULT 'text/plain',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,

    UNIQUE(source_id)
);

COMMENT ON TABLE documents IS 'Source document metadata';
COMMENT ON COLUMN documents.source_id IS 'External identifier (file path, URL, etc.)';
COMMENT ON COLUMN documents.content_type IS 'MIME type: text/plain, text/markdown, application/pdf';
COMMENT ON COLUMN documents.metadata IS 'Additional metadata: author, version, tags, language';

-- -----------------------------------------------------------------------------
-- Chunks: Text fragments from documents
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS chunks (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id     UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    chunk_index     INT NOT NULL,
    content         TEXT NOT NULL,
    token_count     INT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,

    UNIQUE(document_id, chunk_index)
);

COMMENT ON TABLE chunks IS 'Text fragments split from documents';
COMMENT ON COLUMN chunks.chunk_index IS 'Order within document (0-indexed)';
COMMENT ON COLUMN chunks.token_count IS 'Token count for embedding model';
COMMENT ON COLUMN chunks.metadata IS 'Chapter, section, page, spoiler_level, etc.';

-- -----------------------------------------------------------------------------
-- Chunk Embeddings: Vector representations
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS chunk_embeddings (
    chunk_id        UUID PRIMARY KEY REFERENCES chunks(id) ON DELETE CASCADE,
    embedding       vector({{EMBEDDING_DIM}}) NOT NULL,
    model_id        TEXT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE chunk_embeddings IS 'Vector embeddings for chunks';
COMMENT ON COLUMN chunk_embeddings.embedding IS 'Embedding vector (dimension depends on model)';
COMMENT ON COLUMN chunk_embeddings.model_id IS 'Embedding model identifier: text-embedding-3-small, etc.';

-- =============================================================================
-- Graph Layer
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Entities: Extracted concepts and elements
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS entities (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            TEXT NOT NULL,
    entity_type     TEXT NOT NULL,
    aliases         TEXT[] DEFAULT '{}',
    description     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,

    UNIQUE(name, entity_type)
);

COMMENT ON TABLE entities IS 'Extracted concepts: Person, Organization, Technology, etc.';
COMMENT ON COLUMN entities.name IS 'Canonical name';
COMMENT ON COLUMN entities.entity_type IS 'Entity type: Person, Organization, Location, Product, Concept, Event';
COMMENT ON COLUMN entities.aliases IS 'Alternative names, abbreviations';

-- -----------------------------------------------------------------------------
-- Entity Embeddings: Vector representations (optional)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS entity_embeddings (
    entity_id       UUID PRIMARY KEY REFERENCES entities(id) ON DELETE CASCADE,
    embedding       vector({{EMBEDDING_DIM}}) NOT NULL,
    model_id        TEXT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE entity_embeddings IS 'Vector embeddings for entities (for Entity Linking)';

-- -----------------------------------------------------------------------------
-- Edges: Relationships between entities
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS edges (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    src_entity_id       UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    dst_entity_id       UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    edge_type           TEXT NOT NULL,
    weight              REAL NOT NULL DEFAULT 1.0,
    confidence          REAL NOT NULL DEFAULT 1.0,
    description         TEXT,
    evidence_chunk_id   UUID REFERENCES chunks(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata            JSONB NOT NULL DEFAULT '{}'::jsonb
);

COMMENT ON TABLE edges IS 'Relationships between entities';
COMMENT ON COLUMN edges.edge_type IS 'Relationship type: depends_on, friend_of, causes, etc.';
COMMENT ON COLUMN edges.weight IS 'Relationship strength (frequency, importance)';
COMMENT ON COLUMN edges.confidence IS 'Extraction confidence from LLM';
COMMENT ON COLUMN edges.evidence_chunk_id IS 'Source chunk for this relationship';

-- -----------------------------------------------------------------------------
-- Mentions: Entity occurrences in chunks
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mentions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chunk_id        UUID NOT NULL REFERENCES chunks(id) ON DELETE CASCADE,
    entity_id       UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    span_start      INT,
    span_end        INT,
    confidence      REAL NOT NULL DEFAULT 1.0,

    UNIQUE(chunk_id, entity_id, span_start)
);

COMMENT ON TABLE mentions IS 'Entity occurrences within chunks';
COMMENT ON COLUMN mentions.span_start IS 'Character position (start)';
COMMENT ON COLUMN mentions.span_end IS 'Character position (end)';

-- =============================================================================
-- Utility Functions
-- =============================================================================

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_documents_updated_at
    BEFORE UPDATE ON documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_entities_updated_at
    BEFORE UPDATE ON entities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
