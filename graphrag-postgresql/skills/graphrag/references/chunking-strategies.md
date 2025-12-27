# Chunking Strategies Guide

## Overview

文書をChunkに分割する戦略。GraphRAGの品質に直結する重要な処理。

## Basic Principles

### 1. Chunk Size

| Size | Tokens | Use Case |
|------|--------|----------|
| Small | 100-200 | 高精度検索、FAQ |
| Medium | 300-500 | 汎用（推奨） |
| Large | 500-1000 | 長文コンテキスト |

### 2. Overlap

```
Chunk 1: [============================]
Chunk 2:              [============================]
                      ^^^^^^^^^^^
                       Overlap
```

- **推奨**: 10-20% のオーバーラップ
- 文脈の断絶を防ぐ
- Entity/Edgeが境界で分断されるのを防止

### 3. Boundary Detection

良いChunk境界:
- 段落の終わり
- セクションの区切り
- 場面転換
- 話者の変更

悪いChunk境界:
- 文の途中
- 引用の途中
- コードブロックの途中

## Use Case Specific Strategies

### Technical Documents（技術文書）

```python
def chunk_technical_doc(text, max_tokens=400, overlap=50):
    """
    技術文書のチャンキング
    """
    chunks = []

    # 1. セクション分割を優先
    sections = split_by_headers(text)

    for section in sections:
        # 2. セクションが大きすぎる場合は段落で分割
        if count_tokens(section) > max_tokens:
            paragraphs = section.split('\n\n')
            current_chunk = []
            current_tokens = 0

            for para in paragraphs:
                para_tokens = count_tokens(para)

                if current_tokens + para_tokens > max_tokens:
                    # チャンクを保存
                    chunks.append('\n\n'.join(current_chunk))
                    # オーバーラップ
                    current_chunk = current_chunk[-1:] if current_chunk else []
                    current_tokens = count_tokens('\n\n'.join(current_chunk))

                current_chunk.append(para)
                current_tokens += para_tokens

            if current_chunk:
                chunks.append('\n\n'.join(current_chunk))
        else:
            chunks.append(section)

    return chunks
```

**ポイント**:
- ヘッダー階層を保持
- コードブロックは分割しない
- 箇条書きは一塊で

### Story/Narrative（物語）

```python
def chunk_story(text, max_tokens=500, overlap=100):
    """
    物語のチャンキング（場面単位）
    """
    chunks = []

    # 1. 章で分割
    chapters = split_by_chapter(text)

    for chapter in chapters:
        # 2. 場面転換で分割
        scenes = split_by_scene_change(chapter)

        for scene in scenes:
            if count_tokens(scene) > max_tokens:
                # 3. 段落で分割（場面内）
                chunks.extend(split_by_paragraph(scene, max_tokens, overlap))
            else:
                chunks.append(scene)

    return chunks

def split_by_scene_change(text):
    """
    場面転換の検出
    """
    # 空行3つ以上、区切り線、時間経過表現などで分割
    patterns = [
        r'\n{3,}',           # 空行3つ以上
        r'\n[\*\-=]{3,}\n',  # 区切り線
        r'\n\n.*?(数時間後|翌日|その夜|一週間後).*?\n\n',  # 時間経過
    ]
    # ...
```

**ポイント**:
- 場面（scene）単位を優先
- 会話の途中で切らない
- キャラクター名の初出を含める

### Manga/Comic（マンガ）

```python
def chunk_manga(pages, max_panels=10):
    """
    マンガのチャンキング（コマ/吹き出し単位）
    """
    chunks = []
    current_chunk = {
        'panels': [],
        'dialogues': [],
        'page_range': []
    }

    for page in pages:
        for panel in page.panels:
            # 場面転換を検出
            if is_scene_change(panel, current_chunk):
                if current_chunk['panels']:
                    chunks.append(format_manga_chunk(current_chunk))
                current_chunk = new_chunk()

            current_chunk['panels'].append(panel)
            current_chunk['dialogues'].extend(panel.dialogues)

            if len(current_chunk['panels']) >= max_panels:
                chunks.append(format_manga_chunk(current_chunk))
                current_chunk = new_chunk()

    return chunks

def format_manga_chunk(chunk):
    """
    マンガChunkをテキスト化
    """
    text_parts = []
    text_parts.append(f"[ページ {chunk['page_range'][0]}-{chunk['page_range'][-1]}]")

    for panel in chunk['panels']:
        text_parts.append(f"コマ: {panel.description}")
        for dialogue in panel.dialogues:
            text_parts.append(f"  {dialogue.speaker}: 「{dialogue.text}」")

    return '\n'.join(text_parts)
```

**ポイント**:
- コマ（panel）を最小単位に
- 吹き出しのテキストを構造化
- ページ/コマ番号をメタデータに

### Meeting Minutes（議事録）

