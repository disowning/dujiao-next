<template>
  <div class="home-page min-h-screen theme-page">

    <!-- ==================== LIST MODE ==================== -->
    <template v-if="templateMode === 'list'">
      <!-- Commerce Hero -->
      <section class="relative z-10 pt-24 pb-8">
        <div class="container mx-auto px-4">
          <div class="home-commerce-hero"
            @touchstart="onBannerTouchStart"
            @touchend="onBannerTouchEnd">
            <div class="relative z-10 grid items-center gap-8 lg:grid-cols-[1.05fr_0.95fr]">
              <div>
                <span class="inline-flex items-center gap-2 rounded-full border border-white/25 bg-white/15 px-3 py-1 text-xs font-semibold text-white/95 backdrop-blur">
                  <span class="h-2 w-2 rounded-full bg-emerald-300"></span>
                  {{ t('home.hero.badge') }}
                </span>
                <h1 class="mt-5 max-w-3xl text-3xl font-black tracking-[-0.04em] text-white sm:text-4xl lg:text-5xl">
                  {{ t('home.hero.title') }}
                </h1>
                <p class="mt-4 max-w-2xl text-sm leading-7 text-white/82 sm:text-base">
                  {{ t('home.hero.subtitle') }}
                </p>
                <div class="mt-7 flex flex-wrap items-center gap-3">
                  <button type="button" class="home-hero-primary" @click="scrollToProducts">
                    {{ t('home.hero.cta') }}
                  </button>
                  <router-link to="/guest/orders" class="home-hero-secondary">
                    {{ t('home.hero.queryOrders') }}
                  </router-link>
                </div>
              </div>
              <div
                class="home-hero-visual"
                :class="{ 'cursor-pointer': hasHeroLink }"
                @click="hasHeroLink && goToHeroLink()"
              >
                <Transition name="banner-fade" mode="out-in">
                  <img v-if="!bannerLoading && heroImage" :src="heroImage" :key="heroImage" class="home-hero-image" />
                </Transition>
                <div class="relative z-10">
                  <div class="text-xs font-semibold uppercase tracking-[0.24em] text-blue-100">JUXI SHOP</div>
                  <div class="mt-3 text-2xl font-black text-white">{{ heroTitle }}</div>
                  <div class="mt-2 line-clamp-2 text-sm text-white/75">{{ heroSubtitle }}</div>
                  <div class="mt-6 grid grid-cols-2 gap-3">
                    <div class="home-hero-stat">
                      <span>{{ t('home.hero.statsPrimaryLabel') }}</span>
                      <strong>{{ t('home.hero.statsPrimaryValue') }}</strong>
                    </div>
                    <div class="home-hero-stat">
                      <span>{{ t('home.hero.statsSecondaryLabel') }}</span>
                      <strong>{{ t('home.hero.statsSecondaryValue') }}</strong>
                    </div>
                  </div>
                  <div v-if="bannerCount > 1" class="mt-5 flex items-center gap-2">
                    <button
                      v-for="(_, bIdx) in banners"
                      :key="`list-dot-${bIdx}`"
                      type="button"
                      class="h-2 rounded-full transition-all"
                      :class="bIdx === currentBannerIndex ? 'w-7 bg-white' : 'w-2 bg-white/45 hover:bg-white/70'"
                      @click="selectHeroBanner(bIdx)"
                    ></button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Main: Left Categories + Right Product List -->
      <section id="featured" class="relative z-10 pb-6 pt-6">
        <div class="container mx-auto px-4">
          <div class="flex flex-col lg:flex-row gap-6">

            <CategorySidebar
              :categories="listCategoryGroups"
              :selected-category="listSelectedCategory"
              :expanded-parent-ids="listExpandedParentIds"
              :show-drawer="listShowFilterDrawer"
              compact
              @select-category="listSelectCategory"
              @toggle-parent="listToggleParentCategory"
              @update:show-drawer="listShowFilterDrawer = $event"
            />

            <!-- Right: Product List -->
            <main class="flex-1 min-w-0">
              <!-- Search Bar -->
              <div class="relative mb-4">
                <div class="absolute inset-y-0 left-3.5 flex items-center pointer-events-none">
                  <svg class="w-4 h-4 theme-text-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                  </svg>
                </div>
                <input
                  v-model="listSearchQuery"
                  type="text"
                  class="w-full h-10 pl-10 pr-10 rounded-xl border theme-panel text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 theme-text-primary placeholder:theme-text-muted transition-shadow"
                  :placeholder="t('products.searchBoxPlaceholder')"
                  @keydown.enter="listOnSearch"
                />
                <button
                  v-if="listSearchQuery"
                  type="button"
                  class="absolute inset-y-0 right-3 flex items-center theme-text-muted hover:theme-text-primary transition-colors"
                  @click="listClearSearch"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <!-- Loading Skeleton -->
              <div v-if="listLoading" class="space-y-6">
                <div v-for="i in 3" :key="i">
                  <div class="flex items-center gap-2 mb-3 px-0.5">
                    <div class="h-5 w-5 rounded theme-skeleton"></div>
                    <div class="h-4 w-28 rounded theme-skeleton"></div>
                  </div>
                  <div class="space-y-2">
                    <div v-for="j in 3" :key="j"
                      class="theme-panel rounded-xl border flex items-center h-[72px]">
                      <div class="w-14 h-14 m-2 rounded-lg theme-skeleton flex-shrink-0"></div>
                      <div class="flex-1 px-3 py-2 space-y-2">
                        <div class="h-3.5 w-1/3 rounded theme-skeleton"></div>
                        <div class="h-3 w-1/4 rounded theme-skeleton"></div>
                      </div>
                      <div class="px-4 py-2">
                        <div class="h-4 w-14 rounded theme-skeleton"></div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Grouped Product List -->
              <div v-else-if="listProductGroups.length > 0" class="space-y-6">
                <div v-for="group in listProductGroups" :key="group.categoryId ?? 'uncategorized'">
                  <!-- Category Header -->
                  <div class="flex items-center gap-2 mb-3 px-0.5">
                    <span class="w-1 h-5 rounded-full theme-accent-stick flex-shrink-0"></span>
                    <img v-if="group.categoryIcon" :src="getImageUrl(group.categoryIcon)"
                      :alt="group.categoryName" loading="lazy" class="h-5 w-5 rounded object-cover flex-shrink-0" />
                    <span class="text-sm font-semibold theme-text-primary truncate">{{ group.categoryName }}</span>
                    <span class="text-xs theme-text-muted">({{ group.products.length }})</span>
                  </div>
                  <!-- Products in this category -->
                  <div class="space-y-2">
                    <ProductListItem
                      v-for="(product, idx) in group.products"
                      :key="product.id"
                      :product="product"
                      :index="idx"
                      :animation-step="20"
                      @click="goToProduct"
                      @quick-buy="openQuickBuy"
                    />
                  </div>
                </div>

                <PaginationNav
                  :current-page="listCurrentPage"
                  :total-pages="listTotalPages"
                  :loading="listLoading"
                  compact
                  @change-page="listChangePage"
                />
              </div>

              <!-- Empty State -->
              <EmptyState
                v-else
                icon="package"
                :title="t('home.featured.emptyTitle')"
                :description="t('home.featured.emptyDescription')"
                size="lg"
              />
            </main>
          </div>
        </div>
      </section>
    </template>

    <!-- ==================== CARD MODE (default) ==================== -->
    <template v-else>
    <section class="relative z-10 pt-24 pb-8">
      <div class="container mx-auto px-4">
        <div class="home-commerce-hero" @touchstart="onBannerTouchStart" @touchend="onBannerTouchEnd">
          <div class="relative z-10 grid items-center gap-8 lg:grid-cols-[1.05fr_0.95fr]">
            <div>
              <span class="inline-flex items-center gap-2 rounded-full border border-white/25 bg-white/15 px-3 py-1 text-xs font-semibold text-white/95 backdrop-blur">
                <span class="h-2 w-2 rounded-full bg-emerald-300"></span>
                {{ t('home.hero.badge') }}
              </span>
              <h1 class="mt-5 max-w-3xl text-3xl font-black tracking-[-0.04em] text-white sm:text-4xl lg:text-5xl">
                {{ t('home.hero.title') }}
              </h1>
              <p class="mt-4 max-w-2xl text-sm leading-7 text-white/82 sm:text-base">
                {{ t('home.hero.subtitle') }}
              </p>
              <div class="mt-7 flex flex-wrap items-center gap-3">
                <button type="button" class="home-hero-primary" @click="scrollToProducts">{{ t('home.hero.cta') }}</button>
                <router-link to="/guest/orders" class="home-hero-secondary">{{ t('home.hero.queryOrders') }}</router-link>
              </div>
            </div>
            <div
              class="home-hero-visual"
              :class="{ 'cursor-pointer': hasHeroLink }"
              @click="hasHeroLink && goToHeroLink()"
            >
              <Transition name="banner-fade" mode="out-in">
                <img v-if="!bannerLoading && heroImage" :src="heroImage" :key="heroImage" class="home-hero-image" />
              </Transition>
              <div class="relative z-10">
                <div class="text-xs font-semibold uppercase tracking-[0.24em] text-blue-100">JUXI SHOP</div>
                <div class="mt-3 text-2xl font-black text-white">{{ heroTitle }}</div>
                <div class="mt-2 line-clamp-2 text-sm text-white/75">{{ heroSubtitle }}</div>
                <div class="mt-6 grid grid-cols-2 gap-3">
                  <div class="home-hero-stat"><span>{{ t('home.hero.statsPrimaryLabel') }}</span><strong>{{ t('home.hero.statsPrimaryValue') }}</strong></div>
                  <div class="home-hero-stat"><span>{{ t('home.hero.statsSecondaryLabel') }}</span><strong>{{ t('home.hero.statsSecondaryValue') }}</strong></div>
                </div>
                <div v-if="bannerCount > 1" class="mt-5 flex items-center gap-2">
                  <button
                    v-for="(_, index) in banners"
                    :key="`hero-dot-${index}`"
                    type="button"
                    class="h-2 rounded-full transition-all"
                    :class="index === currentBannerIndex ? 'w-7 bg-white' : 'w-2 bg-white/45 hover:bg-white/70'"
                    @click="selectHeroBanner(index)"
                    :aria-label="t('common.switchBanner', { n: index + 1 })"
                  ></button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section id="featured" class="relative z-10 pb-14 pt-10">
      <div class="container mx-auto px-4">
        <div class="mb-8 flex items-end justify-between gap-4">
          <div>
            <div class="mb-2 text-xs font-bold uppercase tracking-[0.24em] text-blue-600">{{ t('home.featured.kicker') }}</div>
            <h2 class="theme-section-heading text-3xl md:text-4xl">{{ t('home.featured.title') }}</h2>
            <p class="mt-2 text-sm theme-text-secondary">{{ t('home.featured.description') }}</p>
          </div>
          <router-link
            to="/products"
            class="hidden items-center gap-2 rounded-full border theme-btn-secondary px-5 py-2.5 text-sm font-semibold sm:inline-flex"
          >
            {{ t('home.featured.viewAll') }}
            <span aria-hidden="true">→</span>
          </router-link>
        </div>

        <div v-if="products.length > 0" class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          <ProductCard
            v-for="(product, idx) in products"
            :key="product.id"
            :product="product"
            :index="idx"
            :animation-step="60"
            @click="goToProduct"
            @quick-buy="openQuickBuy"
          />
        </div>
        <EmptyState
          v-else
          icon="package"
          :title="t('home.featured.emptyTitle')"
          :description="t('home.featured.emptyDescription')"
          size="lg"
        >
          <template #action>
            <router-link v-if="noticeEnabled" to="/notice" class="theme-btn-inline-md theme-btn-secondary border font-semibold">
              {{ t('home.featured.notice') }}
            </router-link>
            <button type="button" class="theme-btn-inline-md theme-btn-primary font-semibold" @click="loadFeaturedProducts">
              {{ t('home.featured.refresh') }}
            </button>
          </template>
        </EmptyState>
      </div>
    </section>

    <template v-if="latestSectionVisible">
    <section class="relative z-10 pb-16 pt-4">
      <div class="container mx-auto px-4">
        <div class="rounded-[28px] border theme-panel p-5 sm:p-8">
          <div class="mb-6 flex items-end justify-between gap-4">
            <div>
              <div class="mb-2 text-xs font-bold uppercase tracking-[0.24em] text-violet-600">{{ t('home.latest.kicker') }}</div>
              <h2 class="theme-section-heading text-[1.7rem]">{{ t('home.latest.title') }}</h2>
              <p class="mt-1 text-sm theme-text-secondary">{{ t('home.latest.description') }}</p>
            </div>
            <div class="flex items-center gap-2 text-sm">
              <router-link v-if="blogEnabled" to="/blog" class="rounded-full border theme-btn-secondary px-4 py-2">{{ t('nav.blog') }}</router-link>
              <router-link v-if="noticeEnabled" to="/notice" class="rounded-full border theme-btn-secondary px-4 py-2">{{ t('nav.notice') }}</router-link>
            </div>
          </div>

          <div v-if="posts.length > 0" class="grid grid-cols-1 gap-5 md:grid-cols-3">
            <article
              v-for="post in posts"
              :key="post.id"
              class="cursor-pointer rounded-[22px] border bg-white p-5 transition-all theme-card-interactive"
              @click="goToPost(post.slug)"
            >
              <div class="mb-3 inline-flex rounded-full bg-blue-50 px-3 py-1 text-xs font-semibold text-blue-600">{{ formatDate(post.published_at) }}</div>
              <h3 class="line-clamp-2 text-base font-bold theme-text-primary">{{ getLocalizedText(post.title) }}</h3>
              <p class="mt-2 line-clamp-2 text-sm theme-text-secondary">{{ getLocalizedText(post.summary) }}</p>
              <div class="mt-5 inline-flex items-center gap-2 text-sm font-bold text-blue-600">{{ t('blog.readMore') }} <span>→</span></div>
            </article>
          </div>
          <EmptyState
            v-else
            icon="inbox"
            :title="t('home.latest.emptyTitle')"
            :description="t('home.latest.emptyDescription')"
            variant="soft"
          />
        </div>
      </div>
    </section>
    </template>
    </template>

    <ProductQuickBuy
      v-if="quickBuyProduct"
      :product="quickBuyProduct"
      :visible="quickBuyVisible"
      @update:visible="quickBuyVisible = $event"
    />

    <AnnouncementModal
      v-if="activeAnnouncement"
      :announcement="activeAnnouncement"
      :visible="announcementVisible"
      @update:visible="announcementVisible = $event"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { postAPI, productAPI } from '../api'
