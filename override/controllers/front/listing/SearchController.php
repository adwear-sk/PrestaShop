<?php
/**
 * Adds stock status and a "from" price to the AJAX search results used by
 * the header search flyout. The core whitelist (SearchResultProductFilter)
 * drops every stock field, so they are computed here and merged back in.
 * The "from" price comes from the ProductListingFrontController override.
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

        $fromPrices = $this->getAdwFromPrices($ids);

        $lastQties = (int) Configuration::get('PS_LAST_QTIES');
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

            $extras[$id] = [
                'adw_stock' => $level,
                'adw_stock_label' => $label,
                'adw_from_price' => $fromPrices[$id] ?? null,
            ];
        }

        return $extras;
    }
}
