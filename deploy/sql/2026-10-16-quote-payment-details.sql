-- Icon, CSS class and checkout hint for the "Cenová ponuka" payment option
-- (adwear_quote), stored in adwear_shippay_details' config. Only when not set
-- yet, so an edit made in the back office is kept.
UPDATE ps_configuration
SET value = JSON_SET(value, '$.payments.adwear_quote', JSON_OBJECT(
        'icon', 'request_quote',
        'class', 'payment-option--quote',
        'hint', 'Nezáväzná žiadosť – teraz nič neplatíte. Pripravíme vám cenovú ponuku (napríklad na väčšie množstvo alebo s potlačou) a pošleme ju e-mailom. Objednávku potvrdíte až po jej odsúhlasení.'
    )),
    date_upd = NOW()
WHERE name = 'ADWEARSHIPPAY_DETAILS'
  AND JSON_VALID(value)
  AND NOT JSON_CONTAINS_PATH(value, 'one', '$.payments.adwear_quote');
