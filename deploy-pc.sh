#!/bin/bash
# url-stocker-pc.vercel.app への正しいデプロイ手順
# 使い方: ./deploy-pc.sh

set -e

VERCEL_TOKEN="${VERCEL_TOKEN}"
TARGET_ALIAS="url-stocker-pc.vercel.app"

echo "▶ 現在のブランチを確認..."
CURRENT=$(git branch --show-current)
if [ "$CURRENT" != "admin" ]; then
  echo "❌ adminブランチにいません（現在: $CURRENT）"
  echo "   git checkout admin してから実行してください"
  exit 1
fi

echo "▶ adminブランチをpush..."
git push

echo "▶ Vercelにプロダクションデプロイ中..."
DEPLOY_OUTPUT=$(npx vercel --prod --token "$VERCEL_TOKEN" --yes 2>&1)
echo "$DEPLOY_OUTPUT"

DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -o 'https://url-stocker-pc-no-shikumi-[^ ]*\.vercel\.app' | head -1)

if [ -z "$DEPLOY_URL" ]; then
  echo "❌ デプロイURLの取得に失敗しました"
  exit 1
fi

echo "▶ エイリアスを更新: $DEPLOY_URL → $TARGET_ALIAS"
npx vercel alias set "$DEPLOY_URL" "$TARGET_ALIAS" --token "$VERCEL_TOKEN"

echo ""
echo "✅ 完了！ https://$TARGET_ALIAS を確認してください"
