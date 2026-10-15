-- Footer: the "Produkty" link column becomes "Ochrana spotrebiteľa" (shipping, legal
-- pages + the withdrawal form); "Naša spoločnosť" keeps the company pages, gains the
-- sitemap and a "Chcem potlač!" link. The theme highlights withdrawal and potlač.
UPDATE ps_link_block
SET content = '{"cms":[1,3,8,6,7],"product":[false],"static":[false],"category":[false]}'
WHERE id_link_block = 1;

UPDATE ps_link_block_lang
SET name = 'Ochrana spotrebiteľa',
    custom_content = '[{"title":"Odst\\u00fapenie od zmluvy","url":"\\/module\\/adwear_withdrawal\\/form"}]'
WHERE id_link_block = 1;

UPDATE ps_link_block
SET content = '{"cms":[4],"static":["contact","sitemap"],"product":[false],"category":[false]}'
WHERE id_link_block = 2;

UPDATE ps_link_block_lang
SET custom_content = '[{"title":"Chcem potla\\u010d!","url":"\\/content\\/9-potlac-a-branding"}]'
WHERE id_link_block = 2;
