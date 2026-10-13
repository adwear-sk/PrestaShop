<?php
// Adds (or updates) the "Chcem potlač!" custom link at the end of the main menu
// (ps_mainmenu), pointing at the potlac-a-branding CMS page. Idempotent.
// The theme styles it as a blue button via its page identifier
// (lnk-chcem-potlac, see themes/adwear src/scss/prestashop/modules/_mainmenu.scss),
// so keep the label in sync with that selector.
// Usage: php menu-link.php
require '/var/www/html/config/config.inc.php';
require_once _PS_MODULE_DIR_ . 'ps_mainmenu/ps_menutoplinks.class.php';

const LABEL = 'Chcem potlač!';

$idShop = (int) Configuration::get('PS_SHOP_DEFAULT');
$idCms = (int) Db::getInstance()->getValue('SELECT id_cms FROM ' . _DB_PREFIX_ . 'cms_lang WHERE link_rewrite = "potlac-a-branding"');
if (!$idCms) {
    exit("The potlac-a-branding CMS page does not exist yet — run upsert.php first.\n");
}

$parts = parse_url(Context::getContext()->link->getCMSLink($idCms));
$url = $parts['path'] . (isset($parts['query']) ? '?' . $parts['query'] : '');

$labels = $links = [];
foreach (Language::getLanguages(false) as $language) {
    $labels[(int) $language['id_lang']] = LABEL;
    $links[(int) $language['id_lang']] = $url;
}

$idLink = (int) Db::getInstance()->getValue(
    'SELECT id_linksmenutop FROM ' . _DB_PREFIX_ . 'linksmenutop_lang WHERE label = "' . pSQL(LABEL) . '" AND id_shop = ' . $idShop
);
if ($idLink) {
    Ps_MenuTopLinks::update($links, $labels, 0, $idShop, $idLink);
} else {
    Ps_MenuTopLinks::add($links, $labels, 0, $idShop);
    $idLink = (int) Db::getInstance()->Insert_ID() ?: (int) Db::getInstance()->getValue(
        'SELECT MAX(id_linksmenutop) FROM ' . _DB_PREFIX_ . 'linksmenutop WHERE id_shop = ' . $idShop
    );
}

$items = array_filter(explode(',', (string) Configuration::get('MOD_BLOCKTOPMENU_ITEMS', null, null, $idShop)));
if (!in_array('LNK' . $idLink, $items, true)) {
    $items[] = 'LNK' . $idLink;
    Configuration::updateValue('MOD_BLOCKTOPMENU_ITEMS', implode(',', $items), false, null, $idShop);
}

// ps_mainmenu caches the rendered tree in var/cache/<env>/ps_mainmenu.
$cacheDir = _PS_CACHE_DIR_ . 'ps_mainmenu';
if (is_dir($cacheDir)) {
    $files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($cacheDir, FilesystemIterator::SKIP_DOTS), RecursiveIteratorIterator::CHILD_FIRST);
    foreach ($files as $file) {
        $file->isDir() ? @rmdir($file->getPathname()) : @unlink($file->getPathname());
    }
}
Tools::clearSmartyCache();

echo 'menu: ', Configuration::get('MOD_BLOCKTOPMENU_ITEMS', null, null, $idShop), ' | LNK', $idLink, ' -> ', $url, PHP_EOL;
