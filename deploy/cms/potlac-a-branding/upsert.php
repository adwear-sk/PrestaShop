<?php
// Creates or updates the "Potlač a branding" CMS page from content.html (same dir).
// Usage: php upsert.php [content.html path]
require '/var/www/html/vendor/autoload.php';
require '/var/www/html/config/config.inc.php';

use PrestaShop\PrestaShop\Core\Domain\CmsPage\Command\AddCmsPageCommand;
use PrestaShop\PrestaShop\Core\Domain\CmsPage\Command\EditCmsPageCommand;

$content = file_get_contents($argv[1] ?? __DIR__ . '/content.html');
$slug = 'potlac-a-branding';
$title = 'Potlač a branding';
$meta = 'Potlač a výšivka loga na tričká, polokošele, mikiny a pracovné odevy. Sieťotlač, transferová potlač DTF aj výšivka s vizualizáciou pred výrobou.';

$kernel = new AdminKernel(getenv('SYMFONY_ENV') ?: 'prod', false);
$kernel->boot();
$bus = $kernel->getContainer()->get('prestashop.core.command_bus');

$langs = array_map(static fn ($l) => (int) $l['id_lang'], Language::getLanguages(false));
$l = static fn ($v) => array_fill_keys($langs, $v);

$id = (int) Db::getInstance()->getValue('SELECT id_cms FROM ' . _DB_PREFIX_ . 'cms_lang WHERE link_rewrite = "' . pSQL($slug) . '"');
if ($id) {
    $cmd = new EditCmsPageCommand($id);
    $cmd->setLocalizedContent($l($content));
    $cmd->setLocalizedMetaDescription($l($meta));
    $bus->handle($cmd);
    echo "updated id=$id\n";
} else {
    $id = $bus->handle(new AddCmsPageCommand(1, $l($title), $l($title), $l($meta), $l($slug), $l($content), true, true, [(int) Configuration::get('PS_SHOP_DEFAULT')]))->getValue();
    echo "created id=$id\n";
}
Tools::clearSmartyCache();

$stored = Db::getInstance()->getValue('SELECT content FROM ' . _DB_PREFIX_ . 'cms_lang WHERE id_cms = ' . (int) $id . ' AND id_lang = ' . $langs[0]);
echo 'input=', strlen($content), ' stored=', strlen((string) $stored), ' identical=', var_export($stored === $content, true), PHP_EOL;
echo 'url=', parse_url(Context::getContext()->link->getCMSLink((int) $id), PHP_URL_PATH), PHP_EOL;
