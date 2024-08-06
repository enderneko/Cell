local addonName, ns = ...

-------------------------------------------------
-- supporters (order by date)
-------------------------------------------------
local supporters1 = { -- wowIDs
    -- {"wowID1", "wowID2"...}
    {"小兔姬-影之哀伤 (CN)", "渺渺-影之哀伤 (CN)"}, -- 呆小七 (爱发电)
    {"夏木沐-伊森利恩 (CN)"}, -- 夏木沐 (爱发电)
    {"七月核桃丶-白银之手 (CN)"}, -- 爱发电用户_ac5d4
    {"芋包-影之哀伤 (CN)", "月刃丶-世界之樹 (TW)"}, -- Smile (爱发电)
    {"青乙-影之哀伤 (CN)"},
    {"黑丨诺-影之哀伤 (CN)"},
    {"大领主王大发-莫格莱尼 (CN)"}, -- Shawn (爱发电)
    {"Sjerry-死亡之翼 (CN)"}, -- 爱发电用户_7957f
    {"貼饼子-匕首岭 (CN)"},
    {"心耀-冰风岗 (CN)"}, -- warbaby (爱不易)
    {"秋末旷夜-凤凰之神 (CN)"}, --
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
    {"Tithaya-Kel'Thuzad (US)"}, -- tithaya (Ko-fi)
    {
        "Everessian-Ravencrest (EU)",
        "Thornar-Ravencrest (EU)",
        "Shylanelle-Ravencrest (EU)",
        "Alenlin-Ravencrest (EU)",
        "Kulresh-Ravencrest (EU)",
        "Grundihm-Ravencrest (EU)",
    }, -- Martin van Vuuren (Ko-fi)
    {"Shendreakah-Zul'jin (US)"}, -- Shendreakah - Zul-jin (Ko-fi)
    {"Palymoo-Twistingnether (EU)"}, -- Palymoo-Twistingnether (EU) (Ko-fi)
    {"Skywarden-Sylvanas (EU)"}, -- Serghei Iakovlev (Ko-fi)
    {"Fourdigitiq-Blackrock (EU)"}, -- Rou (Ko-fi)
    {"Leako-Draenor (EU)"}, -- Leako (Ko-fi)
    {"Asuranpala-Draenor (EU)"}, -- AsuranDex (Ko-fi)
    {"Poolparty-Khaz'goroth (US)"}, -- Poolparty (Ko-fi)
    {"Tenspiritak-Drakthul (EU)"}, -- Tenspiritak (Ko-fi)
    {"Darrágh-Blackrock (EU)"}, -- Jim (Ko-fi)
    {"Cerrmor-Stormrage (US)"}, -- (Ko-fi)
    {"Drumonji-Blackhand (EU)"}, -- (Ko-fi)
    {"Gordonfreems-Illidan (US)"}, -- Gordon Freeman (Ko-fi)
    {"Saphiren-Azralon (US)"}, -- Saphiren (Ko-fi)
    {"Evangeleena-Outland (EU)"}, -- Milda (Ko-fi)
    {"Æleluia-Hyjal (EU)"}, -- eXtRa (Ko-fi)
}

local supporters2 = { -- 有些早期的发电记录已经丢失了……
    {"钛锬", "NGA"}, -- 2021-11-15
    {"呆小七", "爱发电"}, -- 2021-11-15
    {"黑色之城", "NGA"}, -- 2022-03-16
    {"flappysmurf", "爱发电"}, -- 2022-04-16
    {"Mike", "爱发电"}, -- 2022-08-06
    {"七月核桃丶", "爱发电"}, -- 2022-08-08 爱发电用户_ac5d4
    {"Smile", "爱发电"}, -- 2022-08-11
    {"黑诺", "爱发电"}, -- 2022-08-15
    {"古月文武", "爱发电"},
    {"CC", "爱发电"},
    {"Shawn", "爱发电"}, -- 2022-09-16
    {"蓝色-理想", "NGA"},
    {"席慕容", "NGA"},
    {"星空", "爱发电"}, -- 2022-10-19
    {"年复一年路西法", "爱发电"}, -- 2022-10-20
    {"阿哲", "爱发电"}, -- 2022-10-23
    {"Sjerry", "爱发电"}, -- 2022-11-04 爱发电用户_7957f
    {"warbaby", "爱不易"}, -- 2022-11-25
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
    {"花爺", "爱发电"}, -- 2023-09-13
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
    {"tithaya", "Ko-fi"}, -- 2024-04-18
    {"Pandora", "Ko-fi"}, -- 2024-04-22
    {"Martin van Vuuren", "Ko-fi"}, -- 2024-05-06
    {"Shendreakah", "Ko-fi"}, -- 2024-05-12
    {"8xs3", "爱发电"}, -- 2024-05-12 爱发电用户_8xs3
    {"Palymoo", "Ko-fi"}, -- 2024-05-12
    {"Winkupo", "Ko-fi"}, -- 2024-05-14
    {"Serghei Iakovlev", "Ko-fi"}, -- 2024-05-15
    {"Rou", "Ko-fi"}, -- 2024-05-23
    {"Leako", "Ko-fi"}, -- 2024-05-30
    {"lfence", "Ko-fi"}, -- 2024-06-03
    {"AsuranDex", "Ko-fi"}, -- 2024-06-24
    {"fca53", "爱发电"}, -- 2024-07-01 爱发电用户_fca53
    {"Likle", "Ko-fi"}, -- 2024-07-03
    {"eWhK", "爱发电"}, -- 2024-07-03 爱发电用户_eWhK
    {"Poolparty", "Ko-fi"}, -- 2024-07-07
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
}

-------------------------------------------------
-- supporters (wow IDs)
-------------------------------------------------
local tests = {
    ["Komugi-Fyrakk"] = true,
    ["Rutha-Lycanthoth"] = true,
    ["Programming-BurningLegion"] = true,
    ["Programming-影之哀伤"] = true,
    ["篠崎-影之哀伤"] = true,
    ["蜜柑-影之哀伤"] = true,
}

local wowSupporters = {}

do
    for _, t in pairs(supporters1) do
        for i, name in pairs(t) do
            local fullName = strmatch(t[i], "^(.+%-.+) %(%u%u%)$")
            wowSupporters[fullName] = true
        end
    end
end

-------------------------------------------------
-- make them accessible
-------------------------------------------------
if addonName == "Cell" then -- Cell
    ns.supporters1 = supporters1
    ns.supporters2 = supporters2
    ns.wowSupporters = Cell.funcs:TMergeOverwrite(wowSupporters, tests)
else -- other addons
    ns.cellSupporters = wowSupporters
end