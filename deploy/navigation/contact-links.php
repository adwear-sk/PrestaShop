<?php
// Navigation tweaks for the contact page (idempotent):
//  - main menu (ps_mainmenu): replace "O nás" (CMS4) with a "Kontaktujte nás" custom link
//  - footer (ps_linklist "Naša spoločnosť" block): add the contact page
// Usage: php contact-links.php
require '/var/www/html/config/config.inc.php';
require_once _PS_MODULE_DIR_ . 'ps_mainmenu/ps_menutoplinks.class.php';

const MENU_LABEL = 'Kontaktujte nás';
const REPLACED_MENU_ITEM = 'CMS4'; // O nás
const FOOTER_BLOCK = 'Naša spoločnosť';

$db = Db::getInstance();
$idShop = (int) Configuration::get('PS_SHOP_DEFAULT');
$languages = array_map(static fn ($l) => (int) $l['id_lang'], Language::getLanguages(false));
$contactUrl = (string) parse_url(Context::getContext()->link->getPageLink('contact'), PHP_URL_PATH);

// --- Main menu ---------------------------------------------------------------
$labels = array_fill_keys($languages, MENU_LABEL);
$links = array_fill_keys($languages, $contactUrl);
$idLink = (int) $db->getValue(
    'SELECT id_linksmenutop FROM ' . _DB_PREFIX_ . 'linksmenutop_lang WHERE label = "' . pSQL(MENU_LABEL) . '" AND id_shop = ' . $idShop
);
if ($idLink) {
    Ps_MenuTopLinks::update($links, $labels, 0, $idShop, $idLink);
} else {
    Ps_MenuTopLinks::add($links, $labels, 0, $idShop);
    $idLink = (int) $db->getValue('SELECT MAX(id_linksmenutop) FROM ' . _DB_PREFIX_ . 'linksmenutop WHERE id_shop = ' . $idShop);
}

$items = array_values(array_filter(explode(',', (string) Configuration::get('MOD_BLOCKTOPMENU_ITEMS', null, null, $idShop))));
$lnk = 'LNK' . $idLink;
if (!in_array($lnk, $items, true)) {
    $at = array_search(REPLACED_MENU_ITEM, $items, true);
    if ($at === false) {
        $items[] = $lnk;
    } else {
        $items[$at] = $lnk;
    }
} else {
    $items = array_values(array_diff($items, [REPLACED_MENU_ITEM]));
}
Configuration::updateValue('MOD_BLOCKTOPMENU_ITEMS', implode(',', $items), false, null, $idShop);

// --- Footer ------------------------------------------------------------------
$block = $db->getRow(
    'SELECT b.id_link_block, b.content FROM ' . _DB_PREFIX_ . 'link_block b
     JOIN ' . _DB_PREFIX_ . 'link_block_lang bl ON bl.id_link_block = b.id_link_block
     WHERE bl.name = "' . pSQL(FOOTER_BLOCK) . '"'
);
if ($block) {
    $content = json_decode((string) $block['content'], true) ?: [];
    $static = array_values(array_filter($content['static'] ?? []));
    if (!in_array('contact', $static, true)) {
        $static[] = 'contact';
    }
    $content['static'] = $static;
    $db->update('link_block', ['content' => pSQL(json_encode($content))], 'id_link_block = ' . (int) $block['id_link_block']);
} else {
    echo "WARNING: footer block '" . FOOTER_BLOCK . "' not found, footer left unchanged\n";
}

// --- Caches ------------------------------------------------------------------
$cacheDir = _PS_CACHE_DIR_ . 'ps_mainmenu';
if (is_dir($cacheDir)) {
    $files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($cacheDir, FilesystemIterator::SKIP_DOTS), RecursiveIteratorIterator::CHILD_FIRST);
    foreach ($files as $file) {
        $file->isDir() ? @rmdir($file->getPathname()) : @unlink($file->getPathname());
    }
}
Tools::clearSmartyCache();

echo 'menu: ', Configuration::get('MOD_BLOCKTOPMENU_ITEMS', null, null, $idShop), " ($lnk -> $contactUrl)", PHP_EOL;
echo 'footer: ', $block ? $db->getValue('SELECT content FROM ' . _DB_PREFIX_ . 'link_block WHERE id_link_block = ' . (int) $block['id_link_block']) : '-', PHP_EOL;
