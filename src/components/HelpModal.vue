<script setup>
const emit = defineEmits(['close'])
</script>

<template>
  <div class="help-overlay" @click.self="emit('close')">
    <div class="help-modal">
      <button class="help-close" @click="emit('close')">×</button>
      <h2>📖 使い方</h2>
      <ul class="help-list">
        <li><strong>📥 とうろくんへ</strong> — 複数URLをまとめて貼り付けて登録できるフォームに移動できます</li>
        <li><strong>🔍 検索</strong> — 検索ボックスにタイトルやURLの一部を入力すると絞り込めます</li>
        <li><strong>📑 タブ</strong> — 上部のタブでシート（カテゴリ）を切り替えられます</li>
        <li><strong>↕️ 並び替え</strong> — 「日付順」「タイトル順」をクリックすると昇順・降順を切り替えられます</li>
        <li><strong>📅 期間</strong> — 「日・週・月」を選ぶと、その期間のものだけ表示されます</li>
        <li><strong>☆ お気に入り</strong> — カードの星マークをクリックして登録、「お気に入りのみ」で絞り込めます</li>
        <li><strong>🔲 列数</strong> — 1〜3列でカードの表示形式を変更できます</li>
        <li><strong>🖼️ 画像表示</strong> — カードのサムネイル画像をオン/オフできます（読み込みを軽くしたい時に便利）</li>
        <li><strong>🌙 テーマ</strong> — 右上のボタンでダーク／ライト表示を切り替えられます</li>
        <li><strong>💬 意見箱</strong> — 不具合報告や要望はこちらから送信できます</li>
      </ul>
    </div>
  </div>
</template>
