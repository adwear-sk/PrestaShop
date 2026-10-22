-- Legal pages, part 2, and privacy settings (2026-10-22).
-- CMS 6 (privacy) and 7 (cookies) rewritten to match what the shop does:
-- processors Hetzner, Websupport, the accountant; Slovenská pošta and the bank as
-- recipients; core visitor statistics; only two first-party cookies, no
-- analytics or ads. CMS 4 (O nás) and 9 (Potlač a branding) aligned with the
-- VOP: obchod@, full identity, non-VAT payer, the non-binding quote.
-- CMS updates are keyed by id_cms and guarded by the Slovak slug, so a
-- different page under that id is left alone.
--
-- Consents: the partner-offers box goes (PS_CUSTOMER_OPTIN=0); the required
-- psgdpr box on account forms ("Súhlasím s obchodnými podmienkami a zásadami")
-- is switched off, leaving ps_dataprivacy's box as an acknowledgement of the
-- privacy notice; the psgdpr texts on the contact form, reviews and stock
-- alerts become notices; only the newsletter keeps a real, optional consent.
-- Every statement writes a fixed value, so re-running changes nothing.

-- Zásady ochrany osobných údajov
UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = '<h1>Zásady ochrany osobných údajov</h1>
<p class="isSelectedEnd">účinné od <strong>22. 10. 2026</strong></p>
<p class="isSelectedEnd">V týchto zásadách vysvetľujeme, aké osobné údaje spracúvame pri prevádzke internetového obchodu adwear.sk, na aké účely a na akom právnom základe, komu ich poskytujeme, ako dlho ich uchovávame a aké práva máte. Spracúvanie sa riadi nariadením (EÚ) 2016/679 (GDPR) a zákonom č. 18/2018 Z. z. o ochrane osobných údajov.</p>
<h2>1. Prevádzkovateľ</h2>
<p class="isSelectedEnd">Prevádzkovateľom vašich osobných údajov je:</p>
<p class="isSelectedEnd"><strong>adwear s. r. o.</strong><br />Sídlo: Staničná 659/7, 094 14 Sečovská Polianka, Slovenská republika<br />IČO: 56383410<br />DIČ: 2122288828<br />Zapísaná v Obchodnom registri Okresného súdu Prešov, oddiel Sro, vložka č. 48213/P<br />E-mail: <a href="mailto:obchod@adwear.sk"><strong>obchod@adwear.sk</strong></a><br />Telefón: <a href="tel:+421947948180"><strong>+421 947 948 180</strong></a></p>
<p class="isSelectedEnd">Zodpovednú osobu (DPO) sme neurčili. So všetkými otázkami o ochrane osobných údajov sa obráťte priamo na nás na <a href="mailto:obchod@adwear.sk"><strong>obchod@adwear.sk</strong></a> alebo na adresu sídla.</p>
<h2>2. Objednávky a uzavretie zmluvy</h2>
<p class="isSelectedEnd">Keď u nás nakupujete (aj bez registrácie), spracúvame:</p>
<ul>
<li>meno a priezvisko, e-mailovú adresu a telefónne číslo,</li>
<li>fakturačnú a dodaciu adresu; pri nákupe na firmu aj obchodné meno, IČO, DIČ alebo IČ DPH, ak ich uvediete,</li>
<li>obsah objednávky, cenu, zvolený spôsob dopravy a platby a stav objednávky,</li>
<li>správu, ktorú k objednávke pripíšete, a ďalšiu komunikáciu k objednávke.</li>
</ul>
<p class="isSelectedEnd">Údaje používame na prijatie a vybavenie objednávky, na komunikáciu s vami, na prijatie platby, odoslanie alebo odovzdanie tovaru a na vybavenie odstúpenia od zmluvy či reklamácie.</p>
<p class="isSelectedEnd"><strong>Právny základ:</strong> plnenie zmluvy a opatrenia pred jej uzavretím (čl. 6 ods. 1 písm. b) GDPR). Údaje označené ako povinné sú potrebné na uzavretie zmluvy; bez nich objednávku nemôžeme prijať.</p>
<p class="isSelectedEnd"><strong>Doba uchovávania:</strong> údaje o objednávke uchovávame počas plnenia zmluvy, počas zodpovednosti za vady a do uplynutia premlčacích lehôt na uplatnenie nárokov zo zmluvy. Údaje, ktoré sú súčasťou účtovných dokladov (napr. faktúr), uchovávame 10 rokov od konca roka, ktorého sa týkajú (§ 35 zákona č. 431/2002 Z. z. o účtovníctve).</p>
<h2>3. Žiadosť o cenovú ponuku</h2>
<p class="isSelectedEnd">Ak pošlete nezáväznú žiadosť o cenovú ponuku (v pokladni alebo e-mailom), spracúvame rovnaké údaje ako pri objednávke a obsah žiadosti, aby sme vám mohli pripraviť ponuku a prípadne uzavrieť zmluvu.</p>
<p class="isSelectedEnd"><strong>Právny základ:</strong> opatrenia pred uzavretím zmluvy na vašu žiadosť (čl. 6 ods. 1 písm. b) GDPR). Žiadosť o ponuku nie je súhlas so zasielaním reklamy.</p>
<p class="isSelectedEnd"><strong>Doba uchovávania:</strong> ak ponuku prijmete, platí doba uvedená v bode 2. Ak z nej zmluva nevznikne, údaje uchovávame len po dobu nevyhnutnú na vybavenie žiadosti a na prípadnú ďalšiu komunikáciu o nej.</p>
<h2>4. Zákaznícky účet</h2>
<p class="isSelectedEnd">Registrácia je dobrovoľná. V účte uchovávame meno, e-mail, heslo (uložené v podobe, z ktorej ho nemožno spätne zistiť), adresy a históriu objednávok, aby ste nemuseli údaje zadávať opakovane a mali prehľad o objednávkach.</p>
<p class="isSelectedEnd"><strong>Právny základ:</strong> plnenie zmluvy o používaní účtu (čl. 6 ods. 1 písm. b) GDPR).</p>
<p class="isSelectedEnd"><strong>Doba uchovávania:</strong> počas existencie účtu. O zrušenie účtu môžete kedykoľvek požiadať na <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a>. Údaje o objednávkach a účtovné doklady potom uchovávame len v rozsahu a po dobu podľa bodu 2.</p>
<h2>5. Platby</h2>
<p class="isSelectedEnd">Pri platbe bankovým prevodom vidíme v našom bankovom účte meno platiteľa, číslo jeho účtu, sumu, dátum a variabilný symbol alebo správu pre prijímateľa. QR kód PAY by square vytvára priamo náš e-shop; na jeho vytvorenie neposielame vaše údaje nikomu ďalšiemu. Pri platbe na dobierku vyberie sumu od vás Slovenská pošta a pošle nám ju.</p>
<p class="isSelectedEnd">Ak vám vraciame platbu (napr. po odstúpení od zmluvy pri platbe na dobierku), spracúvame číslo účtu, ktoré nám na tento účel oznámite.</p>
<p class="isSelectedEnd"><strong>Právny základ:</strong> plnenie zmluvy (čl. 6 ods. 1 písm. b) GDPR) a plnenie zákonných účtovných a daňových povinností (čl. 6 ods. 1 písm. c) GDPR). <strong>Doba uchovávania:</strong> podľa bodu 2.</p>
<h2>6. Doprava</h2>
<p class="isSelectedEnd">Pri doručení kuriérom odovzdávame <strong>Slovenskej pošte, a. s.</strong> meno, dodaciu adresu, telefónne číslo a e-mail, prípadne sumu dobierky, aby vám mohla zásielku doručiť a informovať vás o nej. Pri osobnom odbere v našom sídle údaje žiadnemu dopravcovi neposkytujeme.</p>
<p class="isSelectedEnd"><strong>Právny základ:</strong> plnenie zmluvy (čl. 6 ods. 1 písm. b) GDPR).</p>
<h2>7. Odstúpenie od zmluvy a reklamácie</h2>
<p class="isSelectedEnd">Ak odstúpite od zmluvy cez náš online formulár, uložíme do databázy e-shopu znenie oznámenia: meno, e-mail, číslo objednávky alebo opis nákupu, rozsah odstúpenia, dátum a čas prijatia a údaje, ktoré uvediete dobrovoľne (adresu, číslo účtu na vrátenie platby). Prijatie vám potvrdíme e-mailom a kópia oznámenia príde aj nám. Rovnako spracúvame odstúpenie doručené e-mailom alebo poštou.</p>
<p class="isSelectedEnd">Pri reklamácii spracúvame vaše kontaktné údaje, údaje o nákupe, opis vady, prípadné fotografie a záznam o vybavení reklamácie.</p>
<p class="isSelectedEnd"><strong>Právny základ:</strong> plnenie zákonných povinností podľa zákona č. 108/2024 Z. z. o ochrane spotrebiteľa a Občianskeho zákonníka (čl. 6 ods. 1 písm. c) GDPR) a plnenie zmluvy (čl. 6 ods. 1 písm. b) GDPR).</p>
<p class="isSelectedEnd"><strong>Doba uchovávania:</strong> po dobu, počas ktorej nám uchovávanie ukladajú predpisy na ochranu spotrebiteľa, a do uplynutia premlčacích lehôt na uplatnenie nárokov, ktoré s odstúpením alebo reklamáciou súvisia.</p>
<h2>8. Personalizácia a grafické podklady</h2>
<p class="isSelectedEnd">Pri potlači alebo výšivke nám posielate logo, text alebo inú grafiku. Ak podklad obsahuje osobné údaje (napr. meno alebo fotografiu), používame ho na prípravu návrhu, výrobu, vybavenie reklamácie a na preukázanie podoby objednanej personalizácie.</p>
<p class="isSelectedEnd"><strong>Právny základ:</strong> plnenie zmluvy (čl. 6 ods. 1 písm. b) GDPR); po vybavení objednávky náš oprávnený záujem na opakovanej výrobe a na ochrane právnych nárokov (čl. 6 ods. 1 písm. f) GDPR).</p>
<p class="isSelectedEnd"><strong>Doba uchovávania:</strong> najviac 4 roky od vybavenia poslednej objednávky, ku ktorej sa podklad vzťahuje, ak ho dlhšie nepotrebujeme na prebiehajúcu reklamáciu alebo spor. O skoršie vymazanie podkladov môžete požiadať na <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a>.</p>
<h2>9. Kontaktný formulár, e-mail a telefón</h2>
<p class="isSelectedEnd">Ak nám napíšete cez kontaktný formulár, uložíme do e-shopu váš e-mail, text správy, priložený súbor a IP adresu, z ktorej ste správu odoslali; správa nám príde aj e-mailom. Pri e-maile, telefonáte alebo správe cez WhatsApp spracúvame údaje, ktoré nám sami oznámite. Pri komunikácii cez WhatsApp spracúva údaje aj jeho prevádzkovateľ podľa vlastných podmienok; ak to nechcete, napíšte nám e-mail.</p>
<p class="isSelectedEnd"><strong>Právny základ:</strong> ak sa správa týka objednávky alebo budúceho nákupu, opatrenia pred uzavretím zmluvy alebo plnenie zmluvy (čl. 6 ods. 1 písm. b) GDPR); inak náš oprávnený záujem odpovedať na otázky zákazníkov a záujemcov (čl. 6 ods. 1 písm. f) GDPR). IP adresu ukladáme z oprávneného záujmu na ochrane formulára pred zneužitím.</p>
<p class="isSelectedEnd"><strong>Doba uchovávania:</strong> komunikáciu, ktorá nesúvisí s objednávkou, uchovávame spravidla najviac 12 mesiacov od jej vybavenia. Komunikáciu k objednávke uchovávame tak ako údaje o objednávke (bod 2).</p>
<h2>10. Hodnotenia produktov</h2>
<p class="isSelectedEnd">Hodnotenie môžu písať len prihlásení zákazníci. Pred zverejnením ho schvaľujeme. Pri hodnotení sa zverejní vaše meno a priezvisko zo zákazníckeho účtu, dátum, počet hviezdičiek, nadpis a text. Neoverujeme, či autor hodnotený produkt kúpil.</p>
<p class="isSelectedEnd"><strong>Právny základ:</strong> náš oprávnený záujem zverejňovať skúsenosti zákazníkov s produktmi (čl. 6 ods. 1 písm. f) GDPR). Hodnotenie píšete dobrovoľne a o jeho odstránenie môžete kedykoľvek požiadať.</p>
<p class="isSelectedEnd"><strong>Doba uchovávania:</strong> kým je produkt v ponuke, alebo kým nepožiadate o odstránenie hodnotenia.</p>
<h2>11. Upozornenie na dostupnosť produktu</h2>
<p class="isSelectedEnd">Ak pri vypredanom produkte zadáte e-mail, pošleme vám jedno upozornenie, keď bude produkt opäť dostupný. Po odoslaní upozornenia sa záznam automaticky vymaže.</p>
<p class="isSelectedEnd"><strong>Právny základ:</strong> vykonanie služby na vašu žiadosť pred prípadným uzavretím zmluvy (čl. 6 ods. 1 písm. b) GDPR). E-mail nepoužívame na reklamu.</p>
<h2>12. Novinky e-mailom (newsletter)</h2>
<p class="isSelectedEnd">Novinky a ponuky posielame iba vtedy, ak sa na ich odber sami prihlásite (v pätičke stránky, pri registrácii alebo v zákazníckom účte). Políčko na prihlásenie nie je nikdy vopred označené a odber nie je podmienkou nákupu. Spracúvame e-mailovú adresu, dátum a čas prihlásenia a IP adresu, z ktorej ste sa prihlásili; pri registrovaných zákazníkoch aj meno. Ponuky partnerov ani iných spoločností neposielame a bez súhlasu vám reklamné e-maily neposielame.</p>
<p class="isSelectedEnd"><strong>Právny základ:</strong> váš súhlas (čl. 6 ods. 1 písm. a) GDPR a § 116 zákona č. 452/2021 Z. z. o elektronických komunikáciách).</p>
<p class="isSelectedEnd"><strong>Odvolanie súhlasu:</strong> kedykoľvek a bezplatne, v zákazníckom účte v časti Osobné údaje alebo e-mailom na <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a>. Odvolanie súhlasu nemá vplyv na zákonnosť spracúvania pred odvolaním.</p>
<p class="isSelectedEnd"><strong>Doba uchovávania:</strong> e-mail na zasielanie noviniek používame do odvolania súhlasu. Záznam o udelení a odvolaní súhlasu uchovávame po dobu, ktorú vyžaduje zákon o elektronických komunikáciách, aby sme vedeli preukázať, že sme súhlas mali a rešpektovali jeho odvolanie.</p>
<h2>13. Návšteva webu, štatistiky a bezpečnosť</h2>
<p class="isSelectedEnd">Pri návšteve e-shopu sa v jeho databáze ukladajú údaje o návšteve: IP adresa, čas návštevy, stránka, z ktorej ste prišli, prvá navštívená stránka, typ prehliadača, operačný systém a jazyk prehliadača. Ak ste prihlásení, návšteva sa priradí k vášmu účtu. Tieto údaje používame len na prehľad o návštevnosti priamo v e-shope a na ochranu pred zneužitím; nezdieľame ich s analytickými ani reklamnými službami. Server a aplikácia zaznamenávajú aj technické údaje o chybách. Odoslané e-maily e-shop eviduje v zázname o odoslaní (príjemca, predmet, dátum).</p>
<p class="isSelectedEnd"><strong>Právny základ:</strong> náš oprávnený záujem na bezpečnej a funkčnej prevádzke e-shopu a na základnom prehľade o jeho návštevnosti (čl. 6 ods. 1 písm. f) GDPR). Proti tomuto spracúvaniu môžete namietať (bod 17).</p>
<p class="isSelectedEnd"><strong>Doba uchovávania:</strong> len po dobu nevyhnutnú na tieto účely; pri bezpečnostnom incidente do jeho vyriešenia. Zálohy databázy sa vytvárajú každú noc a uchovávajú sa 14 dní; potom sa automaticky vymažú.</p>
<p class="isSelectedEnd">Informácie o súboroch cookies nájdete v <a href="/content/7-zasady-pouzivania-cookies">Zásadách používania cookies</a>. Nepoužívame Google Analytics, reklamné ani sledovacie nástroje tretích strán.</p>
<h2>14. Komu údaje poskytujeme</h2>
<p class="isSelectedEnd">Údaje poskytujeme len v rozsahu potrebnom na daný účel týmto príjemcom:</p>
<ul>
<li><strong>Hetzner Online GmbH</strong> (Nemecko) – prevádzkuje server, na ktorom beží e-shop a jeho databáza vrátane záloh (sprostredkovateľ, dátové centrum v EÚ),</li>
<li><strong>Websupport, s. r. o.</strong> (Slovensko) – poskytuje e-mailové schránky a odosielanie e-mailov pre doménu adwear.sk (sprostredkovateľ),</li>
<li><strong>externý poskytovateľ účtovných služieb</strong> – vedie naše účtovníctvo; dostáva údaje z faktúr a účtovných dokladov (sprostredkovateľ),</li>
<li><strong>Slovenská pošta, a. s.</strong> – doručenie zásielok a výber dobierky (bod 6),</li>
<li><strong>naša banka</strong> – prijatie a vrátenie platieb (bod 5),</li>
<li><strong>orgány verejnej moci</strong> (napr. daňový úrad, Slovenská obchodná inšpekcia, súdy), ak nám to ukladá zákon.</li>
</ul>
<p class="isSelectedEnd">Údaje nepredávame a neposkytujeme ich na marketing iným spoločnostiam. Sprostredkovatelia spracúvajú údaje v našom mene a len na uvedené účely.</p>
<h2>15. Prenos mimo EÚ</h2>
<p class="isSelectedEnd">Údaje spracúvame v Európskej únii a mimo Európsky hospodársky priestor ich neprenášame. Výnimkou môže byť komunikácia cez WhatsApp, ak si ju sami zvolíte; tam o spracúvaní rozhoduje aj jeho prevádzkovateľ.</p>
<h2>16. Automatizované rozhodovanie</h2>
<p class="isSelectedEnd">Nerozhodujeme o vás automatizovane a nevytvárame váš profil na marketingové účely. Cenové ponuky pripravujeme ručne.</p>
<h2>17. Vaše práva</h2>
<p class="isSelectedEnd">Za podmienok GDPR máte právo:</p>
<ul>
<li>na prístup k osobným údajom a na ich kópiu (čl. 15),</li>
<li>na opravu nesprávnych alebo doplnenie neúplných údajov (čl. 16),</li>
<li>na vymazanie, ak už údaje nepotrebujeme alebo ich spracúvame neoprávnene (čl. 17),</li>
<li>na obmedzenie spracúvania (čl. 18),</li>
<li>na prenosnosť údajov, ktoré ste nám poskytli na základe zmluvy alebo súhlasu (čl. 20),</li>
<li><strong>namietať proti spracúvaniu</strong> založenému na našom oprávnenom záujme (čl. 21),</li>
<li>kedykoľvek odvolať súhlas, ak spracúvanie na ňom stojí (čl. 7 ods. 3).</li>
</ul>
<p class="isSelectedEnd">Právo na vymazanie nie je absolútne: údaje, ktoré musíme uchovávať podľa zákona (napr. účtovné doklady) alebo ktoré potrebujeme na ochranu právnych nárokov, vymažeme až po uplynutí príslušnej doby.</p>
<p class="isSelectedEnd"><strong>Ako práva uplatniť:</strong> e-mailom na <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a> alebo listom na adresu adwear s. r. o., Staničná 659/7, 094 14 Sečovská Polianka. Ak máte zákaznícky účet, kópiu svojich údajov si môžete stiahnuť aj sami v účte v časti o osobných údajoch (GDPR) a údaje v účte a adresy si môžete sami opraviť. Odpovieme bez zbytočného odkladu, najneskôr do 1 mesiaca; v zložitých prípadoch môžeme lehotu predĺžiť o ďalšie 2 mesiace, o čom vás budeme informovať. Ak budeme mať odôvodnené pochybnosti o vašej totožnosti, môžeme vás požiadať o jej overenie.</p>
<h2>18. Sťažnosť na dozorný orgán</h2>
<p class="isSelectedEnd">Ak sa domnievate, že vaše osobné údaje spracúvame v rozpore s predpismi, môžete podať návrh na začatie konania o ochrane osobných údajov dozornému orgánu:</p>
<p class="isSelectedEnd"><strong>Úrad na ochranu osobných údajov Slovenskej republiky</strong><br />Galvaniho 7/B, 821 04 Bratislava<br />Telefón: +421 2 32 31 32 14<br />E-mail: <a href="mailto:statny.dozor@pdp.gov.sk">statny.dozor@pdp.gov.sk</a><br />Web: <a href="https://dataprotection.gov.sk/sk/" target="_blank" rel="noopener">dataprotection.gov.sk</a></p>
<p class="isSelectedEnd">Postup a formulár nájdete na stránke <a href="https://dataprotection.gov.sk/sk/ine/vyhladavanie-sluzby-formulara-elektronicku-komunikaciu/podavanie-navrhu-zacatie-konania/" target="_blank" rel="noopener">Podávanie návrhu na začatie konania</a>. Môžete sa obrátiť aj na dozorný orgán v štáte EÚ, v ktorom žijete alebo pracujete. Ak nám napíšete najskôr, radi vec preveríme.</p>
<h2>19. Zmeny týchto zásad</h2>
<p class="isSelectedEnd">Zásady aktualizujeme, keď zmeníme spôsob spracúvania, poskytovateľov služieb alebo keď sa zmenia predpisy. Ak by sme začali používať analytické alebo reklamné nástroje, najskôr upravíme tieto zásady a nástroje vyžadujúce súhlas spustíme až po jeho udelení.</p>
<p>Tieto Zásady ochrany osobných údajov sú účinné od <strong>22. 10. 2026</strong> a nahrádzajú znenie účinné od 01. 09. 2026.</p>'
WHERE cl.id_cms = 6 AND cl.link_rewrite = 'zasady-ochrany-osobnych-udajov';

