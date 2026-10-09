-- Slovak label for the DIČ field on the back-office address form
-- (src/Adapter/Address/AddressDicHookSubscriber.php).
INSERT INTO ps_translation (id_lang, `key`, translation, domain, theme) SELECT 1, 'Tax ID', 'DIČ', 'AdminOrderscustomersFeature', NULL FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ps_translation WHERE id_lang = 1 AND `key` = 'Tax ID' AND domain = 'AdminOrderscustomersFeature' AND theme IS NULL);
