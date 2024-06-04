---------------------------------------------------------------------
-- File: Cell\RaidDebuffs\ExpansionData\ExpansionData_deDE.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2023-09-03 19:32:02 +08:00
-- Modified: 2024-06-01 19:58 +08:00
---------------------------------------------------------------------

if not LOCALE_deDE then return end

Cell_ExpansionData.locale = "deDE"

Cell_ExpansionData.expansions = {
    "Dragonflight",
    "Schattenlande",
    "Battle for Azeroth",
    "Legion",
    "Warlords of Draenor",
    "Mists of Pandaria",
    "Cataclysm",
    "Wrath of the Lich King",
    "Burning Crusade",
    "Classic",
}

Cell_ExpansionData.data = {
    ["Battle for Azeroth"] = {
        {
            ["id"] = 1028,
            ["image"] = 2178279,
            ["name"] = "Azeroth",
            ["bosses"] = {
                {
                    ["id"] = 2378,
                    ["image"] = 3284400,
                    ["name"] = "Großkaiserin Shek'zara",
                }, -- [1]
                {
                    ["id"] = 2381,
                    ["image"] = 3284401,
                    ["name"] = "Vuk'laz der Erdbrecher",
                }, -- [2]
                {
                    ["id"] = 2363,
                    ["image"] = 3012063,
                    ["name"] = "Wekemara",
                }, -- [3]
                {
                    ["id"] = 2362,
                    ["image"] = 3012061,
                    ["name"] = "Ulmath der Seelenbinder",
                }, -- [4]
                {
                    ["id"] = 2329,
                    ["image"] = 2497782,
                    ["name"] = "Ivus der Waldlord",
                }, -- [5]
                {
                    ["id"] = 2212,
                    ["image"] = 2176752,
                    ["name"] = "Der Brüllende Löwe",
                }, -- [6]
                {
                    ["id"] = 2139,
                    ["image"] = 2176755,
                    ["name"] = "T'zane",
                }, -- [7]
                {
                    ["id"] = 2141,
                    ["image"] = 2176734,
                    ["name"] = "Ji'arak",
                }, -- [8]
                {
                    ["id"] = 2197,
                    ["image"] = 2176731,
                    ["name"] = "Hagelsturmkonstrukt",
                }, -- [9]
                {
                    ["id"] = 2198,
                    ["image"] = 2176760,
                    ["name"] = "Kriegstreiber Yenajz",
                }, -- [10]
                {
                    ["id"] = 2199,
                    ["image"] = 2176716,
                    ["name"] = "Azurethos, der geflügelte Taifun",
                }, -- [11]
                {
                    ["id"] = 2210,
                    ["image"] = 2176723,
                    ["name"] = "Dünenschlinger Kraulok",
                }, -- [12]
            },
        }, -- [1]
        {
            ["id"] = 1031,
            ["image"] = 2178277,
            ["name"] = "Uldir",
            ["bosses"] = {
                {
                    ["id"] = 2168,
                    ["image"] = 2176749,
                    ["name"] = "Taloc",
                }, -- [1]
                {
                    ["id"] = 2167,
                    ["image"] = 2176741,
                    ["name"] = "MUTTER",
                }, -- [2]
                {
                    ["id"] = 2146,
                    ["image"] = 2176725,
                    ["name"] = "Fauliger Verschlinger",
                }, -- [3]
                {
                    ["id"] = 2169,
                    ["image"] = 2176761,
                    ["name"] = "Zek'voz, Herold von N'Zoth",
                }, -- [4]
                {
                    ["id"] = 2166,
                    ["image"] = 2176757,
                    ["name"] = "Vectis",
                }, -- [5]
                {
                    ["id"] = 2195,
                    ["image"] = 2176762,
                    ["name"] = "Der Wiedergeborene Zul",
                }, -- [6]
                {
                    ["id"] = 2194,
                    ["image"] = 2176742,
                    ["name"] = "Mythrax der Auflöser",
                }, -- [7]
                {
                    ["id"] = 2147,
                    ["image"] = 2176728,
                    ["name"] = "G'huun",
                }, -- [8]
            },
        }, -- [2]
        {
            ["id"] = 1176,
            ["image"] = 2482729,
            ["name"] = "Schlacht von Dazar'alor",
            ["bosses"] = {
                {
                    ["id"] = 2333,
                    ["image"] = 2497778,
                    ["name"] = "Champion des Lichts",
                }, -- [1]
                {
                    ["id"] = 2325,
                    ["image"] = 2497783,
                    ["name"] = "Grong, König des Dschungels",
                }, -- [2]
                {
                    ["id"] = 2341,
                    ["image"] = 2529383,
                    ["name"] = "Jadefeuermeister",
                }, -- [3]
                {
                    ["id"] = 2342,
                    ["image"] = 2497790,
                    ["name"] = "Opulenz",
                }, -- [4]
                {
                    ["id"] = 2330,
                    ["image"] = 2497779,
                    ["name"] = "Konklave der Auserwählten",
                }, -- [5]
                {
                    ["id"] = 2335,
                    ["image"] = 2497784,
                    ["name"] = "König Rastakhan",
                }, -- [6]
                {
                    ["id"] = 2334,
                    ["image"] = 2497788,
                    ["name"] = "Hochtüftler Mekkadrill",
                }, -- [7]
                {
                    ["id"] = 2337,
                    ["image"] = 2497786,
                    ["name"] = "Sturmwallblockade",
                }, -- [8]
                {
                    ["id"] = 2343,
                    ["image"] = 2497785,
                    ["name"] = "Lady Jaina Prachtmeer",
                }, -- [9]
            },
        }, -- [3]
        {
            ["id"] = 1177,
            ["image"] = 2498193,
            ["name"] = "Tiegel der Stürme",
            ["bosses"] = {
                {
                    ["id"] = 2328,
                    ["image"] = 2497795,
                    ["name"] = "Die rastlose Kabale",
                }, -- [1]
                {
                    ["id"] = 2332,
                    ["image"] = 2497794,
                    ["name"] = "Uu'nat, Vorbote der Leere",
                }, -- [2]
            },
        }, -- [4]
        {
            ["id"] = 1179,
            ["image"] = 3025320,
            ["name"] = "Der Ewige Palast",
            ["bosses"] = {
                {
                    ["id"] = 2352,
                    ["image"] = 3012047,
                    ["name"] = "Abyssalkommandantin Sivara",
                }, -- [1]
                {
                    ["id"] = 2347,
                    ["image"] = 3012062,
                    ["name"] = "Schwarzwasserungetüm",
                }, -- [2]
                {
                    ["id"] = 2353,
                    ["image"] = 3012058,
                    ["name"] = "Azsharas Glanz",
                }, -- [3]
                {
                    ["id"] = 2354,
                    ["image"] = 3012055,
                    ["name"] = "Lady Aschenwind",
                }, -- [4]
                {
                    ["id"] = 2351,
                    ["image"] = 3012054,
                    ["name"] = "Orgozoa",
                }, -- [5]
                {
                    ["id"] = 2359,
                    ["image"] = 3012057,
                    ["name"] = "Der Hofstaat der Königin",
                }, -- [6]
                {
                    ["id"] = 2349,
                    ["image"] = 3012064,
                    ["name"] = "Za'qul, Vorbote von Ny'alotha",
                }, -- [7]
                {
                    ["id"] = 2361,
                    ["image"] = 3012056,
                    ["name"] = "Königin Azshara",
                }, -- [8]
            },
        }, -- [5]
        {
            ["id"] = 1180,
            ["image"] = 3221463,
            ["name"] = "Ny'alotha, die Erwachte Stadt",
            ["bosses"] = {
                {
                    ["id"] = 2368,
                    ["image"] = 3256385,
                    ["name"] = "Furorion, der Schwarze Imperator",
                }, -- [1]
                {
                    ["id"] = 2365,
                    ["image"] = 3256380,
                    ["name"] = "Ma'ut",
                }, -- [2]
                {
                    ["id"] = 2369,
                    ["image"] = 3256384,
                    ["name"] = "Der Prophet Skitra",
                }, -- [3]
                {
                    ["id"] = 2377,
                    ["image"] = 3256386,
                    ["name"] = "Dunkle Inquisitorin Xanesh",
                }, -- [4]
                {
                    ["id"] = 2372,
                    ["image"] = 3256378,
                    ["name"] = "Das Schwarmbewusstsein",
                }, -- [5]
                {
                    ["id"] = 2367,
                    ["image"] = 3256383,
                    ["name"] = "Shad'har der Unersättliche",
                }, -- [6]
                {
                    ["id"] = 2373,
                    ["image"] = 3256377,
                    ["name"] = "Drest'agath",
                }, -- [7]
                {
                    ["id"] = 2374,
                    ["image"] = 3256379,
                    ["name"] = "Il'gynoth, die Wiedergeborene Verderbnis",
                }, -- [8]
                {
                    ["id"] = 2370,
                    ["image"] = 3257677,
                    ["name"] = "Vexiona",
                }, -- [9]
                {
                    ["id"] = 2364,
                    ["image"] = 3256382,
                    ["name"] = "Ra-den der Entweihte",
                }, -- [10]
                {
                    ["id"] = 2366,
                    ["image"] = 3256376,
                    ["name"] = "Panzer von N'Zoth",
                }, -- [11]
                {
                    ["id"] = 2375,
                    ["image"] = 3256381,
                    ["name"] = "N'Zoth der Verderber",
                }, -- [12]
            },
        }, -- [6]
        {
            ["id"] = 968,
            ["image"] = 1778892,
            ["name"] = "Atal'Dazar",
            ["bosses"] = {
                {
                    ["id"] = 2082,
                    ["image"] = 1778348,
                    ["name"] = "Priesterin Alun'za",
                }, -- [1]
                {
                    ["id"] = 2036,
                    ["image"] = 1778352,
                    ["name"] = "Vol'kaal",
                }, -- [2]
                {
                    ["id"] = 2083,
                    ["image"] = 1778349,
                    ["name"] = "Rezan",
                }, -- [3]
                {
                    ["id"] = 2030,
                    ["image"] = 1778353,
                    ["name"] = "Yazma",
                }, -- [4]
            },
        }, -- [7]
        {
            ["id"] = 1021,
            ["image"] = 2178278,
            ["name"] = "Das Kronsteiganwesen",
            ["bosses"] = {
                {
                    ["id"] = 2125,
                    ["image"] = 2176732,
                    ["name"] = "Herzbanntriade",
                }, -- [1]
                {
                    ["id"] = 2126,
                    ["image"] = 2176747,
                    ["name"] = "Seelengebundener Goliath",
                }, -- [2]
                {
                    ["id"] = 2127,
                    ["image"] = 2176744,
                    ["name"] = "Raal der Unersättliche",
                }, -- [3]
                {
                    ["id"] = 2128,
                    ["image"] = 2176736,
                    ["name"] = "Lord und Lady Kronsteig",
                }, -- [4]
                {
                    ["id"] = 2129,
                    ["image"] = 2176729,
                    ["name"] = "Gorak Tul",
                }, -- [5]
            },
        }, -- [8]
        {
            ["id"] = 1012,
            ["image"] = 2178274,
            ["name"] = "Das RIESENFLÖZ!!",
            ["bosses"] = {
                {
                    ["id"] = 2109,
                    ["image"] = 2176718,
                    ["name"] = "Münzbetriebener Meuteverprügler",
                }, -- [1]
                {
                    ["id"] = 2114,
                    ["image"] = 2176714,
                    ["name"] = "Azerokk",
                }, -- [2]
                {
                    ["id"] = 2115,
                    ["image"] = 2176745,
                    ["name"] = "Rixxa Fluxflamme",
                }, -- [3]
                {
                    ["id"] = 2116,
                    ["image"] = 2176740,
                    ["name"] = "Mogul Ratztunk",
                }, -- [4]
            },
        }, -- [9]
        {
            ["id"] = 1036,
            ["image"] = 2178271,
            ["name"] = "Der Schrein des Sturms",
            ["bosses"] = {
                {
                    ["id"] = 2153,
                    ["image"] = 2176712,
                    ["name"] = "Aqu'sirr",
                }, -- [1]
                {
                    ["id"] = 2154,
                    ["image"] = 2176754,
                    ["name"] = "Der Gezeitenrat",
                }, -- [2]
                {
                    ["id"] = 2155,
                    ["image"] = 2176737,
                    ["name"] = "Lord Sturmsang",
                }, -- [3]
                {
                    ["id"] = 2156,
                    ["image"] = 2176759,
                    ["name"] = "Vol'zith der Flüsterer",
                }, -- [4]
            },
        }, -- [10]
        {
            ["id"] = 1030,
            ["image"] = 2178273,
            ["name"] = "Der Tempel von Sethraliss",
            ["bosses"] = {
                {
                    ["id"] = 2142,
                    ["image"] = 2176710,
                    ["name"] = "Adderis und Aspix",
                }, -- [1]
                {
                    ["id"] = 2143,
                    ["image"] = 2176739,
                    ["name"] = "Merektha",
                }, -- [2]
                {
                    ["id"] = 2144,
                    ["image"] = 2176727,
                    ["name"] = "Galvazzt",
                }, -- [3]
                {
                    ["id"] = 2145,
                    ["image"] = 2176713,
                    ["name"] = "Avatar von Sethraliss",
                }, -- [4]
            },
        }, -- [11]
        {
            ["id"] = 1022,
            ["image"] = 2178275,
            ["name"] = "Der Tiefenpfuhl",
            ["bosses"] = {
                {
                    ["id"] = 2157,
                    ["image"] = 2176724,
                    ["name"] = "Älteste Leaxa",
                }, -- [1]
                {
                    ["id"] = 2131,
                    ["image"] = 2176719,
                    ["name"] = "Felsschlund der Befallene",
                }, -- [2]
                {
                    ["id"] = 2130,
                    ["image"] = 2176748,
                    ["name"] = "Sporenrufer Zancha",
                }, -- [3]
                {
                    ["id"] = 2158,
                    ["image"] = 2176756,
                    ["name"] = "Entfesselte Monstrosität",
                }, -- [4]
            },
        }, -- [12]
        {
            ["id"] = 1023,
            ["image"] = 2178272,
            ["name"] = "Die Belagerung von Boralus",
            ["bosses"] = {
                {
                    ["id"] = 2133,
                    ["image"] = 2176746,
                    ["name"] = "Unteroffizier Badbrück",
                }, -- [1]
                {
                    ["id"] = 2173,
                    ["image"] = 2176722,
                    ["name"] = "Schreckenskapitänin Luebke",
                }, -- [2]
                {
                    ["id"] = 2134,
                    ["image"] = 2176730,
                    ["name"] = "Hadal Dunkelgrund",
                }, -- [3]
                {
                    ["id"] = 2140,
                    ["image"] = 2176758,
                    ["name"] = "Viq'Goth",
                }, -- [4]
            },
        }, -- [13]
        {
            ["id"] = 1041,
            ["image"] = 2178269,
            ["name"] = "Die Königsruh",
            ["bosses"] = {
                {
                    ["id"] = 2165,
                    ["image"] = 2176751,
                    ["name"] = "Die Goldschlange",
                }, -- [1]
                {
                    ["id"] = 2171,
                    ["image"] = 2176738,
                    ["name"] = "Mchimba der Balsamierer",
                }, -- [2]
                {
                    ["id"] = 2170,
                    ["image"] = 2176750,
                    ["name"] = "Der Rat der Stämme",
                }, -- [3]
                {
                    ["id"] = 2172,
                    ["image"] = 2176720,
                    ["name"] = "Dazar, der erste König",
                }, -- [4]
            },
        }, -- [14]
        {
            ["id"] = 1001,
            ["image"] = 1778893,
            ["name"] = "Freihafen",
            ["bosses"] = {
                {
                    ["id"] = 2102,
                    ["image"] = 1778351,
                    ["name"] = "Himmelskäpt'n Kragg",
                }, -- [1]
                {
                    ["id"] = 2093,
                    ["image"] = 1778346,
                    ["name"] = "Das Kapitänskomitee",
                }, -- [2]
                {
                    ["id"] = 2094,
                    ["image"] = 1778350,
                    ["name"] = "Ring der Beute",
                }, -- [3]
                {
                    ["id"] = 2095,
                    ["image"] = 1778347,
                    ["name"] = "Harlan der Schmierige",
                }, -- [4]
            },
        }, -- [15]
        {
            ["id"] = 1178,
            ["image"] = 3025325,
            ["name"] = "Operation: Mechagon",
            ["bosses"] = {
                {
                    ["id"] = 2357,
                    ["image"] = 3012050,
                    ["name"] = "König Gobbamak",
                }, -- [1]
                {
                    ["id"] = 2358,
                    ["image"] = 3012048,
                    ["name"] = "Schmierer",
                }, -- [2]
                {
                    ["id"] = 2360,
                    ["image"] = 3012059,
                    ["name"] = "Trixie und Naeno",
                }, -- [3]
                {
                    ["id"] = 2355,
                    ["image"] = 3012049,
                    ["name"] = "Fliegende Unterdrückungseinheit JK-8",
                }, -- [4]
                {
                    ["id"] = 2336,
                    ["image"] = 3012060,
                    ["name"] = "Prügelpanzer",
                }, -- [5]
                {
                    ["id"] = 2339,
                    ["image"] = 3012052,
                    ["name"] = "K.U.-J.0.",
                }, -- [6]
                {
                    ["id"] = 2348,
                    ["image"] = 3012053,
                    ["name"] = "Der Garten des Maschinisten",
                }, -- [7]
                {
                    ["id"] = 2331,
                    ["image"] = 3012051,
                    ["name"] = "König Mechagon",
                }, -- [8]
            },
        }, -- [16]
        {
            ["id"] = 1002,
            ["image"] = 2178276,
            ["name"] = "Tol Dagor",
            ["bosses"] = {
                {
                    ["id"] = 2097,
                    ["image"] = 2176753,
                    ["name"] = "Die Sandkönigin",
                }, -- [1]
                {
                    ["id"] = 2098,
                    ["image"] = 2176733,
                    ["name"] = "Jes Knurris",
                }, -- [2]
                {
                    ["id"] = 2099,
                    ["image"] = 2176735,
                    ["name"] = "Kürassier Valyri",
                }, -- [3]
                {
                    ["id"] = 2096,
                    ["image"] = 2176743,
                    ["name"] = "Aufseher Korgus",
                }, -- [4]
            },
        }, -- [17]
    },
    ["Classic"] = {
        {
            ["id"] = 741,
            ["image"] = 1396586,
            ["name"] = "Der Geschmolzene Kern",
            ["bosses"] = {
                {
                    ["id"] = 1519,
                    ["image"] = 1378993,
                    ["name"] = "Lucifron",
                }, -- [1]
                {
                    ["id"] = 1520,
                    ["image"] = 1378995,
                    ["name"] = "Magmadar",
                }, -- [2]
                {
                    ["id"] = 1521,
                    ["image"] = 1378976,
                    ["name"] = "Gehennas",
                }, -- [3]
                {
                    ["id"] = 1522,
                    ["image"] = 1378975,
                    ["name"] = "Garr",
                }, -- [4]
                {
                    ["id"] = 1523,
                    ["image"] = 1379013,
                    ["name"] = "Shazzrah",
                }, -- [5]
                {
                    ["id"] = 1524,
                    ["image"] = 1378966,
                    ["name"] = "Baron Geddon",
                }, -- [6]
                {
                    ["id"] = 1525,
                    ["image"] = 1379015,
                    ["name"] = "Sulfuronherold",
                }, -- [7]
                {
                    ["id"] = 1526,
                    ["image"] = 1378978,
                    ["name"] = "Golemagg der Verbrenner",
                }, -- [8]
                {
                    ["id"] = 1527,
                    ["image"] = 1378998,
                    ["name"] = "Majordomus Exekutus",
                }, -- [9]
                {
                    ["id"] = 1528,
                    ["image"] = 522261,
                    ["name"] = "Ragnaros",
                }, -- [10]
            },
        }, -- [1]
        {
            ["id"] = 742,
            ["image"] = 1396580,
            ["name"] = "Pechschwingenhort",
            ["bosses"] = {
                {
                    ["id"] = 1529,
                    ["image"] = 1379008,
                    ["name"] = "Feuerkralle der Ungezähmte",
                }, -- [1]
                {
                    ["id"] = 1530,
                    ["image"] = 1379022,
                    ["name"] = "Vaelastrasz der Verdorbene",
                }, -- [2]
                {
                    ["id"] = 1531,
                    ["image"] = 1378968,
                    ["name"] = "Brutwächter Dreschbringer",
                }, -- [3]
                {
                    ["id"] = 1532,
                    ["image"] = 1378973,
                    ["name"] = "Feuerschwinge",
                }, -- [4]
                {
                    ["id"] = 1533,
                    ["image"] = 1378971,
                    ["name"] = "Schattenschwinge",
                }, -- [5]
                {
                    ["id"] = 1534,
                    ["image"] = 1378974,
                    ["name"] = "Flammenmaul",
                }, -- [6]
                {
                    ["id"] = 1535,
                    ["image"] = 1378969,
                    ["name"] = "Chromaggus",
                }, -- [7]
                {
                    ["id"] = 1536,
                    ["image"] = 1379001,
                    ["name"] = "Nefarian",
                }, -- [8]
            },
        }, -- [2]
        {
            ["id"] = 743,
            ["image"] = 1396591,
            ["name"] = "Ruinen von Ahn'Qiraj",
            ["bosses"] = {
                {
                    ["id"] = 1537,
                    ["image"] = 1385749,
                    ["name"] = "Kurinnaxx",
                }, -- [1]
                {
                    ["id"] = 1538,
                    ["image"] = 1385734,
                    ["name"] = "General Rajaxx",
                }, -- [2]
                {
                    ["id"] = 1539,
                    ["image"] = 1385755,
                    ["name"] = "Moam",
                }, -- [3]
                {
                    ["id"] = 1540,
                    ["image"] = 1385723,
                    ["name"] = "Buru der Verschlinger",
                }, -- [4]
                {
                    ["id"] = 1541,
                    ["image"] = 1385718,
                    ["name"] = "Ayamiss die Jägerin",
                }, -- [5]
                {
                    ["id"] = 1542,
                    ["image"] = 1385759,
                    ["name"] = "Ossirian der Narbenlose",
                }, -- [6]
            },
        }, -- [3]
        {
            ["id"] = 744,
            ["image"] = 1396593,
            ["name"] = "Tempel von Ahn'Qiraj",
            ["bosses"] = {
                {
                    ["id"] = 1543,
                    ["image"] = 1385769,
                    ["name"] = "Der Prophet Skeram",
                }, -- [1]
                {
                    ["id"] = 1547,
                    ["image"] = 1390436,
                    ["name"] = "Adel der Silithiden",
                }, -- [2]
                {
                    ["id"] = 1544,
                    ["image"] = 1385720,
                    ["name"] = "Schlachtwache Sartura",
                }, -- [3]
                {
                    ["id"] = 1545,
                    ["image"] = 1385728,
                    ["name"] = "Fankriss der Unnachgiebige",
                }, -- [4]
                {
                    ["id"] = 1548,
                    ["image"] = 1385771,
                    ["name"] = "Viscidus",
                }, -- [5]
                {
                    ["id"] = 1546,
                    ["image"] = 1385761,
                    ["name"] = "Prinzessin Huhuran",
                }, -- [6]
                {
                    ["id"] = 1549,
                    ["image"] = 1390437,
                    ["name"] = "Die Zwillingsimperatoren",
                }, -- [7]
                {
                    ["id"] = 1550,
                    ["image"] = 1385760,
                    ["name"] = "Ouro",
                }, -- [8]
                {
                    ["id"] = 1551,
                    ["image"] = 1385726,
                    ["name"] = "C'Thun",
                }, -- [9]
            },
        }, -- [4]
        {
            ["id"] = 64,
            ["image"] = 522358,
            ["name"] = "Burg Schattenfang",
            ["bosses"] = {
                {
                    ["id"] = 96,
                    ["image"] = 522205,
                    ["name"] = "Baron Ashbury",
                }, -- [1]
                {
                    ["id"] = 97,
                    ["image"] = 522206,
                    ["name"] = "Baron Silberlein",
                }, -- [2]
                {
                    ["id"] = 98,
                    ["image"] = 522213,
                    ["name"] = "Kommandant Grüntal",
                }, -- [3]
                {
                    ["id"] = 99,
                    ["image"] = 522249,
                    ["name"] = "Lord Walden",
                }, -- [4]
                {
                    ["id"] = 100,
                    ["image"] = 522247,
                    ["name"] = "Lord Godfrey",
                }, -- [5]
            },
        }, -- [5]
        {
            ["id"] = 316,
            ["image"] = 608214,
            ["name"] = "Das Scharlachrote Kloster",
            ["bosses"] = {
                {
                    ["id"] = 688,
                    ["image"] = 630853,
                    ["name"] = "Thalnos der Seelenfetzer",
                }, -- [1]
                {
                    ["id"] = 671,
                    ["image"] = 630818,
                    ["name"] = "Bruder Korloff",
                }, -- [2]
                {
                    ["id"] = 674,
                    ["image"] = 607643,
                    ["name"] = "Hochinquisitorin Weißsträhne",
                }, -- [3]
            },
        }, -- [6]
        {
            ["id"] = 238,
            ["image"] = 608223,
            ["name"] = "Das Verlies",
            ["bosses"] = {
                {
                    ["id"] = 464,
                    ["image"] = 4776138,
                    ["name"] = "Hogger",
                }, -- [1]
                {
                    ["id"] = 465,
                    ["image"] = 607695,
                    ["name"] = "Fürst Gluthitze",
                }, -- [2]
                {
                    ["id"] = 466,
                    ["image"] = 607753,
                    ["name"] = "Randolph Moloch",
                }, -- [3]
            },
        }, -- [7]
        {
            ["id"] = 226,
            ["image"] = 608211,
            ["name"] = "Der Flammenschlund",
            ["bosses"] = {
                {
                    ["id"] = 694,
                    ["image"] = 608309,
                    ["name"] = "Adarogg",
                }, -- [1]
                {
                    ["id"] = 695,
                    ["image"] = 608310,
                    ["name"] = "Dunkelschamane Koranthal",
                }, -- [2]
                {
                    ["id"] = 696,
                    ["image"] = 522251,
                    ["name"] = "Nagma",
                }, -- [3]
                {
                    ["id"] = 697,
                    ["image"] = 608315,
                    ["name"] = "Lavawache Gordoth",
                }, -- [4]
            },
        }, -- [8]
        {
            ["id"] = 237,
            ["image"] = 608217,
            ["name"] = "Der Tempel von Atal'Hakkar",
            ["bosses"] = {
                {
                    ["id"] = 457,
                    ["image"] = 607548,
                    ["name"] = "Avatar von Hakkar",
                }, -- [1]
                {
                    ["id"] = 458,
                    ["image"] = 607665,
                    ["name"] = "Jammal'an der Prophet",
                }, -- [2]
                {
                    ["id"] = 459,
                    ["image"] = 608311,
                    ["name"] = "Die Wächter des Traumes",
                }, -- [3]
                {
                    ["id"] = 463,
                    ["image"] = 607768,
                    ["name"] = "Eranikus' Schemen",
                }, -- [4]
            },
        }, -- [9]
        {
            ["id"] = 230,
            ["image"] = 608200,
            ["name"] = "Düsterbruch",
            ["bosses"] = {
                {
                    ["id"] = 402,
                    ["image"] = 607824,
                    ["name"] = "Zevrim Dornhuf",
                }, -- [1]
                {
                    ["id"] = 403,
                    ["image"] = 607653,
                    ["name"] = "Hydrobrut",
                }, -- [2]
                {
                    ["id"] = 404,
                    ["image"] = 607686,
                    ["name"] = "Lethtendris",
                }, -- [3]
                {
                    ["id"] = 405,
                    ["image"] = 607533,
                    ["name"] = "Alzzin der Wildformer",
                }, -- [4]
                {
                    ["id"] = 406,
                    ["image"] = 607785,
                    ["name"] = "Tendris Wucherborke",
                }, -- [5]
                {
                    ["id"] = 407,
                    ["image"] = 607656,
                    ["name"] = "Illyanna Rabeneiche",
                }, -- [6]
                {
                    ["id"] = 408,
                    ["image"] = 607703,
                    ["name"] = "Magister Kalendris",
                }, -- [7]
                {
                    ["id"] = 409,
                    ["image"] = 607657,
                    ["name"] = "Immol'thar",
                }, -- [8]
                {
                    ["id"] = 410,
                    ["image"] = 607745,
                    ["name"] = "Prinz Tortheldrin",
                }, -- [9]
                {
                    ["id"] = 411,
                    ["image"] = 607630,
                    ["name"] = "Wache Mol'dar",
                }, -- [10]
                {
                    ["id"] = 412,
                    ["image"] = 607777,
                    ["name"] = "Stampfer Kreeg",
                }, -- [11]
                {
                    ["id"] = 413,
                    ["image"] = 607629,
                    ["name"] = "Wache Fengus",
                }, -- [12]
                {
                    ["id"] = 414,
                    ["image"] = 607631,
                    ["name"] = "Wache Slip'kik",
                }, -- [13]
                {
                    ["id"] = 415,
                    ["image"] = 607560,
                    ["name"] = "Hauptmann Krombruch",
                }, -- [14]
                {
                    ["id"] = 416,
                    ["image"] = 607565,
                    ["name"] = "Cho'Rush der Beobachter",
                }, -- [15]
                {
                    ["id"] = 417,
                    ["image"] = 607673,
                    ["name"] = "König Gordok",
                }, -- [16]
            },
        }, -- [10]
        {
            ["id"] = 231,
            ["image"] = 608202,
            ["name"] = "Gnomeregan",
            ["bosses"] = {
                {
                    ["id"] = 419,
                    ["image"] = 607628,
                    ["name"] = "Grubbis",
                }, -- [1]
                {
                    ["id"] = 420,
                    ["image"] = 607808,
                    ["name"] = "Verflüssigte Ablagerung",
                }, -- [2]
                {
                    ["id"] = 421,
                    ["image"] = 607594,
                    ["name"] = "Elektrokutor 6000",
                }, -- [3]
                {
                    ["id"] = 418,
                    ["image"] = 607572,
                    ["name"] = "Meuteverprügler 9-60",
                }, -- [4]
                {
                    ["id"] = 422,
                    ["image"] = 607714,
                    ["name"] = "Robogenieur Thermadraht",
                }, -- [5]
            },
        }, -- [11]
        {
            ["id"] = 240,
            ["image"] = 608229,
            ["name"] = "Höhlen des Wehklagens",
            ["bosses"] = {
                {
                    ["id"] = 474,
                    ["image"] = 607680,
                    ["name"] = "Lady Anakondra",
                }, -- [1]
                {
                    ["id"] = 476,
                    ["image"] = 607696,
                    ["name"] = "Lord Pythas",
                }, -- [2]
                {
                    ["id"] = 475,
                    ["image"] = 607693,
                    ["name"] = "Lord Kobrahn",
                }, -- [3]
                {
                    ["id"] = 477,
                    ["image"] = 607676,
                    ["name"] = "Kresh",
                }, -- [4]
                {
                    ["id"] = 478,
                    ["image"] = 607775,
                    ["name"] = "Skum",
                }, -- [5]
                {
                    ["id"] = 479,
                    ["image"] = 607698,
                    ["name"] = "Lord Serpentis",
                }, -- [6]
                {
                    ["id"] = 480,
                    ["image"] = 607805,
                    ["name"] = "Verdan der Ewiglebende",
                }, -- [7]
                {
                    ["id"] = 481,
                    ["image"] = 607721,
                    ["name"] = "Mutanus der Verschlinger",
                }, -- [8]
            },
        }, -- [12]
        {
            ["id"] = 233,
            ["image"] = 608212,
            ["name"] = "Hügel der Klingenhauer",
            ["bosses"] = {
                {
                    ["id"] = 1142,
                    ["image"] = 607633,
                    ["name"] = "Aarux",
                }, -- [1]
                {
                    ["id"] = 433,
                    ["image"] = 607718,
                    ["name"] = "Mordresh Feuerauge",
                }, -- [2]
                {
                    ["id"] = 1143,
                    ["image"] = 1064178,
                    ["name"] = "Schwämmerl",
                }, -- [3]
                {
                    ["id"] = 1146,
                    ["image"] = 607584,
                    ["name"] = "Todessprecher Schwarzdorn",
                }, -- [4]
                {
                    ["id"] = 1141,
                    ["image"] = 607537,
                    ["name"] = "Amnennar der Kältebringer",
                }, -- [5]
            },
        }, -- [13]
        {
            ["id"] = 234,
            ["image"] = 608213,
            ["name"] = "Kral der Klingenhauer",
            ["bosses"] = {
                {
                    ["id"] = 896,
                    ["image"] = 607531,
                    ["name"] = "Jäger Knochenhauer",
                }, -- [1]
                {
                    ["id"] = 895,
                    ["image"] = 607760,
                    ["name"] = "Roogug",
                }, -- [2]
                {
                    ["id"] = 899,
                    ["image"] = 607736,
                    ["name"] = "Oberanführer Rammhauer",
                }, -- [3]
                {
                    ["id"] = 900,
                    ["image"] = 1064175,
                    ["name"] = "Groyat der blinde Jäger",
                }, -- [4]
                {
                    ["id"] = 901,
                    ["image"] = 607563,
                    ["name"] = "Charlga Klingenflanke",
                }, -- [5]
            },
        }, -- [14]
        {
            ["id"] = 232,
            ["image"] = 608209,
            ["name"] = "Maraudon",
            ["bosses"] = {
                {
                    ["id"] = 423,
                    ["image"] = 607728,
                    ["name"] = "Noxxion",
                }, -- [1]
                {
                    ["id"] = 424,
                    ["image"] = 607756,
                    ["name"] = "Schlingwurzler",
                }, -- [2]
                {
                    ["id"] = 425,
                    ["image"] = 607796,
                    ["name"] = "Tüftler Gizlock",
                }, -- [3]
                {
                    ["id"] = 427,
                    ["image"] = 607699,
                    ["name"] = "Lord Schlangenzunge",
                }, -- [4]
                {
                    ["id"] = 428,
                    ["image"] = 607562,
                    ["name"] = "Celebras der Verfluchte",
                }, -- [5]
                {
                    ["id"] = 429,
                    ["image"] = 607684,
                    ["name"] = "Erdrutsch",
                }, -- [6]
                {
                    ["id"] = 430,
                    ["image"] = 607761,
                    ["name"] = "Faulschnapper",
                }, -- [7]
                {
                    ["id"] = 431,
                    ["image"] = 607747,
                    ["name"] = "Prinzessin Theradras",
                }, -- [8]
            },
        }, -- [15]
        {
            ["id"] = 311,
            ["image"] = 643262,
            ["name"] = "Scharlachrote Hallen",
            ["bosses"] = {
                {
                    ["id"] = 660,
                    ["image"] = 630833,
                    ["name"] = "Hundemeister Braun",
                }, -- [1]
                {
                    ["id"] = 654,
                    ["image"] = 630816,
                    ["name"] = "Waffenmeister Harlan",
                }, -- [2]
                {
                    ["id"] = 656,
                    ["image"] = 630825,
                    ["name"] = "Flammenwirker Koegler",
                }, -- [3]
            },
        }, -- [16]
        {
            ["id"] = 246,
            ["image"] = 608215,
            ["name"] = "Scholomance",
            ["bosses"] = {
                {
                    ["id"] = 659,
                    ["image"] = 630835,
                    ["name"] = "Ausbilderin Kaltherz",
                }, -- [1]
                {
                    ["id"] = 663,
                    ["image"] = 607666,
                    ["name"] = "Jandice Barov",
                }, -- [2]
                {
                    ["id"] = 665,
                    ["image"] = 607755,
                    ["name"] = "Blutrippe",
                }, -- [3]
                {
                    ["id"] = 666,
                    ["image"] = 630838,
                    ["name"] = "Lilian Voss",
                }, -- [4]
                {
                    ["id"] = 684,
                    ["image"] = 607582,
                    ["name"] = "Dunkelmeister Gandling",
                }, -- [5]
            },
        }, -- [17]
        {
            ["id"] = 228,
            ["image"] = 608196,
            ["name"] = "Schwarzfelstiefen",
            ["bosses"] = {
                {
                    ["id"] = 369,
                    ["image"] = 607644,
                    ["name"] = "Verhörmeisterin Gerstahn",
                }, -- [1]
                {
                    ["id"] = 370,
                    ["image"] = 607697,
                    ["name"] = "Lord Roccor",
                }, -- [2]
                {
                    ["id"] = 371,
                    ["image"] = 607647,
                    ["name"] = "Hundemeister Grebmar",
                }, -- [3]
                {
                    ["id"] = 372,
                    ["image"] = 608314,
                    ["name"] = "Ring des Gesetzes",
                }, -- [4]
                {
                    ["id"] = 373,
                    ["image"] = 607749,
                    ["name"] = "Pyromant Weisenkorn",
                }, -- [5]
                {
                    ["id"] = 374,
                    ["image"] = 607694,
                    ["name"] = "Lord Incendius",
                }, -- [6]
                {
                    ["id"] = 375,
                    ["image"] = 607814,
                    ["name"] = "Wärter Stilgiss",
                }, -- [7]
                {
                    ["id"] = 376,
                    ["image"] = 607602,
                    ["name"] = "Fineous Dunkelader",
                }, -- [8]
                {
                    ["id"] = 377,
                    ["image"] = 607549,
                    ["name"] = "Bael'Gar",
                }, -- [9]
                {
                    ["id"] = 378,
                    ["image"] = 607610,
                    ["name"] = "General Zornesschmied",
                }, -- [10]
                {
                    ["id"] = 379,
                    ["image"] = 607618,
                    ["name"] = "Golemlord Argelmach",
                }, -- [11]
                {
                    ["id"] = 380,
                    ["image"] = 607650,
                    ["name"] = "Hurley Pestatem",
                }, -- [12]
                {
                    ["id"] = 381,
                    ["image"] = 607740,
                    ["name"] = "Phalanx",
                }, -- [13]
                {
                    ["id"] = 383,
                    ["image"] = 607741,
                    ["name"] = "Stöpsel Zapfring",
                }, -- [14]
                {
                    ["id"] = 384,
                    ["image"] = 607535,
                    ["name"] = "Botschafter Flammenschlag",
                }, -- [15]
                {
                    ["id"] = 385,
                    ["image"] = 607587,
                    ["name"] = "Die Sieben",
                }, -- [16]
                {
                    ["id"] = 386,
                    ["image"] = 607705,
                    ["name"] = "Magmus",
                }, -- [17]
                {
                    ["id"] = 387,
                    ["image"] = 607595,
                    ["name"] = "Imperator Dagran Thaurissan",
                }, -- [18]
            },
        }, -- [18]
        {
            ["id"] = 236,
            ["image"] = 608216,
            ["name"] = "Stratholme",
            ["bosses"] = {
                {
                    ["id"] = 443,
                    ["image"] = 607637,
                    ["name"] = "Herdsinger Forresten",
                }, -- [1]
                {
                    ["id"] = 445,
                    ["image"] = 607795,
                    ["name"] = "Timmy der Grausame",
                }, -- [2]
                {
                    ["id"] = 749,
                    ["image"] = 607569,
                    ["name"] = "Kommandant Malor",
                }, -- [3]
                {
                    ["id"] = 446,
                    ["image"] = 607818,
                    ["name"] = "Willey Hoffnungsbrecher",
                }, -- [4]
                {
                    ["id"] = 448,
                    ["image"] = 607660,
                    ["name"] = "Instrukteur Galford",
                }, -- [5]
                {
                    ["id"] = 449,
                    ["image"] = 607551,
                    ["name"] = "Balnazzar",
                }, -- [6]
                {
                    ["id"] = 450,
                    ["image"] = 607792,
                    ["name"] = "Die Unverziehene",
                }, -- [7]
                {
                    ["id"] = 451,
                    ["image"] = 607553,
                    ["name"] = "Baroness Anastari",
                }, -- [8]
                {
                    ["id"] = 452,
                    ["image"] = 607724,
                    ["name"] = "Nerub'enkan",
                }, -- [9]
                {
                    ["id"] = 453,
                    ["image"] = 607707,
                    ["name"] = "Maleki der Leichenblasse",
                }, -- [10]
                {
                    ["id"] = 454,
                    ["image"] = 607791,
                    ["name"] = "Magistrat Barthilas",
                }, -- [11]
                {
                    ["id"] = 455,
                    ["image"] = 607752,
                    ["name"] = "Ramstein der Verschlinger",
                }, -- [12]
                {
                    ["id"] = 456,
                    ["image"] = 607692,
                    ["name"] = "Baron Aurius Totenschwur",
                }, -- [13]
            },
        }, -- [19]
        {
            ["id"] = 227,
            ["image"] = 608195,
            ["name"] = "Tiefschwarze Grotte",
            ["bosses"] = {
                {
                    ["id"] = 368,
                    ["image"] = 1064179,
                    ["name"] = "Ghamoo-Ra",
                }, -- [1]
                {
                    ["id"] = 436,
                    ["image"] = 1064180,
                    ["name"] = "Domina",
                }, -- [2]
                {
                    ["id"] = 426,
                    ["image"] = 522214,
                    ["name"] = "Unterwerfer Kor'ul",
                }, -- [3]
                {
                    ["id"] = 1145,
                    ["image"] = 1064181,
                    ["name"] = "Thruk",
                }, -- [4]
                {
                    ["id"] = 447,
                    ["image"] = 1064182,
                    ["name"] = "Wächter der Tiefe",
                }, -- [5]
                {
                    ["id"] = 1144,
                    ["image"] = 1064183,
                    ["name"] = "Scharfrichter Gor",
                }, -- [6]
                {
                    ["id"] = 437,
                    ["image"] = 1064184,
                    ["name"] = "Zwielichtfürst Bathiel",
                }, -- [7]
                {
                    ["id"] = 444,
                    ["image"] = 607532,
                    ["name"] = "Aku'mai",
                }, -- [8]
            },
        }, -- [20]
        {
            ["id"] = 63,
            ["image"] = 522352,
            ["name"] = "Todesminen",
            ["bosses"] = {
                {
                    ["id"] = 89,
                    ["image"] = 522228,
                    ["name"] = "Glubtok",
                }, -- [1]
                {
                    ["id"] = 90,
                    ["image"] = 522234,
                    ["name"] = "Helix Ritzelbrecher",
                }, -- [2]
                {
                    ["id"] = 91,
                    ["image"] = 522225,
                    ["name"] = "Feindschnitter 5000",
                }, -- [3]
                {
                    ["id"] = 92,
                    ["image"] = 522189,
                    ["name"] = "Admiral Knurrreißer",
                }, -- [4]
                {
                    ["id"] = 93,
                    ["image"] = 522210,
                    ["name"] = "\"Kapitän\" Krümel",
                }, -- [5]
                {
                    ["id"] = 95,
                    ["image"] = 522278,
                    ["name"] = "Vanessa van Cleef",
                }, -- [6]
            },
        }, -- [21]
        {
            ["id"] = 239,
            ["image"] = 608225,
            ["name"] = "Uldaman",
            ["bosses"] = {
                {
                    ["id"] = 467,
                    ["image"] = 607757,
                    ["name"] = "Revelosh",
                }, -- [1]
                {
                    ["id"] = 468,
                    ["image"] = 607550,
                    ["name"] = "Die verschollenen Zwerge",
                }, -- [2]
                {
                    ["id"] = 469,
                    ["image"] = 607664,
                    ["name"] = "Ironaya",
                }, -- [3]
                {
                    ["id"] = 748,
                    ["image"] = 607729,
                    ["name"] = "Obsidianwächter",
                }, -- [4]
                {
                    ["id"] = 470,
                    ["image"] = 607538,
                    ["name"] = "Uralter Steinbewahrer",
                }, -- [5]
                {
                    ["id"] = 471,
                    ["image"] = 607606,
                    ["name"] = "Galgann Feuerhammer",
                }, -- [6]
                {
                    ["id"] = 472,
                    ["image"] = 607626,
                    ["name"] = "Grimlok",
                }, -- [7]
                {
                    ["id"] = 473,
                    ["image"] = 607546,
                    ["name"] = "Archaedas",
                }, -- [8]
            },
        }, -- [22]
        {
            ["id"] = 229,
            ["image"] = 608197,
            ["name"] = "Untere Schwarzfelsspitze",
            ["bosses"] = {
                {
                    ["id"] = 388,
                    ["image"] = 607645,
                    ["name"] = "Hochlord Omokk",
                }, -- [1]
                {
                    ["id"] = 389,
                    ["image"] = 607769,
                    ["name"] = "Schattenjägerin Vosh'gajin",
                }, -- [2]
                {
                    ["id"] = 390,
                    ["image"] = 607810,
                    ["name"] = "Kriegsmeister Voone",
                }, -- [3]
                {
                    ["id"] = 391,
                    ["image"] = 607719,
                    ["name"] = "Mutter Glimmernetz",
                }, -- [4]
                {
                    ["id"] = 392,
                    ["image"] = 607801,
                    ["name"] = "Urok Schreckensbote",
                }, -- [5]
                {
                    ["id"] = 393,
                    ["image"] = 607751,
                    ["name"] = "Rüstmeister Zigris",
                }, -- [6]
                {
                    ["id"] = 394,
                    ["image"] = 607634,
                    ["name"] = "Halycon",
                }, -- [7]
                {
                    ["id"] = 395,
                    ["image"] = 607615,
                    ["name"] = "Gizrul der Geifernde",
                }, -- [8]
                {
                    ["id"] = 396,
                    ["image"] = 607737,
                    ["name"] = "Oberanführer Wyrmthalak",
                }, -- [9]
            },
        }, -- [23]
        {
            ["id"] = 241,
            ["image"] = 608230,
            ["name"] = "Zul'Farrak",
            ["bosses"] = {
                {
                    ["id"] = 483,
                    ["image"] = 607614,
                    ["name"] = "Gahz'rilla",
                }, -- [1]
                {
                    ["id"] = 484,
                    ["image"] = 607541,
                    ["name"] = "Antu'sul",
                }, -- [2]
                {
                    ["id"] = 485,
                    ["image"] = 607793,
                    ["name"] = "Theka der Märtyrer",
                }, -- [3]
                {
                    ["id"] = 486,
                    ["image"] = 607819,
                    ["name"] = "Hexendoktor Zum'rah",
                }, -- [4]
                {
                    ["id"] = 487,
                    ["image"] = 607723,
                    ["name"] = "Nekrum und Sezz'ziz",
                }, -- [5]
                {
                    ["id"] = 489,
                    ["image"] = 607564,
                    ["name"] = "Häuptling Ukorz Sandskalp",
                }, -- [6]
            },
        }, -- [24]
    },
    ["Burning Crusade"] = {
        {
            ["id"] = 745,
            ["image"] = 1396584,
            ["name"] = "Karazhan",
            ["bosses"] = {
                {
                    ["id"] = 1552,
                    ["image"] = 1385766,
                    ["name"] = "Bedienstetenunterkünfte",
                }, -- [1]
                {
                    ["id"] = 1553,
                    ["image"] = 1378965,
                    ["name"] = "Attumen der Jäger",
                }, -- [2]
                {
                    ["id"] = 1554,
                    ["image"] = 1378999,
                    ["name"] = "Moroes",
                }, -- [3]
                {
                    ["id"] = 1555,
                    ["image"] = 1378997,
                    ["name"] = "Tugendhafte Maid",
                }, -- [4]
                {
                    ["id"] = 1556,
                    ["image"] = 1385758,
                    ["name"] = "Opernsaal",
                }, -- [5]
                {
                    ["id"] = 1557,
                    ["image"] = 1379020,
                    ["name"] = "Der Kurator",
                }, -- [6]
                {
                    ["id"] = 1559,
                    ["image"] = 1379012,
                    ["name"] = "Arans Schemen",
                }, -- [7]
                {
                    ["id"] = 1560,
                    ["image"] = 1379017,
                    ["name"] = "Terestian Siechhuf",
                }, -- [8]
                {
                    ["id"] = 1561,
                    ["image"] = 1379002,
                    ["name"] = "Nethergroll",
                }, -- [9]
                {
                    ["id"] = 1764,
                    ["image"] = 1385724,
                    ["name"] = "Das Schachspiel",
                }, -- [10]
                {
                    ["id"] = 1563,
                    ["image"] = 1379006,
                    ["name"] = "Prinz Malchezaar",
                }, -- [11]
            },
        }, -- [1]
        {
            ["id"] = 746,
            ["image"] = 1396582,
            ["name"] = "Gruuls Unterschlupf",
            ["bosses"] = {
                {
                    ["id"] = 1564,
                    ["image"] = 1378985,
                    ["name"] = "Hochkönig Maulgar",
                }, -- [1]
                {
                    ["id"] = 1565,
                    ["image"] = 1378982,
                    ["name"] = "Gruul der Drachenschlächter",
                }, -- [2]
            },
        }, -- [2]
        {
            ["id"] = 747,
            ["image"] = 1396585,
            ["name"] = "Magtheridons Kammer",
            ["bosses"] = {
                {
                    ["id"] = 1566,
                    ["image"] = 1378996,
                    ["name"] = "Magtheridon",
                }, -- [1]
            },
        }, -- [3]
        {
            ["id"] = 748,
            ["image"] = 608199,
            ["name"] = "Höhle des Schlangenschreins",
            ["bosses"] = {
                {
                    ["id"] = 1567,
                    ["image"] = 1385741,
                    ["name"] = "Hydross der Unstete",
                }, -- [1]
                {
                    ["id"] = 1568,
                    ["image"] = 1385768,
                    ["name"] = "Das Grauen aus der Tiefe",
                }, -- [2]
                {
                    ["id"] = 1569,
                    ["image"] = 1385751,
                    ["name"] = "Leotheras der Blinde",
                }, -- [3]
                {
                    ["id"] = 1570,
                    ["image"] = 1385729,
                    ["name"] = "Tiefenlord Karathress",
                }, -- [4]
                {
                    ["id"] = 1571,
                    ["image"] = 1385756,
                    ["name"] = "Morogrim Gezeitenwandler",
                }, -- [5]
                {
                    ["id"] = 1572,
                    ["image"] = 1385750,
                    ["name"] = "Lady Vashj",
                }, -- [6]
            },
        }, -- [4]
        {
            ["id"] = 749,
            ["image"] = 608218,
            ["name"] = "Das Auge",
            ["bosses"] = {
                {
                    ["id"] = 1573,
                    ["image"] = 1385712,
                    ["name"] = "Al'ar",
                }, -- [1]
                {
                    ["id"] = 1574,
                    ["image"] = 1385772,
                    ["name"] = "Leerhäscher",
                }, -- [2]
                {
                    ["id"] = 1575,
                    ["image"] = 1385739,
                    ["name"] = "Hochastromantin Solarian",
                }, -- [3]
                {
                    ["id"] = 1576,
                    ["image"] = 607669,
                    ["name"] = "Kael'thas Sonnenwanderer",
                }, -- [4]
            },
        }, -- [5]
        {
            ["id"] = 750,
            ["image"] = 608198,
            ["name"] = "Die Schlacht um den Hyjal",
            ["bosses"] = {
                {
                    ["id"] = 1577,
                    ["image"] = 1385762,
                    ["name"] = "Furor Winterfrost",
                }, -- [1]
                {
                    ["id"] = 1578,
                    ["image"] = 1385714,
                    ["name"] = "Anetheron",
                }, -- [2]
                {
                    ["id"] = 1579,
                    ["image"] = 1385745,
                    ["name"] = "Kaz'rogal",
                }, -- [3]
                {
                    ["id"] = 1580,
                    ["image"] = 1385719,
                    ["name"] = "Azgalor",
                }, -- [4]
                {
                    ["id"] = 1581,
                    ["image"] = 1385716,
                    ["name"] = "Archimonde",
                }, -- [5]
            },
        }, -- [6]
        {
            ["id"] = 751,
            ["image"] = 1396579,
            ["name"] = "Der Schwarze Tempel",
            ["bosses"] = {
                {
                    ["id"] = 1582,
                    ["image"] = 1378986,
                    ["name"] = "Oberster Kriegsfürst Naj'entus",
                }, -- [1]
                {
                    ["id"] = 1583,
                    ["image"] = 1379016,
                    ["name"] = "Supremus",
                }, -- [2]
                {
                    ["id"] = 1584,
                    ["image"] = 1379011,
                    ["name"] = "Akamas Schemen",
                }, -- [3]
                {
                    ["id"] = 1585,
                    ["image"] = 1379018,
                    ["name"] = "Teron Blutschatten",
                }, -- [4]
                {
                    ["id"] = 1586,
                    ["image"] = 1378983,
                    ["name"] = "Gurtogg Siedeblut",
                }, -- [5]
                {
                    ["id"] = 1587,
                    ["image"] = 1385764,
                    ["name"] = "Reliquiar der Seelen",
                }, -- [6]
                {
                    ["id"] = 1588,
                    ["image"] = 1379000,
                    ["name"] = "Mutter Shahraz",
                }, -- [7]
                {
                    ["id"] = 1589,
                    ["image"] = 1385743,
                    ["name"] = "Der Rat der Illidari",
                }, -- [8]
                {
                    ["id"] = 1590,
                    ["image"] = 1378987,
                    ["name"] = "Illidan Sturmgrimm",
                }, -- [9]
            },
        }, -- [7]
        {
            ["id"] = 752,
            ["image"] = 1396592,
            ["name"] = "Sonnenbrunnenplateau",
            ["bosses"] = {
                {
                    ["id"] = 1591,
                    ["image"] = 1385744,
                    ["name"] = "Kalecgos",
                }, -- [1]
                {
                    ["id"] = 1592,
                    ["image"] = 1385722,
                    ["name"] = "Brutallus",
                }, -- [2]
                {
                    ["id"] = 1593,
                    ["image"] = 1385730,
                    ["name"] = "Teufelsruch",
                }, -- [3]
                {
                    ["id"] = 1594,
                    ["image"] = 1390438,
                    ["name"] = "Die Eredarzwillinge",
                }, -- [4]
                {
                    ["id"] = 1595,
                    ["image"] = 1385757,
                    ["name"] = "M'uru",
                }, -- [5]
                {
                    ["id"] = 1596,
                    ["image"] = 1385746,
                    ["name"] = "Kil'jaeden",
                }, -- [6]
            },
        }, -- [8]
        {
            ["id"] = 247,
            ["image"] = 608193,
            ["name"] = "Auchenaikrypta",
            ["bosses"] = {
                {
                    ["id"] = 523,
                    ["image"] = 607771,
                    ["name"] = "Shirrak der Totenwächter",
                }, -- [1]
                {
                    ["id"] = 524,
                    ["image"] = 607600,
                    ["name"] = "Exarch Maladaar",
                }, -- [2]
            },
        }, -- [9]
        {
            ["id"] = 256,
            ["image"] = 608207,
            ["name"] = "Der Blutkessel",
            ["bosses"] = {
                {
                    ["id"] = 555,
                    ["image"] = 607789,
                    ["name"] = "Der Schöpfer",
                }, -- [1]
                {
                    ["id"] = 556,
                    ["image"] = 607558,
                    ["name"] = "Broggok",
                }, -- [2]
                {
                    ["id"] = 557,
                    ["image"] = 607670,
                    ["name"] = "Keli'dan der Zerstörer",
                }, -- [3]
            },
        }, -- [10]
        {
            ["id"] = 255,
            ["image"] = 608198,
            ["name"] = "Der Schwarze Morast",
            ["bosses"] = {
                {
                    ["id"] = 552,
                    ["image"] = 607566,
                    ["name"] = "Chronolord Deja",
                }, -- [1]
                {
                    ["id"] = 553,
                    ["image"] = 607784,
                    ["name"] = "Temporus",
                }, -- [2]
                {
                    ["id"] = 554,
                    ["image"] = 607529,
                    ["name"] = "Aeonus",
                }, -- [3]
            },
        }, -- [11]
        {
            ["id"] = 262,
            ["image"] = 608199,
            ["name"] = "Der Tiefensumpf",
            ["bosses"] = {
                {
                    ["id"] = 576,
                    ["image"] = 607649,
                    ["name"] = "Hungarfenn",
                }, -- [1]
                {
                    ["id"] = 577,
                    ["image"] = 607614,
                    ["name"] = "Ghaz'an",
                }, -- [2]
                {
                    ["id"] = 578,
                    ["image"] = 607779,
                    ["name"] = "Sumpffürst Musel'ek",
                }, -- [3]
                {
                    ["id"] = 579,
                    ["image"] = 607788,
                    ["name"] = "Die Schattenmutter",
                }, -- [4]
            },
        }, -- [12]
        {
            ["id"] = 254,
            ["image"] = 608218,
            ["name"] = "Die Arkatraz",
            ["bosses"] = {
                {
                    ["id"] = 548,
                    ["image"] = 607823,
                    ["name"] = "Zereketh der Unabhängige",
                }, -- [1]
                {
                    ["id"] = 549,
                    ["image"] = 607574,
                    ["name"] = "Dalliah die Verdammnisverkünderin",
                }, -- [2]
                {
                    ["id"] = 550,
                    ["image"] = 607820,
                    ["name"] = "Zornseher Soccothrates",
                }, -- [3]
                {
                    ["id"] = 551,
                    ["image"] = 607635,
                    ["name"] = "Herold Horizontiss",
                }, -- [4]
            },
        }, -- [13]
        {
            ["id"] = 257,
            ["image"] = 608218,
            ["name"] = "Die Botanika",
            ["bosses"] = {
                {
                    ["id"] = 558,
                    ["image"] = 607570,
                    ["name"] = "Kommandantin Sarannis",
                }, -- [1]
                {
                    ["id"] = 559,
                    ["image"] = 607641,
                    ["name"] = "Hochbotaniker Freywinn",
                }, -- [2]
                {
                    ["id"] = 560,
                    ["image"] = 607794,
                    ["name"] = "Dorngrin der Hüter",
                }, -- [3]
                {
                    ["id"] = 561,
                    ["image"] = 607683,
                    ["name"] = "Laj",
                }, -- [4]
                {
                    ["id"] = 562,
                    ["image"] = 607816,
                    ["name"] = "Warpzweig",
                }, -- [5]
            },
        }, -- [14]
        {
            ["id"] = 261,
            ["image"] = 608199,
            ["name"] = "Die Dampfkammer",
            ["bosses"] = {
                {
                    ["id"] = 573,
                    ["image"] = 607651,
                    ["name"] = "Hydromantin Thespia",
                }, -- [1]
                {
                    ["id"] = 574,
                    ["image"] = 607713,
                    ["name"] = "Robogenieur Dampfhammer",
                }, -- [2]
                {
                    ["id"] = 575,
                    ["image"] = 607815,
                    ["name"] = "Kriegsherr Kalithresh",
                }, -- [3]
            },
        }, -- [15]
        {
            ["id"] = 258,
            ["image"] = 608218,
            ["name"] = "Die Mechanar",
            ["bosses"] = {
                {
                    ["id"] = 563,
                    ["image"] = 607712,
                    ["name"] = "Mechanolord Kapazitus",
                }, -- [1]
                {
                    ["id"] = 564,
                    ["image"] = 607725,
                    ["name"] = "Nethermantin Sepethrea",
                }, -- [2]
                {
                    ["id"] = 565,
                    ["image"] = 607739,
                    ["name"] = "Pathaleon der Kalkulator",
                }, -- [3]
            },
        }, -- [16]
        {
            ["id"] = 260,
            ["image"] = 608199,
            ["name"] = "Die Sklavenunterkünfte",
            ["bosses"] = {
                {
                    ["id"] = 570,
                    ["image"] = 607715,
                    ["name"] = "Mennu der Verräter",
                }, -- [1]
                {
                    ["id"] = 571,
                    ["image"] = 607759,
                    ["name"] = "Rokmar der Zerquetscher",
                }, -- [2]
                {
                    ["id"] = 572,
                    ["image"] = 607750,
                    ["name"] = "Quagmirran",
                }, -- [3]
            },
        }, -- [17]
        {
            ["id"] = 259,
            ["image"] = 608207,
            ["name"] = "Die Zerschmetterten Hallen",
            ["bosses"] = {
                {
                    ["id"] = 566,
                    ["image"] = 607624,
                    ["name"] = "Großhexenmeister Nethekurse",
                }, -- [1]
                {
                    ["id"] = 568,
                    ["image"] = 607811,
                    ["name"] = "Kriegshetzer O'mrogg",
                }, -- [2]
                {
                    ["id"] = 569,
                    ["image"] = 607812,
                    ["name"] = "Kriegshäuptling Kargath Messerfaust",
                }, -- [3]
            },
        }, -- [18]
        {
            ["id"] = 248,
            ["image"] = 608207,
            ["name"] = "Höllenfeuerbollwerk",
            ["bosses"] = {
                {
                    ["id"] = 527,
                    ["image"] = 607817,
                    ["name"] = "Wachhabender Gargolmar",
                }, -- [1]
                {
                    ["id"] = 528,
                    ["image"] = 607734,
                    ["name"] = "Omor der Narbenlose",
                }, -- [2]
                {
                    ["id"] = 529,
                    ["image"] = 607803,
                    ["name"] = "Vazruden der Herold",
                }, -- [3]
            },
        }, -- [19]
        {
            ["id"] = 250,
            ["image"] = 608193,
            ["name"] = "Managruft",
            ["bosses"] = {
                {
                    ["id"] = 534,
                    ["image"] = 607738,
                    ["name"] = "Pandemonius",
                }, -- [1]
                {
                    ["id"] = 535,
                    ["image"] = 607782,
                    ["name"] = "Tavarok",
                }, -- [2]
                {
                    ["id"] = 537,
                    ["image"] = 607726,
                    ["name"] = "Nexusprinz Shaffar",
                }, -- [3]
            },
        }, -- [20]
        {
            ["id"] = 253,
            ["image"] = 608193,
            ["name"] = "Schattenlabyrinth",
            ["bosses"] = {
                {
                    ["id"] = 544,
                    ["image"] = 607536,
                    ["name"] = "Botschafter Höllenschlund",
                }, -- [1]
                {
                    ["id"] = 545,
                    ["image"] = 607555,
                    ["name"] = "Schwarzherz der Hetzer",
                }, -- [2]
                {
                    ["id"] = 546,
                    ["image"] = 607625,
                    ["name"] = "Großmeister Vorpil",
                }, -- [3]
                {
                    ["id"] = 547,
                    ["image"] = 607720,
                    ["name"] = "Murmur",
                }, -- [4]
            },
        }, -- [21]
        {
            ["id"] = 252,
            ["image"] = 608193,
            ["name"] = "Sethekkhallen",
            ["bosses"] = {
                {
                    ["id"] = 541,
                    ["image"] = 607583,
                    ["name"] = "Dunkelwirker Syth",
                }, -- [1]
                {
                    ["id"] = 543,
                    ["image"] = 607780,
                    ["name"] = "Klauenkönig Ikiss",
                }, -- [2]
            },
        }, -- [22]
        {
            ["id"] = 249,
            ["image"] = 608208,
            ["name"] = "Terrasse der Magister",
            ["bosses"] = {
                {
                    ["id"] = 530,
                    ["image"] = 607767,
                    ["name"] = "Selin Feuerherz",
                }, -- [1]
                {
                    ["id"] = 531,
                    ["image"] = 607806,
                    ["name"] = "Vexallus",
                }, -- [2]
                {
                    ["id"] = 532,
                    ["image"] = 607742,
                    ["name"] = "Priesterin Delrissa",
                }, -- [3]
                {
                    ["id"] = 533,
                    ["image"] = 607669,
                    ["name"] = "Kael'thas Sonnenwanderer",
                }, -- [4]
            },
        }, -- [23]
        {
            ["id"] = 251,
            ["image"] = 608198,
            ["name"] = "Vorgebirge des Alten Hügellands",
            ["bosses"] = {
                {
                    ["id"] = 538,
                    ["image"] = 607689,
                    ["name"] = "Leutnant Drach",
                }, -- [1]
                {
                    ["id"] = 539,
                    ["image"] = 607561,
                    ["name"] = "Hauptmann Skarloc",
                }, -- [2]
                {
                    ["id"] = 540,
                    ["image"] = 607596,
                    ["name"] = "Epochenjäger",
                }, -- [3]
            },
        }, -- [24]
    },
    ["Dragonflight"] = {
        {
            ["id"] = 1205,
            ["image"] = 4742925,
            ["name"] = "Dracheninseln",
            ["bosses"] = {
                {
                    ["id"] = 2515,
                    ["image"] = 4757700,
                    ["name"] = "Strunraan, Elend des Himmels",
                }, -- [1]
                {
                    ["id"] = 2506,
                    ["image"] = 4757691,
                    ["name"] = "Basrikron, der Schieferflügel",
                }, -- [2]
                {
                    ["id"] = 2517,
                    ["image"] = 4757692,
                    ["name"] = "Bazual, die gefürchtete Flamme",
                }, -- [3]
                {
                    ["id"] = 2518,
                    ["image"] = 4757697,
                    ["name"] = "Liskanoth, Schrecken der Zukunft",
                }, -- [4]
                {
                    ["id"] = 2531,
                    ["image"] = 5151696,
                    ["name"] = "Die Ältesten der Zaqali",
                }, -- [5]
            },
        }, -- [1]
        {
            ["id"] = 1200,
            ["image"] = 4742931,
            ["name"] = "Gewölbe der Inkarnationen",
            ["bosses"] = {
                {
                    ["id"] = 2480,
                    ["image"] = 4757695,
                    ["name"] = "Eranog",
                }, -- [1]
                {
                    ["id"] = 2500,
                    ["image"] = 4757701,
                    ["name"] = "Terros",
                }, -- [2]
                {
                    ["id"] = 2486,
                    ["image"] = 4757702,
                    ["name"] = "Der Primalistenrat",
                }, -- [3]
                {
                    ["id"] = 2482,
                    ["image"] = 4757699,
                    ["name"] = "Sennarth, der kalte Atem",
                }, -- [4]
                {
                    ["id"] = 2502,
                    ["image"] = 4757694,
                    ["name"] = "Dathea, die Aufgestiegene",
                }, -- [5]
                {
                    ["id"] = 2491,
                    ["image"] = 4757696,
                    ["name"] = "Kurog Grimmtotem",
                }, -- [6]
                {
                    ["id"] = 2493,
                    ["image"] = 4757693,
                    ["name"] = "Bruthüterin Diurna",
                }, -- [7]
                {
                    ["id"] = 2499,
                    ["image"] = 4757698,
                    ["name"] = "Raszageth die Sturmfresserin",
                }, -- [8]
            },
        }, -- [2]
        {
            ["id"] = 1208,
            ["image"] = 5149418,
            ["name"] = "Aberrus, Schmelztiegel der Schatten",
            ["bosses"] = {
                {
                    ["id"] = 2522,
                    ["image"] = 5151370,
                    ["name"] = "Kazzara, die Höllengeschmiedete",
                }, -- [1]
                {
                    ["id"] = 2529,
                    ["image"] = 5151374,
                    ["name"] = "Die Verschmelzungskammer",
                }, -- [2]
                {
                    ["id"] = 2530,
                    ["image"] = 5151375,
                    ["name"] = "Die vergessenen Experimente",
                }, -- [3]
                {
                    ["id"] = 2524,
                    ["image"] = 5151368,
                    ["name"] = "Angriff der Zaqali",
                }, -- [4]
                {
                    ["id"] = 2525,
                    ["image"] = 5151372,
                    ["name"] = "Ältester Rashok",
                }, -- [5]
                {
                    ["id"] = 2532,
                    ["image"] = 5151376,
                    ["name"] = "Der aufmerksame Verwalter, Zskarn",
                }, -- [6]
                {
                    ["id"] = 2527,
                    ["image"] = 5151371,
                    ["name"] = "Magmorax",
                }, -- [7]
                {
                    ["id"] = 2523,
                    ["image"] = 5151369,
                    ["name"] = "Echo von Neltharion",
                }, -- [8]
                {
                    ["id"] = 2520,
                    ["image"] = 5151373,
                    ["name"] = "Schuppenkommandant Sarkareth",
                }, -- [9]
            },
        }, -- [3]
        {
            ["id"] = 1209,
            ["image"] = 5221768,
            ["name"] = "Dämmerung des Ewigen",
            ["bosses"] = {
                {
                    ["id"] = 2521,
                    ["image"] = 5221761,
                    ["name"] = "Chronikar",
                }, -- [1]
                {
                    ["id"] = 2528,
                    ["image"] = 5221766,
                    ["name"] = "Manifestierte Zeitwege",
                }, -- [2]
                {
                    ["id"] = 2535,
                    ["image"] = 5221760,
                    ["name"] = "Verseuchung von Galakrond",
                }, -- [3]
                {
                    ["id"] = 2537,
                    ["image"] = 5221765,
                    ["name"] = "Iridikron der Steingeschuppte",
                }, -- [4]
                {
                    ["id"] = 2526,
                    ["image"] = 5221764,
                    ["name"] = "Tyr, der ewige Hüter",
                }, -- [5]
                {
                    ["id"] = 2536,
                    ["image"] = 5221767,
                    ["name"] = "Morchie",
                }, -- [6]
                {
                    ["id"] = 2534,
                    ["image"] = 5221759,
                    ["name"] = "Zeitverlorenes Schlachtfeld",
                }, -- [7]
                {
                    ["id"] = 2538,
                    ["image"] = 4741507,
                    ["name"] = "Chronolord Deios",
                }, -- [8]
            },
        }, -- [4]
        {
            ["id"] = 1201,
            ["image"] = 4742929,
            ["name"] = "Akademie von Algeth'ar",
            ["bosses"] = {
                {
                    ["id"] = 2509,
                    ["image"] = 4741534,
                    ["name"] = "Vexamus",
                }, -- [1]
                {
                    ["id"] = 2512,
                    ["image"] = 4741524,
                    ["name"] = "Überwuchertes Urtum",
                }, -- [2]
                {
                    ["id"] = 2495,
                    ["image"] = 4741508,
                    ["name"] = "Kraas",
                }, -- [3]
                {
                    ["id"] = 2514,
                    ["image"] = 4741510,
                    ["name"] = "Echo von Doragosa",
                }, -- [4]
            },
        }, -- [5]
        {
            ["id"] = 1196,
            ["image"] = 4742923,
            ["name"] = "Brackenfellhöhle",
            ["bosses"] = {
                {
                    ["id"] = 2471,
                    ["image"] = 4741526,
                    ["name"] = "Hackklaues Kriegsmeute",
                }, -- [1]
                {
                    ["id"] = 2473,
                    ["image"] = 4741532,
                    ["name"] = "Baummaul",
                }, -- [2]
                {
                    ["id"] = 2472,
                    ["image"] = 4741518,
                    ["name"] = "Bauchschuss",
                }, -- [3]
                {
                    ["id"] = 2474,
                    ["image"] = 4741509,
                    ["name"] = "Faultriarchin Zornauge",
                }, -- [4]
            },
        }, -- [6]
        {
            ["id"] = 1204,
            ["image"] = 4742926,
            ["name"] = "Hallen der Infusion",
            ["bosses"] = {
                {
                    ["id"] = 2504,
                    ["image"] = 4741536,
                    ["name"] = "Hüter Irideus",
                }, -- [1]
                {
                    ["id"] = 2507,
                    ["image"] = 4741516,
                    ["name"] = "Schlingender Goliath",
                }, -- [2]
                {
                    ["id"] = 2510,
                    ["image"] = 4741519,
                    ["name"] = "Khajin die Unbeugsame",
                }, -- [3]
                {
                    ["id"] = 2511,
                    ["image"] = 4741525,
                    ["name"] = "Urtümlicher Tsunami",
                }, -- [4]
            },
        }, -- [7]
        {
            ["id"] = 1199,
            ["image"] = 4742928,
            ["name"] = "Neltharus",
            ["bosses"] = {
                {
                    ["id"] = 2490,
                    ["image"] = 4741506,
                    ["name"] = "Chargath der Schuppenschrecken",
                }, -- [1]
                {
                    ["id"] = 2489,
                    ["image"] = 4741513,
                    ["name"] = "Schmiedemeister Gorek",
                }, -- [2]
                {
                    ["id"] = 2494,
                    ["image"] = 4741522,
                    ["name"] = "Magmahauer",
                }, -- [3]
                {
                    ["id"] = 2501,
                    ["image"] = 4741535,
                    ["name"] = "Kriegsfürstin Sargha",
                }, -- [4]
            },
        }, -- [8]
        {
            ["id"] = 1202,
            ["image"] = 4742927,
            ["name"] = "Rubinlebensbecken",
            ["bosses"] = {
                {
                    ["id"] = 2488,
                    ["image"] = 4741523,
                    ["name"] = "Melidrussa die Unterkühlte",
                }, -- [1]
                {
                    ["id"] = 2485,
                    ["image"] = 4741520,
                    ["name"] = "Kokia Feuerhuf",
                }, -- [2]
                {
                    ["id"] = 2503,
                    ["image"] = 4867810,
                    ["name"] = "Kyrakka und Erkhart Sturmader",
                }, -- [3]
            },
        }, -- [9]
        {
            ["id"] = 1203,
            ["image"] = 4742829,
            ["name"] = "Das Azurblaue Gewölbe",
            ["bosses"] = {
                {
                    ["id"] = 2492,
                    ["image"] = 4741521,
                    ["name"] = "Leymor",
                }, -- [1]
                {
                    ["id"] = 2505,
                    ["image"] = 4741503,
                    ["name"] = "Azurklinge",
                }, -- [2]
                {
                    ["id"] = 2483,
                    ["image"] = 4741529,
                    ["name"] = "Telash Grauschwinge",
                }, -- [3]
                {
                    ["id"] = 2508,
                    ["image"] = 4741533,
                    ["name"] = "Umbrelskul",
                }, -- [4]
            },
        }, -- [10]
        {
            ["id"] = 1198,
            ["image"] = 4742924,
            ["name"] = "Der Angriff der Nokhud",
            ["bosses"] = {
                {
                    ["id"] = 2498,
                    ["image"] = 4741514,
                    ["name"] = "Granyth",
                }, -- [1]
                {
                    ["id"] = 2497,
                    ["image"] = 4741531,
                    ["name"] = "Der wütende Gewittersturm",
                }, -- [2]
                {
                    ["id"] = 2478,
                    ["image"] = 4741528,
                    ["name"] = "Teera und Maruuk",
                }, -- [3]
                {
                    ["id"] = 2477,
                    ["image"] = 4741504,
                    ["name"] = "Balakar Khan",
                }, -- [4]
            },
        }, -- [11]
        {
            ["id"] = 1197,
            ["image"] = 4742930,
            ["name"] = "Uldaman: Vermächtnis von Tyr",
            ["bosses"] = {
                {
                    ["id"] = 2475,
                    ["image"] = 4741530,
                    ["name"] = "Die verschollenen Zwerge",
                }, -- [1]
                {
                    ["id"] = 2487,
                    ["image"] = 4741505,
                    ["name"] = "Bromach",
                }, -- [2]
                {
                    ["id"] = 2484,
                    ["image"] = 4741527,
                    ["name"] = "Schildwache Kralldras",
                }, -- [3]
                {
                    ["id"] = 2476,
                    ["image"] = 4741511,
                    ["name"] = "Ascheron",
                }, -- [4]
                {
                    ["id"] = 2479,
                    ["image"] = 4741507,
                    ["name"] = "Chronolord Deios",
                }, -- [5]
            },
        }, -- [12]
    },
    ["Legion"] = {
        {
            ["id"] = 822,
            ["image"] = 1411854,
            ["name"] = "Die Verheerten Inseln",
            ["bosses"] = {
                {
                    ["id"] = 1790,
                    ["image"] = 1411023,
                    ["name"] = "Ana-Mouz",
                }, -- [1]
                {
                    ["id"] = 1956,
                    ["image"] = 1134499,
                    ["name"] = "Apocron",
                }, -- [2]
                {
                    ["id"] = 1883,
                    ["image"] = 1385722,
                    ["name"] = "Brutallus",
                }, -- [3]
                {
                    ["id"] = 1774,
                    ["image"] = 1411024,
                    ["name"] = "Calamir",
                }, -- [4]
                {
                    ["id"] = 1789,
                    ["image"] = 1411025,
                    ["name"] = "Drugon der Frostblütige",
                }, -- [5]
                {
                    ["id"] = 1795,
                    ["image"] = 1472454,
                    ["name"] = "Treibgut",
                }, -- [6]
                {
                    ["id"] = 1770,
                    ["image"] = 1411026,
                    ["name"] = "Humongris",
                }, -- [7]
                {
                    ["id"] = 1769,
                    ["image"] = 1411027,
                    ["name"] = "Levantus",
                }, -- [8]
                {
                    ["id"] = 1884,
                    ["image"] = 1579937,
                    ["name"] = "Malificus",
                }, -- [9]
                {
                    ["id"] = 1783,
                    ["image"] = 1411028,
                    ["name"] = "Na'zak das Scheusal",
                }, -- [10]
                {
                    ["id"] = 1749,
                    ["image"] = 1411029,
                    ["name"] = "Nithogg",
                }, -- [11]
                {
                    ["id"] = 1763,
                    ["image"] = 1411030,
                    ["name"] = "Shar'thos",
                }, -- [12]
                {
                    ["id"] = 1885,
                    ["image"] = 1579941,
                    ["name"] = "Si'vash",
                }, -- [13]
                {
                    ["id"] = 1756,
                    ["image"] = 1411031,
                    ["name"] = "Die Seelenräuber",
                }, -- [14]
                {
                    ["id"] = 1796,
                    ["image"] = 1472455,
                    ["name"] = "Verdorrter J'im",
                }, -- [15]
            },
        }, -- [1]
        {
            ["id"] = 768,
            ["image"] = 1452687,
            ["name"] = "Der Smaragdgrüne Alptraum",
            ["bosses"] = {
                {
                    ["id"] = 1703,
                    ["image"] = 1410972,
                    ["name"] = "Nythendra",
                }, -- [1]
                {
                    ["id"] = 1738,
                    ["image"] = 1410960,
                    ["name"] = "Il'gynoth, Herz der Verderbnis",
                }, -- [2]
                {
                    ["id"] = 1744,
                    ["image"] = 1410947,
                    ["name"] = "Elerethe Renferal",
                }, -- [3]
                {
                    ["id"] = 1667,
                    ["image"] = 1410991,
                    ["name"] = "Ursoc",
                }, -- [4]
                {
                    ["id"] = 1704,
                    ["image"] = 1410945,
                    ["name"] = "Drachen des Alptraums",
                }, -- [5]
                {
                    ["id"] = 1750,
                    ["image"] = 1410940,
                    ["name"] = "Cenarius",
                }, -- [6]
                {
                    ["id"] = 1726,
                    ["image"] = 1410994,
                    ["name"] = "Xavius",
                }, -- [7]
            },
        }, -- [2]
        {
            ["id"] = 861,
            ["image"] = 1537284,
            ["name"] = "Die Prüfung der Tapferkeit",
            ["bosses"] = {
                {
                    ["id"] = 1819,
                    ["image"] = 1410974,
                    ["name"] = "Odyn",
                }, -- [1]
                {
                    ["id"] = 1830,
                    ["image"] = 1536491,
                    ["name"] = "Guarm",
                }, -- [2]
                {
                    ["id"] = 1829,
                    ["image"] = 1410957,
                    ["name"] = "Helya",
                }, -- [3]
            },
        }, -- [3]
        {
            ["id"] = 786,
            ["image"] = 1450575,
            ["name"] = "Die Nachtfestung",
            ["bosses"] = {
                {
                    ["id"] = 1706,
                    ["image"] = 1410981,
                    ["name"] = "Skorpyron",
                }, -- [1]
                {
                    ["id"] = 1725,
                    ["image"] = 1410941,
                    ["name"] = "Chronomatische Anomalie",
                }, -- [2]
                {
                    ["id"] = 1731,
                    ["image"] = 1410989,
                    ["name"] = "Trilliax",
                }, -- [3]
                {
                    ["id"] = 1751,
                    ["image"] = 1410983,
                    ["name"] = "Aluriel die Zauberklinge",
                }, -- [4]
                {
                    ["id"] = 1762,
                    ["image"] = 1410987,
                    ["name"] = "Tichondrius",
                }, -- [5]
                {
                    ["id"] = 1713,
                    ["image"] = 1410965,
                    ["name"] = "Krosus",
                }, -- [6]
                {
                    ["id"] = 1761,
                    ["image"] = 1410939,
                    ["name"] = "Hochbotaniker Tel'arn",
                }, -- [7]
                {
                    ["id"] = 1732,
                    ["image"] = 1410984,
                    ["name"] = "Sterndeuter Etraeus",
                }, -- [8]
                {
                    ["id"] = 1743,
                    ["image"] = 1410954,
                    ["name"] = "Großmagistrix Elisande",
                }, -- [9]
                {
                    ["id"] = 1737,
                    ["image"] = 1410955,
                    ["name"] = "Gul'dan",
                }, -- [10]
            },
        }, -- [4]
        {
            ["id"] = 875,
            ["image"] = 1616106,
            ["name"] = "Das Grabmal des Sargeras",
            ["bosses"] = {
                {
                    ["id"] = 1862,
                    ["image"] = 1579934,
                    ["name"] = "Goroth",
                }, -- [1]
                {
                    ["id"] = 1867,
                    ["image"] = 1579936,
                    ["name"] = "Dämonische Inquisition",
                }, -- [2]
                {
                    ["id"] = 1856,
                    ["image"] = 1579940,
                    ["name"] = "Harjatan",
                }, -- [3]
                {
                    ["id"] = 1903,
                    ["image"] = 1579935,
                    ["name"] = "Schwestern des Mondes",
                }, -- [4]
                {
                    ["id"] = 1861,
                    ["image"] = 1579939,
                    ["name"] = "Herrin Sassz'ine",
                }, -- [5]
                {
                    ["id"] = 1896,
                    ["image"] = 1579943,
                    ["name"] = "Die trostlose Heerschar",
                }, -- [6]
                {
                    ["id"] = 1897,
                    ["image"] = 1579933,
                    ["name"] = "Wachsame Maid",
                }, -- [7]
                {
                    ["id"] = 1873,
                    ["image"] = 1579932,
                    ["name"] = "Gefallener Avatar",
                }, -- [8]
                {
                    ["id"] = 1898,
                    ["image"] = 1385746,
                    ["name"] = "Kil'jaeden",
                }, -- [9]
            },
        }, -- [5]
        {
            ["id"] = 946,
            ["image"] = 1718211,
            ["name"] = "Antorus, der Brennende Thron",
            ["bosses"] = {
                {
                    ["id"] = 1992,
                    ["image"] = 1715210,
                    ["name"] = "Weltenbrecher der Garothi",
                }, -- [1]
                {
                    ["id"] = 1987,
                    ["image"] = 1715209,
                    ["name"] = "Teufelshunde des Sargeras",
                }, -- [2]
                {
                    ["id"] = 1997,
                    ["image"] = 1715225,
                    ["name"] = "Antorisches Oberkommando",
                }, -- [3]
                {
                    ["id"] = 1985,
                    ["image"] = 1715219,
                    ["name"] = "Portalhüterin Hasabel",
                }, -- [4]
                {
                    ["id"] = 2025,
                    ["image"] = 1715208,
                    ["name"] = "Eonar die Lebensbinderin",
                }, -- [5]
                {
                    ["id"] = 2009,
                    ["image"] = 1715211,
                    ["name"] = "Imonar der Seelenjäger",
                }, -- [6]
                {
                    ["id"] = 2004,
                    ["image"] = 1715213,
                    ["name"] = "Kin'garoth",
                }, -- [7]
                {
                    ["id"] = 1983,
                    ["image"] = 1715223,
                    ["name"] = "Varimathras",
                }, -- [8]
                {
                    ["id"] = 1986,
                    ["image"] = 1715222,
                    ["name"] = "Der Zirkel der Shivarra",
                }, -- [9]
                {
                    ["id"] = 1984,
                    ["image"] = 1715207,
                    ["name"] = "Aggramar",
                }, -- [10]
                {
                    ["id"] = 2031,
                    ["image"] = 1715536,
                    ["name"] = "Argus, der Zerrütter",
                }, -- [11]
            },
        }, -- [6]
        {
            ["id"] = 959,
            ["image"] = 1718212,
            ["name"] = "Invasionspunkte",
            ["bosses"] = {
                {
                    ["id"] = 2010,
                    ["image"] = 1715215,
                    ["name"] = "Matrone Folnuna",
                }, -- [1]
                {
                    ["id"] = 2011,
                    ["image"] = 1715216,
                    ["name"] = "Herrin Alluradel",
                }, -- [2]
                {
                    ["id"] = 2012,
                    ["image"] = 1715212,
                    ["name"] = "Inquisitor Meto",
                }, -- [3]
                {
                    ["id"] = 2013,
                    ["image"] = 1715217,
                    ["name"] = "Occularus",
                }, -- [4]
                {
                    ["id"] = 2014,
                    ["image"] = 1715221,
                    ["name"] = "Sotanathor",
                }, -- [5]
                {
                    ["id"] = 2015,
                    ["image"] = 1715218,
                    ["name"] = "Grubenlord Vilemus",
                }, -- [6]
            },
        }, -- [7]
        {
            ["id"] = 716,
            ["image"] = 1498157,
            ["name"] = "Das Auge Azsharas",
            ["bosses"] = {
                {
                    ["id"] = 1480,
                    ["image"] = 1410992,
                    ["name"] = "Kriegsherr Parjesh",
                }, -- [1]
                {
                    ["id"] = 1490,
                    ["image"] = 1410966,
                    ["name"] = "Lady Hassnatter",
                }, -- [2]
                {
                    ["id"] = 1491,
                    ["image"] = 1410964,
                    ["name"] = "König Klafterbart",
                }, -- [3]
                {
                    ["id"] = 1479,
                    ["image"] = 1410978,
                    ["name"] = "Serpentrix",
                }, -- [4]
                {
                    ["id"] = 1492,
                    ["image"] = 1410993,
                    ["name"] = "Azsharas Zorn",
                }, -- [5]
            },
        }, -- [8]
        {
            ["id"] = 762,
            ["image"] = 1411855,
            ["name"] = "Das Finsterherzdickicht",
            ["bosses"] = {
                {
                    ["id"] = 1654,
                    ["image"] = 1410936,
                    ["name"] = "Erzdruide Glaidalis",
                }, -- [1]
                {
                    ["id"] = 1655,
                    ["image"] = 1410973,
                    ["name"] = "Eichenherz",
                }, -- [2]
                {
                    ["id"] = 1656,
                    ["image"] = 1410946,
                    ["name"] = "Dresaron",
                }, -- [3]
                {
                    ["id"] = 1657,
                    ["image"] = 1410979,
                    ["name"] = "Schemen von Xavius",
                }, -- [4]
            },
        }, -- [9]
        {
            ["id"] = 707,
            ["image"] = 1411858,
            ["name"] = "Das Verlies der Wächterinnen",
            ["bosses"] = {
                {
                    ["id"] = 1467,
                    ["image"] = 1410988,
                    ["name"] = "Tirathon Saltheril",
                }, -- [1]
                {
                    ["id"] = 1695,
                    ["image"] = 1410962,
                    ["name"] = "Inquisitor Foltyrium",
                }, -- [2]
                {
                    ["id"] = 1468,
                    ["image"] = 1410937,
                    ["name"] = "Ash'Golm",
                }, -- [3]
                {
                    ["id"] = 1469,
                    ["image"] = 1410952,
                    ["name"] = "Der Starrer",
                }, -- [4]
                {
                    ["id"] = 1470,
                    ["image"] = 1410942,
                    ["name"] = "Cordana Teufelsang",
                }, -- [5]
            },
        }, -- [10]
        {
            ["id"] = 726,
            ["image"] = 1411857,
            ["name"] = "Der Arkus",
            ["bosses"] = {
                {
                    ["id"] = 1497,
                    ["image"] = 1410963,
                    ["name"] = "Ivanyr",
                }, -- [1]
                {
                    ["id"] = 1498,
                    ["image"] = 1410943,
                    ["name"] = "Corstilax",
                }, -- [2]
                {
                    ["id"] = 1499,
                    ["image"] = 1410951,
                    ["name"] = "General Xakal",
                }, -- [3]
                {
                    ["id"] = 1500,
                    ["image"] = 1410970,
                    ["name"] = "Nal'tira",
                }, -- [4]
                {
                    ["id"] = 1501,
                    ["image"] = 1410934,
                    ["name"] = "Berater Vandros",
                }, -- [5]
            },
        }, -- [11]
        {
            ["id"] = 800,
            ["image"] = 1498156,
            ["name"] = "Der Hof der Sterne",
            ["bosses"] = {
                {
                    ["id"] = 1718,
                    ["image"] = 1410975,
                    ["name"] = "Patrouillenoffizier Gerdo",
                }, -- [1]
                {
                    ["id"] = 1719,
                    ["image"] = 1410985,
                    ["name"] = "Talixae Flammenkranz",
                }, -- [2]
                {
                    ["id"] = 1720,
                    ["image"] = 1410933,
                    ["name"] = "Berater Melandrus",
                }, -- [3]
            },
        }, -- [12]
        {
            ["id"] = 727,
            ["image"] = 1411856,
            ["name"] = "Der Seelenschlund",
            ["bosses"] = {
                {
                    ["id"] = 1502,
                    ["image"] = 1410995,
                    ["name"] = "Ymiron, der gefallene König",
                }, -- [1]
                {
                    ["id"] = 1512,
                    ["image"] = 1410956,
                    ["name"] = "Harbaron",
                }, -- [2]
                {
                    ["id"] = 1663,
                    ["image"] = 1410957,
                    ["name"] = "Helya",
                }, -- [3]
            },
        }, -- [13]
        {
            ["id"] = 721,
            ["image"] = 1498158,
            ["name"] = "Die Hallen der Tapferkeit",
            ["bosses"] = {
                {
                    ["id"] = 1485,
                    ["image"] = 1410958,
                    ["name"] = "Hymdall",
                }, -- [1]
                {
                    ["id"] = 1486,
                    ["image"] = 1410959,
                    ["name"] = "Hyrja",
                }, -- [2]
                {
                    ["id"] = 1487,
                    ["image"] = 1410949,
                    ["name"] = "Fenryr",
                }, -- [3]
                {
                    ["id"] = 1488,
                    ["image"] = 1410953,
                    ["name"] = "Gottkönig Skovald",
                }, -- [4]
                {
                    ["id"] = 1489,
                    ["image"] = 1410974,
                    ["name"] = "Odyn",
                }, -- [5]
            },
        }, -- [14]
        {
            ["id"] = 900,
            ["image"] = 1616922,
            ["name"] = "Die Kathedrale der Ewigen Nacht",
            ["bosses"] = {
                {
                    ["id"] = 1905,
                    ["image"] = 1579930,
                    ["name"] = "Agronox",
                }, -- [1]
                {
                    ["id"] = 1906,
                    ["image"] = 1579942,
                    ["name"] = "Dreschzahn der Spöttische",
                }, -- [2]
                {
                    ["id"] = 1904,
                    ["image"] = 1579931,
                    ["name"] = "Domatrax",
                }, -- [3]
                {
                    ["id"] = 1878,
                    ["image"] = 1579938,
                    ["name"] = "Mephistroth",
                }, -- [4]
            },
        }, -- [15]
        {
            ["id"] = 740,
            ["image"] = 1411853,
            ["name"] = "Die Rabenwehr",
            ["bosses"] = {
                {
                    ["id"] = 1518,
                    ["image"] = 1410986,
                    ["name"] = "Das Amalgam der Seelen",
                }, -- [1]
                {
                    ["id"] = 1653,
                    ["image"] = 1410961,
                    ["name"] = "Illysanna Rabenkrone",
                }, -- [2]
                {
                    ["id"] = 1664,
                    ["image"] = 1410982,
                    ["name"] = "Stachelfaust der Verhasste",
                }, -- [3]
                {
                    ["id"] = 1672,
                    ["image"] = 1410967,
                    ["name"] = "Lord Kur'talos Rabenkrone",
                }, -- [4]
            },
        }, -- [16]
        {
            ["id"] = 767,
            ["image"] = 1450574,
            ["name"] = "Neltharions Hort",
            ["bosses"] = {
                {
                    ["id"] = 1662,
                    ["image"] = 1410976,
                    ["name"] = "Rokmora",
                }, -- [1]
                {
                    ["id"] = 1665,
                    ["image"] = 1410990,
                    ["name"] = "Ularogg Klippenformer",
                }, -- [2]
                {
                    ["id"] = 1673,
                    ["image"] = 1410971,
                    ["name"] = "Naraxas",
                }, -- [3]
                {
                    ["id"] = 1687,
                    ["image"] = 1410944,
                    ["name"] = "Dargrul der Unterkönig",
                }, -- [4]
            },
        }, -- [17]
        {
            ["id"] = 860,
            ["image"] = 1537283,
            ["name"] = "Rückkehr nach Karazhan",
            ["bosses"] = {
                {
                    ["id"] = 1820,
                    ["image"] = 1536495,
                    ["name"] = "Der Opernsaal: Wikket",
                }, -- [1]
                {
                    ["id"] = 1826,
                    ["image"] = 1536494,
                    ["name"] = "Der Opernsaal: Westfall Story",
                }, -- [2]
                {
                    ["id"] = 1827,
                    ["image"] = 1536493,
                    ["name"] = "Opernsaal: Das schöne Biest",
                }, -- [3]
                {
                    ["id"] = 1825,
                    ["image"] = 1378997,
                    ["name"] = "Tugendhafte Maid",
                }, -- [4]
                {
                    ["id"] = 1835,
                    ["image"] = 1536490,
                    ["name"] = "Attumen der Jäger",
                }, -- [5]
                {
                    ["id"] = 1837,
                    ["image"] = 1378999,
                    ["name"] = "Moroes",
                }, -- [6]
                {
                    ["id"] = 1836,
                    ["image"] = 1379020,
                    ["name"] = "Der Kurator",
                }, -- [7]
                {
                    ["id"] = 1817,
                    ["image"] = 1536496,
                    ["name"] = "Medivhs Schemen",
                }, -- [8]
                {
                    ["id"] = 1818,
                    ["image"] = 1536492,
                    ["name"] = "Manaschlinger",
                }, -- [9]
                {
                    ["id"] = 1838,
                    ["image"] = 1536497,
                    ["name"] = "Viz'aduum der Beobachter",
                }, -- [10]
            },
        }, -- [18]
        {
            ["id"] = 945,
            ["image"] = 1718213,
            ["name"] = "Sitz des Triumvirats",
            ["bosses"] = {
                {
                    ["id"] = 1979,
                    ["image"] = 1715226,
                    ["name"] = "Zuraal der Aufgestiegene",
                }, -- [1]
                {
                    ["id"] = 1980,
                    ["image"] = 1715220,
                    ["name"] = "Saprish",
                }, -- [2]
                {
                    ["id"] = 1981,
                    ["image"] = 1715224,
                    ["name"] = "Vizekönig Nezhar",
                }, -- [3]
                {
                    ["id"] = 1982,
                    ["image"] = 1715214,
                    ["name"] = "L'ura",
                }, -- [4]
            },
        }, -- [19]
        {
            ["id"] = 777,
            ["image"] = 1498155,
            ["name"] = "Sturm auf die Violette Festung",
            ["bosses"] = {
                {
                    ["id"] = 1693,
                    ["image"] = 1410950,
                    ["name"] = "Faulmiene",
                }, -- [1]
                {
                    ["id"] = 1694,
                    ["image"] = 1410980,
                    ["name"] = "Zitterschlund",
                }, -- [2]
                {
                    ["id"] = 1702,
                    ["image"] = 1410938,
                    ["name"] = "Blutprinzessin Thal'ena",
                }, -- [3]
                {
                    ["id"] = 1686,
                    ["image"] = 1410969,
                    ["name"] = "Gedankenschinder Kaahrj",
                }, -- [4]
                {
                    ["id"] = 1688,
                    ["image"] = 1410968,
                    ["name"] = "Millificent Manasturm",
                }, -- [5]
                {
                    ["id"] = 1696,
                    ["image"] = 1410935,
                    ["name"] = "Anub'esset",
                }, -- [6]
                {
                    ["id"] = 1697,
                    ["image"] = 1410977,
                    ["name"] = "Sael'orn",
                }, -- [7]
                {
                    ["id"] = 1711,
                    ["image"] = 1410948,
                    ["name"] = "Teufelslord Betrugg",
                }, -- [8]
            },
        }, -- [20]
    },
    ["Cataclysm"] = {
        {
            ["id"] = 75,
            ["image"] = 522349,
            ["name"] = "Baradinfestung",
            ["bosses"] = {
                {
                    ["id"] = 139,
                    ["image"] = 522198,
                    ["name"] = "Argaloth",
                }, -- [1]
                {
                    ["id"] = 140,
                    ["image"] = 523207,
                    ["name"] = "Occu'thar",
                }, -- [2]
                {
                    ["id"] = 339,
                    ["image"] = 571742,
                    ["name"] = "Alizabal, Herrin des Hasses",
                }, -- [3]
            },
        }, -- [1]
        {
            ["id"] = 72,
            ["image"] = 522355,
            ["name"] = "Die Bastion des Zwielichts",
            ["bosses"] = {
                {
                    ["id"] = 156,
                    ["image"] = 522232,
                    ["name"] = "Halfus Wyrmbrecher",
                }, -- [1]
                {
                    ["id"] = 157,
                    ["image"] = 522274,
                    ["name"] = "Theralion und Valiona",
                }, -- [2]
                {
                    ["id"] = 158,
                    ["image"] = 522224,
                    ["name"] = "Rat der Aszendenten",
                }, -- [3]
                {
                    ["id"] = 167,
                    ["image"] = 522212,
                    ["name"] = "Cho'gall",
                }, -- [4]
                {
                    ["id"] = 168,
                    ["image"] = 522270,
                    ["name"] = "Sinestra",
                }, -- [5]
            },
        }, -- [2]
        {
            ["id"] = 73,
            ["image"] = 522351,
            ["name"] = "Pechschwingenabstieg",
            ["bosses"] = {
                {
                    ["id"] = 169,
                    ["image"] = 522250,
                    ["name"] = "Omnotron-Verteidigungssystem",
                }, -- [1]
                {
                    ["id"] = 170,
                    ["image"] = 522251,
                    ["name"] = "Magmaul",
                }, -- [2]
                {
                    ["id"] = 171,
                    ["image"] = 522202,
                    ["name"] = "Atramedes",
                }, -- [3]
                {
                    ["id"] = 172,
                    ["image"] = 522211,
                    ["name"] = "Schimaeron",
                }, -- [4]
                {
                    ["id"] = 173,
                    ["image"] = 522252,
                    ["name"] = "Maloriak",
                }, -- [5]
                {
                    ["id"] = 174,
                    ["image"] = 522255,
                    ["name"] = "Nefarians Ende",
                }, -- [6]
            },
        }, -- [3]
        {
            ["id"] = 74,
            ["image"] = 522359,
            ["name"] = "Thron der Vier Winde",
            ["bosses"] = {
                {
                    ["id"] = 154,
                    ["image"] = 522196,
                    ["name"] = "Das Konklave des Windes",
                }, -- [1]
                {
                    ["id"] = 155,
                    ["image"] = 522191,
                    ["name"] = "Al'Akir",
                }, -- [2]
            },
        }, -- [4]
        {
            ["id"] = 78,
            ["image"] = 522353,
            ["name"] = "Feuerlande",
            ["bosses"] = {
                {
                    ["id"] = 192,
                    ["image"] = 522208,
                    ["name"] = "Beth'tilac",
                }, -- [1]
                {
                    ["id"] = 193,
                    ["image"] = 522248,
                    ["name"] = "Lord Rhyolith",
                }, -- [2]
                {
                    ["id"] = 194,
                    ["image"] = 522193,
                    ["name"] = "Alysrazar",
                }, -- [3]
                {
                    ["id"] = 195,
                    ["image"] = 522268,
                    ["name"] = "Shannox",
                }, -- [4]
                {
                    ["id"] = 196,
                    ["image"] = 522204,
                    ["name"] = "Baloroc, der Torwächter",
                }, -- [5]
                {
                    ["id"] = 197,
                    ["image"] = 522223,
                    ["name"] = "Majordomus Hirschhaupt",
                }, -- [6]
                {
                    ["id"] = 198,
                    ["image"] = 522261,
                    ["name"] = "Ragnaros",
                }, -- [7]
            },
        }, -- [5]
        {
            ["id"] = 187,
            ["image"] = 571753,
            ["name"] = "Drachenseele",
            ["bosses"] = {
                {
                    ["id"] = 311,
                    ["image"] = 536058,
                    ["name"] = "Morchok",
                }, -- [1]
                {
                    ["id"] = 324,
                    ["image"] = 536061,
                    ["name"] = "Kriegsherr Zon'ozz",
                }, -- [2]
                {
                    ["id"] = 325,
                    ["image"] = 536062,
                    ["name"] = "Yor'sahj der Unermüdliche",
                }, -- [3]
                {
                    ["id"] = 317,
                    ["image"] = 536057,
                    ["name"] = "Hagara die Sturmbinderin",
                }, -- [4]
                {
                    ["id"] = 331,
                    ["image"] = 571750,
                    ["name"] = "Ultraxion",
                }, -- [5]
                {
                    ["id"] = 332,
                    ["image"] = 571752,
                    ["name"] = "Kriegsmeister Schwarzhorn",
                }, -- [6]
                {
                    ["id"] = 318,
                    ["image"] = 536056,
                    ["name"] = "Todesschwinges Rückgrat",
                }, -- [7]
                {
                    ["id"] = 333,
                    ["image"] = 536055,
                    ["name"] = "Todesschwinges Wahnsinn",
                }, -- [8]
            },
        }, -- [6]
        {
            ["id"] = 185,
            ["image"] = 571756,
            ["name"] = "Brunnen der Ewigkeit",
            ["bosses"] = {
                {
                    ["id"] = 290,
                    ["image"] = 536060,
                    ["name"] = "Peroth'arn",
                }, -- [1]
                {
                    ["id"] = 291,
                    ["image"] = 571747,
                    ["name"] = "Königin Azshara",
                }, -- [2]
                {
                    ["id"] = 292,
                    ["image"] = 571746,
                    ["name"] = "Mannoroth und Varo'then",
                }, -- [3]
            },
        }, -- [7]
        {
            ["id"] = 64,
            ["image"] = 522358,
            ["name"] = "Burg Schattenfang",
            ["bosses"] = {
                {
                    ["id"] = 96,
                    ["image"] = 522205,
                    ["name"] = "Baron Ashbury",
                }, -- [1]
                {
                    ["id"] = 97,
                    ["image"] = 522206,
                    ["name"] = "Baron Silberlein",
                }, -- [2]
                {
                    ["id"] = 98,
                    ["image"] = 522213,
                    ["name"] = "Kommandant Grüntal",
                }, -- [3]
                {
                    ["id"] = 99,
                    ["image"] = 522249,
                    ["name"] = "Lord Walden",
                }, -- [4]
                {
                    ["id"] = 100,
                    ["image"] = 522247,
                    ["name"] = "Lord Godfrey",
                }, -- [5]
            },
        }, -- [8]
        {
            ["id"] = 67,
            ["image"] = 522360,
            ["name"] = "Der Steinerne Kern",
            ["bosses"] = {
                {
                    ["id"] = 110,
                    ["image"] = 522215,
                    ["name"] = "Corborus",
                }, -- [1]
                {
                    ["id"] = 111,
                    ["image"] = 522271,
                    ["name"] = "Plattenhaut",
                }, -- [2]
                {
                    ["id"] = 112,
                    ["image"] = 522258,
                    ["name"] = "Ozruk",
                }, -- [3]
                {
                    ["id"] = 113,
                    ["image"] = 522237,
                    ["name"] = "Hohepriesterin Azil",
                }, -- [4]
            },
        }, -- [9]
        {
            ["id"] = 68,
            ["image"] = 522361,
            ["name"] = "Der Vortexgipfel",
            ["bosses"] = {
                {
                    ["id"] = 114,
                    ["image"] = 522229,
                    ["name"] = "Großwesir Ertan",
                }, -- [1]
                {
                    ["id"] = 115,
                    ["image"] = 522192,
                    ["name"] = "Altairus",
                }, -- [2]
                {
                    ["id"] = 116,
                    ["image"] = 522200,
                    ["name"] = "Asaad, Kalif der Zephyre",
                }, -- [3]
            },
        }, -- [10]
        {
            ["id"] = 186,
            ["image"] = 571755,
            ["name"] = "Die Stunde des Zwielichts",
            ["bosses"] = {
                {
                    ["id"] = 322,
                    ["image"] = 571743,
                    ["name"] = "Arcurion",
                }, -- [1]
                {
                    ["id"] = 342,
                    ["image"] = 536054,
                    ["name"] = "Asira Dämmerschlächter",
                }, -- [2]
                {
                    ["id"] = 341,
                    ["image"] = 536053,
                    ["name"] = "Erzbischof Benedictus",
                }, -- [3]
            },
        }, -- [11]
        {
            ["id"] = 69,
            ["image"] = 522357,
            ["name"] = "Die Verlorene Stadt der Tol'vir",
            ["bosses"] = {
                {
                    ["id"] = 117,
                    ["image"] = 523205,
                    ["name"] = "General Husam",
                }, -- [1]
                {
                    ["id"] = 118,
                    ["image"] = 522246,
                    ["name"] = "Schnappschlund",
                }, -- [2]
                {
                    ["id"] = 119,
                    ["image"] = 522239,
                    ["name"] = "Hochprophet Barim",
                }, -- [3]
                {
                    ["id"] = 122,
                    ["image"] = 522269,
                    ["name"] = "Siamat",
                }, -- [4]
            },
        }, -- [12]
        {
            ["id"] = 184,
            ["image"] = 571754,
            ["name"] = "Endzeit",
            ["bosses"] = {
                {
                    ["id"] = 340,
                    ["image"] = 571744,
                    ["name"] = "Echo von Baine",
                }, -- [1]
                {
                    ["id"] = 285,
                    ["image"] = 571745,
                    ["name"] = "Echo von Jaina",
                }, -- [2]
                {
                    ["id"] = 323,
                    ["image"] = 571748,
                    ["name"] = "Echo von Sylvanas",
                }, -- [3]
                {
                    ["id"] = 283,
                    ["image"] = 571749,
                    ["name"] = "Echo von Tyrande",
                }, -- [4]
                {
                    ["id"] = 289,
                    ["image"] = 536059,
                    ["name"] = "Murozond",
                }, -- [5]
            },
        }, -- [13]
        {
            ["id"] = 71,
            ["image"] = 522354,
            ["name"] = "Grim Batol",
            ["bosses"] = {
                {
                    ["id"] = 131,
                    ["image"] = 522227,
                    ["name"] = "General Umbriss",
                }, -- [1]
                {
                    ["id"] = 132,
                    ["image"] = 522226,
                    ["name"] = "Schmiedemeister Throngus",
                }, -- [2]
                {
                    ["id"] = 133,
                    ["image"] = 522218,
                    ["name"] = "Drahga Schattenbrenner",
                }, -- [3]
                {
                    ["id"] = 134,
                    ["image"] = 522222,
                    ["name"] = "Erudax, der Herzog der Tiefe",
                }, -- [4]
            },
        }, -- [14]
        {
            ["id"] = 70,
            ["image"] = 522356,
            ["name"] = "Hallen des Ursprungs",
            ["bosses"] = {
                {
                    ["id"] = 124,
                    ["image"] = 522272,
                    ["name"] = "Tempelwächter Anhuur",
                }, -- [1]
                {
                    ["id"] = 125,
                    ["image"] = 522219,
                    ["name"] = "Erdwüter Ptah",
                }, -- [2]
                {
                    ["id"] = 126,
                    ["image"] = 522195,
                    ["name"] = "Anraphet",
                }, -- [3]
                {
                    ["id"] = 127,
                    ["image"] = 522241,
                    ["name"] = "Isiset, Konstrukt der Magie",
                }, -- [4]
                {
                    ["id"] = 128,
                    ["image"] = 522194,
                    ["name"] = "Ammunae, Konstrukt des Lebens",
                }, -- [5]
                {
                    ["id"] = 129,
                    ["image"] = 522267,
                    ["name"] = "Setesh, Konstrukt der Zerstörung",
                }, -- [6]
                {
                    ["id"] = 130,
                    ["image"] = 522262,
                    ["name"] = "Rajh, Konstrukt der Sonne",
                }, -- [7]
            },
        }, -- [15]
        {
            ["id"] = 66,
            ["image"] = 522350,
            ["name"] = "Schwarzfelshöhlen",
            ["bosses"] = {
                {
                    ["id"] = 105,
                    ["image"] = 522266,
                    ["name"] = "Rom'ogg Knochenbrecher",
                }, -- [1]
                {
                    ["id"] = 106,
                    ["image"] = 522216,
                    ["name"] = "Corla, Botin des Zwielichts",
                }, -- [2]
                {
                    ["id"] = 107,
                    ["image"] = 522244,
                    ["name"] = "Karsh Stahlbieger",
                }, -- [3]
                {
                    ["id"] = 108,
                    ["image"] = 522207,
                    ["name"] = "Bella",
                }, -- [4]
                {
                    ["id"] = 109,
                    ["image"] = 522201,
                    ["name"] = "Aszendentenfürst Obsidius",
                }, -- [5]
            },
        }, -- [16]
        {
            ["id"] = 65,
            ["image"] = 522362,
            ["name"] = "Thron der Gezeiten",
            ["bosses"] = {
                {
                    ["id"] = 101,
                    ["image"] = 522245,
                    ["name"] = "Lady Naz'jar",
                }, -- [1]
                {
                    ["id"] = 102,
                    ["image"] = 522214,
                    ["name"] = "Kommandant Ulthok",
                }, -- [2]
                {
                    ["id"] = 103,
                    ["image"] = 522253,
                    ["name"] = "Geistbeuger Ghur'sha",
                }, -- [3]
                {
                    ["id"] = 104,
                    ["image"] = 522259,
                    ["name"] = "Ozumat",
                }, -- [4]
            },
        }, -- [17]
        {
            ["id"] = 63,
            ["image"] = 522352,
            ["name"] = "Todesminen",
            ["bosses"] = {
                {
                    ["id"] = 89,
                    ["image"] = 522228,
                    ["name"] = "Glubtok",
                }, -- [1]
                {
                    ["id"] = 90,
                    ["image"] = 522234,
                    ["name"] = "Helix Ritzelbrecher",
                }, -- [2]
                {
                    ["id"] = 91,
                    ["image"] = 522225,
                    ["name"] = "Feindschnitter 5000",
                }, -- [3]
                {
                    ["id"] = 92,
                    ["image"] = 522189,
                    ["name"] = "Admiral Knurrreißer",
                }, -- [4]
                {
                    ["id"] = 93,
                    ["image"] = 522210,
                    ["name"] = "\"Kapitän\" Krümel",
                }, -- [5]
                {
                    ["id"] = 95,
                    ["image"] = 522278,
                    ["name"] = "Vanessa van Cleef",
                }, -- [6]
            },
        }, -- [18]
        {
            ["id"] = 77,
            ["image"] = 522363,
            ["name"] = "Zul'Aman",
            ["bosses"] = {
                {
                    ["id"] = 186,
                    ["image"] = 522190,
                    ["name"] = "Akil'zon",
                }, -- [1]
                {
                    ["id"] = 187,
                    ["image"] = 522254,
                    ["name"] = "Nalorakk",
                }, -- [2]
                {
                    ["id"] = 188,
                    ["image"] = 522242,
                    ["name"] = "Jan'alai",
                }, -- [3]
                {
                    ["id"] = 189,
                    ["image"] = 522231,
                    ["name"] = "Halazzi",
                }, -- [4]
                {
                    ["id"] = 190,
                    ["image"] = 522235,
                    ["name"] = "Hexlord Malacrass",
                }, -- [5]
                {
                    ["id"] = 191,
                    ["image"] = 522217,
                    ["name"] = "Daakara",
                }, -- [6]
            },
        }, -- [19]
        {
            ["id"] = 76,
            ["image"] = 522364,
            ["name"] = "Zul'Gurub",
            ["bosses"] = {
                {
                    ["id"] = 175,
                    ["image"] = 522236,
                    ["name"] = "Hohepriester Venoxis",
                }, -- [1]
                {
                    ["id"] = 176,
                    ["image"] = 522209,
                    ["name"] = "Blutfürst Mandokir",
                }, -- [2]
                {
                    ["id"] = 177,
                    ["image"] = 522230,
                    ["name"] = "Hort des Wahnsinns - Gri'lek",
                }, -- [3]
                {
                    ["id"] = 178,
                    ["image"] = 522233,
                    ["name"] = "Hort des Wahnsinns - Hazza'rah",
                }, -- [4]
                {
                    ["id"] = 179,
                    ["image"] = 522263,
                    ["name"] = "Hort des Wahnsinns - Renataki",
                }, -- [5]
                {
                    ["id"] = 180,
                    ["image"] = 522279,
                    ["name"] = "Hort des Wahnsinns - Wushoolay",
                }, -- [6]
                {
                    ["id"] = 181,
                    ["image"] = 522238,
                    ["name"] = "Hohepriesterin Kilnara",
                }, -- [7]
                {
                    ["id"] = 184,
                    ["image"] = 522280,
                    ["name"] = "Zanzil",
                }, -- [8]
                {
                    ["id"] = 185,
                    ["image"] = 522243,
                    ["name"] = "Jin'do der Götterbrecher",
                }, -- [9]
            },
        }, -- [20]
    },
    ["Mists of Pandaria"] = {
        {
            ["id"] = 322,
            ["image"] = 652218,
            ["name"] = "Pandaria",
            ["bosses"] = {
                {
                    ["id"] = 691,
                    ["image"] = 630847,
                    ["name"] = "Sha des Zorns",
                }, -- [1]
                {
                    ["id"] = 725,
                    ["image"] = 630819,
                    ["name"] = "Salyis' Kriegsmeute",
                }, -- [2]
                {
                    ["id"] = 814,
                    ["image"] = 796778,
                    ["name"] = "Nalak, der Sturmfürst",
                }, -- [3]
                {
                    ["id"] = 826,
                    ["image"] = 796779,
                    ["name"] = "Oondasta",
                }, -- [4]
                {
                    ["id"] = 857,
                    ["image"] = 901155,
                    ["name"] = "Chi-Ji, der Rote Kranich",
                }, -- [5]
                {
                    ["id"] = 858,
                    ["image"] = 901173,
                    ["name"] = "Yu'lon, die Jadeschlange",
                }, -- [6]
                {
                    ["id"] = 859,
                    ["image"] = 901165,
                    ["name"] = "Niuzao, der Schwarze Ochse",
                }, -- [7]
                {
                    ["id"] = 860,
                    ["image"] = 901172,
                    ["name"] = "Xuen, der Weiße Tiger",
                }, -- [8]
                {
                    ["id"] = 861,
                    ["image"] = 901167,
                    ["name"] = "Ordos, Feuergott der Yaungol",
                }, -- [9]
            },
        }, -- [1]
        {
            ["id"] = 317,
            ["image"] = 632273,
            ["name"] = "Mogu'shangewölbe",
            ["bosses"] = {
                {
                    ["id"] = 679,
                    ["image"] = 630820,
                    ["name"] = "Die Steinwache",
                }, -- [1]
                {
                    ["id"] = 689,
                    ["image"] = 630824,
                    ["name"] = "Feng der Verfluchte",
                }, -- [2]
                {
                    ["id"] = 682,
                    ["image"] = 630826,
                    ["name"] = "Gara'jal der Geisterbinder",
                }, -- [3]
                {
                    ["id"] = 687,
                    ["image"] = 630861,
                    ["name"] = "Die Geisterkönige",
                }, -- [4]
                {
                    ["id"] = 726,
                    ["image"] = 630823,
                    ["name"] = "Elegon",
                }, -- [5]
                {
                    ["id"] = 677,
                    ["image"] = 630836,
                    ["name"] = "Der Wille des Kaisers",
                }, -- [6]
            },
        }, -- [2]
        {
            ["id"] = 330,
            ["image"] = 632271,
            ["name"] = "Das Herz der Angst",
            ["bosses"] = {
                {
                    ["id"] = 745,
                    ["image"] = 630834,
                    ["name"] = "Kaiserlicher Wesir Zor'lok",
                }, -- [1]
                {
                    ["id"] = 744,
                    ["image"] = 630817,
                    ["name"] = "Klingenfürst Ta'yak",
                }, -- [2]
                {
                    ["id"] = 713,
                    ["image"] = 630827,
                    ["name"] = "Garalon",
                }, -- [3]
                {
                    ["id"] = 741,
                    ["image"] = 630856,
                    ["name"] = "Windfürst Mel'jarak",
                }, -- [4]
                {
                    ["id"] = 737,
                    ["image"] = 630815,
                    ["name"] = "Bernformer Un'sok",
                }, -- [5]
                {
                    ["id"] = 743,
                    ["image"] = 630830,
                    ["name"] = "Großkaiserin Shek'zeer",
                }, -- [6]
            },
        }, -- [3]
        {
            ["id"] = 320,
            ["image"] = 643264,
            ["name"] = "Terrasse d. Endlosen Frühlings",
            ["bosses"] = {
                {
                    ["id"] = 683,
                    ["image"] = 630844,
                    ["name"] = "Beschützer des Endlosen",
                }, -- [1]
                {
                    ["id"] = 742,
                    ["image"] = 630854,
                    ["name"] = "Tsulong",
                }, -- [2]
                {
                    ["id"] = 729,
                    ["image"] = 630837,
                    ["name"] = "Lei Shi",
                }, -- [3]
                {
                    ["id"] = 709,
                    ["image"] = 630849,
                    ["name"] = "Sha der Angst",
                }, -- [4]
            },
        }, -- [4]
        {
            ["id"] = 362,
            ["image"] = 828453,
            ["name"] = "Thron des Donners",
            ["bosses"] = {
                {
                    ["id"] = 827,
                    ["image"] = 796776,
                    ["name"] = "Jin'rokh der Zerstörer",
                }, -- [1]
                {
                    ["id"] = 819,
                    ["image"] = 796774,
                    ["name"] = "Horridon",
                }, -- [2]
                {
                    ["id"] = 816,
                    ["image"] = 796770,
                    ["name"] = "Rat der Ältesten",
                }, -- [3]
                {
                    ["id"] = 825,
                    ["image"] = 796781,
                    ["name"] = "Tortos",
                }, -- [4]
                {
                    ["id"] = 821,
                    ["image"] = 796786,
                    ["name"] = "Megaera",
                }, -- [5]
                {
                    ["id"] = 828,
                    ["image"] = 796785,
                    ["name"] = "Ji-Kun",
                }, -- [6]
                {
                    ["id"] = 818,
                    ["image"] = 796772,
                    ["name"] = "Durumu der Vergessene",
                }, -- [7]
                {
                    ["id"] = 820,
                    ["image"] = 796780,
                    ["name"] = "Primordius",
                }, -- [8]
                {
                    ["id"] = 824,
                    ["image"] = 796771,
                    ["name"] = "Dunkler Animus",
                }, -- [9]
                {
                    ["id"] = 817,
                    ["image"] = 796775,
                    ["name"] = "Der eiserne Qon",
                }, -- [10]
                {
                    ["id"] = 829,
                    ["image"] = 796773,
                    ["name"] = "Zwillingsempyreanerinnen",
                }, -- [11]
                {
                    ["id"] = 832,
                    ["image"] = 796777,
                    ["name"] = "Lei Shen",
                }, -- [12]
            },
        }, -- [5]
        {
            ["id"] = 369,
            ["image"] = 904981,
            ["name"] = "Schlacht um Orgrimmar",
            ["bosses"] = {
                {
                    ["id"] = 852,
                    ["image"] = 901160,
                    ["name"] = "Immerseus",
                }, -- [1]
                {
                    ["id"] = 849,
                    ["image"] = 901159,
                    ["name"] = "Die gefallenen Beschützer",
                }, -- [2]
                {
                    ["id"] = 866,
                    ["image"] = 901166,
                    ["name"] = "Norushen",
                }, -- [3]
                {
                    ["id"] = 867,
                    ["image"] = 901168,
                    ["name"] = "Sha des Stolzes",
                }, -- [4]
                {
                    ["id"] = 868,
                    ["image"] = 901156,
                    ["name"] = "Galakras",
                }, -- [5]
                {
                    ["id"] = 864,
                    ["image"] = 901161,
                    ["name"] = "Eiserner Koloss",
                }, -- [6]
                {
                    ["id"] = 856,
                    ["image"] = 901163,
                    ["name"] = "Dunkelschamanen der Kor'kron",
                }, -- [7]
                {
                    ["id"] = 850,
                    ["image"] = 901158,
                    ["name"] = "General Nazgrim",
                }, -- [8]
                {
                    ["id"] = 846,
                    ["image"] = 901164,
                    ["name"] = "Malkorok",
                }, -- [9]
                {
                    ["id"] = 870,
                    ["image"] = 901170,
                    ["name"] = "Die Schätze Pandarias",
                }, -- [10]
                {
                    ["id"] = 851,
                    ["image"] = 901171,
                    ["name"] = "Thok der Blutrünstige",
                }, -- [11]
                {
                    ["id"] = 865,
                    ["image"] = 901169,
                    ["name"] = "Belagerungsingenieur Rußschmied",
                }, -- [12]
                {
                    ["id"] = 853,
                    ["image"] = 901162,
                    ["name"] = "Die Getreuen der Klaxxi",
                }, -- [13]
                {
                    ["id"] = 869,
                    ["image"] = 901157,
                    ["name"] = "Garrosh Höllschrei",
                }, -- [14]
            },
        }, -- [6]
        {
            ["id"] = 324,
            ["image"] = 643263,
            ["name"] = "Belagerung des Niuzaotempels",
            ["bosses"] = {
                {
                    ["id"] = 693,
                    ["image"] = 630855,
                    ["name"] = "Wesir Jin'bak",
                }, -- [1]
                {
                    ["id"] = 738,
                    ["image"] = 630822,
                    ["name"] = "Kommandant Vo'jak",
                }, -- [2]
                {
                    ["id"] = 692,
                    ["image"] = 630829,
                    ["name"] = "General Pa'valak",
                }, -- [3]
                {
                    ["id"] = 727,
                    ["image"] = 630857,
                    ["name"] = "Schwadronsführer Ner'onok",
                }, -- [4]
            },
        }, -- [7]
        {
            ["id"] = 316,
            ["image"] = 608214,
            ["name"] = "Das Scharlachrote Kloster",
            ["bosses"] = {
                {
                    ["id"] = 688,
                    ["image"] = 630853,
                    ["name"] = "Thalnos der Seelenfetzer",
                }, -- [1]
                {
                    ["id"] = 671,
                    ["image"] = 630818,
                    ["name"] = "Bruder Korloff",
                }, -- [2]
                {
                    ["id"] = 674,
                    ["image"] = 607643,
                    ["name"] = "Hochinquisitorin Weißsträhne",
                }, -- [3]
            },
        }, -- [8]
        {
            ["id"] = 312,
            ["image"] = 632274,
            ["name"] = "Das Shado-Pan-Kloster",
            ["bosses"] = {
                {
                    ["id"] = 673,
                    ["image"] = 630831,
                    ["name"] = "Gu Wolkenschlag",
                }, -- [1]
                {
                    ["id"] = 657,
                    ["image"] = 630841,
                    ["name"] = "Meister Schneewehe",
                }, -- [2]
                {
                    ["id"] = 685,
                    ["image"] = 630850,
                    ["name"] = "Sha der Gewalt",
                }, -- [3]
                {
                    ["id"] = 686,
                    ["image"] = 630852,
                    ["name"] = "Taran Zhu",
                }, -- [4]
            },
        }, -- [9]
        {
            ["id"] = 302,
            ["image"] = 632275,
            ["name"] = "Die Brauerei Sturmbräu",
            ["bosses"] = {
                {
                    ["id"] = 668,
                    ["image"] = 630843,
                    ["name"] = "Uuk-Uuk",
                }, -- [1]
                {
                    ["id"] = 669,
                    ["image"] = 630832,
                    ["name"] = "Hopsallus",
                }, -- [2]
                {
                    ["id"] = 670,
                    ["image"] = 630860,
                    ["name"] = "Yan-Zhu der Dekantierte",
                }, -- [3]
            },
        }, -- [10]
        {
            ["id"] = 321,
            ["image"] = 632272,
            ["name"] = "Mogu'shanpalast",
            ["bosses"] = {
                {
                    ["id"] = 708,
                    ["image"] = 630842,
                    ["name"] = "Die Prüfung des Königs",
                }, -- [1]
                {
                    ["id"] = 690,
                    ["image"] = 630828,
                    ["name"] = "Gekkan",
                }, -- [2]
                {
                    ["id"] = 698,
                    ["image"] = 630859,
                    ["name"] = "Xin der Waffenmeister",
                }, -- [3]
            },
        }, -- [11]
        {
            ["id"] = 311,
            ["image"] = 643262,
            ["name"] = "Scharlachrote Hallen",
            ["bosses"] = {
                {
                    ["id"] = 660,
                    ["image"] = 630833,
                    ["name"] = "Hundemeister Braun",
                }, -- [1]
                {
                    ["id"] = 654,
                    ["image"] = 630816,
                    ["name"] = "Waffenmeister Harlan",
                }, -- [2]
                {
                    ["id"] = 656,
                    ["image"] = 630825,
                    ["name"] = "Flammenwirker Koegler",
                }, -- [3]
            },
        }, -- [12]
        {
            ["id"] = 246,
            ["image"] = 608215,
            ["name"] = "Scholomance",
            ["bosses"] = {
                {
                    ["id"] = 659,
                    ["image"] = 630835,
                    ["name"] = "Ausbilderin Kaltherz",
                }, -- [1]
                {
                    ["id"] = 663,
                    ["image"] = 607666,
                    ["name"] = "Jandice Barov",
                }, -- [2]
                {
                    ["id"] = 665,
                    ["image"] = 607755,
                    ["name"] = "Blutrippe",
                }, -- [3]
                {
                    ["id"] = 666,
                    ["image"] = 630838,
                    ["name"] = "Lilian Voss",
                }, -- [4]
                {
                    ["id"] = 684,
                    ["image"] = 607582,
                    ["name"] = "Dunkelmeister Gandling",
                }, -- [5]
            },
        }, -- [13]
        {
            ["id"] = 313,
            ["image"] = 632276,
            ["name"] = "Tempel der Jadeschlange",
            ["bosses"] = {
                {
                    ["id"] = 672,
                    ["image"] = 630858,
                    ["name"] = "Der weise Mari",
                }, -- [1]
                {
                    ["id"] = 664,
                    ["image"] = 630840,
                    ["name"] = "Lehrensucher Steinschritt",
                }, -- [2]
                {
                    ["id"] = 658,
                    ["image"] = 630839,
                    ["name"] = "Liu Flammenherz",
                }, -- [3]
                {
                    ["id"] = 335,
                    ["image"] = 630848,
                    ["name"] = "Sha des Zweifels",
                }, -- [4]
            },
        }, -- [14]
        {
            ["id"] = 303,
            ["image"] = 632270,
            ["name"] = "Tor der Untergehenden Sonne",
            ["bosses"] = {
                {
                    ["id"] = 655,
                    ["image"] = 630846,
                    ["name"] = "Saboteur Kip'tilak",
                }, -- [1]
                {
                    ["id"] = 675,
                    ["image"] = 630851,
                    ["name"] = "Bomber Ga'dok",
                }, -- [2]
                {
                    ["id"] = 676,
                    ["image"] = 630821,
                    ["name"] = "Kommandant Ri'mok",
                }, -- [3]
                {
                    ["id"] = 649,
                    ["image"] = 630845,
                    ["name"] = "Raigonn",
                }, -- [4]
            },
        }, -- [15]
    },
    ["Wrath of the Lich King"] = {
        {
            ["id"] = 753,
            ["image"] = 1396596,
            ["name"] = "Archavons Kammer",
            ["bosses"] = {
                {
                    ["id"] = 1597,
                    ["image"] = 1385715,
                    ["name"] = "Archavon der Steinwächter",
                }, -- [1]
                {
                    ["id"] = 1598,
                    ["image"] = 1385727,
                    ["name"] = "Emalon der Sturmwächter",
                }, -- [2]
                {
                    ["id"] = 1599,
                    ["image"] = 1385748,
                    ["name"] = "Koralon der Flammenwächter",
                }, -- [3]
                {
                    ["id"] = 1600,
                    ["image"] = 1385767,
                    ["name"] = "Toravon der Eiswächter",
                }, -- [4]
            },
        }, -- [1]
        {
            ["id"] = 754,
            ["image"] = 1396587,
            ["name"] = "Naxxramas",
            ["bosses"] = {
                {
                    ["id"] = 1601,
                    ["image"] = 1378964,
                    ["name"] = "Anub'Rekhan",
                }, -- [1]
                {
                    ["id"] = 1602,
                    ["image"] = 1378980,
                    ["name"] = "Großwitwe Faerlina",
                }, -- [2]
                {
                    ["id"] = 1603,
                    ["image"] = 1378994,
                    ["name"] = "Maexxna",
                }, -- [3]
                {
                    ["id"] = 1604,
                    ["image"] = 1379004,
                    ["name"] = "Noth der Seuchenfürst",
                }, -- [4]
                {
                    ["id"] = 1605,
                    ["image"] = 1378984,
                    ["name"] = "Heigan der Unreine",
                }, -- [5]
                {
                    ["id"] = 1606,
                    ["image"] = 1378991,
                    ["name"] = "Loatheb",
                }, -- [6]
                {
                    ["id"] = 1607,
                    ["image"] = 1378988,
                    ["name"] = "Instrukteur Razuvious",
                }, -- [7]
                {
                    ["id"] = 1608,
                    ["image"] = 1378979,
                    ["name"] = "Gothik der Ernter",
                }, -- [8]
                {
                    ["id"] = 1609,
                    ["image"] = 1385732,
                    ["name"] = "Die Vier Reiter",
                }, -- [9]
                {
                    ["id"] = 1610,
                    ["image"] = 1379005,
                    ["name"] = "Flickwerk",
                }, -- [10]
                {
                    ["id"] = 1611,
                    ["image"] = 1378981,
                    ["name"] = "Grobbulus",
                }, -- [11]
                {
                    ["id"] = 1612,
                    ["image"] = 1378977,
                    ["name"] = "Gluth",
                }, -- [12]
                {
                    ["id"] = 1613,
                    ["image"] = 1379019,
                    ["name"] = "Thaddius",
                }, -- [13]
                {
                    ["id"] = 1614,
                    ["image"] = 1379010,
                    ["name"] = "Saphiron",
                }, -- [14]
                {
                    ["id"] = 1615,
                    ["image"] = 1378989,
                    ["name"] = "Kel'Thuzad",
                }, -- [15]
            },
        }, -- [2]
        {
            ["id"] = 755,
            ["image"] = 1396588,
            ["name"] = "Das Obsidiansanktum",
            ["bosses"] = {
                {
                    ["id"] = 1616,
                    ["image"] = 1385765,
                    ["name"] = "Sartharion",
                }, -- [1]
            },
        }, -- [3]
        {
            ["id"] = 756,
            ["image"] = 1396581,
            ["name"] = "Das Auge der Ewigkeit",
            ["bosses"] = {
                {
                    ["id"] = 1617,
                    ["image"] = 1385753,
                    ["name"] = "Malygos",
                }, -- [1]
            },
        }, -- [4]
        {
            ["id"] = 759,
            ["image"] = 1396595,
            ["name"] = "Ulduar",
            ["bosses"] = {
                {
                    ["id"] = 1637,
                    ["image"] = 1385731,
                    ["name"] = "Flammenleviathan",
                }, -- [1]
                {
                    ["id"] = 1638,
                    ["image"] = 1385742,
                    ["name"] = "Ignis, Meister des Eisenwerks",
                }, -- [2]
                {
                    ["id"] = 1639,
                    ["image"] = 1385763,
                    ["name"] = "Klingenschuppe",
                }, -- [3]
                {
                    ["id"] = 1640,
                    ["image"] = 1385773,
                    ["name"] = "XT-002 Dekonstruktor",
                }, -- [4]
                {
                    ["id"] = 1641,
                    ["image"] = 1390439,
                    ["name"] = "Die Versammlung des Eisens",
                }, -- [5]
                {
                    ["id"] = 1642,
                    ["image"] = 1385747,
                    ["name"] = "Kologarn",
                }, -- [6]
                {
                    ["id"] = 1643,
                    ["image"] = 1385717,
                    ["name"] = "Auriaya",
                }, -- [7]
                {
                    ["id"] = 1644,
                    ["image"] = 1385740,
                    ["name"] = "Hodir",
                }, -- [8]
                {
                    ["id"] = 1645,
                    ["image"] = 1385770,
                    ["name"] = "Thorim",
                }, -- [9]
                {
                    ["id"] = 1646,
                    ["image"] = 1385733,
                    ["name"] = "Freya",
                }, -- [10]
                {
                    ["id"] = 1647,
                    ["image"] = 1385754,
                    ["name"] = "Mimiron",
                }, -- [11]
                {
                    ["id"] = 1648,
                    ["image"] = 1385735,
                    ["name"] = "General Vezax",
                }, -- [12]
                {
                    ["id"] = 1649,
                    ["image"] = 1385774,
                    ["name"] = "Yogg-Saron",
                }, -- [13]
                {
                    ["id"] = 1650,
                    ["image"] = 1385713,
                    ["name"] = "Algalon der Beobachter",
                }, -- [14]
            },
        }, -- [5]
        {
            ["id"] = 757,
            ["image"] = 1396594,
            ["name"] = "Prüfung des Kreuzfahrers",
            ["bosses"] = {
                {
                    ["id"] = 1618,
                    ["image"] = 1390440,
                    ["name"] = "Die Bestien von Nordend",
                }, -- [1]
                {
                    ["id"] = 1619,
                    ["image"] = 1385752,
                    ["name"] = "Lord Jaraxxus",
                }, -- [2]
                {
                    ["id"] = 1620,
                    ["image"] = 1390442,
                    ["name"] = "Champions der Allianz",
                }, -- [3]
                {
                    ["id"] = 1622,
                    ["image"] = 1390443,
                    ["name"] = "Zwillingsval'kyr",
                }, -- [4]
                {
                    ["id"] = 1623,
                    ["image"] = 607542,
                    ["name"] = "Anub'arak",
                }, -- [5]
            },
        }, -- [6]
        {
            ["id"] = 760,
            ["image"] = 1396589,
            ["name"] = "Onyxias Hort",
            ["bosses"] = {
                {
                    ["id"] = 1651,
                    ["image"] = 1379025,
                    ["name"] = "Onyxia",
                }, -- [1]
            },
        }, -- [7]
        {
            ["id"] = 758,
            ["image"] = 1396583,
            ["name"] = "Die Eiskronenzitadelle",
            ["bosses"] = {
                {
                    ["id"] = 1624,
                    ["image"] = 1378992,
                    ["name"] = "Lord Mark'gar",
                }, -- [1]
                {
                    ["id"] = 1625,
                    ["image"] = 1378990,
                    ["name"] = "Lady Todeswisper",
                }, -- [2]
                {
                    ["id"] = 1627,
                    ["image"] = 1385736,
                    ["name"] = "Kanonenschiffsschlacht von Eiskrone",
                }, -- [3]
                {
                    ["id"] = 1628,
                    ["image"] = 1378970,
                    ["name"] = "Todesbringer Saurfang",
                }, -- [4]
                {
                    ["id"] = 1629,
                    ["image"] = 1378972,
                    ["name"] = "Fauldarm",
                }, -- [5]
                {
                    ["id"] = 1630,
                    ["image"] = 1379009,
                    ["name"] = "Modermiene",
                }, -- [6]
                {
                    ["id"] = 1631,
                    ["image"] = 1379007,
                    ["name"] = "Professor Seuchenmord",
                }, -- [7]
                {
                    ["id"] = 1632,
                    ["image"] = 1385721,
                    ["name"] = "Rat der Blutprinzen",
                }, -- [8]
                {
                    ["id"] = 1633,
                    ["image"] = 1378967,
                    ["name"] = "Blutkönigin Lana'thel",
                }, -- [9]
                {
                    ["id"] = 1634,
                    ["image"] = 1379023,
                    ["name"] = "Valithria Traumwandler",
                }, -- [10]
                {
                    ["id"] = 1635,
                    ["image"] = 1379014,
                    ["name"] = "Sindragosa",
                }, -- [11]
                {
                    ["id"] = 1636,
                    ["image"] = 607688,
                    ["name"] = "Der Lichkönig",
                }, -- [12]
            },
        }, -- [8]
        {
            ["id"] = 761,
            ["image"] = 1396590,
            ["name"] = "Das Rubinsanktum",
            ["bosses"] = {
                {
                    ["id"] = 1652,
                    ["image"] = 1385738,
                    ["name"] = "Halion",
                }, -- [1]
            },
        }, -- [9]
        {
            ["id"] = 271,
            ["image"] = 608192,
            ["name"] = "Ahn'kahet: Das Alte Königreich",
            ["bosses"] = {
                {
                    ["id"] = 580,
                    ["image"] = 607593,
                    ["name"] = "Urahne Nadox",
                }, -- [1]
                {
                    ["id"] = 581,
                    ["image"] = 607744,
                    ["name"] = "Prinz Taldaram",
                }, -- [2]
                {
                    ["id"] = 582,
                    ["image"] = 607667,
                    ["name"] = "Jedoga Schattensucher",
                }, -- [3]
                {
                    ["id"] = 584,
                    ["image"] = 607639,
                    ["name"] = "Herold Volazj",
                }, -- [4]
            },
        }, -- [10]
        {
            ["id"] = 272,
            ["image"] = 608194,
            ["name"] = "Azjol-Nerub",
            ["bosses"] = {
                {
                    ["id"] = 585,
                    ["image"] = 607678,
                    ["name"] = "Krik'thir der Torwächter",
                }, -- [1]
                {
                    ["id"] = 586,
                    ["image"] = 607633,
                    ["name"] = "Hadronox",
                }, -- [2]
                {
                    ["id"] = 587,
                    ["image"] = 607542,
                    ["name"] = "Anub'arak",
                }, -- [3]
            },
        }, -- [11]
        {
            ["id"] = 285,
            ["image"] = 608226,
            ["name"] = "Burg Utgarde",
            ["bosses"] = {
                {
                    ["id"] = 638,
                    ["image"] = 607743,
                    ["name"] = "Prinz Keleseth",
                }, -- [1]
                {
                    ["id"] = 639,
                    ["image"] = 607774,
                    ["name"] = "Skarvald und Dalronn",
                }, -- [2]
                {
                    ["id"] = 640,
                    ["image"] = 607659,
                    ["name"] = "Ingvar der Brandschatzer",
                }, -- [3]
            },
        }, -- [12]
        {
            ["id"] = 279,
            ["image"] = 608219,
            ["name"] = "Das Ausmerzen von Stratholme",
            ["bosses"] = {
                {
                    ["id"] = 611,
                    ["image"] = 607711,
                    ["name"] = "Fleischhaken",
                }, -- [1]
                {
                    ["id"] = 612,
                    ["image"] = 607763,
                    ["name"] = "Salramm der Fleischformer",
                }, -- [2]
                {
                    ["id"] = 613,
                    ["image"] = 607567,
                    ["name"] = "Chronolord Epoch",
                }, -- [3]
                {
                    ["id"] = 614,
                    ["image"] = 607708,
                    ["name"] = "Mal'Ganis",
                }, -- [4]
            },
        }, -- [13]
        {
            ["id"] = 282,
            ["image"] = 608222,
            ["name"] = "Das Oculus",
            ["bosses"] = {
                {
                    ["id"] = 622,
                    ["image"] = 607590,
                    ["name"] = "Drakos der Befrager",
                }, -- [1]
                {
                    ["id"] = 623,
                    ["image"] = 607802,
                    ["name"] = "Varos Wolkenwanderer",
                }, -- [2]
                {
                    ["id"] = 624,
                    ["image"] = 607702,
                    ["name"] = "Magierlord Urom",
                }, -- [3]
                {
                    ["id"] = 625,
                    ["image"] = 607687,
                    ["name"] = "Leywächter Eregos",
                }, -- [4]
            },
        }, -- [14]
        {
            ["id"] = 281,
            ["image"] = 608221,
            ["name"] = "Der Nexus",
            ["bosses"] = {
                {
                    ["id"] = 618,
                    ["image"] = 607623,
                    ["name"] = "Großmagistrix Telestra",
                }, -- [1]
                {
                    ["id"] = 619,
                    ["image"] = 607540,
                    ["name"] = "Anomalus",
                }, -- [2]
                {
                    ["id"] = 620,
                    ["image"] = 607735,
                    ["name"] = "Ormorok der Baumformer",
                }, -- [3]
                {
                    ["id"] = 621,
                    ["image"] = 607671,
                    ["name"] = "Keristrasza",
                }, -- [4]
            },
        }, -- [15]
        {
            ["id"] = 280,
            ["image"] = 608220,
            ["name"] = "Die Seelenschmiede",
            ["bosses"] = {
                {
                    ["id"] = 615,
                    ["image"] = 607559,
                    ["name"] = "Bronjahm",
                }, -- [1]
                {
                    ["id"] = 616,
                    ["image"] = 607585,
                    ["name"] = "Verschlinger der Seelen",
                }, -- [2]
            },
        }, -- [16]
        {
            ["id"] = 283,
            ["image"] = 608228,
            ["name"] = "Die Violette Festung",
            ["bosses"] = {
                {
                    ["id"] = 626,
                    ["image"] = 607597,
                    ["name"] = "Erekem",
                }, -- [1]
                {
                    ["id"] = 627,
                    ["image"] = 607717,
                    ["name"] = "Moragg",
                }, -- [2]
                {
                    ["id"] = 628,
                    ["image"] = 607654,
                    ["name"] = "Ichoron",
                }, -- [3]
                {
                    ["id"] = 629,
                    ["image"] = 607821,
                    ["name"] = "Xevozz",
                }, -- [4]
                {
                    ["id"] = 630,
                    ["image"] = 607685,
                    ["name"] = "Lavanthor",
                }, -- [5]
                {
                    ["id"] = 631,
                    ["image"] = 607825,
                    ["name"] = "Zuramat der Vernichter",
                }, -- [6]
                {
                    ["id"] = 632,
                    ["image"] = 607573,
                    ["name"] = "Cyanigosa",
                }, -- [7]
            },
        }, -- [17]
        {
            ["id"] = 273,
            ["image"] = 608201,
            ["name"] = "Feste Drak'Tharon",
            ["bosses"] = {
                {
                    ["id"] = 588,
                    ["image"] = 607798,
                    ["name"] = "Trollgrind",
                }, -- [1]
                {
                    ["id"] = 589,
                    ["image"] = 607727,
                    ["name"] = "Novos der Beschwörer",
                }, -- [2]
                {
                    ["id"] = 590,
                    ["image"] = 607672,
                    ["name"] = "König Dred",
                }, -- [3]
                {
                    ["id"] = 591,
                    ["image"] = 607790,
                    ["name"] = "Der Prophet Tharon'ja",
                }, -- [4]
            },
        }, -- [18]
        {
            ["id"] = 278,
            ["image"] = 608210,
            ["name"] = "Grube von Saron",
            ["bosses"] = {
                {
                    ["id"] = 608,
                    ["image"] = 607603,
                    ["name"] = "Schmiedemeister Garfrost",
                }, -- [1]
                {
                    ["id"] = 609,
                    ["image"] = 607677,
                    ["name"] = "Ick und Krick",
                }, -- [2]
                {
                    ["id"] = 610,
                    ["image"] = 607765,
                    ["name"] = "Geißelfürst Tyrannus",
                }, -- [3]
            },
        }, -- [19]
        {
            ["id"] = 274,
            ["image"] = 608203,
            ["name"] = "Gundrak",
            ["bosses"] = {
                {
                    ["id"] = 592,
                    ["image"] = 607776,
                    ["name"] = "Slad'ran",
                }, -- [1]
                {
                    ["id"] = 593,
                    ["image"] = 607589,
                    ["name"] = "Koloss der Drakkari",
                }, -- [2]
                {
                    ["id"] = 594,
                    ["image"] = 607716,
                    ["name"] = "Moorabi",
                }, -- [3]
                {
                    ["id"] = 596,
                    ["image"] = 607605,
                    ["name"] = "Gal'darah",
                }, -- [4]
            },
        }, -- [20]
        {
            ["id"] = 275,
            ["image"] = 608204,
            ["name"] = "Hallen der Blitze",
            ["bosses"] = {
                {
                    ["id"] = 597,
                    ["image"] = 607611,
                    ["name"] = "General Bjarngrim",
                }, -- [1]
                {
                    ["id"] = 598,
                    ["image"] = 607809,
                    ["name"] = "Volkhan",
                }, -- [2]
                {
                    ["id"] = 599,
                    ["image"] = 607663,
                    ["name"] = "Ionar",
                }, -- [3]
                {
                    ["id"] = 600,
                    ["image"] = 607690,
                    ["name"] = "Loken",
                }, -- [4]
            },
        }, -- [21]
        {
            ["id"] = 276,
            ["image"] = 608205,
            ["name"] = "Hallen der Reflexion",
            ["bosses"] = {
                {
                    ["id"] = 601,
                    ["image"] = 607601,
                    ["name"] = "Falric",
                }, -- [1]
                {
                    ["id"] = 602,
                    ["image"] = 607710,
                    ["name"] = "Marwyn",
                }, -- [2]
                {
                    ["id"] = 603,
                    ["image"] = 607688,
                    ["name"] = "Flucht vor Arthas",
                }, -- [3]
            },
        }, -- [22]
        {
            ["id"] = 277,
            ["image"] = 608206,
            ["name"] = "Hallen des Steins",
            ["bosses"] = {
                {
                    ["id"] = 604,
                    ["image"] = 607679,
                    ["name"] = "Krystallus",
                }, -- [1]
                {
                    ["id"] = 605,
                    ["image"] = 607706,
                    ["name"] = "Maid der Trauer",
                }, -- [2]
                {
                    ["id"] = 606,
                    ["image"] = 607797,
                    ["name"] = "Tribunal der Zeitalter",
                }, -- [3]
                {
                    ["id"] = 607,
                    ["image"] = 607772,
                    ["name"] = "Sjonnir der Eisenformer",
                }, -- [4]
            },
        }, -- [23]
        {
            ["id"] = 284,
            ["image"] = 608224,
            ["name"] = "Prüfung des Champions",
            ["bosses"] = {
                {
                    ["id"] = 834,
                    ["image"] = 607621,
                    ["name"] = "Großchampions",
                }, -- [1]
                {
                    ["id"] = 635,
                    ["image"] = 607591,
                    ["name"] = "Eadric der Reine",
                }, -- [2]
                {
                    ["id"] = 636,
                    ["image"] = 607547,
                    ["name"] = "Argentumbeichtpatin Blondlocke",
                }, -- [3]
                {
                    ["id"] = 637,
                    ["image"] = 607787,
                    ["name"] = "Der Schwarze Ritter",
                }, -- [4]
            },
        }, -- [24]
        {
            ["id"] = 286,
            ["image"] = 608227,
            ["name"] = "Turm Utgarde",
            ["bosses"] = {
                {
                    ["id"] = 641,
                    ["image"] = 607778,
                    ["name"] = "Svala Grabesleid",
                }, -- [1]
                {
                    ["id"] = 642,
                    ["image"] = 607620,
                    ["name"] = "Gortok Bleichhuf",
                }, -- [2]
                {
                    ["id"] = 643,
                    ["image"] = 607773,
                    ["name"] = "Skadi der Skrupellose",
                }, -- [3]
                {
                    ["id"] = 644,
                    ["image"] = 607674,
                    ["name"] = "König Ymiron",
                }, -- [4]
            },
        }, -- [25]
    },
    ["Warlords of Draenor"] = {
        {
            ["id"] = 557,
            ["image"] = 1041995,
            ["name"] = "Draenor",
            ["bosses"] = {
                {
                    ["id"] = 1291,
                    ["image"] = 1044483,
                    ["name"] = "Drov der Verheerer",
                }, -- [1]
                {
                    ["id"] = 1211,
                    ["image"] = 1044371,
                    ["name"] = "Tarlna der Zeitlose",
                }, -- [2]
                {
                    ["id"] = 1262,
                    ["image"] = 1044364,
                    ["name"] = "Rukhmar",
                }, -- [3]
                {
                    ["id"] = 1452,
                    ["image"] = 1134508,
                    ["name"] = "Oberster Verdammnislord Kazzak",
                }, -- [4]
            },
        }, -- [1]
        {
            ["id"] = 477,
            ["image"] = 1041997,
            ["name"] = "Hochfels",
            ["bosses"] = {
                {
                    ["id"] = 1128,
                    ["image"] = 1044352,
                    ["name"] = "Kargath Messerfaust",
                }, -- [1]
                {
                    ["id"] = 971,
                    ["image"] = 1044375,
                    ["name"] = "Der Schlächter",
                }, -- [2]
                {
                    ["id"] = 1195,
                    ["image"] = 1044372,
                    ["name"] = "Tectus",
                }, -- [3]
                {
                    ["id"] = 1196,
                    ["image"] = 1044342,
                    ["name"] = "Farnspore",
                }, -- [4]
                {
                    ["id"] = 1148,
                    ["image"] = 1044377,
                    ["name"] = "Ogronzwillinge",
                }, -- [5]
                {
                    ["id"] = 1153,
                    ["image"] = 1044343,
                    ["name"] = "Ko'ragh",
                }, -- [6]
                {
                    ["id"] = 1197,
                    ["image"] = 1044349,
                    ["name"] = "Kaiser Mar'gok",
                }, -- [7]
            },
        }, -- [2]
        {
            ["id"] = 457,
            ["image"] = 1041993,
            ["name"] = "Schwarzfelsgießerei",
            ["bosses"] = {
                {
                    ["id"] = 1202,
                    ["image"] = 1044484,
                    ["name"] = "Erzfresser",
                }, -- [1]
                {
                    ["id"] = 1155,
                    ["image"] = 1044345,
                    ["name"] = "Hans'gar und Franzok",
                }, -- [2]
                {
                    ["id"] = 1122,
                    ["image"] = 1044338,
                    ["name"] = "Abrichter Darmac",
                }, -- [3]
                {
                    ["id"] = 1161,
                    ["image"] = 1044346,
                    ["name"] = "Gruul",
                }, -- [4]
                {
                    ["id"] = 1123,
                    ["image"] = 1044344,
                    ["name"] = "Flammenbändigerin Ka'graz",
                }, -- [5]
                {
                    ["id"] = 1147,
                    ["image"] = 1044357,
                    ["name"] = "Zugführer Thogar",
                }, -- [6]
                {
                    ["id"] = 1154,
                    ["image"] = 1044374,
                    ["name"] = "Der Schmelzofen",
                }, -- [7]
                {
                    ["id"] = 1162,
                    ["image"] = 1044353,
                    ["name"] = "Kromog",
                }, -- [8]
                {
                    ["id"] = 1203,
                    ["image"] = 1044350,
                    ["name"] = "Die Eisernen Jungfern",
                }, -- [9]
                {
                    ["id"] = 959,
                    ["image"] = 1044378,
                    ["name"] = "Schwarzfaust",
                }, -- [10]
            },
        }, -- [3]
        {
            ["id"] = 669,
            ["image"] = 1135118,
            ["name"] = "Höllenfeuerzitadelle",
            ["bosses"] = {
                {
                    ["id"] = 1426,
                    ["image"] = 1134502,
                    ["name"] = "Höllenfeuerangriff",
                }, -- [1]
                {
                    ["id"] = 1425,
                    ["image"] = 1134499,
                    ["name"] = "Eiserner Häscher",
                }, -- [2]
                {
                    ["id"] = 1392,
                    ["image"] = 1134504,
                    ["name"] = "Kormrok",
                }, -- [3]
                {
                    ["id"] = 1432,
                    ["image"] = 1134501,
                    ["name"] = "Hoher Rat des Höllenfeuers",
                }, -- [4]
                {
                    ["id"] = 1396,
                    ["image"] = 1134503,
                    ["name"] = "Kilrogg Totauge",
                }, -- [5]
                {
                    ["id"] = 1372,
                    ["image"] = 1134500,
                    ["name"] = "Blutschatten",
                }, -- [6]
                {
                    ["id"] = 1433,
                    ["image"] = 1134506,
                    ["name"] = "Schattenfürst Iskar",
                }, -- [7]
                {
                    ["id"] = 1427,
                    ["image"] = 1134507,
                    ["name"] = "Socrethar der Ewige",
                }, -- [8]
                {
                    ["id"] = 1391,
                    ["image"] = 1134498,
                    ["name"] = "Teufelslord Zakuun",
                }, -- [9]
                {
                    ["id"] = 1447,
                    ["image"] = 1134510,
                    ["name"] = "Xhul'horac",
                }, -- [10]
                {
                    ["id"] = 1394,
                    ["image"] = 1134509,
                    ["name"] = "Tyrannin Velhari",
                }, -- [11]
                {
                    ["id"] = 1395,
                    ["image"] = 1134505,
                    ["name"] = "Mannoroth",
                }, -- [12]
                {
                    ["id"] = 1438,
                    ["image"] = 1134497,
                    ["name"] = "Archimonde",
                }, -- [13]
            },
        }, -- [4]
        {
            ["id"] = 547,
            ["image"] = 1041992,
            ["name"] = "Auchindoun",
            ["bosses"] = {
                {
                    ["id"] = 1185,
                    ["image"] = 1044336,
                    ["name"] = "Kaathar der Wachsame",
                }, -- [1]
                {
                    ["id"] = 1186,
                    ["image"] = 1044370,
                    ["name"] = "Seelenbinderin Nyami",
                }, -- [2]
                {
                    ["id"] = 1216,
                    ["image"] = 1044337,
                    ["name"] = "Azzakel",
                }, -- [3]
                {
                    ["id"] = 1225,
                    ["image"] = 1044373,
                    ["name"] = "Teron'gor",
                }, -- [4]
            },
        }, -- [5]
        {
            ["id"] = 385,
            ["image"] = 1041994,
            ["name"] = "Blutschlägermine",
            ["bosses"] = {
                {
                    ["id"] = 893,
                    ["image"] = 1044355,
                    ["name"] = "Magmolatus",
                }, -- [1]
                {
                    ["id"] = 888,
                    ["image"] = 1044368,
                    ["name"] = "Sklavenwächter Crushto",
                }, -- [2]
                {
                    ["id"] = 887,
                    ["image"] = 1044363,
                    ["name"] = "Roltall",
                }, -- [3]
                {
                    ["id"] = 889,
                    ["image"] = 1044347,
                    ["name"] = "Gug'rokk",
                }, -- [4]
            },
        }, -- [6]
        {
            ["id"] = 556,
            ["image"] = 1060547,
            ["name"] = "Der Immergrüne Flor",
            ["bosses"] = {
                {
                    ["id"] = 1214,
                    ["image"] = 1044381,
                    ["name"] = "Bleichborke",
                }, -- [1]
                {
                    ["id"] = 1207,
                    ["image"] = 1053563,
                    ["name"] = "Uralte Beschützer",
                }, -- [2]
                {
                    ["id"] = 1208,
                    ["image"] = 1044335,
                    ["name"] = "Erzmagierin Sol",
                }, -- [3]
                {
                    ["id"] = 1209,
                    ["image"] = 1044382,
                    ["name"] = "Xeri'tac",
                }, -- [4]
                {
                    ["id"] = 1210,
                    ["image"] = 1044383,
                    ["name"] = "Yalnu",
                }, -- [5]
            },
        }, -- [7]
        {
            ["id"] = 558,
            ["image"] = 1060548,
            ["name"] = "Eisendocks",
            ["bosses"] = {
                {
                    ["id"] = 1235,
                    ["image"] = 1044380,
                    ["name"] = "Fleischfetzer Nok'gar",
                }, -- [1]
                {
                    ["id"] = 1236,
                    ["image"] = 1044340,
                    ["name"] = "Überwacher des Grimmgleises",
                }, -- [2]
                {
                    ["id"] = 1237,
                    ["image"] = 1044359,
                    ["name"] = "Oshir",
                }, -- [3]
                {
                    ["id"] = 1238,
                    ["image"] = 1044367,
                    ["name"] = "Skulloc",
                }, -- [4]
            },
        }, -- [8]
        {
            ["id"] = 536,
            ["image"] = 1041996,
            ["name"] = "Grimmgleisdepot",
            ["bosses"] = {
                {
                    ["id"] = 1138,
                    ["image"] = 1044360,
                    ["name"] = "Raketenfunken und Borka",
                }, -- [1]
                {
                    ["id"] = 1163,
                    ["image"] = 1044339,
                    ["name"] = "Nitrogg Donnerturm",
                }, -- [2]
                {
                    ["id"] = 1133,
                    ["image"] = 1044376,
                    ["name"] = "Himmelsfürstin Tovra",
                }, -- [3]
            },
        }, -- [9]
        {
            ["id"] = 476,
            ["image"] = 1041999,
            ["name"] = "Himmelsnadel",
            ["bosses"] = {
                {
                    ["id"] = 965,
                    ["image"] = 1044362,
                    ["name"] = "Ranjit",
                }, -- [1]
                {
                    ["id"] = 966,
                    ["image"] = 1044334,
                    ["name"] = "Araknath",
                }, -- [2]
                {
                    ["id"] = 967,
                    ["image"] = 1044365,
                    ["name"] = "Rukhran",
                }, -- [3]
                {
                    ["id"] = 968,
                    ["image"] = 1044348,
                    ["name"] = "Oberste Weise Viryx",
                }, -- [4]
            },
        }, -- [10]
        {
            ["id"] = 559,
            ["image"] = 1042000,
            ["name"] = "Obere Schwarzfelsspitze",
            ["bosses"] = {
                {
                    ["id"] = 1226,
                    ["image"] = 1044358,
                    ["name"] = "Erzformer Gor'ashan",
                }, -- [1]
                {
                    ["id"] = 1227,
                    ["image"] = 1044354,
                    ["name"] = "Kyrak",
                }, -- [2]
                {
                    ["id"] = 1228,
                    ["image"] = 1044351,
                    ["name"] = "Kommandant Tharbek",
                }, -- [3]
                {
                    ["id"] = 1229,
                    ["image"] = 1044361,
                    ["name"] = "Zornschwinge die Ungezähmte",
                }, -- [4]
                {
                    ["id"] = 1234,
                    ["image"] = 1044379,
                    ["name"] = "Kriegsfürstin Zaela",
                }, -- [5]
            },
        }, -- [11]
        {
            ["id"] = 537,
            ["image"] = 1041998,
            ["name"] = "Schattenmondgrabstätte",
            ["bosses"] = {
                {
                    ["id"] = 1139,
                    ["image"] = 1044366,
                    ["name"] = "Sadana Blutfuror",
                }, -- [1]
                {
                    ["id"] = 1168,
                    ["image"] = 1053564,
                    ["name"] = "Nhallish",
                }, -- [2]
                {
                    ["id"] = 1140,
                    ["image"] = 1044341,
                    ["name"] = "Knochenschlund",
                }, -- [3]
                {
                    ["id"] = 1160,
                    ["image"] = 1044356,
                    ["name"] = "Ner'zhul",
                }, -- [4]
            },
        }, -- [12]
    },
    ["Schattenlande"] = {
        {
            ["id"] = 1192,
            ["image"] = 3850569,
            ["name"] = "Schattenlande",
            ["bosses"] = {
                {
                    ["id"] = 2430,
                    ["image"] = 3752195,
                    ["name"] = "Valinor, das Licht der Äonen",
                }, -- [1]
                {
                    ["id"] = 2431,
                    ["image"] = 3752183,
                    ["name"] = "Mortanis",
                }, -- [2]
                {
                    ["id"] = 2432,
                    ["image"] = 3752188,
                    ["name"] = "Oranomonos die Immersprießende",
                }, -- [3]
                {
                    ["id"] = 2433,
                    ["image"] = 3752187,
                    ["name"] = "Nurgash Schlammborn",
                }, -- [4]
                {
                    ["id"] = 2456,
                    ["image"] = 4071436,
                    ["name"] = "Mor'geth, Peiniger der Verdammten",
                }, -- [5]
                {
                    ["id"] = 2468,
                    ["image"] = 4529365,
                    ["name"] = "Antros",
                }, -- [6]
            },
        }, -- [1]
        {
            ["id"] = 1190,
            ["image"] = 3759906,
            ["name"] = "Schloss Nathria",
            ["bosses"] = {
                {
                    ["id"] = 2393,
                    ["image"] = 3752190,
                    ["name"] = "Schrillschwinge",
                }, -- [1]
                {
                    ["id"] = 2429,
                    ["image"] = 3753151,
                    ["name"] = "Jäger Altimor",
                }, -- [2]
                {
                    ["id"] = 2422,
                    ["image"] = 3753157,
                    ["name"] = "Rettung des Sonnenkönigs",
                }, -- [3]
                {
                    ["id"] = 2418,
                    ["image"] = 3752156,
                    ["name"] = "Konstrukteur Xy'mox",
                }, -- [4]
                {
                    ["id"] = 2428,
                    ["image"] = 3752174,
                    ["name"] = "Hungernder Zerstörer",
                }, -- [5]
                {
                    ["id"] = 2420,
                    ["image"] = 3752178,
                    ["name"] = "Lady Inerva Dunkelader",
                }, -- [6]
                {
                    ["id"] = 2426,
                    ["image"] = 3753159,
                    ["name"] = "Der Rat des Blutes",
                }, -- [7]
                {
                    ["id"] = 2394,
                    ["image"] = 3752191,
                    ["name"] = "Schlickfaust",
                }, -- [8]
                {
                    ["id"] = 2425,
                    ["image"] = 3753156,
                    ["name"] = "Generäle der Steinlegion",
                }, -- [9]
                {
                    ["id"] = 2424,
                    ["image"] = 3752159,
                    ["name"] = "Graf Denathrius",
                }, -- [10]
            },
        }, -- [2]
        {
            ["id"] = 1193,
            ["image"] = 4182020,
            ["name"] = "Sanktum der Herrschaft",
            ["bosses"] = {
                {
                    ["id"] = 2435,
                    ["image"] = 4071444,
                    ["name"] = "Der Tarragrue",
                }, -- [1]
                {
                    ["id"] = 2442,
                    ["image"] = 4071426,
                    ["name"] = "Das Auge des Kerkermeisters",
                }, -- [2]
                {
                    ["id"] = 2439,
                    ["image"] = 4071445,
                    ["name"] = "Die Neun",
                }, -- [3]
                {
                    ["id"] = 2444,
                    ["image"] = 4071439,
                    ["name"] = "Überrest von Ner'zhul",
                }, -- [4]
                {
                    ["id"] = 2445,
                    ["image"] = 4071442,
                    ["name"] = "Seelenfetzer Dormazain",
                }, -- [5]
                {
                    ["id"] = 2443,
                    ["image"] = 4079051,
                    ["name"] = "Leidensschmied Raznal",
                }, -- [6]
                {
                    ["id"] = 2446,
                    ["image"] = 4071428,
                    ["name"] = "Wächter der Ersten",
                }, -- [7]
                {
                    ["id"] = 2447,
                    ["image"] = 4071427,
                    ["name"] = "Schicksalsschreiber Roh-Kalo",
                }, -- [8]
                {
                    ["id"] = 2440,
                    ["image"] = 4071435,
                    ["name"] = "Kel'Thuzad",
                }, -- [9]
                {
                    ["id"] = 2441,
                    ["image"] = 4071443,
                    ["name"] = "Sylvanas Windläufer",
                }, -- [10]
            },
        }, -- [3]
        {
            ["id"] = 1195,
            ["image"] = 4423752,
            ["name"] = "Mausoleum der Ersten",
            ["bosses"] = {
                {
                    ["id"] = 2458,
                    ["image"] = 4465340,
                    ["name"] = "Aufmerksamer Wächter",
                }, -- [1]
                {
                    ["id"] = 2465,
                    ["image"] = 4465339,
                    ["name"] = "Skolex, der unersättliche Räuber",
                }, -- [2]
                {
                    ["id"] = 2470,
                    ["image"] = 4423749,
                    ["name"] = "Konstrukteur Xy'mox",
                }, -- [3]
                {
                    ["id"] = 2459,
                    ["image"] = 4465333,
                    ["name"] = "Dausegne, das gefallene Orakel",
                }, -- [4]
                {
                    ["id"] = 2460,
                    ["image"] = 4465337,
                    ["name"] = "Prototypenpantheon",
                }, -- [5]
                {
                    ["id"] = 2461,
                    ["image"] = 4465335,
                    ["name"] = "Lihuvim, der oberste Architekt",
                }, -- [6]
                {
                    ["id"] = 2463,
                    ["image"] = 4423738,
                    ["name"] = "Halondrus der Rückgewinner",
                }, -- [7]
                {
                    ["id"] = 2469,
                    ["image"] = 4423747,
                    ["name"] = "Anduin Wrynn",
                }, -- [8]
                {
                    ["id"] = 2457,
                    ["image"] = 4465336,
                    ["name"] = "Lords des Schreckens",
                }, -- [9]
                {
                    ["id"] = 2467,
                    ["image"] = 4465338,
                    ["name"] = "Rygelon",
                }, -- [10]
                {
                    ["id"] = 2464,
                    ["image"] = 4465334,
                    ["name"] = "Der Kerkermeister",
                }, -- [11]
            },
        }, -- [4]
        {
            ["id"] = 1188,
            ["image"] = 3759915,
            ["name"] = "Die Andre Seite",
            ["bosses"] = {
                {
                    ["id"] = 2408,
                    ["image"] = 3752170,
                    ["name"] = "Hakkar der Seelenschinder",
                }, -- [1]
                {
                    ["id"] = 2409,
                    ["image"] = 3752193,
                    ["name"] = "Die Manasturms",
                }, -- [2]
                {
                    ["id"] = 2398,
                    ["image"] = 3753147,
                    ["name"] = "Händlerin Xy'exa",
                }, -- [3]
                {
                    ["id"] = 2410,
                    ["image"] = 3752184,
                    ["name"] = "Mueh'zala",
                }, -- [4]
            },
        }, -- [5]
        {
            ["id"] = 1189,
            ["image"] = 3759912,
            ["name"] = "Die Blutigen Tiefen",
            ["bosses"] = {
                {
                    ["id"] = 2388,
                    ["image"] = 3753153,
                    ["name"] = "Kryxis der Gefräßige",
                }, -- [1]
                {
                    ["id"] = 2415,
                    ["image"] = 3753148,
                    ["name"] = "Henker Tarvold",
                }, -- [2]
                {
                    ["id"] = 2421,
                    ["image"] = 3753149,
                    ["name"] = "Großaufseherin Beryllia",
                }, -- [3]
                {
                    ["id"] = 2407,
                    ["image"] = 3752167,
                    ["name"] = "Generalin Kaal",
                }, -- [4]
            },
        }, -- [6]
        {
            ["id"] = 1184,
            ["image"] = 3759909,
            ["name"] = "Die Nebel von Tirna Scithe",
            ["bosses"] = {
                {
                    ["id"] = 2400,
                    ["image"] = 3753152,
                    ["name"] = "Ingra Maloch",
                }, -- [1]
                {
                    ["id"] = 2402,
                    ["image"] = 3752181,
                    ["name"] = "Nebelruferin",
                }, -- [2]
                {
                    ["id"] = 2405,
                    ["image"] = 3752194,
                    ["name"] = "Tred'ova",
                }, -- [3]
            },
        }, -- [7]
        {
            ["id"] = 1182,
            ["image"] = 3759910,
            ["name"] = "Die Nekrotische Schneise",
            ["bosses"] = {
                {
                    ["id"] = 2395,
                    ["image"] = 3752157,
                    ["name"] = "Pestknochen",
                }, -- [1]
                {
                    ["id"] = 2391,
                    ["image"] = 3753146,
                    ["name"] = "Amarth der Ernter",
                }, -- [2]
                {
                    ["id"] = 2392,
                    ["image"] = 3753158,
                    ["name"] = "Chirurg Fleischnaht",
                }, -- [3]
                {
                    ["id"] = 2396,
                    ["image"] = 3753155,
                    ["name"] = "Nalthor der Eisbinder",
                }, -- [4]
            },
        }, -- [8]
        {
            ["id"] = 1186,
            ["image"] = 3759913,
            ["name"] = "Die Spitzen des Aufstiegs",
            ["bosses"] = {
                {
                    ["id"] = 2399,
                    ["image"] = 3752177,
                    ["name"] = "Kin-Tara",
                }, -- [1]
                {
                    ["id"] = 2416,
                    ["image"] = 3752198,
                    ["name"] = "Ventunax",
                }, -- [2]
                {
                    ["id"] = 2414,
                    ["image"] = 3752189,
                    ["name"] = "Oryphrion",
                }, -- [3]
                {
                    ["id"] = 2412,
                    ["image"] = 3752160,
                    ["name"] = "Devos, Paragon des Zweifels",
                }, -- [4]
            },
        }, -- [9]
        {
            ["id"] = 1185,
            ["image"] = 3759908,
            ["name"] = "Hallen der Sühne",
            ["bosses"] = {
                {
                    ["id"] = 2406,
                    ["image"] = 3752171,
                    ["name"] = "Halkias, der Sündenbefleckte Goliath",
                }, -- [1]
                {
                    ["id"] = 2387,
                    ["image"] = 3752165,
                    ["name"] = "Echelon",
                }, -- [2]
                {
                    ["id"] = 2411,
                    ["image"] = 3753150,
                    ["name"] = "Hochadjudikatorin Aleez",
                }, -- [3]
                {
                    ["id"] = 2413,
                    ["image"] = 3752179,
                    ["name"] = "Oberster Kämmerer",
                }, -- [4]
            },
        }, -- [10]
        {
            ["id"] = 1183,
            ["image"] = 3759911,
            ["name"] = "Seuchensturz",
            ["bosses"] = {
                {
                    ["id"] = 2419,
                    ["image"] = 3752168,
                    ["name"] = "Globgrog",
                }, -- [1]
                {
                    ["id"] = 2403,
                    ["image"] = 3752162,
                    ["name"] = "Doktor Ickus",
                }, -- [2]
                {
                    ["id"] = 2423,
                    ["image"] = 3752163,
                    ["name"] = "Domina Giftklinge",
                }, -- [3]
                {
                    ["id"] = 2404,
                    ["image"] = 3752180,
                    ["name"] = "Markgräfin Stradama",
                }, -- [4]
            },
        }, -- [11]
        {
            ["id"] = 1194,
            ["image"] = 4182022,
            ["name"] = "Tazavesh, der Verhüllte Markt",
            ["bosses"] = {
                {
                    ["id"] = 2437,
                    ["image"] = 4071449,
                    ["name"] = "Zo'phex der Wächter",
                }, -- [1]
                {
                    ["id"] = 2454,
                    ["image"] = 4071447,
                    ["name"] = "Die Große Menagerie",
                }, -- [2]
                {
                    ["id"] = 2436,
                    ["image"] = 4071438,
                    ["name"] = "Postraumfiasko",
                }, -- [3]
                {
                    ["id"] = 2452,
                    ["image"] = 4071448,
                    ["name"] = "Myzas Oase",
                }, -- [4]
                {
                    ["id"] = 2451,
                    ["image"] = 4071440,
                    ["name"] = "So'azmi",
                }, -- [5]
                {
                    ["id"] = 2448,
                    ["image"] = 4071429,
                    ["name"] = "Hylbrand",
                }, -- [6]
                {
                    ["id"] = 2449,
                    ["image"] = 4071446,
                    ["name"] = "Zeitkäpt'n Hakenschwanz",
                }, -- [7]
                {
                    ["id"] = 2455,
                    ["image"] = 4071441,
                    ["name"] = "So'leah",
                }, -- [8]
            },
        }, -- [12]
        {
            ["id"] = 1187,
            ["image"] = 3759914,
            ["name"] = "Theater der Schmerzen",
            ["bosses"] = {
                {
                    ["id"] = 2397,
                    ["image"] = 3752153,
                    ["name"] = "Ein Affront der Herausforderer",
                }, -- [1]
                {
                    ["id"] = 2401,
                    ["image"] = 3752169,
                    ["name"] = "Bluthack",
                }, -- [2]
                {
                    ["id"] = 2390,
                    ["image"] = 3752199,
                    ["name"] = "Xav der Unbesiegte",
                }, -- [3]
                {
                    ["id"] = 2389,
                    ["image"] = 3753154,
                    ["name"] = "Kul'tharok",
                }, -- [4]
                {
                    ["id"] = 2417,
                    ["image"] = 3752182,
                    ["name"] = "Mordretha, die Unendliche Kaiserin",
                }, -- [5]
            },
        }, -- [13]
    },
}