```python
def chunk_meeting(transcript, max_tokens=400):
    """
    議事録のチャンキング（議題/発言単位）
    """
    chunks = []

    # 1. 議題（アジェンダ項目）で分割
    agenda_items = split_by_agenda(transcript)

    for item in agenda_items:
        # 2. 議題が大きい場合は発言者交代で分割
        if count_tokens(item.content) > max_tokens:
            speaker_blocks = split_by_speaker(item.content)

            current_chunk = []
            current_tokens = 0

            for block in speaker_blocks:
                block_tokens = count_tokens(block)

                if current_tokens + block_tokens > max_tokens:
                    chunks.append({
                        'content': '\n'.join(current_chunk),
                        'metadata': {
                            'agenda_item': item.title,
                            'participants': extract_speakers(current_chunk)
                        }
                    })
                    current_chunk = []
                    current_tokens = 0

                current_chunk.append(block)
                current_tokens += block_tokens

            if current_chunk:
                chunks.append({
                    'content': '\n'.join(current_chunk),
                    'metadata': {
                        'agenda_item': item.title,
                        'participants': extract_speakers(current_chunk)
                    }
                })
        else:
            chunks.append({
                'content': item.content,
                'metadata': {'agenda_item': item.title}
            })

    return chunks
```

**ポイント**:
- 議題単位を優先
- 発言者情報を保持
- 決定事項/アクションを明示

### FAQ/Knowledge Base（FAQ）

```python
def chunk_faq(documents, max_tokens=300):
    """
    FAQ/ナレッジベースのチャンキング
    """
    chunks = []

    for doc in documents:
        # Q&Aペアを1チャンクに
        qa_pairs = extract_qa_pairs(doc)

        for qa in qa_pairs:
            qa_content = f"Q: {qa.question}\n\nA: {qa.answer}"

            if count_tokens(qa_content) <= max_tokens:
                chunks.append({
                    'content': qa_content,
                    'metadata': {
                        'type': 'qa',
                        'category': qa.category,
                        'keywords': qa.keywords
                    }
                })
            else:
                # 回答が長い場合は分割
                answer_chunks = split_answer(qa.answer, max_tokens - count_tokens(f"Q: {qa.question}\n\nA: "))
                for i, ans_chunk in enumerate(answer_chunks):
                    chunks.append({
                        'content': f"Q: {qa.question}\n\nA: {ans_chunk}",
                        'metadata': {
                            'type': 'qa',
                            'part': i + 1
                        }
                    })

    return chunks
```

**ポイント**:
- Q&Aペアは分割しない
- カテゴリ/タグをメタデータに
- 関連質問へのリンクを保持

### Incident Reports（障害報告）

```python
def chunk_incident(report, max_tokens=400):
    """
    障害報告のチャンキング
    """
    chunks = []

    # 構造化セクションごとに分割
    sections = {
        'summary': extract_section(report, '概要'),
        'symptoms': extract_section(report, '症状'),
        'timeline': extract_section(report, 'タイムライン'),
        'root_cause': extract_section(report, '原因'),
        'solution': extract_section(report, '対応'),
        'prevention': extract_section(report, '再発防止'),
    }

    for section_name, content in sections.items():
        if content:
            if count_tokens(content) > max_tokens:
                # 長いセクションは段落で分割
                sub_chunks = split_by_paragraph(content, max_tokens)
                for i, sub in enumerate(sub_chunks):
                    chunks.append({
                        'content': sub,
                        'metadata': {
                            'section': section_name,
                            'part': i + 1,
                            'incident_id': report.id
                        }
                    })
            else:
                chunks.append({
                    'content': content,
                    'metadata': {
                        'section': section_name,
                        'incident_id': report.id
                    }
                })

    return chunks
```

**ポイント**:
- セクション構造を保持
- 原因→対応の因果関係を維持
- タイムラインは時系列を保持

## Metadata Design

### Common Metadata

```json
{
  "document_id": "doc_xxx",
  "chunk_index": 5,
  "section": "第3章",
  "page": 42,
  "created_at": "2024-01-15",
  "language": "ja"
}
```

### Use Case Specific

**Story**:
```json
{
  "chapter": 3,
  "scene": "battle_scene",
  "characters": ["Alice", "Bob"],
  "spoiler_level": 3
}
```

**Technical**:
```json
{
  "category": "api",
  "version": "2.0",
  "tags": ["authentication", "oauth"],
  "code_language": "python"
}
```

**Incident**:
```json
{
  "incident_id": "INC-2024-001",
  "severity": "critical",
  "affected_service": "payment",
  "section": "root_cause"
}
```

## Quality Assurance

### Validation Rules

```python
def validate_chunk(chunk):
    errors = []

    # 1. 最小長チェック
    if count_tokens(chunk.content) < 20:
        errors.append("Chunk too short")

    # 2. 最大長チェック
    if count_tokens(chunk.content) > 1000:
        errors.append("Chunk too long")

    # 3. 文の完全性
    if not chunk.content.strip().endswith(('.', '。', '!', '?', '！', '？')):
        errors.append("Chunk may be truncated")

    # 4. コードブロックの完全性
    if chunk.content.count('```') % 2 != 0:
        errors.append("Incomplete code block")

    return errors
```

### Metrics

```sql
-- Chunk統計
SELECT
    COUNT(*) as total_chunks,
    AVG(token_count) as avg_tokens,
    MIN(token_count) as min_tokens,
    MAX(token_count) as max_tokens,
    STDDEV(token_count) as stddev_tokens
FROM chunks;

-- 極端なChunkを検出
SELECT id, content, token_count
FROM chunks
WHERE token_count < 50 OR token_count > 800
ORDER BY token_count;
```
