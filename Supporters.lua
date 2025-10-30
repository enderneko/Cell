local addonName, ns = ...

-------------------------------------------------
-- supporters (order by date)
-------------------------------------------------
-- mvp: ff8000
-- goat: 7fff00,b6f92

local supporters1 = { -- wowIDs
    -- {"wowID1", "wowID2"...}
    {
        "|cff7fff00Palymoo-TwistingNether (EU)|r",
        "|cff7fff00Dreadsham-TwistingNether (EU)|r",
        "|cff7fff00Dreadninja-TwistingNether (EU)|r",
        "|cff7fff00Dreadfu-TwistingNether (EU)|r",
        "|cff7fff00Dreads-TwistingNether (EU)|r",
    }, -- Palymoo (Ko-fi)
    {
        "|cff7fff00Tithaya-Kel'Thuzad (US)|r",
        "|cff7fff00Yesiram-Kel'Thuzad (US)|r",
    }, -- Chris (Ko-fi)
    {
        "|cff00ffffVollmer-Ragnaros (EU)|r",
        "|cff00ffffVollmerto-Kazzak (EU)|r",
        "|cff00ffffVollmerfire-Ragnaros (EU)|r",
    }, -- Vollmerino (CUF)
    {
        "|cffff8000小兔姬-影之哀伤 (CN)|r",
        "|cffff8000渺渺-影之哀伤 (CN)|r"
    }, -- 呆小七 (爱发电)
    {"夏木沐-伊森利恩 (CN)"}, -- 夏木沐 (爱发电)
    {"七月核桃丶-白银之手 (CN)"}, -- 爱发电用户_ac5d4
    {"芋包-影之哀伤 (CN)", "月刃丶-世界之樹 (TW)", "月刄-影之哀伤 (CN)"}, -- Smile (爱发电)
    {"青乙-影之哀伤 (CN)", "永离诸幻-影之哀伤 (CN)"},
    {
        "|cffff8000黑诺-影之哀伤 (CN)|r",
        "|cffff8000黑丨诺-影之哀伤 (CN)|r",
        "|cffff8000黑丶诺-影之哀伤 (CN)|r"
    },
    {"大领主王大发-莫格莱尼 (CN)"}, -- Shawn (爱发电)
    {"Sjerry-死亡之翼 (CN)"}, -- 爱发电用户_7957f
    {"貼饼子-匕首岭 (CN)"},
    {"|cfffb6f92心耀-冰风岗 (CN)|r"}, -- warbaby (爱不易)
    {"秋末旷夜-凤凰之神 (CN)", "秋末旷叶-凤凰之神 (CN)"}, -- 爱发电用户_760ee (爱发电)
    {"曾經活過-憤怒使者 (TW)"}, -- ZzZ (爱发电)
    {"音速豆奶-白银之手 (CN)"}, -- 爱发电用户_83f12
    {"Hardpp-Illidan (US)", "六月的奶德-艾露恩 (CN)"}, -- 爱发电用户_15402
    {"握握-暗影之月 (TW)"}, -- 爱发电用户_a3e3a
    {"Sonichunter-地獄吼 (TW)", "Katoomba-地獄吼 (TW)"}, -- 爱发电用户_6db77
    {"微樓聽雨-銀翼要塞 (TW)"}, -- 爱发电用户_8xs3
    {"黑哥哥-世界之樹 (TW)"}, -- 爱发电用户_fdc1d
    {"Kuroni-Blackhand (US)"}, -- Kuro (Ko-fi)
    {"Nodwa-Blackhand (US)"}, -- Nodwa (Ko-fi)
    {"Deijava-Illidan (US)"}, -- Kyoman (Ko-fi)
    {"Epriestin-TarrenMill (EU)"}, -- Sharelia (ko-fi)
    {"Nascente-TarrenMill (EU)"}, -- Nascente-Tarren Mill (Ko-fi)
    {"Longmer-Illidan (US)"}, -- 爱发电用户_4116d (爱发电)
    {"Phæro-Antonidas (EU)", "Callistò-Antonidas (EU)"}, -- Phæro (Ko-fi)
    {"Synthatt-Illidan (US)"}, -- Synthatt (Ko-fi)
    {"Holystora-Antonidas (EU)"}, -- devo (Ko-fi)
    {
        "|cffff8000Everessian-Ravencrest (EU)|r",
        "|cffff8000Thundaem-Ravencrest (EU)|r",
        "|cffff8000Shylanelle-Ravencrest (EU)|r",
        "|cffff8000Alenlin-Ravencrest (EU)|r",
        "|cffff8000Kulresh-Ravencrest (EU)|r",
        "|cffff8000Thurådin-Ravencrest (EU)|r",
    }, -- Martin van Vuuren (Ko-fi)
    {"Shendreakah-Zul'jin (US)"}, -- Shendreakah - Zul-jin (Ko-fi)
    {
        "|cffff8000Lucen-Terokkar (EU)|r",
        "|cffff8000Apexion-Terokkar (EU)|r",
        "|cffff8000Moonwhisper-Terokkar (EU)|r",
        "|cffff8000Wildrunner-Terokkar (EU)|r",
    }, -- Serghei Iakovlev (Ko-fi)
    {"Fourdigitiq-Blackrock (EU)"}, -- Rou (Ko-fi)
    {"Leako-Draenor (EU)"}, -- Leako (Ko-fi)
    {"|cffff8000Asuranpala-Draenor (EU)|r"}, -- AsuranDex (Ko-fi)
    {"|cffff8000Poolparty-Khaz'goroth (US)|r"}, -- Poolparty (Ko-fi)
    {"Tenspiritak-Drakthul (EU)"}, -- Tenspiritak (Ko-fi)
    {"Darrágh-Blackrock (EU)"}, -- Jim (Ko-fi)
    {"Cerrmor-Stormrage (US)"}, -- (Ko-fi)
    {"Gordonfreems-Illidan (US)"}, -- Gordon Freeman (Ko-fi)
    {"Saphiren-Azralon (US)"}, -- Saphiren (Ko-fi)
    {"Evangeleena-Outland (EU)"}, -- Milda (Ko-fi)
    {"Æleluia-Hyjal (EU)"}, -- eXtRa (Ko-fi)
    {
        "Druladin-Blackhand (EU)",
        "Drumane-Blackhand (EU)",
        "Drupriest-Blackhand (EU)",
        "Druvoke-Blackhand (EU)",
        "Drumonji-Blackhand (EU)",
    }, -- Ko-fi
    {"Saintara-Blackhand (EU)"}, -- Ko-fi
    {"|cffff8000Lúthieñ-Ravencrest (EU)|r"}, -- Zion (Ko-fi)
    {"Jeânnîne-Hyjal (EU)"}, -- Jânine (Ko-fi)
    {
        "Angelofbliss-TarrenMill (EU)",
        "Angelique-Dawnbringer (EU)",
    }, -- Angelofbliss (Ko-fi)
    {"Stormpork-Silvermoon (EU)"}, -- Magicpork (Ko-fi)
    {"日理万基-罗宁 (CN)"}, -- LPRO (爱发电)
    {"Kimo-海克泰尔 (CN)"}, -- 爱发电用户_30f63 (爱发电)
    {"Fróger-TarrenMill (EU)"}, -- Fróger (Ko-fi)
    {"风不竞-影之哀伤 (CN)"}, -- 空想无量自在 (爱发电)
    {"白夜之翼-影之哀伤 (CN)"}, -- 大宇 (爱发电)
    {"絵野-金色平原 (CN)"}, -- Neet_F (爱发电)
    {"Shichiki-Antonidas (EU)"}, -- Shichiki-EU-Antonidas (Ko-fi)
    {
        "|cfffb6f92露露缇娅-迅捷微风 (CN)|r",
        "|cfffb6f92露露緹婭灬-迅捷微风 (CN)|r",
        "|cfffb6f92露露缇娅丶-迅捷微风 (CN)|r",
        "|cfffb6f92露露緹婭丶-迅捷微风 (CN)|r",
        "|cfffb6f92露露缇娅丶-霜语 (CN)|r",
        "|cfffb6f92露露缇娅灬-霜语 (CN)|r",
    }, -- 露露缇娅 (爱发电)
    {
        "|cfffb6f92Rëat-Silvermoon (EU)|r",
        "|cfffb6f92Reatsham-Silvermoon (EU)|r",
        "|cfffb6f92Reatvoker-Silvermoon (EU)|r",
    }, -- Reat
    {"Daydream-Dalaran (EU)"}, -- luana11
    {"|cffff8000Aschgewitter-Eredar (EU)|r"}, -- Aschgewitter - Eredar
    {"三号-熊猫酒仙 (CN)"}, -- 爱发电用户_sUE4
    {"远古列王守卫-回音山 (CN)"}, -- PPQ
    {"Huf-ArgentDawn (EU)"}, -- Huf
    {"吕小美-震地者 (CN)"}, -- 假寐的死神 (爱发电)
    {
        "Tdps-Ragnaros (EU)",
        "Rosehip-Ragnaros (EU)",
    }, -- Tdps-Ragnaros
    {"Daanior-Draenor (EU)"}, -- Daanior-Draenor (Ko-fi)
    {"血蹄凯恩嗯-加丁 (CN)"}, -- 爱发电用户_1e94c
    {"墨染雲湮-白银之手 (CN)"}, -- 墨染雲湮-白银之手
    {"Taudri-Mankrik (US)"}, -- Taudry (Ko-fi)
    {"Sproutz-Illidan (US)"}, -- Sproutz (Ko-fi)
    {
        "|cfffb6f92Floofe-Nightslayer (US)|r",
        "|cfffb6f92Mommie-Nightslayer (US)|r",
        "|cfffb6f92Flewf-Nightslayer (US)|r",
    }, -- Floofe (Ko-fi)
    {"无语了捏-回音山 (CN)"}, -- 我有脂肪肝 (爱发电)
    {"月弥-神圣之歌 (CN)"}, -- 爱发电用户_bb967 (爱发电)
    {"|cfffb6f92Darkquinn-Proudmoore (US)|r"}, -- Quinn (Ko-fi)
}

