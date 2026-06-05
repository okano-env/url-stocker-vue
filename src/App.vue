<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import Toolbar from './components/Toolbar.vue'
import CardGrid from './components/CardGrid.vue'
import FocusModal from './components/FocusModal.vue'

const GAS_URL = 'https://script.google.com/macros/s/AKfycbxmuUCneFf06w2tFb-fuojnDLWrH6APH-pJHWg_zit7cf1wioKCaG32mZRAuoPxHNu5/exec'
const CACHE_TTL = 3 * 60 * 1000

// ── URL params ──
const params = new URLSearchParams(location.search)
function getSheetFromHash() {
  return decodeURIComponent(location.hash.slice(1))
}
const currentSheet = ref(getSheetFromHash())
const showTabs = currentSheet.value
  ? params.get('tabs') === 'on'
  : params.get('tabs') !== 'off'

// ── テーマ ──
const theme = ref(localStorage.getItem('url-stocker-theme') || 'dark')
function applyTheme(t) {
  theme.value = t
  document.documentElement.setAttribute('data-theme', t)
  localStorage.setItem('url-stocker-theme', t)
}
function toggleTheme() {
  applyTheme(theme.value === 'dark' ? 'light' : 'dark')
}
applyTheme(theme.value)

// ── データ ──
const allCards = ref([])
const sheets = ref([])
const sheetName = ref('')
const syncing = ref(false)

// ── お気に入り ──
const favorites = ref(JSON.parse(localStorage.getItem('url-stocker-fav') || '[]'))
function isFav(url) { return favorites.value.includes(url) }
function toggleFav(url) {
  const idx = favorites.value.indexOf(url)
  if (idx === -1) favorites.value.push(url)
  else favorites.value.splice(idx, 1)
  localStorage.setItem('url-stocker-fav', JSON.stringify(favorites.value))
  showToast(idx === -1 ? '★ お気に入りに追加しました' : '☆ お気に入りを解除しました')
}

// ── ソート ──
const currentSort = ref('date')
const sortDir = ref({ date: 'asc', title: 'asc' })
function setSort(type) {
  if (currentSort.value === type) {
    sortDir.value[type] = sortDir.value[type] === 'desc' ? 'asc' : 'desc'
  } else {
    currentSort.value = type
  }
}

// ── 日付ナビ ──
const navMode = ref('all')
const navDate = ref(new Date())
function getWeekStart(d) {
  const day = d.getDay()
  const diff = day === 0 ? -6 : 1 - day
  return new Date(d.getFullYear(), d.getMonth(), d.getDate() + diff)
}
function getNavRange() {
  const d = navDate.value
  if (navMode.value === 'day') {
    const s = new Date(d.getFullYear(), d.getMonth(), d.getDate())
    return { start: s, end: s }
  }
  if (navMode.value === 'week') {
    const ws = getWeekStart(d)
    const we = new Date(ws.getFullYear(), ws.getMonth(), ws.getDate() + 6)
    return { start: ws, end: we }
  }
  if (navMode.value === 'month') {
    return {
      start: new Date(d.getFullYear(), d.getMonth(), 1),
      end: new Date(d.getFullYear(), d.getMonth() + 1, 0)
    }
  }
  return null
}
function setNavMode(mode) { navMode.value = mode; navDate.value = new Date() }
function navStep(dir) {
  const d = new Date(navDate.value)
  if (navMode.value === 'day') d.setDate(d.getDate() + dir)
  if (navMode.value === 'week') d.setDate(d.getDate() + dir * 7)
  if (navMode.value === 'month') d.setMonth(d.getMonth() + dir)
  navDate.value = d
}
function goToday() { navDate.value = new Date() }

// ── フィルター ──
const searchQuery = ref('')
const favFilterOn = ref(false)
function toggleFavFilter() { favFilterOn.value = !favFilterOn.value }

function matchesDateFilter(card) {
  if (navMode.value === 'all') return true
  const range = getNavRange()
  const parts = card.date.split('/')
  const cardDay = new Date(+parts[0], +parts[1] - 1, +parts[2])
  return cardDay >= range.start && cardDay <= range.end
}

const filteredCards = computed(() => {
  const q = searchQuery.value.toLowerCase()
  let base = allCards.value.filter(c => {
    const matchQ = !q || c.title.toLowerCase().includes(q) || c.url.toLowerCase().includes(q)
    const matchFav = !favFilterOn.value || isFav(c.url)
    return matchQ && matchFav && matchesDateFilter(c)
  })
  const dir = sortDir.value[currentSort.value] === 'desc' ? -1 : 1
  return base.slice().sort((a, b) => {
    if (currentSort.value === 'date') {
      const d = dir * a.date.localeCompare(b.date)
      return d !== 0 ? d : a.originalIndex - b.originalIndex
    }
    return dir * a.title.localeCompare(b.title, 'ja')
  })
})

const metaText = computed(() => {
  const total = allCards.value.length
  const filtered = filteredCards.value.length
  return `全 ${total} 件` + (filtered < total ? `（絞り込み中: ${filtered} 件）` : '')
})

// ── 列数 ──
const currentCols = ref(2)

// ── トースト ──
const toastMsg = ref('')
const toastVisible = ref(false)
let toastTimer = null
function showToast(msg) {
  toastMsg.value = msg
  toastVisible.value = true
  clearTimeout(toastTimer)
  toastTimer = setTimeout(() => { toastVisible.value = false }, 2200)
}

// ── URLコピー ──
function copyUrl(url) {
  navigator.clipboard.writeText(url).then(() => showToast('📋 URLをコピーしました'))
}

