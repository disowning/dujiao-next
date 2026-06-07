<template>
  <div
    class="group relative theme-panel rounded-[22px] border transition-all overflow-hidden flex flex-col h-full theme-slide-up"
    :class="isSoldOut(product)
      ? 'cursor-default opacity-85 grayscale-[0.25] saturate-50 border-rose-300/60 dark:border-rose-900/40'
      : 'cursor-pointer theme-card-interactive'"
    :style="{ animationDelay: `${index * animationStep}ms` }"
    @click="$emit('click', product.slug)">
    <!-- Image Area -->
    <div class="aspect-[4/3] overflow-hidden bg-gradient-to-br from-blue-50 via-white to-violet-50 relative shrink-0">
      <div
        class="absolute inset-0 z-10 transition-colors duration-300"
        :class="isSoldOut(product) ? 'bg-black/15' : 'bg-black/15 group-hover:bg-black/5'"
      ></div>
      <img v-if="displayImageSrc && !imageErrored" :src="displayImageSrc"
        :alt="getLocalizedText(product.title)" loading="lazy" decoding="async"
        class="w-full h-full object-cover transform transition-transform duration-700 ease-out"
        :class="[
          isSoldOut(product) ? 'grayscale brightness-75' : 'group-hover:scale-105',
        ]"
        @error="handleImageError" />
      <div v-else class="w-full h-full flex items-center justify-center theme-text-muted" role="img"
        :aria-label="getLocalizedText(product.title)">
        <svg class="w-8 h-8 md:w-12 md:h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
            d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
      </div>

      <div v-if="isSoldOut(product)" class="absolute inset-0 z-20 bg-black/45"></div>
      <div v-if="isSoldOut(product)"
        class="absolute left-2 top-2 md:left-4 md:top-4 z-30 theme-badge theme-badge-solid-danger text-xs font-bold tracking-wider shadow-sm">
        {{ t('products.stockStatus.outOfStock') }}
      </div>

      <!-- Tags -->
      <div v-if="!isSoldOut(product) && product.tags && product.tags.length > 0"
        class="absolute top-2 right-2 md:top-4 md:right-4 z-20 flex flex-wrap gap-1 md:gap-2 justify-end">
        <span v-for="(tag, tagIndex) in product.tags.slice(0, maxTags)" :key="tagIndex"
          class="theme-badge theme-badge-inverse px-2 md:px-3 py-0.5 md:py-1 text-xs font-medium">
          {{ tag }}
        </span>
      </div>
    </div>

    <!-- Content Area -->
    <div class="p-3 md:p-4 relative z-20 flex flex-col flex-1">
      <div v-if="product.category?.name" class="text-xs theme-text-muted tracking-wide mb-1 md:mb-2 truncate">
        {{ t('products.categoryLabel') }} · {{ getLocalizedText(product.category.name) }}
      </div>
      <h3 class="text-sm md:text-lg font-bold theme-text-primary mb-1 md:mb-2 transition-colors line-clamp-1">
        {{ getLocalizedText(product.title) }}
      </h3>

      <!-- Badges -->
      <div class="mb-2 md:mb-3 flex flex-wrap items-center gap-1 md:gap-2">
        <!-- Mobile: show only fulfillment type badge -->
        <span class="md:hidden theme-badge text-xs"
          :class="product.fulfillment_type === 'auto' ? 'theme-badge-info' : 'theme-badge-neutral'">
          {{ getFulfillmentTypeLabel(product.fulfillment_type) }}
        </span>

        <!-- Desktop: show all badges -->
        <span class="hidden md:inline-flex theme-badge"
          :class="product.purchase_type === 'guest' ? 'theme-badge-warning' : 'theme-badge-success'">
          <svg v-if="product.purchase_type === 'guest'" class="mr-1 h-3 w-3" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 21v-2a4 4 0 00-4-4H7a4 4 0 00-4 4v2" />
            <circle cx="9.5" cy="7" r="3" stroke-width="2" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 8l2 2-2 2" />
          </svg>
          <svg v-else class="mr-1 h-3 w-3" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <rect x="3" y="11" width="18" height="10" rx="2" ry="2" stroke-width="2" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 11V8a5 5 0 0110 0v3" />
          </svg>
          {{ getPurchaseTypeLabel(product.purchase_type) }}
        </span>

        <span class="hidden md:inline-flex theme-badge"
          :class="product.fulfillment_type === 'auto' ? 'theme-badge-info' : 'theme-badge-neutral'">
          <svg v-if="product.fulfillment_type === 'auto'" class="mr-1 h-3 w-3" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 2L3 14h7l-1 8 10-12h-7l1-8z" />
          </svg>
          <svg v-else class="mr-1 h-3 w-3" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.7 6.3l3 3m-9.4 9.4l-4 1 1-4 9.9-9.9a2.1 2.1 0 013 3L8.3 18.7z" />
          </svg>
          {{ getFulfillmentTypeLabel(product.fulfillment_type) }}
        </span>

        <span class="hidden md:inline-flex theme-badge"
          :class="getStockBadgeClass(product.stock_status)">
          {{ getStockStatusLabel(product) }}
        </span>
      </div>

      <p class="hidden md:block theme-text-secondary text-sm mb-6 line-clamp-2">
        {{ getLocalizedText(product.description) }}
      </p>

      <div class="product-card-footer">
        <div class="product-card-price-block">
          <span class="product-card-price-label">{{ t('products.price') }}</span>
          <span
            class="product-card-price-main"
            :class="{ 'product-card-price-main--promotion': hasProductPromotionPrice }"
            :aria-label="activePriceAria"
          >
            <span class="product-card-price-amount">{{ activePriceParts.amount }}</span>
            <span v-if="activePriceParts.currency" class="product-card-price-currency">{{ activePriceParts.currency }}</span>
          </span>
          <div v-if="hasProductPromotionPrice" class="product-card-price-meta">
            <span
              class="product-card-original-price"
              :aria-label="originalPriceAria"
            >{{ formatPrice(product.price_amount, siteCurrency) }}</span>
            <span class="theme-badge theme-badge-danger theme-badge-xs">
              {{ t('products.promotionTag') }}
            </span>
          </div>
          <div v-else-if="hasWholesalePrices(product)" class="product-card-price-meta">
            <span class="theme-badge theme-badge-success theme-badge-xs">
              {{ t('products.wholesaleTag') }}
            </span>
          </div>
          <div v-else-if="hasPromotionRules(product)" class="product-card-price-meta">
            <span class="theme-badge theme-badge-warning theme-badge-xs">
              {{ t('products.promotionBadge') }}
            </span>
          </div>
        </div>

        <button
          type="button"
          :aria-label="t('products.quickBuyAria')"
          class="product-card-buy-button"
          :class="{ 'product-card-buy-button--disabled': isSoldOut(product) }"
          :disabled="isSoldOut(product)"
          :aria-disabled="isSoldOut(product)"
          @click.stop="$emit('quickBuy', product)"
        >
          <span class="product-card-buy-icon" aria-hidden="true">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 100 4 2 2 0 000-4z" />
            </svg>
          </span>
          <span>{{ t('quickBuy.buyNow') }}</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { computed, ref, watch } from 'vue'