local supporters2 = { -- 有些早期的发电记录已经丢失了……
    {"|cfffb6f92钛锬|r", "爱发电"}, -- 2021-11-15
    {"|cffff8000呆小七|r", "爱发电"}, -- 2021-11-15
    {"黑色之城", "爱发电"}, -- 2022-03-16
    {"flappysmurf", "爱发电"}, -- 2022-04-16
    {"Mike", "爱发电"}, -- 2022-08-06
    {"七月核桃丶", "爱发电"}, -- 2022-08-08 爱发电用户_ac5d4
    {"|cffff8000Smile|r", "爱发电"}, -- 2022-08-11
    {"|cffff8000黑诺|r", "爱发电"}, -- 2022-08-15
    {"古月文武", "爱发电"},
    {"CC", "爱发电"},
    {"Shawn", "爱发电"}, -- 2022-09-16
    {"蓝色-理想", "爱发电"},
    {"席慕容", "爱发电"},
    {"星空", "爱发电"}, -- 2022-10-19
    {"年复一年路西法", "爱发电"}, -- 2022-10-20
    {"阿哲", "爱发电"}, -- 2022-10-23
    {"Sjerry", "爱发电"}, -- 2022-11-04 爱发电用户_7957f
    {"|cfffb6f92warbaby|r", "爱不易"}, -- 2022-11-25
    {"6ND8", "爱发电"}, -- 2022-11-16
    {"伊莉丝翠的眷顾", "爱发电"}, -- 2022-11-18
    {"批歪", "爱发电"},
    {"音速豆奶", "爱发电"}, -- 2022-11-29 爱发电用户_83f12
    {"ZzZ", "爱发电"}, -- 2022-12-10
    {"月神之韧", "爱发电"}, -- 2023-01-01
    {"Smile", "爱发电"}, -- 2023-01-05
    {"Si", "爱发电"}, -- 2023-01-07
    {"晓文", "爱发电"}, -- 2023-01-15
    {"六月的奶德", "爱发电"}, -- 2023-01-26 爱发电用户_15402
    {"握握", "爱发电"}, -- 2023-05-10 爱发电用户_a3e3a
    {"千雪之心", "爱发电"}, -- 2023-05-25 爱发电用户_2a168
    {"朝", "爱发电"}, -- 2023-06-16
    {"Sonichunter", "爱发电"}, -- 2023-06-26
    {"ATOMS. ོ", "爱发电"}, -- 2023-07-13 爱发电用户_4f365
    {"微樓聽雨", "爱发电"}, -- 2023-07-20 爱发电用户_8xs3
    {"往事", "爱发电"}, -- 2023-07-30
    {"哄哄", "爱发电"}, -- 2023-08-15
    {"acm447", "爱发电"}, -- 2023-08-15
    {"|cffff8000花爺|r", "爱发电"}, -- 2023-09-13
    {"黑哥哥", "爱发电"}, -- 2023-09-23 爱发电用户_fdc1d
    {"得闲饮茶", "爱发电"}, -- 2023-12-03
    {"北方", "爱发电"}, -- 2023-12-06
    {"Kuro", "Ko-fi"}, -- 2023-12-15
    {"Nodwa", "Ko-fi"}, -- 2023-12-18
    {"Kyoman", "Ko-fi"}, -- 2023-12-22
    {"Sharelia", "Ko-fi"}, -- 2023-12-25
    {"Longmer", "爱发电"}, -- 2023-12-23 爱发电用户_4116d (爱发电)
    {"Nascente", "Ko-fi"}, -- 2023-12-26
    {"nas4", "爱发电"}, -- 2023-12-27 爱发电用户_nas4 (爱发电)
    {"Phæro", "Ko-fi"}, -- 2024-02-10
    {"Jane", "Ko-fi"}, -- 2024-02-11
    {"拜拜", "爱发电"}, -- 2024-02-26 爱发电用户_bcb32
    {"qwe#6664", "KOOK"}, -- 2024-02-26 爱发电用户_QBbY
    {"Synthatt", "Ko-fi"}, -- 2024-03-26
    {"devo", "Ko-fi"}, -- 2024-04-07
    {"QBbY", "爱发电"}, -- 2024-04-09 爱发电用户_QBbY
    {"|cff7fff00Chris|r", "Ko-fi"}, -- Chris 2024-04-18
    {"Pandora", "Ko-fi"}, -- 2024-04-22
    {"|cffff8000Martin van Vuuren|r", "Ko-fi"}, -- 2024-05-06
    {"Shendreakah", "Ko-fi"}, -- 2024-05-12
    {"8xs3", "爱发电"}, -- 2024-05-12 爱发电用户_8xs3
    {"|cff7fff00Palymoo|r", "Ko-fi"}, -- 2024-05-12
    {"Winkupo", "Ko-fi"}, -- 2024-05-14
    {"|cffff8000Serghei Iakovlev|r", "Ko-fi"}, -- 2024-05-15
    {"Rou", "Ko-fi"}, -- 2024-05-23
    {"Leako", "Ko-fi"}, -- 2024-05-30
    {"lfence", "Ko-fi"}, -- 2024-06-03
    {"|cffff8000AsuranDex|r", "Ko-fi"}, -- 2024-06-24
    {"fca53", "爱发电"}, -- 2024-07-01 爱发电用户_fca53
    {"Likle", "Ko-fi"}, -- 2024-07-03
    {"eWhK", "爱发电"}, -- 2024-07-03 爱发电用户_eWhK
    {"|cffff8000Poolparty|r", "Ko-fi"}, -- 2024-07-07
    {"Tenspiritak", "Ko-fi"}, -- 2024-07-07
    {"Jim", "Ko-fi"}, -- 2024-07-13
    {"Cerrmor-Stormrage", "Ko-fi"}, -- 2024-07-15
    {"Drumonji-Blackhand", "Ko-fi"}, -- 2024-07-19
    {"Intuition", "Ko-fi"}, -- 2024-07-23
    {"Gordon Freeman", "Ko-fi"}, -- 2024-07-25
    {"Saphiren", "Ko-fi"}, -- 2024-07-25
    {"Milda", "Ko-fi"}, -- 2024-07-30
    {"eXtRa", "Ko-fi"}, -- 2024-07-31
    {"男月月", "Ko-fi"}, -- 2024-07-31
    {"Akanma·Starsong", "爱发电"}, -- 2024-08-01
    {"Druladin-Blackhand", "Ko-fi"}, -- 2024-08-12
    {"|cffff8000Zion|r", "Ko-fi"}, -- 2024-08-18
    {"Saintara-Blackhand", "Ko-fi"}, -- 2024-08-23
    {"Jânine", "Ko-fi"}, -- 2024-08-24
    {"Angelofbliss", "Ko-fi"}, -- 2024-08-24
    {"Magicpork", "Ko-fi"}, -- 2024-08-30
    {"LPRO", "爱发电"}, -- 2024-09-08
    {"30f63", "爱发电"}, -- 2024-09-09
    {"760ee", "爱发电"}, -- 2024-09-11
    {"Xonqevo", "Ko-fi"}, -- 2024-09-16
    {"Fróger", "Ko-fi"}, -- 2024-09-21
    {"空想无量自在", "爱发电"}, -- 2024-09-25
    {"大宇", "爱发电"}, -- 2024-09-25
    {"httpete", "Ko-fi"}, -- 2024-09-28
    {"Neet_F", "爱发电"}, -- 2024-09-28
    {"冷冽谷尬舞队队长", "爱发电"}, -- 2024-10-01
    {"Shichiki-EU-Antonidas", "Ko-fi"}, -- 2024-10-03
    {"|cfffb6f92露露缇娅|r", "爱发电"}, -- 2024-12-20
    {"luana11", "Ko-fi"}, -- 2025-01-25
    {"|cffff8000Aschgewitter - Eredar|r", "Ko-fi"}, -- 2025-02-27
    {"爱发电用户_sUE4", "爱发电"}, -- 2025-03-02
    {"无多路", "爱发电"}, -- 2025-03-04
    {"Huf", "Ko-fi"}, -- 2025-03-04
    {"假寐的死神", "爱发电"}, -- 2025-03-05
    {"Tdps-Ragnaros", "Ko-fi"}, -- 2025-03-08
    {"PPQ", "爱发电"}, -- 2025-03-08
    {"Daanior-Draenor", "Ko-fi"}, -- 2025-03-23
    {"爱发电用户_1e94c", "爱发电"}, -- 2025-03-31
    {"Kaymi", "Ko-fi"}, -- 2025-04-19
    {"Venarius", "Ko-fi"}, -- 2025-04-24
    {"墨染雲湮-白银之手", "爱发电"}, -- 2025-05-01
    {"Shyn", "Ko-fi"}, -- 2025-05-22
    {"|cffff8000Taudry|r", "Ko-fi"}, -- 2025-07-02
    {"Ko-fi Supporter", "Ko-fi"}, -- 2025-07-03
    {"Sproutz", "Ko-fi"}, -- 2025-07-03
    {"|cffff8000Chrystal|r", "Ko-fi"}, -- 2025-07-04
    {"Natalz", "Ko-fi"}, -- 2025-07-06
    {"|cfffb6f92Floofe|r", "Ko-fi"}, -- 2025-08-07
    {"我有脂肪肝", "爱发电"}, -- 2025-08-07
    {"奶德史塔克-A'lar CN", "Ko-fi"}, -- 2025-08-15
    {"爱发电用户_bb967", "爱发电"}, -- 2025-08-22
    {"施然", "爱发电"}, -- 2025-10-06
    {"|cfffb6f92Quinn|r", "Ko-fi"}, -- 2025-10-28
}