import { getImageUrl } from '../utils/image'
import { useLocalized } from '../composables/useProduct'
import { useBannerCarousel } from '../composables/useBannerCarousel'
import { useProductList } from '../composables/useProductList'
import { useProductListGroups } from '../composables/useProductListGroups'
import { usePageSeo } from '../composables/usePageSeo'
import { useAppStore } from '../stores/app'
import ProductCard from '../components/ProductCard.vue'
import ProductListItem from '../components/ProductListItem.vue'
import ProductQuickBuy from '../components/ProductQuickBuy.vue'
import CategorySidebar from '../components/CategorySidebar.vue'
import PaginationNav from '../components/PaginationNav.vue'
import AnnouncementModal from '../components/AnnouncementModal.vue'
import EmptyState from '../components/EmptyState.vue'
import { useAnnouncement, type HomeAnnouncement } from '../composables/useAnnouncement'

const router = useRouter()
const { t } = useI18n()
const { getLocalizedText } = useLocalized()
const appStore = useAppStore()

const templateMode = computed(() => appStore.config?.template_mode || 'card')
const navBuiltin = computed(() => (appStore.config?.nav_config as { builtin?: Record<string, boolean> } | undefined)?.builtin)
const blogEnabled = computed(() => navBuiltin.value?.blog !== false)
const noticeEnabled = computed(() => navBuiltin.value?.notice !== false)
const latestSectionVisible = computed(() => blogEnabled.value || noticeEnabled.value)

