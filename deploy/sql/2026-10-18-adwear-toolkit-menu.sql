-- "Nástroje" (AdminAdwearToolkit): a level-1 back-office menu item at the end
-- of the "Rozšírenia" (IMPROVE) section, holding Adwear's own module pages.
-- Category Migrator and Malfini API move there out of "Moduly"
-- (AdminParentModulesSf). Rows are looked up by class_name, since ids differ
-- between shops, and every statement can be re-run without changing anything.

-- The parent tab. It needs no controller: its link is its first child's.
INSERT INTO ps_tab (id_parent, position, module, class_name, route_name, active, enabled, icon, wording, wording_domain)
SELECT improve.id_tab,
       (SELECT IFNULL(MAX(sibling.position), -1) + 1 FROM ps_tab sibling WHERE sibling.id_parent = improve.id_tab),
       NULL, 'AdminAdwearToolkit', '', 1, 1, 'build', 'Nástroje', 'Admin.Navigation.Menu'
FROM ps_tab improve
WHERE improve.class_name = 'IMPROVE'
  AND NOT EXISTS (SELECT 1 FROM ps_tab existing WHERE existing.class_name = 'AdminAdwearToolkit');

INSERT INTO ps_tab_lang (id_tab, id_lang, name)
SELECT tab.id_tab, lang.id_lang, 'Nástroje'
FROM ps_tab tab
CROSS JOIN ps_lang lang
WHERE tab.class_name = 'AdminAdwearToolkit'
  AND NOT EXISTS (SELECT 1 FROM ps_tab_lang existing WHERE existing.id_tab = tab.id_tab AND existing.id_lang = lang.id_lang);

-- Roles and access, as Tab::initAccess creates them, for the profiles that
-- can open Category Migrator.
INSERT INTO ps_authorization_role (slug)
SELECT CONCAT('ROLE_MOD_TAB_ADMINADWEARTOOLKIT_', action.name)
FROM (SELECT 'CREATE' AS name UNION ALL SELECT 'READ' UNION ALL SELECT 'UPDATE' UNION ALL SELECT 'DELETE') action
WHERE NOT EXISTS (SELECT 1 FROM ps_authorization_role existing WHERE existing.slug = CONCAT('ROLE_MOD_TAB_ADMINADWEARTOOLKIT_', action.name));

INSERT INTO ps_access (id_profile, id_authorization_role)
SELECT DISTINCT access.id_profile, role.id_authorization_role
FROM ps_authorization_role role
JOIN ps_authorization_role sibling_role
  ON sibling_role.slug = REPLACE(role.slug, 'ROLE_MOD_TAB_ADMINADWEARTOOLKIT_', 'ROLE_MOD_TAB_ADMINCATEGORYMIGRATOR_')
JOIN ps_access access ON access.id_authorization_role = sibling_role.id_authorization_role
WHERE role.slug LIKE 'ROLE\_MOD\_TAB\_ADMINADWEARTOOLKIT\_%'
  AND NOT EXISTS (SELECT 1 FROM ps_access existing WHERE existing.id_profile = access.id_profile AND existing.id_authorization_role = role.id_authorization_role);

-- Category Migrator and Malfini API move under it.
UPDATE ps_tab tab
JOIN ps_tab toolkit ON toolkit.class_name = 'AdminAdwearToolkit'
SET tab.id_parent = toolkit.id_tab,
    tab.position = IF(tab.class_name = 'AdminCategoryMigrator', 1, 2)
WHERE tab.class_name IN ('AdminCategoryMigrator', 'AdminMalfiniApi');

-- Close the gaps they leave under "Moduly".
UPDATE ps_tab tab
JOIN (
    SELECT child.id_tab, ROW_NUMBER() OVER (ORDER BY child.position, child.id_tab) - 1 AS new_position
    FROM ps_tab child
    JOIN ps_tab modules ON modules.id_tab = child.id_parent
    WHERE modules.class_name = 'AdminParentModulesSf'
) renumbered ON renumbered.id_tab = tab.id_tab
SET tab.position = renumbered.new_position;
