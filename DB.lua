local AddonName, ns                         = ...

local L                                     = ns.L
local RGB                                   = ns.RGB
local GetClassColor                         = ns.GetClassColor

local pt                                    = print

local LibBG                                 = LibStub:GetLibrary("BiaoGe-LibUIDropDownMenu-4.0") -- 调用库菜单UI
ns.LibBG                                    = LibBG
LibBG.UIDropDownMenu_HandleGlobalMouseEvent = function() end

local realmID                               = GetRealmID()
local player                                = ZL.playerName
local realmName                             = ZL.realmName
local GetAddOnMetadata                      = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local IsAddOnLoaded                         = IsAddOnLoaded or C_AddOns.IsAddOnLoaded
local LoadAddOn                             = LoadAddOn or C_AddOns.LoadAddOn

ZongLanTooltip                              = CreateFrame("GameTooltip", "ZongLanTooltip", UIParent, "GameTooltipTemplate") -- 用于装等获取

-- 游戏按键设置
BINDING_HEADER_ZONGLAN                      = "ZongLan"
BINDING_NAME_ZONGLAN_ROLEOVERVIEW           = L["打开/关闭角色总览"]

ZL.blackListPlayer                          = {
}
if ZL.blackListPlayer[realmID] and ZL.blackListPlayer[realmID][ZL.playerName] then
end

ns.Interface = "Interface\\AddOns\\" .. AddonName .. "\\"

-- 全局变量
do
    ZL.Movetable = {}
    ZL.options = {}
    ZL.itemCaches = {}
    ZL.dropDown = LibBG:Create_UIDropDownMenu(nil, UIParent)
    ZL.onEnterAlpha = 0.1
    ZL.highLightAlpha = 0.2
    ZL.otherEditAlpha = 0.3
    ZL.scrollStep = 80
    ZL.borderAlpha = .5
    ZL.ver = "v" .. GetAddOnMetadata(AddonName, "Version")
    ZL.rareIcon = "|A:nameplates-icon-elite-silver:0:0|a"
    ZL.iconTexCoord = { .07, .93, .07, .93 }
    ZL.fakuanIsFirst = {}
    ZL.editTemplate = "ZongLan_InputBoxTemplate" or "InputBoxTemplate"
    ZL.editSearchTemplate = "ZongLan_SearchBoxTemplate" or "SearchBoxTemplate"
    ZL.scrollTemplate = "ZongLan_ModernScrollFrameTemplate" or "UIPanelScrollFrameTemplate"
    ZL.notLootBossIDs = {}
    ZL.itemOnEnterDelay = 0.02
    ZL.addonChannelCount = 10
    ZL.LastBagItemFrame = {}
    if ZL.IsRetail then
        ZL.CloseButtonOffset = 0
    else
        ZL.CloseButtonOffset = 2
    end
end

