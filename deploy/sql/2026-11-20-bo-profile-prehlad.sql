-- Read-only back-office profile 'Prehľad' (orders, customers, returns, stats, stock monitoring)
-- and employee 2 moved to it from the near-SuperAdmin 'Admin' profile (sec-accounts, L1).

-- Profile, created once (keyed by its name).
INSERT INTO ps_profile (id_profile)
SELECT NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ps_profile_lang WHERE name = 'Prehľad' COLLATE utf8mb4_bin);
SET @new_profile = IF(ROW_COUNT() > 0, LAST_INSERT_ID(), NULL);

INSERT INTO ps_profile_lang (id_lang, id_profile, name)
SELECT l.id_lang, @new_profile, 'Prehľad' FROM ps_lang l
WHERE @new_profile IS NOT NULL;

SET @p = (SELECT MIN(id_profile) FROM ps_profile_lang WHERE name = 'Prehľad' COLLATE utf8mb4_bin);

-- View only (no create/update/delete): the menu parents plus the data pages. Left out on purpose: settings
-- pages (invoice/delivery slip options, predefined order messages) and customer service threads, whose
-- legacy controller lets READ reply, forward and close threads.
INSERT INTO ps_access (id_profile, id_authorization_role)
SELECT @p, r.id_authorization_role FROM ps_authorization_role r
WHERE @p IS NOT NULL
  AND r.slug IN (
    'ROLE_MOD_TAB_ADMINDASHBOARD_READ',
    'ROLE_MOD_TAB_SELL_READ',
    'ROLE_MOD_TAB_ADMINPARENTORDERS_READ',
    'ROLE_MOD_TAB_ADMINORDERS_READ',
    'ROLE_MOD_TAB_ADMINSLIP_READ',
    'ROLE_MOD_TAB_ADMINCARTS_READ',
    'ROLE_MOD_TAB_ADMINCATALOG_READ',
    'ROLE_MOD_TAB_ADMINTRACKING_READ',
    'ROLE_MOD_TAB_ADMINPARENTCUSTOMER_READ',
    'ROLE_MOD_TAB_ADMINCUSTOMERS_READ',
    'ROLE_MOD_TAB_ADMINADDRESSES_READ',
    'ROLE_MOD_TAB_ADMINPARENTCUSTOMERTHREADS_READ',
    'ROLE_MOD_TAB_ADMINRETURN_READ',
    'ROLE_MOD_TAB_ADMINSTATS_READ'
  )
  AND NOT EXISTS (SELECT 1 FROM ps_access a WHERE a.id_profile = @p AND a.id_authorization_role = r.id_authorization_role);

-- Module 'view' = their blocks render in the BO (dashboard widgets, stats reports, order-page blocks).
-- Not granted: dashgoals, pagesnotfound and statscheckup, which save settings or delete data from their
-- display hook without a permission check. No module manager right either, since any right there opens
-- every module's configure form (so product comments can't be moderated from this profile).
INSERT INTO ps_module_access (id_profile, id_authorization_role)
SELECT @p, r.id_authorization_role FROM ps_authorization_role r
WHERE @p IS NOT NULL
  AND r.slug LIKE 'ROLE\_MOD\_MODULE\_%\_READ'
  AND r.slug NOT IN ('ROLE_MOD_MODULE_DASHGOALS_READ', 'ROLE_MOD_MODULE_PAGESNOTFOUND_READ', 'ROLE_MOD_MODULE_STATSCHECKUP_READ')
  AND NOT EXISTS (SELECT 1 FROM ps_module_access a WHERE a.id_profile = @p AND a.id_authorization_role = r.id_authorization_role);

-- Employee 2, only while still on the old 'Admin' profile.
UPDATE ps_employee SET id_profile = @p
WHERE id_employee = 2 AND id_profile = 5 AND @p IS NOT NULL;
