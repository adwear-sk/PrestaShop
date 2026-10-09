-- Slovak text for the mail footer (mails/themes/modern/components/footer.html.twig).
INSERT INTO ps_translation (id_lang, `key`, translation, domain, theme)
SELECT 1, 'Visit us at:', 'Navštívte nás na:', 'EmailsBody', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ps_translation WHERE id_lang = 1 AND `key` = 'Visit us at:' AND domain = 'EmailsBody');
