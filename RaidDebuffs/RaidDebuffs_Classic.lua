---------------------------------------------------------------------
-- File: Cell\RaidDebuffs\RaidDebuffs_Classic.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2022-08-05 17:46:11 +08:00
-- Modified: 2023-07-16 15:34:29 +08:00
---------------------------------------------------------------------

local _, Cell = ...
local F = Cell.funcs

local debuffs = {
    [741] = { -- 熔火之心
        ["general"] = {
        },
        [1519] = { -- 鲁西弗隆
        },
        [1520] = { -- 玛格曼达
        },
        [1521] = { -- 基赫纳斯
        },
        [1522] = { -- 加尔
        },
        [1523] = { -- 沙斯拉尔
        },
        [1524] = { -- 迦顿男爵
        },
        [1525] = { -- 萨弗隆先驱者
        },
        [1526] = { -- 焚化者古雷曼格
        },
        [1527] = { -- 管理者埃克索图斯
        },
        [1528] = { -- 拉格纳罗斯
        },
    },

    [742] = { -- 黑翼之巢
        ["general"] = {
        },
        [1529] = { -- 狂野的拉佐格尔
        },
        [1530] = { -- 堕落的瓦拉斯塔兹
        },
        [1531] = { -- 勒什雷尔
        },
        [1532] = { -- 费尔默
        },
        [1533] = { -- 埃博诺克
        },
        [1534] = { -- 弗莱格尔
        },
        [1535] = { -- 克洛玛古斯
        },
        [1536] = { -- 奈法利安
        },
    },

    [743] = { -- 安其拉废墟
        ["general"] = {
        },
        [1537] = { -- 库林纳克斯
        },
        [1538] = { -- 拉贾克斯将军
        },
        [1539] = { -- 莫阿姆
        },
        [1540] = { -- 吞咽者布鲁
        },
        [1541] = { -- 狩猎者阿亚米斯
        },
        [1542] = { -- 无疤者奥斯里安
        },
    },

    [744] = { -- 安其拉神殿
        ["general"] = {
        },
        [1543] = { -- 预言者斯克拉姆
        },
        [1547] = { -- 安其拉三宝
        },
        [1544] = { -- 沙尔图拉
        },
        [1545] = { -- 顽强的范克瑞斯
        },
        [1548] = { -- 维希度斯
        },
        [1546] = { -- 哈霍兰公主
        },
        [1549] = { -- 双子皇帝
        },
        [1550] = { -- 奥罗
        },
        [1551] = { -- 克苏恩
        },
    },

    [234] = { -- 剃刀沼泽
        ["general"] = {
        },
        [896] = { -- 猎手布塔斯克
        },
        [895] = { -- 鲁古格
        },
        [899] = { -- 督军拉姆塔斯
        },
        [900] = { -- 盲眼猎手格罗亚特
        },
        [901] = { -- 卡尔加·刺肋
        },
    },

    [233] = { -- 剃刀高地
        ["general"] = {
        },
        [1142] = { -- 阿鲁克斯
        },
        [433] = { -- 火眼莫德雷斯
        },
        [1143] = { -- 麦什伦
        },
        [1146] = { -- 亡语者布莱克松
        },
        [1141] = { -- 寒冰之王亚门纳尔
        },
    },

    [230] = { -- 厄运之槌
        ["general"] = {
        },
        [402] = { -- 瑟雷姆·刺蹄
        },
        [403] = { -- 海多斯博恩
        },
        [404] = { -- 蕾瑟塔蒂丝
        },
        [405] = { -- 荒野变形者奥兹恩
        },
        [406] = { -- 特迪斯·扭木
        },
        [407] = { -- 伊琳娜·暗木
        },
        [408] = { -- 卡雷迪斯镇长
        },
        [409] = { -- 伊莫塔尔
        },
        [410] = { -- 托塞德林王子
        },
        [411] = { -- 卫兵摩尔达
        },
        [412] = { -- 践踏者克雷格
        },
        [413] = { -- 卫兵芬古斯
        },
        [414] = { -- 卫兵斯里基克
        },
        [415] = { -- 克罗卡斯
        },
        [416] = { -- 观察者克鲁什
        },
        [417] = { -- 戈多克大王
        },
    },

    [240] = { -- 哀嚎洞穴
        ["general"] = {
        },
        [474] = { -- 安娜科德拉
        },
        [476] = { -- 皮萨斯
        },
        [475] = { -- 考布莱恩
        },
        [477] = { -- 克雷什
        },
        [478] = { -- 斯卡姆
        },
        [479] = { -- 瑟芬迪斯
        },
        [480] = { -- 永生者沃尔丹
        },
        [481] = { -- 吞噬者穆坦努斯
        },
    },

    [239] = { -- 奥达曼
        ["general"] = {
        },
        [467] = { -- 鲁维罗什
        },
        [468] = { -- 失踪的矮人
        },
        [469] = { -- 艾隆纳亚
        },
        [748] = { -- 黑曜石哨兵
        },
        [470] = { -- 远古巨石卫士
        },
        [471] = { -- 加加恩·火锤
        },
        [472] = { -- 格瑞姆洛克
        },
        [473] = { -- 阿扎达斯
        },
    },

    [64] = { -- 影牙城堡
        ["general"] = {
        },
        [96] = { -- 灰葬男爵
        },
        [97] = { -- 席瓦莱恩男爵
        },
        [98] = { -- 指挥官斯普林瓦尔
        },
        [99] = { -- 沃登勋爵
        },
        [100] = { -- 高弗雷勋爵
        },
    },

    [226] = { -- 怒焰裂谷
        ["general"] = {
        },
        [694] = { -- 阿达罗格
        },
        [695] = { -- 黑暗萨满柯兰萨
        },
        [696] = { -- 焰喉
        },
        [697] = { -- 熔岩守卫戈多斯
        },
    },

    [236] = { -- 斯坦索姆
        ["general"] = {
        },
        [443] = { -- 弗雷斯特恩
        },
        [445] = { -- 悲惨的提米
        },
        [749] = { -- 指挥官玛洛尔
        },
        [446] = { -- 希望破坏者威利
        },
        [448] = { -- 档案管理员加尔福特
        },
        [449] = { -- 巴纳扎尔
        },
        [450] = { -- 不可宽恕者
        },
        [451] = { -- 安娜丝塔丽男爵夫人
        },
        [452] = { -- 奈鲁布恩坎
        },
        [453] = { -- 苍白的玛勒基
        },
        [454] = { -- 巴瑟拉斯镇长
        },
        [455] = { -- 吞咽者拉姆斯登
        },
        [456] = { -- 奥里克斯·瑞文戴尔领主
        },
    },

    [63] = { -- 死亡矿井
        ["general"] = {
        },
        [89] = { -- 格拉布托克
        },
        [90] = { -- 赫利克斯·破甲
        },
        [91] = { -- 死神5000
        },
        [92] = { -- 撕心狼将军
        },
        [93] = { -- “船长”曲奇
        },
    },

    [232] = { -- 玛拉顿
        ["general"] = {
        },
        [423] = { -- 诺克赛恩
        },
        [424] = { -- 锐刺鞭笞者
        },
        [425] = { -- 工匠吉兹洛克
        },
        [427] = { -- 维利塔恩
        },
        [428] = { -- 被诅咒的塞雷布拉斯
        },
        [429] = { -- 兰斯利德
        },
        [430] = { -- 洛特格里普
        },
        [431] = { -- 瑟莱德丝公主
        },
    },

    [238] = { -- 监狱
        ["general"] = {
        },
        [464] = { -- 霍格
        },
        [465] = { -- 灼热勋爵
        },
        [466] = { -- 兰多菲·摩洛克
        },
    },

    [241] = { -- 祖尔法拉克
        ["general"] = {
        },
        [483] = { -- 加兹瑞拉
        },
        [484] = { -- 安图苏尔
        },
        [485] = { -- 殉教者塞卡
        },
        [486] = { -- 巫医祖穆拉恩
        },
        [487] = { -- 耐克鲁姆和塞瑟斯
        },
        [489] = { -- 乌克兹·沙顶
        },
    },

    [316] = { -- 血色修道院
        ["general"] = {
        },
        [688] = { -- 裂魂者萨尔诺斯
        },
        [671] = { -- 科洛夫修士
        },
        [674] = { -- 大检察官怀特迈恩
        },
    },

    [311] = { -- 血色大厅
        ["general"] = {
        },
        [660] = { -- 驯犬者布兰恩
        },
        [654] = { -- 武器大师哈兰
        },
        [656] = { -- 织焰者孔格勒
        },
    },

    [231] = { -- 诺莫瑞根
        ["general"] = {
        },
        [419] = { -- 格鲁比斯
        },
        [420] = { -- 粘性辐射尘
        },
        [421] = { -- 电刑器6000型
        },
        [418] = { -- 群体打击者9-60
        },
        [422] = { -- 机械师瑟玛普拉格
        },
    },

    [246] = { -- 通灵学院
        ["general"] = {
        },
        [659] = { -- 指导者寒心
        },
        [663] = { -- 詹迪斯·巴罗夫
        },
        [665] = { -- 血骨傀儡
        },
        [666] = { -- 莉莉安·沃斯
        },
        [684] = { -- 黑暗院长加丁
        },
    },

    [237] = { -- 阿塔哈卡神庙
        ["general"] = {
        },
        [457] = { -- 哈卡的化身
        },
        [458] = { -- 预言者迦玛兰
        },
        [459] = { -- 梦境守望者
        },
        [463] = { -- 伊兰尼库斯的阴影
        },
    },

    [227] = { -- 黑暗深渊
        ["general"] = {
        },
        [368] = { -- 加摩拉
        },
        [436] = { -- 多米尼娜
        },
        [426] = { -- 征服者克鲁尔
        },
        [1145] = { -- 苏克
        },
        [447] = { -- 深渊守护者
        },
        [1144] = { -- 刽子手戈尔
        },
        [437] = { -- 暮光领主巴赛尔
        },
        [444] = { -- 阿库麦尔
        },
    },

    [229] = { -- 黑石塔下层
        ["general"] = {
        },
        [388] = { -- 欧莫克大王
        },
        [389] = { -- 暗影猎手沃什加斯
        },
        [390] = { -- 指挥官沃恩
        },
        [391] = { -- 烟网蛛后
        },
        [392] = { -- 尤洛克·暗嚎
        },
        [393] = { -- 军需官兹格雷斯
        },
        [394] = { -- 哈雷肯
        },
        [395] = { -- 奴役者基兹鲁尔
        },
        [396] = { -- 维姆萨拉克
        },
    },

    [228] = { -- 黑石深渊
        ["general"] = {
        },
        [369] = { -- 审讯官格斯塔恩
        },
        [370] = { -- 洛考尔
        },
        [371] = { -- 驯犬者格雷布玛尔
        },
        [372] = { -- 秩序竞技场
        },
        [373] = { -- 控火师罗格雷恩
        },
        [374] = { -- 伊森迪奥斯
        },
        [375] = { -- 典狱官斯迪尔基斯
        },
        [376] = { -- 弗诺斯·达克维尔
        },
        [377] = { -- 贝尔加
        },
        [378] = { -- 怒炉将军
        },
        [379] = { -- 傀儡统帅阿格曼奇
        },
        [380] = { -- 霍尔雷·黑须
        },
        [381] = { -- 法拉克斯
        },
        [383] = { -- 普拉格
        },
        [384] = { -- 弗莱拉斯总大使
        },
        [385] = { -- 黑铁七贤
        },
        [386] = { -- 玛格姆斯
        },
        [387] = { -- 达格兰·索瑞森大帝
        },
    },
}

F:LoadBuiltInDebuffs(debuffs)