// ── スクロールトップ ──
const showScrollTop = ref(false)
function onScroll() { showScrollTop.value = window.scrollY > 320 }
onMounted(() => window.addEventListener('scroll', onScroll))
onUnmounted(() => window.removeEventListener('scroll', onScroll))

// ── フォーカスモード ──
const focusIndex = ref(0)
const focusActive = ref(false)
function openFocus(idx) { focusIndex.value = idx; focusActive.value = true }
function closeFocus() { focusActive.value = false }
function focusMove(dir) {
  const next = focusIndex.value + dir
  if (next >= 0 && next < filteredCards.value.length) focusIndex.value = next
}

function onKeydown(e) {
  if (!focusActive.value) return
  if (e.key === 'ArrowRight') focusMove(1)
  else if (e.key === 'ArrowLeft') focusMove(-1)
  else if (e.key === 'Escape') closeFocus()
}
onMounted(() => document.addEventListener('keydown', onKeydown))
onUnmounted(() => document.removeEventListener('keydown', onKeydown))

// ── データ取得 ──
function getCached(key) {
  try {
    const entry = JSON.parse(localStorage.getItem(key))
    if (!entry) return null
    if (Date.now() - entry.ts > CACHE_TTL) return null
    return entry.data
  } catch { return null }
}
function setCached(key, data) {
  localStorage.setItem(key, JSON.stringify({ ts: Date.now(), data }))
}

function load(sheet) {
  const gasUrl = GAS_URL + (sheet ? '?sheet=' + encodeURIComponent('📌' + sheet) : '')
  const cacheKey = 'url-stocker-cache-' + (sheet || 'ログ')
  const cached = getCached(cacheKey)
  if (cached) renderData(cached)
  syncing.value = true

  const controller = new AbortController()
  const timer = setTimeout(() => controller.abort(), 15000)
  fetch(gasUrl, { signal: controller.signal })
    .then(r => { clearTimeout(timer); return r.json() })
    .then(data => { setCached(cacheKey, data); renderData(data); syncing.value = false })
    .catch(err => {
      clearTimeout(timer)
      syncing.value = false
      if (!cached) {
        const msg = err.name === 'AbortError' ? '⏱ タイムアウト' : '⚠️ 読み込み失敗'
        showToast(msg)
      }
    })
}

function renderData(data) {
  sheetName.value = data.sheetName
  document.title = data.sheetName
  const total = data.cards.length
  allCards.value = data.cards.map((c, i) => ({ ...c, originalIndex: total - i }))
  if (showTabs) sheets.value = data.sheets || []
}

function switchSheet(name) {
  currentSheet.value = name
  history.pushState(null, '', '#' + encodeURIComponent(name))
  load(name)
}

function copyShareUrl() {
  if (!currentSheet.value) { showToast('⚠️ タブでシートを選んでからコピーしてください'); return }
  const url = location.origin + location.pathname + '#' + encodeURIComponent(currentSheet.value)
  navigator.clipboard.writeText(url).then(() => showToast('🔗 共有URLをコピーしました'))
}

function forceReload() {
  Object.keys(localStorage)
    .filter(k => k.startsWith('url-stocker-cache-'))
    .forEach(k => localStorage.removeItem(k))
  allCards.value = []
  load(currentSheet.value)
}

function onHashChange() {
  const sheet = getSheetFromHash()
  currentSheet.value = sheet
  load(sheet)
}
onMounted(() => {
  window.addEventListener('hashchange', onHashChange)
  load(currentSheet.value)
})
onUnmounted(() => window.removeEventListener('hashchange', onHashChange))
</script>

<template>
  <header>
    <div class="header-top">
      <h1>🔖 {{ sheetName || '読み込み中...' }}</h1>
      <button v-if="showTabs" class="share-btn" @click="copyShareUrl">🔗 共有URLをコピー</button>
      <button class="theme-btn" @click="toggleTheme">{{ theme === 'dark' ? '🌙' : '☀️' }}</button>
    </div>
    <p class="meta">
      <span>{{ metaText }}</span>
      <span v-if="syncing" class="sync-badge">↻ 更新中...</span>
    </p>
  </header>

  <div v-if="showTabs && sheets.length" class="tabs">
    <button
      v-for="name in sheets"
      :key="name"
      :class="['tab', { active: name === sheetName }]"
      @click="switchSheet(name)"
    >{{ name }}</button>
  </div>

  <Toolbar
    :current-sort="currentSort"
    :sort-dir="sortDir"
    :nav-mode="navMode"
    :nav-date="navDate"
    :fav-filter-on="favFilterOn"
    :current-cols="currentCols"
    @set-sort="setSort"
    @set-nav-mode="setNavMode"
    @nav-step="navStep"
    @go-today="goToday"
    @toggle-fav-filter="toggleFavFilter"
    @set-cols="n => currentCols = n"
  />

  <div class="search-wrap">
    <input type="text" v-model="searchQuery" placeholder="タイトル・URLで絞り込み..." />
  </div>

  <CardGrid
    :cards="filteredCards"
    :favorites="favorites"
    :current-cols="currentCols"
    @open-focus="openFocus"
    @toggle-fav="toggleFav"
    @copy-url="copyUrl"
  />

  <Teleport to="body">
    <FocusModal
      v-if="focusActive"
      :cards="filteredCards"
      :focus-index="focusIndex"
      :favorites="favorites"
      @close="closeFocus"
      @move="focusMove"
      @toggle-fav="toggleFav"
    />

    <div :id="'toast'" :class="{ show: toastVisible }">{{ toastMsg }}</div>

    <button
      v-if="showScrollTop"
      class="scroll-top-btn"
      @click="window.scrollTo({ top: 0, behavior: 'smooth' })"
    >↑</button>
  </Teleport>
</template>
