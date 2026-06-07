<template>
  <div class="page-loading-state theme-panel border">
    <div class="page-loading-spinner" aria-hidden="true">
      <span></span>
    </div>
    <p class="mt-4 text-sm font-semibold theme-text-secondary">{{ label }}</p>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  label: string
}>()
</script>

<style scoped>
.page-loading-state {
  display: flex;
  min-height: 260px;
  align-items: center;
  justify-content: center;
  flex-direction: column;
  border-radius: 22px;
  box-shadow: 0 14px 36px rgba(15, 23, 42, 0.06);
}

.page-loading-spinner {
  display: grid;
  width: 52px;
  height: 52px;
  place-items: center;
  border-radius: 18px;
  background: linear-gradient(135deg, rgba(37, 99, 235, 0.1), rgba(124, 58, 237, 0.12));
}

.page-loading-spinner span {
  width: 24px;
  height: 24px;
  border: 3px solid rgba(37, 99, 235, 0.2);
  border-top-color: #2563eb;
  border-radius: 999px;
  animation: page-loading-spin 0.8s linear infinite;
}

@keyframes page-loading-spin {
  to { transform: rotate(360deg); }
}
</style>
