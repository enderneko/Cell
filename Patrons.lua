local addonName, ns = ...

-------------------------------------------------
-- patrons (order by date)
-------------------------------------------------
local patrons = {
    -- {"nameInPatronList", "sortKey", "wowIDs"...}
    {"小兔姬-影之哀伤 (CN)", "xiaotuji", "渺渺-影之哀伤"},
    {"钛锬 (NGA)", "taitan"},
    {"黑色之城 (NGA)", "heisezhicheng"},
    {"夏木沐-伊森利恩 (CN)", "xiamumu"},
    {"flappysmurf (爱发电)", "flappysmurf"},
    {"七月核桃丶-白银之手 (CN)", "qiyuehetaodian"},
    {"芋包-影之哀伤 (CN)", "yubao"},
    {"青乙-影之哀伤 (CN)", "qingyi"},
    {"黑丨诺-影之哀伤 (CN)", "heishunuo"},
    {"Mike (爱发电)", "mike"},
    {"大领主王大发-莫格莱尼 (CN)", "dalingzhuwangdafa"},
    {"古月文武 (爱发电)", "guyuewenwu"},
    {"CC (爱发电)", "cc"},
    {"蓝色-理想 (NGA)", "lanse-lixiang"},
    {"席慕容 (NGA)", "ximurong"},
    {"星空 (爱发电)", "xingkong"},
    {"年复一年路西法 (爱发电)", "nianfuyinianluxifa"},
    {"阿哲 (爱发电)", "azhe"},
    {"北方 (爱发电)", "beifang"},
    {"Sjerry-死亡之翼 (CN)", "sjerry"},
    {"貼饼子-匕首岭 (CN)", "tiebingzi"},
    {"warbaby (爱不易)", "warbaby", "心耀-冰风岗"},
    {"6ND8 (爱发电)", "6nd8"},
    {"伊莉丝翠的眷顾 (爱发电)", "yilisicuidejuangu"},
    {"秋末旷夜-凤凰之神 (CN)", "qiumokuangye"},
    {"批歪 (爱发电)", "piwai"},
    {"曾經活過-憤怒使者 (TW)", "cengjinghuoguo"},
    {"音速豆奶-白银之手 (CN)", "yinsudounai"},
    {"月神之韧 (爱发电)", "yueshenzhiren"},
    {"Si (爱发电)", "si"},
    {"晓文 (爱发电)", "xiaowen"},
    {"Hardpp-Illidan (US)", "hardpp", "六月的奶德-艾露恩"},
    {"握握-暗影之月 (TW)", "wowo"},
    {"千雪之心 (爱发电)", "qianxuezhixin"},
    {"朝 (爱发电)", "chao"},
    {"Sonichunter-地獄吼 (TW)", "sonichunter", "Katoomba-地獄吼 (TW)"},
    {"ATOMS. ོ (爱发电)", "atoms"},
    {"微樓聽雨-銀翼要塞 (TW)", "weiloutingyu"},
    {"往事 (爱发电)", "wangshi"},
    {"哄哄 (爱发电)", "honghong"},
    {"acm447 (爱发电)", "acm447"},
    {"花爺 (爱发电)", "huaye"},
    {"黑哥哥-世界之樹 (TW)", "heigege"},
}

-- sort
table.sort(patrons, function(a, b)
    return a[2] < b[2]
end)

-------------------------------------------------
-- patrons (wow IDs)
-------------------------------------------------
local tests = {
    ["Devevoker-Lycanthoth"] = true,
    ["Celldev-Lycanthoth"] = true,
    ["Programming-Lycanthoth"] = true,
    ["Programming-影之哀伤"] = true,
    ["篠崎-影之哀伤"] = true,
    ["蜜柑-影之哀伤"] = true,
}

local wowPatrons = {}

do
    for _, t in pairs(patrons) do
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
    ns.patrons = patrons
    ns.wowPatrons = Cell.funcs:TMergeOverwrite(wowPatrons, tests)
else -- other addons
    ns.cellPatrons = wowPatrons
end