-- ps_linklist was hooked to displayAdditionalCustomerAddressFields (the module never
-- registers it). As a widget it rendered an empty link block on every address card.
DELETE hm FROM ps_hook_module hm
JOIN ps_hook h ON h.id_hook = hm.id_hook
JOIN ps_module m ON m.id_module = hm.id_module
WHERE m.name = 'ps_linklist' AND h.name = 'displayAdditionalCustomerAddressFields';
