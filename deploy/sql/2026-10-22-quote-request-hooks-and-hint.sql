-- adwear_quote: a quote is a non-binding request. Deploys don't run module
-- upgrades, so make sure its hooks are registered; without actionEmailSendBefore
-- a quote request goes out as an ordinary order confirmation.
INSERT INTO ps_hook_module (id_module, id_shop, id_hook, position)
SELECT m.id_module, ms.id_shop, h.id_hook,
       (SELECT COALESCE(MAX(hm2.position), 0) + 1
        FROM ps_hook_module hm2
        WHERE hm2.id_hook = h.id_hook AND hm2.id_shop = ms.id_shop)
FROM ps_module m
JOIN ps_module_shop ms ON ms.id_module = m.id_module
JOIN ps_hook h ON h.name IN ('actionEmailSendBefore', 'displayPaymentReturn', 'paymentOptions')
WHERE m.name = 'adwear_quote'
  AND NOT EXISTS (
      SELECT 1 FROM ps_hook_module hm
      WHERE hm.id_module = m.id_module AND hm.id_shop = ms.id_shop AND hm.id_hook = h.id_hook
  );

-- Checkout hint under the "Cenová ponuka" option (adwear_shippay_details), only
-- while it still has the text shipped in 2026-10-16-quote-payment-details.sql.
UPDATE ps_configuration
SET value = JSON_SET(value, '$.payments.adwear_quote.hint',
        'Nezáväzná žiadosť o cenovú ponuku, napríklad na väčšie množstvo alebo s potlačou. Odoslaním tejto žiadosti nevzniká povinnosť kúpiť ani zaplatiť. Podmienky prípadnej objednávky vám predložíme v ponuke.'),
    date_upd = NOW()
WHERE name = 'ADWEARSHIPPAY_DETAILS'
  AND JSON_VALID(value)
  AND JSON_UNQUOTE(JSON_EXTRACT(value, '$.payments.adwear_quote.hint')) = 'Nezáväzná žiadosť – teraz nič neplatíte. Pripravíme vám cenovú ponuku (napríklad na väčšie množstvo alebo s potlačou) a pošleme ju e-mailom. Objednávku potvrdíte až po jej odsúhlasení.';
