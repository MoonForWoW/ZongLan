if ZL.IsBlackListPlayer then return end
local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L
local GetClassColor = ns.GetClassColor

local RR = ns.RR
local NN = ns.NN
local RN = ns.RN
local Size = ns.Size
local RGB = ns.RGB
local RGB_16 = ns.RGB_16
local GetClassRGB = ns.GetClassRGB
local SetClassCFF = ns.SetClassCFF
local GetText_T = ns.GetText_T
local AddTexture = ns.AddTexture
local GetItemID = ns.GetItemID
local Round = ns.Round

local pt = print

local player = ZL.playerName
local realmID = GetRealmID()

local FBCD = "RaidCD"
local MONEY = "MONEY"
local dbNames = { AddonName, "ZongLanDB" }

ZL.RoleOverviewOtherEquipSlots = {
    { id = "head", name = INVTYPE_HEAD, slots = { { id = "1", name = "HeadSlot" } } },
    { id = "neck", name = INVTYPE_NECK, slots = { { id = "2", name = "NeckSlot" } } },
    { id = "shoulder", name = INVTYPE_SHOULDER, slots = { { id = "3", name = "ShoulderSlot" } } },
    { id = "back", name = INVTYPE_CLOAK, slots = { { id = "15", name = "BackSlot" } } },
    { id = "chest", name = INVTYPE_CHEST, slots = { { id = "5", name = "ChestSlot" } } },
    { id = "wrist", name = INVTYPE_WRIST, slots = { { id = "9", name = "WristSlot" } } },
    { id = "hands", name = INVTYPE_HAND, slots = { { id = "10", name = "HandsSlot" } } },
    { id = "waist", name = INVTYPE_WAIST, slots = { { id = "6", name = "WaistSlot" } } },
    { id = "legs", name = INVTYPE_LEGS, slots = { { id = "7", name = "LegsSlot" } } },
    { id = "feet", name = INVTYPE_FEET, slots = { { id = "8", name = "FeetSlot" } } },
    {
        id = "finger",
        name = INVTYPE_FINGER,
        slots = {
            { id = "11", name = "Finger0Slot" },
            { id = "12", name = "Finger1Slot" },
        },
    },
}

ZL.RoleOverviewOtherEquipInfo = {
    name = L["装备"],
    color = "C084FC",
    type = "equip",
    id = "otherEquips",
    tex = select(2, GetInventorySlotInfo("ChestSlot")),
    width = 55,
}

ZL.RoleOverviewCustomItemsInfo = {
    name = L["物品"],
    color = "FFFF00",
    type = "items",
    id = "customItems",
    tex = 134842,
    minWidth = 55,
    width = 55,
}

