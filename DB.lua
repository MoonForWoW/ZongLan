local AddonName, ns                         = ...

local L                                     = ns.L
local RGB                                   = ns.RGB
local GetClassColor                         = ns.GetClassColor

local pt                                    = print

local LibBG                                 = LibStub:GetLibrary("BiaoGe-LibUIDropDownMenu-4.0") -- 调用库菜单UI
ns.LibBG                                    = LibBG
LibBG.UIDropDownMenu_HandleGlobalMouseEvent = function() end

local realmID                               = GetRealmID()
local player                                = BG.playerName
local realmName                             = BG.realmName
local GetAddOnMetadata                      = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local IsAddOnLoaded                         = IsAddOnLoaded or C_AddOns.IsAddOnLoaded
local LoadAddOn                             = LoadAddOn or C_AddOns.LoadAddOn

-- 全局变量
do
    BG.FBtable = {}
    BG.FBtable2 = {}
    BG.FBIDtable = {}
    BG.lootQuality = {}
    BG.difficultyTable = {}
    BG.diffIDTbl = {}
    BG.phaseFBtable = {}
    BG.bossPositionStartEnd = {}
    BG.FBfromBossPosition = {}
    BG.Movetable = {}
    BG.options = {}
    BG.itemCaches = {}
    BG.dropDown = LibBG:Create_UIDropDownMenu(nil, UIParent)
    BG.onEnterAlpha = 0.1
    BG.highLightAlpha = 0.2
    BG.otherEditAlpha = 0.3
    BG.scrollStep = 80
    BG.borderAlpha = .5
    BG.ver = "v" .. GetAddOnMetadata(AddonName, "Version")
    BG.BG = "|cff00BFFF<BiaoGe>|r "
    BG.rareIcon = "|A:nameplates-icon-elite-silver:0:0|a"
    BG.iconTexCoord = { .07, .93, .07, .93 }
    BG.zaxiang = {} -- 杂项如果太多，则需要换列
    BG.zhuangbeiWidth = 140
    BG.zhuangbeiWidth2 = 235
    BG.maijiaWidth = 90
    BG.jineWidth = 90
    BG.spFB = {}
    BG.fakuanIsFirst = {}
    BG.editTemplate = "BiaoGe_InputBoxTemplate" or "InputBoxTemplate"
    BG.editSearchTemplate = "BiaoGe_SearchBoxTemplate" or "SearchBoxTemplate"
    BG.scrollTemplate = "BiaoGe_ModernScrollFrameTemplate" or "UIPanelScrollFrameTemplate"
    BG.notLootBossIDs = {}
    BG.itemOnEnterDelay = 0.02
    BG.addonChannelCount = 10
    BG.LastBagItemFrame = {}
    if BG.IsRetail then
        BG.CloseButtonOffset = 0
    else
        BG.CloseButtonOffset = 2
    end
end

