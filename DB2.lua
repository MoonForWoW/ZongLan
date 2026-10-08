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

local realmID = GetRealmID()

local FBCD = "RaidCD"
local MONEY = "MONEY"

ZL.Init(function()
    ZongLan[FBCD] = ZongLan[FBCD] or {}
    ZongLan[FBCD][realmID] = ZongLan[FBCD][realmID] or {}

    ZongLan[MONEY] = ZongLan[MONEY] or {}
    ZongLan[MONEY][realmID] = ZongLan[MONEY][realmID] or {}
    ZongLan[MONEY][realmID][ZL.myName] = ZongLan[MONEY][realmID][ZL.myName] or {}

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
            -- ZongLan.FBCDchoice.ULDtitan = 1
            -- ZongLan.FBCDchoice["SWtitan"] = 1
            -- ZongLan.FBCDchoice["ZAtitan"] = 1
            ZongLan.FBCDchoice.TOCtitan = 1
            ZongLan.FBCDchoice.ZUGtitan = 1
            ZongLan.FBCDchoice.NAXXtitan = 1
            ZongLan.FBCDchoice.OStitan = 0
            ZongLan.FBCDchoice.EOEtitan = 0
            ZongLan.FBCDchoice.SSCtitan = 0
            ZongLan.FBCDchoice.TKtitan = 0
            ZongLan.FBCDchoice.Doomwalker = 0
            ZongLan.FBCDchoice.DoomLordKazzak = 0
            ZongLan.FBCDchoice["MCtitan"] = 0
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
        elseif ZL.IsForever then
            ZL.Once("FBCDchoice", 260918, function()
                ZongLan.FBCDchoice.OLforever = 1
                ZongLan.FBCDchoice.HSforever = 1
                ZongLan.FBCDchoice.BDforever = 1
                for i, id in ipairs({ 2586, 2587, 2740, }) do
                    ZongLan.FBCDchoice["faction" .. id] = 1
                end
            end)
        end
    end
    if not ZongLan.MONEYchoice then
        ZongLan.MONEYchoice = {}
        ZongLan.MONEYchoice["money"] = 1
        if ZL.IsVanilla then
            ZongLan.MONEYchoice = {
                [22726] = 1,
                [226404] = 1,
                [221262] = 1,
                [221365] = 1,
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
            }
        elseif ZL.IsTitan then
            ZongLan.MONEYchoice[3403] = 1
            ZongLan.MONEYchoice[3406] = 1
            ZongLan.MONEYchoice[1901] = 1
            ZongLan.MONEYchoice["items"] = 1
            ZongLan.MONEYchoice["items_updateItem"] = 1
        elseif ZL.IsCTM then
            ZongLan.MONEYchoice = {
                [77952] = 1, -- 橙片
                [396] = 1,
                [395] = 1,
                [3281] = 1,
                [3148] = 1,
                [1901] = 1,
            }
        elseif ZL.IsMOP then
            ZongLan.MONEYchoice[396] = 1
            ZongLan.MONEYchoice[395] = 1
            ZongLan.MONEYchoice[3416] = 1
            ZongLan.MONEYchoice[776] = 1
            ZongLan.MONEYchoice[738] = 1
        elseif ZL.IsRetail then
            ZongLan.MONEYchoice[3383] = 1
            ZongLan.MONEYchoice[3341] = 1
            ZongLan.MONEYchoice[3343] = 1
            ZongLan.MONEYchoice[3345] = 1
            ZongLan.MONEYchoice[3347] = 1
        elseif ZL.IsForever then
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
            ZL.Once("FBCDchoice", 261007, function()
                ZongLan.FBCDchoice["ULDtitan"] = 1
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
            ZL.Once("FBCDchoice", 260923, function()
                ZongLan.MONEYchoice[3448] = 1
                ZongLan.MONEYchoice[3546] = 1
                ZongLan.MONEYchoice[3418] = 1
                ZongLan.MONEYchoice[3465] = 1
                ZongLan.MONEYchoice[3509] = 1
                ZongLan.MONEYchoice[3442] = 1
                ZongLan.MONEYchoice[3443] = 1
                ZongLan.MONEYchoice[3444] = 1
                ZongLan.MONEYchoice[3445] = 1
                ZongLan.MONEYchoice[3446] = 1
            end)
        elseif ZL.IsForever then
            ZL.Once("MONEYchoice", 260918, function()
                for i, id in ipairs({ 3469, 3402, 1792, }) do
                    ZongLan.MONEYchoice[id] = 1
                end
            end)
        end

        -- 默认勾选饰品和武器
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
            { 34334, 269842, 269845, 269846, 269847, 269848, 269849, },        -- 橙弓
            {
                46017, 270182, 270183, 270184, 270185, 270186,                 -- 奶橙锤
                287189, 287184, 287185, 287186, 287187, 287188,                -- 物理橙锤
                45038,                                                         -- 片
            },
        }
        ids_updateItem = {
            -- 10938, 10939, 29223, 264272, 2131, -- 测试
            265340, 265524, 267339, 269664, 270148, -- 橙脖
            265335, 265523, 267338, 269667, 270157, -- 橙锤
            265526, 267335, 269669, 270156,         -- 风剑
            267340, 269665, 270149,                 -- 橙杖
            269670, 270150,                         -- 橙匕
            270158,                                 -- 橙弓
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
                { name = "ULDtitan", name2 = L["奥杜尔"], color = "00BFFF", fbId = 603, type = "fb" },
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
            ZL.FBCount = 16
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

                3448, -- 腐蚀之币
                3546, -- 盘绕丝线
                3418, -- 星云虚空核心
                3465, -- 毒疫法力涌流
                3509, -- 潮汐火花尘
                3442, -- 冒险者迷雾纹章
                3443, -- 老兵迷雾纹章
                3444, -- 勇士迷雾纹章
                3445, -- 英雄迷雾纹章
                3446, -- 神话迷雾纹章
            }
            for i, id in ipairs(currencys) do
                tinsert(ZL.MONEYall_table, 1, { color = "ffffff", id = id, width = 80 })
            end
            tinsert(ZL.MONEYall_table, 1,
                { name = L["双倍经验"], color = "99ff99", type = "xp", id = "xp", tex = 1080931, width = 70 } -- 双倍经验
            )
        elseif ZL.IsForever then
            ZL.FBCDall_table = {
                { name = 'OLforever', name2 = L['奥妮克希亚'], color = "00BFFF", fbId = 249, type = "fb" },
                { name = 'HSforever', name2 = L['海加尔峰'], color = "00BFFF", fbId = -100, type = "fb" },
                { name = 'BDforever', name2 = L['深穴'], color = "00BFFF", fbId = -100, type = "fb" },
            }
            ZL.FBCount = #ZL.FBCDall_table

            ZL.MONEYall_table = {
                { name = L["双倍经验"], color = "99ff99", type = "xp", id = "xp", tex = 1080931, width = 70 }, -- 双倍经验
                { color = "ffffff", id = 3469, width = 70 }, -- 褪色的安德麦雷亚尔
                { color = "ffffff", id = 3402, width = 70 }, -- 商人青睐
                { color = "ffffff", id = 1792, width = 70 }, -- 荣誉点数
                { color = "ffffff", id = 3468, width = 70 }, -- 等级点数
                { color = "ffffff", id = 515, width = 70 }, -- 暗月奖券
                { name = L["金币"], color = "FFD700", type = "money", id = "money", tex = 237618, width = 80 }, -- 金币
            }

            -- 声望
            ZL.factionTbl = {
                -- 1077, -- 破碎残阳
            }
            tinsert(ZL.factionTbl, 1, ZL.IsAlliance and 2586 or 2587) -- 贸易局
            if ZL.IsAlliance then
                tinsert(ZL.factionTbl, 2740)                          -- 肯瑞托
            end
            for _, id in ipairs(ZL.factionTbl) do
                local name3
                tinsert(ZL.FBCDall_table, {
                    name = "faction" .. id,
                    name2 = C_Reputation.GetFactionDataByID(id).name,
                    name3 = name3,
                    id = id,
                    color = "FFFF00",
                    type = "faction"
                })
            end
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

    -- 爆发药水与合剂
    do
        local presetPotionIDs, presetFlaskIDs
        if ZL.IsVanilla then
            presetPotionIDs = {
                13442, -- 强效怒气药水
                13455, -- 强效石盾药水
            }
            presetFlaskIDs = {
                13510, -- 泰坦合剂
                13511, -- 精炼智慧合剂
                13512, -- 超级能量合剂
                13513, -- 多重抗性合剂
            }
        elseif ZL.IsTBC then
            presetPotionIDs = {
                22788, -- 烈焰菇
                22828, -- 疯狂力量药水
                22837, -- 英雄药水
                22838, -- 加速药水
                22839, -- 毁灭药水
                22849, -- 铁盾药水
            }
            presetFlaskIDs = {
                22851, -- 强固合剂
                22853, -- 强效回复合剂
                22854, -- 无情突袭合剂
                22861, -- 盲目光芒合剂
                22866, -- 纯粹死亡合剂
                33208, -- 多彩奇迹合剂
            }
        elseif ZL.IsTitan then
            presetPotionIDs = {
                40211, -- 速度药水
                40212, -- 狂野魔法药水
                40093, -- 不灭药水
                20007, -- 狂野魔精药水
            }
            presetFlaskIDs = {
                46376, -- 冰霜巨龙合剂
                46377, -- 无尽怒气合剂
                46378, -- 纯净魔精合剂
                46379, -- 石血合剂
                40079, -- 次级坚韧合剂
                44939, -- 次级抗性合剂
                13511, -- 精炼智慧合剂
            }
        elseif ZL.IsWLK_80 then
            presetPotionIDs = {
                40211, -- 速度药水
                40212, -- 狂野魔法药水
                40093, -- 不灭药水
            }
            presetFlaskIDs = {
                46376, -- 冰霜巨龙合剂
                46377, -- 无尽怒气合剂
                46378, -- 纯净魔精合剂
                46379, -- 石血合剂
                40079, -- 次级坚韧合剂
                44939, -- 次级抗性合剂
                13511, -- 精炼智慧合剂
            }
        elseif ZL.IsCTM then
            presetPotionIDs = {
                58146, -- 魔像之血药水
                58145, -- 托维尔药水
                58091, -- 火山药水
                58090, -- 土灵药水
            }
            presetFlaskIDs = {
                58088, -- 泰坦之力合剂
                58087, -- 风行合剂
                58086, -- 龙智合剂
                58085, -- 钢皮合剂
                67438, -- 流水合剂
            }
        elseif ZL.IsMOP then
            presetPotionIDs = {
                76095, -- 魔古之力药水
                76089, -- 春华药水
                76093, -- 青龙药水
                76090, -- 高山药水
            }
            presetFlaskIDs = {
                76088, -- 冬噬合剂
                76084, -- 春华合剂
                76085, -- 暖阳合剂
                76086, -- 秋叶合剂
                76087, -- 大地合剂
            }
        elseif ZL.IsRetail then
            presetPotionIDs = {
                241308, 241309, -- 光明潜能
                241296, 241297, -- 狂热药水
                241288, 241289, -- 鲁莽药水
                241292, 241293, -- 狂放饮剂
                271886, 271887, -- 流光药剂
                271889, 271890, -- 诱惑秘药
            }
            presetFlaskIDs = {
                241320, 241321, -- 萨拉斯抗性合剂
                241322, 241323, -- 魔导师合剂
                241324, 241325, -- 血骑士合剂
                241326, 241327, -- 破碎残阳合剂
            }
        elseif ZL.IsForever then
            presetFlaskIDs = {
                13510, -- 泰坦合剂
                13511, -- 精炼智慧合剂
                13512, -- 超级能量合剂
                13513, -- 多重抗性合剂
            }
        end
        ns.presetPotionIDs = presetPotionIDs
        ns.presetFlaskIDs = presetFlaskIDs
    end
end)