-- Zásady používania cookies
UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = '<h1>Zásady používania cookies</h1>
<p class="isSelectedEnd">účinné od <strong>22. 10. 2026</strong></p>
<p class="isSelectedEnd">Tieto zásady vysvetľujú, aké súbory cookies a podobné technológie používa internetový obchod adwear.sk. Prevádzkovateľom je <strong>adwear s. r. o.</strong>, Staničná 659/7, 094 14 Sečovská Polianka, IČO 56383410, e-mail <a href="mailto:obchod@adwear.sk"><strong>obchod@adwear.sk</strong></a>, telefón <a href="tel:+421947948180"><strong>+421 947 948 180</strong></a>.</p>
<h2>1. Čo sú cookies</h2>
<p class="isSelectedEnd">Cookies sú malé textové súbory, ktoré webová stránka uloží do vášho prehliadača a pri ďalšej požiadavke ich od prehliadača opäť dostane. Vďaka nim si e-shop napríklad pamätá obsah košíka alebo to, že ste prihlásení.</p>
<h2>2. Používame iba nevyhnutné cookies</h2>
<p class="isSelectedEnd">E-shop ukladá do vášho prehliadača iba tieto dve cookies. Obe nastavuje priamo naša stránka (adwear.sk), nie tretia strana:</p>
<ul>
<li><strong>PrestaShop-…</strong> (za pomlčkou nasleduje kód) – šifrovaná cookie e-shopu. Pamätá si obsah košíka, prihlásenie do účtu, zvolený jazyk a menu, priebeh objednávky a technický identifikátor návštevníka. Platnosť: 20 dní od poslednej návštevy.</li>
<li><strong>PHPSESSID</strong> – identifikátor relácie, ktorý server potrebuje na prenos údajov medzi jednotlivými krokmi (napr. pri odoslaní formulára). Neobsahuje žiadne údaje o vás, len náhodný kód. Prehliadač ho uchováva dlhodobo; môžete ho kedykoľvek vymazať.</li>
</ul>
<p class="isSelectedEnd">Tieto cookies sú nevyhnutné na to, aby fungoval košík, prihlásenie a objednávka, teda služby, ktoré si sami vyžiadate. Podľa § 109 ods. 8 zákona č. 452/2021 Z. z. o elektronických komunikáciách na ne nepotrebujeme váš súhlas, a preto stránka nezobrazuje lištu so súhlasom s cookies.</p>
<p class="isSelectedEnd">Identifikátor návštevníka z cookie PrestaShop-… e-shop používa aj na to, aby vo svojej databáze spočítal návštevy (bez služieb tretích strán). Viac o týchto údajoch nájdete v bode 13 <a href="/content/6-zasady-ochrany-osobnych-udajov">Zásad ochrany osobných údajov</a>.</p>
<h2>3. Nepoužívame analytické ani reklamné nástroje</h2>
<p class="isSelectedEnd">Na stránke <strong>nepoužívame</strong> Google Analytics, Google Ads, Meta Pixel ani iné analytické, reklamné či sledovacie nástroje. Stránka nenačítava písma, videá, mapy ani skripty z cudzích serverov a nevkladá obsah sociálnych sietí. Ikony sociálnych sietí v pätičke a tlačidlá na zdieľanie sú obyčajné odkazy: k danej službe sa pripojíte, až keď na ne kliknete, a odvtedy platia jej pravidlá.</p>
<p class="isSelectedEnd">Do lokálneho úložiska prehliadača (localStorage, sessionStorage) e-shop nič neukladá.</p>
<h2>4. Ako cookies spravovať</h2>
<p class="isSelectedEnd">Cookies si môžete pozrieť, vymazať alebo zablokovať v nastaveniach svojho prehliadača. Ak zablokujete nevyhnutné cookies, nebude fungovať košík, prihlásenie ani dokončenie objednávky.</p>
<h2>5. Zmeny</h2>
<p class="isSelectedEnd">Ak by sme v budúcnosti chceli používať cookies, ktoré nie sú nevyhnutné (napríklad na analytiku alebo reklamu), najskôr aktualizujeme tieto zásady a takéto cookies spustíme až po vašom súhlase, ktorý budete môcť odmietnuť alebo neskôr odvolať rovnako jednoducho, ako ste ho udelili.</p>
<p class="isSelectedEnd">Informácie o spracúvaní osobných údajov nájdete v <a href="/content/6-zasady-ochrany-osobnych-udajov">Zásadách ochrany osobných údajov</a>.</p>
<p>Tieto Zásady používania cookies sú účinné od <strong>22. 10. 2026</strong> a nahrádzajú znenie účinné od 01. 09. 2026.</p>'
WHERE cl.id_cms = 7 AND cl.link_rewrite = 'zasady-pouzivania-cookies';

