---
name: ai-business-team
description: AIの専門家チームが新規事業を創出。ラフなアイデアやドメイン指定から、市場調査・競合分析・顧客分析・ビジネスモデル設計・財務計画・リスク評価を経て完全な事業提案書を生成。Use when the user says "新規事業", "事業提案", "ビジネスプラン", "business plan", "startup idea", or wants to create/evaluate a new business concept.
---

# AI Business Team - 新規事業創出スキル

AIの専門家チームが協働し、**ラフなアイデアから完全な事業提案書を生成する**。
**Project Manager** がチーム全体を統括し、各メンバーのアウトプットを評価。品質基準を満たさない場合はやり直しを指示する。

## AI Team Members

| ロール | 担当フェーズ | 実行方法 |
|--------|------------|---------|
| **Project Manager（プロジェクトマネージャー）** | **Phase 6** | **メインスレッド（全フェーズ統括）** |
| Market Researcher（市場調査員） | Phase 3 | Agent（並列） |
| Industry & Competitive Analyst（業界・競合分析） | Phase 4 | Agent（並列） |
| Customer Analyst（顧客・課題分析） | Phase 5 | Agent（並列） |
| Business Model Designer（ビジネスモデル設計） | Phase 7 | メインスレッド |
| Financial Analyst（財務分析） | Phase 8 | メインスレッド |
| Strategy Advisor（戦略アドバイザー） | Phase 9 | メインスレッド |

**メインスレッドはProject Managerとして振る舞う。** リサーチAgentの成果物を評価し、品質が不十分な場合は具体的なフィードバックと共にやり直しを指示する。

## Output Location

```
{project}/
├── business-proposal/
│   ├── proposal.md              # 完全な事業提案書
│   ├── market-analysis.md       # 市場分析レポート
│   ├── lean-canvas.md           # Lean Canvas
│   └── financial-projection.md  # 収益シミュレーション
```

---

## Execution Flow

### Phase 1: Understand the Seed Idea（要件理解）

**ユーザーの入力 `$ARGUMENTS` を分析**し、以下を抽出:

1. **コアアイデア/対象ドメイン**: 何の事業か
2. **ターゲット顧客仮説**: 誰向けか（B2B/B2C/B2B2C）
3. **課題仮説**: どんな課題を解決するか
4. **既存の制約やリソース**: 技術力、業界知識、資金、ネットワーク等

**AskUserQuestionで不足情報を確認**:

以下の情報で不明な点があれば質問する（全て必須ではない）:

- コアアイデアまたは対象ドメイン（必須。未指定なら確認）
- ターゲット顧客のイメージ（未指定なら「チームが調査します」と伝える）
- 制約条件（地域: 日本限定か海外も含むか、予算規模感、タイムライン）
- 希望するビジネスモデル（SaaS/マーケットプレイス/D2C等。未指定なら「最適なモデルをチームが提案します」）
- 既存のリソースやアセット（技術、業界コネクション、特許等）

**ユーザーの回答を元に「リサーチブリーフ」を作成**:
```
- 事業ドメイン: ...
- 課題仮説: ...
- ターゲット顧客: ...
- 制約条件: ...
- 希望ビジネスモデル: ...
- 既存リソース: ...
```

### Phase 2: Read Reference Documents（リファレンス読込）

以下のリファレンスを全て読み込む:

- [references/market-analysis-methods.md](references/market-analysis-methods.md) - 市場調査手法
- [references/business-model-frameworks.md](references/business-model-frameworks.md) - ビジネスモデルフレームワーク
- [references/competitive-analysis.md](references/competitive-analysis.md) - 競合分析フレームワーク
- [references/financial-modeling.md](references/financial-modeling.md) - 財務モデリング手法
- [references/risk-assessment.md](references/risk-assessment.md) - リスク評価フレームワーク
- [references/industry-research-guide.md](references/industry-research-guide.md) - 業界リサーチガイド

### Phase 3-5: Parallel Research（並列リサーチ）

**3つのAgentを同時に起動し、並列でリサーチを実行する。**
各Agentにはリサーチブリーフ（Phase 1の結果）と担当リファレンスの内容を渡す。

---

### Phase 3: Market Research（市場調査） - Agent①

**Agent起動指示**:

