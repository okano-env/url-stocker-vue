<script setup>
import { computed } from 'vue'

const props = defineProps({
  cards: Array,
  focusIndex: Number,
  favorites: Array,
})
const emit = defineEmits(['close', 'move', 'toggle-fav', 'copy-url'])

const card = computed(() => props.cards[props.focusIndex])
const total = computed(() => props.cards.length)
const counter = computed(() => `${card.value.originalIndex}番  (${props.focusIndex + 1} / ${total.value})`)
const faviconUrl = computed(() => `https://www.google.com/s2/favicons?domain=${card.value.domain}&sz=64`)
const isFav = computed(() => props.favorites.includes(card.value.url))

function isPreviewable(url) {
  return url.includes('surge.sh') || url.includes('vercel.app') || url.includes('netlify.app')
}
const previewable = computed(() => isPreviewable(card.value.url))

const prevCard = computed(() => props.focusIndex > 0 ? props.cards[props.focusIndex - 1] : null)
const nextCard = computed(() => props.focusIndex < total.value - 1 ? props.cards[props.focusIndex + 1] : null)
</script>

<template>
  <div class="focus-overlay" @click.self="emit('close')">
    <!-- テキストカード -->
    <div v-if="!previewable" class="focus-card">
      <div class="focus-counter">{{ counter }}</div>
      <div class="focus-site">
        <img class="focus-favicon" :src="faviconUrl" @error="e => e.target.style.display='none'">
        <span class="focus-domain">🌐 {{ card.domain }}</span>
      </div>
      <div class="focus-title-row">
        <div class="focus-title">{{ card.title }}</div>
        <button :class="['focus-star', { active: isFav }]" @click="emit('toggle-fav', card.url)">
          {{ isFav ? '★' : '☆' }}
        </button>
      </div>
      <div class="focus-date">📅 {{ card.date }}</div>
      <div class="focus-actions">
        <a class="focus-open-btn" :href="card.url" target="_blank" rel="noopener noreferrer">このURLを開く →</a>
        <button class="focus-copy-btn" @click="emit('copy-url', card.url)">📋 コピー</button>
      </div>
      <div class="focus-related">
        <button v-if="prevCard" class="related-item" @click="emit('move', -1)">
          <span class="related-label">← 前の記事</span>
          <span class="related-title">{{ prevCard.title }}</span>
        </button>
        <button v-if="nextCard" class="related-item related-next" @click="emit('move', 1)">
          <span class="related-label">次の記事 →</span>
          <span class="related-title">{{ nextCard.title }}</span>
        </button>
      </div>
      <div class="focus-nav">
        <button class="nav-btn back-btn" @click="emit('close')">一覧に戻る</button>
      </div>
      <span class="focus-back-hint">Escキーでも戻れます</span>
    </div>

    <!-- iframeプレビュー -->
    <div v-else class="focus-preview">
      <div class="preview-header">
        <img class="preview-favicon" :src="faviconUrl" @error="e => e.target.style.display='none'">
        <span class="preview-title">{{ card.title }}</span>
        <span class="preview-counter">{{ counter }}</span>
        <button :class="['preview-star', { active: isFav }]" @click="emit('toggle-fav', card.url)">
          {{ isFav ? '★' : '☆' }}
        </button>
        <button class="preview-copy-btn" @click="emit('copy-url', card.url)">📋 コピー</button>
        <a class="preview-open-btn" :href="card.url" target="_blank" rel="noopener noreferrer">全画面で開く ↗</a>
      </div>
      <iframe class="preview-iframe" :src="card.url" title="preview" allow="scripts"></iframe>
      <div class="focus-related preview-related">
        <button v-if="prevCard" class="related-item" @click="emit('move', -1)">
          <span class="related-label">← 前の記事</span>
          <span class="related-title">{{ prevCard.title }}</span>
        </button>
        <button v-if="nextCard" class="related-item related-next" @click="emit('move', 1)">
          <span class="related-label">次の記事 →</span>
          <span class="related-title">{{ nextCard.title }}</span>
        </button>
      </div>
      <div class="preview-footer">
        <button class="nav-btn back-btn" @click="emit('close')">一覧に戻る（Esc）</button>
      </div>
    </div>
  </div>
</template>