-- O nás
UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = '<h2>Kto sme</h2>
<p>ADWEAR je slovenský e-shop s textilom, pracovným oblečením a doplnkami, ktorý prevádzkuje spoločnosť adwear s. r. o. so sídlom v Sečovskej Polianke. Obliekame firmy, tímy, školy, kluby aj jednotlivcov – a ak chcete, oblečenie vám upravíme potlačou alebo výšivkou.</p>

<h2>Čo u nás nájdete</h2>
<ul>
<li><strong>Oblečenie</strong> – tričká, tielka, polokošele, košele, mikiny, fleece, softshellové a ďalšie bundy, vesty, tepláky, šortky aj šaty.</li>
<li><strong>Pracovné oblečenie a obuv</strong> – pracovné nohavice, bundy a vesty, reflexné vesty a bezpečnostná obuv s certifikáciou podľa noriem EN ISO.</li>
<li><strong>Doplnky a príslušenstvo</strong> – čiapky, šiltovky, šatky, tašky, batohy, uteráky a osušky.</li>
</ul>
<p>Ponúkame overené značky <strong>MALFINI, MALFINI Premium, RIMECK, PICCOLIO, TRICORP, ALBATROS, BATA INDUSTRIALS</strong> a <strong>PUMA</strong>. Väčšinu modelov nájdete v pánskom, dámskom, detskom aj unisex strihu a v širokej škále farieb a veľkostí. Dostupnosť tovaru aktualizujeme každú hodinu priamo zo skladu dodávateľa.</p>

