if not LOCALE_zhCN then return end

local L = select( 2, ...).L

L["New version found (%s). Please visit %s to get the latest version."] = "发现新版本 (%s)。 请访问 %s 下载最新版本。"
L["ABOUT"] = "Cell 是受启发于 CompactRaid 的团队框架，参考了其代码，重写并增强。\n我个人很喜欢 CompactRaid，并常年使用它，但其作者似乎已经不再更新了。因此我写了 Cell，希望你能喜欢。\n另外，我也参考了一些很棒的团队框架，比如 Aptechka 和 Grid2。\nCell 并不打算成为一个轻量或强大（如 VuhDo、Grid2）的团队框架插件。设置简单，功能足够，就行了。"

-------------------------------------------------
-- slash command
-------------------------------------------------
L["Available slash commands"] = "可用的斜杠命令"
L["show Cell options frame"] = "打开Cell选项界面"
L["reset Cell position"] = "重置Cell位置"
L["These \"reset\" commands below affect all your characters in this account"] = "以下这些“重置”命令会影响该账号下的所有角色"
L["reset all Layouts and Indicators"] = "重置所有布局与指示器"
L["reset all Click-Castings"] = "重置所有点击施法"
L["reset all Raid Debuffs"] = "重置所有副本减益"
L["reset all Cell settings"] = "重置所有Cell设置"

-------------------------------------------------
-- buttons
-------------------------------------------------
L["Options"] = "选项"
L["Raid"] = "团队"

-------------------------------------------------
-- tools
-------------------------------------------------
L["Pull Timer"] = "开怪倒数"
L["You don't have permission to do this"] = "你没有权限这样做"
L["You"] = "你"
L["%s lock %s on %s."] = "%s将%s锁定在%s。"
L["%s unlock %s from %s."] = "%s将%s从%s解锁。"
-- L["Raid Sort"] = "团队排序"
-- L["Raid Roster"] = "团队名单"

-------------------------------------------------
-- status text
-------------------------------------------------
L["AFK"] = "暂离"
L["DEAD"] = "死亡"
L["GHOST"] = "鬼魂"
L["OFFLINE"] = "离线"
L["PENDING"] = "待定"
L["ACCEPTED"] = "已接受"
L["DECLINED"] = "已拒绝"
L["DRINKING"] = "喝水"

-------------------------------------------------
-- options
-------------------------------------------------
L["Can't change options in combat."] = "无法在战斗中更改设置。"
L["Yes"] = "是"
L["No"] = "否"

-------------------------------------------------
-- general
-------------------------------------------------
L["General"] = "常规"
L["Blizzard Frames"] = "暴雪框体"
L["Hide Blizzard Raid / Party"] = "隐藏暴雪团队/小队"
L["Hide Blizzard Frames"] = "隐藏暴雪框体"
L["Require reload of the UI"] = "需要重载界面"
L["Unit Tooltips"] = "单位鼠标提示"
L["Hide in Combat"] = "战斗中隐藏"
L["Visibility"] = "可见性"
L["Show Solo"] = "单人时显示"
L["Show while not in a group"] = "当不在队伍时显示"
L["To open options frame, use /cell options"] = "用 /cell options 来打开选项窗口"
L["Show Party"] = "小队时显示"
L["Show while in a party"] = "当在小队时显示"
L["Show Party Pets"] = "显示小队宠物"
L["Show pets while in a party"] = "当在小队时显示宠物"
L["Lock Cell Frame"] = "把它给我锁死"
L["Fade Out Menu"] = "淡出菜单"
L["Fade out menu buttons on mouseout"] = "当鼠标移开时淡出菜单按钮"
L["Raid Tools"] = "团队工具"
L["Only in Group"] = "仅在队伍中"
L["Show the number of tanks/healers/damagers while in raid"] = "当在团队时显示坦克、治疗、输出的个数"
L["Only show when you have permission to do this"] = "仅在你有权限这样做时显示"
L["Show ReadyCheck and PullTimer buttons"] = "显示 就位确认 与 开怪倒数 按钮"
L["pullTimerTips"] = "\n|r开怪倒数\n左键单击: |cffffffff开始倒计时|r\n右键单击: |cffffffff取消倒计时|r"
L["Ready"] = "就位"
L["Pull"] = "倒数"
L["Show Marks Bar"] = "显示标记工具条"
L["Target Marks"] = "目标标记"
L["World Marks"] = "世界标记"
L["Both"] = "全部"
L["marksTips"] = "\n|r目标标记\n左键单击: |cffffffff在目标上设置标记|r\n右键单击: |cffffffff将标记锁定在目标上 (在你的队伍中)|r"
L["Mover"] = "移动框"
L["Unlock"] = "解锁"
L["Lock"] = "锁定"
L["Show Battle Res Timer"] = "显示战复计时器"
L["Only show during encounter or in mythic+"] = "仅在首领战或者史诗钥石地下城中显示"
L["BR"] = "战复"

