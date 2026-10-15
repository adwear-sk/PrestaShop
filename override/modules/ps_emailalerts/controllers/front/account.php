<?php
/**
 * "Moje upozornenia" page without the dev-mode deprecation banner.
 *
 * MailAlert::getMailAlerts() (ps_emailalerts 3.0.1, also upstream master) builds
 * cover URLs with the old "productId-imageId" identifier, so Link::getImageLink()
 * prints "Passing image identifier in the old format is deprecated" above the page
 * whenever _PS_MODE_DEV_ is on and the customer has an alert. The URL it returns is
 * still correct, so only that one notice is muted while the list is built.
 * Drop this override once the module passes plain image IDs.
 */
class Ps_EmailAlertsAccountModuleFrontControllerOverride extends Ps_EmailAlertsAccountModuleFrontController
{
    public function initContent()
    {
        set_error_handler(
            static function (int $errno, string $errstr): bool {
                return str_starts_with($errstr, 'Passing image identifier in the old format is deprecated');
            },
            E_USER_DEPRECATED
        );

        try {
            parent::initContent();
        } finally {
            restore_error_handler();
        }
    }
}
