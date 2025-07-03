-- these data will be moved into AbstractFramework when Cell finishes migrating to AbstractFramework

local specData = {
    -- Death Knight
    [250] = { -- Blood
        ["name"] = {enUS = "Blood", deDE = "Blut", esES = "Sangre", esMX = "Sangre", frFR = "Sang", itIT = "Sangue", koKR = "혈기", ptBR = "Sangue", ruRU = "Кровь", zhCN = "鲜血", zhTW = "血魄"},
        ["role"] = "TANK",
        ["icon"] = 135770,
        ["classId"] = 6,
    },
    [251] = { -- Frost
        ["name"] = {enUS = "Frost", deDE = "Frost", esES = "Escarcha", esMX = "Escarcha", frFR = "Givre", itIT = "Gelo", koKR = "냉기", ptBR = "Gélido", ruRU = "Лед", zhCN = "冰霜", zhTW = "冰霜"},
        ["role"] = "MELEE",
        ["icon"] = 135773,
        ["classId"] = 6,
    },
    [252] = { -- Unholy
        ["name"] = {enUS = "Unholy", deDE = "Unheilig", esES = "Profano", esMX = "Profano", frFR = "Impie", itIT = "Empietà", koKR = "부정", ptBR = "Profano", ruRU = "Нечестивость", zhCN = "邪恶", zhTW = "穢邪"},
        ["role"] = "MELEE",
        ["icon"] = 135775,
        ["classId"] = 6,
    },
    [1455] = {
        ["name"] = {enUS = "Initial", deDE = "Standard", esES = "Inicial", esMX = "Inicial", frFR = "Initial", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 135775,
        ["classId"] = 6,
    },

    -- Demon Hunter
    [577] = { -- Havoc
        ["name"] = {enUS = "Havoc", deDE = "Verwüstung", esES = "Devastación", esMX = "Caos", frFR = "Dévastation", itIT = "Rovina", koKR = "파멸", ptBR = "Devastação", ruRU = "Истребление", zhCN = "浩劫", zhTW = "災虐"},
        ["role"] = "MELEE",
        ["icon"] = 1247264,
        ["classId"] = 12,
    },
    [581] = { -- Vengeance
        ["name"] = {enUS = "Vengeance", deDE = "Rachsucht", esES = "Venganza", esMX = "Venganza", frFR = "Vengeance", itIT = "Vendetta", koKR = "복수", ptBR = "Vingança", ruRU = "Месть", zhCN = "复仇", zhTW = "復仇"},
        ["role"] = "TANK",
        ["icon"] = 1247265,
        ["classId"] = 12,
    },
    [1456] = {
        ["name"] = {enUS = "Initial", deDE = "Standard", esES = "Inicial", esMX = "Inicial", frFR = "Initial", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 1247264,
        ["classId"] = 12,
    },

    -- Druid
    [102] = { -- Balance
        ["name"] = {enUS = "Balance", deDE = "Gleichgewicht", esES = "Equilibrio", esMX = "Equilibrio", frFR = "Équilibre", itIT = "Equilibrio", koKR = "조화", ptBR = "Equilíbrio", ruRU = "Баланс", zhCN = "平衡", zhTW = "平衡"},
        ["role"] = "RANGED",
        ["icon"] = 136096,
        ["classId"] = 11,
    },
    [103] = { -- Feral
        ["name"] = {enUS = "Feral", deDE = "Wildheit", esES = "Feral", esMX = "Feral", frFR = "Farouche", itIT = "Aggressore Ferino", koKR = "야성", ptBR = "Feral", ruRU = "Сила зверя", zhCN = "野性", zhTW = "野性戰鬥"},
        ["role"] = "MELEE",
        ["icon"] = 132115,
        ["classId"] = 11,
    },
    [104] = { -- Guardian
        ["name"] = {enUS = "Guardian", deDE = "Wächter", esES = "Guardián", esMX = "Guardián", frFR = "Gardien", itIT = "Guardiano Ferino", koKR = "수호", ptBR = "Guardião", ruRU = "Страж", zhCN = "守护", zhTW = "守護者"},
        ["role"] = "TANK",
        ["icon"] = 132276,
        ["classId"] = 11,
    },
    [105] = { -- Restoration
        ["name"] = {enUS = "Restoration", deDE = "Wiederherstellung", esES = "Restauración", esMX = "Restauración", frFR = "Restauration", itIT = "Rigenerazione", koKR = "회복", ptBR = "Restauração", ruRU = "Исцеление", zhCN = "恢复", zhTW = "恢復"},
        ["role"] = "HEALER",
        ["icon"] = 136041,
        ["classId"] = 11,
    },
    [1447] = {
        ["name"] = {enUS = "Initial", deDE = "Standard", esES = "Inicial", esMX = "Inicial", frFR = "Initial", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 136096,
        ["classId"] = 11,
    },

    -- Evoker
    [1467] = { -- Devastation
        ["name"] = {enUS = "Devastation", deDE = "Verheerung", esES = "Devastación", esMX = "Devastación", frFR = "Dévastation", itIT = "Devastazione", koKR = "황폐", ptBR = "Devastação", ruRU = "Опустошитель", zhCN = "湮灭", zhTW = "破滅"},
        ["role"] = "RANGED",
        ["icon"] = 4511811,
        ["classId"] = 13,
    },
    [1468] = { -- Preservation
        ["name"] = {enUS = "Preservation", deDE = "Bewahrung", esES = "Preservación", esMX = "Preservación", frFR = "Préservation", itIT = "Conservazione", koKR = "보존", ptBR = "Preservação", ruRU = "Хранитель", zhCN = "恩护", zhTW = "護存"},
        ["role"] = "HEALER",
        ["icon"] = 4511812,
        ["classId"] = 13,
    },
    [1473] = { -- Augmentation
        ["name"] = {enUS = "Augmentation", deDE = "Verstärkung", esES = "Aumento", esMX = "Aumento", frFR = "Augmentation", itIT = "Fortificazione", koKR = "증강", ptBR = "Aprimoramento", ruRU = "Насыщатель", zhCN = "增辉", zhTW = "強化"},
        ["role"] = "RANGED",
        ["icon"] = 5198700,
        ["classId"] = 13,
    },
    [1465] = {
        ["name"] = {enUS = "Initial", deDE = "Initiand", esES = "Inicial", esMX = "Inicial", frFR = "Primaire", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 4574311,
        ["classId"] = 13,
    },

    -- Hunter
    [253] = { -- Beast Mastery
        ["name"] = {enUS = "Beast Mastery", deDE = "Tierherrschaft", esES = "Bestias", esMX = "Bestias", frFR = "Maîtrise des bêtes", itIT = "Affinità Animale", koKR = "야수", ptBR = "Domínio das Feras", ruRU = "Повелитель зверей", zhCN = "野兽控制", zhTW = "野獸控制"},
        ["role"] = "RANGED",
        ["icon"] = 461112,
        ["classId"] = 3,
    },
    [254] = { -- Marksmanship
        ["name"] = {enUS = "Marksmanship", deDE = "Treffsicherheit", esES = "Puntería", esMX = "Puntería", frFR = "Précision", itIT = "Precisione di Tiro", koKR = "사격", ptBR = "Precisão", ruRU = "Стрельба", zhCN = "射击", zhTW = "射擊"},
        ["role"] = "RANGED",
        ["icon"] = 236179,
        ["classId"] = 3,
    },
    [255] = { -- Survival
        ["name"] = {enUS = "Survival", deDE = "Überleben", esES = "Supervivencia", esMX = "Supervivencia", frFR = "Survie", itIT = "Sopravvivenza", koKR = "생존", ptBR = "Sobrevivência", ruRU = "Выживание", zhCN = "生存", zhTW = "生存"},
        ["role"] = "MELEE",
        ["icon"] = 461113,
        ["classId"] = 3,
    },
    [1448] = {
        ["name"] = {enUS = "Initial", deDE = "Standard", esES = "Inicial", esMX = "Inicial", frFR = "Initial", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 461112,
        ["classId"] = 3,
    },

    -- Mage
    [62] = { -- Arcane
        ["name"] = {enUS = "Arcane", deDE = "Arkan", esES = "Arcano", esMX = "Arcano", frFR = "Arcanes", itIT = "Arcano", koKR = "비전", ptBR = "Arcano", ruRU = "Тайная магия", zhCN = "奥术", zhTW = "秘法"},
        ["role"] = "RANGED",
        ["icon"] = 135932,
        ["classId"] = 8,
    },
    [63] = { -- Fire
        ["name"] = {enUS = "Fire", deDE = "Feuer", esES = "Fuego", esMX = "Fuego", frFR = "Feu", itIT = "Fuoco", koKR = "화염", ptBR = "Fogo", ruRU = "Огонь", zhCN = "火焰", zhTW = "火焰"},
        ["role"] = "RANGED",
        ["icon"] = 135810,
        ["classId"] = 8,
    },
    [64] = { -- Frost
        ["name"] = {enUS = "Frost", deDE = "Frost", esES = "Escarcha", esMX = "Escarcha", frFR = "Givre", itIT = "Gelo", koKR = "냉기", ptBR = "Gélido", ruRU = "Лед", zhCN = "冰霜", zhTW = "冰霜"},
        ["role"] = "RANGED",
        ["icon"] = 135846,
        ["classId"] = 8,
    },
    [1449] = {
        ["name"] = {enUS = "Initial", deDE = "Standard", esES = "Inicial", esMX = "Inicial", frFR = "Initial", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 135846,
        ["classId"] = 8,
    },

    -- Monk
    [268] = { -- Brewmaster
        ["name"] = {enUS = "Brewmaster", deDE = "Braumeister", esES = "Maestro cervecero", esMX = "Maestro cervecero", frFR = "Maître brasseur", itIT = "Mastro Birraio", koKR = "양조", ptBR = "Mestre Cervejeiro", ruRU = "Хмелевар", zhCN = "酒仙", zhTW = "釀酒"},
        ["role"] = "TANK",
        ["icon"] = 608951,
        ["classId"] = 10,
    },
    [269] = { -- Windwalker
        ["name"] = {enUS = "Windwalker", deDE = "Windläufer", esES = "Viajero del viento", esMX = "Viajero del viento", frFR = "Marche-vent", itIT = "Impeto", koKR = "풍운", ptBR = "Andarilho do Vento", ruRU = "Танцующий с ветром", zhCN = "踏风", zhTW = "御風"},
        ["role"] = "MELEE",
        ["icon"] = 608953,
        ["classId"] = 10,
    },
    [270] = { -- Mistweaver
        ["name"] = {enUS = "Mistweaver", deDE = "Nebelwirker", esES = "Tejedor de niebla", esMX = "Tejedor de niebla", frFR = "Tisse-brume", itIT = "Misticismo", koKR = "운무", ptBR = "Tecelão da Névoa", ruRU = "Ткач туманов", zhCN = "织雾", zhTW = "織霧"},
        ["role"] = "HEALER",
        ["icon"] = 608952,
        ["classId"] = 10,
    },
    [1450] = {
        ["name"] = {enUS = "Initial", deDE = "Standard", esES = "Inicial", esMX = "Inicial", frFR = "Initial", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 608953,
        ["classId"] = 10,
    },

    -- Paladin
    [65] = { -- Holy
        ["name"] = {enUS = "Holy", deDE = "Heilig", esES = "Sagrado", esMX = "Sagrado", frFR = "Sacré", itIT = "Sacro", koKR = "신성", ptBR = "Sagrado", ruRU = "Свет", zhCN = "神圣", zhTW = "神聖"},
        ["role"] = "HEALER",
        ["icon"] = 135920,
        ["classId"] = 2,
    },
    [66] = { -- Protection
        ["name"] = {enUS = "Protection", deDE = "Schutz", esES = "Protección", esMX = "Protección", frFR = "Protection", itIT = "Protezione", koKR = "보호", ptBR = "Proteção", ruRU = "Защита", zhCN = "防护", zhTW = "防護"},
        ["role"] = "TANK",
        ["icon"] = 236264,
        ["classId"] = 2,
    },
    [70] = { -- Retribution
        ["name"] = {enUS = "Retribution", deDE = "Vergeltung", esES = "Reprensión", esMX = "Reprensión", frFR = "Vindicte", itIT = "Castigo", koKR = "징벌", ptBR = "Retribuição", ruRU = "Воздаяние", zhCN = "惩戒", zhTW = "懲戒"},
        ["role"] = "MELEE",
        ["icon"] = 135873,
        ["classId"] = 2,
    },
    [1451] = {
        ["name"] = {enUS = "Initial", deDE = "Standard", esES = "Inicial", esMX = "Inicial", frFR = "Initial", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 135873,
        ["classId"] = 2,
    },

    -- Priest
    [256] = { -- Discipline
        ["name"] = {enUS = "Discipline", deDE = "Disziplin", esES = "Disciplina", esMX = "Disciplina", frFR = "Discipline", itIT = "Disciplina", koKR = "수양", ptBR = "Disciplina", ruRU = "Послушание", zhCN = "戒律", zhTW = "戒律"},
        ["role"] = "HEALER",
        ["icon"] = 135940,
        ["classId"] = 5,
    },
    [257] = { -- Holy
        ["name"] = {enUS = "Holy", deDE = "Heilig", esES = "Sagrado", esMX = "Sagrado", frFR = "Sacré", itIT = "Sacro", koKR = "신성", ptBR = "Sagrado", ruRU = "Свет", zhCN = "神圣", zhTW = "神聖"},
        ["role"] = "HEALER",
        ["icon"] = 237542,
        ["classId"] = 5,
    },
    [258] = { -- Shadow
        ["name"] = {enUS = "Shadow", deDE = "Schatten", esES = "Sombra", esMX = "Sombra", frFR = "Ombre", itIT = "Ombra", koKR = "암흑", ptBR = "Sombra", ruRU = "Тьма", zhCN = "暗影", zhTW = "暗影"},
        ["role"] = "RANGED",
        ["icon"] = 136207,
        ["classId"] = 5,
    },
    [1452] = {
        ["name"] = {enUS = "Initial", deDE = "Standard", esES = "Inicial", esMX = "Inicial", frFR = "Initial", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 135940,
        ["classId"] = 5,
    },

    -- Rogue
    [259] = { -- Assassination
        ["name"] = {enUS = "Assassination", deDE = "Meucheln", esES = "Asesinato", esMX = "Asesinato", frFR = "Assassinat", itIT = "Assassinio", koKR = "암살", ptBR = "Assassinato", ruRU = "Ликвидация", zhCN = "奇袭", zhTW = "刺殺"},
        ["role"] = "MELEE",
        ["icon"] = 236270,
        ["classId"] = 4,
    },
    [260] = { -- Outlaw
        ["name"] = {enUS = "Outlaw", deDE = "Gesetzlosigkeit", esES = "Forajido", esMX = "Forajido", frFR = "Hors-la-loi", itIT = "Fuorilegge", koKR = "무법", ptBR = "Fora da Lei", ruRU = "Головорез", zhCN = "狂徒", zhTW = "暴徒"},
        ["role"] = "MELEE",
        ["icon"] = 236286,
        ["classId"] = 4,
    },
    [261] = { -- Subtlety
        ["name"] = {enUS = "Subtlety", deDE = "Täuschung", esES = "Sutileza", esMX = "Sutileza", frFR = "Finesse", itIT = "Scaltrezza", koKR = "잠행", ptBR = "Subterfúgio", ruRU = "Скрытность", zhCN = "敏锐", zhTW = "敏銳"},
        ["role"] = "MELEE",
        ["icon"] = 132320,
        ["classId"] = 4,
    },
    [1453] = {
        ["name"] = {enUS = "Initial", deDE = "Standard", esES = "Inicial", esMX = "Inicial", frFR = "Initial", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 236270,
        ["classId"] = 4,
    },

    -- Shaman
    [262] = { -- Elemental
        ["name"] = {enUS = "Elemental", deDE = "Elementar", esES = "Elemental", esMX = "Elemental", frFR = "Élémentaire", itIT = "Elementale", koKR = "정기", ptBR = "Elemental", ruRU = "Стихии", zhCN = "元素", zhTW = "元素"},
        ["role"] = "RANGED",
        ["icon"] = 136048,
        ["classId"] = 7,
    },
    [263] = { -- Enhancement
        ["name"] = {enUS = "Enhancement", deDE = "Verstärkung", esES = "Mejora", esMX = "Mejora", frFR = "Amélioration", itIT = "Potenziamento", koKR = "고양", ptBR = "Aperfeiçoamento", ruRU = "Совершенствование", zhCN = "增强", zhTW = "增強"},
        ["role"] = "MELEE",
        ["icon"] = 237581,
        ["classId"] = 7,
    },
    [264] = { -- Restoration
        ["name"] = {enUS = "Restoration", deDE = "Wiederherstellung", esES = "Restauración", esMX = "Restauración", frFR = "Restauration", itIT = "Rigenerazione", koKR = "복원", ptBR = "Restauração", ruRU = "Исцеление", zhCN = "恢复", zhTW = "恢復"},
        ["role"] = "HEALER",
        ["icon"] = 136052,
        ["classId"] = 7,
    },
    [1444] = {
        ["name"] = {enUS = "Initial", deDE = "Standard", esES = "Inicial", esMX = "Inicial", frFR = "Initial", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 136048,
        ["classId"] = 7,
    },

    -- Warlock
    [265] = { -- Affliction
        ["name"] = {enUS = "Affliction", deDE = "Gebrechen", esES = "Aflicción", esMX = "Aflicción", frFR = "Affliction", itIT = "Afflizione", koKR = "고통", ptBR = "Suplício", ruRU = "Колдовство", zhCN = "痛苦", zhTW = "痛苦"},
        ["role"] = "RANGED",
        ["icon"] = 136145,
        ["classId"] = 9,
    },
    [266] = { -- Demonology
        ["name"] = {enUS = "Demonology", deDE = "Dämonologie", esES = "Demonología", esMX = "Demonología", frFR = "Démonologie", itIT = "Demonologia", koKR = "악마", ptBR = "Demonologia", ruRU = "Демонология", zhCN = "恶魔学识", zhTW = "惡魔學識"},
        ["role"] = "RANGED",
        ["icon"] = 136172,
        ["classId"] = 9,
    },
    [267] = { -- Destruction
        ["name"] = {enUS = "Destruction", deDE = "Zerstörung", esES = "Destrucción", esMX = "Destrucción", frFR = "Destruction", itIT = "Distruzione", koKR = "파괴", ptBR = "Destruição", ruRU = "Разрушение", zhCN = "毁灭", zhTW = "毀滅"},
        ["role"] = "RANGED",
        ["icon"] = 136186,
        ["classId"] = 9,
    },
    [1454] = {
        ["name"] = {enUS = "Initial", deDE = "Standard", esES = "Inicial", esMX = "Inicial", frFR = "Initial", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 136145,
        ["classId"] = 9,
    },

    -- Warrior
    [71] = { -- Arms
        ["name"] = {enUS = "Arms", deDE = "Waffen", esES = "Armas", esMX = "Armas", frFR = "Armes", itIT = "Armi", koKR = "무기", ptBR = "Armas", ruRU = "Оружие", zhCN = "武器", zhTW = "武器"},
        ["role"] = "MELEE",
        ["icon"] = 132355,
        ["classId"] = 1,
    },
    [72] = { -- Fury
        ["name"] = {enUS = "Fury", deDE = "Furor", esES = "Furia", esMX = "Furia", frFR = "Fureur", itIT = "Furia", koKR = "분노", ptBR = "Fúria", ruRU = "Неистовство", zhCN = "狂怒", zhTW = "狂怒"},
        ["role"] = "MELEE",
        ["icon"] = 132347,
        ["classId"] = 1,
    },
    [73] = { -- Protection
        ["name"] = {enUS = "Protection", deDE = "Schutz", esES = "Protección", esMX = "Protección", frFR = "Protection", itIT = "Protezione", koKR = "방어", ptBR = "Proteção", ruRU = "Защита", zhCN = "防护", zhTW = "防護"},
        ["role"] = "TANK",
        ["icon"] = 132341,
        ["classId"] = 1,
    },
    [1446] = {
        ["name"] = {enUS = "Initial", deDE = "Standard", esES = "Inicial", esMX = "Inicial", frFR = "Initial", itIT = "Iniziale", koKR = "입문", ptBR = "Inicial", ruRU = "Начальный", zhCN = "初始", zhTW = "初始"},
        ["role"] = "DAMAGER",
        ["icon"] = 132355,
        ["classId"] = 1,
    },

    -- Adventurer
    [1478] = {
        ["name"] = {enUS = "Adventurer", deDE = "Abenteurer", esES = "Aventurero", esMX = "Aventurero", frFR = "Aventurier", itIT = "Avventuriero", koKR = "모험가", ptBR = "Aventureiro", ruRU = "Искатель приключений", zhCN = "冒险者", zhTW = "冒險者"},
        ["role"] = "DAMAGER",
        ["icon"] = 2055034,
        ["classId"] = 14,
    },
}

_G.GetSpecData = function(specId)
    if specData[specId] then
        return specData[specId]
    else
        return nil
    end
end

_G.GetSpecName = function(specId, locale)
    locale = locale or GetLocale()
    if specData[specId] then
        return specData[specId]["name"][locale] or specData[specId]["name"]["enUS"]
    else
        return _G.UNKNOWN
    end
end

_G.GetSpecRole = function(specId)
    if specData[specId] then
        return specData[specId]["role"]
    else
        return "DAMAGER"
    end
end

_G.GetSpecIcon = function(specId)
    if specData[specId] then
        return specData[specId]["icon"]
    else
        return 134400 -- Default icon (question mark)
    end
end

_G.GetSpecClassID = function(specId)
    if specData[specId] then
        return specData[specId]["classId"]
    else
        return 0 -- Default class ID for unknown specs
    end
end

_G.GetSpecsForClassID = function(classId)
    local specs = {}
    for specId, data in pairs(specData) do
        if data["classId"] == classId then
            table.insert(specs, specId)
        end
    end
    table.sort(specs)
    return specs
end