-------------------------------------------------
-- appearance
-------------------------------------------------
L["Appearance"] = "外观"
L["Texture"] = "材质"
L["Scale"] = "缩放"
L["Pixel Perfect"] = "像素精确"
L["Options UI Font Size"] = "选项界面字体尺寸"
L["UnitButton Color"] = "单位按钮颜色"
L["Power Color"] = "能量颜色"
L["Class Color"] = "职业颜色"
L["Class Color (dark)"] = "职业颜色 (暗)"
L["Custom Color"] = "自定义颜色"
L["Bar Color"] = "条颜色"
L["Background Color"] = "背景颜色"
L["Power Color"] = "能量颜色"
L["Target Highlight Color"] = "目标高亮颜色"
L["Mouseover Highlight Color"] = "鼠标指向高亮颜色"
L["Reset All"] = "全部重置"

-------------------------------------------------
-- click-castings
-------------------------------------------------
L["Click-Castings"] = "点击施法"
L["Profiles"] = "配置"
L["Use common profile"] = "使用通用配置"
L["Use separate profile for each spec"] = "为每个天赋使用独立配置"
L["Current Profile"] = "当前配置"
L["Common"] = "通用"
L["New"] = "新建"
L["Save"] = "保存"
L["Discard"] = "撤销"
L["left-click: edit"] = "左键：编辑"
L["right-click: delete"] = "右键：删除"

L["Left"] = "左键"
L["Right"] = "右键"
L["Middle"] = "中键"
L["Button4"] = "侧键4"
L["Button5"] = "侧键5"
L["ScrollUp"] = "滚轮上"
L["ScrollDown"] = "滚轮下"

L["Macro"] = "宏"
L["Spell"] = "法术"
L["target"] = "目标"
L["focus"] = "焦点"
L["assist"] = "协助"
L["togglemenu"] = "菜单"

L["Target"] = "目标"
L["Focus"] = "焦点"
L["Assist"] = "协助"
L["Menu"] = "菜单"

L["T"] = "天赋"
L["P"] = "PvP天赋"

L["Edit"] = "编辑"
L["Extra Action Button"] = "额外按键"
L["Action"] = "动作"
L["Shift+Enter: add a new line"] = "Shift+Enter：添加新行"
L["Enter: apply\nESC: discard"] = "Enter：应用\nESC：取消"
L["Press Key to Bind"] = "点击按键以绑定"

-------------------------------------------------
-- layouts
-------------------------------------------------
L["Layouts"] = "布局"
L["Layout"] = "布局"
L["Currently Enabled"] = "当前启用"
L["Enable"] = "启用"
L["Rename"] = "重命名"
L["Delete"] = "删除"
L["Rename layout"] = "重命名布局"
L["Create new layout"] = "新建布局"
L["(based on current)"] = "(基于当前)"
L["Delete layout"] = "删除布局"
L["Solo/Party"] = "单人/小队"
L["BG 1-15"] = "战场 1-15"
L["BG 16-40"] = "战场 16-40"
L["Group Filter"] = "队伍过滤"
L["Group Arrangement"] = "队伍排列"
L["Orientation"] = "方向"
L["Vertical"] = "纵向"
L["Horizontal"] = "横向"
L["OFF"] = "关"
L["Party"] = "小队"
L["Unit Button Size"] = "单位按钮尺寸"
L["Width"] = "宽"
L["Height"] = "高"
L["Power Height"] = "能量高度"
L["Misc"] = "其他"
L["Unit Spacing"] = "单位间距"
L["Group Columns"] = "队伍列数"
L["Group Rows"] = "队伍行数"
L["Group Spacing"] = "队伍间距"
L["vehicle name"] = "载具名称"
L["Tip: Every layout has its own position setting."] = "提示：每个布局都有其单独的位置设置。"

