<script setup>
import { computed } from 'vue'

const props = defineProps({
  currentSort: String,
  sortDir: Object,
  navMode: String,
  navDate: Date,
  favFilterOn: Boolean,
  currentCols: Number,
  showImages: Boolean,
})
const emit = defineEmits(['set-sort', 'set-nav-mode', 'nav-step', 'go-today', 'toggle-fav-filter', 'set-cols', 'toggle-images'])

const sortArrows = { date: '日付順', title: 'タイトル順' }
function sortLabel(type) {
  const arrow = props.sortDir[type] === 'desc' ? ' ↓' : ' ↑'
  return sortArrows[type] + (props.currentSort === type ? arrow : ' ↓')
}

function fmtMonthDay(d) { return (d.getMonth() + 1) + '月' + d.getDate() + '日' }
function getWeekStart(d) {
  const day = d.getDay()
  const diff = day === 0 ? -6 : 1 - day
  return new Date(d.getFullYear(), d.getMonth(), d.getDate() + diff)
}

const navLabel = computed(() => {
  const d = props.navDate
  if (props.navMode === 'day') return d.getFullYear() + '年' + (d.getMonth() + 1) + '月' + d.getDate() + '日'
  if (props.navMode === 'week') {
    const ws = getWeekStart(d)
    const we = new Date(ws.getFullYear(), ws.getMonth(), ws.getDate() + 6)
    return fmtMonthDay(ws) + ' 〜 ' + fmtMonthDay(we)
  }
  if (props.navMode === 'month') return d.getFullYear() + '年' + (d.getMonth() + 1) + '月'
  return ''
})

const todayLabel = computed(() => ({ day: '今日', week: '今週', month: '今月' }[props.navMode] || ''))
</script>

<template>
  <!-- 【整列・近接】全フィルターを1本の横並びバーに統合 -->
  <div class="toolbar">
    <div class="toolbar-group">
      <span class="group-label">並び替え</span>
      <div class="seg-pill">
        <button
          v-for="type in ['date', 'title']"
          :key="type"
          :class="['seg-opt', { active: currentSort === type }]"
          @click="emit('set-sort', type)"
        >{{ sortLabel(type) }}</button>
      </div>
    </div>

    <div class="toolbar-sep"></div>

    <div class="toolbar-group">
      <span class="group-label">期間</span>
      <div class="seg-pill">
        <button
          v-for="mode in ['all', 'day', 'week', 'month']"
          :key="mode"
          :class="['seg-opt', { active: navMode === mode }]"
          @click="emit('set-nav-mode', mode)"
        >{{ { all: '全期間', day: '日', week: '週', month: '月' }[mode] }}</button>
      </div>
      <div v-if="navMode !== 'all'" class="nav-ctrl">
        <button class="nav-arrow" @click="emit('nav-step', -1)">‹</button>
        <button class="nav-today-btn" @click="emit('go-today')">{{ todayLabel }}</button>
        <span class="nav-label">{{ navLabel }}</span>
        <button class="nav-arrow" @click="emit('nav-step', 1)">›</button>
      </div>
    </div>

    <div class="toolbar-sep"></div>

    <div class="toolbar-group">
      <span class="group-label">列</span>
      <div class="col-picker">
        <button
          v-for="n in [1, 2, 3, 4]"
          :key="n"
          :class="['col-btn', { active: currentCols === n }]"
          :title="`${n}列`"
          @click="emit('set-cols', n)"
        >
          <svg width="20" height="14" viewBox="0 0 20 14" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect
              v-for="i in n"
              :key="i"
              :x="(i - 1) * (20 / n) + 1"
              y="1"
              :width="(20 / n) - 2"
              height="12"
              rx="1.5"
              fill="currentColor"
            />
          </svg>
        </button>
      </div>
    </div>

    <div class="toolbar-sep"></div>

    <button :class="['toggle-btn', { active: favFilterOn }]" @click="emit('toggle-fav-filter')">★ お気に入り</button>
    <button :class="['toggle-btn', { active: !showImages }]" @click="emit('toggle-images')">{{ showImages ? '🖼 画像' : '🚫 画像' }}</button>
  </div>
</template>
