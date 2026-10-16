-- Short intro under the category title (theme clamps it to two lines with "Viac").
-- Only fills categories that have no description yet, so texts edited in the BO stay.
UPDATE ps_category_lang cl
JOIN ps_lang l ON l.id_lang = cl.id_lang AND l.iso_code = 'sk'
JOIN (
  SELECT 124 AS id_category, '<p>Tričká, polokošele, mikiny, bundy aj pracovné oblečenie od overených značiek ako Malfini, Rimeck či Piccolio. Väčšinu modelov nájdete v mnohých farbách a veľkostiach – s potlačou vášho loga alebo bez nej.</p>' AS description
  UNION ALL SELECT 125, '<p>Tričká s krátkym aj dlhým rukávom pre pánov, dámy aj deti. Hodia sa na každý deň, do práce aj ako firemné či reklamné tričká s potlačou. Vyberajte podľa strihu, farby a gramáže.</p>'
  UNION ALL SELECT 126, '<p>Tielka a topy na šport, leto aj voľný čas. Ľahké a priedušné modely v pánskych aj dámskych strihoch, ktoré môžete doplniť potlačou.</p>'
  UNION ALL SELECT 127, '<p>Polokošele s golierom, ktoré pôsobia upravene v kancelárii aj na firemnej akcii. Obľúbená voľba pre firemné oblečenie – s logom vyzerajú reprezentatívne.</p>'
  UNION ALL SELECT 128, '<p>Pánske a dámske košele s krátkym aj dlhým rukávom do kancelárie, na recepciu či na prácu s klientmi. Môžete ich doplniť firemným logom.</p>'
  UNION ALL SELECT 129, '<p>Mikiny s kapucňou aj bez nej, na zips alebo cez hlavu. Teplé a pohodlné na každý deň a vďaka veľkej ploche na hrudi a chrbte ideálne na potlač.</p>'
  UNION ALL SELECT 130, '<p>Fleecové mikiny a bundy, ktoré hrejú, no zostávajú ľahké a rýchlo schnú. Vhodné ako medzivrstva na turistiku, do práce vonku aj na bežné nosenie.</p>'
  UNION ALL SELECT 131, '<p>Softshellové bundy, vetrovky a vesty do premenlivého počasia. Chránia pred vetrom a hodia sa na turistiku, do práce aj ako firemné oblečenie s logom.</p>'
  UNION ALL SELECT 132, '<p>Softshellové bundy spájajú ochranu pred vetrom s priedušnosťou a pružnosťou materiálu. Vhodné na turistiku, šport aj do práce vonku.</p>'
  UNION ALL SELECT 133, '<p>Ľahké vetrovky aj zateplené bundy na prechodné obdobie a chladnejšie dni. Pánske a dámske modely v rôznych farbách.</p>'
  UNION ALL SELECT 134, '<p>Vesty, ktoré zahrejú trup a nechajú voľnosť rukám. Ľahké aj zateplené modely na každodenné nosenie aj do práce.</p>'
  UNION ALL SELECT 135, '<p>Tepláky, legíny a šortky na šport, voľný čas aj pohodlie doma. Pánske aj dámske strihy.</p>'
  UNION ALL SELECT 136, '<p>Pohodlné tepláky a legíny na šport, cvičenie aj voľný čas.</p>'
  UNION ALL SELECT 137, '<p>Šortky na leto, šport a voľný čas.</p>'
  UNION ALL SELECT 138, '<p>Dámske šaty a sukne z príjemných materiálov na každý deň aj do práce.</p>'
  UNION ALL SELECT 139, '<p>Pracovné nohavice, šortky, bundy a reflexné vesty od značiek ako Rimeck a Tricorp. Odolné materiály a praktické vrecká na každodennú prácu v dielni, na stavbe aj vonku.</p>'
  UNION ALL SELECT 140, '<p>Pracovné nohavice s množstvom praktických vreciek a odolnými švami, ktoré vydržia náročnú prácu.</p>'
  UNION ALL SELECT 141, '<p>Pracovné šortky s praktickými vreckami na teplé dni na stavbe, v dielni aj v záhrade.</p>'
  UNION ALL SELECT 142, '<p>Odolné pracovné bundy a vesty, ktoré chránia pred chladom a vetrom pri práci vonku.</p>'
  UNION ALL SELECT 143, '<p>Reflexné vesty s výraznou farbou a reflexnými pásmi pre lepšiu viditeľnosť na ceste, stavbe či v sklade. Môžete ich doplniť potlačou s názvom firmy.</p>'
  UNION ALL SELECT 144, '<p>Pracovná a bezpečnostná obuv od značiek Bata Industrials, Puma a Albatros. Poltopánky, členková obuv aj sandále do dielne, skladu či na stavbu.</p>'
  UNION ALL SELECT 145, '<p>Nízka pracovná a bezpečnostná obuv, ktorá je ľahká a pohodlná na celý deň. Vyberajte podľa veľkosti a certifikácie.</p>'
  UNION ALL SELECT 146, '<p>Vyššia pracovná a bezpečnostná obuv, ktorá lepšie drží členok pri práci v náročnom teréne.</p>'
  UNION ALL SELECT 147, '<p>Priedušné pracovné sandále na teplé dni.</p>'
  UNION ALL SELECT 148, '<p>Čiapky, šiltovky, šatky, tašky, uteráky a pracovné doplnky. Drobnosti, ktoré dotvoria firemnú kolekciu alebo poslúžia ako reklamný darček s logom.</p>'
  UNION ALL SELECT 149, '<p>Čiapky, ktoré zahrejú v chladných dňoch. S logom sú praktickým reklamným predmetom.</p>'
  UNION ALL SELECT 150, '<p>Šiltovky a klobúky, ktoré chránia pred slnkom a s logom poslúžia ako reklamný predmet.</p>'
  UNION ALL SELECT 151, '<p>Multifunkčné šatky na krk aj hlavu na šport, turistiku a voľný čas.</p>'
  UNION ALL SELECT 152, '<p>Tašky a batohy na nákupy, do školy, do práce aj na cesty. S potlačou sú obľúbeným reklamným darčekom.</p>'
  UNION ALL SELECT 153, '<p>Mäkké uteráky a osušky do kúpeľne, na pláž aj do wellness.</p>'
  UNION ALL SELECT 154, '<p>Doplnky k pracovnému oblečeniu a obuvi.</p>'
) intro ON intro.id_category = cl.id_category
SET cl.description = intro.description
WHERE cl.description IS NULL OR cl.description = '';