<h2>Potlač a personalizácia</h2>
<p>Oblečenie vám radi upravíme podľa vašich predstáv – vaším logom, názvom firmy, menom alebo vlastnou grafikou. Pri každom produkte uvádzame, ktoré technológie sú preň vhodné, napríklad sieťotlač, digitálny transfer, sublimácia alebo výšivka. Ak je to potrebné, pred výrobou vám pošleme grafický náhľad na schválenie.</p>

<h2>Pre firmy aj jednotlivcov</h2>
<p>Nakupovať u nás môžete ako súkromná osoba aj ako firma. Pripravujete firemné oblečenie, výbavu pre zamestnancov alebo reklamné textílie na podujatie? Pošlite nám nezáväznú žiadosť o cenovú ponuku – v pokladni zvoľte <strong>Cenová ponuka</strong> alebo nám napíšte na <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a>. Odoslaním žiadosti nevzniká povinnosť kúpiť ani zaplatiť; podmienky prípadnej objednávky vám predložíme v ponuke.</p>

<h2>Kontakt</h2>
<p><strong>adwear s. r. o.</strong><br />
Staničná 659/7, 094 14 Sečovská Polianka<br />
IČO: 56383410, DIČ: 2122288828<br />
Zapísaná v Obchodnom registri Okresného súdu Prešov, oddiel Sro, vložka č. 48213/P<br />
E-mail: <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a><br />
Telefón: <a href="tel:+421947948180">+421 947 948 180</a><br />
Predávajúci nie je platiteľom DPH. Všetky ceny sú konečné.</p>
<p>Informácie o doručení nájdete na stránke <a href="/content/1-doprava-a-platba">Doprava a platba</a>, o vrátení tovaru na stránke <a href="/content/8-reklamacie-a-vratenie-tovaru">Reklamácie a vrátenie tovaru</a> a podmienky nákupu vo <a href="/content/3-vseobecne-obchodne-podmienky">Všeobecných obchodných podmienkach</a>.</p>'
WHERE cl.id_cms = 4 AND cl.link_rewrite = 'o-nas';

-- Potlač a branding
UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = '<div class="adwear-branding">

