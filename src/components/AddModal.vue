<script setup>
import { ref } from 'vue'

const props = defineProps({ sheet: String })
const emit = defineEmits(['close', 'added'])

const GAS_URL = 'https://script.google.com/macros/s/AKfycbxmuUCneFf06w2tFb-fuojnDLWrH6APH-pJHWg_zit7cf1wioKCaG32mZRAuoPxHNu5/exec'

const inputUrl = ref('')
const state = ref('idle') // idle | sending | done

async function submit() {
  const url = inputUrl.value.trim()
  if (!url || !url.startsWith('http')) return
  const payload = { sheet: props.sheet, urls: [url] }
  console.log('[AddModal] sending:', payload)
  state.value = 'sending'
  try {
    await fetch(GAS_URL, {
      method: 'POST',
      mode: 'no-cors',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    })
    console.log('[AddModal] fetch done (no-cors: response opaque)')
    state.value = 'done'
    setTimeout(() => { emit('added'); emit('close') }, 3000)
  } catch(e) {
    console.error('[AddModal] fetch error:', e)
    state.value = 'idle'
  }
}

function onOverlayClick(e) {
  if (e.target === e.currentTarget) emit('close')
}
</script>

<template>
  <div class="add-overlay" @click="onOverlayClick">
    <div class="add-modal">

      <!-- イラスト＋キャッチコピー -->
      <div class="add-hero">
        <svg viewBox="0 0 160 100" class="add-svg" fill="none" xmlns="http://www.w3.org/2000/svg">
          <!-- ブラウザウィンドウ風の箱 -->
          <rect x="20" y="20" width="120" height="72" rx="10" fill="#1e2a3a" stroke="#0297e0" stroke-width="2"/>
          <rect x="20" y="20" width="120" height="22" rx="10" fill="#0297e0"/>
          <rect x="20" y="31" width="120" height="11" fill="#0297e0"/>
          <circle cx="33" cy="31" r="4" fill="#ff5f57"/>
          <circle cx="46" cy="31" r="4" fill="#febc2e"/>
          <circle cx="59" cy="31" r="4" fill="#28c840"/>
          <!-- アドレスバー -->
          <rect x="70" y="25" width="60" height="12" rx="6" fill="#0f1e2e"/>
          <text x="78" y="34" font-size="7" fill="#4a9eca" font-family="monospace">https://...</text>
          <!-- 落ちてくるURL粒 -->
          <circle cx="80" cy="62" r="5" fill="#0297e0" opacity="0.9"/>
          <circle cx="80" cy="62" r="9" fill="#0297e0" opacity="0.15"/>
          <text x="68" y="66" font-size="7" fill="#7ecffa" font-family="monospace">URL</text>
          <!-- 下向き矢印 -->
          <path d="M80 74 L76 70 M80 74 L84 70" stroke="#0297e0" stroke-width="2" stroke-linecap="round"/>
          <!-- 波紋 -->
          <circle cx="80" cy="80" r="8" stroke="#0297e0" stroke-width="1" opacity="0.4"/>
          <circle cx="80" cy="80" r="14" stroke="#0297e0" stroke-width="1" opacity="0.2"/>
        </svg>
        <div class="add-catchcopy">
          <p class="add-catch-main">「あとで見よう」は<br>永遠に来ない。</p>
          <p class="add-catch-sub">見つけたそのとき、ためるんや🐘</p>
        </div>
      </div>

      <!-- フォーム -->
      <div class="add-form-area">
        <div class="add-sheet-badge">📌 {{ sheet || 'STOCK' }}</div>
        <div class="add-input-row">
          <input
            v-model="inputUrl"
            class="add-input"
            type="url"
            placeholder="https://"
            :disabled="state !== 'idle'"
            @keydown.enter="submit"
            autofocus
          />
          <button
            class="add-btn"
            :disabled="state !== 'idle' || !inputUrl.startsWith('http')"
            @click="submit"
          >
            <span v-if="state === 'idle'">追加</span>
            <span v-else-if="state === 'sending'">送信中…</span>
            <span v-else>✅ 完了！</span>
          </button>
        </div>
      </div>

      <button class="add-close" @click="emit('close')">✕</button>
    </div>
  </div>
</template>
