-- § 20a zákona 108/2024 (since 19 June 2026): the online withdrawal function
-- must be labelled "odstúpiť od zmluvy tu" or an equally clear phrase. The
-- footer link said "Odstúpenie od zmluvy". The block stores its links as JSON
-- with \u escapes; the exact old link entry scopes the change and makes it
-- repeatable (compared as bytes: the column's collation ignores accents).
UPDATE ps_link_block_lang lbl
JOIN ps_lang l ON l.id_lang = lbl.id_lang AND l.iso_code = 'sk'
SET lbl.custom_content = REPLACE(lbl.custom_content,
    '{"title":"Odst\\u00fapenie od zmluvy","url":"\\/module\\/adwear_withdrawal\\/form"}',
    '{"title":"Odst\\u00fapi\\u0165 od zmluvy tu","url":"\\/module\\/adwear_withdrawal\\/form"}')
WHERE LOCATE(CAST('{"title":"Odst\\u00fapenie od zmluvy","url":"\\/module\\/adwear_withdrawal\\/form"}' AS BINARY), CAST(lbl.custom_content AS BINARY)) > 0;
