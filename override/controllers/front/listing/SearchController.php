<?php
/**
 * Adds stock status and a "from" price to the AJAX search results used by
 * the header search flyout. The core whitelist (SearchResultProductFilter)
 * drops every stock field, so they are computed here and merged back in.
 */
class SearchController extends SearchControllerCore
{
    protected function prepareProductArrayForAjaxReturn(array $products)
    {
        $ids = [];
        foreach ($products as $product) {
            $ids[] = (int) $product['id_product'];
        }

        $filtered = parent::prepareProductArrayForAjaxReturn($products);
        if (empty($ids)) {
            return $filtered;
        }

        $extras = $this->getAdwSearchExtras($ids);
        foreach ($filtered as $k => $product) {
            $id = (int) $product['id_product'];
            foreach ($extras[$id] ?? [] as $key => $value) {
                $filtered[$k][$key] = $value;
            }
        }

        return $filtered;
    }

    /**
     * @param int[] $ids
     *
     * @return array<int, array{adw_stock: string, adw_stock_label: string, adw_from_price: string|null}>
     */
    private function getAdwSearchExtras(array $ids): array
    {
        $db = Db::getInstance();
        $idShop = (int) $this->context->shop->id;
        $in = implode(',', array_map('intval', $ids));

        $stock = [];
        foreach ($db->executeS(
            'SELECT id_product, quantity FROM ' . _DB_PREFIX_ . 'stock_available
            WHERE id_product IN (' . $in . ') AND id_product_attribute = 0' . StockAvailable::addSqlShopRestriction(null, $idShop)
        ) ?: [] as $row) {
            $stock[(int) $row['id_product']] = (int) $row['quantity'];
        }

        // Cheapest combination per product, only where the combination prices differ.
        $cheapest = [];
        foreach ($db->executeS(
            'SELECT id_product, id_product_attribute, price FROM ' . _DB_PREFIX_ . 'product_attribute_shop
            WHERE id_product IN (' . $in . ') AND id_shop = ' . $idShop . '
            ORDER BY id_product, price ASC, id_product_attribute ASC'
        ) ?: [] as $row) {
            $id = (int) $row['id_product'];
            if (!isset($cheapest[$id])) {
                $cheapest[$id] = ['ipa' => (int) $row['id_product_attribute'], 'min' => (float) $row['price'], 'max' => (float) $row['price']];
            }
            $cheapest[$id]['max'] = (float) $row['price'];
        }

        $lastQties = (int) Configuration::get('PS_LAST_QTIES');
        $useTax = Product::getTaxCalculationMethod((int) $this->context->cookie->id_customer) == PS_TAX_INC;
        $locale = $this->context->getCurrentLocale();
        $currency = $this->context->currency->iso_code;

        $extras = [];
        foreach ($ids as $id) {
            $qty = $stock[$id] ?? 0;
            if ($qty <= 0) {
                $level = 'out';
                $label = 'Vypredané';
            } elseif ($qty <= $lastQties) {
                $level = 'low';
                $label = 'Posledné kusy';
            } else {
                $level = 'in';
                $label = 'Skladom';
            }

            $fromPrice = null;
            if (isset($cheapest[$id]) && $cheapest[$id]['min'] != $cheapest[$id]['max']) {
                $fromPrice = $locale->formatPrice(
                    Product::getPriceStatic($id, $useTax, $cheapest[$id]['ipa']),
                    $currency
                );
            }

            $extras[$id] = [
                'adw_stock' => $level,
                'adw_stock_label' => $label,
                'adw_from_price' => $fromPrice,
            ];
        }

        return $extras;
    }
}
