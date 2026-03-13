---------------------------------------------------------------------
-- File: RaidDebuffs_Midnight.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2026-03-09
-- Note: Spell IDs extracted from wago.tools DB2 JournalEncounterSection.
--       Initial version: all encounter spells enabled.
--       Disable non-debuff spells in-game via the Raid Debuffs config UI.
---------------------------------------------------------------------

---@class Cell
local Cell = select(2, ...)
local F = Cell.funcs

local debuffs = {
    -- ====================================================================
    -- The Voidspire (Raid - 6 bosses)
    -- ====================================================================
    [1307] = {
        ["general"] = {
        },
        [2733] = { -- Imperator Averzian
            1251361, -- Shadow's Advance
            1251583, -- March of the Endless
            1249262, -- Umbral Collapse
            1260712, -- Oblivion's Wrath
            1253918, -- Imperator's Glory
            1249251, -- Dark Upheaval
            1249714, -- Umbral Barrier
            1262036, -- Void Rupture
            1265540, -- Blackening Wounds
            1255683, -- Gnashing Void
            1264164, -- Dark Resilience
            1267205, -- Hobbled
            1255702, -- Pitch Bulwark
            1255749, -- Gathering Darkness
            1258883, -- Void Fall
            1274846, -- Dark Barrage
            1275059, -- Black Miasma
            1280035, -- Cosmic Shell
            1280015, -- Void Marked
            1280075, -- Lingering Darkness
            1283069, -- Weakened
            1284786, -- Shadow Phalanx
        },
        [2734] = { -- Vorasius
            1254199, -- Parasite Expulsion
            1259186, -- Blisterburst
            1241692, -- Shadowclaw Slam
            1256855, -- Void Breath
            1243270, -- Dark Goo
            1241844, -- Smashed
            1260052, -- Primordial Roar
            1244419, -- Overpowering Pulse
            1273067, -- Aftershock
            1272937, -- Primordial Power
            1272527, -- Creep Spit
            1280101, -- Dark Energy
        },
        [2735] = { -- Vaelgor & Ezzorak
            1244221, -- Dread Breath
            1262623, -- Nullbeam
            1244672, -- Nullzone
            1244917, -- Void Howl
            1245175, -- Voidbolt
            1245391, -- Gloom
            1245420, -- Gloomfield
            1245554, -- Gloomtouched
            1249748, -- Midnight Flames
            1245645, -- Rakfang
            1248847, -- Radiant Barrier
            1272867, -- Aura of Light
            1244413, -- Nullsnap
            1252157, -- Nullzone Implosion
            1255763, -- Midnight Manifestation
            1251686, -- Unbound Shadow
            1265152, -- Impale
            1280458, -- Grappling Maw
            1265131, -- Vaelwing
            1264467, -- Tail Lash
            1266570, -- Nullscatter
            1263623, -- Cosmosis
            1270189, -- Twilight Bond
            1270250, -- Twilight Fury
            1270852, -- Diminish
            1270513, -- Shadowmark
        },
        [2736] = { -- Fallen-King Salhadaar
            1246175, -- Entropic Unraveling
            1250686, -- Twisting Obscurity
            1254081, -- Fractured Projection
            1247738, -- Void Convergence
            1254088, -- Shadow Fracture
            1271577, -- Destabilizing Strikes
            1260015, -- Umbral Beams
            1245960, -- Void Infusion
            1250991, -- Dark Radiation
            1253032, -- Shattering Twilight
            1251213, -- Twilight Spikes
            1245592, -- Torturous Extract
            1248697, -- Despotic Command
            1248709, -- Oppressive Darkness
            1275056, -- Nexus Shield
            1250828, -- Void Exposure
        },
        [2737] = { -- Lightblinded Vanguard
            1246162, -- Aura of Devotion
            1251857, -- Judgment
            1246485, -- Avenger's Shield
            1248644, -- Divine Toll
            1248449, -- Aura of Wrath
            1246736, -- Judgment
            1246765, -- Divine Storm
            1246749, -- Sacred Toll
            1248983, -- Execution Sentence
            1248451, -- Aura of Peace
            1246745, -- Exorcism
            1248674, -- Sacred Shield
            1248710, -- Tyr's Wrath
            1251859, -- Shield of the Righteous
            1251812, -- Final Verdict
            1246155, -- Consecration
            1256133, -- Retribution
            1255738, -- Searing Radiance
            1258659, -- Light Infused
            1246391, -- Forbearance
            1276243, -- Zealous Spirit
            1272324, -- Divine Tempest
            1272471, -- Spirit of the Mender
            1272700, -- Spirit of the Defender
            1272699, -- Spirit of the Vindictive
            1276982, -- Divine Consecration
            1246385, -- Avenging Wrath
            1246384, -- Divine Shield
            1258514, -- Blinding Light
            1249047, -- Divine Hammer
            1280159, -- Execution Sentence
            1249130, -- Elekk Charge
        },
        [2738] = { -- Crown of the Cosmos (Xal'atath)
            1239080, -- Aspect of the End
            1232470, -- Grasp of Emptiness
            1233865, -- Null Corona
            1237251, -- Empowering Darkness
            1233602, -- Silverstrike Arrow
            1243982, -- Silverstrike Barrage
            1234569, -- Stellar Emission
            1237614, -- Ranger Captain's Mark
            1237729, -- Silverstrike Ricochet
            1237038, -- Voidstalker Sting
            1256787, -- Call of the Void
            1233470, -- Umbral Tether
            1232784, -- Bursting Emptiness
            1261531, -- Corrupting Essence
            1233689, -- Silver Residue
            1233778, -- Echoing Darkness
            1233787, -- Dark Hand
            1238843, -- Devouring Cosmos
            1260000, -- Void Barrage
            1238206, -- Volatile Fissure
            1238708, -- Dark Rush
            1239089, -- Gravity Collapse
            1239279, -- Echoing Darkness
            1243743, -- Interrupting Tremor
            1243753, -- Ravenous Abyss
            1234564, -- Silverstrike Barrage
            1235622, -- Singularity Eruption
            1245874, -- Orbiting Matter
            1246461, -- Rift Slash
            1246918, -- Cosmic Barrier
            1255368, -- Void Expulsion
            1242553, -- Void Remnants
            1232467, -- Grasp of Emptiness
            1237837, -- Call of the Void
            1237844, -- Umbral Tether
            1238672, -- Coalesced Form
            1233526, -- Corrupting Essence
            1255378, -- Bursting Emptiness
            1261165, -- Empowering Darkness
        },
    },

    -- ====================================================================
    -- March on Quel'Danas (Raid - 2 bosses)
    -- ====================================================================
    [1308] = {
        ["general"] = {
        },
        [2739] = { -- Belo'ren, Child of Al'ar
            1242792, -- Incubation of Flames
            1241313, -- Rebirth
            1241282, -- Embers of Belo'ren
            1242260, -- Infused Quills
            1242981, -- Radiant Echoes
            1242515, -- Voidlight Convergence
            1241162, -- Light Feather
            1241163, -- Void Feather
            1241292, -- Light Dive
            1243852, -- Light Eruption
            1241339, -- Void Dive
            1243854, -- Void Eruption
            1242093, -- Light Quill
            1242094, -- Void Quill
            1243021, -- Light Echo
            1243026, -- Void Echo
            1243866, -- Voidlight Rupture
            1246709, -- Death Drop
            1260763, -- Guardian's Edict
            1261217, -- Light Edict
            1261218, -- Void Edict
            1283067, -- Burning Heart
            1244344, -- Eternal Burns
            1241640, -- Voidlight Edict
            1241838, -- Light Patch
            1241845, -- Void Patch
            1263412, -- Rebirth
            1264696, -- Light Blast
            1264698, -- Void Blast
            1244348, -- Light Burn
            1266404, -- Void Burn
            1262573, -- Ashen Benediction
            1243320, -- Immortal Flame
            1242803, -- Light Flames
            1242815, -- Void Flames
        },
        [2740] = { -- Midnight Falls
            1273158, -- Death's Requiem
            1249609, -- Dark Rune
            1249584, -- Dissonance
            1249796, -- Shattered Sky
            1284931, -- Termination Prism
            1284934, -- Terminate
            1250898, -- The Dark Archangel
            1251649, -- Disintegration
            1251789, -- Cosmic Fracture
            1266388, -- Dark Constellation
            1252974, -- Dimming
            1251807, -- Cosmic Fracture
            1253915, -- Heaven's Glaives
            1263970, -- Heaven's Lance
            1282027, -- The Darkwell
            1254642, -- Thunderous Well
            1279463, -- Iris of Oblivion
            1281194, -- Dark Meltdown
            1284699, -- Light's End
            1254398, -- Glimmering
            1254262, -- Tears of L'ura
            1254256, -- Naaru's Lament
            1265842, -- Impaled
            1263253, -- Black Tide
            1266897, -- Light Siphon
            1266898, -- Stellar Implosion
            1249582, -- Resonance
            1244412, -- Death's Dirge
            1274455, -- Severance
            1276529, -- Dimension Breach
            1276062, -- Dimension Link
            1260261, -- Total Eclipse
            1282441, -- Starsplinter
            1285561, -- Dark Quasar
            1282034, -- Into the Darkwell
            1282008, -- Abyssal Pool
            1282412, -- Core Harvest
            1266622, -- Midnight
            1266113, -- Torchbearer
            1284525, -- Galvanize
            1282246, -- Void Cores
            1282249, -- Cosmic Fission
            1284638, -- Decay
            1282373, -- Charged Core
            1282458, -- Radiance
            1285827, -- Overkill Current
            1281184, -- Criticality
            1251386, -- Safeguard Prism
            1251392, -- Safeguard
            1284980, -- Grim Symphony
            1279420, -- Dark Quasar
            1262055, -- Eclipsed
            1285685, -- Black Shroud
            1253104, -- Dawnlight Barrier
            1287702, -- Severed Surge
        },
    },

    -- ====================================================================
    -- Windrunner Spire (Dungeon)
    -- ====================================================================
    [1299] = {
        ["general"] = {
        },
        [2655] = { -- Emberdawn
            465904, -- Burning Gale
            466556, -- Flaming Updraft
            466064, -- Searing Beak
            469633, -- Flaming Twisters
            467120, -- Ignited Embers
            1217762, -- Fire Breath
        },
        [2656] = { -- Derelict Duo
            472736, -- Debilitating Shriek
            474105, -- Curse of Darkness
            472724, -- Shadow Bolt
            472795, -- Heaving Yank
            474075, -- Heaving Chop
            472745, -- Splattering Spew
            472777, -- Gunk Splatter
            472888, -- Bone Hack
            1219551, -- Broken Bond
            1282272, -- Splattered
            1215813, -- Shadowy
        },
        [2657] = { -- Commander Kroluk
            470963, -- Bladestorm
            468070, -- Rallying Bellow
            467620, -- Rampage
            1217094, -- Throw Axe
            472043, -- Rallying Bellow
            472081, -- Reckless Leap
            1250851, -- Shield Wall
            1253026, -- Intimidating Shout
            1251981, -- Chain Lightning
            467815, -- Intercepting Charge
            1270620, -- Flame Nova
            1283357, -- Falling Rubble
        },
        [2658] = { -- The Restless Heart
            1253986, -- Gust Shot
            468429, -- Bullseye Windblast
            468442, -- Billowing Wind
            472556, -- Arrow Rain
            1253977, -- Turbulent Arrows
            474528, -- Bolt Gale
            472662, -- Tempest Slash
            1216042, -- Squall Leap
            1282932, -- Storming Soulfont
        },
    },

    -- ====================================================================
    -- Magisters' Terrace (Dungeon)
    -- ====================================================================
    [1300] = {
        ["general"] = {
        },
        [2659] = { -- Arcanotron Custos
            474345, -- Refueling Protocol
            474308, -- Energy Orb
            474496, -- Repulsing Slam
            1214038, -- Ethereal Shackles
            1243905, -- Unstable Energy
            1214081, -- Arcane Expulsion
            474407, -- Arcane Empowerment
            1214089, -- Arcane Residue
        },
        [2661] = { -- Seranel Sunlash
            1224903, -- Suppression Zone
            1225135, -- Feedback
            1225193, -- Wave of Silence
            1225792, -- Runic Mark
            1246446, -- Null Reaction
            1248689, -- Hastening Ward
        },
        [2660] = { -- Gemellus
            1223847, -- Triplicate
            1223936, -- Synaptic Nexus
            1224299, -- Astral Grasp
            1224401, -- Cosmic Radiation
            1224100, -- Void Secretions
            1284958, -- Cosmic Sting
            1253707, -- Neural Link
        },
        [2662] = { -- Degentrius
            1215087, -- Unstable Void Essence
            1215161, -- Void Destruction
            1214714, -- Void Torrent
            1280113, -- Hulking Fragment
            1215897, -- Devouring Entropy
            1271066, -- Entropy Blast
            1269631, -- Entropy Orb
            1284627, -- Umbral Splinters
            1284628, -- Stygian Ichor
        },
    },

    -- ====================================================================
    -- Blackrock Depths (Dungeon)
    -- ====================================================================
    [1301] = {
        ["general"] = {
        },
        [2663] = { -- Lord Roccor
            462346, -- Living Magma
            463674, -- Crystallize
            462322, -- Eruption
            462320, -- Igneous Crystallization
            462351, -- Roiling Magma
        },
        [2664] = { -- Bael'Gar
            462974,
            463890,
            463143,
            462972,
            462968,
        },
        [2665] = { -- Lord Incendius
            463487,
            463503,
            463486,
            463471,
            463472,
            463495,
            463499,
        },
        [2666] = { -- Golem Lord Argelmach
            463821,
            463829,
            464485,
            463852,
            463847,
            463823,
            463837,
            464489,
        },
        [2667] = { -- The Seven
            464347,
            464348,
            464358,
            464359,
            464361,
            464331,
            464371,
            464333,
            464334,
            464353,
            464363,
            464362,
            464366,
            464367,
            464337,
            464340,
            464344,
        },
        [2668] = { -- General Angerforge
            464425,
            466265,
            466273,
            467424,
            467423,
            466259,
            466107,
            464417,
            467464,
            466096,
            466086,
        },
        [2669] = { -- Ambassador Flamelash
            464372, -- Burning Spirit
            464998,
            470244,
            464769,
            470203,
            470207,
            464379,
            464981,
            464382,
            464983,
            464377,
        },
        [2670] = { -- Emperor Dagran Thaurissan
            465069,
            465077,
            465079,
            465268,
            465093,
            465060,
            465070,
            465225,
            465065,
            465086,
            466371,
            465091,
            466504,
            465099,
        },
    },

    -- ====================================================================
    -- Murder Row (Dungeon)
    -- ====================================================================
    [1304] = {
        ["general"] = {
        },
        [2679] = { -- Kystia Manaheart
            1230289, -- Illicit Infusion
            1217989, -- Felshield
            1223906, -- Fel Nova
            1230298, -- Chaos Barrage
            1253811, -- Fel Spray
            1228198, -- Corroding Spittle
            1264095, -- Mirror Images
            1264106, -- Felstorm
            1230304, -- Light Infusion
            1265412, -- Destabilized
        },
        [2680] = { -- Zaen Bladesorrow
            474478, -- Killing Spree
            1218347, -- Murder in a Row
            474765, -- Same-Day Delivery
            1201553, -- Fel-Infused Freight
            1214357, -- Fire Bomb
            1222795, -- Envenom
            474515, -- Heartstop Poison
            1266241, -- Freight Explosion
        },
        [2681] = { -- Xathuux the Annihilator
            1214663, -- Axe Toss
            474197, -- Demonic Rage
            474234, -- Burning Steps
            473898, -- Legion Strike
            1214650, -- Fel Lightning
        },
        [2682] = { -- Lithiel Cinderfury
            1223204, -- Felfire Burst
            474375, -- Chaos Bolt
            1214675, -- Demonic Gateway
            474457, -- Fingers of Gul'dan
            1217384, -- Malefic Wave
            1217415, -- Felshield
            1226469, -- Malefic Empowerment
            1231262, -- Felfire Core
            1216945, -- Searing Fel Flame
        },
    },

    -- ====================================================================
    -- The Blinding Vale (Dungeon)
    -- ====================================================================
    [1309] = {
        ["general"] = {
        },
        [2769] = { -- Lightblossom Trinity
            1234753, -- Bedrock Slam
            1234782, -- Fertile Loam
            1234850, -- Lightsower Dash
            1235640, -- Thornblade
            1235564, -- Lightblossom Beam
            1235751, -- Lightbloom Overgrowth
            1235814, -- Light-Scorched Earth
            1235616, -- Light Bolt
            1235729, -- Light-Gorged
            1253028, -- Thicket's Trinity
            1261011, -- Fan Of Thorns
            1276586, -- Bedrock Surge
        },
        [2770] = { -- Ikuzz the Light Hunter
            1236658, -- Bloodthorn Roots
            1236746, -- Verdant Stomp
            1236709, -- Thorncaller Roar
            1237090, -- Bloodthirsty Gaze
            1237093, -- Crushing Footfalls
            1237166, -- Incise
            1237073, -- Lightcrazed Frenzy
            1272290, -- Crunched
        },
        [2771] = { -- Lightwarden Ruia
            1239824, -- Lightfire
            1239830, -- Lightfire Beams
            1240098, -- Lightfall
            1239821, -- Warden's Wrath
            1240210, -- Pulverizing Strikes
            1241058, -- Grievous Thrash
            1241067, -- Spirits of the Vale
            1257094, -- Pulverized
            1272265, -- Mangling Claws
        },
        [2772] = { -- Ziekket
            1246372, -- Awaken the Lightbloom
            1247669, -- Lightspore Shot
            1246379, -- Dormant
            1246607, -- Concentrated Lightbeam
            1246660, -- Lightsap
            1246858, -- Lightbloom's Essence
            1247039, -- Fluorescent Outburst
            1247052, -- Lightbloom's Might
            1247685, -- Thornspike
            1247377, -- Oozing Xylem
            1247050, -- Fluorescent Shield
            1253320, -- Vicious Regrowth
        },
    },

    -- ====================================================================
    -- Den of Nalorakk (Dungeon)
    -- ====================================================================
    [1311] = {
        ["general"] = {
        },
        [2776] = { -- The Hoardmonger
            1235072, -- Resourceful Measures
            1235125, -- Hearty Bellow
            1235129, -- Bonespike Slam
            1235405, -- Bonespiked
            1235105, -- Overflowing Supplies
            1234233, -- Spoiled Supplies
            1234846, -- Toxic Spores
            1245593, -- Putrid Burst
            1234021, -- Earthshatter Slam
            1234681, -- Ravenous Bellow
        },
        [2777] = { -- Sentinel of Winter
            1235783, -- Shattering Frostspike
            1235829, -- Winter's Shroud
            1234314, -- Snowdrift
            1235656, -- Eternal Winter
            1235623, -- Raging Squall
            1235548, -- Glacial Torment
            1263590, -- Rimeshatter
            1263597, -- Rime Detonation
        },
        [2778] = { -- Nalorakk
            1243002, -- Fury of the War God
            1243408, -- Echoing Fury
            1242860, -- Echoing Maul
            1255385, -- Forceful Roar
            1243585, -- Overwhelming Onslaught
            1262253, -- Brutal Slam
            1243063, -- Tempest of Fury
            1255577, -- Raging Tempest
            1261776, -- Echoing Tempest
        },
    },

    -- ====================================================================
    -- Voidscar Arena (Dungeon)
    -- ====================================================================
    [1313] = {
        ["general"] = {
        },
        [2791] = { -- Taz'Rah
            1222199, -- Dark Rift
            1222098, -- Nether Dash
            1222085, -- Cosmic Spike
            1225107, -- Ethereal Shards
            1263593, -- Gather Shadows
        },
        [2792] = { -- Atroxus
            1222724, -- Noxious Breath
            1222642, -- Hulking Claw
            1226031, -- Poison Splash
            1222692, -- Toxic Aura
            1262497, -- Monstrous Stomp
            1222484, -- Poison Pool
            1263971, -- Lingering Poison
            1222371, -- Provoke Creeper
            1282892, -- Sickening Bite
            1283506, -- Fixate
        },
        [2793] = { -- Charonus
            1248130, -- Unstable Singularity
            1227197, -- Cosmic Blast
            1222755, -- Void Cascade
            1223298, -- Gravitic Orbs
            1263983, -- Condensed Mass
        },
    },

    -- ====================================================================
    -- The Dreamrift (Dungeon)
    -- ====================================================================
    [1314] = {
        ["general"] = {
        },
        [2795] = { -- Chimaerus the Undreamt God
            1262289, -- Alndust Upheaval
            1245486, -- Corrupted Devastation
            1245698, -- Alnsight
            1245406, -- Ravenous Dive
            1245844, -- Cannibalized Essence
            1245919, -- Alndust Essence
            1246132, -- Rift Shroud
            1272726, -- Rending Tear
            1249017, -- Fearsome Cry
            1249207, -- Discordant Roar
            1250953, -- Rift Sickness
            1252863, -- Insatiable
            1246653, -- Caustic Phlegm
            1257087, -- Consuming Miasma
            1253744, -- Rift Vulnerability
            1257093, -- Lingering Miasma
            1258610, -- Rift Emergence
            1261997, -- Essence Bolt
            1262020, -- Colossal Strikes
            1245727, -- Alnshroud
            1246621, -- Caustic Phlegm
            1257085, -- Consuming Miasma
            1267201, -- Dissonance
            1264756, -- Rift Madness
            1245396, -- Consume
            1282001, -- Alndust Upheaval
        },
    },

    -- ====================================================================
    -- Maisara Caverns (Dungeon)
    -- ====================================================================
    [1315] = {
        ["general"] = {
        },
        [2810] = { -- Muro'jin and Nekraxx
            1246666, -- Infected Pinions
            1249789, -- Revive Pet
            1243900, -- Fetid Quillstorm
            1260731, -- Freezing Trap
            1249479, -- Carrion Swoop
            1249769, -- Coordinated Assault
            1249948, -- Bestial Wrath
            1266480, -- Flanking Spear
            1260643, -- Barrage
            1260709, -- Vilebranch Sting
            1243751, -- Icy Slick
            1266488, -- Open Wound
        },
        [2811] = { -- Vordaza
            1251554, -- Drain Soul
            1250708, -- Necrotic Convergence
            1251204, -- Wrest Phantoms
            1251775, -- Final Pursuit
            1251833, -- Soulrot
            1251813, -- Lingering Dread
            1252054, -- Unmake
            1251598, -- Deathshroud
            1252611, -- Coalesced Death
            1264974, -- Veiled Presence
            1264987, -- Withering Miasma
            1266706, -- Haunting Remains
        },
        [2812] = { -- Rak'tul, Vessel of Souls
            1252676, -- Crush Souls
            1252777, -- Soulbind
            1252816, -- Chill of Death
            1251023, -- Spiritbreaker
            1248863, -- Deathgorged Vessel
            1248980, -- Volatile Essence
            1253788, -- Soulrending Roar
            1253844, -- Withering Soul
            1254175, -- Cries of the Fallen
            1254010, -- Eternal Suffering
            1255629, -- Spectral Residue
            1259810, -- Shattered Totem
            1253909, -- Soul Expulsion
            1266723, -- Spectral Decay
        },
    },

    -- ====================================================================
    -- Nexus-Point Xenas (Dungeon)
    -- ====================================================================
    [1316] = {
        ["general"] = {
        },
        [2813] = { -- Chief Corewright Kasreth
            1250553, -- Arcane Zap
            1251767, -- Reflux Charge
            1257509, -- Corespark Detonation
            1264040, -- Flux Collapse
            1264042, -- Arcane Spill
            1251579, -- Leyline Array
            1276485, -- Sparkburn
        },
        [2814] = { -- Corewarden Nysarra
            1247976, -- Lightscar Flare
            1247937, -- Umbral Lash
            1249014, -- Eclipsing Step
            1282723, -- Dusk Frights
            1282665, -- Void Lash
            1252828, -- Void Gash
            1252883, -- Devour the Unworthy
            1253965, -- Lightscarred
            1282679, -- Flailstorm
            1282722, -- Nullify
            1252703, -- Null Vanguard
        },
        [2815] = { -- Lothraxion
            1253848, -- Brilliant Dispersion
            1253950, -- Searing Rend
            1255531, -- Flicker
            1255389, -- Radiant Scar
            1266713, -- Mirrored Rend
            1257613, -- Divine Guile
            1271511, -- Core Exposure
        },
    },

    -- ====================================================================
    -- Midnight (Dungeon)
    -- ====================================================================
    [1312] = {
        ["general"] = {
        },
        [2827] = { -- Lu'ashal
            1276436, -- Dawncrazed Halo
            1276247, -- Dawnfire Breath
            1243963, -- Radiant Sunder
            1243988, -- Blinding Fissure
            1258427, -- Radiant Flare
            1258426, -- Radiant Ember
        },
        [2829] = { -- Thorm'belan
            1257825, -- Scintillating Shard
            1257320, -- Radiant Mote
            1257737, -- Shard Eruption
            1258136, -- Rending Claw
            1257618, -- Dazzling Radiance
            1258639, -- Shredding Tendrils
        },
        [2828] = { -- Predaxas
            1276193, -- Regurgitation
            1276320, -- Seismic Slam
            1276884, -- Voidscatter
            1277043, -- Bilepool
            1276988, -- Toxin Splatter
            1277711, -- Bestial Rage
            1277694, -- Blood Nova
            1277829, -- Devour
        },
        [2782] = { -- Cragpine
            1235144, -- War Club
            1257906, -- Ancient Seeds
            1235131, -- Rootquake
            1235134, -- Erupting Roots
        },
    },

}

F.LoadBuiltInDebuffs(debuffs)
