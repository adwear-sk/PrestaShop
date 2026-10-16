-- 24 products per listing page instead of 12 (divides into the 2- and 3-column grids);
-- "Načítať ďalšie" adds the next 24 below.
UPDATE ps_configuration SET value = '24', date_upd = NOW() WHERE name = 'PS_PRODUCTS_PER_PAGE';
