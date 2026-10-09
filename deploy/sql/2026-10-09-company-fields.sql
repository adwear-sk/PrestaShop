-- Company purchases: a DIČ column next to the core IČO (dni) and IČ DPH
-- (vat_number), all three in the SK address format, the "Nakupujem na firmu"
-- toggle label, and labelled IDs on invoices instead of bare numbers in the
-- address blocks. The dic field itself is declared in override/classes/Address.php.
ALTER TABLE ps_address ADD COLUMN dic VARCHAR(16) DEFAULT NULL AFTER dni;
UPDATE ps_address_format SET format = REPLACE(format, 'company\nvat_number', 'company\ndni\ndic\nvat_number') WHERE id_country = (SELECT id_country FROM ps_country WHERE iso_code = 'SK') AND format NOT LIKE '%dni%';
INSERT INTO ps_translation (id_lang, `key`, translation, domain, theme) SELECT 1, 'I am buying as a company', 'Nakupujem na firmu', 'ShopThemeCustomeraccount', 'adwear' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ps_translation WHERE id_lang = 1 AND `key` = 'I am buying as a company' AND domain = 'ShopThemeCustomeraccount' AND theme = 'adwear');
INSERT INTO ps_translation (id_lang, `key`, translation, domain, theme) SELECT 1, 'Tax ID', 'DIČ', 'ShopThemeCustomeraccount', 'adwear' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ps_translation WHERE id_lang = 1 AND `key` = 'Tax ID' AND domain = 'ShopThemeCustomeraccount' AND theme = 'adwear');
INSERT INTO ps_translation (id_lang, `key`, translation, domain, theme) SELECT 1, 'Tax ID', 'DIČ', 'ShopPdf', NULL FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ps_translation WHERE id_lang = 1 AND `key` = 'Tax ID' AND domain = 'ShopPdf' AND theme IS NULL);
UPDATE ps_configuration SET value = '{"avoid":["dni","dic","vat_number"]}' WHERE name IN ('PS_INVCE_INVOICE_ADDR_RULES', 'PS_INVCE_DELIVERY_ADDR_RULES');
