<template>
  <div class="products-page min-h-screen theme-page pt-24 pb-16">
    <div class="container mx-auto px-4">
      <!-- Page Header -->
      <div class="products-heading mb-8 mt-8">
        <div>
          <span class="products-kicker">{{ t('products.kicker') }}</span>
          <h1 class="mt-3 text-3xl font-black tracking-[-0.04em] theme-text-primary md:text-5xl">{{ t('nav.products') }}</h1>
          <p class="mt-3 max-w-2xl text-sm leading-7 theme-text-secondary md:text-base">
            {{ t('products.subtitle') }}
          </p>
        </div>
      </div>

      <div class="flex flex-col gap-6 lg:flex-row lg:gap-8">
        <CategorySidebar
          :categories="categoryGroups"
          :selected-category="selectedCategory"
          :expanded-parent-ids="expandedParentIds"
          :show-drawer="showFilterDrawer"
          :show-search="true"
          :search-query="searchQuery"
          @select-category="selectCategory"
          @toggle-parent="toggleParentCategory"
          @update:show-drawer="showFilterDrawer = $event"
          @update:search-query="searchQuery = $event"
          @clear-search="clearSearch"
        />

        <!-- Main Content - Products Grid -->
        <main class="min-w-0 flex-1">
          <!-- Loading Skeleton -->
          <PageLoadingState v-if="loading" :label="t('common.loading')" />

          <!-- Products Grid -->
          <div v-else-if="products.length > 0">
            <div class="products-shop-grid">
              <ProductCard
                v-for="(product, idx) in products"
                :key="product.id"
                :product="product"
                :index="idx"
                :max-tags="isMobileGrid ? 1 : 2"
                :animation-step="50"
                @click="goToProduct"
                @quick-buy="openQuickBuy"
              />
            </div>

            <PaginationNav
              :current-page="currentPage"
              :total-pages="totalPages"
              :loading="loading"
              @change-page="changePage"
            />
          </div>

          <!-- Empty State -->
          <EmptyState
            v-else
            variant="soft"
            size="md"
            :icon="(searchQuery || selectedCategory) ? 'search' : 'package'"
            :title="(searchQuery || selectedCategory) ? t('products.emptyFiltered') : t('products.empty')"
            :description="(searchQuery || selectedCategory) ? t('products.emptyFilteredDescription') : t('products.emptyDescription')"
          >
            <template #action>
              <button
                v-if="searchQuery || selectedCategory"
                class="theme-btn-inline-md border theme-btn-secondary font-semibold"
                @click="clearSearch(); selectCategory(null)"
              >
                {{ t('products.clearFilters') }}
              </button>
              <button
                v-else
                class="theme-btn-inline-md theme-btn-primary font-semibold"
                @click="initialize"
              >
                {{ t('products.refreshProducts') }}
              </button>
              <router-link to="/" class="theme-btn-inline-md border theme-btn-secondary font-semibold">
                {{ t('products.backHome') }}
              </router-link>
            </template>
          </EmptyState>
        </main>
      </div>
    </div>

    <ProductQuickBuy
      v-if="quickBuyProduct"
      :product="quickBuyProduct"
      :visible="quickBuyVisible"
      @update:visible="quickBuyVisible = $event"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useProductList } from '../composables/useProductList'
import { usePageSeo } from '../composables/usePageSeo'
import { useLocalized } from '../composables/useProduct'
import ProductCard from '../components/ProductCard.vue'
import ProductQuickBuy from '../components/ProductQuickBuy.vue'
import CategorySidebar from '../components/CategorySidebar.vue'
import PaginationNav from '../components/PaginationNav.vue'
import EmptyState from '../components/EmptyState.vue'
import PageLoadingState from '../components/PageLoadingState.vue'

const router = useRouter()
const { t } = useI18n()

const {
  loading,
  products,
  selectedCategory,
  searchQuery,
  currentPage,
  totalPages,
  showFilterDrawer,
  expandedParentIds,
  categoryGroups,
  categoryMap,
  selectCategory,
  toggleParentCategory,
  changePage,
  clearSearch,
  initialize,
  cleanup,
} = useProductList({ pageSize: 12, homeRouteName: 'products' })

// ==================== SEO ====================
const route = useRoute()
const { getLocalizedText } = useLocalized()
const seoCategoryName = computed(() => {
  if (!selectedCategory.value) return ''
  const cat = categoryMap.value.get(selectedCategory.value)
  return cat ? getLocalizedText(cat.name) : ''
})
usePageSeo({
  canonicalPath: () => route.path,
  title: () => {
    if (route.name === 'category-products') {
      return seoCategoryName.value || t('nav.products')
    }
    return t('nav.products')
  },
})

const quickBuyProduct = ref<any>(null)
const quickBuyVisible = ref(false)

const openQuickBuy = (product: any) => {
  quickBuyProduct.value = product
  quickBuyVisible.value = true
}

// Detect mobile 2-col grid (< md breakpoint)
const isMobileGrid = ref(window.innerWidth < 768)
const handleResize = () => {
  isMobileGrid.value = window.innerWidth < 768
}

const goToProduct = (slug: string) => {
  router.push(`/products/${slug}`)
}

onMounted(async () => {
  window.addEventListener('resize', handleResize, { passive: true })
  await initialize()
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  cleanup()
})
</script>

<style scoped>
.products-heading {
  position: relative;
  overflow: hidden;
  border: 1px solid rgba(226, 232, 240, 0.9);
  border-radius: 28px;
  background:
    radial-gradient(circle at 92% 10%, rgba(124, 58, 237, 0.13), transparent 28%),
    radial-gradient(circle at 8% 12%, rgba(37, 99, 235, 0.12), transparent 30%),
    var(--ui-bg-overlay-strong);
  box-shadow: 0 14px 36px rgba(15, 23, 42, 0.06);
  padding: 28px;
}

.products-kicker {
  display: inline-flex;
  align-items: center;
  border-radius: 999px;
  background: rgba(37, 99, 235, 0.09);
  color: #2563eb;
  font-size: 0.75rem;
  font-weight: 800;
  letter-spacing: 0.18em;
  padding: 0.45rem 0.85rem;
  text-transform: uppercase;
}

.products-shop-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 1.25rem;
}

@media (min-width: 640px) {
  .products-shop-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (min-width: 1280px) {
  .products-shop-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (min-width: 1536px) {
  .products-shop-grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}

@media (max-width: 768px) {
  .products-heading {
    padding: 22px;
  }
}

.line-clamp-1 {
  overflow: hidden;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 1;
  line-clamp: 1;
}
.line-clamp-2 {
  overflow: hidden;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  line-clamp: 2;
}
</style>