import { getFirstImageUrl, getImageUrl } from '../utils/image'
import { useLocalized, useProductLabels } from '../composables/useProduct'

const props = withDefaults(defineProps<{
  product: any
  index?: number
  maxTags?: number
  animationStep?: number
}>(), {
  index: 0,
  maxTags: 2,
  animationStep: 50,
})

defineEmits<{
  click: [slug: string]
  quickBuy: [product: any]
}>()

const { t } = useI18n()
const { getLocalizedText, siteCurrency, formatPrice } = useLocalized()
const { getPurchaseTypeLabel, getFulfillmentTypeLabel, getStockBadgeClass, getStockStatusLabel, isSoldOut, hasPromotionPrice, getPromotionPriceAmount, hasPromotionRules, hasWholesalePrices } = useProductLabels()

const hasProductPromotionPrice = computed(() => hasPromotionPrice(props.product))

const splitPriceDisplay = (amount: any) => {
  const currency = siteCurrency.value
  const display = formatPrice(amount, currency)
  if (display === '-') return { amount: display, currency: '' }

  const normalizedCurrency = String(currency || '').trim()
  const currencySuffix = normalizedCurrency ? ` ${normalizedCurrency}` : ''
  if (currencySuffix && display.endsWith(currencySuffix)) {
    return {
      amount: display.slice(0, -currencySuffix.length),
      currency: normalizedCurrency,
    }
  }

  return { amount: display, currency: '' }
}

const activePriceAmount = computed(() => (
  hasProductPromotionPrice.value
    ? getPromotionPriceAmount(props.product)
    : props.product?.price_amount
))

const activePriceParts = computed(() => splitPriceDisplay(activePriceAmount.value))

const activePriceAria = computed(() => {
  const price = formatPrice(activePriceAmount.value, siteCurrency.value)
  return hasProductPromotionPrice.value
    ? t('products.promotionPriceAria', { price })
    : t('products.priceAria', { price })
})

const originalPriceAria = computed(() => (
  t('products.originalPriceAria', {
    price: formatPrice(props.product?.price_amount, siteCurrency.value),
  })
))