<div class="row g-4 g-lg-5 align-items-center mb-5">
  <div class="col-lg-6">
    <span class="badge rounded-pill text-bg-primary mb-3">Firemné oblečenie s logom</span>
    <h2 class="display-5 fw-bold mb-3">Vaše logo na oblečení, ktoré ľudia naozaj nosia</h2>
    <p class="lead text-secondary mb-4">Tričká, polokošele, mikiny, pracovné odevy aj šiltovky s potlačou alebo výšivkou vášho loga. Pomôžeme vybrať textil aj techniku a pred výrobou vám pošleme vizualizáciu na schválenie.</p>
    <div class="d-flex flex-wrap gap-2 mb-4">
      <a class="btn btn-primary btn-lg" href="/kontaktujte-nas">Nezáväzný dopyt</a>
      <a class="btn btn-outline-primary btn-lg" href="/124-oblecenie">Vybrať oblečenie</a>
    </div>
    <ul class="list-unstyled ps-0 d-flex flex-wrap gap-3 mb-0 small">
      <li class="d-flex align-items-center gap-1"><i class="material-icons text-primary">check_circle</i> Vizualizácia pred výrobou</li>
      <li class="d-flex align-items-center gap-1"><i class="material-icons text-primary">check_circle</i> Kvalitný textil Malfini</li>
      <li class="d-flex align-items-center gap-1"><i class="material-icons text-primary">check_circle</i> Malé aj veľké série</li>
    </ul>
  </div>
  <div class="col-lg-6">
    <img class="img-fluid w-100 rounded-4 shadow object-fit-cover" src="/img/cms/potlac-a-branding/hero-tim.webp" alt="Tím v tričkách s farebnou potlačou" width="1200" height="900" />
  </div>
</div>

<div class="row g-3 mb-5">
  <div class="col-sm-6 col-lg-3">
    <div class="h-100 p-4 rounded-4 bg-body-tertiary">
      <i class="material-icons text-primary fs-1 mb-2">checkroom</i>
      <h3 class="h5 fw-semibold">Textil aj potlač na jednom mieste</h3>
      <p class="text-secondary small mb-0">Vyberte si z našej ponuky oblečenia a o branding sa postaráme my. Nemusíte riešiť viacerých dodávateľov.</p>
    </div>
  </div>
  <div class="col-sm-6 col-lg-3">
    <div class="h-100 p-4 rounded-4 bg-body-tertiary">
      <i class="material-icons text-primary fs-1 mb-2">palette</i>
      <h3 class="h5 fw-semibold">Vizualizácia na schválenie</h3>
      <p class="text-secondary small mb-0">Ešte pred výrobou uvidíte, ako bude logo na oblečení vyzerať – veľkosť, umiestnenie aj farby.</p>
    </div>
  </div>
  <div class="col-sm-6 col-lg-3">
    <div class="h-100 p-4 rounded-4 bg-body-tertiary">
      <i class="material-icons text-primary fs-1 mb-2">tune</i>
      <h3 class="h5 fw-semibold">Správna technika</h3>
      <p class="text-secondary small mb-0">Odporučíme potlač alebo výšivku podľa materiálu, motívu a počtu kusov, aby výsledok vydržal.</p>
    </div>
  </div>
  <div class="col-sm-6 col-lg-3">
    <div class="h-100 p-4 rounded-4 bg-body-tertiary">
      <i class="material-icons text-primary fs-1 mb-2">support_agent</i>
      <h3 class="h5 fw-semibold">Osobný prístup</h3>
      <p class="text-secondary small mb-0">Každú objednávku riešime individuálne – od výberu veľkostí až po doručenie.</p>
    </div>
  </div>
</div>

