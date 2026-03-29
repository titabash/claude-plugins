# AI Business Team

AIの専門家チームが協働し、ラフなアイデアから完全な事業提案書を生成するClaude Codeプラグイン。

## 特徴

- **6つのAIロール**が専門分野を分担: 市場調査、競合分析、顧客分析、ビジネスモデル設計、財務計画、戦略策定
- **並列リサーチ**: 3つのAgentが同時にWebSearchで情報収集
- **フレームワーク準拠**: Business Model Canvas、Lean Canvas、Porter's Five Forces、SWOT分析等の標準フレームワークを活用
- **Go/No-Go判定**: 7つの基準で事業化の可否を客観的に評価
- **完全な成果物**: 事業提案書、市場分析レポート、Lean Canvas、収益シミュレーションの4ファイルを生成

## 使い方

```
/business-create アニメ業界の制作進行をDXする事業
/business-create 高齢者の孤独を解決するコミュニティサービス
/business-create 中小企業向けAI経費精算SaaS
/business-create 地方の農家と都市部の消費者を直結するマーケットプレイス
/business-create ペット業界の課題を解決できる新規事業を提案して
```

ドメイン指定だけでもOK:
```
/business-create 教育業界で何かできないか
/business-create 物流のDX
```

## 生成される成果物

```
business-proposal/
├── proposal.md              # 完全な事業提案書（全12セクション）
├── market-analysis.md       # 市場分析レポート（TAM/SAM/SOM、競合、規制）
├── lean-canvas.md           # Lean Canvas（ビジュアル + 詳細）
└── financial-projection.md  # 収益シミュレーション（3年/3シナリオ）
```

## AIチーム構成

| ロール | 担当 | 実行方法 |
|--------|------|---------|
| **Project Manager** | **チーム統括・品質評価・やり直し指示** | **メインスレッド** |
| Market Researcher | 市場規模・成長トレンド・規制環境の調査 | Agent（並列） |
| Industry & Competitive Analyst | 競合マッピング・Porter's 5F・Blue Ocean分析 | Agent（並列） |
| Customer Analyst | ターゲット顧客・JTBD・WTP推定 | Agent（並列） |
| Business Model Designer | BMC・Lean Canvas・収益モデル設計 | メインスレッド |
| Financial Analyst | ユニットエコノミクス・収益予測・損益分岐点 | メインスレッド |
| Strategy Advisor | SWOT・リスク評価・GTM戦略・マイルストーン | メインスレッド |

## 実行フロー

1. **要件理解** - アイデアを分析、不足情報を質問
2. **並列リサーチ** - 3つのAgentが同時に市場・競合・顧客を調査
3. **マネージャー評価** - 各Agentのアウトプットを品質基準で評価、不十分なら具体的フィードバック付きでやり直し指示（最大2回リトライ）
4. **ビジネスモデル設計** - 検証済みリサーチ結果を統合してBMC/Lean Canvasを作成
5. **財務計画** - 3年収益予測、ユニットエコノミクス、損益分岐点
6. **リスク評価・戦略** - SWOT、Go/No-Go判定、GTM戦略
7. **ユーザー確認** - 方向性を確認、必要に応じて調整
8. **成果物生成** - 4つのドキュメントを生成

## ディレクトリ構成

```
ai-business-team/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── business-create.md
├── skills/
│   └── ai-business-team/
│       ├── SKILL.md
│       ├── references/
│       │   ├── market-analysis-methods.md
│       │   ├── business-model-frameworks.md
│       │   ├── competitive-analysis.md
│       │   ├── financial-modeling.md
│       │   ├── risk-assessment.md
│       │   └── industry-research-guide.md
│       └── templates/
│           ├── business-proposal.md
│           ├── market-analysis-report.md
│           └── lean-canvas.md
└── README.md
```

## 注意事項

- 本スキルはAIによるデスクリサーチに基づいて事業提案書を生成します
- 実際の事業化には、一次情報の収集と専門家によるレビューを推奨します
- 財務予測は仮説に基づく推定値であり、実際の数値とは異なる場合があります
- WebSearchの結果に依存するため、最新かつ正確な情報が得られない場合があります
