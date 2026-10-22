-- Legal pages, part 1: VOP (CMS 3), Reklamácie a vrátenie tovaru (CMS 8) and
-- Doprava a platba (CMS 1), rewritten as the final texts effective 2026-10-22:
-- obchod@adwear.sk, the seat as returns address, non-VAT payer, ordering steps
-- and the "Objednať s povinnosťou platby" button, the non-binding quote,
-- withdrawal under 108/2024 incl. the §20a online form, defects under the
-- current Civil Code, ADR (SOI + ministry list, no ODR link), SOI Prešov.
-- Each update is keyed by id_cms and guarded by the page's slug in Slovak, so a
-- different page under that id is left alone; re-running writes the same text.

-- Všeobecné obchodné podmienky (VOP)
UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = '<h1>VŠEOBECNÉ OBCHODNÉ PODMIENKY</h1>
<p><strong>spoločnosti adwear s. r. o.</strong></p>
<p><strong>účinné od: 22. 10. 2026</strong></p>
<h2>Článok I.</h2>
<h3>Úvodné ustanovenia a identifikácia Predávajúceho</h3>
<ol start="1">
<li>Tieto všeobecné obchodné podmienky (ďalej len „VOP“) upravujú práva a povinnosti súvisiace s nákupom tovaru, objednávaním personalizácie alebo potlače a so žiadosťami o cenovú ponuku prostredníctvom internetového obchodu adwear.sk, ktorý prevádzkuje spoločnosť:</li>
</ol>
<p><strong>adwear s. r. o.</strong><br />sídlo: Staničná 659/7, 094 14 Sečovská Polianka, Slovenská republika<br />IČO: 56383410<br />DIČ: 2122288828<br />Predávajúci nie je platiteľom DPH.<br />zapísaná v Obchodnom registri Okresného súdu Prešov, oddiel: Sro, vložka č. 48213/P<br />e-mail: <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a><br />telefón: <a href="tel:+421947948180">+421 947 948 180</a><br />internetový obchod: adwear.sk</p>
<p>(ďalej len „Predávajúci“ alebo „ADWEAR“).</p>
<ol start="2">
<li>Adresou na vrátenie tovaru, odstúpenie od zmluvy, uplatnenie práv zo zodpovednosti za vady a inú písomnú komunikáciu je sídlo Predávajúceho: <strong>adwear s. r. o., Staničná 659/7, 094 14 Sečovská Polianka</strong>. Elektronicky možno Predávajúceho kontaktovať na e-maile <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a>.</li>
<li>Orgánom dozoru nad dodržiavaním povinností Predávajúceho voči spotrebiteľom je <strong>Slovenská obchodná inšpekcia, Inšpektorát SOI pre Prešovský kraj</strong>, Obrancov mieru 6, 080 01 Prešov 1, odbor výkonu dohľadu, tel. 051/772 15 97 (<a href="https://www.soi.sk/kontakt" target="_blank" rel="noopener">kontakty na www.soi.sk</a>).</li>
<li>Tieto VOP tvoria neoddeliteľnú súčasť zmluvy uzavretej medzi Predávajúcim a Zákazníkom, ak individuálna dohoda strán neurčuje inak.</li>
<li>VOP sa vzťahujú na zmluvy uzatvárané so Spotrebiteľmi aj s Podnikateľmi. Ustanovenia výslovne určené Spotrebiteľovi sa použijú iba na spotrebiteľské právne vzťahy.</li>
<li>Ak je niektoré ustanovenie týchto VOP v rozpore s kogentným ustanovením právneho predpisu na ochranu Spotrebiteľa, použije sa príslušné zákonné ustanovenie.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok II.</h2>
<h3>Vymedzenie pojmov</h3>
<ol start="1">
<li><strong>Zákazníkom</strong> je každá fyzická alebo právnická osoba, ktorá uzatvára alebo má záujem uzatvoriť zmluvu s Predávajúcim.</li>
<li><strong>Spotrebiteľom</strong> je fyzická osoba, ktorá pri uzatváraní a plnení zmluvy nekoná v rámci predmetu svojej podnikateľskej činnosti alebo povolania.</li>
<li><strong>Podnikateľom</strong> je Zákazník, ktorý uzatvára zmluvu v súvislosti so svojou podnikateľskou, obchodnou, profesijnou alebo inou obdobnou činnosťou.</li>
<li>Samotná skutočnosť, že fyzická osoba má pridelené IČO, automaticky neznamená, že pri každej Objednávke vystupuje ako Podnikateľ. Rozhodujúci je účel konkrétnej Objednávky.</li>
<li><strong>Tovarom</strong> sa rozumie najmä textil, odev, obuv, doplnok alebo iný hnuteľný výrobok ponúkaný Predávajúcim.</li>
<li><strong>Bežným tovarom</strong> sa rozumie Tovar, ktorý nebol vyrobený ani upravený podľa individuálnych špecifikácií konkrétneho Zákazníka.</li>
<li><strong>Personalizovaným tovarom</strong> sa rozumie Tovar vyrobený alebo upravený podľa individuálnych špecifikácií konkrétneho Zákazníka, najmä použitím mena, individuálneho textu, čísla, loga, fotografie, grafiky, dizajnu alebo iného individuálne určeného prvku.</li>
<li>Za Personalizovaný tovar sa nepovažuje Tovar, pri ktorom Zákazník vyberá iba z farieb, veľkostí, variantov alebo motívov, ktoré Predávajúci bežne ponúka všetkým zákazníkom.</li>
<li><strong>Potlačou</strong> alebo <strong>Personalizáciou</strong> sa rozumie úprava Tovaru najmä tlačou, výšivkou alebo inou technológiou podľa ponuky Predávajúceho a dohody so Zákazníkom.</li>
<li><strong>Grafickými podkladmi</strong> sa rozumejú najmä logá, fotografie, obrázky, texty, dizajny, ochranné známky, grafické súbory a iné podklady dodané Zákazníkom alebo vytvorené podľa jeho pokynov.</li>
<li><strong>Grafickou korektúrou</strong> sa rozumie vizuálny alebo technický náhľad Personalizácie určený na kontrolu a schválenie Zákazníkom pred výrobou.</li>
<li><strong>Objednávkou</strong> sa rozumie návrh Zákazníka na uzavretie kúpnej zmluvy odoslaný prostredníctvom internetového obchodu tlačidlom „Objednať s povinnosťou platby“.</li>
<li><strong>Žiadosťou o cenovú ponuku</strong> sa rozumie nezáväzná žiadosť Zákazníka odoslaná prostredníctvom internetového obchodu tlačidlom „Odoslať nezáväznú žiadosť o ponuku“ alebo iným spôsobom (napríklad e-mailom). <strong>Cenovou ponukou</strong> sa rozumie ponuka Predávajúceho vypracovaná na základe takej žiadosti.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok III.</h2>
<h3>Informácie o Tovare a ponuka</h3>
<ol start="1">
<li>Predávajúci pri jednotlivých Tovaroch uvádza informácie o ich hlavných vlastnostiach, cene, dostupnosti a ďalšie informácie v rozsahu požadovanom právnymi predpismi.</li>
<li>Informácie o materiálovom zložení textilného výrobku a ďalšie povinné produktové informácie sú uvedené pri konkrétnom Tovare.</li>
<li>Fotografie, náhľady a vizualizácie Tovaru majú informačný charakter. Zobrazenie farieb sa môže primerane líšiť v závislosti od vlastností a nastavenia displeja, osvetlenia, materiálu, výrobnej šarže alebo použitej technológie. Tým nie je dotknutá povinnosť Predávajúceho dodať Tovar v súlade s dohodnutými a zákonnými požiadavkami.</li>
<li>Ak Predávajúci oznámi zníženie ceny Tovaru, údaj o predchádzajúcej cene a ďalšie údaje súvisiace so zľavou uvádza v súlade s platnými právnymi predpismi.</li>
<li>Prezentácia Tovaru v internetovom obchode nie je návrhom Predávajúceho na uzavretie zmluvy. Návrh na uzavretie zmluvy predkladá Zákazník Objednávkou.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok IV.</h2>
<h3>Objednávka a uzavretie zmluvy</h3>
<ol start="1">
<li>
<p>Objednávka sa v internetovom obchode vytvára v týchto krokoch:</p>
<p>a) Zákazník vloží Tovar v zvolenom variante a množstve do košíka,<br />b) v košíku skontroluje obsah, prípadne uplatní zľavový kód, a pokračuje k pokladni,<br />c) zadá osobné údaje (registrácia nie je podmienkou nákupu),<br />d) zadá adresu doručenia a fakturačnú adresu,<br />e) zvolí spôsob dopravy,<br />f) zvolí spôsob platby a skontroluje súhrn Objednávky vrátane celkovej ceny, ceny dopravy a ďalších nákladov,<br />g) potvrdí, že sa oboznámil s týmito VOP, a<br />h) odošle Objednávku tlačidlom <strong>„Objednať s povinnosťou platby“</strong>.</p>
</li>
<li>Pred odoslaním Objednávky môže Zákazník všetky zadané údaje skontrolovať a opraviť chyby, najmä návratom do predchádzajúcich krokov pomocou tlačidiel „Upraviť“ alebo úpravou obsahu košíka.</li>
<li>Odoslaním Objednávky tlačidlom „Objednať s povinnosťou platby“ Zákazník predkladá Predávajúcemu záväzný návrh na uzavretie kúpnej zmluvy a berie na vedomie, že Objednávka zakladá povinnosť zaplatiť kúpnu cenu.</li>
<li>Predávajúci bezodkladne po odoslaní Objednávky zašle Zákazníkovi na ním uvedený e-mail automatické potvrdenie o prijatí Objednávky so súhrnom jej obsahu. Toto automatické potvrdenie potvrdzuje doručenie Objednávky Predávajúcemu; samo osebe nie je prijatím návrhu na uzavretie zmluvy.</li>
<li><strong>Zmluva je uzavretá okamihom, keď Predávajúci Objednávku prijme</strong>, a to oznámením o prijatí Objednávky alebo o jej spracovaní zaslaným Zákazníkovi e-mailom, najneskôr však odoslaním Tovaru Zákazníkovi alebo oznámením, že je Tovar pripravený na osobný odber.</li>
<li>Predávajúci je pred prijatím Objednávky oprávnený overiť najmä dostupnosť Tovaru, technickú realizovateľnosť Personalizácie, použiteľnosť Grafických podkladov a prípadný zjavný technický omyl v údajoch internetového obchodu.</li>
<li>
<p>Predávajúci môže Objednávku pred uzavretím zmluvy odmietnuť najmä v prípade, ak:</p>
<p>a) Tovar nie je dostupný,<br />b) Personalizáciu nemožno z technických dôvodov vykonať,<br />c) Grafické podklady nemožno v požadovanej forme použiť,<br />d) realizácia by bola v rozpore s právnymi predpismi alebo by zjavne neoprávnene zasahovala do práv tretích osôb, alebo<br />e) v internetovom obchode bola v dôsledku technickej chyby uvedená zjavne nesprávna cena alebo iný zjavne nesprávny údaj.</p>
<p>O odmietnutí Objednávky Predávajúci Zákazníka bez zbytočného odkladu informuje e-mailom.</p>
</li>
<li>Ak Zákazník zaplatil cenu alebo jej časť ešte pred prijatím Objednávky a Predávajúci Objednávku neprijme, prijatú platbu mu vráti bez zbytočného odkladu, najneskôr do 14 dní, rovnakým spôsobom, akým bola zaplatená.</li>
<li>Zmluva sa uzatvára v slovenskom jazyku.</li>
<li>Predávajúci uchováva uzavretú zmluvu (údaje o Objednávke) v elektronickej podobe v rozsahu potrebnom na plnenie zmluvy a svojich zákonných povinností; Zákazníkovi je prístupná v jeho zákazníckom účte, ak si ho zriadil, a v e-mailoch, ktoré mu Predávajúci zaslal. Tieto VOP sú zverejnené v internetovom obchode a Zákazník si ich môže kedykoľvek zobraziť, uložiť a vytlačiť.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok V.</h2>
<h3>Nezáväzná cenová ponuka</h3>
<ol start="1">
<li>Pri väčších množstvách, Personalizácii alebo inej individuálnej požiadavke môže Zákazník namiesto Objednávky požiadať o cenovú ponuku. V pokladni internetového obchodu zvolí spôsob „Cenová ponuka“ a žiadosť odošle tlačidlom <strong>„Odoslať nezáväznú žiadosť o ponuku“</strong>; o cenovú ponuku možno požiadať aj e-mailom na <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a>.</li>
<li><strong>Odoslaním žiadosti o cenovú ponuku nevzniká povinnosť kúpiť ani zaplatiť.</strong> Žiadosť nie je Objednávkou ani návrhom na uzavretie zmluvy. Prijatie žiadosti Predávajúci potvrdí e-mailom.</li>
<li>Na základe žiadosti zašle Predávajúci Zákazníkovi e-mailom cenovú ponuku. Cenová ponuka obsahuje najmä opis Tovaru a Personalizácie, množstvo, celkovú cenu vrátane ceny dopravy a ďalších nákladov, spôsob platby, predpokladanú lehotu výroby a dodania, lehotu platnosti ponuky a informáciu o tom, či sa na Tovar vzťahuje výnimka z práva na odstúpenie od zmluvy podľa článku XI. Súčasťou cenovej ponuky sú tieto VOP.</li>
<li>Zákazník cenovú ponuku prijme spôsobom uvedeným v ponuke, najmä odpoveďou na e-mail s ponukou, v ktorej výslovne potvrdí, že ponuku prijíma a objednáva s povinnosťou platby. Ponuku možno prijať iba počas lehoty jej platnosti a bez zmien; odpoveď so zmenami alebo výhradami je novou žiadosťou, na ktorú môže Predávajúci reagovať novou ponukou.</li>
<li><strong>Zmluva je uzavretá okamihom, keď Predávajúcemu dôjde prijatie cenovej ponuky.</strong> Predávajúci Zákazníkovi uzavretie zmluvy bez zbytočného odkladu potvrdí e-mailom.</li>
<li>Kým Zákazník ponuku neprijme, nevzniká mu žiadna povinnosť; ak ju v lehote platnosti neprijme, ponuka zaniká.</li>
<li>Na zmluvu uzavretú prijatím cenovej ponuky sa použijú tieto VOP v znení účinnom v čase prijatia ponuky vrátane práv Spotrebiteľa na odstúpenie od zmluvy a zo zodpovednosti za vady.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok VI.</h2>
<h3>Personalizácia a zákazková výroba</h3>
<ol start="1">
<li>Pri Objednávke Personalizovaného tovaru je Zákazník povinný poskytnúť Predávajúcemu pravdivé, úplné a technicky použiteľné podklady a informácie potrebné na realizáciu zákazky.</li>
<li>Technické požiadavky na Grafické podklady, najmä podporované formáty súborov, rozlíšenie, farebný režim a rozmery, oznámi Predávajúci Zákazníkovi podľa charakteru zákazky pred začatím výroby, najmä e-mailom alebo v cenovej ponuke.</li>
<li>Ak Grafické podklady nie sú vhodné na výrobu, Predávajúci môže Zákazníka požiadať o ich úpravu, dodanie kvalitnejšieho podkladu alebo odsúhlasenie technického riešenia.</li>
<li>Ak Predávajúci pripraví Grafickú korektúru, výroba sa začne až po jej schválení Zákazníkom.</li>
<li>Schválením Grafickej korektúry Zákazník potvrdzuje najmä správnosť obsahu, textov, mien, čísiel, rozmiestnenia prvkov a ďalších vlastností, ktoré je možné z korektúry rozumne posúdiť.</li>
<li>Schválenie Grafickej korektúry nezbavuje Predávajúceho zodpovednosti za vady spôsobené nesprávnou výrobou alebo výrobou v rozpore so schválenou korektúrou.</li>
<li>
<p>Za vadu sa nepovažuje taká technologická odchýlka, ktorá:</p>
<p>a) vyplýva z povahy dohodnutej výrobnej technológie alebo materiálu,<br />b) nachádza sa v rámci vopred oznámenej a primeranej výrobnej tolerancie, a zároveň<br />c) nemá za následok nesúlad výrobku s dohodnutými alebo zákonnými požiadavkami.</p>
</li>
<li>Za bežnú výrobnú toleranciu pri umiestnení potlače sa považuje odchýlka najviac <strong>± 2 cm v horizontálnom alebo vertikálnom smere oproti schválenému grafickému návrhu</strong>. Tolerancia sa nevzťahuje na odchýlky, ktoré podstatne menia vzhľad, čitateľnosť, funkčnosť alebo dohodnuté vlastnosti výrobku.</li>
<li>Farebnosť zobrazená na displeji nemusí byť úplne totožná s farebnosťou výrobku. Výsledok ovplyvňuje najmä farba a materiál textilu a použitá technológia potlače. Ak je pre zákazku podstatná presná farebná zhoda alebo konkrétny farebný štandard, musí byť výslovne dohodnutá pred výrobou.</li>
<li>Rozmery textilného výrobku sa môžu primerane líšiť v rozsahu výrobnej tolerancie výrobcu príslušného textilu. Pri jednotlivých výrobných šaržiach môže dôjsť k primeraným odchýlkam v odtieni alebo rozmeroch.</li>
<li>Pri opakovanej Objednávke nie je možné bez osobitnej dohody zaručiť úplnú farebnú alebo materiálovú zhodu s predchádzajúcou výrobnou šaržou. Tým nie je dotknutá zodpovednosť Predávajúceho za dohodnuté vlastnosti a kvalitu výrobku.</li>
<li>Zákazník je povinný dodržiavať pokyny na používanie, pranie a ošetrovanie Tovaru a Personalizácie. Predávajúci nezodpovedá za poškodenie preukázateľne spôsobené nesprávnym používaním alebo nedodržaním poskytnutých pokynov.</li>
<li>Ak je výrobná lehota určená v pracovných dňoch a jej začatie je podmienené schválením Grafickej korektúry alebo úhradou platby, začína plynúť nasledujúci pracovný deň po splnení poslednej z týchto podmienok.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok VII.</h2>
<h3>Grafické podklady, autorské práva a práva tretích osôb</h3>
<ol start="1">
<li>Zákazník zodpovedá za to, že je oprávnený použiť Grafické podklady, ktoré poskytne Predávajúcemu na realizáciu Objednávky.</li>
<li>Zákazník je povinný zabezpečiť, aby použitím ním dodaného loga, fotografie, textu, dizajnu, ochrannej známky alebo iného obsahu nedošlo k neoprávnenému zásahu do autorských práv, práv k ochranným známkam, osobnostných práv alebo iných práv tretích osôb.</li>
<li>
<p>Poskytnutím Grafických podkladov udeľuje Zákazník Predávajúcemu nevýhradné oprávnenie použiť ich v rozsahu potrebnom na:</p>
<p>a) technické spracovanie Objednávky,<br />b) prípravu Grafickej korektúry,<br />c) výrobu a dodanie objednaného Tovaru,<br />d) vybavenie prípadnej reklamácie, a<br />e) splnenie zákonných povinností Predávajúceho.</p>
</li>
<li>Poskytnutie Grafických podkladov neznamená súhlas s ich použitím na reklamu, sociálne siete, referencie alebo inú marketingovú komunikáciu Predávajúceho. Také použitie je možné iba so súhlasom Zákazníka alebo na inom zákonnom základe.</li>
<li>Predávajúci môže odmietnuť realizáciu obsahu, ktorého výroba by bola v rozpore s právnymi predpismi alebo rozhodnutím príslušného orgánu alebo by zjavne neoprávnene zasahovala do práv tretích osôb.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok VIII.</h2>
<h3>Cena a platobné podmienky</h3>
<ol start="1">
<li>Cena Tovaru a Personalizácie je uvedená v internetovom obchode alebo v cenovej ponuke Predávajúceho.</li>
<li><strong>Predávajúci nie je platiteľom DPH. Všetky uvedené ceny sú konečné.</strong></li>
<li>Pred odoslaním Objednávky je Zákazníkovi v súhrne Objednávky zobrazená celková cena vrátane ceny dopravy a všetkých ďalších platieb. Iné poplatky, než ktoré sú uvedené v súhrne Objednávky alebo v cenovej ponuke, Predávajúci neúčtuje.</li>
<li>Ak cenu Personalizácie nemožno vopred určiť, Predávajúci ju oznámi v cenovej ponuke predtým, ako sa Zákazník zaviaže cenu zaplatiť.</li>
<li>Zákazník môže zaplatiť bankovým prevodom alebo na dobierku pri prevzatí Tovaru. Podrobnosti o spôsoboch platby a ich podmienkach sú uvedené na stránke <a href="/content/1-doprava-a-platba">„Doprava a platba“</a>. Za zvolený spôsob platby sa neúčtuje žiadny poplatok.</li>
<li>Pri bankovom prevode je kúpna cena zaplatená pripísaním sumy na účet Predávajúceho. Platobné údaje dostane Zákazník po odoslaní Objednávky na obrazovke a v e-maile.</li>
<li>Pri Personalizovanom tovare a zákazkovej výrobe Predávajúci požaduje úhradu celej ceny vopred, pred začatím výroby; táto podmienka je uvedená v cenovej ponuke alebo na stránke „Doprava a platba“.</li>
<li>Ak je Zákazníkom Podnikateľ a je v omeškaní so zaplatením peňažného záväzku, Predávajúcemu patria zákonné alebo dohodnuté úroky z omeškania a ďalšie nároky podľa príslušných právnych predpisov.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok IX.</h2>
<h3>Dodanie Tovaru</h3>
<ol start="1">
<li><strong>Tovar doručujeme iba na území Slovenskej republiky.</strong></li>
<li>Zákazník si môže zvoliť osobný odber v sídle Predávajúceho alebo doručenie kuriérom (Slovenská pošta). Ceny dopravy a ďalšie podmienky sú uvedené na stránke <a href="/content/1-doprava-a-platba">„Doprava a platba“</a> a v súhrne Objednávky.</li>
<li>Predpokladaná dodacia lehota je uvedená pri spôsobe dopravy v Objednávke, v cenovej ponuke alebo v potvrdení Objednávky.</li>
<li>Ak sa strany nedohodli na inej lehote dodania, Predávajúci dodá Tovar bez zbytočného odkladu, <strong>najneskôr do 30 dní odo dňa uzavretia zmluvy</strong>.</li>
<li>Pri Personalizovanom tovare môže byť začatie výroby a dodacia lehota podmienené dodaním potrebných Grafických podkladov, schválením Grafickej korektúry, úhradou ceny alebo inou dohodnutou súčinnosťou Zákazníka.</li>
<li>Ak Zákazník neposkytne súčinnosť potrebnú na riadnu výrobu alebo dodanie, dohodnutá lehota sa primerane posunie o čas omeškania Zákazníka a čas objektívne potrebný na opätovné zaradenie zákazky do výroby.</li>
<li>Ak Predávajúci nedodá Spotrebiteľovi Tovar včas, Spotrebiteľ môže postupovať podľa Občianskeho zákonníka vrátane poskytnutia dodatočnej primeranej lehoty na dodanie, ak zákon neumožňuje odstúpiť od zmluvy aj bez jej poskytnutia.</li>
<li>Pri Spotrebiteľovi prechádza vlastnícke právo a nebezpečenstvo náhodnej skazy, poškodenia alebo straty Tovaru okamihom jeho dodania podľa Občianskeho zákonníka.</li>
<li>Ak je Zákazníkom Podnikateľ, prechod nebezpečenstva škody na Tovare sa riadi Obchodným zákonníkom a individuálnou dohodou strán. Pri Podnikateľovi si Predávajúci vyhradzuje vlastnícke právo k Tovaru až do úplného zaplatenia kúpnej ceny.</li>
<li>Zákazníkovi odporúčame pri prevzatí skontrolovať stav zásielky a viditeľné poškodenie obalu oznámiť dopravcovi a podľa možnosti zdokumentovať. Nesplnenie tohto odporúčania Spotrebiteľa nezbavuje jeho zákonných práv.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok X.</h2>
<h3>Odstúpenie Spotrebiteľa od zmluvy bez uvedenia dôvodu</h3>
<ol start="1">
<li>Tento článok sa vzťahuje iba na Spotrebiteľa. Práva podľa tohto článku vyplývajú zo zákona č. 108/2024 Z. z. o ochrane spotrebiteľa.</li>
<li>Spotrebiteľ má právo odstúpiť od zmluvy uzavretej prostredníctvom internetového obchodu bez uvedenia dôvodu v lehote <strong>14 dní odo dňa, keď on alebo ním určená tretia osoba okrem dopravcu prevezme Tovar</strong>. Od zmluvy môže odstúpiť aj pred prevzatím Tovaru, kedykoľvek od uzavretia zmluvy.</li>
<li>Ak sa Tovary objednané v jednej Objednávke dodávajú oddelene, lehota plynie odo dňa prevzatia Tovaru dodaného ako posledný. Ak sa dodáva Tovar pozostávajúci z viacerých dielov alebo kusov, lehota plynie odo dňa prevzatia posledného dielu alebo kusu.</li>
<li>
<p>Spotrebiteľ môže od zmluvy odstúpiť ktorýmkoľvek z týchto spôsobov:</p>
<p>a) <strong>online funkciou „Odstúpiť od zmluvy“</strong> v internetovom obchode, ktorá je dostupná bez prihlásenia na stránke <a href="/module/adwear_withdrawal/form">Odstúpenie od zmluvy</a> a odkazom „Odstúpenie od zmluvy“ v pätičke každej stránky,<br />b) akýmkoľvek jednoznačným vyhlásením zaslaným e-mailom na <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a> alebo poštou na adresu adwear s. r. o., Staničná 659/7, 094 14 Sečovská Polianka, alebo<br />c) vyplnením a zaslaním vzorového formulára, ktorý je Prílohou č. 1 týchto VOP.</p>
</li>
<li>Použitie vzorového formulára ani online funkcie nie je povinné. Na odstúpenie stačí uviesť meno, údaje umožňujúce identifikovať zmluvu (napríklad číslo Objednávky alebo opis nákupu) a rozsah odstúpenia, ak sa odstúpenie týka len niektorých Tovarov.</li>
<li>Pri online funkcii Spotrebiteľ vyplní údaje vo formulári a odstúpenie potvrdí tlačidlom „Potvrdiť odstúpenie od zmluvy“. Predávajúci mu bez zbytočného odkladu zašle na uvedený e-mail potvrdenie o prijatí oznámenia o odstúpení, ktoré obsahuje úplné znenie oznámenia a dátum a čas jeho prijatia (§ 20a zákona č. 108/2024 Z. z.). Pri odstúpení e-mailom alebo poštou Predávajúci prijatie oznámenia potvrdí bez zbytočného odkladu e-mailom.</li>
<li>Lehota na odstúpenie je zachovaná, ak Spotrebiteľ odošle oznámenie o odstúpení najneskôr v posledný deň lehoty.</li>
<li>Spotrebiteľ je povinný najneskôr do <strong>14 dní odo dňa odstúpenia od zmluvy</strong> zaslať Tovar späť na adresu <strong>adwear s. r. o., Staničná 659/7, 094 14 Sečovská Polianka</strong> alebo ho tam po dohode odovzdať. Lehota je zachovaná, ak Spotrebiteľ Tovar odošle pred jej uplynutím. Zásielky zaslané na dobierku Predávajúci nepreberá.</li>
<li><strong>Priame náklady na vrátenie Tovaru znáša Spotrebiteľ.</strong></li>
<li>Predávajúci vráti Spotrebiteľovi všetky platby prijaté na základe zmluvy alebo v súvislosti s ňou, vrátane nákladov na dodanie Tovaru, bez zbytočného odkladu, <strong>najneskôr do 14 dní odo dňa doručenia oznámenia o odstúpení od zmluvy</strong>.</li>
<li>Platby Predávajúci vráti rovnakým spôsobom, aký Spotrebiteľ použil pri platbe, pokiaľ sa výslovne nedohodnú na inom spôsobe, pri ktorom Spotrebiteľovi nevzniknú žiadne ďalšie poplatky. Pri Objednávke zaplatenej na dobierku sa platba vracia bankovým prevodom na účet, ktorý Spotrebiteľ uvedie (vo formulári na odstúpenie alebo e-mailom), alebo inak podľa dohody.</li>
<li>Ak si Spotrebiteľ výslovne zvolil iný než najlacnejší bežný spôsob dodania ponúkaný Predávajúcim, Predávajúci nie je povinný vrátiť rozdiel medzi cenou zvoleného a najlacnejšieho bežného spôsobu dodania.</li>
<li>Predávajúci nie je povinný vrátiť platby skôr, ako mu je Tovar doručený späť alebo kým Spotrebiteľ nepreukáže, že Tovar zaslal späť, podľa toho, čo nastane skôr.</li>
<li>Spotrebiteľ zodpovedá za zníženie hodnoty Tovaru, ktoré vzniklo v dôsledku zaobchádzania s Tovarom nad rámec potrebný na zistenie jeho povahy, vlastností a funkčnosti. Tovar je možné vyskúšať v rozsahu, v akom by to bolo možné v kamennej predajni.</li>
<li>Ak sa odstúpenie týka iba niektorých Tovarov z Objednávky, zmluva o ostatných Tovaroch zostáva zachovaná.</li>
<li>Tento článok sa nepoužije v prípadoch, v ktorých zákon právo Spotrebiteľa na odstúpenie od zmluvy vylučuje (článok XI).</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok XI.</h2>
<h3>Personalizovaný tovar a výnimka z práva na odstúpenie</h3>
<ol start="1">
<li>Spotrebiteľ nemôže odstúpiť od zmluvy bez uvedenia dôvodu, ak je jej predmetom <strong>Tovar vyrobený podľa jeho špecifikácií alebo Tovar vyrobený na mieru</strong> (§ 19 ods. 1 písm. c) zákona č. 108/2024 Z. z.).</li>
<li>Výnimka sa vzťahuje iba na Tovar, ktorý bol podľa individuálnych požiadaviek Spotrebiteľa skutočne vyrobený alebo upravený, najmä potlačou alebo výšivkou s jeho menom, textom, číslom, logom, fotografiou, grafikou alebo iným individuálne určeným prvkom.</li>
<li>Výnimka sa nevzťahuje na Bežný tovar, a to ani vtedy, ak ho Predávajúci objednáva od dodávateľa až po prijatí Objednávky. Výber farby, veľkosti alebo iného bežne ponúkaného variantu nie je špecifikáciou Spotrebiteľa.</li>
<li>Ak Objednávka obsahuje Personalizovaný tovar aj Bežný tovar, Spotrebiteľ môže odstúpiť od zmluvy v časti týkajúcej sa Bežného tovaru.</li>
<li>Predávajúci Spotrebiteľa pred uzavretím zmluvy upozorní, ktorého Tovaru sa výnimka týka, spravidla v cenovej ponuke.</li>
<li><strong>Výnimka z práva na odstúpenie nijako neobmedzuje práva Spotrebiteľa zo zodpovednosti za vady</strong> Personalizovaného tovaru (článok XIII a XIV).</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok XII.</h2>
<h3>Potlač alebo úprava textilu dodaného Zákazníkom</h3>
<ol start="1">
<li>Ak Predávajúci po individuálnej dohode prijme na Potlač alebo inú úpravu textil alebo inú vec Zákazníka, nejde v tejto časti o predaj Tovaru, ale o zhotovenie diela – úpravu veci Zákazníka.</li>
<li>Pri Spotrebiteľovi sa práva a povinnosti z takejto úpravy veci riadia najmä ustanoveniami § 652 až § 655 Občianskeho zákonníka. Záručná doba pri úprave veci je podľa § 654 Občianskeho zákonníka <strong>tri mesiace</strong>.</li>
<li>Ak ide o zmluvu uzavretú na diaľku a Spotrebiteľ požaduje začatie úpravy pred uplynutím lehoty na odstúpenie od zmluvy, Predávajúci si vyžiada jeho výslovnú žiadosť a poučí ho, že po úplnom vykonaní úpravy stráca právo na odstúpenie a že pri odstúpení po začatí plnenia uhradí cenu za skutočne poskytnuté plnenie v rozsahu ustanovenom zákonom.</li>
<li>Predávajúci môže úpravu odmietnuť, ak je vzhľadom na stav, materiál alebo vlastnosti veci riziko poškodenia neprimerané alebo požadovaná technológia nie je pre daný materiál vhodná. Na nevhodnosť pokynov alebo veci Zákazníka Predávajúci upozorní.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok XIII.</h2>
<h3>Zodpovednosť za vady – Spotrebiteľ</h3>
<ol start="1">
<li>Tento článok sa vzťahuje na Spotrebiteľa pri Tovare predanom Predávajúcim vrátane Personalizovaného tovaru. Práva zo zodpovednosti za vady sa spravujú Občianskym zákonníkom (§ 612 a nasl.).</li>
<li>Predávajúci zodpovedá za to, že Tovar pri dodaní spĺňa dohodnuté a zákonné požiadavky na predanú vec.</li>
<li>Predávajúci zodpovedá za vadu, ktorú mal Tovar pri dodaní a ktorá sa prejaví <strong>do dvoch rokov od dodania Tovaru</strong>.</li>
<li><strong>Po prvom odstránení vady opravou sa doba zodpovednosti Predávajúceho za vady predlžuje o 12 mesiacov.</strong> K predĺženiu dochádza iba raz, bez ohľadu na počet ďalších opráv.</li>
<li>Pri vade, ktorá sa prejaví v období ustanovenom Občianskym zákonníkom, sa predpokladá, že Tovar bol vadný už pri dodaní, ak sa nepreukáže opak alebo ak tomu nebráni povaha Tovaru alebo vady.</li>
<li>Spotrebiteľ je povinný vytknúť vadu <strong>do dvoch mesiacov od jej zistenia</strong>, najneskôr do uplynutia doby zodpovednosti za vady vrátane jej predĺženia.</li>
<li>
<p>Vadu možno vytknúť:</p>
<p>a) e-mailom na <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a>,<br />b) písomne na adresu adwear s. r. o., Staničná 659/7, 094 14 Sečovská Polianka, kam možno Tovar aj zaslať, alebo<br />c) osobne v sídle Predávajúceho po predchádzajúcej dohode.</p>
<p>Pri vytknutí je vhodné uviesť číslo Objednávky, označenie Tovaru a opis vady; fotografie pomáhajú vadu posúdiť rýchlejšie, nie sú však podmienkou vytknutia.</p>
</li>
<li>Predávajúci bezodkladne po vytknutí vady vydá Spotrebiteľovi <strong>písomné potvrdenie o vytknutí vady</strong> (spravidla e-mailom), v ktorom uvedie lehotu, v ktorej vadu odstráni.</li>
<li>Lehota na odstránenie vady <strong>nesmie byť dlhšia ako 30 dní odo dňa vytknutia vady</strong>, ibaže dlhšiu lehotu odôvodňuje objektívny dôvod, ktorý Predávajúci nemôže ovplyvniť.</li>
<li><strong>Pred odstránením vady Predávajúci Spotrebiteľa informuje o jeho práve vybrať si medzi opravou a výmenou a o predĺžení doby zodpovednosti za vady o 12 mesiacov po prvom odstránení vady opravou.</strong></li>
<li>
<p>Ak Predávajúci zodpovedá za vadu, Spotrebiteľ má za podmienok Občianskeho zákonníka právo:</p>
<p>a) na odstránenie vady opravou alebo výmenou Tovaru,<br />b) na primeranú zľavu z ceny, alebo<br />c) odstúpiť od zmluvy.</p>
</li>
<li>Spotrebiteľ si môže zvoliť medzi opravou a výmenou, okrem prípadu, keď zvolený spôsob nie je možný alebo by v porovnaní s druhým spôsobom spôsobil Predávajúcemu neprimerané náklady.</li>
<li>Oprava alebo výmena sa vykoná bezplatne, v primeranej lehote a bez závažných ťažkostí pre Spotrebiteľa. Náklady na zaslanie reklamovaného Tovaru Predávajúcemu a jeho vrátenie Spotrebiteľovi pri oprávnenej reklamácii znáša Predávajúci.</li>
<li>Na primeranú zľavu alebo odstúpenie od zmluvy má Spotrebiteľ právo najmä vtedy, ak Predávajúci vadu neodstránil alebo ju odmietol odstrániť, ak sa vada prejaví opakovane, ak je vada taká závažná, že odôvodňuje okamžitú zľavu alebo odstúpenie, alebo ak Predávajúci vyhlásil, že vadu neodstráni. Pre nepodstatnú (zanedbateľnú) vadu nemožno od zmluvy odstúpiť.</li>
<li>Ak Predávajúci zodpovednosť za vadu odmietne, <strong>písomne oznámi Spotrebiteľovi dôvody odmietnutia</strong>.</li>
<li>Uplatnením práv zo zodpovednosti za vady nie je dotknuté právo Spotrebiteľa na náhradu škody ani na náhradu účelne vynaložených nákladov podľa zákona.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok XIV.</h2>
<h3>Osobitosti vád Personalizovaného tovaru</h3>
<ol start="1">
<li>Personalizovaný tovar podlieha zodpovednosti za vady rovnako ako iný Tovar.</li>
<li>Pri posudzovaní súladu Personalizovaného tovaru sa prihliada najmä na schválenú Grafickú korektúru, dodané Grafické podklady, dohodnutú technológiu, výrobnú toleranciu a ďalšie dohodnuté vlastnosti.</li>
<li>Ak Zákazník schválil Grafickú korektúru obsahujúcu konkrétny text, meno, číslo, grafiku alebo rozmiestnenie prvku a Predávajúci vyrobil Tovar v súlade s ňou, chyba obsiahnutá už v podklade schválenom Zákazníkom nie je vadou Tovaru.</li>
<li>Predchádzajúci odsek sa nepoužije na vadu, ktorú Zákazník z Grafickej korektúry nemohol rozumne zistiť, ani na nesprávne vykonanie výroby.</li>
<li>Bežné opotrebovanie Personalizácie ani poškodenie preukázateľne spôsobené používaním v rozpore s pokynmi na používanie alebo ošetrovanie nie je vadou, za ktorú Predávajúci zodpovedá.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok XV.</h2>
<h3>Zodpovednosť za vady a zmeny Objednávky – Podnikateľ</h3>
<ol start="1">
<li>Ak je Zákazníkom Podnikateľ, zodpovednosť za vady sa riadi Obchodným zákonníkom a prípadnou individuálnou dohodou strán.</li>
<li>Podnikateľ je povinný Tovar prezrieť čo najskôr po prechode nebezpečenstva škody a zistené vady oznámiť Predávajúcemu bez zbytočného odkladu.</li>
<li>Podnikateľ nemá zákonné právo na odstúpenie od zmluvy bez uvedenia dôvodu. Po uzavretí zmluvy môže požiadať o zrušenie alebo zmenu Objednávky; Predávajúci nie je povinný žiadosti vyhovieť a pri Personalizovanom tovare ju môže podmieniť úhradou preukázateľne vzniknutých nákladov.</li>
<li>Ustanovenia týchto VOP o odstúpení Spotrebiteľa od zmluvy, o zodpovednosti za vady voči Spotrebiteľovi a o alternatívnom riešení spotrebiteľských sporov sa na Podnikateľa nepoužijú.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok XVI.</h2>
<h3>Neprevzatie zásielky</h3>
<ol start="1">
<li>Zákazník je povinný poskytnúť súčinnosť potrebnú na riadne doručenie Objednávky.</li>
<li>Samotné neprevzatie zásielky sa nepovažuje za odstúpenie od zmluvy. Spotrebiteľ však môže od zmluvy odstúpiť aj pred prevzatím Tovaru podľa článku X.</li>
<li>Ak sa zásielka vráti Predávajúcemu z dôvodu na strane Zákazníka, Predávajúci môže so Zákazníkom dohodnúť jej opätovné odoslanie a úhradu skutočne vzniknutých nákladov s tým spojených.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok XVII.</h2>
<h3>Alternatívne riešenie spotrebiteľských sporov a dozor</h3>
<ol start="1">
<li>Tento článok sa vzťahuje iba na Spotrebiteľa.</li>
<li>Ak Spotrebiteľ nie je spokojný so spôsobom, ktorým Predávajúci vybavil jeho reklamáciu, alebo sa domnieva, že Predávajúci porušil jeho práva, môže sa na Predávajúceho obrátiť so <strong>žiadosťou o nápravu</strong> e-mailom na <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a> alebo písomne na adresu sídla Predávajúceho.</li>
<li>Ak Predávajúci na žiadosť o nápravu odpovie zamietavo alebo na ňu neodpovie <strong>do 30 dní odo dňa jej odoslania</strong>, Spotrebiteľ môže podať návrh na začatie alternatívneho riešenia sporu subjektu alternatívneho riešenia sporov podľa zákona č. 391/2015 Z. z. o alternatívnom riešení spotrebiteľských sporov. Pri zamietavej odpovedi Predávajúci Spotrebiteľa na trvanlivom médiu informuje o príslušných subjektoch alternatívneho riešenia sporov.</li>
<li>Návrh možno podať najneskôr do jedného roka odo dňa, keď Predávajúci na žiadosť o nápravu odpovedal zamietavo, alebo odo dňa uplynutia 30-dňovej lehoty na odpoveď.</li>
<li>
<p>Príslušným subjektom pre spory z kúpy Tovaru je:</p>
<p><strong>Slovenská obchodná inšpekcia</strong><br />ústredný inšpektorát, odbor pre medzinárodné vzťahy a alternatívne riešenie spotrebiteľských sporov<br />Bajkalská 21/A, P. O. BOX 29, 827 99 Bratislava 27<br />e-mail: <a href="mailto:ars@soi.sk">ars@soi.sk</a>, <a href="mailto:adr@soi.sk">adr@soi.sk</a>, tel. +421 2 58 27 21 23<br /><a href="https://www.soi.sk/alternativne-riesenie-spotrebitelskych-sporov" target="_blank" rel="noopener">www.soi.sk – Alternatívne riešenie spotrebiteľských sporov</a></p>
<p>Spotrebiteľ sa môže obrátiť aj na iný subjekt zapísaný v <a href="https://www.mhsr.sk/obchod/ochrana-spotrebitela/alternativne-riesenie-spotrebitelskych-sporov-1/zoznam-subjektov-alternativneho-riesenia-spotrebitelskych-sporov-1" target="_blank" rel="noopener">zozname subjektov alternatívneho riešenia spotrebiteľských sporov</a>, ktorý vedie Ministerstvo hospodárstva Slovenskej republiky. Ak je príslušných viac subjektov, Spotrebiteľ má právo voľby.</p>
</li>
<li>Alternatívne riešenie sporu nevylučuje právo Spotrebiteľa obrátiť sa na súd.</li>
<li>Dozor nad dodržiavaním povinností Predávajúceho vykonáva Slovenská obchodná inšpekcia, Inšpektorát SOI pre Prešovský kraj, Obrancov mieru 6, 080 01 Prešov 1, tel. 051/772 15 97.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok XVIII.</h2>
<h3>Ochrana osobných údajov</h3>
<ol start="1">
<li>Informácie o spracúvaní osobných údajov sú uvedené v dokumente <a href="/content/6-zasady-ochrany-osobnych-udajov">„Zásady ochrany osobných údajov“</a>.</li>
<li>Informácie o používaní súborov cookies sú uvedené v dokumente <a href="/content/7-zasady-pouzivania-cookies">„Zásady používania cookies“</a>.</li>
<li>Osobné údaje obsiahnuté v Grafických podkladoch sa spracúvajú iba v rozsahu potrebnom na realizáciu Objednávky a splnenie súvisiacich povinností Predávajúceho.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok XIX.</h2>
<h3>Elektronická komunikácia</h3>
<ol start="1">
<li>Komunikácia súvisiaca s Objednávkou alebo cenovou ponukou prebieha najmä e-mailom na adresu, ktorú Zákazník uviedol. Zákazník je povinný uviesť správne a aktuálne kontaktné údaje.</li>
<li>Predávajúci Zákazníkovi elektronicky zasiela najmä potvrdenie prijatia Objednávky, oznámenie o jej prijatí, cenové ponuky, účtovné doklady, Grafické korektúry, informácie o odoslaní a potvrdenia súvisiace s odstúpením od zmluvy a reklamáciou.</li>
<li>Uzavretím zmluvy ani súhlasom s týmito VOP Zákazník neudeľuje súhlas so zasielaním marketingovej komunikácie.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok XX.</h2>
<h3>Mimoriadne okolnosti</h3>
<ol start="1">
<li>Predávajúci nezodpovedá za omeškanie alebo nemožnosť plnenia v rozsahu, v akom boli spôsobené okolnosťou, za ktorú podľa právnych predpisov nezodpovedá. O takej prekážke a jej predpokladanom vplyve Zákazníka bez zbytočného odkladu informuje.</li>
<li>Tento článok neobmedzuje zákonné práva Spotrebiteľa pri nedodaní Tovaru alebo inom porušení zmluvy.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Článok XXI.</h2>
<h3>Rozhodné právo a záverečné ustanovenia</h3>
<ol start="1">
<li>Právne vzťahy medzi Predávajúcim a Zákazníkom sa riadia právnym poriadkom Slovenskej republiky, najmä Občianskym zákonníkom, zákonom č. 108/2024 Z. z. o ochrane spotrebiteľa, zákonom č. 22/2004 Z. z. o elektronickom obchode a zákonom č. 391/2015 Z. z. o alternatívnom riešení spotrebiteľských sporov; vzťahy s Podnikateľmi aj Obchodným zákonníkom.</li>
<li>Ak sa niektoré ustanovenie týchto VOP stane neplatným alebo neúčinným, nemá to vplyv na platnosť ostatných ustanovení.</li>
<li>Predávajúci môže tieto VOP meniť. <strong>Na zmluvu sa vždy použije znenie VOP účinné v čase odoslania Objednávky</strong> (pri cenovej ponuke v čase jej prijatia); neskoršia zmena VOP sa na už uzavretú zmluvu nevzťahuje.</li>
<li><strong>Tieto VOP nadobúdajú účinnosť dňa 22. 10. 2026.</strong> Nahrádzajú znenie účinné od 24. 08. 2026, ktoré sa naďalej použije na zmluvy uzavreté na základe Objednávok odoslaných do 21. 10. 2026.</li>
</ol>
<div contenteditable="false"><hr /></div>
<h2>Príloha č. 1</h2>
<h3>Vzorový formulár na odstúpenie od zmluvy</h3>
<p>(vyplňte a zašlite tento formulár len v prípade, že si želáte odstúpiť od zmluvy; odstúpiť môžete aj online funkciou na stránke <a href="/module/adwear_withdrawal/form">Odstúpenie od zmluvy</a>)</p>
<p>– Komu: adwear s. r. o., Staničná 659/7, 094 14 Sečovská Polianka, e-mail: obchod@adwear.sk</p>
<p>– Týmto oznamujem/oznamujeme (*), že odstupujem/odstupujeme (*) od zmluvy na tento tovar: ……………………………………</p>
<p>– Číslo objednávky: ……………………………………</p>
<p>– Dátum objednania/dátum prevzatia (*): ……………………………………</p>
<p>– Meno a priezvisko spotrebiteľa/spotrebiteľov: ……………………………………</p>
<p>– Adresa spotrebiteľa/spotrebiteľov: ……………………………………</p>
<p>– Podpis spotrebiteľa/spotrebiteľov (iba ak sa tento formulár podáva v listinnej podobe): ……………………………………</p>
<p>– Dátum: ……………………………………</p>
<p>(*) Nehodiace sa prečiarknite.</p>'
WHERE cl.id_cms = 3 AND cl.link_rewrite = 'vseobecne-obchodne-podmienky';

