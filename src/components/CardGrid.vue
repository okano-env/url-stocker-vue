<script setup>
import noImage from '../assets/no-image.png'

const props = defineProps({
  cards: Array,
  favorites: Array,
  currentCols: Number,
  showImages: Boolean,
  hasKey: Boolean,
})
const emit = defineEmits(['open-focus', 'toggle-fav', 'copy-url', 'edit-card', 'delete-card'])

function isFav(url) { return props.favorites.includes(url) }
function faviconUrl(domain) { return `https://www.google.com/s2/favicons?domain=${domain}&sz=32` }
function onImgError(e) { e.target.src = noImage }
// カードのサムネイル画像URLを返す（描画完了を待てないSPAはプレースホルダー）
function thumbSrc(c) {
  if (c.url && c.url.includes('vercel.app')) return noImage
  return c.image || noImage
}
</script>

<template>
  <div :class="['grid', `cols-${currentCols}`]">
    <div v-if="cards.length === 0" class="loading">
      <div v-if="cards === null" class="spinner"></div>
      <span v-else>該当なし</span>
    </div>
    <div
      v-for="(c, i) in cards"
      :key="c.url + i"
      :class="['card', { 'is-fav': isFav(c.url) }]"
      @click="emit('open-focus', i)"
    >
      <img v-if="showImages" class="thumbnail" :src="thumbSrc(c)" :alt="c.title" loading="lazy" @error="onImgError">
      <div class="card-top">
        <span class="card-num">{{ c.originalIndex }}</span>
        <img class="favicon" :src="faviconUrl(c.domain)" @error="e => e.target.style.display='none'">
        <span class="domain">{{ c.domain }}</span>
        <span class="date">{{ c.date }}</span>
      </div>
      <div class="card-title-row">
        <div class="title">{{ c.title }}</div>
        <button
          :class="['star-btn', { active: isFav(c.url) }]"
          @click.stop="emit('toggle-fav', c.url)"
        >{{ isFav(c.url) ? '★' : '☆' }}</button>
      </div>
      <button class="copy-btn" @click.stop="emit('copy-url', c.url)">📋 コピー</button>
      <div v-if="hasKey" class="admin-btns">
        <button class="admin-btn edit-btn" @click.stop="emit('edit-card', c)">✏️</button>
        <button class="admin-btn del-btn" @click.stop="emit('delete-card', c)">🗑️</button>
      </div>
    </div>
  </div>
</template>
