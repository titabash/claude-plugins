---
description: Generate a comprehensive business proposal with an AI specialist team. Describe your idea or target domain in natural language.
argument-hint: "<事業アイデアや対象ドメインの説明>"
---

# AI Business Team - 新規事業創出

**AIの専門家チームがラフなアイデアから完全な事業提案書を生成します。**

## Arguments

`$ARGUMENTS`: 事業アイデアまたは対象ドメインの説明（自然言語）

### 例

```
/business-create アニメ業界の制作進行をDXする事業
/business-create 高齢者の孤独を解決するコミュニティサービス
/business-create 中小企業向けAI経費精算SaaS
/business-create 地方の農家と都市部の消費者を直結するマーケットプレイス
/business-create ペット業界の課題を解決できる新規事業を提案して
```

## AIチーム構成

| ロール | 担当 |
|--------|------|
| **Project Manager** | **チーム統括・品質評価・やり直し指示** |
| Market Researcher | 市場規模・成長トレンド・規制環境の調査 |
| Industry & Competitive Analyst | 競合マッピング・業界構造分析 |
| Customer Analyst | ターゲット顧客・課題・ニーズの深掘り |
| Business Model Designer | ビジネスモデル・収益構造の設計 |
| Financial Analyst | 収益予測・ユニットエコノミクス・損益分岐点分析 |
| Strategy Advisor | リスク評価・GTM戦略・マイルストーン策定 |

## Output

```
{project}/
├── business-proposal/
│   ├── proposal.md              # 完全な事業提案書
│   ├── market-analysis.md       # 市場分析レポート
│   ├── lean-canvas.md           # Lean Canvas
│   └── financial-projection.md  # 収益シミュレーション
```

## Execution

1. ユーザーの `$ARGUMENTS` を分析し、不足情報があれば質問
2. リファレンスドキュメントを読込
3. **3つのAIエージェントが並列でリサーチ**（市場調査・競合分析・顧客分析）
4. **Project Managerが各リサーチの品質を評価**（不十分ならやり直し指示）
5. 検証済みリサーチ結果を統合してビジネスモデルを設計
6. 財務計画・リスク評価を実施
7. ユーザーに確認後、最終成果物を生成