-------------------------------------------------
-- indicators
-------------------------------------------------
L["Indicators"] = "指示器"
L["Preview"] = "预览"
L["Create"] = "创建"
L["Current Layout"] = "当前布局"
L["Indicator Settings"] = "指示器设置"
L["Name Text"] = "名字"
L["Status Text"] = "状态文字"
L["Health Text"] = "血量文字"
L["Role Icon"] = "职责图标"
L["Leader Icon"] = "队长图标"
L["Ready Check Icon"] = "就位确认图标"
L["Raid Icon (player)"] = "团队标记 (玩家)"
L["Raid Icon (target)"] = "团队标记 (目标)"
L["Aggro Indicator"] = "仇恨指示器"
L["Aggro Bar"] = "仇恨条"
L["Shield Bar"] = "护盾条"
L["AoE Healing"] = "AoE 治疗"
L["External Cooldowns"] = "减伤 (来自他人)"
L["Defensive Cooldowns"] = "减伤 (自身)"
L["Tank Active Mitigation"] = "坦克主动减伤"
L["Dispels"] = "驱散"
L["Debuffs"] = "减益"

L["Create new indicator"] = "创建新指示器"
L["Delete indicator"] = "删除指示器"
L["Buff"] = "增益"
L["Debuff"] = "减益"
L["Buff List"] = "增益列表"
L["Debuff List"] = "减益列表"
L["Enter spell id"] = "输入法术ID"
L["Invalid"] = "无效"
L["Debuff Filter (blacklist)"] = "减益过滤器 (黑名单)"
L["Icon"] = "图标"
L["Rect"] = "矩形"
L["Bar"] = "进度条"
L["Text"] = "文本"
L["Icons"] = "图标组"
L["Bars"] = "进度条组"

L["Enabled"] = "启用"
L["Anchor Point"] = "锚点"
L["To UnitButton's"] = "到单位按钮的"
L["To HealthBar's"] = "到血条的"
L["Vehicle Name Position"] = "载具名称位置"
L["Status Text Position"] = "状态文字位置"
L["Hide"] = "隐藏"
L["Text Width"] = "文字宽度"
L["Unlimited"] = "无限制"
L["Font"] = "字体"
L["Font Outline"] = "字体轮廓"
L["Font Size"] = "字体尺寸"
L["Shadow"] = "阴影"
L["Outline"] = "轮廓"
L["Monochrome Outline"] = "单色轮廓"
L["Name Color"] = "名字颜色"
L["BOTTOM"] = "下"
L["BOTTOMLEFT"] = "左下"
L["BOTTOMRIGHT"] = "右下"
L["CENTER"] = "中"
L["LEFT"] = "左"
L["RIGHT"] = "右"
L["TOP"] = "上"
L["TOPLEFT"] = "左上"
L["TOPRIGHT"] = "右上"
L["X Offset"] = "X 偏移"
L["Y Offset"] = "Y 偏移"
L["Frame Level"] = "层级"
L["Size"] = "尺寸"
L["Border"] = "边框"
L["Alpha"] = "透明度"
L["Max Icons"] = "最大显示数量"
L["Format"] = "格式"
L["hideFull"] = "当血量满时隐藏"
L["Color"] = "颜色"
L["Remaining Time <"] = "剩余时间 <"
L["sec"] = "秒"

L["dispellableByMe"] = "只显示我能驱散的减益"
L["castByMe"] = "只显示我施放的增益"
L["showDuration"] = "显示持续时间文本"
L["enableHighlight"] = "高亮单位按钮"
L["onlyShowTopGlow"] = "仅为当前减益显示高亮效果"

L["left-to-right"] = "从左到右"
L["right-to-left"] = "从右到左"
L["top-to-bottom"] = "从上到下"
L["bottom-to-top"] = "从下到上"

L["Leader Icons will hide while in combat"] = "战斗时队长图标将会隐藏"
L["You can config debuffs in %s"] = "你可以在 %s 里设置减益"
L["Indicator settings are part of Layout settings which are account-wide."] = "指示器设置是布局设置的一部分，它们是账号配置而非角色。"
L["The spells list of a icons indicator is unordered (no priority)."] = "图标组指示器的法术列表是无序的（无优先级）。"
L["The priority of spells decreases from top to bottom."] = "法术优先级从上到下递减。"
L["With this indicator enabled, shield / overshield textures are disabled"] = "启用该指示器将会禁用血条上的护盾材质"