-- 初始化
do
    -- 基础信息
    do
        if BG.IsVanilla_Sod then
            BG.FB1 = "MCsod"
            BG.fullLevel = 60
            BG.fullLevel_RoleOverview = 25
        end
        if BG.IsVanilla_60 then
            BG.fullLevel = 60
            BG.fullLevel_RoleOverview = 35
        end
        if BG.IsTBC then
            BG.fullLevel = 70
            BG.fullLevel_RoleOverview = 35
        end
        if BG.IsWLK_80 then
            BG.fullLevel = 80
            BG.fullLevel_RoleOverview = 60
        end
        if BG.IsTitan then
            BG.fullLevel = 80
            BG.fullLevel_RoleOverview = 60
        end
        if BG.IsCTM then
            BG.fullLevel = 85
            BG.fullLevel_RoleOverview = 70
        end
        if BG.IsMOP then
            BG.fullLevel = 90
            BG.fullLevel_RoleOverview = 80
            BG.worldBossID = { 32098, 32099, 32518, 32519, 33117, 33118, } -- 炮舰 怒之煞 暴风领主纳拉克 乌达斯塔 四天神 野牛人
        end
        if BG.IsRetail then
            BG.fullLevel = 90
            BG.fullLevel_RoleOverview = 80
        end
    end

    -- 颜色
    do
        BG.b1 = "00BFFF"
        function BG.STC_b1(text)
            if text then
                local t
                t = "|cff" .. "00BFFF" .. text .. "|r"
                return t
            end
        end

        BG.r1 = "FF0000"
        function BG.STC_r1(text)
            if text then
                local t
                t = "|cff" .. "FF0000" .. text .. "|r"
                return t
            end
        end

        BG.r2 = "FF1493"
        function BG.STC_r2(text)
            if text then
                local t
                t = "|cff" .. "FF1493" .. text .. "|r"
                return t
            end
        end

        BG.r3 = "FF69B4"
        function BG.STC_r3(text)
            if text then
                local t
                t = "|cff" .. "FF69B4" .. text .. "|r"
                return t
            end
        end

        BG.g1 = "00FF00"
        function BG.STC_g1(text)
            if text then
                local t
                t = "|cff" .. "00FF00" .. text .. "|r"
                return t
            end
        end

        BG.g2 = "40c040"
        function BG.STC_g2(text)
            if text then
                local t
                t = "|cff" .. "40c040" .. text .. "|r"
                return t
            end
        end

        BG.y1 = "FFFF00"
        function BG.STC_y1(text) -- yellow
            if text then
                local t
                t = "|cff" .. "FFFF00" .. text .. "|r"
                return t
            end
        end

        BG.y2 = "FFD100"
        function BG.STC_y2(text) -- gold
            if text then
                local t
                t = "|cff" .. "FFD100" .. text .. "|r"
                return t
            end
        end

        BG.w1 = "FFFFFF"
        function BG.STC_w1(text) -- 白色
            if text then
                local t
                t = "|cff" .. "FFFFFF" .. text .. "|r"
                return t
            end
        end

        BG.dis = "808080"
        function BG.STC_dis(text) -- 灰色
            if text then
                local t
                t = "|cff" .. "808080" .. text .. "|r"
                return t
            end
        end
    end

    -- 声音
    do
        BG.sound1 = SOUNDKIT.GS_TITLE_OPTION_OK -- 按键音效
        BG.sound2 = 569593                      -- 升级音效
        BG.sound3 = SOUNDKIT.IG_MAINMENU_CLOSE  -- 菜单打开音效

        local Interface = "Interface\\AddOns\\BiaoGe\\Media\\sound\\"
        BG.soundAuthor = {
            { ID = "AI", addonName = AddonName, isBiaoGe = true },
        }
        BG.soundTbl = BG.soundAuthor
        BG.soundTbl2 = {
            { ID = "paimai", name = "拍卖啦" },
            { ID = "hope", name = "心愿达成" },
            { ID = "qingkong", name = "已清空表格" },
            { ID = "cehuiqingkong", name = "已撤回清空" },
            { ID = "alchemyReady", name = "炼金转化已就绪" },
            { ID = "tailorReady", name = "裁缝洗布已就绪" },
            { ID = "leatherworkingReady", name = "制皮筛盐已就绪" },
            { ID = "pingjia", name = "给个评价吧" },
            { ID = "biaogefull", name = "表格满了" },
            { ID = "guoqi", name = "装备快过期了" },
            { ID = "uploading", name = "账单正在上传" },
            { ID = "uploaded", name = "账单上传成功" },
            { ID = "countDownStop", name = "倒数暂停" },
            { ID = "HusbandComeOn", name = "老公加油" },
            { ID = "qiankuan", name = "你有未收欠款" },
            { ID = "autoAuctionAutoEndTips", name = "自动出价结束" },
            { ID = "tradeSuccess", name = "交易成功" },
            { ID = "tradeFalse", name = "交易失败" },
            { ID = "fakuanFull", name = "罚款格子满了" },
            { ID = "auctionError", name = "拍卖出错了" },
            { ID = "currencyfull", name = "牌子满了" },
            { ID = "auctionTopPrice", name = "小心偷家" },
            { ID = "tooLate", name = "请不要卡秒出价" },
        }
        --[[
/run BG.PlaySound("paimai")
/run BG.PlaySound("hope")
]]
        local function DefaultSound()
            for i = 1, C_AddOns.GetNumAddOns() do
                local addonName = C_AddOns.GetAddOnInfo(i)
                local enabled = C_AddOns.GetAddOnEnableState(i, player)
                if C_AddOns.GetAddOnMetadata(i, "X-BiaoGe-Voice") and enabled ~= 0 then
                    local author = C_AddOns.GetAddOnMetadata(i, "Author")
                    tinsert(BG.soundAuthor, { ID = author, addonName = addonName })
                end
            end
            for _, value in ipairs(BG.soundAuthor) do
                local author = value.ID
                local addonName = value.addonName
                local isBiaoGe = value.isBiaoGe
                for _, v in ipairs(BG.soundTbl2) do
                    local soundID = v.ID
                    local soundName = v.name
                    if isBiaoGe then
                        BG["sound_" .. soundID .. author] = Interface .. author .. "\\" .. soundID
                    else
                        BG["sound_" .. soundID .. author] = format("Interface\\AddOns\\%s\\sound\\%s", addonName, soundName)
                    end
                end
            end

            local yes
            for i, v in ipairs(BG.soundAuthor) do
                if BiaoGe.options.Sound == v.ID then
                    yes = true
                end
            end
            if not yes then
                BiaoGe.options.Sound = "AI"
            end
        end

        BG.Init2(function()
            DefaultSound()
        end)
    end

    BG.classColorNames = {}
    for i = 1, GetNumClasses() do
        local className, classFilename = GetClassInfo(i)
        if className then
            local color = select(4, GetClassColor(classFilename))
            BG.classColorNames[className] = format("|c%s%s|r", color, className)
        end
    end

    hooksecurefunc(LibBG, "ToggleDropDownMenu", function(_, _, _, dropDown)
        for i = 1, L_UIDROPDOWNMENU_MAXBUTTONS do
            local button = _G["L_DropDownList1Button" .. i]
            if button.line then button.line:Hide() end
            if button.value == "   " then
                if not button.line then
                    local line = button:CreateTexture(nil, 'BACKGROUND')
                    line:SetTexture([[Interface\Common\UI-TooltipDivider-Transparent]])
                    line:SetHeight(8)
                    line:SetPoint('LEFT')
                    line:SetPoint('RIGHT', -5, 0)
                    line:Hide()
                    button.line = line
                end
                button.line:Show()
            end
        end
    end)