<div class="mb-5">
  <div class="text-center mx-auto mb-4" style="max-width:720px;">
    <h2 class="fw-bold">Techniky zušľachtenia</h2>
    <p class="text-secondary mb-0">Každá technika má svoje silné stránky. Najvhodnejšiu vyberieme podľa toho, na čo oblečenie potrebujete.</p>
  </div>
  <div class="row g-4">
    <div class="col-md-4">
      <div class="card h-100 border-0 shadow-sm rounded-4 overflow-hidden">
        <img class="card-img-top object-fit-cover" src="/img/cms/potlac-a-branding/sietotlac.webp" alt="Sieťotlač – nanášanie farby cez sito" width="800" height="600" />
        <div class="card-body p-4">
          <h3 class="h4 fw-semibold">Sieťotlač</h3>
          <p class="text-secondary">Klasika pre väčšie série. Sýte farby, výborná odolnosť pri praní a nízka cena za kus pri vyššom počte.</p>
          <ul class="list-unstyled ps-0 small mb-0">
            <li class="d-flex gap-2 mb-1"><i class="material-icons text-primary fs-6">done</i> Firemné akcie, eventy, kampane</li>
            <li class="d-flex gap-2 mb-1"><i class="material-icons text-primary fs-6">done</i> Motívy s menším počtom farieb</li>
            <li class="d-flex gap-2"><i class="material-icons text-primary fs-6">done</i> Tričká, mikiny, tašky</li>
          </ul>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card h-100 border-0 shadow-sm rounded-4 overflow-hidden">
        <img class="card-img-top object-fit-cover" src="/img/cms/potlac-a-branding/transfer.webp" alt="Transferová potlač na tričko" width="800" height="600" />
        <div class="card-body p-4">
          <h3 class="h4 fw-semibold">Transferová potlač (DTF)</h3>
          <p class="text-secondary">Plnofarebná potlač aj s prechodmi a jemnými detailmi. Ideálna pre menšie série a personalizáciu.</p>
          <ul class="list-unstyled ps-0 small mb-0">
            <li class="d-flex gap-2 mb-1"><i class="material-icons text-primary fs-6">done</i> Fotografie a farebné logá</li>
            <li class="d-flex gap-2 mb-1"><i class="material-icons text-primary fs-6">done</i> Mená a čísla na dresy</li>
            <li class="d-flex gap-2"><i class="material-icons text-primary fs-6">done</i> Bavlna, polyester aj zmesi</li>
          </ul>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card h-100 border-0 shadow-sm rounded-4 overflow-hidden">
        <img class="card-img-top object-fit-cover" src="/img/cms/potlac-a-branding/vysivka.webp" alt="Strojová výšivka loga" width="800" height="600" />
        <div class="card-body p-4">
          <h3 class="h4 fw-semibold">Výšivka</h3>
          <p class="text-secondary">Prémiový a mimoriadne odolný vzhľad. Logo vyšité priamo do látky pôsobí reprezentatívne a vydrží roky.</p>
          <ul class="list-unstyled ps-0 small mb-0">
            <li class="d-flex gap-2 mb-1"><i class="material-icons text-primary fs-6">done</i> Polokošele, košele, bundy</li>
            <li class="d-flex gap-2 mb-1"><i class="material-icons text-primary fs-6">done</i> Šiltovky a čiapky</li>
            <li class="d-flex gap-2"><i class="material-icons text-primary fs-6">done</i> Pracovné odevy a uniformy</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="mb-5">
  <h2 class="h3 fw-bold mb-3">Porovnanie na prvý pohľad</h2>
  <div class="d-none d-md-block rounded-4 border shadow-sm overflow-hidden">
    <table class="table align-middle mb-0">
      <thead>
        <tr>
          <th scope="col" class="p-3 bg-primary-subtle text-primary-emphasis small text-uppercase fw-semibold border-0">Technika</th>
          <th scope="col" class="p-3 bg-primary-subtle text-primary-emphasis small text-uppercase fw-semibold border-0">Ideálne pre</th>
          <th scope="col" class="p-3 bg-primary-subtle text-primary-emphasis small text-uppercase fw-semibold border-0">Detaily a farby</th>
          <th scope="col" class="p-3 bg-primary-subtle text-primary-emphasis small text-uppercase fw-semibold border-0">Odolnosť pri praní</th>
          <th scope="col" class="p-3 bg-primary-subtle text-primary-emphasis small text-uppercase fw-semibold border-0">Pôsobenie</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <th scope="row" class="p-3 border-start-0 border-end-0">
            <div class="d-flex align-items-center gap-3">
              <span class="d-inline-flex align-items-center justify-content-center flex-shrink-0 rounded-circle bg-primary-subtle text-primary" style="width:44px;height:44px;"><i class="material-icons">format_paint</i></span>
              <span><span class="d-block fw-semibold">Sieťotlač</span><span class="d-block small text-secondary fw-normal">plné farby cez sito</span></span>
            </div>
          </th>
          <td class="p-3 border-start-0 border-end-0">väčšie série, eventy, kampane</td>
          <td class="p-3 border-start-0 border-end-0"><span class="text-nowrap"><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-secondary-subtle me-1" style="width:10px;height:10px;"></span></span><span class="visually-hidden">Detaily a farby: 2 z 3</span></td>
          <td class="p-3 border-start-0 border-end-0"><span class="text-nowrap"><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span></span><span class="visually-hidden">Odolnosť pri praní: 3 z 3</span></td>
          <td class="p-3 border-start-0 border-end-0"><span class="badge rounded-pill bg-primary-subtle text-primary-emphasis fw-semibold px-3 py-2">sýte, odolné</span></td>
        </tr>
        <tr>
          <th scope="row" class="p-3 border-start-0 border-end-0">
            <div class="d-flex align-items-center gap-3">
              <span class="d-inline-flex align-items-center justify-content-center flex-shrink-0 rounded-circle bg-primary-subtle text-primary" style="width:44px;height:44px;"><i class="material-icons">layers</i></span>
              <span><span class="d-block fw-semibold">Transfer (DTF)</span><span class="d-block small text-secondary fw-normal">plnofarebná potlač</span></span>
            </div>
          </th>
          <td class="p-3 border-start-0 border-end-0">menšie série, personalizácia, fotografie</td>
          <td class="p-3 border-start-0 border-end-0"><span class="text-nowrap"><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span></span><span class="visually-hidden">Detaily a farby: 3 z 3</span></td>
          <td class="p-3 border-start-0 border-end-0"><span class="text-nowrap"><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-secondary-subtle me-1" style="width:10px;height:10px;"></span></span><span class="visually-hidden">Odolnosť pri praní: 2 z 3</span></td>
          <td class="p-3 border-start-0 border-end-0"><span class="badge rounded-pill bg-primary-subtle text-primary-emphasis fw-semibold px-3 py-2">detailné, ostré</span></td>
        </tr>
        <tr>
          <th scope="row" class="p-3 border-start-0 border-end-0 border-bottom-0">
            <div class="d-flex align-items-center gap-3">
              <span class="d-inline-flex align-items-center justify-content-center flex-shrink-0 rounded-circle bg-primary-subtle text-primary" style="width:44px;height:44px;"><i class="material-icons">gesture</i></span>
              <span><span class="d-block fw-semibold">Výšivka</span><span class="d-block small text-secondary fw-normal">logo vyšité do látky</span></span>
            </div>
          </th>
          <td class="p-3 border-start-0 border-end-0 border-bottom-0">polokošele, šiltovky, pracovné odevy</td>
          <td class="p-3 border-start-0 border-end-0 border-bottom-0"><span class="text-nowrap"><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-secondary-subtle me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-secondary-subtle me-1" style="width:10px;height:10px;"></span></span><span class="visually-hidden">Detaily a farby: 1 z 3</span></td>
          <td class="p-3 border-start-0 border-end-0 border-bottom-0"><span class="text-nowrap"><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span></span><span class="visually-hidden">Odolnosť pri praní: 3 z 3</span></td>
          <td class="p-3 border-start-0 border-end-0 border-bottom-0"><span class="badge rounded-pill bg-primary-subtle text-primary-emphasis fw-semibold px-3 py-2">prémiové, trvácne</span></td>
        </tr>
      </tbody>
    </table>
  </div>
  <div class="d-md-none d-flex flex-column gap-3">
    <div class="rounded-4 border shadow-sm p-3">
      <div class="d-flex align-items-center gap-3 mb-3">
        <span class="d-inline-flex align-items-center justify-content-center flex-shrink-0 rounded-circle bg-primary-subtle text-primary" style="width:44px;height:44px;"><i class="material-icons">format_paint</i></span>
        <span><span class="d-block fw-semibold">Sieťotlač</span><span class="d-block small text-secondary">plné farby cez sito</span></span>
      </div>
      <p class="small mb-2"><span class="text-secondary">Ideálne pre:</span> väčšie série, eventy, kampane</p>
      <div class="d-flex justify-content-between align-items-center small mb-1"><span class="text-secondary">Detaily a farby</span><span class="text-nowrap"><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-secondary-subtle me-1" style="width:10px;height:10px;"></span></span><span class="visually-hidden">Detaily a farby: 2 z 3</span></div>
      <div class="d-flex justify-content-between align-items-center small mb-3"><span class="text-secondary">Odolnosť pri praní</span><span class="text-nowrap"><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span></span><span class="visually-hidden">Odolnosť pri praní: 3 z 3</span></div>
      <span class="badge rounded-pill bg-primary-subtle text-primary-emphasis fw-semibold px-3 py-2">sýte, odolné</span>
    </div>
    <div class="rounded-4 border shadow-sm p-3">
      <div class="d-flex align-items-center gap-3 mb-3">
        <span class="d-inline-flex align-items-center justify-content-center flex-shrink-0 rounded-circle bg-primary-subtle text-primary" style="width:44px;height:44px;"><i class="material-icons">layers</i></span>
        <span><span class="d-block fw-semibold">Transfer (DTF)</span><span class="d-block small text-secondary">plnofarebná potlač</span></span>
      </div>
      <p class="small mb-2"><span class="text-secondary">Ideálne pre:</span> menšie série, personalizácia, fotografie</p>
      <div class="d-flex justify-content-between align-items-center small mb-1"><span class="text-secondary">Detaily a farby</span><span class="text-nowrap"><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span></span><span class="visually-hidden">Detaily a farby: 3 z 3</span></div>
      <div class="d-flex justify-content-between align-items-center small mb-3"><span class="text-secondary">Odolnosť pri praní</span><span class="text-nowrap"><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-secondary-subtle me-1" style="width:10px;height:10px;"></span></span><span class="visually-hidden">Odolnosť pri praní: 2 z 3</span></div>
      <span class="badge rounded-pill bg-primary-subtle text-primary-emphasis fw-semibold px-3 py-2">detailné, ostré</span>
    </div>
    <div class="rounded-4 border shadow-sm p-3">
      <div class="d-flex align-items-center gap-3 mb-3">
        <span class="d-inline-flex align-items-center justify-content-center flex-shrink-0 rounded-circle bg-primary-subtle text-primary" style="width:44px;height:44px;"><i class="material-icons">gesture</i></span>
        <span><span class="d-block fw-semibold">Výšivka</span><span class="d-block small text-secondary">logo vyšité do látky</span></span>
      </div>
      <p class="small mb-2"><span class="text-secondary">Ideálne pre:</span> polokošele, šiltovky, pracovné odevy</p>
      <div class="d-flex justify-content-between align-items-center small mb-1"><span class="text-secondary">Detaily a farby</span><span class="text-nowrap"><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-secondary-subtle me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-secondary-subtle me-1" style="width:10px;height:10px;"></span></span><span class="visually-hidden">Detaily a farby: 1 z 3</span></div>
      <div class="d-flex justify-content-between align-items-center small mb-3"><span class="text-secondary">Odolnosť pri praní</span><span class="text-nowrap"><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span><span class="d-inline-block rounded-circle bg-primary me-1" style="width:10px;height:10px;"></span></span><span class="visually-hidden">Odolnosť pri praní: 3 z 3</span></div>
      <span class="badge rounded-pill bg-primary-subtle text-primary-emphasis fw-semibold px-3 py-2">prémiové, trvácne</span>
    </div>
  </div>
  <p class="small text-secondary mt-3 mb-0">Nie ste si istí, ktorú techniku zvoliť? <a href="/kontaktujte-nas">Napíšte nám</a> – poradíme podľa vášho loga a oblečenia.</p>
