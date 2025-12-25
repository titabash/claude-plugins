#!/bin/bash

# UIデザインガイドライン作成プラグインの検証スクリプト

echo "========================================="
echo "プラグイン構造の検証"
echo "========================================="
echo ""

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
ERRORS=0

# 必須ファイルのチェック
echo "1. 必須ファイルの存在確認..."

required_files=(
    ".claude-plugin/plugin.json"
    "skills/ui-design-guideline/SKILL.md"
    "skills/ui-design-guideline/references/color-systems.md"
    "skills/ui-design-guideline/references/typography-scales.md"
    "skills/ui-design-guideline/references/spacing-systems.md"
    "skills/ui-design-guideline/references/component-patterns.md"
    "skills/ui-design-guideline/references/accessibility.md"
    "skills/ui-design-guideline/templates/guideline-template.md"
    "skills/ui-design-guideline/templates/component-template.md"
    "skills/ui-design-guideline/templates/design-tokens.json"
    "README.md"
)

for file in "${required_files[@]}"; do
    if [ -f "$PLUGIN_DIR/$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file が見つかりません"
        ((ERRORS++))
    fi
done

echo ""

# plugin.jsonの検証
echo "2. plugin.jsonの検証..."
if command -v python3 &> /dev/null; then
    if python3 -m json.tool "$PLUGIN_DIR/.claude-plugin/plugin.json" > /dev/null 2>&1; then
        echo "  ✓ plugin.jsonは有効なJSON形式です"
    else
        echo "  ✗ plugin.jsonが無効なJSON形式です"
        ((ERRORS++))
    fi
else
    echo "  ⚠ Python3が見つからないため、JSON検証をスキップ"
fi

# plugin.jsonの必須フィールド確認
if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    if grep -q '"name"' "$PLUGIN_DIR/.claude-plugin/plugin.json" && \
       grep -q '"version"' "$PLUGIN_DIR/.claude-plugin/plugin.json" && \
       grep -q '"skills"' "$PLUGIN_DIR/.claude-plugin/plugin.json"; then
        echo "  ✓ plugin.jsonに必須フィールドが含まれています"
    else
        echo "  ✗ plugin.jsonに必須フィールドが不足しています"
        ((ERRORS++))
    fi
fi

echo ""

# SKILL.mdのYAMLフロントマター確認
echo "3. SKILL.mdのYAMLフロントマター確認..."
if [ -f "$PLUGIN_DIR/skills/ui-design-guideline/SKILL.md" ]; then
    if head -n 4 "$PLUGIN_DIR/skills/ui-design-guideline/SKILL.md" | grep -q "^---$" && \
       head -n 4 "$PLUGIN_DIR/skills/ui-design-guideline/SKILL.md" | grep -q "name:" && \
       head -n 4 "$PLUGIN_DIR/skills/ui-design-guideline/SKILL.md" | grep -q "description:"; then
        echo "  ✓ SKILL.mdに有効なYAMLフロントマターがあります"
    else
        echo "  ✗ SKILL.mdのYAMLフロントマターが無効です"
        ((ERRORS++))
    fi
fi

echo ""

# ファイルサイズの確認
echo "4. ファイルサイズの確認..."
total_lines=$(find "$PLUGIN_DIR" -type f \( -name "*.md" -o -name "*.json" \) -exec wc -l {} + | tail -n 1 | awk '{print $1}')
echo "  ✓ 合計 $total_lines 行のコンテンツ"

echo ""

# 結果表示
echo "========================================="
if [ $ERRORS -eq 0 ]; then
    echo "✅ 検証成功！プラグインは正しく構成されています。"
    echo ""
    echo "次のステップ："
    echo "1. プラグインをClaude Codeのプラグインディレクトリにコピー："
    echo "   cp -r $PLUGIN_DIR ~/.claude/plugins/"
    echo ""
    echo "2. Claude Codeを再起動"
    echo ""
    echo "3. Claude Codeで以下のように依頼："
    echo "   'UIデザインガイドラインを作成してください'"
else
    echo "❌ $ERRORS 個のエラーが見つかりました。"
    echo "上記のエラーを修正してください。"
fi
echo "========================================="

exit $ERRORS