// ==================== Shared State ====================
const products = ref<any[]>([])
const posts = ref<any[]>([])
const quickBuyProduct = ref<any>(null)
const quickBuyVisible = ref(false)

const { shouldShow } = useAnnouncement()
const activeAnnouncement = ref<HomeAnnouncement | null>(null)
const announcementVisible = ref(false)

const openQuickBuy = (product: any) => {
  quickBuyProduct.value = product
  quickBuyVisible.value = true
}

// ==================== Banner Carousel ====================
const {
  banners,
  bannerLoading,
  currentBannerIndex,
  bannerCount,
  heroImage,
  heroTitle,
  heroSubtitle,
  hasHeroLink,
  loadBanners,
  selectHeroBanner,
  goToHeroLink,
  onBannerTouchStart,
  onBannerTouchEnd,
  stopHeroAutoPlay,
} = useBannerCarousel()

// ==================== List Mode ====================
const {
  loading: listLoading,
  products: listProducts,
  selectedCategory: listSelectedCategory,
  searchQuery: listSearchQuery,
  currentPage: listCurrentPage,
  totalPages: listTotalPages,
  showFilterDrawer: listShowFilterDrawer,
  expandedParentIds: listExpandedParentIds,
  categoryGroups: listCategoryGroups,
  categoryMap: listCategoryMap,
  selectCategory: listSelectCategory,
  toggleParentCategory: listToggleParentCategory,
  changePage: listChangePage,
  clearSearch: listClearSearch,
  onSearch: listOnSearch,
  initialize: listInitialize,
  cleanup: listCleanup,
} = useProductList({ pageSize: 20, homeRouteName: 'home' })