```
あなたは「Market Researcher（市場調査員）」として行動してください。

## リサーチブリーフ
{Phase 1で作成したリサーチブリーフを挿入}

## リファレンス知識
{references/market-analysis-methods.md の内容を挿入}
{references/industry-research-guide.md の内容を挿入}

## タスク
WebSearchとWebFetchを使って以下を調査してください:

1. **市場規模（TAM/SAM/SOM）**
   - トップダウンとボトムアップの両方で推計
   - 数値には必ず出典を付ける

2. **市場成長率**
   - 過去5年のCAGR
   - 今後5年の予測CAGR
   - 成長ドライバー3つ以上

3. **市場トレンド**
   - テクノロジートレンド
   - 消費者/顧客行動トレンド
   - 規制トレンド

4. **規制環境**
   - 該当する主要法規制
   - 許認可の必要性
   - 今後の規制変更予定

## 提出前セルフレビュー
結果を提出する前に、以下のチェックリストで自己評価し、不足があれば自分で補完してから提出すること:
- [ ] TAM/SAM/SOMが全て具体的な数値で記載されているか
- [ ] 全ての数値に出典URL・ソース名が付いているか
- [ ] 成長ドライバーが3つ以上挙げられているか
- [ ] 規制環境に具体的な法律名・制度名が含まれているか
- [ ] 対象ドメインに即した内容で、一般論に終始していないか

## 出力フォーマット
リファレンスの「リサーチ結果の構造化」セクションのフォーマットに従って結果をまとめてください。
日本語で出力してください。全ての数値に出典URLまたはソース名を明記してください。
```

---

### Phase 4: Industry & Competitive Analysis（業界・競合分析） - Agent②

**Agent起動指示**:

```
あなたは「Industry & Competitive Analyst（業界・競合分析アナリスト）」として行動してください。

## リサーチブリーフ
{Phase 1で作成したリサーチブリーフを挿入}

## リファレンス知識
{references/competitive-analysis.md の内容を挿入}
{references/industry-research-guide.md の内容を挿入}

## タスク
WebSearchとWebFetchを使って以下を調査してください:

1. **競合マッピング**
   - 直接競合（同じ課題を同じ方法で解決）: 3社以上
   - 間接競合（同じ課題を別の方法で解決）: 2社以上
   - 代替手段（Excel、手作業、既存のやり方）
   - 各競合の強み/弱み/価格帯/資金調達状況

2. **業界構造分析（Porter's Five Forces）**
   - 5つの要因それぞれをスコアリング（1-5）
   - 各スコアの根拠を明記

3. **市場のギャップと機会**
   - 競合がカバーしていない領域
   - 顧客の不満が大きい領域
   - 技術的に新しいアプローチが可能な領域

4. **Blue Ocean評価（「競合がいる＝Red Ocean」は誤り。価値曲線とERRCで判断せよ）**
   - 競争要因6-8個を列挙し価値曲線の収束度を分析。ERRC全4象限を検討
   - 非顧客層（第1-3層）の規模推定。BOIインデックス4項目で検証

## 提出前セルフレビュー
結果を提出する前に、以下のチェックリストで自己評価し、不足があれば自分で補完してから提出すること:
- [ ] 直接競合が3社以上、具体的な企業名で挙げられているか
- [ ] 各競合の強み/弱みが具体的か（「優れている」等の抽象表現はNG）
- [ ] Porter's Five Forcesの5要因全てにスコア(1-5)と根拠があるか
- [ ] Blue Ocean評価がERRC全4象限+非顧客層分析を含んでいるか（競合の有無だけで判断していないか）
- [ ] 競合情報に出典URLが付いているか

## 出力フォーマット
リファレンスの「リサーチ結果の構造化」セクションのフォーマットに従って結果をまとめてください。
日本語で出力してください。競合情報には出典URLを明記してください。
```

---

### Phase 5: Customer & Problem Analysis（顧客・課題分析） - Agent③

**Agent起動指示**:

```
あなたは「Customer Analyst（顧客・課題分析アナリスト）」として行動してください。

## リサーチブリーフ
{Phase 1で作成したリサーチブリーフを挿入}

## リファレンス知識
{references/industry-research-guide.md の内容を挿入}

## タスク
WebSearchとWebFetchを使って以下を調査してください:

1. **ターゲット顧客の特定**
   - プライマリセグメント（最初に狙う顧客層）
   - セカンダリセグメント（次に拡大する顧客層）
   - 各セグメントの規模推定

2. **顧客の課題（ペインポイント）**
   - 上位3つの課題を特定
   - 各課題の深刻度（Must-have vs Nice-to-have）
   - 課題による具体的な損失（時間、コスト、機会損失）

3. **Jobs-to-be-Done分析**
   - 機能的ジョブ: 顧客が達成したいタスク
   - 感情的ジョブ: 顧客が感じたい感情
   - 社会的ジョブ: 顧客が周囲にどう見られたいか

4. **顧客ペルソナ（1-2人）**
   - デモグラフィック（年齢、役職、業界等）
   - 行動パターン
   - 課題と不満
   - 意思決定プロセス

5. **支払い意欲（WTP）の推定**
   - 類似サービスの価格帯から推定
   - 課題解決によるROIから逆算

## 出力フォーマット
以下の構造で結果をまとめてください:

### 顧客・課題分析結果

#### ターゲットセグメント
| セグメント | 規模 | 課題の深刻度 | 優先度 |
|-----------|------|------------|--------|

#### 顧客ペルソナ
[ペルソナ1の詳細]

#### 課題マップ
| # | 課題 | 深刻度 | 現在の解決策 | 不満点 |
|---|------|--------|------------|--------|

#### Jobs-to-be-Done
| ジョブタイプ | 内容 |
|------------|------|

#### 支払い意欲（WTP）
- 推定価格帯: ...
- 根拠: ...

## 提出前セルフレビュー
結果を提出する前に、以下のチェックリストで自己評価し、不足があれば自分で補完してから提出すること:
- [ ] ターゲットセグメントが具体的な属性（業種・規模・役職等）で定義されているか
- [ ] 課題が3つ以上、深刻度付きで特定されているか
- [ ] 顧客ペルソナが具体的（年齢、役職、行動パターン等）か
- [ ] 支払い意欲（WTP）が価格帯として推定されているか
- [ ] 対象ドメインに即した内容で、一般論に終始していないか

日本語で出力してください。
```

---

### Phase 6: Manager Review（マネージャー評価）

**Project Managerとして、Phase 3-5の全リサーチ結果を評価する。**
品質基準を満たさないアウトプットには具体的なフィードバックを付けてやり直しを指示する。

#### 評価基準（全Agent共通）

各Agentは提出前にセルフレビューを実施済み。マネージャーは以下の観点で最終評価する:

1. **出典の信頼性**: URL・ソース名が明記され、曖昧な記述（「〜と言われている」等）がないか
2. **数値の具体性**: 定性的な記述のみに終始していないか
3. **ドメイン適合性**: リサーチブリーフの対象に即した内容か（一般論NG）
4. **Agent間の整合性**: 市場規模と顧客WTP、競合ギャップと顧客課題に矛盾がないか
5. **セルフレビュー項目の達成度**: 各Agent固有のチェックリスト項目を満たしているか

#### 評価プロセス

1. **判定**: 各Agentに PASS / REVISE / REDO を付与
   - **PASS**: 基準を満たしている → Phase 7に進む
   - **REVISE**: 一部不足 → 不足箇所と改善指示を付けてAgentを再起動
   - **REDO**: 大幅に品質不足 → 問題点を明示して再実行
2. **リトライ上限: 2回**（合計3回まで）。3回目で未達なら不足を明示してPhase 7へ
3. **評価結果をユーザーに報告**:
```
## リサーチ品質レビュー結果
| ロール | 判定 | コメント |
|--------|------|---------|
| Market Researcher | PASS/REVISE/REDO | ... |
| Industry & Competitive Analyst | PASS/REVISE/REDO | ... |
| Customer Analyst | PASS/REVISE/REDO | ... |
```

---

### Phase 7: Business Model Design（ビジネスモデル設計）

**Phase 6でPASS済みの全リサーチ結果を統合し、ビジネスモデルを設計する。**

references/business-model-frameworks.md のフレームワークを活用:

1. **Value Proposition Design**
   - 顧客の課題（Phase 5→6で検証済み）に最も効果的に応えるソリューションを定義
   - UVP（独自の価値提案）を一文で表現

2. **Business Model Canvas作成**
   - 9つの要素を全て埋める
   - 市場データ（Phase 3）と競合データ（Phase 4）に基づく（Phase 6で品質検証済み）

3. **Lean Canvas作成**
   - 特にProblem/Solution Fit を重視
   - Unfair Advantage を競合分析から導出

4. **収益モデル決定**
   - ユーザーの希望（Phase 1）があればそれをベースに
   - なければ市場特性と顧客WTPから最適モデルを選定
   - 価格設定の方針を決定

5. **チャネル戦略**
   - 顧客セグメントに到達する最適チャネル
   - 初期チャネル vs スケール時チャネル

### Phase 8: Financial Projection（財務計画）

references/financial-modeling.md のフレームワークを活用:

1. **ユニットエコノミクスの設計**
   - ARPU: 収益モデル × 価格設定から算出
   - CAC: チャネル戦略とマーケティング投資から推定
   - LTV: ARPU × 粗利率 ÷ 想定チャーンレートから算出
   - LTV/CAC比 と回収期間を計算

2. **3年収益予測（3シナリオ）**
   - 保守的/標準/積極的の3パターン
   - ボトムアップで月次ベースのモデルを構築
   - 顧客数、MRR/ARR、売上、粗利、営業利益

3. **コスト構造**
   - 固定費（人件費、オフィス、ツール）
   - 変動費（インフラ、マーケティング、決済手数料）

4. **損益分岐点分析**
   - 顧客数ベースの損益分岐点
   - 月数ベースの損益分岐点

5. **必要資金の算出**
   - MVP開発費
   - 損益分岐点までの運転資金
   - マーケティング投資
   - 合計必要資金と推奨調達方法

### Phase 9: Risk Assessment & Strategy（リスク評価・戦略）

references/risk-assessment.md のフレームワークを活用:

1. **SWOT分析**
   - 内部要因（Strengths/Weaknesses）: リソース、技術、チーム
   - 外部要因（Opportunities/Threats）: 市場、競合、規制

2. **リスク評価マトリクス**
   - 6カテゴリ（市場/実行/技術/規制/財務/競合）で主要リスクを特定
   - 各リスクの発生確率 × 影響度でスコアリング
   - スコア9以上のリスクには必ず具体的な対策を策定

3. **Go/No-Go定量スコアリング**
   - 7つの基準を各1-5点で評価し、総合スコアで判定:

   | # | 基準 | 1点（No-Go） | 3点（条件付き） | 5点（Go） |
   |---|------|-------------|---------------|----------|
   | 1 | 市場規模 | SAM 10億未満 | SAM 10-100億 | SAM 100億以上 |
   | 2 | 成長率 | 市場縮小 | CAGR 5-10% | CAGR 10%以上 |
   | 3 | 競争環境 | 価値曲線が収束＋ERRC不成立 | ERRC一部成立＋非顧客層あり | ERRC全4象限成立＋大きな非顧客層 |
   | 4 | 課題深刻度 | Nice-to-have | 業務改善レベル | Must-have（深刻） |
   | 5 | 収益性 | LTV/CAC < 1 | LTV/CAC 1-3 | LTV/CAC > 3 |
   | 6 | 実現可能性 | 重大な技術障壁 | 中程度の開発難度 | 既存技術で実現可能 |
   | 7 | 規制環境 | 重大な規制障壁 | ニュートラル | 追い風（補助金等） |

   - **総合スコア**: 7項目の合計（7-35点）
     - **Go（25-35点）**: 事業化を強く推奨
     - **Conditional Go（18-24点）**: 条件付きで推奨（低スコア項目の対策が必要）
     - **No-Go（7-17点）**: 再検討を推奨（ピボットまたは撤退）

4. **Go-to-Market戦略**
   - Phase 1（0-6ヶ月）: MVP開発と初期検証
   - Phase 2（6-18ヶ月）: PMF達成と初期成長
   - Phase 3（18-36ヶ月）: スケール拡大

5. **マイルストーンとKPI**
   - 四半期ごとのマイルストーン設定
   - 追跡すべきKPI（3-5個）の定義と目標値

