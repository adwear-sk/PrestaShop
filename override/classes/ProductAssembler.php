<?php
/**
 * Adds a "from" price to every assembled product, so all product cards show it:
 * listings (category, search, brand…) and the card modules (ps_featuredproducts,
 * ps_specials, ps_newproducts, ps_bestsellers, ps_crossselling,
 * ps_categoryproducts, ps_viewedproduct). adw_from_price is the formatted price
 * of the cheapest combination, set only where the combination prices differ, so
 * the theme can show "od 3,00 €" instead of the default combination's price.
 */
class ProductAssembler extends ProductAssemblerCore
{
    /** @var Context */
    private $adwContext;

    public function __construct(Context $context)
    {
        parent::__construct($context);
        $this->adwContext = $context;
    }

    public function assembleProduct(array $rawProduct)
    {
        $product = parent::assembleProduct($rawProduct);

        if (is_array($product) && isset($product['id_product'])) {
            $fromPrices = static::getAdwFromPrices([(int) $product['id_product']], $this->adwContext);
            $product['adw_from_price'] = $fromPrices[(int) $product['id_product']] ?? null;
        }

        return $product;
    }

    public function assembleProducts(array $rawProducts)
    {
        $products = parent::assembleProducts($rawProducts);

        $ids = [];
        foreach ($products as $product) {
            if (is_array($product) && isset($product['id_product'])) {
                $ids[] = (int) $product['id_product'];
            }
        }

        $fromPrices = static::getAdwFromPrices($ids, $this->adwContext);
        foreach ($products as &$product) {
            if (is_array($product) && isset($product['id_product'])) {
                $product['adw_from_price'] = $fromPrices[(int) $product['id_product']] ?? null;
            }
        }

        return $products;
    }

    /**
     * Also used by the search flyout (SearchController override).
     *
     * @param int[] $ids
     *
     * @return array<int, string> formatted cheapest price, only for products whose combination prices differ
     */
    public static function getAdwFromPrices(array $ids, Context $context): array
    {
        if (empty($ids)) {
            return [];
        }

        $cheapest = [];
        foreach (Db::getInstance()->executeS(
            'SELECT id_product, id_product_attribute, price FROM ' . _DB_PREFIX_ . 'product_attribute_shop
            WHERE id_product IN (' . implode(',', array_map('intval', $ids)) . ') AND id_shop = ' . (int) $context->shop->id . '
            ORDER BY id_product, price ASC, id_product_attribute ASC'
        ) ?: [] as $row) {
            $id = (int) $row['id_product'];
            if (!isset($cheapest[$id])) {
                $cheapest[$id] = ['ipa' => (int) $row['id_product_attribute'], 'min' => (float) $row['price'], 'max' => (float) $row['price']];
            }
            $cheapest[$id]['max'] = (float) $row['price'];
        }

        $useTax = Product::getTaxCalculationMethod((int) $context->cookie->id_customer) == PS_TAX_INC;
        $locale = $context->getCurrentLocale();
        $currency = $context->currency->iso_code;

        $fromPrices = [];
        foreach ($cheapest as $id => $row) {
            if ($row['min'] != $row['max']) {
                $fromPrices[$id] = $locale->formatPrice(Product::getPriceStatic($id, $useTax, $row['ipa']), $currency);
            }
        }

        return $fromPrices;
    }
}
