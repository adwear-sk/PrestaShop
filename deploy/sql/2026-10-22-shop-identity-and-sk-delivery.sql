-- Seller identity on invoices and delivery to Slovakia only (2026-10-22).
-- The PDF header prints PS_SHOP_CITY and PS_SHOP_DETAILS: the city had a typo, and
-- the legal name and register details were missing (the header name is the shop
-- name). Each update runs only while the value differs (the city compared byte for
-- byte: the column collation ignores accents).
UPDATE ps_configuration
SET value = 'Sečovská Polianka', date_upd = NOW()
WHERE name = 'PS_SHOP_CITY'
  AND value COLLATE utf8mb4_bin = 'Sečovska Polianka';

UPDATE ps_configuration
SET value = 'adwear s. r. o., IČO: 56383410, DIČ: 2122288828, zapísaná v Obchodnom registri Okresného súdu Prešov, oddiel: Sro, vložka č. 48213/P',
    date_upd = NOW()
WHERE name = 'PS_SHOP_DETAILS'
  AND (value IS NULL OR value = '');

-- The shop delivers only to Slovakia (VOP, Doprava a platba): every other country
-- leaves the address and checkout forms. Addresses and orders are kept.
UPDATE ps_country
SET active = 0
WHERE iso_code <> 'SK'
  AND active = 1;