</div>

<div class="row g-4 g-lg-5 align-items-center mb-5">
  <div class="col-lg-6 order-lg-2">
    <h2 class="fw-bold mb-3">Oblečenie, ktoré reprezentuje vašu firmu</h2>
    <p class="text-secondary">Jednotné oblečenie s logom posilňuje dôveru zákazníkov aj súdržnosť tímu. Vaši ľudia sú navyše vidieť všade, kam idú – na stavbe, v predajni, na veľtrhu či na firemnom behu.</p>
    <p class="text-secondary mb-4">Vyberte si oblečenie z našej ponuky a dajte ho označiť vaším logom:</p>
    <div class="d-flex flex-wrap gap-2">
      <a class="btn btn-sm btn-outline-secondary rounded-pill" href="/125-tricka">Tričká</a>
      <a class="btn btn-sm btn-outline-secondary rounded-pill" href="/127-polokosele">Polokošele</a>
      <a class="btn btn-sm btn-outline-secondary rounded-pill" href="/129-mikiny">Mikiny</a>
      <a class="btn btn-sm btn-outline-secondary rounded-pill" href="/131-bundy-a-vesty">Bundy a vesty</a>
      <a class="btn btn-sm btn-outline-secondary rounded-pill" href="/139-pracovne-oblecenie">Pracovné oblečenie</a>
      <a class="btn btn-sm btn-outline-secondary rounded-pill" href="/150-siltovky-a-klobuky">Šiltovky</a>
      <a class="btn btn-sm btn-outline-secondary rounded-pill" href="/149-ciapky">Čiapky</a>
      <a class="btn btn-sm btn-outline-secondary rounded-pill" href="/152-tasky-a-batohy">Tašky a batohy</a>
    </div>
  </div>
  <div class="col-lg-6 order-lg-1">
    <img class="img-fluid w-100 rounded-4 object-fit-cover" src="/img/cms/potlac-a-branding/pracovne-odevy.webp" alt="Pracovníci v jednotných pracovných odevoch" width="1200" height="800" />
  </div>
</div>

<div class="mb-5">
  <div class="text-center mx-auto mb-4" style="max-width:720px;">
    <h2 class="fw-bold">Ako to funguje</h2>
    <p class="text-secondary mb-0">Od prvého e-mailu po hotové oblečenie v štyroch krokoch.</p>
  </div>
  <div class="row g-4">
    <div class="col-sm-6 col-lg-3">
      <div class="h-100 p-4 rounded-4 border">
        <span class="badge rounded-pill text-bg-primary fs-6 mb-3">1</span>
        <h3 class="h5 fw-semibold">Pošlite dopyt</h3>
        <p class="text-secondary small mb-0">Napíšte nám, aké oblečenie, koľko kusov a do kedy potrebujete. Ak ho máte, priložte aj logo. Dopyt je nezáväzný – nevzniká ním povinnosť kúpiť ani zaplatiť.</p>
      </div>
    </div>
    <div class="col-sm-6 col-lg-3">
      <div class="h-100 p-4 rounded-4 border">
        <span class="badge rounded-pill text-bg-primary fs-6 mb-3">2</span>
        <h3 class="h5 fw-semibold">Ponuka a vizualizácia</h3>
        <p class="text-secondary small mb-0">E-mailom vám pošleme cenovú ponuku s konečnou cenou vrátane dopravy, termínom a platnosťou ponuky a vizualizáciu s umiestnením loga, technikou a farbami.</p>
      </div>
    </div>
    <div class="col-sm-6 col-lg-3">
      <div class="h-100 p-4 rounded-4 border">
        <span class="badge rounded-pill text-bg-primary fs-6 mb-3">3</span>
        <h3 class="h5 fw-semibold">Schválenie a výroba</h3>
        <p class="text-secondary small mb-0">Ponuku prijmete odpoveďou na e-mail, v ktorej potvrdíte objednávku s povinnosťou platby. Výrobu spustíme po schválení vizualizácie a prijatí platby.</p>
      </div>
    </div>
    <div class="col-sm-6 col-lg-3">
      <div class="h-100 p-4 rounded-4 border">
        <span class="badge rounded-pill text-bg-primary fs-6 mb-3">4</span>
        <h3 class="h5 fw-semibold">Doručenie</h3>
        <p class="text-secondary small mb-0">Hotové oblečenie vám doručíme až k vám, roztriedené podľa dohody.</p>
      </div>
    </div>
  </div>
</div>

<div class="row g-4 g-lg-5 mb-5">
  <div class="col-lg-5">
    <div class="h-100 p-4 p-lg-5 rounded-4 bg-body-tertiary">
      <i class="material-icons text-primary fs-1 mb-2">draw</i>
      <h2 class="h3 fw-bold">Aké logo nám poslať?</h2>
      <p class="text-secondary">Najlepšie výsledky dosiahneme s vektorovým logom vo formáte <strong>AI, EPS, SVG</strong> alebo <strong>PDF</strong>.</p>
      <p class="text-secondary mb-0">Nemáte ho? Nevadí – pošlite logo v čo najvyššom rozlíšení (napríklad PNG) a poradíme vám, ako ďalej.</p>
    </div>
  </div>
  <div class="col-lg-7">
    <h2 class="h3 fw-bold mb-3">Časté otázky</h2>
    <div class="border-bottom pb-3 mb-3">
      <h3 class="h6 fw-semibold">Ktorú techniku si mám vybrať?</h3>
      <p class="text-secondary small mb-0">Závisí od materiálu, motívu a počtu kusov. Pre väčšie série s jednoduchým logom je vhodná sieťotlač, pre farebné motívy a menšie série transferová potlač a pre reprezentatívny vzhľad výšivka. Radi poradíme.</p>
    </div>
    <div class="border-bottom pb-3 mb-3">
      <h3 class="h6 fw-semibold">Uvidím výsledok ešte pred výrobou?</h3>
      <p class="text-secondary small mb-0">Áno. Ku každej zákazke pripravíme vizualizáciu a výrobu spustíme až po jej schválení.</p>
    </div>
    <div class="border-bottom pb-3 mb-3">
      <h3 class="h6 fw-semibold">Môžem kombinovať rôzne druhy oblečenia a veľkosti?</h3>
      <p class="text-secondary small mb-0">Samozrejme. V jednej zákazke môžete mať napríklad tričká, mikiny aj šiltovky v rôznych veľkostiach a farbách.</p>
    </div>
    <div class="border-bottom pb-3 mb-3">
      <h3 class="h6 fw-semibold">Ako dlho trvá výroba?</h3>
      <p class="text-secondary small mb-0">Termín závisí od techniky, počtu kusov a dostupnosti textilu. Presný termín vám povieme spolu s cenovou ponukou.</p>
    </div>
    <div class="border-bottom pb-3 mb-3">
      <h3 class="h6 fw-semibold">Môžem oblečenie s potlačou vrátiť?</h3>
      <p class="text-secondary small mb-0">Tovar vyrobený podľa vašich požiadaviek (napríklad s vaším logom alebo menom) nemožno vrátiť v 14-dňovej lehote; upozorníme vás na to v ponuke. Na nepotlačený tovar zo skladu sa táto výnimka nevzťahuje a práva z vád vám zostávajú. Podrobnosti sú vo <a href="/content/3-vseobecne-obchodne-podmienky">Všeobecných obchodných podmienkach</a>.</p>
    </div>
    <div>
      <h3 class="h6 fw-semibold">Je možné umiestniť logo na viac miest?</h3>
      <p class="text-secondary small mb-0">Áno – na hruď, chrbát, rukáv aj golier. Každé umiestnenie zobrazíme vo vizualizácii.</p>
    </div>
  </div>
