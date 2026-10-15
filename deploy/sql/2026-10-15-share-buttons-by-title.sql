-- The theme renders the share button next to the product title ({widget} call), so the
-- module no longer outputs into displayProductAdditionalInfo under the buy box.
DELETE hm FROM ps_hook_module hm
JOIN ps_hook h ON h.id_hook = hm.id_hook
JOIN ps_module m ON m.id_module = hm.id_module
WHERE h.name = 'displayProductAdditionalInfo' AND m.name = 'ps_sharebuttons';
