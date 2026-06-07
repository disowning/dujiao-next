<template>
  <div
    class="blog-page min-h-screen theme-page pt-20 pb-16 relative overflow-hidden">
    <div class="container mx-auto px-4 relative z-10">
      <!-- Page Header -->
      <div class="mb-16 mt-12 text-center">
        <h1 class="text-4xl md:text-6xl font-black mb-6 tracking-tight theme-text-primary">{{ t('nav.blog') }}</h1>
        <p
          class="theme-text-secondary max-w-2xl mx-auto text-lg leading-relaxed border-b theme-border pb-8">
          {{ t('blog.subtitle') }}
        </p>
      </div>

      <!-- Search Box -->
      <div class="mb-12 max-w-xl mx-auto">
        <div
          class="relative theme-panel-soft backdrop-blur-md border rounded-2xl flex items-center px-5 py-3 transition-all focus-within:shadow-lg">
          <svg class="w-5 h-5 theme-text-muted shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          <input v-model="searchKeyword" type="text" :placeholder="t('blog.searchPlaceholder')"
            class="flex-1 bg-transparent border-none outline-none px-3 theme-text-primary placeholder:theme-text-muted" />
          <button v-if="searchKeyword" type="button" @click="searchKeyword = ''"
            class="theme-text-muted hover:theme-text-primary transition-colors text-sm font-medium px-2 py-1 rounded-md">
            {{ t('blog.searchClear') }}
          </button>
        </div>
      </div>

      <!-- Loading State -->
      <PageLoadingState v-if="loading" :label="t('common.loading')" />

      <!-- Posts Grid -->
      <div v-else-if="posts.length > 0">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <article v-for="post in posts" :key="post.id"
            class="group theme-panel backdrop-blur-xl border rounded-2xl overflow-hidden hover:bg-gray-50 dark:hover:bg-white/5 transition-all duration-300 hover:-translate-y-1 hover:shadow-xl cursor-pointer flex flex-col"
            @click="goToPost(post.slug)">
            <!-- Thumbnail -->
            <div v-if="post.thumbnail" class="h-48 overflow-hidden relative">
              <img :src="getImageUrl(post.thumbnail)" :alt="getLocalizedText(post.title)"
                loading="lazy" class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110">
              <div class="absolute inset-0 bg-black/35"></div>
            </div>

            <div class="p-8 flex flex-col flex-1">
              <div class="flex items-center justify-between mb-6">
                <span class="theme-badge-meta"
                  :class="post.type === 'blog'
                    ? 'theme-badge-accent'
                    : 'theme-badge-info'">
                  {{ post.type === 'blog' ? t('nav.blog') : t('nav.notice') }}
                </span>
                <time class="text-xs theme-text-muted font-mono">
                  {{ formatDate(post.published_at) }}
                </time>
              </div>

              <h2
                class="text-2xl font-bold mb-4 theme-text-primary transition-colors line-clamp-2 leading-tight">
                {{ getLocalizedText(post.title) }}
              </h2>

              <p class="theme-text-secondary text-sm mb-8 line-clamp-3 leading-relaxed flex-1">
                {{ getLocalizedText(post.summary) }}
              </p>

              <div
                class="flex items-center text-sm font-medium theme-text-muted group-hover:text-gray-900 dark:group-hover:text-white transition-colors mt-auto pt-6 border-t theme-border">
                {{ t('blog.readMore') }}
                <svg class="w-4 h-4 ml-2 transition-transform group-hover:translate-x-2" fill="none"
                  stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3" />
                </svg>
              </div>
            </div>
          </article>
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="mt-16 flex justify-center">
          <nav
            class="flex items-center space-x-2 theme-panel-soft backdrop-blur-md p-2 rounded-2xl border">
            <button @click="changePage(currentPage - 1)" :disabled="currentPage === 1"
              class="w-10 h-10 flex items-center justify-center rounded-xl border theme-btn-secondary transition-all disabled:opacity-30 disabled:cursor-not-allowed">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>

            <span class="px-4 py-2 font-mono theme-text-muted">
              <span class="theme-text-primary font-bold">{{ currentPage }}</span>
              <span class="mx-2 opacity-50">/</span>
              <span>{{ totalPages }}</span>
            </span>

            <button @click="changePage(currentPage + 1)" :disabled="currentPage === totalPages"
              class="w-10 h-10 flex items-center justify-center rounded-xl border theme-btn-secondary transition-all disabled:opacity-30 disabled:cursor-not-allowed">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </nav>
        </div>
      </div>

      <!-- Empty State -->
      <EmptyState
        v-else
        icon="inbox"
        size="md"
        :title="searchKeyword.trim() ? t('blog.noResults') : t('blog.empty')"
        :description="searchKeyword.trim() ? t('blog.noResultsDescription') : t('blog.emptyDescription')"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAppStore } from '../stores/app'
import { postAPI } from '../api'
import { getImageUrl } from '../utils/image'
import { debounceAsync } from '../utils/debounce'
import { usePageSeo } from '../composables/usePageSeo'
import EmptyState from '../components/EmptyState.vue'
import PageLoadingState from '../components/PageLoadingState.vue'

const router = useRouter()
const { t } = useI18n()
const appStore = useAppStore()

usePageSeo({
  title: () => t('nav.blog'),
  canonicalPath: () => '/blog',
})

const loading = ref(true)
const posts = ref<any[]>([])
const currentPage = ref(1)
const pageSize = ref(12)
const total = ref(0)
const totalPages = ref(0)
const searchKeyword = ref('')

const getLocalizedText = (jsonData: any) => {
  if (!jsonData) return ''
  const locale = appStore.locale
  return jsonData[locale] || jsonData['zh-CN'] || jsonData['en-US'] || ''
}

const formatDate = (dateString: string) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString(appStore.locale, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

const loadPosts = async () => {
  loading.value = true
  try {
    const params: Record<string, any> = {
      type: 'blog',
      page: currentPage.value,
      page_size: pageSize.value,
    }
    const keyword = searchKeyword.value.trim()
    if (keyword) {
      params.search = keyword
    }
    const response = await postAPI.list(params)
    posts.value = response.data.data || []
    if (response.data.pagination) {
      total.value = response.data.pagination.total || 0
      totalPages.value = response.data.pagination.total_page || 0
    }
  } catch (error) {
    console.error('Failed to load posts:', error)
  } finally {
    loading.value = false
  }
}

const debouncedLoadPosts = debounceAsync(loadPosts, 300)

const goToPost = (slug: string) => {
  router.push(`/blog/${slug}`)
}

const changePage = (page: number) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  debouncedLoadPosts()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

watch(searchKeyword, () => {
  currentPage.value = 1
  debouncedLoadPosts()
})

onMounted(() => {
  loadPosts()
})

onUnmounted(() => {
  debouncedLoadPosts.cancel()
})
</script>

<style scoped>
.line-clamp-2 {
  overflow: hidden;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  line-clamp: 2;
}

.line-clamp-3 {
  overflow: hidden;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 3;
  line-clamp: 3;
}
</style>
