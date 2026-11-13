-- Drop the "Dostupnosť" (availability) facet: ps_facetedsearch 5.1.0 counts it
-- with a cubic stock join that runs into the 120 s max_execution_time on cold
-- listings (upstream fix PR #1346 is unreleased). Revisit with real traffic.
-- The storefront reads ps_layered_category; the template's serialized filter
-- list is only used when the BO regenerates it, so both are cleaned.
DELETE FROM ps_layered_category WHERE type = 'availability';

-- Remove the stock entry and decrement the array length of the serialized
-- template. LOCATE on the entry keeps the second run a no-op.
UPDATE ps_layered_filter
SET filters = CONCAT(
        'a:',
        CAST(SUBSTRING_INDEX(SUBSTRING(filters, 3), ':', 1) AS UNSIGNED) - 1,
        SUBSTRING(
            REGEXP_REPLACE(filters, 's:23:"layered_selection_stock";a:2:\\{[^}]*\\}', ''),
            LOCATE(':{', filters)
        )
    )
WHERE LOCATE('s:23:"layered_selection_stock";', filters) > 0;

-- Cached filter blocks still carry the facet.
DELETE FROM ps_layered_filter_block;
