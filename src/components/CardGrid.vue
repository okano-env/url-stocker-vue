<script setup>
import noImage from '../assets/no-image.png'

const props = defineProps({
  cards: Array,
  favorites: Array,
  currentCols: Number,
  showImages: Boolean,
})
const emit = defineEmits(['open-focus', 'toggle-fav', 'copy-url'])

function isFav(url) { return props.favorites.includes(url) }
function faviconUrl(domain) { return `https://www.google.com/s2/favicons?domain=${domain}&sz=32` }
function onImgError(e) { e.target.src = noImage }
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
      <img v-if="showImages" class="thumbnail" :src="c.image || noImage" :alt="c.title" loading="lazy" @error="onImgError">
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
    </div>
  </div>
</template>