const imageErrored = ref(false)
const attemptIdx = ref(0)

const imageCandidates = computed<string[]>(() => {
  const arr: string[] = []
  const primary = getFirstImageUrl(props.product?.images)
  if (primary) arr.push(primary)
  const categoryIcon = props.product?.category?.icon
  if (categoryIcon) {
    const resolved = getImageUrl(categoryIcon)
    if (resolved && resolved !== primary) arr.push(resolved)
  }
  return arr
})

const displayImageSrc = computed(() => imageCandidates.value[attemptIdx.value] ?? '')

watch(imageCandidates, () => {
  attemptIdx.value = 0
  imageErrored.value = false
}, { deep: true })

const handleImageError = () => {
  if (attemptIdx.value < imageCandidates.value.length - 1) {
    attemptIdx.value++
  } else {
    imageErrored.value = true
  }
}
</script>

<style scoped>
.product-card-footer {
  position: relative;
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 0.85rem;
  margin-top: auto;
  padding-top: 1rem;
}

.product-card-footer::before {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(
    90deg,
    transparent,
    color-mix(in oklab, var(--ui-border-strong) 58%, transparent),
    transparent
  );
}

.product-card-price-block {
  min-width: 0;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 0.18rem;
}

.product-card-price-label {
  color: var(--ui-text-muted);
  font-size: 0.68rem;
  font-weight: 700;
  letter-spacing: 0.16em;
  line-height: 1;
  text-transform: uppercase;
}

.product-card-price-main {
  display: inline-flex;
  align-items: baseline;
  gap: 0.35rem;
  color: var(--ui-price-primary);
  line-height: 1;
  white-space: nowrap;
}

.product-card-price-main--promotion {
  color: var(--ui-price-promotion);
}

.product-card-price-amount {
  font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, "Liberation Mono", monospace;
  font-size: clamp(1.35rem, 4.8vw, 1.72rem);
  font-weight: 850;
  font-variant-numeric: tabular-nums;
  letter-spacing: -0.045em;
}

.product-card-price-currency {
  color: var(--ui-text-muted);
  font-size: 0.72rem;
  font-weight: 800;
  letter-spacing: 0.08em;
}

.product-card-price-meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.35rem;
  min-height: 1.1rem;
}

.product-card-original-price {
  color: var(--ui-price-original);
  font-size: 0.72rem;
  line-height: 1;
  text-decoration: line-through;
}

.product-card-buy-button {
  position: relative;
  isolation: isolate;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.42rem;
  min-height: 2.7rem;
  flex-shrink: 0;
  border: 0;
  border-radius: 999px;
  padding: 0 1.15rem;
  background: linear-gradient(135deg, #2563eb 0%, #4f46e5 58%, #7c3aed 100%);
  color: #ffffff;
  box-shadow: 0 12px 26px rgba(37, 99, 235, 0.24);
  font-size: 0.84rem;
  font-weight: 700;
  letter-spacing: -0.01em;
  line-height: 1;
  transition:
    transform 0.2s ease,
    box-shadow 0.2s ease,
    filter 0.2s ease;
}

.product-card-buy-button::after {
  content: "";
  position: absolute;
  inset: 1px;
  z-index: -1;
  border-radius: inherit;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.22), transparent 62%);
  pointer-events: none;
}

.product-card-buy-button:hover:not(:disabled) {
  transform: translateY(-2px);
  filter: saturate(1.08);
  box-shadow: 0 16px 34px rgba(37, 99, 235, 0.3);
}

.product-card-buy-button:active:not(:disabled) {
  transform: translateY(0);
  box-shadow: 0 10px 22px rgba(37, 99, 235, 0.24);
}

.product-card-buy-button:focus-visible {
  outline: none;
  box-shadow:
    0 16px 34px rgba(37, 99, 235, 0.3),
    0 0 0 3px var(--ui-focus-ring);
}

.product-card-buy-button--disabled,
.product-card-buy-button:disabled {
  cursor: not-allowed;
  background: linear-gradient(135deg, #cbd5e1, #94a3b8);
  color: rgba(255, 255, 255, 0.86);
  box-shadow: none;
  filter: grayscale(0.15);
  opacity: 0.72;
}

.product-card-buy-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.dark .product-card-buy-button {
  box-shadow: 0 16px 34px rgba(37, 99, 235, 0.18);
}

.dark .product-card-buy-button:hover:not(:disabled) {
  box-shadow: 0 20px 40px rgba(79, 70, 229, 0.28);
}

@media (max-width: 380px) {
  .product-card-footer {
    align-items: stretch;
    flex-direction: column;
  }

  .product-card-buy-button {
    width: 100%;
  }
}
</style>