-- Reklamácie a vrátenie tovaru
UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = '<h1>Reklamácie a vrátenie tovaru</h1>
<p class="isSelectedEnd">Ak s objednávkou niečo nie je v poriadku alebo chcete tovar vrátiť, kontaktujte nás:</p>
<p class="isSelectedEnd"><strong>E-mail:</strong> <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a><br /><strong>Telefón:</strong> <a href="tel:+421947948180">+421 947 948 180</a></p>
<p class="isSelectedEnd">Adresa na vrátenie tovaru, reklamácie a písomnú komunikáciu je sídlo našej spoločnosti:</p>
<p class="isSelectedEnd"><strong>adwear s. r. o.</strong><br />Staničná 659/7<br />094 14 Sečovská Polianka<br />Slovenská republika</p>
<p class="isSelectedEnd">Ak nám pred odoslaním tovaru napíšete e-mail, pomôžete nám vybaviť vašu požiadavku rýchlejšie. Nie je to však podmienkou vrátenia tovaru ani reklamácie.</p>
<div contenteditable="false"><hr /></div>
<h2>Odstúpenie od zmluvy do 14 dní</h2>
<p class="isSelectedEnd">Ak ste spotrebiteľ, môžete od zmluvy uzavretej v našom internetovom obchode odstúpiť bez uvedenia dôvodu <strong>do 14 dní od prevzatia tovaru</strong> (zákon č. 108/2024 Z. z. o ochrane spotrebiteľa). Odstúpiť môžete aj skôr, ešte pred prevzatím tovaru.</p>
<p class="isSelectedEnd">Odstúpenie nám oznámte jedným z týchto spôsobov:</p>
<ul>
<li><strong>online</strong> na stránke <a href="/module/adwear_withdrawal/form"><strong>Odstúpenie od zmluvy</strong></a> (bez prihlásenia; odkaz nájdete aj v pätičke každej stránky) – formulár odošlete tlačidlom „Potvrdiť odstúpenie od zmluvy“ a hneď vám e-mailom pošleme potvrdenie s úplným znením oznámenia, dátumom a časom jeho prijatia,</li>
<li>e-mailom na <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a> alebo listom na adresu nášho sídla – stačí jednoznačné vyhlásenie s vaším menom, číslom objednávky alebo opisom nákupu a uvedením, ktorých výrobkov sa odstúpenie týka,</li>
<li>vzorovým formulárom, ktorý je <a href="/content/3-vseobecne-obchodne-podmienky">Prílohou č. 1 Všeobecných obchodných podmienok</a>.</li>
</ul>
<p class="isSelectedEnd">Lehota je zachovaná, ak oznámenie odošlete najneskôr v posledný deň lehoty.</p>
<p class="isSelectedEnd">Tovar nám pošlite <strong>najneskôr do 14 dní od odstúpenia</strong> na adresu:</p>
<p class="isSelectedEnd"><strong>adwear s. r. o.</strong><br />Staničná 659/7<br />094 14 Sečovská Polianka</p>
<p class="isSelectedEnd"><strong>Priame náklady na vrátenie tovaru znášate vy.</strong> Zásielky zaslané na našu adresu <strong>na dobierku nepreberáme</strong>.</p>
<div contenteditable="false"><hr /></div>
<h2>Vrátenie peňazí</h2>
<p class="isSelectedEnd">Všetky platby vrátane ceny za doručenie vám vrátime bez zbytočného odkladu, <strong>najneskôr do 14 dní odo dňa, keď nám doručíte oznámenie o odstúpení</strong>.</p>
<p class="isSelectedEnd">Peniaze vrátime rovnakým spôsobom, akým ste platili, pokiaľ sa výslovne nedohodneme na inom spôsobe bez ďalších poplatkov pre vás. Ak ste platili na dobierku, vrátime ich bankovým prevodom na účet, ktorý nám uvediete vo formulári na odstúpenie alebo e-mailom.</p>
<p class="isSelectedEnd">Ak ste si zvolili drahší než najlacnejší ponúkaný spôsob doručenia, vrátime cenu najlacnejšieho bežného spôsobu doručenia.</p>
<p class="isSelectedEnd">Vrátenie platby môžeme zadržať, kým nám tovar nebude doručený alebo kým nepreukážete, že ste ho odoslali, podľa toho, čo nastane skôr.</p>
<div contenteditable="false"><hr /></div>
<h2>V akom stave môže byť vrátený tovar</h2>
<p class="isSelectedEnd">Tovar môžete vyskúšať v rozsahu potrebnom na zistenie jeho povahy, vlastností a funkčnosti, ako by ste to mohli urobiť v kamennej predajni.</p>
<p class="isSelectedEnd">Odporúčame preto vracať tovar:</p>
<ul>
<li>nenosený nad rámec bežného vyskúšania,</li>
<li>nepraný,</li>
<li>čistý,</li>
<li>bez poškodenia,</li>
<li>bez zápachu alebo znečistenia,</li>
<li>podľa možnosti s pôvodnými visačkami a obalom.</li>
</ul>
<p class="isSelectedEnd">Ak ste s tovarom zaobchádzali nad rámec potrebný na jeho vyskúšanie, zodpovedáte za zníženie jeho hodnoty, ktoré tým vzniklo. Samotné odstránenie obalu alebo vyskúšanie tovaru nie je dôvodom na odmietnutie odstúpenia od zmluvy.</p>
<div contenteditable="false"><hr /></div>
<h2>Personalizovaný a potlačený tovar</h2>
<p class="isSelectedEnd">Právo na odstúpenie od zmluvy bez uvedenia dôvodu sa nevzťahuje na tovar <strong>vyrobený podľa vašich špecifikácií alebo na mieru</strong>, napríklad na textil individuálne potlačený alebo vyšitý:</p>
<ul>
<li>vaším logom,</li>
<li>menom,</li>
<li>textom alebo číslom,</li>
<li>fotografiou,</li>
<li>vlastnou grafikou,</li>
<li>iným individuálnym návrhom.</li>
</ul>
<p class="isSelectedEnd">Výnimka sa týka iba takto upravených výrobkov. Bežný tovar, pri ktorom ste si iba vybrali farbu alebo veľkosť, môžete vrátiť vždy, aj keď ho objednávame od dodávateľa až po vašej objednávke. Ak objednávka obsahuje personalizovaný aj bežný tovar, bežný tovar môžete vrátiť.</p>
<p class="isSelectedEnd"><strong>Práva zo zodpovednosti za vady zostávajú zachované aj pri personalizovanom tovare.</strong> Ak je potlač chybná, nezodpovedá schválenému návrhu alebo má výrobok inú vadu, ide o reklamáciu.</p>
<div contenteditable="false"><hr /></div>
<h2>Výmena veľkosti</h2>
<p class="isSelectedEnd">Samostatnú službu výmeny veľkosti neposkytujeme. Bežný tovar môžete vrátiť odstúpením od zmluvy a vytvoriť novú objednávku v požadovanej veľkosti.</p>
<p class="isSelectedEnd">Personalizovaný tovar dodaný v objednanej veľkosti a bez vady nie je možné vrátiť ani vymeniť iba pre nesprávne zvolenú veľkosť.</p>
<div contenteditable="false"><hr /></div>
<h1>Reklamácie</h1>
<p class="isSelectedEnd">Za vady tovaru zodpovedáme podľa Občianskeho zákonníka <strong>dva roky od jeho dodania</strong>. Ak má tovar vadu, vytknite nám ju <strong>do dvoch mesiacov od jej zistenia</strong>:</p>
<ul>
<li>e-mailom na <a href="mailto:obchod@adwear.sk"><strong>obchod@adwear.sk</strong></a>,</li>
<li>listom alebo zaslaním tovaru na adresu adwear s. r. o., Staničná 659/7, 094 14 Sečovská Polianka,</li>
<li>osobne v našom sídle po predchádzajúcej dohode.</li>
</ul>
<p class="isSelectedEnd">Do správy uveďte najmä:</p>
<ul>
<li>číslo objednávky,</li>
<li>vaše meno,</li>
<li>označenie reklamovaného výrobku,</li>
<li>stručný opis vady.</li>
</ul>
<p class="isSelectedEnd">Môžete priložiť aj fotografie vady. Nie sú podmienkou reklamácie, no často nám umožnia vadu posúdiť rýchlejšie a ušetriť vám zasielanie výrobku.</p>
<div contenteditable="false"><hr /></div>
<h2>Ako reklamáciu vybavujeme</h2>
<ul>
<li>Bezodkladne vám vydáme <strong>písomné potvrdenie o vytknutí vady</strong> (e-mailom) s lehotou, v ktorej vadu odstránime.</li>
<li>Vadu odstránime <strong>najneskôr do 30 dní od jej vytknutia</strong>; dlhšia lehota je možná iba z objektívneho dôvodu, ktorý nemôžeme ovplyvniť.</li>
<li>Pred odstránením vady vás informujeme o vašom práve <strong>vybrať si medzi opravou a výmenou</strong>. Zvolený spôsob vykonáme, ibaže nie je možný alebo by v porovnaní s druhým spôsobom spôsobil neprimerané náklady.</li>
<li>Ak vadu odstránime opravou, <strong>doba zodpovednosti za vady sa po prvej oprave predlžuje o 12 mesiacov</strong> (iba raz).</li>
<li>Ak vadu neodstránime, odmietneme ju odstrániť, vada sa opakuje alebo je závažná, máte právo na <strong>primeranú zľavu</strong> alebo môžete <strong>odstúpiť od zmluvy</strong>. Pre zanedbateľnú vadu od zmluvy odstúpiť nemožno.</li>
<li>Oprava aj výmena sú pre vás bezplatné. Pri oprávnenej reklamácii hradíme aj náklady na zaslanie tovaru.</li>
<li>Ak reklamáciu zamietneme, <strong>dôvody vám oznámime písomne</strong>.</li>
</ul>
<p class="isSelectedEnd">Podrobné pravidlá sú v článku XIII <a href="/content/3-vseobecne-obchodne-podmienky">Všeobecných obchodných podmienok</a>.</p>
<div contenteditable="false"><hr /></div>
<h2>Reklamácia potlače</h2>
<p class="isSelectedEnd">Pri reklamácii personalizovaného výrobku posudzujeme najmä:</p>
<ul>
<li>zhodu so schváleným grafickým návrhom,</li>
<li>správnosť textu, loga a grafiky,</li>
<li>umiestnenie potlače,</li>
<li>kvalitu prevedenia,</li>
<li>stav samotného textilu.</li>
</ul>
<p class="isSelectedEnd">Za vadu nemožno považovať chybu, ktorá bola zreteľne obsiahnutá v grafickom návrhu, ktorý ste pred výrobou schválili, ak bol výrobok vyrobený v súlade s ním. To neplatí pre chyby, ktoré ste z návrhu nemohli rozumne zistiť, ani pre chyby vzniknuté pri výrobe.</p>
<div contenteditable="false"><hr /></div>
<h2>Poškodená zásielka pri doprave</h2>
<p class="isSelectedEnd">Ak pri prevzatí zistíte, že je obal viditeľne poškodený, odporúčame:</p>
<ol start="1">
<li>poškodenie zásielky odfotografovať,</li>
<li>podľa možností upozorniť kuriéra na viditeľné poškodenie,</li>
<li>pri výraznom poškodení zásielku neprevziať,</li>
<li>čo najskôr nás kontaktovať na <a href="mailto:obchod@adwear.sk"><strong>obchod@adwear.sk</strong></a>.</li>
</ol>
<p class="isSelectedEnd">Ak poškodenie zistíte až po otvorení zásielky, kontaktujte nás a podľa možnosti pošlite fotografie obalu aj tovaru.</p>
<p class="isSelectedEnd"><strong>Ak ste pri prevzatí neuplatnili výhradu voči kuriérovi, neprichádzate tým o svoje práva voči nám.</strong> Škodu, ktorá vznikla pred dodaním tovaru, s dopravcom riešime my.</p>
<div contenteditable="false"><hr /></div>
<h2>Ak nie ste spokojní s vybavením</h2>
<p class="isSelectedEnd">Ak nie ste spokojní s tým, ako sme vybavili vašu reklamáciu, alebo sa domnievate, že sme porušili vaše práva, pošlite nám <strong>žiadosť o nápravu</strong> na <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a>. Ak ju zamietneme alebo na ňu neodpovieme do 30 dní, môžete podať návrh na alternatívne riešenie sporu <a href="https://www.soi.sk/alternativne-riesenie-spotrebitelskych-sporov" target="_blank" rel="noopener">Slovenskej obchodnej inšpekcii</a> alebo inému subjektu zo <a href="https://www.mhsr.sk/obchod/ochrana-spotrebitela/alternativne-riesenie-spotrebitelskych-sporov-1/zoznam-subjektov-alternativneho-riesenia-spotrebitelskych-sporov-1" target="_blank" rel="noopener">zoznamu Ministerstva hospodárstva SR</a>. Podrobnosti sú v článku XVII Všeobecných obchodných podmienok.</p>
<div contenteditable="false"><hr /></div>
<h2>Dôležité</h2>
<p class="isSelectedEnd"><strong>Vrátenie tovaru</strong> a <strong>reklamácia</strong> sú dve rozdielne situácie:</p>
<ul>
<li><strong>Vrátenie do 14 dní</strong> je odstúpenie spotrebiteľa od zmluvy bez uvedenia dôvodu pri tovare, pri ktorom to zákon umožňuje.</li>
<li><strong>Reklamácia</strong> je uplatnenie práv, keď má výrobok vadu.</li>
</ul>
<p>Podrobné podmienky sú uvedené vo <a href="/content/3-vseobecne-obchodne-podmienky"><strong>Všeobecných obchodných podmienkach</strong></a>, účinných od 22. 10. 2026.</p>'
WHERE cl.id_cms = 8 AND cl.link_rewrite = 'reklamacie-a-vratenie-tovaru';