-------------------------------------------------
-- raid debuffs
-------------------------------------------------
L["Raid Debuffs"] = "副本减益"
L["Show Current Instance"] = "显示当前副本"
L["Tips: Drag and drop to change debuff order. Double-click on instance name to open Encounter Journal. The priority of General Debuffs is higher than Boss Debuffs."] = "提示：拖动减益可以调整顺序，双击副本名称可以打开地下城手册。常规减益的优先级比首领减益的优先级更高。"
-- L["Enable All"] = "全部启用"
-- L["Disable All"] = "全部禁用"
L["Track by ID"] = "匹配法术ID"
L["Glow Type"] = "发光类型"
L["Glow Color"] = "发光颜色"
L["None"] = "无"
L["Normal"] = "通常"
L["Pixel"] = "像素"
L["Shine"] = "闪耀"
L["Lines"] = "线条数"
L["Particles"] = "粒子数"
L["Frequency"] = "速度"
L["Length"] = "长度"
L["Thickness"] = "粗细"
L["Create new debuff (id)"] = "创建新减益 (id)"
L["Delete debuff?"] = "删除减益？"
L["Invalid spell id."] = "无效的法术id。"
L["Debuff already exists."] = "减益已存在。"

-------------------------------------------------
-- about
-------------------------------------------------
L["About"] = "关于"
L["Author"] = "作者"
L["Translators"] = "翻译"
L["Slash Commands"] = "斜杠命令"
L["Bug Report & Suggestion"] = "问题报告与建议"

-------------------------------------------------
-- what's new
-------------------------------------------------
L["r26-release"] = [[
    <h1>点击施法</h1>
    <p>点击施法现在支持键盘与多键鼠标。</p> 
    <p>由于代码改动，你可能需要重新设置点击施法的按键绑定。</p>
    <br/>
    <h1>指示器</h1>
    <p>指示器法术列表更新了，现在所有自定义指示器将检查法术ID而不是法术名称。</p>
    <p>因此，需要重新设置自定义指示器的增减益列表才能使其正常显示。</p>
    <br/>
    <h1>指示器预览透明度</h1>
    <p>你现在可以更改指示器预览中的非当前指示器的透明度了，这下调整指示器应该会比以前方便些。</p>
    <p>查看“指示器”页面的右上角的滑动条，你懂的。</p>
    <br/>
    <h1>框体位置</h1>
    <p>每个布局现在有独立的位置设置。</p>
    <p>以下框体的位置已被重置：Cell主框体、标记、就位倒数。</p>
    <br/>
    <h1>其他</h1>
    <p>新增的小队/团队预览模式可以帮你更方便地调整各种布局啦。</p>
    <p>队伍锚点功能来啦，到 布局 -&gt; 队伍排列 那里看看吧。</p>
    <br/>
]]
L["r32-release"] = [[
    <h1>指示器</h1>
    <p>新指示器：血量文字。</p>
    <p>新选项：层级。</p>
    <br/>
    <h1>副本减益 (Beta)</h1>
    <p>添加了暗影国度的副本减益。这些减益目前仅匹配法术名称，之后会添加“匹配法术ID”的选项。</p>
    <p>所有减益默认都是启用的，你可能想要禁用一些不那么重要的减益。</p>
    <br/>
    <h1>其他</h1>
    <p>已修复：标记工具条，点击施法。</p>
    <p>已将“团队构成”文字移至“团队”按钮的鼠标提示中。</p>
    <p>添加了“淡出菜单”的选项。</p>
    <br/>
]]
L["r35-release"] = [[
    <h1>指示器</h1>
    <p>部分内置指示器现在有配置选项了：职责图标，队长图标，就位确认图标，仇恨指示器。</p>
    <p>为“减益 (中间)”添加了“边框”与“仅为当前减益显示高亮效果”的选项。</p>
    <br/>
    <h1>副本减益 (Beta)</h1>
    <p>所有减益默认都是启用的，你可能想要禁用一些不那么重要的减益。</p>
    <p>添加了“匹配法术ID”的选项。</p>
    <p>添加了发光效果的详细配置选项。</p>
    <br/>
    <h1>常规</h1>
    <p>更新了鼠标提示相关选项。</p>
    <br/>
    <h1>布局</h1>
    <p>在“文字宽度”内添加了“隐藏”选项。</p>
    <br/>
]]
L["r36-release"] = [[
    <h1>指示器</h1>
    <p>新指示器：名字，状态文字，护盾条。</p>
    <p>为“减益”指示器添加了“只显示我能驱散的减益”的选项。</p>
    <br/>
    <h1>其他</h1>
    <p>由于指示器的变动，一些字体相关选项被移除了。</p>
    <p>修复了“战复计时器”的框体宽度。</p>
    <p>添加了对OmniCD的支持（仅小队）。</p>
    <br/>
]]