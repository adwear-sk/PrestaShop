<?php
/**
 * Adds a "from" price to the products of every listing (category, search,
 * brand, new products…). adw_from_price is the formatted price of the cheapest
 * combination, set only where the combination prices differ, so the theme can
 * show "od 3,00 €" instead of the default combination's price.
 */
abstract class ProductListingFrontController extends ProductListingFrontControllerCore
{
    protected function prepareMultipleProductsForTemplate(array $products)
    {
        $products = parent::prepareMultipleProductsForTemplate($products);

        $ids = [];
        foreach ($products as $product) {
            $ids[] = (int) $product['id_product'];
        }

        $fromPrices = $this->getAdwFromPrices($ids);
        foreach ($products as $product) {
            $product['adw_from_price'] = $fromPrices[(int) $product['id_product']] ?? null;
        }

        return $products;
    }

    /**
     * @param int[] $ids
     *
     * @return array<int, string> formatted cheapest price, only for products whose combination prices differ
     */
    protected function getAdwFromPrices(array $ids): array
    {
        if (empty($ids)) {
            return [];
        }

        $cheapest = [];
        foreach (Db::getInstance()->executeS(
            'SELECT id_product, id_product_attribute, price FROM ' . _DB_PREFIX_ . 'product_attribute_shop
            WHERE id_product IN (' . implode(',', array_map('intval', $ids)) . ') AND id_shop = ' . (int) $this->context->shop->id . '
            ORDER BY id_product, price ASC, id_product_attribute ASC'
        ) ?: [] as $row) {
            $id = (int) $row['id_product'];
            if (!isset($cheapest[$id])) {
                $cheapest[$id] = ['ipa' => (int) $row['id_product_attribute'], 'min' => (float) $row['price'], 'max' => (float) $row['price']];
            }
            $cheapest[$id]['max'] = (float) $row['price'];
        }

        $useTax = Product::getTaxCalculationMethod((int) $this->context->cookie->id_customer) == PS_TAX_INC;
        $locale = $this->context->getCurrentLocale();
        $currency = $this->context->currency->iso_code;

        $fromPrices = [];
        foreach ($cheapest as $id => $row) {
            if ($row['min'] != $row['max']) {
                $fromPrices[$id] = $locale->formatPrice(Product::getPriceStatic($id, $useTax, $row['ipa']), $currency);
            }
        }

        return $fromPrices;
    }
}