</div>

<div class="position-relative rounded-4 overflow-hidden text-white mb-4">
  <img class="position-absolute top-0 start-0 w-100 h-100 object-fit-cover" src="/img/cms/potlac-a-branding/nite.webp" alt="" width="1600" height="700" />
  <div class="position-absolute top-0 start-0 w-100 h-100 bg-dark opacity-75"></div>
  <div class="position-relative p-4 p-md-5 text-center">
    <h2 class="display-6 fw-bold text-white mb-3">Pripravení obliecť svoj tím?</h2>
    <p class="lead text-white mx-auto mb-4" style="max-width:640px;">Pošlite nám, čo potrebujete, a my vám pripravíme ponuku s vizualizáciou.</p>
    <div class="d-flex flex-wrap justify-content-center gap-2">
      <a class="btn btn-primary btn-lg" href="/kontaktujte-nas">Poslať dopyt</a>
      <a class="btn btn-light btn-lg" href="mailto:obchod@adwear.sk">obchod@adwear.sk</a>
      <a class="btn btn-outline-light btn-lg" href="tel:+421947948180">+421 947 948 180</a>
    </div>
  </div>
</div>

</div>'
WHERE cl.id_cms = 9 AND cl.link_rewrite = 'potlac-a-branding';

-- No partner offers; psgdpr's required box off on registration, guest
-- checkout and the identity page.
UPDATE ps_configuration SET value = '0', date_upd = NOW()
WHERE name IN ('PS_CUSTOMER_OPTIN', 'PSGDPR_CREATION_FORM_SWITCH', 'PSGDPR_CUSTOMER_FORM_SWITCH')
  AND (value IS NULL OR value <> '0');

-- Account forms: an acknowledgement of the privacy notice, not a consent.
-- PSGDPR_* texts are only shown if those switches are turned back on.
UPDATE ps_configuration_lang cl
JOIN ps_configuration c ON c.id_configuration = cl.id_configuration
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.value = 'Beriem na vedomie, že moje údaje spracúvate na vybavenie objednávok a správu zákazníckeho účtu. Podrobnosti sú v <a href="/content/6-zasady-ochrany-osobnych-udajov" target="_blank" rel="noopener">Zásadách ochrany osobných údajov</a>.', cl.date_upd = NOW()
WHERE c.name IN ('CUSTPRIV_MSG_AUTH', 'PSGDPR_CREATION_FORM', 'PSGDPR_CUSTOMER_FORM')
  AND NOT (cl.value <=> 'Beriem na vedomie, že moje údaje spracúvate na vybavenie objednávok a správu zákazníckeho účtu. Podrobnosti sú v <a href="/content/6-zasady-ochrany-osobnych-udajov" target="_blank" rel="noopener">Zásadách ochrany osobných údajov</a>.');

-- Newsletter note (registration checkbox and footer form), plain text.
UPDATE ps_configuration_lang cl
JOIN ps_configuration c ON c.id_configuration = cl.id_configuration
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.value = 'Odber je dobrovoľný. Súhlas môžete kedykoľvek odvolať v zákazníckom účte v časti Osobné údaje alebo e-mailom na obchod@adwear.sk.', cl.date_upd = NOW()
WHERE c.name = 'NW_CONDITIONS'
  AND NOT (cl.value <=> 'Odber je dobrovoľný. Súhlas môžete kedykoľvek odvolať v zákazníckom účte v časti Osobné údaje alebo e-mailom na obchod@adwear.sk.');

-- psgdpr texts per module form.
UPDATE ps_psgdpr_consent_lang gl
JOIN ps_psgdpr_consent g ON g.id_gdpr_consent = gl.id_gdpr_consent
JOIN ps_module m ON m.id_module = g.id_module AND m.name = 'contactform'
JOIN ps_lang l ON l.id_lang = gl.id_lang AND l.iso_code = 'sk'
SET gl.message = 'Beriem na vedomie, že údaje z formulára použijete na vybavenie mojej správy. Podrobnosti sú v <a href="/content/6-zasady-ochrany-osobnych-udajov" target="_blank" rel="noopener">Zásadách ochrany osobných údajov</a>.'
WHERE NOT (gl.message <=> 'Beriem na vedomie, že údaje z formulára použijete na vybavenie mojej správy. Podrobnosti sú v <a href="/content/6-zasady-ochrany-osobnych-udajov" target="_blank" rel="noopener">Zásadách ochrany osobných údajov</a>.');

UPDATE ps_psgdpr_consent_lang gl
JOIN ps_psgdpr_consent g ON g.id_gdpr_consent = gl.id_gdpr_consent
JOIN ps_module m ON m.id_module = g.id_module AND m.name = 'productcomments'
JOIN ps_lang l ON l.id_lang = gl.id_lang AND l.iso_code = 'sk'
SET gl.message = 'Beriem na vedomie, že po schválení sa hodnotenie zverejní pri produkte spolu s mojím menom a priezviskom. Podrobnosti sú v <a href="/content/6-zasady-ochrany-osobnych-udajov" target="_blank" rel="noopener">Zásadách ochrany osobných údajov</a>.'
WHERE NOT (gl.message <=> 'Beriem na vedomie, že po schválení sa hodnotenie zverejní pri produkte spolu s mojím menom a priezviskom. Podrobnosti sú v <a href="/content/6-zasady-ochrany-osobnych-udajov" target="_blank" rel="noopener">Zásadách ochrany osobných údajov</a>.');

UPDATE ps_psgdpr_consent_lang gl
JOIN ps_psgdpr_consent g ON g.id_gdpr_consent = gl.id_gdpr_consent
JOIN ps_module m ON m.id_module = g.id_module AND m.name = 'ps_emailalerts'
JOIN ps_lang l ON l.id_lang = gl.id_lang AND l.iso_code = 'sk'
SET gl.message = 'Beriem na vedomie, že e-mail použijete len na jedno upozornenie o dostupnosti tohto produktu. Podrobnosti sú v <a href="/content/6-zasady-ochrany-osobnych-udajov" target="_blank" rel="noopener">Zásadách ochrany osobných údajov</a>.'
WHERE NOT (gl.message <=> 'Beriem na vedomie, že e-mail použijete len na jedno upozornenie o dostupnosti tohto produktu. Podrobnosti sú v <a href="/content/6-zasady-ochrany-osobnych-udajov" target="_blank" rel="noopener">Zásadách ochrany osobných údajov</a>.');

UPDATE ps_psgdpr_consent_lang gl
JOIN ps_psgdpr_consent g ON g.id_gdpr_consent = gl.id_gdpr_consent
JOIN ps_module m ON m.id_module = g.id_module AND m.name = 'ps_emailsubscription'
JOIN ps_lang l ON l.id_lang = gl.id_lang AND l.iso_code = 'sk'
SET gl.message = 'Súhlasím so zasielaním e-mailových noviniek a ponúk od adwear s. r. o. Súhlas môžem kedykoľvek odvolať. Podrobnosti sú v <a href="/content/6-zasady-ochrany-osobnych-udajov" target="_blank" rel="noopener">Zásadách ochrany osobných údajov</a>.'
WHERE NOT (gl.message <=> 'Súhlasím so zasielaním e-mailových noviniek a ponúk od adwear s. r. o. Súhlas môžem kedykoľvek odvolať. Podrobnosti sú v <a href="/content/6-zasady-ochrany-osobnych-udajov" target="_blank" rel="noopener">Zásadách ochrany osobných údajov</a>.');
