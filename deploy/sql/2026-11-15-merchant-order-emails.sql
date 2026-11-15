-- New-order mails to the shop (2026-11-15). ps_emailalerts sends its merchant
-- "new_order" mail only to MA_MERCHANT_ORDER_EMAILS, which was never set
-- (MA_MERCHANT_MAILS feeds stock alerts only), so the shop got no mail for orders
-- or quote requests (quotes run validateOrder too). A value set in the BO is kept.
INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
SELECT NULL, NULL, 'MA_MERCHANT_ORDER_EMAILS', 'obchod@adwear.sk', NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM ps_configuration WHERE name = 'MA_MERCHANT_ORDER_EMAILS'
);

UPDATE ps_configuration
SET value = 'obchod@adwear.sk', date_upd = NOW()
WHERE name = 'MA_MERCHANT_ORDER_EMAILS'
  AND (value IS NULL OR value = '');