end

-- 本地配置数据库
BG.Init(function()
    if type(BiaoGe) ~= "table" then
        BiaoGe = {}
    end
    if not BiaoGe.point then
        BiaoGe.point = {}
    end

    if not BiaoGe.options then
        BiaoGe.options = {}
    end
    
    if not BiaoGe.options.SearchHistory then
        BiaoGe.options.SearchHistory = {}
    end

    -- 记录服务器名称
    do
        BiaoGe.realmName = BiaoGe.realmName or {}
        BiaoGe.realmName[realmID] = realmName
    end
    -- 记录每个角色的职业、等级、天赋
    do
        BiaoGe.playerInfo = BiaoGe.playerInfo or {}
        BiaoGe.playerInfo[realmID] = BiaoGe.playerInfo[realmID] or {}
        BiaoGe.playerInfo[realmID][player] = BiaoGe.playerInfo[realmID][player] or {}
        BiaoGe.playerInfo[realmID][player].class = select(2, UnitClass("player"))
        BiaoGe.playerInfo[realmID][player].raceID = select(3, UnitRace("player"))
        BiaoGe.playerInfo[realmID][player].faction = UnitFactionGroup("player")
        BiaoGe.playerInfo[realmID][player].iLevel = select(2, GetAverageItemLevel()) or 0

        local function UpdateLevel(level)
            BiaoGe.playerInfo[realmID][player].level = level
            BG.isFullLevel = level >= BG.fullLevel
        end
        UpdateLevel(UnitLevel("player"))
        BG.RegisterEvent("PLAYER_LEVEL_UP", function(self, event, level)
            UpdateLevel(level)
            if BG.UpdateMeetingHornLevelButton then
                BG.UpdateMeetingHornLevelButton()
            end
        end)

        -- 天赋
        do
            local function GetTalent(_, event)
                local specIndex
                if BG.verOver4 then
                    specIndex = C_SpecializationInfo.GetSpecialization()
                    if specIndex == 0 or specIndex == 5 then
                        specIndex = nil
                    end
                else
                    local maxNum = 0
                    for i = 1, 3 do
                        local num = select(5, GetTalentTabInfo(i, nil, nil, GetActiveTalentGroup()))
                        if num and num >= maxNum then
                            maxNum = num
                            specIndex = i
                        end
                    end
                    if maxNum == 0 then specIndex = nil end
                end
                BiaoGe.playerInfo[realmID][player].talent = specIndex
            end

            local f = CreateFrame("Frame")
            f:RegisterEvent("PLAYER_TALENT_UPDATE")
            f:RegisterEvent("PLAYER_ENTERING_WORLD")
            if BG.verOver4 then
                f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
            end
            f:SetScript("OnEvent", function(self, event, ...)
                if event == "PLAYER_ENTERING_WORLD" then
                    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
                end
                self.t = 0
                self:SetScript("OnUpdate", function(_, t)
                    self.t = self.t + t
                    if self.t > 1 then
                        self:SetScript("OnUpdate", nil)
                        GetTalent()
                    end
                end)
            end)

            function BG.GetTalentIcon(class, talent, w)
                w = w or 0
                if talent then
                    local a, b, c, d = unpack(BG.iconTexCoord)
                    local coord = format("100:100:%s:%s:%s:%s", a * 100, b * 100, c * 100, d * 100)
                    local tex = BG.talentIcon[class][talent]
                    if tex then
                        return format("|T%s:%s:%s:0:0:%s|t", BG.talentIcon[class][talent], w, w, coord)
                    end
                end
                return format("|A:GarrMission_ClassIcon-%s:%s:%s|a", class, w, w)
            end

            BG.talentIcon = {
                DEATHKNIGHT = {
                    "Interface\\Icons\\Spell_Deathknight_BloodPresence", -- T
                    "Interface\\Icons\\Spell_Deathknight_FrostPresence",
                    "Interface\\Icons\\Spell_Deathknight_UnholyPresence",
                },
                PALADIN = {
                    "Interface\\Icons\\Spell_Holy_HolyBolt",     -- N
                    "Interface\\Icons\\Spell_Holy_DevotionAura", -- T
                    "Interface\\Icons\\Spell_Holy_AuraOfLight",
                },
                WARRIOR = {
                    "Interface\\Icons\\ability_warrior_savageblow",
                    "Interface\\Icons\\ability_warrior_innerrage",
                    "Interface\\Icons\\ability_warrior_defensivestance", -- T
                },
                EVOKER = {                                               -- 唤魔师
                    "Interface\\Icons\\ability_evoker_powerswell",
                    "Interface\\Icons\\ability_evoker_emeraldblossom",
                    "Interface\\Icons\\ability_evoker_reversion_green",
                },
                SHAMAN = {
                    "Interface\\Icons\\spell_nature_lightning",
                    "Interface\\Icons\\spell_nature_lightningshield",
                    "Interface\\Icons\\Spell_Nature_HealingWaveGreater", -- N
                },
                HUNTER = {
                    "Interface\\Icons\\Ability_Hunter_BeastTaming",
                    "Interface\\Icons\\Ability_Marksmanship",
                    "Interface\\Icons\\Ability_Hunter_SwiftStrike",
                },
                DEMONHUNTER = {
                    "Interface\\Icons\\ability_demonhunter_specdps",
                    "Interface\\Icons\\Ability_DemonHunter_SpecTank",
                    "Interface\\Icons\\classicon_demonhunter_void",
                },
                MONK = {
                    "Interface/Icons/spell_monk_brewmaster_spec", -- 酒仙
                    "Interface/Icons/spell_monk_mistweaver_spec", -- 织雾
                    "Interface/Icons/spell_monk_windwalker_spec", -- 踏风
                },
                ROGUE = {
                    "Interface\\Icons\\ability_rogue_eviscerate",
                    "Interface\\Icons\\ability_backstab",
                    "Interface\\Icons\\ability_stealth",
                },
                MAGE = {
                    "Interface\\Icons\\inv_misc_rune_03",
                    "Interface\\Icons\\spell_fire_firebolt02",
                    "Interface\\Icons\\spell_frost_frostbolt02",
                },
                WARLOCK = {
                    "Interface\\Icons\\spell_shadow_deathcoil",
                    "Interface\\Icons\\spell_shadow_metamorphosis",
                    "Interface\\Icons\\spell_shadow_rainoffire",
                },
                PRIEST = {
                    "Interface\\Icons\\spell_holy_wordfortitude",  -- N
                    "Interface\\Icons\\spell_holy_guardianspirit", -- N
                    "Interface\\Icons\\spell_shadow_shadowwordpain",
                },
            }
            if BG.verOver4 then
                BG.talentIcon.DRUID = {
                    "Interface\\Icons\\spell_nature_starfall",     -- 鸟
                    "Interface\\Icons\\ability_druid_catform",     -- 猫
                    "Interface\\Icons\\ability_racial_bearform",   -- 熊
                    "Interface\\Icons\\Spell_Nature_HealingTouch", -- N
                }
            else
                BG.talentIcon.DRUID = {
                    "Interface\\Icons\\spell_nature_starfall",
                    "Interface\\Icons\\ability_racial_bearform",
                    "Interface\\Icons\\Spell_Nature_HealingTouch", -- N
                }
            end
        end
    end

    -- 默认字体
    do
        local l = GetLocale()
        local default, list
        if (l == "koKR") then
            default = "2002.TTF"
        elseif (l == "zhCN") then
            default = "ARKai_T.ttf"
            list = {
                "ARKai_T.ttf",
                "ARKai_C.ttf",
                "ARHei.ttf",
                -- "ARIALN.ttf",
                -- "FRIZQT__.ttf",
            }
        elseif (l == "zhTW") then
            default = "blei00d.TTF"
            list = {
                "bLEI00D.ttf",
                "bHEI00M.ttf",
                "bHEI01B.ttf",
                "bKAI00M.ttf",
            }
        elseif (l == "ruRU") then
            default = "FRIZQT___CYR.TTF"
        else
            default = "FRIZQT__.TTF"
            list = {
                "FRIZQT__.TTF",
                "2002.TTF",
                "2002B.TTF",
                "ARHei.TTF",
                "ARKai_C.TTF",
                "ARKai_T.TTF",
                "ARIALN.TTF",
                "K_Pagetext.TTF",
                "MORPHEUS_CYR.TTF",
                "NIM_____.ttf",
                "SKURRI_CYR.TTF",
            }
        end
        BiaoGe.font = BiaoGe.font or default

        local t = UIParent:CreateFontString()
        t:SetFont(format("Fonts\\%s", BiaoGe.font), 15, "OUTLINE")
        t:Hide()
        if not t:GetFont() then
            BiaoGe.font = default
        end
        BIAOGE_TEXT_FONT = format("Fonts\\%s", BiaoGe.font)

        if list then
            for i = #list, 1, -1 do
                local t = UIParent:CreateFontString()
                t:SetFont(format("Fonts\\%s", list[i]), 15, "OUTLINE")
                t:Hide()
                if not t:GetFont() then
                    tremove(list, i)
                end
            end
        end
        BG.fontList = list

        local name = "editFontSize"
        BiaoGe.options[name] = BiaoGe.options[name] or 14
        function BiaoGe_InputBoxTemplate_OnLoad(self)
            self:SetFont(BIAOGE_TEXT_FONT, BiaoGe.options[name], "OUTLINE")
        end
    end

    -- 自定义字体
    do
        local function CreateMyFont(color, size, H)
            local cff
            if color == "Blue" then
                cff = "00BFFF"
            elseif color == "Green" then
                cff = "00FF00"
            elseif color == "Green2" then
                cff = "40c040"
            elseif color == "Red" then
                cff = "FF0000"
            elseif color == "Fen" then
                cff = "FF69B4"
            elseif color == "Gold" then
                cff = "FFD100"
            elseif color == "Yellow" then
                cff = "FFFF00"
            elseif color == "White" then
                cff = "FFFFFF"
            elseif color == "Dis" then
                cff = "808080"
            end
            BG["Font" .. color .. size] = CreateFont("BG.Font" .. color .. size)
            BG["Font" .. color .. size]:SetTextColor(RGB(cff))
            BG["Font" .. color .. size]:SetFont(BIAOGE_TEXT_FONT, size, "OUTLINE")
        end

        CreateMyFont("Blue", 13)
        CreateMyFont("Blue", 15)

        CreateMyFont("Green", 13)
        CreateMyFont("Green", 15)
        CreateMyFont("Green", 25)

        CreateMyFont("Green2", 15)

        CreateMyFont("Gold", 13)
        CreateMyFont("Gold", 15)

        CreateMyFont("Yellow", 13)
        CreateMyFont("Yellow", 15)

        CreateMyFont("Red", 13)
        CreateMyFont("Red", 15)

        CreateMyFont("Fen", 15)

        CreateMyFont("White", 13)
        CreateMyFont("White", 14)
        CreateMyFont("White", 15)
        CreateMyFont("White", 18)
        CreateMyFont("White", 25)

        CreateMyFont("Dis", 13)
        CreateMyFont("Dis", 15)
    end
end)

-- 命令行
SlashCmdList["BiaoGeRoleOverview"] = function()
    BG.SetFBCD(nil, nil, true)
end
SLASH_BiaoGeRoleOverview1 = "/bgr"
SLASH_Baganator2 = nil
