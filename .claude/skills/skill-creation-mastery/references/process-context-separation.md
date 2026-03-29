# Process/Context分離原則

SKILL.mdにはProcess（手順）、references/にはContext（知識）を配置する設計原則。

## 定義

| 種別 | 定義 | 配置先 |
|------|------|--------|
| **Process** | Claudeが従うべき順序付き手順、条件分岐、実行フロー | SKILL.md |
| **Context** | 判断に必要な背景知識、ルール、例、データ | references/ |

## 判断フレームワーク

以下の質問で判断する:

```
Q: この情報は「何をするか」を示しているか、「どう判断するか」の根拠か？

「何をするか」→ Process → SKILL.md
「どう判断するか」→ Context → references/
```

### Processの特徴

- **順序がある**: Phase 1 → Phase 2 → Phase 3
- **動詞で始まる**: 「読み込む」「生成する」「確認する」「報告する」
- **条件分岐**: 「もし〜なら」「ユーザーがXを選択した場合」
- **ツール指示**: 「Read references/xxx.md」「Write to output/」
- **ユーザー対話**: 「AskUserQuestionで確認」

### Contextの特徴

- **宣言的**: 「カラーシステムはHSLベースが推奨」
- **名詞中心**: 「パターン」「ルール」「仕様」「例」
- **参照される**: Processから「〜を参照して判断」と参照される
- **独立読解可能**: そのファイルだけ読んでも理解できる

## 具体例

### 例1: GraphRAG PostgreSQLスキル

**SKILL.md（Process）**:
```markdown
### Phase 3: Entity/Edge型を設計
1. ユーザー要件を分析
2. references/use-cases.md を参照し、類似パターンを特定
3. カスタムEntity型とEdge型を設計
4. AskUserQuestionで設計を確認
```

**references/use-cases.md（Context）**:
```markdown
## 物語・コンテンツ管理
| Entity型 | 説明 |
|----------|------|
| Character | 登場人物 |
| Location | 場所 |
| Item | アイテム |

| Edge型 | 説明 |
|--------|------|
| friend_of | 友好関係 |
| enemy_of | 敵対関係 |
...
```

→ SKILL.mdは「何をするか」（設計して確認する）、references/は「何を知っていれば設計できるか」（パターン集）。

### 例2: UI Design Guidelineスキル

**SKILL.md（Process）**:
```markdown
### Phase 4.2: references/colors.md を生成
references/color-systems.md を読み、以下を含むファイルを生成:
- Primary color palette (50-900)
- Semantic colors
- Contrast validation
```

**references/color-systems.md（Context）**:
```markdown
## HSLベースのカラー生成
### Step 1: Primary Hue選択
ブランドカラーからHue値を抽出...

### 50-900スケール生成ルール
- 50: Lightnessを95%に
- 100: Lightnessを90%に
...

### WCAG コントラスト比
- AA: 4.5:1 (通常テキスト)
- AAA: 7:1 (通常テキスト)
```

## 境界ケース

### サマリーはSKILL.mdに含めてよい

references/の内容の「要約」はSKILL.mdに含めてよい。ただし詳細はreferences/に委ねる。

```markdown
# SKILL.md内（OK）
### Naming Conventions
- kebab-case、最大64文字
- 詳細 → references/naming-guide.md
```

### テーブルは行数で判断

| 行数 | 配置先 |
|------|--------|
| 5行以内 | SKILL.md |
| 6-20行 | 判断による |
| 20行以上 | references/ |

### 条件付きContext読み込み

Contextをすべてのケースで読む必要がない場合、条件付きにする:

```markdown
### Phase 2: 設計
**日本語プロジェクトの場合のみ**:
Read [references/japanese-typography.md] を参照。

**アクセシビリティAAA対応の場合のみ**:
Read [references/accessibility-aaa.md] を参照。
```

## 分離チェックリスト

SKILL.mdの各セクションに対して:

- [ ] 順序付きステップが含まれているか → **Process OK**
- [ ] 20行以上のパターン集/例/データが含まれていないか → **references/へ移動**
- [ ] 「〜の場合は」で始まる詳細ルールが多くないか → **references/へ移動**
- [ ] セクションを削除してもフローが理解できるか → **削除可能ならreferences/候補**

## アンチパターン

### 1. Contextの直接埋め込み
```markdown
# 悪い例（SKILL.md内）
## カラーシステム
HSLベースのカラー生成では、まずPrimary Hueを選択し...
（以下、100行のカラー理論）
```

### 2. Processの外部化
```markdown
# 悪い例（SKILL.md内）
実行手順はreferences/workflow.mdを参照。
（← SKILL.mdが空っぽになり、手順が把握できない）
```

### 3. 混在
```markdown
# 悪い例（SKILL.md内）
### Phase 2: カラー設計
HSLベースが推奨される理由は...（50行のContext）
上記を踏まえて、以下の手順で設計する:（10行のProcess）
```

→ 正しくは: 10行のProcessをSKILL.mdに、50行のContextをreferences/に。
