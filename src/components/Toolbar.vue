<script setup>
import { computed } from 'vue'

const props = defineProps({
  currentSort: String,
  sortDir: Object,
  navMode: String,
  navDate: Date,
  favFilterOn: Boolean,
  currentCols: Number,
})
const emit = defineEmits(['set-sort', 'set-nav-mode', 'nav-step', 'go-today', 'toggle-fav-filter', 'set-cols'])

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
  <div class="toolbar">
    <div>
      <div class="sort-group">
        <span class="sort-label">並び替え：</span>
        <button
          v-for="type in ['date', 'title']"
          :key="type"
          :class="['sort-btn', { active: currentSort === type }]"
          @click="emit('set-sort', type)"
        >{{ sortLabel(type) }}</button>
      </div>
      <div class="date-nav">
        <span class="sort-label">期間：</span>
        <button
          v-for="mode in ['all', 'day', 'week', 'month']"
          :key="mode"
          :class="['nav-mode-btn', { active: navMode === mode }]"
          @click="emit('set-nav-mode', mode)"
        >{{ { all: '全期間', day: '日', week: '週', month: '月' }[mode] }}</button>
        <div v-if="navMode !== 'all'" class="nav-ctrl">
          <button class="nav-arrow" @click="emit('nav-step', -1)">‹</button>
          <button class="nav-today-btn" @click="emit('go-today')">{{ todayLabel }}</button>
          <span class="nav-label">{{ navLabel }}</span>
          <button class="nav-arrow" @click="emit('nav-step', 1)">›</button>
        </div>
      </div>
    </div>
    <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
      <div style="display:flex;align-items:center;gap:6px;">
        <span class="sort-label">列数：</span>
        <button
          v-for="n in [1, 2, 3]"
          :key="n"
          :class="['col-btn', { active: currentCols === n }]"
          @click="emit('set-cols', n)"
        >{{ n }}列</button>
      </div>
      <button :class="['fav-btn', { active: favFilterOn }]" @click="emit('toggle-fav-filter')">★ お気に入りのみ</button>
    </div>
  </div>
</template>