ZL.Init(function()
    ZongLan[FBCD] = ZongLan[FBCD] or {}
    ZongLan[FBCD][realmID] = ZongLan[FBCD][realmID] or {}

    ZongLan[MONEY] = ZongLan[MONEY] or {}
    ZongLan[MONEY][realmID] = ZongLan[MONEY][realmID] or {}
    ZongLan[MONEY][realmID][player] = ZongLan[MONEY][realmID][player] or {}

    ZongLan.roleOverviewNote = ZongLan.roleOverviewNote or {}
    ZongLan.roleOverviewNote[realmID] = ZongLan.roleOverviewNote[realmID] or {}

    -- 选择初始化
    if ZL.IsTBC then
        ZL.Once("FBCDchoiceDefault", 260213, function()
            ZongLan.FBCDchoice = nil
            ZongLan.MONEYchoice = nil
        end)
    end
    if ZL.IsRetail then
        ZL.Once("FBCDchoiceDefault", 260425, function()
            ZongLan.FBCDchoice = nil
            ZongLan.MONEYchoice = nil
        end)
    end
    if not ZongLan.FBCDchoice then
        ZongLan.FBCDchoice = {}
        if ZL.IsVanilla then
            ZongLan.FBCDchoice["NAXX"] = 1
            ZongLan.FBCDchoice["TAQ"] = 1
            ZongLan.FBCDchoice["BWL"] = 1
            ZongLan.FBCDchoice["OL"] = 1
            ZongLan.FBCDchoice["MC"] = 1
            ZongLan.FBCDchoice["AQL"] = 1
            ZongLan.FBCDchoice["ZUG"] = 1
            ZongLan.FBCDchoice["BWLsod"] = 1
            ZongLan.FBCDchoice["ZUGsod"] = 1
            ZongLan.FBCDchoice["TCV"] = 1
            ZongLan.FBCDchoice["MCsod"] = 1
            ZongLan.FBCDchoice["OLsod"] = 1
            ZongLan.FBCDchoice["SC"] = 1
            ZongLan.FBCDchoice["TTS"] = 1
            ZongLan.FBCDchoice["professionCD"] = 1
        elseif ZL.IsTBC then
            ZongLan.FBCDchoice["TK"] = 1
            ZongLan.FBCDchoice["SSC"] = 1
            ZongLan.FBCDchoice["GL"] = 1
            ZongLan.FBCDchoice["ML"] = 1
            ZongLan.FBCDchoice["KZ"] = 1
        elseif ZL.IsWLK_80 then
            ZongLan.FBCDchoice["25RS"] = 1
            ZongLan.FBCDchoice["10RS"] = 1
            ZongLan.FBCDchoice["25ICC"] = 1
            ZongLan.FBCDchoice["10ICC"] = 1
            ZongLan.FBCDchoice["25VOA"] = 1
            ZongLan.FBCDchoice["10VOA"] = 1
            ZongLan.FBCDchoice["gamma"] = 1
            ZongLan.FBCDchoice["heroe"] = 1
            ZongLan.FBCDchoice["week1"] = 1
            ZongLan.FBCDchoice["faction1156"] = 1
        elseif ZL.IsTitan then
            ZongLan.FBCDchoice["SWtitan"] = 1
            ZongLan.FBCDchoice["ZAtitan"] = 1
            ZongLan.FBCDchoice.TOCtitan = 1
            ZongLan.FBCDchoice.ZUGtitan = 1
            ZongLan.FBCDchoice.NAXXtitan = 1
            ZongLan.FBCDchoice.OStitan = 0
            ZongLan.FBCDchoice.EOEtitan = 0
            ZongLan.FBCDchoice.SSCtitan = 0
            ZongLan.FBCDchoice.TKtitan = 0
            ZongLan.FBCDchoice.Doomwalker = 0
            ZongLan.FBCDchoice.DoomLordKazzak = 0
            ZongLan.FBCDchoice["MCtitan"] = 1
            ZongLan.FBCDchoice["VOAtitan"] = 1
            ZongLan.FBCDchoice["gamma"] = 1
            ZongLan.FBCDchoice["heroe"] = 1
            ZongLan.FBCDchoice["week1"] = 1
            ZongLan.FBCDchoice["week2"] = 1
            ZongLan.FBCDchoice["dungeonMoney"] = 1
            ZongLan.FBCDchoice["holiday"] = 1
            ZongLan.FBCDchoice["professionCD"] = 1
            ZongLan.FBCDchoice["faction" .. "270"] = 1
            ZongLan.FBCDchoice["faction" .. "749"] = 1
        elseif ZL.IsCTM then
            ZongLan.FBCDchoice["DS"] = 1
            ZongLan.FBCDchoice["FL"] = 1
            ZongLan.FBCDchoice["BOT"] = 1
            ZongLan.FBCDchoice["BWD"] = 1
            ZongLan.FBCDchoice["TOF"] = 1
            ZongLan.FBCDchoice["25BH"] = 1
            ZongLan.FBCDchoice["10BH"] = 1
            ZongLan.FBCDchoice["faction1204"] = 1
            ZongLan.FBCDchoice["faction1171"] = 1
        elseif ZL.IsMOP then
            ZongLan.FBCDchoice["SOO"] = 1
            ZongLan.FBCDchoice["TOT"] = 0
            ZongLan.FBCDchoice["worldBoss6"] = 1
            ZongLan.FBCDchoice["worldBoss5"] = 1
            ZongLan.FBCDchoice["worldBoss4"] = 0
            ZongLan.FBCDchoice["worldBoss3"] = 0
            ZongLan.FBCDchoice["worldBoss2"] = 0
            ZongLan.FBCDchoice["worldBoss1"] = 0
            ZongLan.FBCDchoice["chengpi"] = 1
            ZongLan.FBCDchoice["holiday"] = 1
            ZongLan.FBCDchoice["professionCD"] = 1
            ZongLan.FBCDchoice["faction" .. "1359"] = 1 -- 黑王子
            ZongLan.FBCDchoice["faction" .. "1492"] = 1 -- 皇帝少昊
            ZongLan.FBCDchoice["faction" .. "1435"] = 0
            ZongLan.FBCDchoice["faction" .. "1387"] = 0
            ZongLan.FBCDchoice["faction" .. "1388"] = 0
        elseif ZL.IsRetail then
        end
    end
    if not ZongLan.MONEYchoice then
        ZongLan.MONEYchoice = {}
        if ZL.IsVanilla then
            ZongLan.MONEYchoice = {
                [22726] = 1,
                [226404] = 1,
                [221262] = 1,
                [221365] = 1,
                ["money"] = 1,
            }
        elseif ZL.IsTBC then
            ZongLan.MONEYchoice[29434] = 1
            ZongLan.MONEYchoice[1900] = 1
            ZongLan.MONEYchoice[1901] = 1
            ZongLan.MONEYchoice["money"] = 1
        elseif ZL.IsWLK_80 then
            ZongLan.MONEYchoice = {
                -- [396] = 1,
                -- [395] = 1,
                [50274] = 1, -- 橙片
                [341] = 1,
                [301] = 1,
                [221] = 1,
                [102] = 1,
                [101] = 1,
                [2711] = 1, -- 天灾石
                [2589] = 1, -- 赛德精华
                ["money"] = 1,
            }
        elseif ZL.IsTitan then
            ZongLan.MONEYchoice[3403] = 1
            ZongLan.MONEYchoice[3406] = 1
            ZongLan.MONEYchoice[1901] = 1
            ZongLan.MONEYchoice["items"] = 1
            ZongLan.MONEYchoice["items_updateItem"] = 1
            ZongLan.MONEYchoice["money"] = 1
        elseif ZL.IsCTM then
            ZongLan.MONEYchoice = {
                [77952] = 1, -- 橙片
                [396] = 1,
                [395] = 1,
                [3281] = 1,
                [3148] = 1,
                [1901] = 1,
                ["money"] = 1,
            }
        elseif ZL.IsMOP then
            ZongLan.MONEYchoice[396] = 1
            ZongLan.MONEYchoice[395] = 1
            ZongLan.MONEYchoice[3416] = 1
            ZongLan.MONEYchoice[776] = 1
            ZongLan.MONEYchoice[738] = 1
            ZongLan.MONEYchoice["money"] = 1
        elseif ZL.IsRetail then
            ZongLan.MONEYchoice[3383] = 1
            ZongLan.MONEYchoice[3341] = 1
            ZongLan.MONEYchoice[3343] = 1
            ZongLan.MONEYchoice[3345] = 1
            ZongLan.MONEYchoice[3347] = 1
            ZongLan.MONEYchoice["money"] = 1
        end
    end
    if not ZongLan.SKILLchoice then
        ZongLan.SKILLchoice = {}
        ZongLan.SKILLchoice[0] = true
    end

    -- 更新
    do
        if ZL.IsVanilla then
            ZL.Once("ro", 250602, function()
                ZongLan.MONEYchoice[22726] = 1
            end)
            ZL.Once("FBCDchoice", 260623, function()
                ZongLan.FBCDchoice["professionCD"] = 1
            end)
        elseif ZL.IsTBC then
            ZL.Once("FBCDchoice", 260518, function()
                ZongLan.FBCDchoice["TK"] = 1
                ZongLan.FBCDchoice["SSC"] = 1
            end)
            ZL.Once("MONEYchoice", 260508, function()
                ZongLan.MONEYchoice[29434] = 1
                ZongLan.MONEYchoice[1900] = 1
                ZongLan.MONEYchoice[1901] = 1
            end)
        elseif ZL.IsWLK_80 then
            ZL.Once("FBCDchoice", 250717, function()
                ZongLan.FBCDchoice["25RS"] = 1
                ZongLan.FBCDchoice["10RS"] = 1
                ZongLan.FBCDchoice["25TOC"] = nil
                ZongLan.FBCDchoice["10TOC"] = nil
            end)
            ZL.Once("FBCDchoice", 250626, function()
                if ZongLan.MONEYchoice[45039] == 1 then
                    ZongLan.MONEYchoice[45038] = 1
                end
            end)
            ZL.Once("FBCDchoice", 250610, function()
                ZongLan.FBCDchoice["faction1156"] = 1
            end)
            ZL.Once("FBCDchoice", 250512, function()
                ZongLan.FBCDchoice["25ICC"] = 1
                ZongLan.FBCDchoice["10ICC"] = 1
                ZongLan.FBCDchoice["25OL"] = nil
                ZongLan.FBCDchoice["10OL"] = nil
                ZongLan.FBCDchoice["25ULD"] = nil
                ZongLan.FBCDchoice["10ULD"] = nil
                ZongLan.FBCDchoice["25NAXX"] = nil
                ZongLan.FBCDchoice["10NAXX"] = nil
                ZongLan.FBCDchoice["25EOE"] = nil
                ZongLan.FBCDchoice["10EOE"] = nil
                ZongLan.FBCDchoice["25OS"] = nil
                ZongLan.FBCDchoice["10OS"] = nil

                ZongLan.MONEYchoice[341] = 1
                ZongLan.MONEYchoice[301] = 1
                ZongLan.MONEYchoice[2711] = 1
                ZongLan.MONEYchoice[2589] = 1
            end)
            ZL.Once("ro", 250602, function()
                ZongLan.MONEYchoice[50274] = 1
            end)
        elseif ZL.IsTitan then
            ZL.Once("FBCDchoice", 260611, function()
                ZongLan.FBCDchoice.week2 = 1
            end)
            ZL.Once("FBCDchoice", 260623, function()
                ZongLan.FBCDchoice["professionCD"] = 1
            end)
            ZL.Once("FBCDchoice", 260801, function()
                ZongLan.FBCDchoice["SWtitan"] = 1
                ZongLan.FBCDchoice["ZAtitan"] = 1
            end)
        elseif ZL.IsCTM then
        elseif ZL.IsMOP then
            ZL.Once("FBCDchoice", 260802, function()
                ZongLan.FBCDchoice["SOO"] = 1
                ZongLan.FBCDchoice["worldBoss6"] = 1
                ZongLan.FBCDchoice["worldBoss5"] = 1
                ZongLan.FBCDchoice["worldBoss4"] = 0
                ZongLan.FBCDchoice["worldBoss3"] = 0
                ZongLan.FBCDchoice["TES"] = 0
                ZongLan.FBCDchoice["HOF"] = 0
                ZongLan.FBCDchoice["MSV"] = 0
            end)
            ZL.Once("MONEYchoice", 260807, function()
                ZongLan.MONEYchoice[3416] = 1
                ZongLan.MONEYchoice[777] = 1
                ZongLan.MONEYchoice[776] = 1
            end)
        elseif ZL.IsRetail then
            ZL.Once("FBCDchoice", 260813, function()
                ZongLan.FBCDchoice.VA_M = 1
                ZongLan.FBCDchoice.VA_H = 1
                ZongLan.FBCDchoice.TG_M = 1
                ZongLan.FBCDchoice.TG_H = 1
                ZongLan.FBCDchoice.VS_M = 0
                ZongLan.FBCDchoice.DR_M = 0
                ZongLan.FBCDchoice.MQD_M = 0
                ZongLan.FBCDchoice.VS_H = 0
                ZongLan.FBCDchoice.DR_H = 0
                ZongLan.FBCDchoice.MQD_H = 0
            end)
        end
        ZL.Once("MONEYchoice", 260731, function()
            ZongLan.MONEYchoice.trinkets = 1
        end)
        ZL.Once("MONEYchoice", 260818, function()
            ZongLan.MONEYchoice.weapons = 1
        end)
    end

    -- 时光服橙武
    local ids, ids_updateItem
    if ZL.IsTitan then
        ids = {
            -- { 10938, 10939, }, -- 测试
            -- { 6948 },          -- 测试
            -- { 42122 },         -- 测试
            -- { 209790 },        -- 测试
            -- { 209630 },        -- 测试
            {
                255103, 260344, 257606, 260346,
                264750, 264779, 264759, 264769,
                264751, 264780, 264760, 264770,
                264752, 264781, 264761, 264771,
                264753, 264782, 264762, 264772,
                264754, 264783, 264763, 264773,
                264755, 264784, 264764, 264774,
                264789, 264785, 264765, 264775,
                264756, 264786, 264766, 264776,
                264757, 264787, 264767, 264777,
                264758, 264788, 264768, 264778,
            },                  -- 橙脖
            { 263264, 17203, }, -- [萨弗隆铁锭][萨弗隆战锤]
            { 257605, },        -- [萨弗拉斯之眼]
            {
                264749, 264936, 264748, 264935, 264746, 264934, 264746, 264933, 264745, 264932,
                264744, 264931, 264743, 264930, 264742, 264929, 264741, 264928, 264731, 264927,
                259908, 264926,
            },                                                                                 -- 橙锤
            {
                265522, 265521, 265520, 265519, 265518, 265517, 265516, 265515, 265514, 19019, -- 风剑
                19018,                                                                         -- [风吻之刃]
            },
            {
                265570, 265569, 265568, 265567, 265566, 265565, 265564, 265563, 22632, -- 橙杖
                265841,                                                                -- 片
            },
            {
                17142, 269677, 269675, 269672, 269679, 269676, 269680, 269674, -- 橙匕
                272955,                                                        -- [艾瑞达之心]
            },
            { 34334, },                                                        -- 橙弓
        }
        ids_updateItem = {
            -- 10938, 10939, 29223, 264272, 2131, -- 测试
            265340, 265524, 267339, 269664, -- 橙脖
            265335, 265523, 267338, 269667, -- 橙锤
            265526, 267335, 269669,         -- 风剑
            267340, 269665,                 -- 橙杖
            269670,                         -- 橙匕
        }
    end

    -- 基础数据初始化
    do
        ZL.factionTbl = {}
        if ZL.IsVanilla_Sod then
            ZL.FBCDall_table = {
                { name = "BWLsod", color = "00BFFF", fbId = 469, type = "fb" },
                { name = "MCsod", color = "00BFFF", fbId = 409, type = "fb" },
                { name = "ZUGsod", color = "00BFFF", fbId = 309, type = "fb" },
                { name = "TCV", name2 = L["风王子"], color = "00BFFF", fbId = 2804, type = "fb" },
                { name = "OLsod", name2 = L["黑龙"], color = "00BFFF", fbId = 249, type = "fb" },
                { name = "SC", name2 = L["蓝龙"], color = "00BFFF", fbId = 2791, type = "fb" },
                { name = "TTS", name2 = L["卡扎克"], color = "00BFFF", fbId = 2789, type = "fb" },
                { name = "Temple", color = "00BFFF", fbId = 109, type = "fb" },
                { name = "Gno", color = "00BFFF", fbId = 90, type = "fb" },
                { name = "BD", color = "00BFFF", fbId = 48, type = "fb" },
                -- 任务
                -- { name = "huiguweek", name2 = L["灰谷日常"], color = "FF8C00", type = "quest" },
                -- 专业
                { name = "alchemy", name2 = L["炼金转化"], color = "ADFF2F", type = "profession" },
                { name = "leatherworking", name2 = L["制皮筛盐"], color = "ADFF2F", type = "profession" },
                { name = "tailor", name2 = L["裁缝洗布"], color = "ADFF2F", type = "profession" },
            }

            ZL.MONEYall_table = {
                { name = L["双倍经验"], color = "99ff99", type = "xp", id = "xp", tex = 1080931, width = 70 }, -- 双倍经验
                { name = L["褪色的安德麦雷亚尔"], color = "FF6600", type = "item", id = 226404, tex = 133799, width = 70 }, -- 荒野祭品
                { name = L["荒野祭品"], color = "98FB98", id = 221262, type = "item", tex = 132119, width = 70 }, -- 荒野祭品
                { name = L["白银戮币"], color = "E6E8FA", id = 221365, type = "item", id_gold = 221366, id_copper = 221364, tex = 237282, width = 70 }, -- 白银戮币
                { name = L["金币"], color = "FFD700", type = "money", id = "money", tex = 237618, width = 80 }, -- 金币
            }
        elseif ZL.IsVanilla_60 then
            ZL.FBCDall_table = {
                { name = "NAXX", name2 = L["纳克萨玛斯"], color = "00BFFF", fbId = 533, num = 40, type = "fb" },
                { name = "TAQ", name2 = L["安其拉"], color = "00BFFF", fbId = 531, num = 40, type = "fb" },
                { name = "AQL", name2 = L["废墟"], color = "00BFFF", fbId = 509, num = 20, type = "fb" },
                { name = "ZUG", name2 = L["祖格"], color = "00BFFF", fbId = 309, num = 20, type = "fb" },
                { name = "BWL", name2 = L["黑翼"], color = "00BFFF", fbId = 469, num = 40, type = "fb" },
                { name = "OL", name2 = L["黑龙"], color = "00BFFF", fbId = 249, num = 40, type = "fb" },
                { name = "MC", name2 = L["熔火之心"], color = "00BFFF", fbId = 409, num = 40, type = "fb" },
                -- 专业
                { name = "professionCD", name2 = L["专业技能CD"], color = "ADFF2F", type = "profession" },
                { name = "ignore_alchemy", name2 = L["忽略炼金转化（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_leatherworking", name2 = L["忽略制皮筛盐（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_tailor", name2 = L["忽略裁缝洗布（需重载）"], color = "ADFF2F", type = "profession" },
            }
            ZL.skillCount = 4
            -- 声望
            ZL.factionTbl = { 910, 609, 270, 749, 529, 59, 576, }
            for _, id in ipairs(ZL.factionTbl) do
                tinsert(ZL.FBCDall_table, { name = "faction" .. id, name2 = GetFactionInfoByID(id), id = id, color = "FFFF00", type = "faction" })
            end

            ZL.MONEYall_table = {
                { name = L["双倍经验"], color = "99ff99", type = "xp", id = "xp", tex = 1080931, width = 70 }, -- 双倍经验
                { name = L["埃提耶什的碎片"], color = "ff8000", type = "item", id = 22726, quest = 9250, tex = 134888, width = 70 }, -- 橙片
                { name = L["金币"], color = "FFD700", type = "money", id = "money", tex = 237618, width = 80 }, -- 金币
            }
        elseif ZL.IsTBC then
            ZL.FBCDall_table = {
                { name = "SW", name2 = L["太阳井"], color = "00BFFF", fbId = 580, num = 25, type = "fb" },
                { name = "BT", name2 = L["黑庙"], color = "00BFFF", fbId = 564, num = 25, type = "fb" },
                { name = "HS", name2 = L["海山"], color = "00BFFF", fbId = 534, num = 25, type = "fb" },
                { name = "ZA", name2 = L["祖阿曼"], color = "00BFFF", fbId = 568, num = 10, type = "fb" },
                { name = "TK", name2 = L["风暴"], color = "00BFFF", fbId = 550, num = 25, type = "fb" },
                { name = "SSC", name2 = L["毒蛇"], color = "00BFFF", fbId = 548, num = 25, type = "fb" },
                { name = "GL", name2 = L["格鲁尔"], color = "00BFFF", fbId = 565, num = 25, type = "fb" },
                { name = "ML", name2 = L["玛胖"], color = "00BFFF", fbId = 544, num = 25, type = "fb" },
                { name = "KZ", name2 = L["卡拉赞"], color = "00BFFF", fbId = 532, num = 10, type = "fb" },
                -- 日常
                { name = "dayQuestCount", name2 = L["日常"], color = "FF8C00", type = "quest" },
            }
            ZL.FBCount = 9
            ZL.dayQuestCount = 1
            -- 声望
            ZL.factionTbl = {
                1077, -- 破碎残阳
                1012, -- 灰舌死誓者
                990,  -- 流沙之鳞
                967,  -- 紫罗兰之眼

                932,  -- 奥尔多
                934,  -- 占星者

                935,  -- 沙塔尔
                1011, -- 贫民窟
                989,  -- 时光守护者
                942,  -- 塞纳里奥远征队

                1038, -- 奥格瑞拉
                933,  -- 星界财团

                1031, -- 沙塔尔天空卫队
                1015, -- 灵翼之龙

                970,  -- 孢子村
            }
            if ZL.IsAlliance then
                tinsert(ZL.factionTbl, 978) -- 库雷尼
                tinsert(ZL.factionTbl, 946) -- 荣耀堡
            elseif ZL.IsHorde then
                tinsert(ZL.factionTbl, 941) -- 玛格汉
                tinsert(ZL.factionTbl, 947) -- 萨尔玛
            end
            for _, id in ipairs(ZL.factionTbl) do
                tinsert(ZL.FBCDall_table, { name = "faction" .. id, name2 = GetFactionInfoByID(id), id = id, color = "FFFF00", type = "faction" })
            end

            ZL.MONEYall_table = {
                { name = L["双倍经验"], color = "99ff99", type = "xp", id = "xp", tex = 1080931, width = 70 }, -- 双倍经验
                { name = L["公正徽章"], color = "E6E8FA", id = 29434, type = "item", tex = 135884, width = 70 },
                { color = "FFFFFF", id = 1900, width = 70 }, -- JJC
                { color = "FFFFFF", id = 1901, width = 70 }, -- 荣誉
                { name = L["金币"], color = "FFD700", type = "money", id = "money", tex = 237618, width = 80 }, -- 金币
            }
        elseif ZL.IsWLK_80 then
            ZL.FBCDall_table = {
                --WLK
                { name = "25RS", name2 = L["25红玉"], color = "FF4500", fbId = 724, num = 25, type = "fb" },
                { name = "10RS", name2 = L["10红玉"], color = "FF4500", fbId = 724, num = 10, type = "fb" },
                { name = "25ICC", name2 = L["25冰冠"], color = "9370DB", fbId = 631, num = 25, type = "fb" },
                { name = "10ICC", name2 = L["10冰冠"], color = "9370DB", fbId = 631, num = 10, type = "fb" },
                { name = "25TOC", name2 = L["25十字军"], color = "FF69B4", fbId = 649, num = 25, type = "fb" },
                { name = "10TOC", name2 = L["10十字军"], color = "FF69B4", fbId = 649, num = 10, type = "fb" },
                { name = "25OL", name2 = L["25黑龙"], color = "FFA500", fbId = 249, num = 25, type = "fb" },
                { name = "10OL", name2 = L["10黑龙"], color = "FFA500", fbId = 249, num = 10, type = "fb" },
                { name = "25ULD", name2 = L["25奥杜尔"], color = "00BFFF", fbId = 603, num = 25, type = "fb" },
                { name = "10ULD", name2 = L["10奥杜尔"], color = "00BFFF", fbId = 603, num = 10, type = "fb" },
                { name = "25NAXX", name2 = L["25纳克"], color = "32CD32", fbId = 533, num = 25, type = "fb" },
                { name = "10NAXX", name2 = L["10纳克"], color = "32CD32", fbId = 533, num = 10, type = "fb" },
                { name = "25EOE", name2 = L["25蓝龙"], color = "1E90FF", fbId = 616, num = 25, type = "fb" },
                { name = "10EOE", name2 = L["10蓝龙"], color = "1E90FF", fbId = 616, num = 10, type = "fb" },
                { name = "25OS", name2 = L["25黑曜石"], color = "8B4513", fbId = 615, num = 25, type = "fb" },
                { name = "10OS", name2 = L["10黑曜石"], color = "8B4513", fbId = 615, num = 10, type = "fb" },
                { name = "25VOA", name2 = L["25宝库"], color = "FFFF00", fbId = 624, num = 25, type = "fb" },
                { name = "10VOA", name2 = L["10宝库"], color = "FFFF00", fbId = 624, num = 10, type = "fb" },
                --TBC
                { name = "SW", name2 = L["太阳井"], color = "D3D3D3", fbId = 580, num = 25, type = "fb" },
                { name = "BT", name2 = L["黑庙"], color = "D3D3D3", fbId = 564, num = 25, type = "fb" },
                { name = "HS", name2 = L["海山"], color = "D3D3D3", fbId = 534, num = 25, type = "fb" },
                { name = "TK", name2 = L["风暴"], color = "D3D3D3", fbId = 550, num = 25, type = "fb" },
                { name = "SSC", name2 = L["毒蛇"], color = "D3D3D3", fbId = 548, num = 25, type = "fb" },
                { name = "GL", name2 = L["格鲁尔"], color = "D3D3D3", fbId = 565, num = 25, type = "fb" },
                { name = "ML", name2 = L["玛胖"], color = "D3D3D3", fbId = 544, num = 25, type = "fb" },
                { name = "ZA", name2 = L["祖阿曼"], color = "D3D3D3", fbId = 568, num = 10, type = "fb" },
                { name = "KZ", name2 = L["卡拉赞"], color = "D3D3D3", fbId = 532, num = 10, type = "fb" },
                { name = "PT", name2 = L["平台"], color = "D3D3D3", fbId = 585, num = 5, type = "fb" },
                { name = "STK", name2 = L["塞泰克"], color = "D3D3D3", fbId = 556, num = 5, type = "fb" },
                --CLASSIC
                { name = "TAQ", name2 = L["安其拉"], color = "D3D3D3", fbId = 531, num = 40, type = "fb" },
                { name = "AQL", name2 = L["废墟"], color = "D3D3D3", fbId = 509, num = 20, type = "fb" },
                { name = "ZUG", name2 = L["祖格"], color = "D3D3D3", fbId = 309, num = 20, type = "fb" },
                { name = "BWL", name2 = L["黑翼"], color = "D3D3D3", fbId = 469, num = 40, type = "fb" },
                { name = "MC", name2 = L["熔火之心"], color = "D3D3D3", fbId = 409, num = 40, type = "fb" },
                -- 日常
                { name = "week1", name2 = L["周常"], color = "FF8C00", type = "quest" },
                { name = "gamma", name2 = L["泰坦"], color = "FF8C00", type = "quest" },
                { name = "heroe", name2 = L["英雄"], color = "FF8C00", type = "quest" },
                { name = "zhubao", name2 = L["珠宝"], color = "FF8C00", type = "quest" },
                { name = "cooking", name2 = L["烹饪"], color = "FF8C00", type = "quest" },
                { name = "fish", name2 = L["钓鱼"], color = "FF8C00", type = "quest" },
                -- 专业
                { name = "alchemy_yanjiu", name2 = L["炼金研究"], color = "ADFF2F", type = "profession" },
                { name = "alchemy_zhuanhua", name2 = L["炼金转化"], color = "ADFF2F", type = "profession" },
                { name = "inscription_dadiaowen", name2 = L["大雕文"], color = "ADFF2F", type = "profession" },
                { name = "inscription_xiaodiaowen", name2 = L["小雕文"], color = "ADFF2F", type = "profession" },
                { name = "jewelcrafting_bingdonglingzhu", name2 = L["冰冻棱柱"], color = "ADFF2F", type = "profession" },
                { name = "forge_taitanjinggang", name2 = L["泰坦精钢"], color = "ADFF2F", type = "profession" },
                { name = "tailor_fawenbu", name2 = L["法纹布"], color = "ADFF2F", type = "profession" },
                { name = "tailor_wuwenbu", name2 = L["乌纹布"], color = "ADFF2F", type = "profession" },
                { name = "tailor_yueyingbu", name2 = L["月影布"], color = "ADFF2F", type = "profession" },
                { name = "tailor_bingchuanbeibao", name2 = L["冰川背包"], color = "ADFF2F", type = "profession" },
            }
            -- 声望
            ZL.factionTbl = { 1156 }
            for _, id in ipairs(ZL.factionTbl) do
                tinsert(ZL.FBCDall_table, { name = "faction" .. id, name2 = GetFactionInfoByID(id), id = id, color = "FFFF00", type = "faction" })
            end

            ZL.MONEYall_table = {
                { name = L["双倍经验"], color = "99ff99", type = "xp", id = "xp", tex = 1080931, width = 70 }, -- 双倍经验
                { name = L["影霜碎片"], color = "ff8000", type = "item", id = 50274, quest = 24548, tex = 340336, width = 70 }, -- 橙片
                { name = L["瓦兰奈尔碎片"], color = "ff8000", type = "item", id = 45038, quest = 13622, tex = "Interface/Icons/inv_ingot_titansteel_red", width = 70 }, -- 橙片
                { color = "00BFFF", id = 341, width = 70 }, -- 寒冰
                { color = "7B68EE", id = 301, width = 70 }, -- 凯旋
                { color = "FFFF00", id = 221, width = 70 }, -- 征服
                { color = "BA55D3", id = 102, width = 70 }, -- 勇气
                { color = "E6E6FA", id = 101, width = 70 }, -- 英雄
                { color = "00FF00", id = 2711, width = 70 }, -- 天灾石
                { color = "00FFFF", id = 2589, width = 70 }, -- 赛德精华
                { color = "FFFFFF", id = 241, width = 70 }, -- 冠军印章
                { color = "FFFFFF", id = 61, width = 70 }, -- 珠宝日常
                { color = "FFFFFF", id = 81, width = 70 }, -- 烹饪日常
                { color = "FFFFFF", id = 161, width = 70 }, -- 岩石守卫
                { color = "FFFFFF", id = 1900, width = 70 }, -- JJC
                { color = "FFFFFF", id = 1901, width = 70 }, -- 荣誉
                { color = "D3D3D3", id = 42, width = 70 }, -- TBC公正牌子
                { name = L["金币"], color = "FFD700", type = "money", id = "money", tex = 237618, width = 80 }, -- 金币
            }
        elseif ZL.IsTitan then
            ZL.FBCDall_table = {
                { name = "SWtitan", name2 = L["太阳井"], color = "00BFFF", fbId = 580, type = "fb" },
                { name = "ZAtitan", name2 = L["祖阿曼"], color = "00BFFF", fbId = 568, type = "fb" },
                { name = "TOCtitan", name2 = L["十字军"], color = "00BFFF", fbId = 649, type = "fb" },
                { name = "ZUGtitan", name2 = L["祖格"], color = "00BFFF", fbId = 309, type = "fb" },
                { name = "NAXXtitan", name2 = L["纳克萨玛斯"], color = "00BFFF", fbId = 533, type = "fb" },
                { name = "OStitan", name2 = L["黑曜石"], color = "00BFFF", fbId = 615, type = "fb" },
                { name = "EOEtitan", name2 = L["永恒"], color = "00BFFF", fbId = 616, type = "fb" },
                { name = "SSCtitan", name2 = L["毒蛇"], color = "00BFFF", fbId = 548, type = "fb" },
                { name = "TKtitan", name2 = L["风暴"], color = "00BFFF", fbId = 550, type = "fb" },
                { name = "MCtitan", name2 = L["熔火"], color = "00BFFF", fbId = 409, type = "fb" },
                { name = "VOAtitan", name2 = L["宝库"], color = "00BFFF", fbId = 624, type = "fb" },
                { name = "Doomwalker", name2 = L["末日行者"], color = "99ccff", fbId = 119, type = "fb" },
                { name = "DoomLordKazzak", name2 = L["末日领主"], color = "99ccff", fbId = 118, type = "fb" },
                { name = "Lanlongtitan", name2 = L["蓝龙"], color = "99ccff", fbId = 116, type = "fb" },
                { name = "Kazaketitan", name2 = L["卡扎克"], color = "99ccff", fbId = 117, type = "fb" },
                -- 日常
                { name = "week1", name2 = L["周常"], color = "FF8C00", type = "quest" },
                { name = "week2", name2 = L["祖格周常"], color = "FF8C00", type = "quest" },
                { name = "zhubao", name2 = L["珠宝"], color = "FF8C00", type = "quest" },
                { name = "cooking", name2 = L["烹饪"], color = "FF8C00", type = "quest" },
                { name = "fish", name2 = L["钓鱼"], color = "FF8C00", type = "quest" },
                -- { name = "dungeonMoney", name2 = L["随机本金币惩罚"], name3 = L["金币惩罚"], id = 1284288, color = "FF8C00", type = "buff" },
                { name = "holiday", name2 = L["节日本"], color = "FF8C00", type = "quest" },
                { name = "dayQuestCount", name2 = L["日常"], color = "FF8C00", type = "quest" },
                -- 专业
                { name = "professionCD", name2 = L["专业技能CD"], color = "ADFF2F", type = "profession" },
                { name = "ignore_alchemy_yanjiu", name2 = L["忽略炼金研究（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_alchemy_zhuanhua", name2 = L["忽略炼金转化（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_inscription_dadiaowen", name2 = L["忽略大雕文（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_inscription_xiaodiaowen", name2 = L["忽略小雕文（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_jewelcrafting_bingdonglingzhu", name2 = L["忽略冰冻棱柱（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_forge_taitanjinggang", name2 = L["忽略泰坦精钢（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_tailor_bingchuanbeibao", name2 = L["忽略冰川背包（需重载）"], color = "ADFF2F", type = "profession" },
            }
            ZL.FBCount = 15
            ZL.dayQuestCount = 7
            ZL.skillCount = 8
            -- 声望
            ZL.factionTbl = {
                1077, -- 破碎残阳
                270,  -- 赞达拉ZUG
                749,  -- 海达希亚水元素
                1119, -- 霍迪尔
                1098, -- 黑锋骑士团
                1106, -- 银色北伐军
                1090, -- 肯瑞托
                1091, -- 龙眠联军
                1104, -- 狂心氏族
                1105, -- 神谕者
                1073, -- 卡鲁亚克
            }
            for _, id in ipairs(ZL.factionTbl) do
                local name3
                if id == 749 then
                    name3 = L["海达希亚"]
                end
                tinsert(ZL.FBCDall_table, {
                    name = "faction" .. id,
                    name2 = GetFactionInfoByID(id),
                    name3 = name3,
                    id = id,
                    color = "FFFF00",
                    type = "faction"
                })
            end

            ZL.MONEYall_table = {
                { name = L["双倍经验"], color = "99ff99", type = "xp", id = "xp", tex = 1080931, width = 70 }, -- 双倍经验
                {
                    name = L["已有橙武"],
                    color = "ff8000",
                    type = "items",
                    id = "items",
                    ids = ids,
                    tex = 135561,
                    minWidth = 70,
                    width = 70
                },
                {
                    name = L["升级物品"],
                    color = "ff8000",
                    type = "items",
                    id = "items_updateItem",
                    ids = ids_updateItem,
                    tex = 840662,
                    minWidth = 70,
                    width = 70
                },
                { color = "ff9900", id = 3403, width = 100 }, -- 泰坦余烬
                { color = "7B68EE", id = 3406, width = 70 }, -- 泰坦碎片
                { color = "FFFFFF", id = 61, width = 70 }, -- 珠宝日常
                { color = "FFFFFF", id = 81, width = 70 }, -- 烹饪日常
                { color = "FFFFFF", id = 241, width = 70 }, -- 冠军徽记
                { color = "FFFFFF", id = 161, width = 70 }, -- 岩石守卫
                { color = "FFFFFF", id = 1900, width = 70 }, -- JJC
                { color = "FFFFFF", id = 1901, width = 70 }, -- 荣誉
                { name = L["金币"], color = "FFD700", type = "money", id = "money", tex = 237618, width = 80 }, -- 金币
            }
        elseif ZL.IsCTM then
            ZL.FBCDall_table = {
                -- CTM
                { name = "DS", name2 = GetRealZoneText(967), color = "9370DB", fbId = 967, type = "fb" },
                { name = "FL", name2 = GetRealZoneText(720), color = "FF4500", fbId = 720, type = "fb" },
                { name = "BOT", name2 = GetRealZoneText(671), color = "FFFF00", fbId = 671, type = "fb" },
                { name = "BWD", name2 = GetRealZoneText(669), color = "FF1493", fbId = 669, type = "fb" },
                { name = "TOF", name2 = GetRealZoneText(754), color = "87CEFA", fbId = 754, type = "fb" },
                { name = "25BH", name2 = "25" .. GetRealZoneText(757), color = "8B4513", fbId = 757, num = 25, type = "fb" },
                { name = "10BH", name2 = "10" .. GetRealZoneText(757), color = "8B4513", fbId = 757, num = 10, type = "fb" },
                --WLK
                { name = "25RS", name2 = L["25红玉"], color = "FF4500", fbId = 724, num = 25, type = "fb" },
                { name = "10RS", name2 = L["10红玉"], color = "FF4500", fbId = 724, num = 10, type = "fb" },
                { name = "25ICC", name2 = L["25冰冠"], color = "9370DB", fbId = 631, num = 25, type = "fb" },
                { name = "10ICC", name2 = L["10冰冠"], color = "9370DB", fbId = 631, num = 10, type = "fb" },
                { name = "25TOC", name2 = L["25十字军"], color = "FF69B4", fbId = 649, num = 25, type = "fb" },
                { name = "10TOC", name2 = L["10十字军"], color = "FF69B4", fbId = 649, num = 10, type = "fb" },
                { name = "25OL", name2 = L["25黑龙"], color = "FFA500", fbId = 249, num = 25, type = "fb" },
                { name = "10OL", name2 = L["10黑龙"], color = "FFA500", fbId = 249, num = 10, type = "fb" },
                { name = "25ULD", name2 = L["25奥杜尔"], color = "00BFFF", fbId = 603, num = 25, type = "fb" },
                { name = "10ULD", name2 = L["10奥杜尔"], color = "00BFFF", fbId = 603, num = 10, type = "fb" },
                { name = "25NAXX", name2 = L["25纳克"], color = "32CD32", fbId = 533, num = 25, type = "fb" },
                { name = "10NAXX", name2 = L["10纳克"], color = "32CD32", fbId = 533, num = 10, type = "fb" },
                { name = "25EOE", name2 = L["25蓝龙"], color = "1E90FF", fbId = 616, num = 25, type = "fb" },
                { name = "10EOE", name2 = L["10蓝龙"], color = "1E90FF", fbId = 616, num = 10, type = "fb" },
                { name = "25OS", name2 = L["25黑曜石"], color = "8B4513", fbId = 615, num = 25, type = "fb" },
                { name = "10OS", name2 = L["10黑曜石"], color = "8B4513", fbId = 615, num = 10, type = "fb" },
                { name = "25VOA", name2 = L["25宝库"], color = "FFFF00", fbId = 624, num = 25, type = "fb" },
                { name = "10VOA", name2 = L["10宝库"], color = "FFFF00", fbId = 624, num = 10, type = "fb" },
                --TBC
                { name = "SW", name2 = L["太阳井"], color = "D3D3D3", fbId = 580, num = 25, type = "fb" },
                { name = "BT", name2 = L["黑庙"], color = "D3D3D3", fbId = 564, num = 25, type = "fb" },
                { name = "HS", name2 = L["海山"], color = "D3D3D3", fbId = 534, num = 25, type = "fb" },
                { name = "TK", name2 = L["风暴"], color = "D3D3D3", fbId = 550, num = 25, type = "fb" },
                { name = "SSC", name2 = L["毒蛇"], color = "D3D3D3", fbId = 548, num = 25, type = "fb" },
                { name = "GL", name2 = L["格鲁尔"], color = "D3D3D3", fbId = 565, num = 25, type = "fb" },
                { name = "ML", name2 = L["玛胖"], color = "D3D3D3", fbId = 544, num = 25, type = "fb" },
                { name = "ZA", name2 = L["祖阿曼"], color = "D3D3D3", fbId = 568, num = 10, type = "fb" },
                { name = "KZ", name2 = L["卡拉赞"], color = "D3D3D3", fbId = 532, num = 10, type = "fb" },
                { name = "PT", name2 = L["平台"], color = "D3D3D3", fbId = 585, num = 5, type = "fb" },
                { name = "STK", name2 = L["塞泰克"], color = "D3D3D3", fbId = 556, num = 5, type = "fb" },
                --CLASSIC
                { name = "TAQ", name2 = L["安其拉"], color = "D3D3D3", fbId = 531, num = 40, type = "fb" },
                { name = "AQL", name2 = L["废墟"], color = "D3D3D3", fbId = 509, num = 20, type = "fb" },
                { name = "ZUG", name2 = L["祖格"], color = "D3D3D3", fbId = 309, num = 20, type = "fb" },
                { name = "BWL", name2 = L["黑翼"], color = "D3D3D3", fbId = 469, num = 40, type = "fb" },
                { name = "MC", name2 = L["熔火之心"], color = "D3D3D3", fbId = 409, num = 40, type = "fb" },
                -- 日常
                { name = "zhubao", name2 = L["珠宝"], color = "FF8C00", type = "quest" },
                { name = "cooking", name2 = L["烹饪"], color = "FF8C00", type = "quest" },
                { name = "fish", name2 = L["钓鱼"], color = "FF8C00", type = "quest" },
            }
            -- 声望
            ZL.factionTbl = {
                1204, -- 海加尔复仇者
                1171, -- 塞拉赞恩
                1158, -- 海山
                1135, -- 大地之环
                1173, -- 拉穆卡恒
            }
            if ZL.IsAlliance then
                tinsert(ZL.factionTbl, 1177) -- 巴拉丁典狱官
                tinsert(ZL.factionTbl, 1174) -- 蛮锤部族
            elseif ZL.IsHorde then
                tinsert(ZL.factionTbl, 1172) -- 龙吼氏族
                tinsert(ZL.factionTbl, 1178) -- 地狱咆哮近卫军
            end
            for _, id in ipairs(ZL.factionTbl) do
                tinsert(ZL.FBCDall_table, { name = "faction" .. id, name2 = GetFactionInfoByID(id), id = id, color = "FFFF00", type = "faction" })
            end

            ZL.MONEYall_table = {
                { name = L["双倍经验"], color = "99ff99", type = "xp", id = "xp", tex = 1080931, width = 70 }, -- 双倍经验
                { name = L["橙匕碎片"], color = "ff8000", type = "item", id2 = 77951, id = 77952, quest2 = 30107, quest = 30116, tex2 = 134101, tex = 458969, width = 70 }, -- 橙片
                { color = "BA55D3", id = 396, width = 70 }, -- 勇气点数
                { color = "00BFFF", id = 395, width = 70 }, -- 正义点数
                { color = "CC9966", id = 3281, width = 70 }, -- 裂隙石碎片P3
                { color = "CC6633", id = 3148, width = 70 }, -- 裂隙石碎片P2
                { color = "FFFFFF", id = 615, width = 70 }, -- 死亡之翼的堕落精华
                { color = "FFFFFF", id = 614, width = 70 }, -- 黑暗之尘
                { color = "FFFFFF", id = 361, width = 70 }, -- 珠宝日常
                { color = "FFFFFF", id = 81, width = 70 }, -- 烹饪日常
                { color = "FFFFFF", id = 515, width = 70 }, -- 暗月
                { color = "FFFFFF", id = 390, width = 70 }, -- 征服点数
                { color = "FFFFFF", id = 1901, width = 70 }, -- 荣誉点数
                { name = L["金币"], color = "FFD700", type = "money", id = "money", tex = 237618, width = 80 }, -- 金币
            }
        elseif ZL.IsMOP then
            ZL.FBCDall_table = {
                -- MOP
                { name = "SOO", name2 = GetRealZoneText(1136), color = "00ff00", fbId = 1136, type = "fb" },
                { name = "TOT", name2 = GetRealZoneText(1098), color = "00ff00", fbId = 1098, type = "fb" },
                { name = "TES", name2 = GetRealZoneText(996), color = "00ff00", fbId = 996, type = "fb" },
                { name = "HOF", name2 = GetRealZoneText(1009), color = "00ff00", fbId = 1009, type = "fb" },
                { name = "MSV", name2 = GetRealZoneText(1008), color = "00ff00", fbId = 1008, type = "fb" },
                { name = "worldBoss6", name2 = L["野牛人"], color = "99ff99", type = "worldBoss" },
                { name = "worldBoss5", name2 = L["四天神"], color = "99ff99", type = "worldBoss" },
                { name = "worldBoss4", name2 = L["乌达斯塔"], color = "99ff99", type = "worldBoss" },
                { name = "worldBoss3", name2 = L["暴风领主"], color = "99ff99", type = "worldBoss" },
                { name = "worldBoss2", name2 = L["怒之煞"], color = "99ff99", type = "worldBoss" },
                { name = "worldBoss1", name2 = L["炮舰"], color = "99ff99", type = "worldBoss" },
                -- CTM
                { name = "DS", name2 = GetRealZoneText(967), color = "9370DB", fbId = 967, type = "fb" },
                { name = "FL", name2 = GetRealZoneText(720), color = "FF4500", fbId = 720, type = "fb" },
                { name = "BOT", name2 = GetRealZoneText(671), color = "FFFF00", fbId = 671, type = "fb" },
                { name = "BWD", name2 = GetRealZoneText(669), color = "FF1493", fbId = 669, type = "fb" },
                { name = "TOF", name2 = GetRealZoneText(754), color = "87CEFA", fbId = 754, type = "fb" },
                { name = "25BH", name2 = "25" .. GetRealZoneText(757), color = "FFA500", fbId = 757, num = 25, type = "fb" },
                { name = "10BH", name2 = "10" .. GetRealZoneText(757), color = "FFA500", fbId = 757, num = 10, type = "fb" },
                --WLK
                { name = "25RS", name2 = L["25红玉"], color = "FF4500", fbId = 724, num = 25, type = "fb" },
                { name = "10RS", name2 = L["10红玉"], color = "FF4500", fbId = 724, num = 10, type = "fb" },
                { name = "25ICC", name2 = L["25冰冠"], color = "9370DB", fbId = 631, num = 25, type = "fb" },
                { name = "10ICC", name2 = L["10冰冠"], color = "9370DB", fbId = 631, num = 10, type = "fb" },
                { name = "25TOC", name2 = L["25十字军"], color = "FF69B4", fbId = 649, num = 25, type = "fb" },
                { name = "10TOC", name2 = L["10十字军"], color = "FF69B4", fbId = 649, num = 10, type = "fb" },
                { name = "25OL", name2 = L["25黑龙"], color = "FFA500", fbId = 249, num = 25, type = "fb" },
                { name = "10OL", name2 = L["10黑龙"], color = "FFA500", fbId = 249, num = 10, type = "fb" },
                { name = "25ULD", name2 = L["25奥杜尔"], color = "00BFFF", fbId = 603, num = 25, type = "fb" },
                { name = "10ULD", name2 = L["10奥杜尔"], color = "00BFFF", fbId = 603, num = 10, type = "fb" },
                { name = "25NAXX", name2 = L["25纳克"], color = "32CD32", fbId = 533, num = 25, type = "fb" },
                { name = "10NAXX", name2 = L["10纳克"], color = "32CD32", fbId = 533, num = 10, type = "fb" },
                { name = "25EOE", name2 = L["25蓝龙"], color = "1E90FF", fbId = 616, num = 25, type = "fb" },
                { name = "10EOE", name2 = L["10蓝龙"], color = "1E90FF", fbId = 616, num = 10, type = "fb" },
                { name = "25OS", name2 = L["25黑曜石"], color = "8B4513", fbId = 615, num = 25, type = "fb" },
                { name = "10OS", name2 = L["10黑曜石"], color = "8B4513", fbId = 615, num = 10, type = "fb" },
                { name = "25VOA", name2 = L["25宝库"], color = "FFFF00", fbId = 624, num = 25, type = "fb" },
                { name = "10VOA", name2 = L["10宝库"], color = "FFFF00", fbId = 624, num = 10, type = "fb" },
                --TBC
                { name = "SW", name2 = L["太阳井"], color = "D3D3D3", fbId = 580, num = 25, type = "fb" },
                { name = "BT", name2 = L["黑庙"], color = "D3D3D3", fbId = 564, num = 25, type = "fb" },
                { name = "HS", name2 = L["海山"], color = "D3D3D3", fbId = 534, num = 25, type = "fb" },
                { name = "TK", name2 = L["风暴"], color = "D3D3D3", fbId = 550, num = 25, type = "fb" },
                { name = "SSC", name2 = L["毒蛇"], color = "D3D3D3", fbId = 548, num = 25, type = "fb" },
                { name = "GL", name2 = L["格鲁尔"], color = "D3D3D3", fbId = 565, num = 25, type = "fb" },
                { name = "ML", name2 = L["玛胖"], color = "D3D3D3", fbId = 544, num = 25, type = "fb" },
                { name = "ZA", name2 = L["祖阿曼"], color = "D3D3D3", fbId = 568, num = 10, type = "fb" },
                { name = "KZ", name2 = L["卡拉赞"], color = "D3D3D3", fbId = 532, num = 10, type = "fb" },
                { name = "PT", name2 = L["平台"], color = "D3D3D3", fbId = 585, num = 5, type = "fb" },
                { name = "STK", name2 = L["塞泰克"], color = "D3D3D3", fbId = 556, num = 5, type = "fb" },
                --CLASSIC
                { name = "TAQ", name2 = L["安其拉"], color = "D3D3D3", fbId = 531, num = 40, type = "fb" },
                { name = "AQL", name2 = L["废墟"], color = "D3D3D3", fbId = 509, num = 20, type = "fb" },
                { name = "ZUG", name2 = L["祖格"], color = "D3D3D3", fbId = 309, num = 20, type = "fb" },
                { name = "BWL", name2 = L["黑翼"], color = "D3D3D3", fbId = 469, num = 40, type = "fb" },
                { name = "MC", name2 = L["熔火之心"], color = "D3D3D3", fbId = 409, num = 40, type = "fb" },
                -- 日常
                { name = "chengpi", name2 = L["橙披任务进度"], color = "FF8C00", type = "achievement" },
                { name = "shoucai", name2 = L["收菜"], color = "FF8C00", type = "quest" },
                { name = "cooking", name2 = L["烹饪"], color = "FF8C00", type = "quest" },
                { name = "holiday", name2 = L["节日本"], color = "FF8C00", type = "quest" },
                -- 专业
                { name = "professionCD", name2 = L["专业技能CD"], color = "ADFF2F", type = "profession" },
                { name = "ignore_alchemy_huohuagang", name2 = L["忽略炼金转化（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_enchanting_xieshashuijing", name2 = L["忽略邪煞水晶（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_inscription_zhihuijuanzhou", name2 = L["忽略智慧卷轴（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_jewelcrafting_yanjiu", name2 = L["忽略珠宝研究（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_jewelcrafting_shenlongzhixin", name2 = L["忽略神龙之心（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_forge_piligangding", name2 = L["忽略霹雳钢锭（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_leatherworking_hualizhipi", name2 = L["忽略华丽制皮（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_tailoring_diwangsichou", name2 = L["忽略帝王丝绸（需重载）"], color = "ADFF2F", type = "profession" },
                { name = "ignore_engineering_jiade", name2 = L["忽略贾德的特制能量源（需重载）"], color = "ADFF2F", type = "profession" },
            }
            ZL.FBCount = 11
            ZL.dayQuestCount = 4
            ZL.skillCount = 10
            -- 声望
            do
                ZL.factionTbl = {
                    1359, -- 黑王子
                    1492, -- 皇帝少昊
                    1435, -- 影踪突袭营
                    1341, -- 至尊天神
                    1269, -- 金莲教
                    1270, -- 影踪派
                    1337, -- 卡拉克西
                    1271, -- 云端翔龙骑士团
                    1272, -- 阡陌客
                    1302, -- 垂钓翁
                    1345, -- 游学者
                }
                if ZL.IsAlliance then
                    tinsert(ZL.factionTbl, 3, 1376) -- 神盾守备军
                    tinsert(ZL.factionTbl, 3, 1387) -- 肯瑞托远征军
                elseif ZL.IsHorde then
                    tinsert(ZL.factionTbl, 3, 1375) -- 统御先锋军
                    tinsert(ZL.factionTbl, 3, 1388) -- 夺日者先锋军
                end
                for _, id in ipairs(ZL.factionTbl) do
                    tinsert(ZL.FBCDall_table, { name = "faction" .. id, name2 = GetFactionInfoByID(id), id = id, color = "FFFF00", type = "faction" })
                end
            end
            --[[
/dump C_CurrencyInfo.GetCurrencyInfo(396)
/dump C_CurrencyInfo.GetCurrencyInfo(697)
GameTooltip:SetCurrencyByID(697)
]]
            local name = "showCurrencyTop"
            ZongLan.options[name] = ZongLan.options[name] or 1
            ZL.showCurrencyTop = ZongLan.options[name] == 1

            ZL.MONEYall_table = {
                { name = L["双倍经验"], color = "99ff99", type = "xp", id = "xp", tex = 1080931, width = 70 }, -- 双倍经验
                { color = "FFFF00", id = 777, width = 70 }, -- 永恒铸币
                { color = "BA55D3", id = 396, width = ZL.showCurrencyTop and 135 or 70 }, -- 勇气点数
                { color = "00BFFF", id = 395, width = 70 }, -- 正义点数
                { name = L["正义奖章"], color = "FF99FF", id = 256883, type = "item", tex = 237547, width = 70 },
                { name = L["战斗的奖励"], color = "00BFFF", id = 247796, type = "item", tex = 463446, width = 70 },
                { color = "00FFFF", id = 3416, width = 70 }, -- 至尊石聚簇
                { color = "00FFFF", id = 3414, width = 70 }, -- 至尊石碎块
                { color = "00FFFF", id = 3350, width = 70 }, -- 至尊石碎片
                { color = "FFD700", id = 776, width = ZL.showCurrencyTop and 90 or 70 }, -- 战火徽记
                { color = "FFD700", id = 752, width = ZL.showCurrencyTop and 90 or 70 }, -- 魔古命运符文
                { color = "FFD700", id = 697, width = ZL.showCurrencyTop and 90 or 70 }, -- 长者的好运符
                { color = "C0C0C0", id = 738, width = 70 }, -- 次级好运护符
                { color = "FFFFFF", id = 402, width = 70 }, -- 铁掌徽记
                { color = "FFFFFF", id = 515, width = 70 }, -- 暗月
                { color = "FFFFFF", id = 3407, width = 70 }, -- 白金硬币
                { color = "CC9933", id = 390, width = ZL.showCurrencyTop and 135 or 70 }, -- 征服点数
                { color = "FFFFFF", id = 1901, width = 70 }, -- 荣誉点数
                { name = L["金币"], color = "FFD700", type = "money", id = "money", tex = 237618, width = 80 }, -- 金币
            }
        elseif ZL.IsRetail then
            ZL.FBCDall_table = {}
            local hards = {
                { 'M', 16 },
                { 'H', 15 },
                { 'N', 14 },
            }
            for _, p in ipairs({
                {
                    { name = 'VA', id = 3004 },
                    { name = 'TG', id = 2987 },
                },
                {
                    { name = 'Micosis', id = 1592 },
                    { name = 'VS', id = 2912 },
                    { name = 'DR', id = 2939 },
                    { name = 'MQD', id = 2913 }
                },
            }) do
                for _, hard in ipairs(hards) do
                    for i, fbs in ipairs(p) do
                        tinsert(ZL.FBCDall_table, {
                            name = fbs.name .. "_" .. hard[1],
                            name2 = GetRealZoneText(fbs.id),
                            color = "00BFFF",
                            fbId = fbs.id,
                            diff = hard[2],
                            type = "fb"
                        })
                    end
                end
            end

            ZL.FBCount = # ZL.FBCDall_table

            ZL.MONEYall_table = {
                { name = L["金币"], color = "FFD700", type = "money", id = "money", tex = 237618, width = 100 }, -- 金币
            }
            local currencys = {
                3319, -- 暮刃徽记
                3316, -- 虚光泥灰岩
                3373, -- 垂钓者珍珠
                3376, -- 敦敦碎片
                3377, -- 纯粹丰饶之物
                3379, -- 充盈奥能
                3385, -- 辉光尘埃
                3392, -- 苦痛残迹
                3400, -- 纯净虚空样本
                3256, -- 炼金匠人活力药剂
                3257, -- 锻造匠人活力药剂
                3258, -- 附魔匠人活力药剂
                3259, -- 工程匠人活力药剂
                3260, -- 采药匠人活力药剂
                3261, -- 铭文匠人活力药剂
                3262, -- 珠宝匠人活力药剂
                3263, -- 制皮匠人活力药剂
                3264, -- 采矿匠人活力药剂
                3265, -- 剥皮匠人活力药剂
                3266, -- 裁缝匠人活力药剂
                3028, -- 修复的宝箱钥匙
                3310, -- 宝箱钥匙碎片
                3212, -- 光耀星火尘
                3378, -- 曦光魔力涌动
                3383, -- 冒险者曦光纹章
                3341, -- 老兵曦光纹章
                3343, -- 勇士曦光纹章
                3345, -- 英雄曦光纹章
                3347, -- 史诗曦光纹章
            }
            for i, id in ipairs(currencys) do
                tinsert(ZL.MONEYall_table, 1, { color = "ffffff", id = id, width = 80 })
            end
            tinsert(ZL.MONEYall_table, 1,
                { name = L["双倍经验"], color = "99ff99", type = "xp", id = "xp", tex = 1080931, width = 70 } -- 双倍经验
            )
        end

        local trinkets = {
            name = L["饰品"],
            color = "C084FC",
            type = "equip",
            id = "trinkets",
            tex = 136115,
            -- tex = 237274,
            width = 55,
        }
        local weapons = {
            name = L["武器"],
            color = "C084FC",
            type = "equip",
            id = "weapons",
            tex = 132402,
            width = 55,
        }
        tinsert(ZL.MONEYall_table, 2, trinkets)
        tinsert(ZL.MONEYall_table, 2, weapons)

        for i, v in ipairs(ZL.MONEYall_table) do
            if not v.type and type(v.id) == "number" then
                local info = C_CurrencyInfo.GetCurrencyInfo(v.id)
                if info then
                    ZL.MONEYall_table[i].name = info.name
                    ZL.MONEYall_table[i].tex = info.iconFileID
                    ZL.MONEYall_table[i].type = "currency"
                end
            end
        end

        if not ZL.IsRetail then
            local fuc = C_TradeSkillUI.GetTradeSkillDisplayName
            local color = "ADFF2F"
            -- local color = "FF99FF"
            -- local color = "F48CBA"

            ZL.SKILLall_table = {
                { name = "main", id = 0, name2 = L["主专业"], color = color, type = "skill", tex = "", width = 110 }, -- 主专业
                { name = "fish", id = 356, name2 = fuc(356), color = color, type = "skill", tex = 136245, width = 60 }, -- 钓鱼
                { name = "cook", id = 185, name2 = fuc(185), color = color, type = "skill", tex = 133971, width = 60 }, -- 烹饪
                { name = "heal", id = 129, name2 = fuc(129), color = color, type = "skill", tex = 135966, width = 60 }, -- 急救
            }
            if ZL.verOver4 then
                tinsert(ZL.SKILLall_table, 2,
                    { name = "archaeology", id = 794, name2 = fuc(794), color = color, type = "skill", tex = 441139, width = 60 }) -- 考古
            end
        end
    end

    -- 获取副本CD
    do
        local colorplayer = SetClassCFF(player, "player")

        function ZL.UpdateFBCD()
            local time = GetServerTime()
            local cd = {}

            for i = 1, GetNumSavedInstances() do
                local name, lockoutId, resettime, difficultyId, locked,
                extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName,
                numEncounters, encounterProgress, extendDisabled, instanceId =
                    GetSavedInstanceInfo(i)
                if locked then
                    local killInfo = {}
                    local killNum = 0
                    for encounterIndex = 1, numEncounters do
                        local bossName, fileDataID, isKilled = GetSavedInstanceEncounterInfo(i, encounterIndex)
                        tinsert(killInfo, { name = bossName, isKilled = isKilled })
                        if isKilled then
                            killNum = killNum + 1
                        end
                    end
                    local a = {
                        player = player,
                        colorplayer = colorplayer,
                        fbId = instanceId,
                        num = maxPlayers,
                        resettime = resettime,
                        endtime = resettime + time,
                        diff = difficultyId,
                        bossSum = numEncounters,
                        killNum = killNum,
                        killInfo = killInfo,
                    }
                    tinsert(cd, a)
                end
            end
            if ZL.IsTitan then
                for i = 1, GetNumSavedWorldBosses() do
                    local name, bossID, resettime = GetSavedWorldBossInfo(i)
                    if bossID then
                        local a = {
                            player = player,
                            colorplayer = colorplayer,
                            fbId = bossID,
                            num = 0,
                            resettime = resettime,
                            endtime = resettime + time,
                            isWorldBoss = true,
                        }
                        tinsert(cd, a)
                    end
                end
            end
            if next(cd) then
                ZongLan[FBCD][realmID][player] = cd
            else
                ZongLan[FBCD][realmID][player] = {
                    {
                        player = player,
                        colorplayer = colorplayer,
                    }
                }
            end

            -- 检查其他角色cd是否到期
            for _, db in pairs(dbNames) do
                if _G[db] and _G[db][FBCD] then
                    for realmID in pairs(_G[db][FBCD]) do
                        if type(realmID) == "number" and type(_G[db][FBCD][realmID]) == "table" then
                            local playerList = {}
                            for _player in pairs(_G[db][FBCD][realmID]) do
                                tinsert(playerList, _player)
                            end
                            for _, _player in ipairs(playerList) do
                                if _player ~= player then
                                    local yes
                                    local player0, colorplayer0
                                    for i = #_G[db][FBCD][realmID][_player], 1, -1 do
                                        local cd = _G[db][FBCD][realmID][_player][i]
                                        if cd and not player0 and not colorplayer0 then
                                            player0 = cd.player
                                            colorplayer0 = cd.colorplayer
                                        end
                                        if cd and cd.endtime then
                                            if time >= cd.endtime then
                                                tremove(_G[db][FBCD][realmID][_player], i)
                                            elseif time < cd.endtime then
                                                cd.resettime = cd.endtime - time
                                                yes = true
                                            end
                                        end
                                    end
                                    if not yes then
                                        _G[db][FBCD][realmID][_player] = {
                                            {
                                                player = player0,
                                                colorplayer = colorplayer0,
                                            }
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        local cd
        local function RequestRaidInfoWithCD()
            if not cd then
                cd = true
                ZL.After(0.5, function()
                    cd = nil
                    RequestRaidInfo()
                end)
            end
        end
        ZL.Init2(RequestRaidInfoWithCD)
        ZL.RegisterEvent("ENCOUNTER_END", function(self, event, _, _, _, _, success)
            if success == 1 then
                RequestRaidInfoWithCD()
            end
        end)
        ZL.RegisterEvent("CHAT_MSG_SYSTEM", function(self, event, msg)
            if not ZL.IsSecret(msg) and msg == INSTANCE_SAVED then
                RequestRaidInfoWithCD()
            end
        end)

        ZL.Init2(function()
            ZL.After(1, ZL.UpdateFBCD)
        end)
        ZL.RegisterEvent("ENCOUNTER_END", function(self, event, _, _, _, _, success)
            if success == 1 then
                ZL.After(1, ZL.UpdateFBCD)
            end
        end)
        ZL.RegisterEvent("UPDATE_INSTANCE_INFO", function()
            ZL.After(1, ZL.UpdateFBCD)
        end)

        for realmID, players in pairs(ZongLan[MONEY]) do
            for player, v in pairs(players) do
                if not ZongLan[FBCD][realmID][player] then
                    ZongLan[FBCD][realmID][player] = {
                        {
                            player = player,
                            colorplayer = v.colorplayer,
                        }
                    }
                end
            end
        end
    end

    -- 世界BOSS（MOP）
    ZongLan.worldBossCD = ZongLan.worldBossCD or {}
    ZongLan.worldBossCD[realmID] = ZongLan.worldBossCD[realmID] or {}
    ZongLan.worldBossCD[realmID][player] = ZongLan.worldBossCD[realmID][player] or {}
    if ZL.IsMOP then
        local function SaveWorldBoss(bossIndex)
            local resetDay = 2
            if ZL.IsCN() then
                resetDay = 4
            end

            local currentTimestamp = GetServerTime()
            local currentWeekday = date("%w", currentTimestamp)
            local daysToThursday = resetDay - currentWeekday
            local nextThursdayTimestamp

            local today = date("*t", currentTimestamp)
            -- 如果时间小于当天凌晨7点
            if daysToThursday == 0 and today.hour < 7 then
                today.hour = 7
                today.min = 0
                today.sec = 0
                nextThursdayTimestamp = time(today)
            else
                -- 如果已经是周四了，则日期+7
                if daysToThursday <= 0 then
                    daysToThursday = daysToThursday + 7
                end
                nextThursdayTimestamp = currentTimestamp + daysToThursday * 86400

                local nextThursdayDateTable = date("*t", nextThursdayTimestamp)
                nextThursdayDateTable.hour = 7
                nextThursdayDateTable.min = 0
                nextThursdayDateTable.sec = 0
                nextThursdayTimestamp = time(nextThursdayDateTable)
            end
            -- 计算时间差
            local secondsToNextThursday = nextThursdayTimestamp - currentTimestamp -- 距离下周四还有多少秒
            local timestamp = currentTimestamp + secondsToNextThursday             -- 到下周四的实际时间戳

            local colorplayer = SetClassCFF(player, "player")
            ZongLan.worldBossCD[realmID][player]["worldBoss" .. bossIndex] = {
                name = "worldBoss" .. bossIndex,
                player = player,
                colorplayer = colorplayer,
                resettime = secondsToNextThursday,
                endtime = timestamp
            }
        end

        local function GetBossIsKill()
            if InCombatLockdown() then return end
            for bossIndex, questID in ipairs(ZL.worldBossID) do
                if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                    if not ZongLan.worldBossCD[realmID][player]["worldBoss" .. bossIndex] then
                        SaveWorldBoss(bossIndex)
                    end
                else
                    ZongLan.worldBossCD[realmID][player]["worldBoss" .. bossIndex] = nil
                end
            end
        end

        local function UpdateWorldBossEndTime()
            local time = GetServerTime()
            for _, db in pairs(dbNames) do
                if _G[db] and _G[db].worldBossCD then
                    for realmID in pairs(_G[db].worldBossCD) do
                        if type(realmID) == "number" and type(_G[db].worldBossCD[realmID]) == "table" then
                            for player in pairs(_G[db].worldBossCD[realmID]) do
                                local questList = {}
                                for questName in pairs(_G[db].worldBossCD[realmID][player]) do
                                    tinsert(questList, questName)
                                end
                                for _, questName in ipairs(questList) do
                                    local v = _G[db].worldBossCD[realmID][player][questName]
                                    if time < v.endtime then
                                        v.resettime = v.endtime - time
                                    else
                                        _G[db].worldBossCD[realmID][player][questName] = nil
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        ZL.Init2(function()
            UpdateWorldBossEndTime()
        end)
        C_Timer.NewTicker(60, function()
            UpdateWorldBossEndTime()
        end)
        C_Timer.NewTicker(5, function()
            GetBossIsKill()
        end)
    elseif ZL.IsTitan then
        local function GetBossIsKill()
            if InCombatLockdown() then return end
            local level = UnitLevel("player")
            local instanceID = select(8, GetInstanceInfo())
            if level >= ZL.fullLevel and (instanceID == 0 or instanceID == 1 or instanceID == 530) then
                RequestRaidInfo()
            end
        end
        C_Timer.NewTicker(5, function()
            GetBossIsKill()
        end)
    end

    -- 日常任务
    local holidayDungeonIDs = { 286, 285, 287, 288 } -- 火焰节、万圣节、美酒节、情人节
    do
        ZongLan.QuestCD = ZongLan.QuestCD or {}
        ZongLan.QuestCD[realmID] = ZongLan.QuestCD[realmID] or {}
        ZongLan.QuestCD[realmID][player] = ZongLan.QuestCD[realmID][player] or {}

        local function IsLearnSkill(skillID)
            return ZongLan[MONEY][realmID][player].skill[skillID]
        end

        local function GetQuestSkillID(questName)
            return ZL.dayQuests and ZL.dayQuests[questName] and ZL.dayQuests[questName].skillID
        end

        -- 日常
        if ZL.IsVanilla_Sod then
            ZL.dayQuests = {
                huiguweek = { questIDs = { 79090, 79098 }, }, -- 灰谷
            }
        elseif ZL.IsWLK then
            ZL.dayQuests = {
                zhubao = {
                    questIDs = { 12959, 12962, 12961, 12958, 12963, 12960 },
                    skillID = 755,
                },
                cooking = {
                    questIDs = { 13114, 13116, 13113, 13115, 13112, 13102, 13100, 13107, 13101, 13103 },
                    skillID = 185,
                },
                fish = {
                    questIDs = { 13836, 13833, 13834, 13832, 13830 },
                    skillID = 356,
                },
            }
            if ZL.IsWLK_80 then
                ZL.dayQuests.gamma = { questIDs = { 83717, 83713, 78752 } }
                ZL.dayQuests.heroe = { questIDs = { 87379, 83714, 84552, 78753 } }
            end
        elseif ZL.IsCTM then
            ZL.dayQuests = {
                zhubao = {
                    questIDs = { 25156, 25161, 25159, 25158, 25162, 25160, 25154, 25155, 25105, 25157 },
                    skillID = 755,
                },
                cooking = {
                    questIDs = { 29316, 29352, 29314, 29356, 29351, 26190, 26153, 29313, 26183, 29362, 26192, 29358, 26235, 26233, 29333, 29334, 26177, 29318, 29364, 29365, 26234, 26220, 29357, 29363, 26226, 26227, 29332, 29315, 29353, 29355, 29360 },
                    skillID = 185,
                },
                fish = {
                    questIDs = { 26557, 29322, 29354, 29361, 26588, 29317, 26572, 29320, 29345, 29348, 29346, 26543, 29319, 26556, 29349, 26420, 29342, 26536, 29321, 29324, 29344, 29343, 29350, 29347, 29359, 26488, 29323, 29325, 26414, 26442 },
                    skillID = 356,
                },
            }
        elseif ZL.IsMOP then
            ZL.dayQuests = {
                cooking = {
                    questIDs = { 30331, 30328, 30330, 30332, 30329, },
                    skillID = 185,
                },
            }
        end
        local function SaveDayQuest(questName, questID, count)
            local currentTimestamp = GetServerTime()
            local secondsUntilNext7am = ZL.GetNextDayTime()
            local timestamp = currentTimestamp + secondsUntilNext7am

            local colorplayer = SetClassCFF(player, "player")
            ZongLan.QuestCD[realmID][player][questName] = {
                name = questName,
                player = player,
                colorplayer = colorplayer,
                questID = questID,
                resettime = secondsUntilNext7am,
                endtime = timestamp,
                count = count,
            }
        end
        local function UpdateDayQuest(questID)
            if not ZL.dayQuests then return end
            for questName in pairs(ZL.dayQuests) do
                for _, _questID in pairs(ZL.dayQuests[questName].questIDs) do
                    if _questID == questID then
                        SaveDayQuest(questName, questID)
                        return
                    end
                end
            end
        end
        -- 日常数量
        local function UpdateDayQuestCount()
            if not GetDailyQuestsCompleted then return end
            local count = GetDailyQuestsCompleted()
            if count > 0 then
                SaveDayQuest('dayQuestCount', nil, count)
            else
                ZongLan.QuestCD[realmID][player].dayQuestCount = nil
            end
        end

        -- 周常
        if ZL.IsWLK then
            ZL.weekQuests = {
                week1 = {
                    questIDs = { 24579, 24580, 24581, 24582, 24583, 24584, 24585, 24586, 24587, 24588, 24589, 24590,
                        93975, 94577, 94579, 95037, 96312 -- 时光服
                    }
                },
                -- 祖格宝石周常
                week2 = {
                    questIDs = { 98183, }
                },
            }
        end
        local function SaveWeekQuest(questName, questID)
            local currentTimestamp = GetServerTime()
            local secondsToNextThursday = ZL.GetNextWeekTime()         -- 距离下周四还有多少秒
            local timestamp = currentTimestamp + secondsToNextThursday -- 到下周四的实际时间戳

            local colorplayer = SetClassCFF(player, "player")
            ZongLan.QuestCD[realmID][player][questName] = {
                name = questName,
                player = player,
                colorplayer = colorplayer,
                questID = questID,
                resettime = secondsToNextThursday,
                endtime = timestamp
            }
        end
        local function UpdateWeekQuest(questID)
            if not ZL.weekQuests then return end
            for questName in pairs(ZL.weekQuests) do
                for _, _questID in pairs(ZL.weekQuests[questName].questIDs) do
                    if _questID == questID then
                        SaveWeekQuest(questName, questID)
                        return
                    end
                end
            end
        end

        -- MOP收菜
        if ZL.IsMOP then
            -- 开垦：开始计时，收菜显示打勾
            -- 倒计时生效时，无视开垦
            -- 倒计时结束，回到第一步，收菜清除打勾
            ZL.RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", function(self, event, ...)
                local unit, _, spellID = ...
                if unit == "player" and (spellID == 111003 or spellID == 116357 or spellID == 139892) then -- 开垦和万能犁
                    SaveDayQuest("shoucai", 111003)
                end
            end)
        end

        -- 节日本
        local init
        function ZL.InitHoliday()
            if init then return end
            init = true
            ZL.RegisterEvent("LFG_COMPLETION_REWARD", function()
                local dungeonID = select(10, GetInstanceInfo())
                if dungeonID and ZL.ValueInTable(holidayDungeonIDs, dungeonID) then
                    SaveDayQuest("holiday")
                end
            end)
        end

        -- 交任务时触发
        ZL.RegisterEvent("QUEST_TURNED_IN", function(self, event, questID)
            UpdateDayQuest(questID)
            UpdateWeekQuest(questID)
            ZL.After(1, function()
                UpdateDayQuestCount()
            end)
        end)

        -- 检查全部角色的任务重置cd是否到期（日常是第二天凌晨7点）
        local function UpdateQuestEndTime()
            local time = GetServerTime()
            for _, db in pairs(dbNames) do
                if _G[db] and _G[db].QuestCD then
                    for realmID in pairs(_G[db].QuestCD) do
                        if type(realmID) == "number" and type(_G[db].QuestCD[realmID]) == "table" then
                            for player in pairs(_G[db].QuestCD[realmID]) do
                                local questList = {}
                                for questName in pairs(_G[db].QuestCD[realmID][player]) do
                                    tinsert(questList, questName)
                                end
                                for _, questName in ipairs(questList) do
                                    local v = _G[db].QuestCD[realmID][player][questName]
                                    if v.endtime and time < v.endtime then
                                        v.resettime = v.endtime - time
                                    else
                                        local skillID = GetQuestSkillID(questName)
                                        if skillID then
                                            -- 专业任务，加上notFinish标记，用于显示X
                                            _G[db].QuestCD[realmID][player][questName].endtime = nil
                                            _G[db].QuestCD[realmID][player][questName].resettime = nil
                                            _G[db].QuestCD[realmID][player][questName].notFinish = true
                                            -- 但如果自己没学这个专业了，则清空
                                            if ZL.IsMe(realmID, player) and not IsLearnSkill(skillID) then
                                                _G[db].QuestCD[realmID][player][questName] = nil
                                            end
                                        else
                                            _G[db].QuestCD[realmID][player][questName] = nil
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        -- 追溯已完成的任务
        local function CheckQuestsCompleted()
            if ZL.dayQuests then
                for questName, v in pairs(ZL.dayQuests) do
                    if not ZongLan.QuestCD[realmID][player][questName] then
                        local skillID = v.skillID
                        if skillID and IsLearnSkill(skillID) then
                            ZongLan.QuestCD[realmID][player][questName] = {
                                notFinish = true,
                            }
                        end
                    end
                    for _, _questID in pairs(ZL.dayQuests[questName].questIDs) do
                        if C_QuestLog.IsQuestFlaggedCompleted(_questID) then
                            SaveDayQuest(questName, _questID)
                            break
                        end
                    end
                end
            end
            if ZL.weekQuests then
                for questName in pairs(ZL.weekQuests) do
                    for _, _questID in pairs(ZL.weekQuests[questName].questIDs) do
                        if C_QuestLog.IsQuestFlaggedCompleted(_questID) then
                            SaveWeekQuest(questName, _questID)
                            break
                        end
                    end
                end
            end
            UpdateDayQuestCount()
        end

        ZL.Init2(function()
            ZL.After(3, function()
                CheckQuestsCompleted()
                UpdateQuestEndTime()
            end)
        end)
        C_Timer.NewTicker(60, function()
            UpdateQuestEndTime()
        end)
    end

    -- 橙披
    if ZL.IsMOP then
        ZongLan.legendaryCloak = ZongLan.legendaryCloak or {}
        ZongLan.legendaryCloak[realmID] = ZongLan.legendaryCloak[realmID] or {}
        local db = ZongLan.legendaryCloak[realmID]
        local ids = {
            { id = 31488, name = L['正在第1章'] },
            { id = 31454, name = L['正在第1章'] },
            { id = 31482, name = L['已完成第1章'] },
            { id = 32390, name = L['已完成第2章'] },
            { id = 32597, name = L['已完成第3章'] },
            { id = 32861, name = L['已完成第4章'] },
            -- { id = 7536, name = L['已完成第5章'] },
            { id = 33104, name = L['|cff00ff00已完成|r'] },
        }
        local function UpdateLegendaryCloak()
            for i, v in ipairs(ids) do
                if C_QuestLog.IsQuestFlaggedCompleted(v.id) then
                    db[player] = v.name
                end
            end
        end
        ZL.RegisterEvent("QUEST_TURNED_IN", function(self, event, questID)
            ZL.After(.5, function()
                UpdateLegendaryCloak()
            end)
        end)
        ZL.Init2(function()
            ZL.After(3, function()
                UpdateLegendaryCloak()
            end)
        end)
    end

    -- 时光服随机本金币惩罚
    ZongLan.buffCD = ZongLan.buffCD or {}
    ZongLan.buffCD[realmID] = ZongLan.buffCD[realmID] or {}
    ZongLan.buffCD[realmID][player] = ZongLan.buffCD[realmID][player] or {}
    if ZL.IsTitan then
        local buffIDs = { { id = 1284288, type = "HARMFUL" } }

        local function UpdateBuffRecord()
            for i, v in ipairs(buffIDs) do
                local buffID = v.id
                ZongLan.buffCD[realmID][player][buffID] = nil
                for i = 1, 60 do
                    local name, icon, count, dispelType, duration, expirationTime, source,
                    isStealable, nameplateShowPersonal, spellID = UnitAura("player", i, v.type)
                    if not spellID then break end
                    if buffID == spellID then
                        local cooldown = expirationTime - GetTime()
                        local currentTimestamp = GetServerTime()
                        local secondsUntilNext7am = ZL.GetNextDayTime()
                        local nextDayEndTime = currentTimestamp + secondsUntilNext7am
                        ZongLan.buffCD[realmID][player][buffID] = {
                            resettime = cooldown,
                            endtime = cooldown + currentTimestamp,
                            nextDayEndTime = nextDayEndTime,
                        }
                        break
                    end
                end
            end
        end

        function ZL.UpdateBuffCD()
            local time = GetServerTime()
            local buffIDs = {}
            for buffID in pairs(ZongLan.buffCD[realmID][player]) do
                tinsert(buffIDs, buffID)
            end
            for _, buffID in pairs(buffIDs) do
                local v = ZongLan.buffCD[realmID][player][buffID]
                if v and v.endtime then
                    if time >= v.endtime then
                        ZongLan.buffCD[realmID][player][buffID] = nil
                    elseif time < v.endtime then
                        v.resettime = v.endtime - time
                    end
                end
            end
        end

        local function UpdateBuffEndTime()
            local time = GetServerTime()
            for _, db in pairs(dbNames) do
                if _G[db] and _G[db].buffCD then
                    for realmID in pairs(_G[db].buffCD) do
                        if type(realmID) == "number" and type(_G[db].buffCD[realmID]) == "table" then
                            for player in pairs(_G[db].buffCD[realmID]) do
                                local buffIDs = {}
                                for buffID in pairs(_G[db].buffCD[realmID][player]) do
                                    tinsert(buffIDs, buffID)
                                end
                                for _, buffID in pairs(buffIDs) do
                                    local v = _G[db].buffCD[realmID][player][buffID]
                                    if v and v.nextDayEndTime and time > v.nextDayEndTime then
                                        _G[db].buffCD[realmID][player][buffID] = nil
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        ZL.RegisterEvent("UNIT_AURA", function(_, _, unit, info)
            if unit == "player" then
                UpdateBuffRecord()
            end
        end)

        ZL.Init2(function()
            UpdateBuffEndTime()
            ZL.UpdateBuffCD()
            ZL.After(5, UpdateBuffRecord)
        end)

        C_Timer.NewTicker(10, function()
            ZL.UpdateBuffCD()
        end)
    end

    -- 专业技能CD
    if not ZL.IsRetail then
        ZongLan.tradeSkillCooldown = ZongLan.tradeSkillCooldown or {}
        ZongLan.tradeSkillCooldown[realmID] = ZongLan.tradeSkillCooldown[realmID] or {}
        ZongLan.tradeSkillCooldown[realmID][player] = ZongLan.tradeSkillCooldown[realmID][player] or {}

        local tbl = {}
        if ZL.IsVanilla then
            tbl = {
                alchemy = {
                    name = L["炼金转化"],
                    name2 = L["炼金术"],
                    spell = 17187, -- 转化奥金
                    icon = "Interface/Icons/trade_alchemy",
                },
                leatherworking = {
                    name = L["制皮筛盐"],
                    name2 = L["制皮"],
                    spell = 19566, --筛盐
                    icon = "Interface/Icons/trade_leatherworking",
                },
                tailor = {
                    name = L["裁缝洗布"],
                    name2 = L["裁缝"],
                    spell = 18560, --月布
                    icon = "Interface/Icons/trade_tailoring",
                },
            }
        elseif ZL.IsWLK then
            tbl = {
                alchemy_yanjiu = {
                    name = L["炼金研究"],
                    name2 = L["炼金术"],
                    spell = 60893,
                    icon = "Interface/Icons/trade_alchemy",
                },
                alchemy_zhuanhua = {
                    name = L["炼金转化"],
                    name2 = L["炼金术"],
                    spell = 66660,
                    icon = 237235,
                },
                inscription_dadiaowen = {
                    name = L["大雕文"],
                    name2 = L["铭文"],
                    spell = 61177,
                    icon = "Interface/Icons/inv_inscription_tradeskill01",
                },
                inscription_xiaodiaowen = {
                    name = L["小雕文"],
                    name2 = L["铭文"],
                    spell = 61288,
                    icon = 237132,
                },
                jewelcrafting_bingdonglingzhu = {
                    name = L["冰冻棱柱"],
                    name2 = L["珠宝加工"],
                    spell = 62242,
                    icon = "Interface/Icons/inv_misc_gem_01",
                },
                forge_taitanjinggang = {
                    name = L["泰坦精钢"],
                    name2 = L["采矿"],
                    spell = 55208,
                    icon = "Interface/Icons/trade_mining",
                },
                tailor_fawenbu = {
                    name = L["法纹布"],
                    name2 = L["裁缝"],
                    spell = 56003,
                },
                tailor_wuwenbu = {
                    name = L["乌纹布"],
                    name2 = L["裁缝"],
                    spell = 56002,
                },
                tailor_yueyingbu = {
                    name = L["月影布"],
                    name2 = L["裁缝"],
                    spell = 56001,
                },
                tailor_bingchuanbeibao = {
                    name = L["冰川背包"],
                    name2 = L["裁缝"],
                    spell = 56005,
                    icon = 133666,
                },
            }
            if ZongLan.FBCDchoice["ignore_jewelcrafting_yanjiu"] == 1 then
                tbl.jewelcrafting_yanjiu = nil
            end
        elseif ZL.IsMOP then
            tbl = {
                alchemy_huohuagang = {
                    name = L["炼金转化"],
                    name2 = L["炼金术"],
                    spell = 114780,
                    icon = "Interface/Icons/trade_alchemy",
                },
                forge_piligangding = {
                    name = L["霹雳钢锭"],
                    name2 = L["锻造"],
                    spell = 138646,
                    icon = "Interface/Icons/trade_blacksmithing",
                },
                enchanting_xieshashuijing = {
                    name = L["邪煞水晶"],
                    name2 = L["附魔"],
                    spell = 116499,
                    icon = "Interface/Icons/trade_engraving",
                },
                inscription_zhihuijuanzhou = {
                    name = L["智慧卷轴"],
                    name2 = L["铭文"],
                    spell = 112996,
                    icon = "Interface/Icons/inv_inscription_tradeskill01",
                },
                jewelcrafting_yanjiu = {
                    name = L["珠宝研究"],
                    name2 = L["珠宝加工"],
                    spell = 131686,
                    icon = "Interface/Icons/inv_misc_gem_01",
                },
                jewelcrafting_shenlongzhixin = {
                    name = L["神龙之心"],
                    name2 = L["珠宝加工"],
                    spell = 140050,
                    icon = 651736,
                },
                leatherworking_hualizhipi = {
                    name = L["华丽制皮"],
                    name2 = L["制皮"],
                    spell = 140040,
                    icon = "Interface/Icons/trade_leatherworking",
                },
                tailoring_diwangsichou = {
                    name = L["帝王丝绸"],
                    name2 = L["裁缝"],
                    spell = 125557,
                    icon = "Interface/Icons/trade_tailoring",
                },
                engineering_jiade = {
                    name = L["贾德的特制能量源"],
                    name2 = L["工程"],
                    spell = 139176,
                    icon = "Interface/Icons/trade_engineering",
                },
            }
        end
        local names = {}
        for name in pairs(tbl) do
            if ZongLan.FBCDchoice["ignore_" .. name] == 1 then
                names[name] = true
            end
        end
        for name in pairs(names) do
            tbl[name] = nil
        end
        for profession, v in pairs(tbl) do
            if not v.icon then
                v.icon = C_Spell.GetSpellTexture(v.spell)
            end
        end
        ZL.professionCDInfo = tbl

        local function GetCooldown()
            local time = GetServerTime()
            local getTime = GetTime()
            for profession, v in pairs(tbl) do
                local startTime, duration, cooldown
                if ZL.IsRetail then
                    local info = C_Spell.GetSpellCooldown(v.spell)
                    startTime = info.startTime
                    duration = info.duration
                else
                    startTime, duration = GetSpellCooldown(v.spell)
                end
                startTime = startTime > getTime and (startTime - 2 ^ 32 / 1000) or startTime
                cooldown = startTime + duration - getTime
                if cooldown > 0 then
                    if ZL.IsMOP then
                        cooldown = ZL.GetNextDayTime()
                    end
                    ZongLan.tradeSkillCooldown[realmID][player][profession] = {
                        class = select(2, UnitClass("player")),
                        resettime = cooldown,
                        endtime = cooldown + time,
                        ready = nil,
                    }
                end
            end
        end
        local professionCooldownPending
        local delay=1
        local function Go()
            professionCooldownPending = nil
            GetCooldown()
        end
        ZL.RegisterEvent("TRADE_SKILL_UPDATE", function()
            if professionCooldownPending then return end
            professionCooldownPending = true
            ZL.After(delay, Go)
        end)
        ZL.RegisterEvent("SPELL_UPDATE_COOLDOWN", function(self, event)
            if InCombatLockdown() then return end
            if professionCooldownPending then return end
            professionCooldownPending = true
            ZL.After(delay, Go)
        end)

        -- 检查其他角色cd是否到期
        local delay = 3
        local function UpdateProfessionCD()
            local time = GetServerTime()
            for _, db in pairs(dbNames) do
                if _G[db] and _G[db].tradeSkillCooldown then
                    for realmID in pairs(_G[db].tradeSkillCooldown) do
                        if type(realmID) == "number" and type(_G[db].tradeSkillCooldown[realmID]) == "table" then
                            for player in pairs(_G[db].tradeSkillCooldown[realmID]) do
                                for profession, v in pairs(_G[db].tradeSkillCooldown[realmID][player]) do
                                    if v.endtime then
                                        if time >= v.endtime then
                                            v.resettime = nil
                                            v.endtime = nil
                                            v.ready = true
                                            -- 限定只提醒当前账号是因为没办法删掉其他子账号的endtime，其他子账号会重复提醒
                                            if db == "ZongLan" and ZongLan.FBCDchoice[profession] and ZongLan.FBCDchoice[profession] == 1 then
                                                local color
                                                if v.class then
                                                    color = select(4, GetClassColor(v.class))
                                                end
                                                local name = ZL.IsMe(realmID, player) and L["我"] or player
                                                local colorName = color and "|c" .. color .. name .. "|r" or name
                                                local msg = ZL.STC_g1(format(L["%s：%s已就绪！"], colorName, tbl[profession].name))
                                                ZL.After(delay, function()
                                                    ZL.SendSystemMessage(msg)
                                                    if ZL["sound_" .. profession .. "Ready" .. ZongLan.options.Sound] then
                                                        ZL.PlaySound(profession .. "Ready")
                                                    else
                                                        PlaySoundFile(ns.Interface .. "Media\\sound\\other\\done.mp3", "Master")
                                                    end
                                                end)
                                                delay = delay + 3
                                            end
                                        elseif time < v.endtime then
                                            v.resettime = v.endtime - time
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- 检查专业技能是否忘记了，如果忘记了，则删掉对应的专业CD记录
        do
            local function CheckSkillIsForget()
                for profession, v in pairs(tbl) do
                    local isLearned
                    for i = 1, GetNumSkillLines() do
                        if GetSkillLineInfo(i) == v.name2 then
                            isLearned = true
                            break
                        end
                    end
                    if not isLearned then
                        ZongLan.tradeSkillCooldown[realmID][player][profession] = nil
                    end
                end
            end
            ZL.RegisterEvent("SKILL_LINES_CHANGED", function()
                ZL.After(2, function()
                    CheckSkillIsForget()
                end)
            end)
        end

        ZL.Init2(function()
            ZL.After(2, function()
                GetCooldown()
                UpdateProfessionCD()
            end)
        end)
        C_Timer.NewTicker(19, function()
            UpdateProfessionCD()
        end)
    end

    -- 专业技能点数
    if not ZL.IsRetail then
        local skillInfo = {
            [L["锻造"]] = { id = 164, icon = 136241, isMain = true },
            [L["工程学"]] = { id = 202, icon = 136243, isMain = true },
            [L["炼金术"]] = { id = 171, icon = 136240, isMain = true },
            [L["制皮"]] = { id = 165, icon = 133611, isMain = true },
            [L["裁缝"]] = { id = 197, icon = 136249, isMain = true },
            [L["附魔"]] = { id = 333, icon = 136244, isMain = true },
            [L["采矿"]] = { id = 186, icon = 136248, isMain = true },
            [L["草药学"]] = { id = 182, icon = 136065, isMain = true },
            [L["剥皮"]] = { id = 393, icon = 134366, isMain = true },
            [L["铭文"]] = { id = 773, icon = 237171, isMain = true },
            [L["珠宝加工"]] = { id = 755, icon = 134071, isMain = true },
            [L["考古学"]] = { id = 794, icon = 441139, isMain = nil },
            [L["钓鱼"]] = { id = 356, icon = 136245, isMain = nil },
            [L["烹饪"]] = { id = 185, icon = 133971, isMain = nil },
            [L["急救"]] = { id = 129, icon = 135966, isMain = nil },
        }
        local function UpdatetradeSkill()
            if SkillFrame and SkillFrame:IsVisible() then return end
            if WardrobeFrame and WardrobeFrame:IsVisible() then return end
            ExpandSkillHeader(0)
            local tbl = {}
            for i = 1, GetNumSkillLines() do
                local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier,
                skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType,
                skillDescription = GetSkillLineInfo(i)
                if not header and skillInfo[skillName] then
                    local id = skillInfo[skillName].id
                    tbl[id] = {
                        level = skillRank,
                        icon = skillInfo[skillName].icon,
                        isMain = skillInfo[skillName].isMain,
                    }
                end
            end
            ZongLan[MONEY][realmID][player].skill = tbl
        end

        ZL.Init2(function()
            UpdatetradeSkill()
        end)
        C_Timer.NewTicker(5, function()
            UpdatetradeSkill()
        end)
    end

    -- 获取货币信息
    do
        function ZL.MONEYupdate()
            local tbl = {}
            local player = ZL.playerName
            tbl.player = player
            tbl.colorplayer = SetClassCFF(player, "player")
            tbl.skill = ZongLan[MONEY][realmID][player].skill
            for i, v in ipairs(ZL.MONEYall_table) do
                if v.type == "money" then
                    tbl.money = floor(GetMoney() / 1e4)
                elseif v.type == "items" then
                    local itemsTbl = {}
                    for _, v in ipairs(v.ids) do
                        if type(v) == "table" then
                            local items = v
                            for _, itemID in ipairs(items) do
                                local count = GetItemCount(itemID, true)
                                if count and count > 0 then
                                    tinsert(itemsTbl, {
                                        id = itemID,
                                        count = count,
                                    })
                                    break
                                end
                            end
                        else
                            local itemID = v
                            local count = GetItemCount(itemID, true)
                            if count and count > 0 then
                                tinsert(itemsTbl, {
                                    id = itemID,
                                    count = count,
                                })
                            end
                        end
                    end
                    tbl[v.id] = itemsTbl
                elseif v.type == "item" then
                    local id = v.id
                    local tex = v.tex
                    if v.quest2 and not C_QuestLog.IsQuestFlaggedCompleted(v.quest2) then
                        id = v.id2
                        tex = v.tex2
                    end
                    local count
                    if v.id_gold and v.id_copper then
                        count = GetItemCount(v.id_gold, true) * 100 + GetItemCount(v.id, true) + floor(GetItemCount(v.id_copper, true) / 100)
                    else
                        count = GetItemCount(id, true)
                    end
                    local questsCompleted
                    if v.quest and C_QuestLog.IsQuestFlaggedCompleted(v.quest) then
                        questsCompleted = true
                    end
                    tbl[v.id] = { count = count, tex = tex, isItem = true, quest = questsCompleted, }
                elseif v.type == "xp" then
                    tbl.xp = ZongLan[MONEY][realmID][player].xp
                elseif v.type ~= "equip" and C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
                    local info = C_CurrencyInfo.GetCurrencyInfo(v.id)
                    if info then
                        local count = info.quantity
                        local tex = info.iconFileID
                        tbl[v.id] = {
                            count = count,
                            tex = tex,
                        }
                        local weekMax = info.maxWeeklyQuantity
                        if weekMax and weekMax > 0 then
                            local weekCount = info.quantityEarnedThisWeek
                            tbl[v.id].weekCount = weekCount
                            tbl[v.id].weekMax = weekMax
                            if weekCount >= weekMax then
                                tbl[v.id].weekTimestamp = select(2, ZL.GetNextWeekTime())
                            end
                        end
                        local totalMax = info.maxQuantity
                        if totalMax and totalMax > 0 then
                            if info.useTotalEarnedForMaxQty then
                                local totalCount = info.totalEarned
                                tbl[v.id].totalCount = totalCount
                                tbl[v.id].totalMax = totalMax
                                if totalCount >= totalMax then
                                    tbl[v.id].weekTimestamp = select(2, ZL.GetNextWeekTime())
                                end
                            else
                                if count >= totalMax then
                                    tbl[v.id].isFull = true
                                end
                            end
                        end
                    end
                end
            end
            ZongLan[MONEY][realmID][player] = tbl
        end

        local function UpdateCD()
            local time = GetServerTime()
            for _, db in ipairs(dbNames) do
                if _G[db] and _G[db][MONEY] then
                    for realmID in pairs(_G[db][MONEY]) do
                        if type(realmID) == "number" and type(_G[db][MONEY][realmID]) == "table" then
                            for player in pairs(_G[db][MONEY][realmID]) do
                                for id, v in pairs(_G[db][MONEY][realmID][player]) do
                                    if type(v) == "table" and v.weekTimestamp and time >= v.weekTimestamp then
                                        _G[db][MONEY][realmID][player][id].weekTimestamp = nil
                                        if v.weekCount then
                                            _G[db][MONEY][realmID][player][id].weekCount = 0
                                        end
                                        if v.totalMax then
                                            _G[db][MONEY][realmID][player][id].totalMax = 0
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- 事件
        ZL.Init2(function()
            UpdateCD()
            C_Timer.After(0.5, ZL.MONEYupdate)
        end)
        ZL.RegisterEvent({ "CURRENCY_DISPLAY_UPDATE", "PLAYER_MONEY", "BAG_UPDATE_DELAYED" }, function()
            C_Timer.After(0.5, ZL.MONEYupdate)
        end)
    end

    -- 获取双倍经验
    do
        -- 创建插件框架
        local race = select(2, UnitRace("player"))
        local isPanda = race == "Pandaren"
        local function UpdateXP()
            local exhaustion = GetXPExhaustion() -- 获取剩余双倍经验值
            local per = 0
            if exhaustion then
                local maxXP = UnitXPMax("player")
                per = exhaustion / maxXP * 100
            end
            ZongLan[MONEY][realmID][player].xp = {
                per = format("%.1f", per),
                perNow = format("%d", per),
                time = GetServerTime(),
                resting = IsResting(),
                isPanda = isPanda,
            }
        end
        ZL.Init2(UpdateXP)
        ZL.RegisterEvent({ "PLAYER_XP_UPDATE", "UPDATE_EXHAUSTION", "PLAYER_LEVEL_UP", "PLAYER_UPDATE_RESTING" }, UpdateXP)

        function ZL.UpdateXP()
            local time = GetServerTime()
            local function Update(db)
                if not (db and db[MONEY]) then return end
                for realmID, v in pairs(db[MONEY]) do
                    if (type(realmID) == "number" and type(db[MONEY][realmID]) == "table") then
                        for player, v in pairs(db[MONEY][realmID]) do
                            if type(v.xp) == "table" then
                                local num = 4
                                if v.xp.resting then
                                    num = 1
                                end
                                local panda = 1
                                if v.xp.isPanda then
                                    panda = 0.5
                                end
                                v.xp.perNow = min(150, format("%d", tonumber(v.xp.per) + (time - v.xp.time) / (60 * 60 * 8 * num * panda) * 5))
                            end
                        end
                    end
                end
            end
            Update(ZongLan)
            Update(ZongLanDB)
        end
    end

    -- 角色装备和装等
    do
        ZongLan.equip = ZongLan.equip or {}
        ZongLan.equip[realmID] = ZongLan.equip[realmID] or {}
        ZongLan.equip[realmID][player] = ZongLan.equip[realmID][player] or {}

        local ItemLevelPattern = gsub(ITEM_LEVEL, "%%d", "(%%d+)")
        local function GetItemLevelByTooltip(slot, link)
            ZongLanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
            ZongLanTooltip:SetInventoryItem("player", slot)
            local text, level
            for i = 2, 5 do
                if _G[ZongLanTooltip:GetName() .. "TextLeft" .. i] then
                    text = _G[ZongLanTooltip:GetName() .. "TextLeft" .. i]:GetText() or ""
                    level = string.match(text, ItemLevelPattern)
                    if level then
                        return tonumber(level)
                    end
                end
            end
            level = select(4, GetItemInfo(link)) or 0
            return level
        end

        function ZL.GetPlayerEquip()
            local tbl = ZongLan.equip[realmID][player]
            wipe(tbl)
            for slot = 1, 19 do
                local link = GetInventoryItemLink("player", slot)
                if link then
                    local itemID = GetInventoryItemID("player", slot)
                    local quality = GetInventoryItemQuality("player", slot)
                    local level
                    if ZL.IsMOP then
                        level = GetItemLevelByTooltip(slot, link)
                    else
                        level = select(4, GetItemInfo(link))
                    end
                    slot = tostring(slot)
                    tbl[slot] = {
                        link = link,
                        itemID = itemID,
                        quality = quality,
                        level = level,
                    }
                end
            end
        end

        local function GetPlayerAverageItemLevel()
            local _, avgLevel = GetAverageItemLevel()
            ZongLan.playerInfo[realmID][player].iLevel = avgLevel or 0
            local avgLevel0 = Round(avgLevel, 0)
            -- 更新集结号密语装等
            if ZL.isFullLevel and ZL.MeetingHorn and ZL.MeetingHorn.iLevelCheckButton then
                ZL.MeetingHorn.iLevelCheckButton.Text:SetText(avgLevel0)
            end
        end

        local delay
        local again
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:SetScript("OnEvent", function(self, event, ...)
            if event == "PLAYER_ENTERING_WORLD" then
                self:UnregisterEvent("PLAYER_ENTERING_WORLD")
                delay = 3
                again = true
                ZL.After(delay, function()
                    self:RegisterEvent("UNIT_INVENTORY_CHANGED")
                end)
            else
                delay = 1
            end
            self.t = 0
            self:SetScript("OnUpdate", function(_, t)
                self.t = self.t + t
                if self.t > delay then
                    self:SetScript("OnUpdate", nil)
                    ZL.GetPlayerEquip()
                    GetPlayerAverageItemLevel()
                    if again then
                        again = nil
                        ZL.After(5, function()
                            ZL.GetPlayerEquip()
                            GetPlayerAverageItemLevel()
                        end)
                    end
                end
            end)
        end)
    end

    -- 背包
    do
        ZongLan.bag = ZongLan.bag or {}
        ZongLan.bag[realmID] = ZongLan.bag[realmID] or {}
        ZongLan.bag[realmID][player] = ZongLan.bag[realmID][player] or {}
        ZongLan.bag[realmID][player].bag = ZongLan.bag[realmID][player].bag or {}
        ZongLan.bag[realmID][player].bagKey = ZongLan.bag[realmID][player].bagKey or {}
        ZongLan.bag[realmID][player].bank = ZongLan.bag[realmID][player].bank or {}
        ZongLan.bag[realmID][player].bagLink = ZongLan.bag[realmID][player].bagLink or {}
        ZongLan.bag[realmID][player].bagKeyLink = ZongLan.bag[realmID][player].bagKeyLink or {}
        ZongLan.bag[realmID][player].bankLink = ZongLan.bag[realmID][player].bankLink or {}

        local function GetBagSlots(bagType)
            if bagType == "bag" then
                if ZL.IsRetail then
                    return BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS
                else
                    return BACKPACK_CONTAINER, BACKPACK_CONTAINER + NUM_BAG_SLOTS
                end
            elseif bagType == "bank" then
                if ZL.IsRetail then
                    return NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS
                else
                    return NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
                end
            end
        end

        local function SaveFromBagNum(bag, bagType)
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info then
                    ZongLan.bag[realmID][player][bagType][info.itemID] =
                        (ZongLan.bag[realmID][player][bagType][info.itemID] or 0) + info.stackCount
                    local link = info.hyperlink
                    if not link and C_Container.GetContainerItemLink then
                        link = C_Container.GetContainerItemLink(bag, slot)
                    end
                    if link then
                        local linkType = bagType .. "Link"
                        local oldInfo = ZongLan.bag[realmID][player][linkType][link]
                        local oldCount = type(oldInfo) == "table" and oldInfo.count or tonumber(oldInfo) or 0
                        local maxStack = select(8, GetItemInfo(link))
                        ZongLan.bag[realmID][player][linkType][link] = {
                            count = oldCount + info.stackCount,
                            stackable = (type(oldInfo) == "table" and oldInfo.stackable)
                                or info.stackCount > 1 or (maxStack and maxStack > 1) or nil,
                        }
                    end
                end
            end
        end

        function ZL.SaveBag()
            wipe(ZongLan.bag[realmID][player].bag)
            wipe(ZongLan.bag[realmID][player].bagKey)
            wipe(ZongLan.bag[realmID][player].bagLink)
            wipe(ZongLan.bag[realmID][player].bagKeyLink)
            local startBag, endBag = GetBagSlots("bag")
            for bag = startBag, endBag do
                SaveFromBagNum(bag, "bag")
            end
            SaveFromBagNum(-2, "bagKey")
        end

        function ZL.SaveBank()
            if ZL.IsRetail then return end
            if not ZL.bankIsOpen then return end
            wipe(ZongLan.bag[realmID][player].bank)
            wipe(ZongLan.bag[realmID][player].bankLink)
            local startBag, endBag = GetBagSlots("bank")
            for bag = startBag, endBag do
                SaveFromBagNum(bag, "bank")
            end
            SaveFromBagNum(-1, "bank")
        end

        function ZL.GetItemBagCount(tbl, itemID)
            return (tbl.bag and tbl.bag[itemID] or 0)
                + (tbl.bagKey and tbl.bagKey[itemID] or 0)
                + (tbl.bank and tbl.bank[itemID] or 0)
        end

        ZL.RegisterEvent("BAG_UPDATE_DELAYED", function()
            ZL.SaveBag()
            ZL.SaveBank()
        end)
        ZL.RegisterEvent("BANKFRAME_OPENED", function()
            ZL.bankIsOpen = true
            ZL.SaveBank()
        end)
        ZL.RegisterEvent("BANKFRAME_CLOSED", function()
            ZL.bankIsOpen = false
        end)
    end

    -- 声望
    if not ZL.IsRetail then
        ZongLan.bag[realmID][player].faction = ZongLan.bag[realmID][player].faction or {}

        local function SaveReputation()
            for _, factionID in ipairs(ZL.factionTbl) do
                local name, _, standingID, barMin, barMax, barValue = GetFactionInfoByID(factionID)
                if name then
                    ZongLan.bag[realmID][player].faction[factionID] = {
                        name = name,
                        standingID = standingID,
                        currentValue = barValue - barMin,
                        maxValue = barMax - barMin,
                        factionID = factionID,
                    }
                end
            end
        end

        ZL.Init2(function()
            ZL.After(10, function()
                SaveReputation()
            end)
        end)

        ZL.RegisterEvent("UPDATE_FACTION", function()
            ZL.After(.5, function()
                SaveReputation()
            end)
        end)
    end

    -- 删除重复角色装备数据
    for realmID, v in pairs(ZongLan.equip) do
        if type(realmID) == "number" and type(v) == "table" then
            if ZongLan.playerInfo[realmID] then
                for player in pairs(ZongLan.equip[realmID]) do
                    if not ZongLan.playerInfo[realmID][player] then
                        ZongLan.equip[realmID][player] = nil
                    end
                end
            else
                ZongLan.equip[realmID] = nil
            end
        end
    end
end)
