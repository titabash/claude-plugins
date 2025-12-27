-- =============================================================================
-- GraphRAG Indexes for PostgreSQL
-- =============================================================================
-- Index types:
--   - pgvector: HNSW (recommended) or IVFFlat
--   - PGroonga: Japanese full-text search
--   - B-tree: Standard lookups
--   - GIN: JSONB metadata search
-- =============================================================================

-- =============================================================================
-- pgvector Indexes (Vector Search)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Chunk Embeddings - HNSW (Recommended)
-- -----------------------------------------------------------------------------
-- HNSW: Better recall, slower build, more memory
-- Parameters:
--   m: connections per node (higher = better recall, more memory)
--   ef_construction: search width during build (higher = better quality)
CREATE INDEX IF NOT EXISTS idx_chunk_embeddings_hnsw
ON chunk_embeddings USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- -----------------------------------------------------------------------------
-- Chunk Embeddings - IVFFlat (Alternative for large datasets)
-- -----------------------------------------------------------------------------
-- IVFFlat: Faster build, less memory, needs training
-- Parameters:
--   lists: number of clusters (rule of thumb: sqrt(rows) to rows/1000)
-- Uncomment if using IVFFlat instead of HNSW:
-- CREATE INDEX IF NOT EXISTS idx_chunk_embeddings_ivfflat
-- ON chunk_embeddings USING ivfflat (embedding vector_cosine_ops)
-- WITH (lists = 100);

-- -----------------------------------------------------------------------------
-- Entity Embeddings - HNSW
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_entity_embeddings_hnsw
ON entity_embeddings USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- -----------------------------------------------------------------------------
-- Community Report Embeddings - HNSW
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_community_reports_hnsw
ON community_reports USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- =============================================================================
-- PGroonga Indexes (Full-Text Search)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Chunks Content - Japanese Full-Text
-- -----------------------------------------------------------------------------
-- TokenMecab: Recommended for Japanese
-- NormalizerNFKC130: Unicode normalization
CREATE INDEX IF NOT EXISTS idx_chunks_content_pgroonga
ON chunks USING pgroonga (content)
WITH (
    tokenizer = 'TokenMecab',
    normalizer = 'NormalizerNFKC130'
);

-- -----------------------------------------------------------------------------
-- Entity Name - Full-Text
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_entities_name_pgroonga
ON entities USING pgroonga (name)
WITH (
    tokenizer = 'TokenMecab',
    normalizer = 'NormalizerNFKC130'
);

-- -----------------------------------------------------------------------------
-- Entity Aliases - Array Full-Text
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_entities_aliases_pgroonga
ON entities USING pgroonga (aliases)
WITH (
    tokenizer = 'TokenMecab',
    normalizer = 'NormalizerNFKC130'
);

-- -----------------------------------------------------------------------------
-- Entity Description - Full-Text
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_entities_description_pgroonga
ON entities USING pgroonga (description)
WITH (
    tokenizer = 'TokenMecab',
    normalizer = 'NormalizerNFKC130'
);

-- =============================================================================
-- B-tree Indexes (Standard Lookups)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Documents
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_documents_source_id ON documents(source_id);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON documents(created_at);

-- -----------------------------------------------------------------------------
-- Chunks
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_chunks_document_id ON chunks(document_id);
CREATE INDEX IF NOT EXISTS idx_chunks_document_index ON chunks(document_id, chunk_index);

-- -----------------------------------------------------------------------------
-- Entities
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_entities_type ON entities(entity_type);
CREATE INDEX IF NOT EXISTS idx_entities_name_type ON entities(name, entity_type);

-- -----------------------------------------------------------------------------
-- Edges
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_edges_src ON edges(src_entity_id);
CREATE INDEX IF NOT EXISTS idx_edges_dst ON edges(dst_entity_id);
CREATE INDEX IF NOT EXISTS idx_edges_type ON edges(edge_type);
CREATE INDEX IF NOT EXISTS idx_edges_src_type ON edges(src_entity_id, edge_type);
CREATE INDEX IF NOT EXISTS idx_edges_dst_type ON edges(dst_entity_id, edge_type);
CREATE INDEX IF NOT EXISTS idx_edges_confidence ON edges(confidence);
CREATE INDEX IF NOT EXISTS idx_edges_evidence ON edges(evidence_chunk_id);

-- Time validity indexes (if using time-series)
CREATE INDEX IF NOT EXISTS idx_edges_valid_from ON edges(valid_from_event_id);
CREATE INDEX IF NOT EXISTS idx_edges_valid_to ON edges(valid_to_event_id);

-- -----------------------------------------------------------------------------
-- Mentions
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_mentions_chunk ON mentions(chunk_id);
CREATE INDEX IF NOT EXISTS idx_mentions_entity ON mentions(entity_id);
CREATE INDEX IF NOT EXISTS idx_mentions_chunk_entity ON mentions(chunk_id, entity_id);

-- -----------------------------------------------------------------------------
-- Events
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_events_document ON events(document_id);
CREATE INDEX IF NOT EXISTS idx_events_order ON events(document_id, event_index);

-- -----------------------------------------------------------------------------
-- Communities
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_communities_level ON communities(level);
CREATE INDEX IF NOT EXISTS idx_communities_parent ON communities(parent_id);

-- -----------------------------------------------------------------------------
-- Community Entities
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_community_entities_entity ON community_entities(entity_id);

-- =============================================================================
-- GIN Indexes (JSONB Metadata)
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_documents_metadata ON documents USING gin (metadata);
CREATE INDEX IF NOT EXISTS idx_chunks_metadata ON chunks USING gin (metadata);
CREATE INDEX IF NOT EXISTS idx_entities_metadata ON entities USING gin (metadata);
CREATE INDEX IF NOT EXISTS idx_edges_metadata ON edges USING gin (metadata);
CREATE INDEX IF NOT EXISTS idx_communities_metadata ON communities USING gin (metadata);

-- =============================================================================
-- Partial Indexes (Filtered Search Optimization)
-- =============================================================================

-- High confidence edges only
CREATE INDEX IF NOT EXISTS idx_edges_high_confidence
ON edges(src_entity_id, dst_entity_id, edge_type)
WHERE confidence >= 0.8;

-- Active edges (no valid_to)
CREATE INDEX IF NOT EXISTS idx_edges_active
ON edges(src_entity_id, dst_entity_id, edge_type)
WHERE valid_to_event_id IS NULL;

-- =============================================================================
-- Runtime Settings (Add to postgresql.conf or SET per session)
-- =============================================================================

-- HNSW search parameter (higher = better recall, slower)
-- SET hnsw.ef_search = 100;  -- default: 40

-- IVFFlat search parameter
-- SET ivfflat.probes = 10;   -- default: 1

-- Enable iterative_scan for filtered ANN queries (pgvector 0.8.0+)
-- SET hnsw.iterative_scan = relaxed_order;

-- =============================================================================
-- Maintenance Commands
-- =============================================================================

-- Analyze tables for query optimization
-- ANALYZE chunk_embeddings;
-- ANALYZE chunks;
-- ANALYZE entities;
-- ANALYZE edges;
-- ANALYZE mentions;

-- Reindex concurrently (for production)
-- REINDEX INDEX CONCURRENTLY idx_chunk_embeddings_hnsw;
