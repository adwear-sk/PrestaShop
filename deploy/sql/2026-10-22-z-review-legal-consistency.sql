-- Review corrections, append-only follow-up to the legal pages of 2026-10-22.
-- Stop optional cookie-linked visit tracking without touching core or deleting
-- existing evidence. statsdata records connections even with its three switches
-- off, so disable the installed module itself. No other module is affected.
UPDATE ps_module SET active = 0 WHERE name = 'statsdata' AND active <> 0;

-- Exact old fragments + Slovak slug scope each correction and make it repeatable.
UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = REPLACE(cl.content, 'Ak ste platili na dobierku, vrátime ich bankovým prevodom na účet, ktorý nám uvediete vo formulári na odstúpenie alebo e-mailom.', 'Ak ste platili na dobierku alebo v hotovosti, môžeme sa s vami dohodnúť na vrátení bankovým prevodom na účet, ktorý nám uvediete. Uvedenie účtu nie je podmienkou odstúpenia ani jediným možným spôsobom vrátenia platby.')
WHERE cl.link_rewrite = 'reklamacie-a-vratenie-tovaru' AND LOCATE('Ak ste platili na dobierku, vrátime ich bankovým prevodom na účet, ktorý nám uvediete vo formulári na odstúpenie alebo e-mailom.', cl.content) > 0;

UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = REPLACE(cl.content, 'Pri Objednávke zaplatenej na dobierku sa platba vracia bankovým prevodom na účet, ktorý Spotrebiteľ uvedie (vo formulári na odstúpenie alebo e-mailom), alebo inak podľa dohody.', 'Pri Objednávke zaplatenej na dobierku alebo v hotovosti možno platbu po výslovnej dohode so Spotrebiteľom vrátiť bankovým prevodom na ním uvedený účet. Uvedenie účtu nie je podmienkou odstúpenia ani jediným možným spôsobom vrátenia platby.')
WHERE cl.link_rewrite = 'vseobecne-obchodne-podmienky' AND LOCATE('Pri Objednávke zaplatenej na dobierku sa platba vracia bankovým prevodom na účet, ktorý Spotrebiteľ uvedie (vo formulári na odstúpenie alebo e-mailom), alebo inak podľa dohody.', cl.content) > 0;

UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = REPLACE(cl.content, 'Na nepotlačený tovar zo skladu sa táto výnimka nevzťahuje a práva z vád vám zostávajú.', 'Na bežný tovar sa táto výnimka nevzťahuje, ani keď ho objednáme od dodávateľa až po vašej objednávke. Práva zo zodpovednosti za vady zostávajú zachované aj pri personalizovanom tovare.')
WHERE cl.link_rewrite = 'potlac-a-branding' AND LOCATE('Na nepotlačený tovar zo skladu sa táto výnimka nevzťahuje a práva z vád vám zostávajú.', cl.content) > 0;

UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = REPLACE(cl.content, 'Ponuky partnerov ani iných spoločností neposielame a bez súhlasu vám reklamné e-maily neposielame.', 'Bez súhlasu vám reklamné e-maily neposielame.')
WHERE cl.link_rewrite = 'zasady-ochrany-osobnych-udajov' AND LOCATE('Ponuky partnerov ani iných spoločností neposielame a bez súhlasu vám reklamné e-maily neposielame.', cl.content) > 0;

UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = REPLACE(cl.content, '<p class="isSelectedEnd">Pri návšteve e-shopu sa v jeho databáze ukladajú údaje o návšteve: IP adresa, čas návštevy, stránka, z ktorej ste prišli, prvá navštívená stránka, typ prehliadača, operačný systém a jazyk prehliadača. Ak ste prihlásení, návšteva sa priradí k vášmu účtu. Tieto údaje používame len na prehľad o návštevnosti priamo v e-shope a na ochranu pred zneužitím; nezdieľame ich s analytickými ani reklamnými službami. Server a aplikácia zaznamenávajú aj technické údaje o chybách. Odoslané e-maily e-shop eviduje v zázname o odoslaní (príjemca, predmet, dátum).</p>', '<p class="isSelectedEnd">Server a aplikácia zaznamenávajú technické údaje potrebné na bezpečnú a funkčnú prevádzku, napríklad IP adresu, čas požiadavky a údaje o chybách. Odoslané e-maily e-shop eviduje v zázname o odoslaní (príjemca, predmet, dátum). Návštevnosť nesledujeme analytickými nástrojmi ani modulom návštevných štatistík. Údaje o návštevách zaznamenané pred jeho vypnutím používame už len v nevyhnutnom rozsahu na riešenie bezpečnostných incidentov a ochranu právnych nárokov.</p>')
WHERE cl.link_rewrite = 'zasady-ochrany-osobnych-udajov' AND LOCATE('<p class="isSelectedEnd">Pri návšteve e-shopu sa v jeho databáze ukladajú údaje o návšteve: IP adresa, čas návštevy, stránka, z ktorej ste prišli, prvá navštívená stránka, typ prehliadača, operačný systém a jazyk prehliadača. Ak ste prihlásení, návšteva sa priradí k vášmu účtu. Tieto údaje používame len na prehľad o návštevnosti priamo v e-shope a na ochranu pred zneužitím; nezdieľame ich s analytickými ani reklamnými službami. Server a aplikácia zaznamenávajú aj technické údaje o chybách. Odoslané e-maily e-shop eviduje v zázname o odoslaní (príjemca, predmet, dátum).</p>', cl.content) > 0;

UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = REPLACE(cl.content, 'náš oprávnený záujem na bezpečnej a funkčnej prevádzke e-shopu a na základnom prehľade o jeho návštevnosti', 'náš oprávnený záujem na bezpečnej a funkčnej prevádzke e-shopu a ochrane právnych nárokov')
WHERE cl.link_rewrite = 'zasady-ochrany-osobnych-udajov' AND LOCATE('náš oprávnený záujem na bezpečnej a funkčnej prevádzke e-shopu a na základnom prehľade o jeho návštevnosti', cl.content) > 0;

UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = REPLACE(cl.content, '<p class="isSelectedEnd">Identifikátor návštevníka z cookie PrestaShop-… e-shop používa aj na to, aby vo svojej databáze spočítal návštevy (bez služieb tretích strán). Viac o týchto údajoch nájdete v bode 13 <a href="/content/6-zasady-ochrany-osobnych-udajov">Zásad ochrany osobných údajov</a>.</p>', '<p class="isSelectedEnd">Modul návštevných štatistík je vypnutý. Technický identifikátor v cookie používame na fungovanie e-shopu, nie na sledovanie návštevnosti. O technických záznamoch servera sa dočítate v bode 13 <a href="/content/6-zasady-ochrany-osobnych-udajov">Zásad ochrany osobných údajov</a>.</p>')
WHERE cl.link_rewrite = 'zasady-pouzivania-cookies' AND LOCATE('<p class="isSelectedEnd">Identifikátor návštevníka z cookie PrestaShop-… e-shop používa aj na to, aby vo svojej databáze spočítal návštevy (bez služieb tretích strán). Viac o týchto údajoch nájdete v bode 13 <a href="/content/6-zasady-ochrany-osobnych-udajov">Zásad ochrany osobných údajov</a>.</p>', cl.content) > 0;

UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = CONCAT(cl.content, '\n', '<h2>Zákonné práva pri vadnom tovare</h2><p>Na vaše zákonné práva upozorňuje aj <a href="/themes/adwear/assets/img/legal/eu-legal-guarantee-sk.svg">harmonizované oznámenie EÚ o zákonnej záruke súladu</a>. Nejde o dodatočnú obchodnú záruku.</p>')
WHERE cl.link_rewrite = 'vseobecne-obchodne-podmienky'
  AND LOCATE('eu-legal-guarantee-sk.svg', cl.content) = 0;

UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = CONCAT(cl.content, '\n', '<h2>Zákonné práva pri vadnom tovare</h2><p>Na vaše zákonné práva upozorňuje aj <a href="/themes/adwear/assets/img/legal/eu-legal-guarantee-sk.svg">harmonizované oznámenie EÚ o zákonnej záruke súladu</a>. Nejde o dodatočnú obchodnú záruku.</p>')
WHERE cl.link_rewrite = 'reklamacie-a-vratenie-tovaru'
  AND LOCATE('eu-legal-guarantee-sk.svg', cl.content) = 0;