-- 初始化
do
    -- 基础信息
    do
        if ZL.IsVanilla_Sod then
            ZL.FB1 = "MCsod"
            ZL.fullLevel = 60
            ZL.fullLevel_RoleOverview = 25
        end
        if ZL.IsVanilla_60 then
            ZL.fullLevel = 60
            ZL.fullLevel_RoleOverview = 35
        end
        if ZL.IsTBC then
            ZL.fullLevel = 70
            ZL.fullLevel_RoleOverview = 35
        end
        if ZL.IsWLK_80 then
            ZL.fullLevel = 80
            ZL.fullLevel_RoleOverview = 60
        end
        if ZL.IsTitan then
            ZL.fullLevel = 80
            ZL.fullLevel_RoleOverview = 60
        end
        if ZL.IsCTM then
            ZL.fullLevel = 85
            ZL.fullLevel_RoleOverview = 70
        end
        if ZL.IsMOP then
            ZL.fullLevel = 90
            ZL.fullLevel_RoleOverview = 80
            ZL.worldBossID = { 32098, 32099, 32518, 32519, 33117, 33118, } -- 炮舰 怒之煞 暴风领主纳拉克 乌达斯塔 四天神 野牛人
        end
        if ZL.IsRetail then
            ZL.fullLevel = 90
            ZL.fullLevel_RoleOverview = 80
        end
    end

    -- 颜色
    do
        ZL.b1 = "00BFFF"
        function ZL.STC_b1(text)
            if text then
                local t
                t = "|cff" .. "00BFFF" .. text .. "|r"
                return t
            end
        end

        ZL.r1 = "FF0000"
        function ZL.STC_r1(text)
            if text then
                local t
                t = "|cff" .. "FF0000" .. text .. "|r"
                return t
            end
        end

        ZL.r2 = "FF1493"
        function ZL.STC_r2(text)
            if text then
                local t
                t = "|cff" .. "FF1493" .. text .. "|r"
                return t
            end
        end

        ZL.r3 = "FF69B4"
        function ZL.STC_r3(text)
            if text then
                local t
                t = "|cff" .. "FF69B4" .. text .. "|r"
                return t
            end
        end

        ZL.g1 = "00FF00"
        function ZL.STC_g1(text)
            if text then
                local t
                t = "|cff" .. "00FF00" .. text .. "|r"
                return t
            end
        end

        ZL.g2 = "40c040"
        function ZL.STC_g2(text)
            if text then
                local t
                t = "|cff" .. "40c040" .. text .. "|r"
                return t
            end
        end

        ZL.y1 = "FFFF00"
        function ZL.STC_y1(text) -- yellow
            if text then
                local t
                t = "|cff" .. "FFFF00" .. text .. "|r"
                return t
            end
        end

        ZL.y2 = "FFD100"
        function ZL.STC_y2(text) -- gold
            if text then
                local t
                t = "|cff" .. "FFD100" .. text .. "|r"
                return t
            end
        end

        ZL.w1 = "FFFFFF"
        function ZL.STC_w1(text) -- 白色
            if text then
                local t
                t = "|cff" .. "FFFFFF" .. text .. "|r"
                return t
            end
        end

        ZL.dis = "808080"
        function ZL.STC_dis(text) -- 灰色
            if text then
                local t
                t = "|cff" .. "808080" .. text .. "|r"
                return t
            end
        end
    end

    -- 声音
    do
        ZL.sound1 = SOUNDKIT.GS_TITLE_OPTION_OK -- 按键音效
        ZL.sound2 = 569593                      -- 升级音效
        ZL.sound3 = SOUNDKIT.IG_MAINMENU_CLOSE  -- 菜单打开音效

        local Interface = ns.Interface .. "Media\\sound\\"
        ZL.soundAuthor = {
            { ID = "AI", addonName = AddonName, isBiaoGe = true },
        }
        ZL.soundTbl = ZL.soundAuthor
        ZL.soundTbl2 = {
            { ID = "alchemyReady", name = "炼金转化已就绪" },
            { ID = "tailorReady", name = "裁缝洗布已就绪" },
            { ID = "leatherworkingReady", name = "制皮筛盐已就绪" },
        }
        --[[
/run ZL.PlaySound("paimai")
/run ZL.PlaySound("hope")
]]
        local function DefaultSound()
            for i = 1, C_AddOns.GetNumAddOns() do
                local addonName = C_AddOns.GetAddOnInfo(i)
                local enabled = C_AddOns.GetAddOnEnableState(i, player)
                if C_AddOns.GetAddOnMetadata(i, "X-BiaoGe-Voice") and enabled ~= 0 then
                    local author = C_AddOns.GetAddOnMetadata(i, "Author")
                    tinsert(ZL.soundAuthor, { ID = author, addonName = addonName })
                end
            end
            for _, value in ipairs(ZL.soundAuthor) do
                local author = value.ID
                local addonName = value.addonName
                local isBiaoGe = value.isBiaoGe
                for _, v in ipairs(ZL.soundTbl2) do
                    local soundID = v.ID
                    local soundName = v.name
                    if isBiaoGe then
                        ZL["sound_" .. soundID .. author] = Interface .. author .. "\\" .. soundID
                    else
                        ZL["sound_" .. soundID .. author] = format("Interface\\AddOns\\%s\\sound\\%s", addonName, soundName)
                    end
                end
            end

            local yes
            for i, v in ipairs(ZL.soundAuthor) do
                if ZongLan.options.Sound == v.ID then
                    yes = true
                end
            end
            if not yes then
                ZongLan.options.Sound = "AI"
            end
        end

        ZL.Init2(function()
            DefaultSound()
        end)
    end

    ZL.classColorNames = {}
    for i = 1, GetNumClasses() do
        local className, classFilename = GetClassInfo(i)
        if className then
            local color = select(4, GetClassColor(classFilename))
            ZL.classColorNames[className] = format("|c%s%s|r", color, className)
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
ZL.Init(function()
    if type(ZongLan) ~= "table" then
        ZongLan = {}
    end
    if not ZongLan.point then
        ZongLan.point = {}
    end

    if not ZongLan.options then
        ZongLan.options = {}
    end
    
    if not ZongLan.options.SearchHistory then
        ZongLan.options.SearchHistory = {}
    end

    -- 记录服务器名称
    do
        ZongLan.realmName = ZongLan.realmName or {}
        ZongLan.realmName[realmID] = realmName
    end
    -- 记录每个角色的职业、等级、天赋
    do
        ZongLan.playerInfo = ZongLan.playerInfo or {}
        ZongLan.playerInfo[realmID] = ZongLan.playerInfo[realmID] or {}
        ZongLan.playerInfo[realmID][player] = ZongLan.playerInfo[realmID][player] or {}
        ZongLan.playerInfo[realmID][player].class = select(2, UnitClass("player"))
        ZongLan.playerInfo[realmID][player].raceID = select(3, UnitRace("player"))
        ZongLan.playerInfo[realmID][player].faction = UnitFactionGroup("player")
        ZongLan.playerInfo[realmID][player].iLevel = select(2, GetAverageItemLevel()) or 0

        local function UpdateLevel(level)
            ZongLan.playerInfo[realmID][player].level = level
            ZL.isFullLevel = level >= ZL.fullLevel
        end
        UpdateLevel(UnitLevel("player"))
        ZL.RegisterEvent("PLAYER_LEVEL_UP", function(self, event, level)
            UpdateLevel(level)
            if ZL.UpdateMeetingHornLevelButton then
                ZL.UpdateMeetingHornLevelButton()
            end
        end)

        -- 天赋
        do
            local function GetTalent(_, event)
                local specIndex
                if ZL.verOver4 then
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
                ZongLan.playerInfo[realmID][player].talent = specIndex
            end

            local f = CreateFrame("Frame")
            f:RegisterEvent("PLAYER_TALENT_UPDATE")
            f:RegisterEvent("PLAYER_ENTERING_WORLD")
            if ZL.verOver4 then
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

            function ZL.GetTalentIcon(class, talent, w)
                w = w or 0
                if talent then
                    local a, b, c, d = unpack(ZL.iconTexCoord)
                    local coord = format("100:100:%s:%s:%s:%s", a * 100, b * 100, c * 100, d * 100)
                    local tex = ZL.talentIcon[class][talent]
                    if tex then
                        return format("|T%s:%s:%s:0:0:%s|t", ZL.talentIcon[class][talent], w, w, coord)
                    end
                end
                return format("|A:GarrMission_ClassIcon-%s:%s:%s|a", class, w, w)
            end

            ZL.talentIcon = {
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
            if ZL.verOver4 then
                ZL.talentIcon.DRUID = {
                    "Interface\\Icons\\spell_nature_starfall",     -- 鸟
                    "Interface\\Icons\\ability_druid_catform",     -- 猫
                    "Interface\\Icons\\ability_racial_bearform",   -- 熊
                    "Interface\\Icons\\Spell_Nature_HealingTouch", -- N
                }
            else
                ZL.talentIcon.DRUID = {
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
        ZongLan.font = ZongLan.font or default

        local t = UIParent:CreateFontString()
        t:SetFont(format("Fonts\\%s", ZongLan.font), 15, "OUTLINE")
        t:Hide()
        if not t:GetFont() then
            ZongLan.font = default
        end
        ns.Font = format("Fonts\\%s", ZongLan.font)

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
        ZL.fontList = list

        local name = "editFontSize"
        ZongLan.options[name] = ZongLan.options[name] or 14
        function ZongLan_InputBoxTemplate_OnLoad(self)
            self:SetFont(ns.Font, ZongLan.options[name], "OUTLINE")
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
            ZL["Font" .. color .. size] = CreateFont("ZL.Font" .. color .. size)
            ZL["Font" .. color .. size]:SetTextColor(RGB(cff))
            ZL["Font" .. color .. size]:SetFont(ns.Font, size, "OUTLINE")
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
SlashCmdList["ZongLanRoleOverview"] = function()
    ZL.SetFBCD(nil, nil, true)
end
SLASH_ZongLanRoleOverview1 = "/zl"
SLASH_ZongLanRoleOverview2 = "/zonglan"

SlashCmdList["ZongLanRoleOverviewError"] = function()
    C_Timer.After(0, function()
        ChatEdit_ActivateChat(ChatEdit_ChooseBoxForSend())
        ChatEdit_ChooseBoxForSend():SetText("https://docs.qq.com/doc/DYVFDaU5uR21sanJm")
        ChatEdit_ChooseBoxForSend():HighlightText()
    end)
end
SLASH_ZongLanRoleOverviewError1 = "/zle"
