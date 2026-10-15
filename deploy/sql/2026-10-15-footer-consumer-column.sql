-- Footer: the "Produkty" link column becomes "Ochrana spotrebiteľa" (legal pages +
-- the withdrawal form, highlighted by the theme); "Naša spoločnosť" keeps the
-- company pages and gains Potlač a branding.
UPDATE ps_link_block
SET content = '{"cms":[3,8,6,7],"product":[false],"static":[false],"category":[false]}'
WHERE id_link_block = 1;

UPDATE ps_link_block_lang
SET name = 'Ochrana spotrebiteľa',
    custom_content = '[{"title":"Odst\\u00fapenie od zmluvy","url":"\\/module\\/adwear_withdrawal\\/form"}]'
WHERE id_link_block = 1;

UPDATE ps_link_block
SET content = '{"cms":[1,4,9],"static":["contact"],"product":[false],"category":[false]}'
WHERE id_link_block = 2;

UPDATE ps_link_block_lang
SET custom_content = ''
WHERE id_link_block = 2;