### Phase 10: Confirm with User（ユーザー確認）

**AskUserQuestionで設計結果を提示し、確認を取る**:

以下を簡潔に提示:

1. **エグゼクティブサマリー**（3-5行）
   - 事業概要、ターゲット市場、提案するビジネスモデル

2. **Lean Canvas**（テキスト版の要約）
   - Problem / Solution / UVP / Customer Segments

3. **主要数値**
   - TAM/SAM/SOM
   - 想定ARR（3年目）
   - 必要投資額
   - 損益分岐点

4. **Go/No-Goスコアカード**
   - 7基準の各スコア（1-5）と総合スコア（7-35）をテーブルで提示
   - 判定: Go / Conditional Go / No-Go

5. **調整ポイント**
   - 「以下の方向性で事業提案書を生成してよろしいですか？」
   - 「修正したい点や、追加で深堀りしたい項目があれば教えてください」

**ユーザーから修正要望があれば**:
- 該当フェーズのリサーチや設計を再実行（Phase 6のマネージャー評価も再度実施）
- 必要に応じて追加のAgent起動

### Phase 11: Generate Final Deliverables（成果物生成）

**テンプレートを使って最終成果物を生成する。**

1. **Read Templates**:
   - [templates/business-proposal.md](templates/business-proposal.md)
   - [templates/market-analysis-report.md](templates/market-analysis-report.md)
   - [templates/lean-canvas.md](templates/lean-canvas.md)

2. **Generate Files**:

   **ファイル1: `business-proposal/proposal.md`**
   - templates/business-proposal.md をベースに
   - Phase 3-9の全結果を反映して{{PLACEHOLDER}}を置換
   - 全セクションを埋める

   **ファイル2: `business-proposal/market-analysis.md`**
   - templates/market-analysis-report.md をベースに
   - Phase 3（市場調査）とPhase 4（競合分析）の結果を反映

   **ファイル3: `business-proposal/lean-canvas.md`**
   - templates/lean-canvas.md をベースに
   - Phase 7（ビジネスモデル設計）の結果を反映

   **ファイル4: `business-proposal/financial-projection.md`**
   - Phase 8（財務計画）の結果を独立したドキュメントとして生成
   - 3シナリオの収益予測テーブル
   - ユニットエコノミクスの詳細
   - 損益分岐点分析
   - 必要資金と推奨調達方法

3. **Completion Report**:

生成完了を報告:

```
## AI Business Team - 事業提案完了

### 生成されたファイル
- `business-proposal/proposal.md` - 完全な事業提案書
- `business-proposal/market-analysis.md` - 市場分析レポート
- `business-proposal/lean-canvas.md` - Lean Canvas
- `business-proposal/financial-projection.md` - 収益シミュレーション

### Go/No-Go判定: {判定結果}

### 次のステップ
1. 提案書の内容をレビューし、仮説の妥当性を検証
2. ターゲット顧客への一次ヒアリングを実施
3. MVP（最小限の実用製品）のプロトタイプを作成
4. 必要に応じて資金調達の準備を開始

### 注意事項
- 本提案書はAIによるデスクリサーチに基づいています
- 実際の事業化には一次情報の収集と専門家のレビューを推奨します
- 財務予測は仮説に基づく推定値です
```

---

## Reference Files

- [references/market-analysis-methods.md](references/market-analysis-methods.md) - TAM/SAM/SOM、市場調査手法
- [references/business-model-frameworks.md](references/business-model-frameworks.md) - BMC、Lean Canvas、収益モデル
- [references/competitive-analysis.md](references/competitive-analysis.md) - Porter's 5F、SWOT、Blue Ocean
- [references/financial-modeling.md](references/financial-modeling.md) - ユニットエコノミクス、収益予測
- [references/risk-assessment.md](references/risk-assessment.md) - リスク分類、Go/No-Go基準
- [references/industry-research-guide.md](references/industry-research-guide.md) - 日本市場データソース

## Template Files

- [templates/business-proposal.md](templates/business-proposal.md) - 事業提案書テンプレート
- [templates/market-analysis-report.md](templates/market-analysis-report.md) - 市場分析レポートテンプレート
- [templates/lean-canvas.md](templates/lean-canvas.md) - Lean Canvasテンプレート
