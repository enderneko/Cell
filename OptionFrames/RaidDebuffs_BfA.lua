local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

-- taken from Grid2
local debuffs = {
    [477] = {
        [971] = {
            156151,
            -- 156152,
        },
    },
    [1030] = { -- Temple of Sethraliss
        [2142] = { -- Adderis and Aspix
            263371, -- Conduction
            263234, -- Arcing Blade
            268993, -- Golpe bajo
            263778, -- Fuerza de vendaval
            225080, -- reincarnation
        },
        [2143] = { -- Merektha
            267027, -- Cytotoxin
            263958, -- A Knot of Snakes
            261732, -- Blinding Sand
            263927, -- Charco t�xico
        },
        [2144] = { -- Galvazzt
            266512, -- Consume Charge
            266923, -- Galvanizar
        },
        [2145] = { -- Avatar of Sethraliss
            269686, -- Plague
            269670, -- Potenciaci�n
            268024, -- Pulso
        },
        ["general"] = {
            273563, -- Neurotoxina
            272657, -- Aliento nocivo
            272655, -- Arena asoladora
            272696, -- Rel�mpagos embotellados
            272699, -- Flema venenosa
            268013, -- Choque de llamas
            268007, -- Ataque al coraz�n
            268008, -- Amuleto de serpiente
        },
    },
    [1001] = { -- Freehold
        [2102] = { -- Skycap'n Kragg
            278993, -- Vile Bombardment
        },
        [2093] = { -- Council o' Captains
            258874, -- Blackout Barrel
            267523, -- Oleada cortante
            1604,   -- Atontado
        },
        [2094] = { -- Ring of Booty
            256553, -- Flailing Shark
            256363, -- Pu�etazo desgarrador
        },
        [2095] = { -- Harlan Sweete
            281591, -- Cannon Barrage
            257460, -- Escombros igneos
            257314, -- Bomba de polvora negra
        },
        ["general"] = {
            257908, -- Hoja aceitada
            257478, -- Mordedura entorpecedora
            274384, -- Trampas para ratas
        }
    },
    [1022] = { -- The Underrot
        [2157] = { -- Elder Leaxa
            260685, -- Taint of G'huun
        },
        [2131] = { -- Cragmaw the Infested
            260333, -- Tantrum
            260455, -- Colmillos serrados
        },
        [2130] = { -- Sporecaller Zancha
            259714, -- Decaying Spores
            259718, -- Agitaci�n
            273226, -- Esporas putrefactas
        },
        [2158] = { -- Unbound Abomination
            269301, -- Putrid Blood
        },
        ["general"] = {
            265533, -- Fauce sangrienta
            265019, -- Tajo salvaje
            265377, -- Trampa con gancho
            265568, -- Presagio oscuro
            266107, -- Sed de sangre
            266265, -- Asalto malvado
            272180, -- Descarga mortal
            265468, -- Maldici�n fulminante
            272609, -- Mirada enloquecedora
            265511, -- Drenaje de esp�ritu
            278961, -- Mente putrefacta
            273599, -- Aliento podrido
        },
    },
    [968] = { -- Atal'Dazar
        [2082] = { -- Priestess Alun'za
            274195, -- Corrupted Blood
            277072, -- Corrupted Gold
            265914, -- Molten Gold
            255835, -- Transfusion
            255836, -- Transfusion
        },
        [2036] = { -- Vol'kaal
            263927, -- Toxic Pool
            250372, -- Lingering Nausea
            255620, -- Erupci�n purulenta
        },
        [2083] = { -- Rezan
            255434, -- Serrated Teeth
            255371, -- Terrifying Visage
            257407, -- Pursuit
            255421, -- Devour
        },
        [2030] = { -- Yazma
            250096, -- Dolor atroz
            259145, -- Soulrend
            249919, -- Skewer
        },
        ["general"] = {
            253562, -- Fuego salvaje
            254959, -- Quemar alma
            260668, -- Transfusion
            255567, -- Carga fren�tica
            279118, -- Maleficio inestable
            252692, -- Golpe embotador
            252687, -- Golpe de Venolmillo
            255041, -- Chirrido aterrorizador
            255814, -- Acometida desgarradora
        },
    },
    [1036] = { -- Shrine of the Storm
        [2153] = { -- Aqu'sirr
            264560, -- Choking Brine
            264477, -- Grasp from the Depths
        },
        [2154] = { -- Tidesage Council
            267899, -- Hindering Cleave
            267818, -- Viento cortante
        },
        [2155] = { -- Lord Stormsong
            268896, -- Mind Rend
            269104, -- Vac�o explosivo
            269131, -- Dominamentes ancestral
        },
        [2156] = { -- Vol'zith the Whisperer
                267034, -- Whispers of Power
        },
        ["general"] = {
            268233, -- Choque electrizante
            274633, -- Arremetida hendiente
            268309, -- Oscuridad infinita
            268315, -- Latigazo
            268317, -- Desgarrar mente
            268322, -- Toque de los ahogados
            268391, -- Ataque mental
            274720, -- Golpe abisal
            276268, -- Golpe tumultuoso
            268059, -- Ancla de vinculaci�n
            268027, -- Mareas crecientes
            268214, -- Grabar carne
        },
    },
    [1002] = { -- Tol Dagor
        [2097] = { -- The Sand Queen
            257092, -- Sand Trap
            260016, -- Mordedura irritante
        },
        [2098] = { -- Jes Howlis
            257791, -- Howling Fear
            257777, -- Chafarote entorpecedor
            257793, -- Polvo de humo
            260067, -- Vapuleo sa�oso
        },
        [2099] = { -- Knight Captain Valyri
            257028, -- Fuselighter
            259711, -- A cal y canto
        },
        [2096] = { -- Overseer Korgus
            256198, -- Azerite Rounds: Incendiary
            256038, -- Deadeye
            256044, -- Deadeye
            256200, -- Veneno Muerte Diestra
            256105, -- R�faga explosiva
            256201, -- Cartuchos incendiarios
        },
        ["general"] = {
            258864, -- Fuego de supresi�n
            258313, -- Esposar
            258079, -- Dentellada enorme
            258075, -- Mordedura irritante
            258058, -- Exprimir
            265889, -- Golpe de antorcha
            258128, -- Grito debilitante
            225080, -- Reencarnaci�n
        },
    },
    [1021] = { -- Waycrest Manor
        [2125] = { -- Heartsbane Triad
            260741, -- Jagged Nettles
            260926, -- Soul Manipulation
            260703, -- Unstable Runic Mark
        },
        [2126] = { -- Soulbound Goliath
            260551, -- Soul Thorns
        },
        [2127] = { -- Raal the Gluttonous
            268231, -- Rotten Expulsion
        },
        [2128] = { -- Lord and Lady Waycrest
            261439, -- Virulent Pathogen
            261438, -- Golpe extenuante
            261440, -- Patogeno virulento
        },
        [2129] = { -- Gorak Tul
            268203, -- Death Lens
        },
        ["general"] = {
            263905, -- Tajo marcador
            265352, -- A�ublo de sapo
            266036, -- Drenar esencia
            264105, -- Se�al r�nica
            264390, -- Hechizo de vinculaci�n
            265346, -- Mirada p�lida
            264050, -- Espina infectada
            265761, -- Tromba espinosa
            264153, -- Flema
            265407, -- Campanilla para la cena
            271178, -- Salto devastador
            263943, -- Grabar
            264520, -- Serpiente mutiladora
            265881, -- Toque putrefacto
            264378, -- Fragmentar alma
            264407, -- Rostro horripilante
            265880, -- Marca p�rfida
            265882, -- Pavor persistente
            266035, -- Astilla de hueso
            263891, -- Espinas enredadoras
            264556, -- Golpe desgarrador
            278456, -- Infestar
        },
    },
    [1012] = { -- The MOTHERLODE!!
        [2109] = { -- Coin-Operated Crowd Pummeler
            256137, -- Timed Detonation
            257333, -- Shocking Claw
            262347, -- Pulso est�tico
            270882, -- Azerita llameante
        },
        [2114] = { -- Azerokk
            257582, -- Raging Gaze
            258627, -- Resonant Quake
            257544, -- Corte dentado
            275907, -- Machaque tect�nico
        },
        [2115] = { -- Rixxa Fluxflame
            258971, -- Azerite Catalyst
            259940, -- Propellant Blast
            259853, -- Quemadura qu�mica
        },
        [2116] = { -- Mogul Razdunk
            260811, -- Homing Missile
            260829, -- Misil buscador
            260838, -- Misil buscador
            270277, -- Cohete rojo grande
        },
        ["general"] = {
            280604, -- Chorro helado
            280605, -- Congelaci�n cerebral
            263637, -- Tendedero
            269298, -- Toxina de creaviudas
            263202, -- Lanza de roca
            268704, -- Temblor furioso
            268846, -- Hoja de eco
            263074, -- Mordedura degenerativa
            262270, -- Compuesto c�ustico
            262794, -- Latigazo de energ�a
            262811, -- Gl�bulo parasitario
            268797, -- Transmutar: enemigo en baba
            269429, -- Disparo cargado
            262377, -- Buscar y destruir
            262348, -- Deflagraci�n de mina
            269092, -- Tromba de artiller�a
            262515, -- Buscacorazones de azerita
            262513, -- Buscacorazones de azerita
        },
    },
    [1023] = { -- Siege of Boralus
        [2133] = { -- Chopper Redhook
            257459, -- On the Hook
            257288, -- Heavy Slash
        },
        [2173] = { -- Dread Captain Lockwood
            256076, -- Gut Shot
        },
        [2134] = { -- Hadal Darkfathom
            257882, -- Break Water
            257862, -- Crashing Tide
        },
        [2140] = { -- Viq'Goth
            274991, -- Putrid Waters
        },
    },
    [1041] = { -- Kings' Rest
        [2165] = { -- The Golden Serpent
            265773, -- Spit Gold
            265914, -- Molten Gold
        },
        [2171] = { -- Mchimba the Embalmer
            267626, -- Dessication
            267702, -- Entomb
            267764, -- Struggle
            267639, -- Burn Corruption
        },
        [2170] = { -- The Council of Tribes
            267273, -- Poison Nova
            266238, -- Shattered Defenses
            266231, -- Severing Axe
            267257, -- Thundering Crash
        },
        [2172] = { -- Dazar, The First King
            268932, -- Quaking Leap
            268586, -- Blade Combo
        },
    },
    [1178] = { -- Operation: Mechagon
        [2357] = { -- King Gobbamak
            297257, -- electrical-charge
        },
        [2358] = { -- Gunker
            298124, -- gooped
            297913, -- toxic-goop
            298229, -- toxic-fumes
        },
        [2360] = { -- Trixie & Naeno
            298669, -- taze
            298718, -- mega-taze
        },
        [2355] = { -- HK-8 Aerial Oppression Unit
            295445, -- wreck
            302274, -- fulminating-zap
            295939, -- annihilation-ray
            296150, -- vent-blast
        },
        [2336] = { -- Tussle Tonks
            285388, -- vent-jets
        },
        [2339] = { -- K.U.-J.0.
            294929, -- blazing-chomp
            291946, -- venting-flames
        },
        [2348] = { -- Machinist's Garden
            285443, -- hidden-flame-cannon
            294860, -- blossom-blast
            285460, -- discom-bomb-ulator
        },
        [2331] = { -- King Mechagon
            291939, -- giga-zap
        },
        ["general"] = {
            299438, -- sledgehammer
            300207, -- shock-coil
            299475, -- b-o-r-k
            301712, -- pounce
            299502, -- nanoslicer
            294290, -- process-waste
            294195, -- arcing-zap
            293986, -- sonic-pulse
        },
    },
    [1028] = { -- Azeroth -- REVIEW:
        [2139] = { -- T'zane
            261605, -- Consuming Spirits
            261552, -- Terror Wail
        },
        [2141] = { -- Ji'arak
            260989, -- Storm Wing
            261509, -- Clutch
        },
        [2197] = { -- Hailstone Construct
            274895, -- Freezing Tempest
            274891, -- Glacial Breath
        },
        [2199] = { -- Azurethos, The Winged Typhoon
            274839, -- Azurethos' Fury
        },
        [2213] = { -- Doom's Howl
            271244, -- Demolisher Cannon
        },
        [2198] = { -- Warbringer Yenajz
            274932, -- Endless Abyss
            274904, -- Reality Tear
        },
        [2210] = { -- Dunegorger Kraulok
            275175, -- Sonic Bellow
        },
    },
    [1031] = { -- Uldir
        [2168] = { -- Taloc
            271222, -- Plasma Discharge
            270290, -- Blood Storm
            275270, -- Fixate
            275189, -- Hardened Arteries
            275205, -- Enlarged Heart
        },
        [2167] = { -- MOTHER
            267821, -- Defense Grid
            267787, -- Sanitizing Strike
            268095, -- Cleansing Purge
            268198, -- Clinging Corruption
            268253, -- Surgical Beam
            268277, -- Purifying Flame
        },
        [2146] = { -- Fetid Devourer
            262313, -- Malodorous Miasma
            262314, -- Putrid Paroxysm
            262292, -- Rotting Regurgitation
        },
        [2169] = { -- Zek'voz, Herald of N'zoth
            265360, -- Roiling Deceit
            265662, -- Corruptor's Pact
            265237, -- Shatter
            265264, -- Void Lash
            265646, -- Will of the Corruptor
            264210, -- Jagged Mandible
            270589, -- Void Wail
            270620, -- Psionic Blast
        },
        [2166] = { -- Vectis
            265129, -- Omega Vector
            265178, -- Evolving Affliction
            265212, -- Gestate
            265127, -- Lingering Infection
            265206, -- Immunosuppression
        },
        [2195] = { -- Zul, Reborn
            273365, -- Dark Revelation
            274358, -- Rupturing Blood
            273434, -- Pit of Despair
            274195, -- Corrupted Blood
            274271, -- Deathwish
            272018, -- Absorbed in Darkness
            276020, -- Fixate
            276299, -- Engorged Burst
        },
        [2194] = { -- Mythrax the Unraveler
            272336, -- Annihilation
            272536, -- Imminent Ruin
            274693, -- Essence Shear
            272407, -- Oblivion Sphere
            272146, -- Annihilation
            274019, -- Mind Flay
            274113, -- Obliteration Beam
            274761, -- Oblivion Veil
            279013, -- Essence Shatter
        },
        [2147] = { -- G'huun
            263334, -- Putrid Blood
            263372, -- Power Matrix
            263436, -- Imperfect Physiology
            272506, -- Explosive Corruption
            267409, -- Dark Bargain
            267430, -- Torment
            263235, -- Blood Feast
            270287, -- Blighted Ground
            263321, -- Undulating Mass
            267659, -- Unclean Contagion
            267700, -- Gaze of G'huun
            267813, -- Blood Host
            269691, -- Mind Thrall
            277007, -- Bursting Boil
            279575, -- Choking Miasma
        },
    },
    [1176] = { -- Battle of Dazar'alor
        [2333] = { -- Champion of the Light
            283572, -- Sacred Blade
            283651, -- Blinding Faith
            283579, -- Consecration
        },
        [2341] = { -- Jadefire Masters
            286988, -- Searing Embers
            282037, -- Rising Flames
            288151, -- Tested
            285632, -- Stalking
        },
        [2325] = { -- Grong, the Revenant
            285875, -- Rending Bite
            283069, -- Megatomic Fire (Horde)
            286373, -- Chill of Death (Alliance)
            282215, -- Megatomic Seeker Missile
            282471, -- Voodoo Blast
            285659, -- Apetagonizer Core
            286434, -- Necrotic Core
            285671, -- Crushed
            282010, -- Shattered
        },
        [2342] = { -- Opulence
            283063, -- Flames of Punishment
            283507, -- Volatile Charge
            286501, -- Creeping Blaze
            287072, -- Liquid Gold
            284470, -- Hex of Lethargy
        },
        [2330] = { -- Conclave of the Chosen
            284663, -- Bwonsamdi's Wrath
            282135, -- Crawling Hex
            285878, -- Mind Wipe
            282592, -- Bleeding Wounds
            286060, -- Cry of the Fallen
            282444, -- Lacerating Claws
            286811, -- Akunda's Wrath
            282209, -- Mark of Prey
        },
        [2335] = { -- King Rastakhan
            285195, -- Deadly Withering
            285044, -- Toad Toxin
            284831, -- Scorching Detonation
            284781, -- Grevious Axe
            285213, -- Caress of Death
            288449, -- Death's Door
            284662, -- Seal of Purification
            285349, -- Plague of Fire
        },
        [2334] = { -- High Tinker Mekkatorque
            287167, -- Discombobulation
            283411, -- Gigavolt Blast
            286480, -- Anti Tampering Shock
            287757, -- Gigavolt Charge
            282182, -- Buster Cannon
            284168, -- Shrunk
            284214, -- Trample
            287891, -- Sheep Shrapnel
            289023, -- Enormous
        },
        [2337] = { -- Stormwall Blockade
            285000, -- Kelp Wrapping
            284405, -- Tempting Song
            285350, -- Storms Wail
            285075, -- Freezing Tidepool
            285382, -- Kelp Wrapping
        },
        [2343] = { -- Lady Jaina Proudmoore
            287626, -- Grasp of Frost
            287490,	-- Frozen Solid
            287365, -- Searing Pitch
            285212, -- Chilling Touch
            285253, -- Ice Shard
            287199, -- Ring of Ice
            288218, -- Broadside
            289220, -- Heart of Frost
            288038, -- Marked Target
            287565, -- Avalanche
        },
    },
    [1177] = { -- Crucible of Storms
        [2328] = { -- The Restless Cabal
            282540, -- Agent of demise
            282432, -- Crushing Doubt
            282384, -- Shear Mind
            283524, -- Aphotic Blast
            282517, -- Terrifying Echo
            282562, -- Promises of Power
            282738, -- Embrace of the void
            293300, -- Storm essence
            293488, -- Oceanic Essence
        },
        [2332] = { -- Uu'nat, Harbinger of the Void
            285345, -- Maddening eyes of N'zoth
            285652, -- Insatiable torment
            284733, -- Embrace of the void
            285367  -- Piercing gaze
        },
    },
    [1179] = { -- The Eternal Palace
        [2352] = { -- Abyssal Commander Sivara
            300882, -- Inversion Sickness
            295421, -- Over flowing Venom
            295348, -- Over flowing Chill
            294715, -- Toxic Brand
            294711, -- Frost Mark
            300705, -- Septic Taint
            300701, -- Rimefrost
            294847, -- Unstable Mixture
            300961, -- Frozen Ground
            300962, -- Septic Ground
        },
        [2347] = { -- Blackwater Behemoth
            292127, -- Darkest Depths
            292307, -- Gaze from Below
            292167, -- Toxic Spine
            301494, -- Piercing Barb
            298595, -- Glowing Stinger
            292138, -- Radiant Biomass
            292133, -- Bioluminescence
        },
        [2353] = { -- Radiance of Azshara
            296737, -- Arcane Bomb
            296566, -- Tide Fist
        },
        [2354] = { -- Lady Ashvane
            296693, -- Waterlogged
            297333, -- Briny Bubble
            296725, -- Barnacle Bash
            296752, -- Cutting Coral
        },
        [2351] = { -- Orgozoa
            298306, -- Incubation Fluid
            295779, -- Aqua Lance
            298156, -- Desensitizing Sting
            298306, -- Incubation Fluid
        },
        [2359] = { -- The Queen's Court
            297586, -- Suffering
            299914, -- Frenetic Charge
            296851, -- Fanatical Verdict
            300545, -- Mighty Rupture
        },
        [2349] = { -- Za'qul, Harbinger of Ny'alotha
            292971, -- Hysteria
            292963, -- Dread
            293509, -- Manifest Nightmares
            298192, -- Dark Beyond
        },
        [2361] = { -- Queen Azshara
            303825, -- Crushing Depths
            303657, -- Arcane Burst
            300492, -- Static Shock
            297907, -- Cursed Heart
        },
    },
    [1180] = { -- Ny'alotha, the Waking City
        [2368] = { -- Wrathion, the Black Emperor
            306163, -- Incineration
            314347, -- Noxxious Choke
            307013, -- Burning Madness
            313250, -- Creeping Madness (mythic)
        },
        [2365] = { -- Maut
            307806, -- Devour Magic
            306301, -- Forbidden Mana
            307399, -- Shadow Wounds
            314992, -- Drain Essence
            314337, -- Ancient Curse (mythic)
        },
        [2369] = { -- The Prophet Skitra
            308059, -- Shadow Shock Applied
            307950, -- Shred Psyche
        },
        [2377] = { -- Dark Inquisitor Xanesh
            313198, -- Void Touched
            312406, -- Voidwoken
        },
        [2372] = { -- The Hivemind
            313461, -- Corrosion
            313129, -- Mindless
            313460, -- Nullification
        },
        [2367] = { -- Shad'har the Insatiable
            307358, -- Debilitating Spit
            307945, -- Umbral Eruption
            306929, -- Bubbling Breath
            307260, -- Fixate
            312332, -- Slimy Residue
            306930, -- Entropic Breath
        },
        [2373] = { -- Drest'agath
            310552, -- Mind Flay
            310358, -- Muttering Insanity
        },
        [2374] = { -- Il'gynoth, Corruption Reborn
            275269, -- Fixate
            311159, -- Cursed Blood
        },
        [2370] = { -- Vexiona
            307314, -- Encroaching Shadows
            307359, -- Despair
            310323, -- Desolation
        },
        [2364] = { -- Ra-den the Despoiled
            306819, -- Nullifying Strike
            306273, -- Unstable Vita
            306279, -- Instability Exposure
            309777, -- Void Defilement
            313227, -- Decaying Wound
            310019, -- Charged Bonds
            313077, -- Unstable Nightmare
            315252, -- Dread Inferno Fixate
            316065, -- Corrupted Existence
        },
        [2366] = { -- Carapace of N'Zoth
            307008, -- Breed Madness
            306973, -- Madness Bomb
            306984, -- Insanity Bomb
            307008, -- Breed Madness
        },
        [2375] = { -- N'Zoth the Corruptor
            308885, -- Mind Flay
            317112, -- Evoke Anguish
            309980, -- Paranoia
        },
    },
}
F:LoadBuiltInDebuffs(debuffs)