-- Doprava a platba
UPDATE ps_cms_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
SET cl.content = '<h2>Doprava</h2>
<p></p>
<p>Objednávky doručujeme <strong>iba na území Slovenskej republiky.</strong> Vybrať si môžete z týchto spôsobov:</p>
<p></p>
<h3>Osobný odber</h3>
<p></p>
<p>Objednávku si môžete vyzdvihnúť <strong>bezplatne</strong> v našom sídle na adrese <strong>Staničná 659/7, 094 14 Sečovská Polianka</strong>. Keď bude objednávka pripravená, ozveme sa vám e-mailom alebo telefonicky a dohodneme čas vyzdvihnutia.</p>
<p></p>
<h3>Kuriér (Slovenská pošta)</h3>
<p></p>
<p>Zásielku doručí Slovenská pošta na adresu, ktorú uvediete v objednávke. Cena doručenia je <strong>4,99 €</strong>.</p>
<p></p>
<p>Pri objednávke tovaru v hodnote <strong>70 € a viac (po odpočítaní zliav) je doručenie kuriérom zdarma.</strong></p>
<p></p>
<p>Presná cena dopravy sa vám zobrazí v košíku a v súhrne objednávky pred jej odoslaním.</p>
<p></p>
<h3>Dodacia lehota</h3>
<p></p>
<p>Pri bežnom, nepotlačenom tovare skladom odosielame objednávku spravidla tak, aby bola doručená do <strong>2 až 5 pracovných dní.</strong> Pri platbe bankovým prevodom lehota začína plynúť pripísaním platby na náš účet.</p>
<p></p>
<p>Pri <strong>personalizovanom tovare a zákazkovej potlači</strong> je štandardná doba výroby približne <strong>1 až 3 týždne</strong> po schválení finálneho grafického návrhu a prijatí platby. K nej treba pripočítať čas doručenia. Konkrétnu lehotu uvedieme v cenovej ponuke.</p>
<p></p>
<p>Ak nie je dohodnuté inak, tovar dodáme najneskôr do 30 dní od uzavretia zmluvy.</p>
<p></p>
<hr />
<p></p>
<h2>Platba</h2>
<p></p>
<p>Za objednávku môžete zaplatiť týmito spôsobmi. <strong>Za žiadny spôsob platby neúčtujeme poplatok.</strong></p>
<p></p>
<h3>Bankovým prevodom</h3>
<p></p>
<p>Po odoslaní objednávky vám platobné údaje zobrazíme na stránke s potvrdením a pošleme e-mailom, vrátane QR kódu PAY by square. Platbu prijímame na účet <strong>adwear s. r. o.</strong>, IBAN <strong>SK18 1100 0000 0029 4817 4821</strong> (Tatra banka, a.s.). Ako variabilný symbol alebo správu pre prijímateľa uveďte údaje z potvrdenia objednávky.</p>
<p></p>
<p>Objednávku odošleme po pripísaní platby na náš účet.</p>
<p></p>
<h3>Na dobierku</h3>
<p></p>
<p>Pri bežnom, nepersonalizovanom tovare môžete zaplatiť <strong>pri prevzatí zásielky</strong> od kuriéra alebo pri osobnom odbere.</p>
<p></p>
<h4>Personalizovaný tovar a zákazková potlač</h4>
<p></p>
<p>Objednávky s <strong>personalizovaným tovarom alebo zákazkovou potlačou sa uhrádzajú vopred</strong> bankovým prevodom; dobierka pri nich nie je dostupná. Výroba začne až po:</p>
<p></p>
<ol>
<li>schválení finálneho grafického návrhu,</li>
<li>pripísaní platby na náš účet.</li>
</ol>
<p></p>
<hr />
<p></p>
<h2>Nezáväzná cenová ponuka</h2>
<p></p>
<p>Ak chcete väčšie množstvo, potlač alebo inú úpravu, v pokladni zvoľte <strong>Cenová ponuka</strong> a žiadosť odošlite tlačidlom <strong>„Odoslať nezáväznú žiadosť o ponuku“</strong>. Môžete nám napísať aj na <a href="mailto:obchod@adwear.sk">obchod@adwear.sk</a>.</p>
<p></p>
<p><strong>Odoslaním tejto žiadosti nevzniká povinnosť kúpiť ani zaplatiť. Podmienky prípadnej objednávky vám predložíme v ponuke.</strong></p>
<p></p>
<ol>
<li>Odošlete nezáväznú žiadosť o ponuku.</li>
<li>Pošleme vám e-mailom cenovú ponuku s celkovou cenou vrátane dopravy, spôsobom platby, lehotou dodania a platnosťou ponuky.</li>
<li>Ak s ponukou súhlasíte, prijmete ju spôsobom uvedeným v ponuke – odpoveďou, v ktorej potvrdíte, že objednávate s povinnosťou platby.</li>
<li>Prijatím ponuky vzniká zmluva. Uzavretie zmluvy vám potvrdíme e-mailom.</li>
</ol>
<p></p>
<h3>B2B objednávky</h3>
<p></p>
<p>Pri väčších objednávkach podnikateľov a pravidelných obchodných partnerov je možné <strong>individuálne dohodnúť fakturáciu so splatnosťou.</strong> Nejde o automatický nárok; závisí od dohody so spoločnosťou adwear s. r. o.</p>
<p></p>
<hr />
<p></p>
<h2>Dôležité informácie</h2>
<p></p>
<p><strong>Predávajúci nie je platiteľom DPH. Všetky ceny sú konečné.</strong></p>
<p></p>
<p>Celková cena objednávky vrátane dopravy je vám vždy zobrazená <strong>pred odoslaním objednávky tlačidlom „Objednať s povinnosťou platby“.</strong></p>
<p></p>
<p>Ďalšie podmienky nájdete vo <a href="/content/3-vseobecne-obchodne-podmienky">Všeobecných obchodných podmienkach</a> a na stránke <a href="/content/8-reklamacie-a-vratenie-tovaru">Reklamácie a vrátenie tovaru</a>.</p>'
WHERE cl.id_cms = 1 AND cl.link_rewrite = 'doprava-a-platba';