const listProductGroups = useProductListGroups(listProducts, listCategoryMap)

// ==================== SEO ====================
const route = useRoute()
const seoCategoryName = computed(() => {
  if (!listSelectedCategory.value) return ''
  const cat = listCategoryMap.value.get(listSelectedCategory.value)
  return cat ? getLocalizedText(cat.name) : ''
})
usePageSeo({
  canonicalPath: () => route.path,
  title: () => {
    if (route.name === 'category-products') {
      return seoCategoryName.value || t('nav.products')
    }
    if (route.name === 'products') return t('nav.products')
    return undefined
  },
})

// ==================== Card Mode ====================
const formatDate = (dateString: string) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString()
}

const goToProduct = (slug: string) => {
  router.push(`/products/${slug}`)
}

const goToPost = (slug: string) => {
  router.push(`/blog/${slug}`)
}

const scrollToProducts = () => {
  document.querySelector('#featured')?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

const loadFeaturedProducts = async () => {
  try {
    const response = await productAPI.list({ page: 1, page_size: 15 })
    products.value = response.data.data || []
  } catch (error) {
    console.error('Failed to load products:', error)
  }
}

const loadLatestPosts = async () => {
  if (!latestSectionVisible.value) return
  try {
    const params: Record<string, unknown> = { page: 1, page_size: 3 }
    if (blogEnabled.value && !noticeEnabled.value) params.type = 'blog'
    if (!blogEnabled.value && noticeEnabled.value) params.type = 'notice'
    const response = await postAPI.list(params)
    posts.value = response.data.data || []
  } catch (error) {
    console.error('Failed to load posts:', error)
  }
}

// ==================== Lifecycle ====================
const showAnnouncementIfNeeded = () => {
  const announcement = appStore.config?.announcement as HomeAnnouncement | undefined
  if (announcement && shouldShow(announcement)) {
    activeAnnouncement.value = announcement
    announcementVisible.value = true
  }
}

onMounted(async () => {
  await appStore.loadConfig()
  if (templateMode.value === 'list') {
    await Promise.all([loadBanners(), listInitialize()])
  } else {
    await Promise.all([loadBanners(), loadFeaturedProducts(), loadLatestPosts()])
  }
  showAnnouncementIfNeeded()
})

onUnmounted(() => {
  stopHeroAutoPlay()
  listCleanup()
})
</script>

<style scoped>
.home-commerce-hero {
  position: relative;
  overflow: hidden;
  border-radius: 28px;
  padding: clamp(1.5rem, 4vw, 3.5rem);
  color: white;
  background:
    radial-gradient(circle at 90% 12%, rgba(255, 255, 255, 0.22), transparent 16rem),
    radial-gradient(circle at 72% 100%, rgba(56, 189, 248, 0.28), transparent 20rem),
    linear-gradient(135deg, #2563eb 0%, #7c3aed 100%);
  box-shadow: 0 24px 60px rgba(37, 99, 235, 0.22);
}

.home-commerce-hero::before,
.home-commerce-hero::after {
  position: absolute;
  content: "";
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.14);
}

.home-commerce-hero::before {
  width: 18rem;
  height: 18rem;
  right: -6rem;
  top: -8rem;
}

.home-commerce-hero::after {
  width: 11rem;
  height: 11rem;
  left: 42%;
  bottom: -8rem;
}

.home-hero-primary,
.home-hero-secondary {
  display: inline-flex;
  min-height: 2.75rem;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  padding: 0.7rem 1.25rem;
  font-size: 0.875rem;
  font-weight: 700;
  transition: transform 0.2s ease, box-shadow 0.2s ease, background-color 0.2s ease;
}

.home-hero-primary {
  background: white;
  color: #1d4ed8;
  box-shadow: 0 14px 28px rgba(15, 23, 42, 0.18);
}

.home-hero-secondary {
  border: 1px solid rgba(255, 255, 255, 0.34);
  background: rgba(255, 255, 255, 0.12);
  color: white;
  backdrop-filter: blur(12px);
}

.home-hero-primary:hover,
.home-hero-secondary:hover {
  transform: translateY(-2px);
  box-shadow: 0 18px 32px rgba(15, 23, 42, 0.22);
}

.home-hero-visual {
  position: relative;
  min-height: 16rem;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 24px;
  padding: 1.5rem;
  background: rgba(15, 23, 42, 0.2);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.16);
  backdrop-filter: blur(16px);
}

.home-hero-image {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0.2;
  mix-blend-mode: luminosity;
}

.home-hero-stat {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  border: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: 18px;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.12);
}

.home-hero-stat span {
  font-size: 0.75rem;
  color: rgba(255, 255, 255, 0.68);
}

.home-hero-stat strong {
  font-size: 1.25rem;
  color: white;
}

.banner-fade-enter-active,
.banner-fade-leave-active {
  transition: opacity 300ms ease;
}
.banner-fade-enter-from,
.banner-fade-leave-to {
  opacity: 0;
}

@media (max-width: 768px) {
  .home-commerce-hero {
    border-radius: 22px;
    padding: 1.75rem 1.25rem;
  }

  .home-hero-primary,
  .home-hero-secondary {
    flex: 1 1 auto;
  }

  .home-hero-visual {
    min-height: 13rem;
    border-radius: 20px;
    padding: 1.25rem;
  }
}
</style>
