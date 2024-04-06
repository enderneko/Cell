local addonName, ns = ...

-------------------------------------------------
-- patrons (order by date)
-------------------------------------------------
local patrons1 = {
    -- {"nameInPatronList", "sortKey", "wowIDs"...}
    {"小兔姬-影之哀伤 (CN)", "xiaotuji", "渺渺-影之哀伤"},
    {"夏木沐-伊森利恩 (CN)", "xiamumu"},
    {"七月核桃丶-白银之手 (CN)", "qiyuehetaodian"},
    {"芋包-影之哀伤 (CN)", "yubao"},
    {"青乙-影之哀伤 (CN)", "qingyi"},
    {"黑丨诺-影之哀伤 (CN)", "heishunuo"},
    {"大领主王大发-莫格莱尼 (CN)", "dalingzhuwangdafa"},
    {"Sjerry-死亡之翼 (CN)", "sjerry"},
    {"貼饼子-匕首岭 (CN)", "tiebingzi"},
    {"心耀-冰风岗 (CN)", "xinyao"},
    {"秋末旷夜-凤凰之神 (CN)", "qiumokuangye"},
    {"曾經活過-憤怒使者 (TW)", "cengjinghuoguo"},
    {"音速豆奶-白银之手 (CN)", "yinsudounai"},
    {"Hardpp-Illidan (US)", "hardpp", "六月的奶德-艾露恩"},
    {"握握-暗影之月 (TW)", "wowo"},
    {"Sonichunter-地獄吼 (TW)", "sonichunter", "Katoomba-地獄吼"},
    {"微樓聽雨-銀翼要塞 (TW)", "weiloutingyu"},
    {"黑哥哥-世界之樹 (TW)", "heigege"},
    {"Kuroni-Blackhand (US)", "kuroni"}, -- Kuro (Ko-fi)
    {"Nodwa-Blackhand (US)", "nodwa"}, -- Nodwa (Ko-fi)
    {"Deijava-Illidan (US)", "deijava"}, -- Kyoman (Ko-fi)
    {"Epriestin-TarrenMill (EU)", "epriestin"}, -- Sharelia (ko-fi)
    {"Nascente-TarrenMill (EU)", "nascente"}, -- Nascente-Tarren Mill (Ko-fi)
    {"月刃丶-世界之樹 (TW)", "yuerendian"}, -- Smile (爱发电)
    {"Longmer-Illidan (US)", "longmer"}, -- 爱发电用户_4116d (爱发电)
    {"Phæro-Antonidas (EU)", "phæro", "Callistò-Antonidas (EU)"}, -- Phæro (Ko-fi)
    {"Synthatt-Illidan (US)", "synthatt"}, -- Synthatt (Ko-fi)
}

local patrons2 = {
    {"钛锬 (NGA)", "taitan"},
    {"黑色之城 (NGA)", "heisezhicheng"},
    {"flappysmurf (爱发电)", "flappysmurf"},
    {"Mike (爱发电)", "mike"},
    {"古月文武 (爱发电)", "guyuewenwu"},
    {"CC (爱发电)", "cc"},
    {"蓝色-理想 (NGA)", "lanse-lixiang"},
    {"席慕容 (NGA)", "ximurong"},
    {"星空 (爱发电)", "xingkong"},
    {"年复一年路西法 (爱发电)", "nianfuyinianluxifa"},
    {"阿哲 (爱发电)", "azhe"},
    {"北方 (爱发电)", "beifang"},
    {"warbaby (爱不易)", "warbaby"},
    {"6ND8 (爱发电)", "6nd8"},
    {"伊莉丝翠的眷顾 (爱发电)", "yilisicuidejuangu"},
    {"批歪 (爱发电)", "piwai"},
    {"月神之韧 (爱发电)", "yueshenzhiren"},
    {"Si (爱发电)", "si"},
    {"晓文 (爱发电)", "xiaowen"},
    {"千雪之心 (爱发电)", "qianxuezhixin"},
    {"朝 (爱发电)", "chao"},
    {"ATOMS. ོ (爱发电)", "atoms"},
    {"往事 (爱发电)", "wangshi"},
    {"哄哄 (爱发电)", "honghong"},
    {"acm447 (爱发电)", "acm447"},
    {"花爺 (爱发电)", "huaye"},
    {"得闲饮茶 (爱发电)", "dexianyincha"},
    {"Jane (Ko-fi)", "jane"},
}

-- sort
table.sort(patrons1, function(a, b)
    return a[2] < b[2]
end)

table.sort(patrons2, function(a, b)
    return a[2] < b[2]
end)

-------------------------------------------------
-- patrons (wow IDs)
-------------------------------------------------
local tests = {
    ["Komugi-Fyrakk"] = true,
    ["Celldev-Lycanthoth"] = true,
    ["Programming-BurningLegion"] = true,
    ["Programming-Lycanthoth"] = true,
    ["Programming-影之哀伤"] = true,
    ["篠崎-影之哀伤"] = true,
    ["蜜柑-影之哀伤"] = true,
}

local wowPatrons = {}

do
    for _, t in pairs(patrons1) do
        for i, name in pairs(t) do
            if i == 1 then
                local fullName = strmatch(t[i], "^(.+%-.+) %(%u%u%)$")
                if fullName then
                    wowPatrons[fullName] = true
                end
            elseif i ~= 2 then
                wowPatrons[name] = true
            end
        end
    end
end

-------------------------------------------------
-- make them accessible
-------------------------------------------------
if addonName == "Cell" then -- Cell
    ns.patrons1 = patrons1
    ns.patrons2 = patrons2
    ns.wowPatrons = Cell.funcs:TMergeOverwrite(wowPatrons, tests)
else -- other addons
    ns.cellPatrons = wowPatrons
end