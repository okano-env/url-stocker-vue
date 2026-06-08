<script setup>
import { ref } from 'vue'

const emit = defineEmits(['close', 'sent'])

const GAS_URL = 'https://script.google.com/macros/s/AKfycbxmuUCneFf06w2tFb-fuojnDLWrH6APH-pJHWg_zit7cf1wioKCaG32mZRAuoPxHNu5/exec'

const categories = [
  { value: '不具合', label: '🐛 不具合がある' },
  { value: '使いにくい', label: '😵 使いにくい' },
  { value: '要望', label: '💡 こんな機能が欲しい' },
  { value: 'その他', label: '💬 その他' },
]
const category = ref('その他')
const comment = ref('')
const sending = ref(false)

async function send() {
  if (!comment.value.trim()) return
  sending.value = true
  try {
    await fetch(GAS_URL, {
      method: 'POST',
      mode: 'no-cors',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ type: 'feedback', category: category.value, comment: comment.value.trim() })
    })
    emit('sent')
    emit('close')
  } finally {
    sending.value = false
  }
}
</script>

<template>
  <div class="feedback-overlay" @click.self="emit('close')">
    <div class="feedback-modal">
      <button class="feedback-close" @click="emit('close')">×</button>
      <h2>💬 意見箱</h2>
      <div class="feedback-options">
        <label v-for="c in categories" :key="c.value" class="feedback-option" :class="{ active: category === c.value }">
          <input type="radio" :value="c.value" v-model="category"> {{ c.label }}
        </label>
      </div>
      <textarea v-model="comment" placeholder="気になることを自由に書いてください..."></textarea>
      <button class="feedback-send" :disabled="sending || !comment.trim()" @click="send">
        {{ sending ? '送信中...' : '送信する' }}
      </button>
    </div>
  </div>
</template>