-------------------------------------------------
-- supporters (wow IDs)
-------------------------------------------------
local tests = {
    ["Rutha-Lycanthoth"] = true,
    ["Programming-BurningLegion"] = true,
    ["Programming-影之哀伤"] = "goat",
    ["篠崎-影之哀伤"] = "goat",
    ["蜜柑-影之哀伤"] = "goat",
    ["萝露-影之哀伤"] = "goat",
}

local wowSupporters = {}

do
    for _, t in pairs(supporters1) do
        for i, name in pairs(t) do
            local fullName
            if strfind(name, "^|") then
                fullName = strmatch(name, "^|cff......(.+%-.+) %(%u%u%)|r$")
                if strfind(name, "^|cffff8000") then
                    wowSupporters[fullName] = "mvp"
                else
                    wowSupporters[fullName] = "goat"
                end
            else
                fullName = strmatch(name, "^(.+%-.+) %(%u%u%)$")
                wowSupporters[fullName] = true
            end
        end
    end
end

-------------------------------------------------
-- make them accessible
-------------------------------------------------
if addonName == "Cell" then -- Cell
    ns.supporters1 = supporters1
    ns.supporters2 = supporters2
    ns.wowSupporters = Cell.funcs.TMergeOverwrite(wowSupporters, tests)
else -- other addons
    ns.cellSupporters = wowSupporters
end