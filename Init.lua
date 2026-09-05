local AddonName, ns = ...

local L = ns.L
ns.GetClassColor = GetClassColor
local GetClassColor = ns.GetClassColor

local pt = print

local RR = "|r"
ns.RR = RR
local NN = "\n"
ns.NN = NN
local RN = "|r\n"
ns.RN = RN

ZL = {}

----------tbl元素个数----------
local function Size(t)
    local s = 0
    for k, v in pairs(t) do
        if v ~= nil then s = s + 1 end
    end
    return s
end
ns.Size = Size

----------把16进制颜色转换成0-1RGB----------
local function RGB(hex, Alpha)
    local red = hex:sub(1, 2)
    local green = hex:sub(3, 4)
    local blue = hex:sub(5, 6)

    red = tonumber(red, 16) / 255
    green = tonumber(green, 16) / 255
    blue = tonumber(blue, 16) / 255

    if Alpha then
        return red, green, blue, Alpha
    else
        return red, green, blue
    end
end
ns.RGB = RGB

----------DB_Loot插入职业任务文本----------
local function ClassQuest(classID)
    local className, classFile, classID = GetClassInfo(classID)
    local color = select(4, GetClassColor(classFile))
    return "|c" .. color .. className .. "|r" .. ZL.STC_y1(QUESTS_LABEL)
end
ns.ClassQuest = ClassQuest


-- 注册事件
do
    local addonLoadedFuncs = {}
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, event, addonName)
        if addonName ~= AddonName then return end
        self:UnregisterEvent("ADDON_LOADED")
        for _, func in ipairs(addonLoadedFuncs) do
            securecall(func)
        end
    end)
    function ZL.Init(func)
        tinsert(addonLoadedFuncs, func)
    end

    local enterWorldFuncs = {}
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function(self, event, ...)
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        for _, func in ipairs(enterWorldFuncs) do
            securecall(func)
        end
    end)
    function ZL.Init2(func)
        tinsert(enterWorldFuncs, func)
    end

    local loginFuncs = {}
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function(self, event)
        self:UnregisterEvent("PLAYER_LOGIN")
        for _, func in ipairs(loginFuncs) do
            securecall(func)
        end
    end)
    function ZL.Init3(func)
        tinsert(loginFuncs, func)
    end

    local events = {}
    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", function(_, event, ...)
        for _, func in ipairs(events[event]) do
            if event == "COMBAT_LOG_EVENT_UNFILTERED" then
                securecall(func, f, event, CombatLogGetCurrentEventInfo())
            else
                securecall(func, f, event, ...)
            end
        end
    end)
    local function RegisterOneEvent(event, func)
        if not events[event] then
            events[event] = {}
            f:RegisterEvent(event)
        end
        tinsert(events[event], func)
    end
    function ZL.RegisterEvent(event, func)
        if type(event) == "table" then
            for _, e in ipairs(event) do
                RegisterOneEvent(e, func)
            end
        else
            RegisterOneEvent(event, func)
        end
    end
end

-- 版本号
if GetCurrentRegion() ~= 5 then
    ZL.IsTW = true
end

local ver = select(4, GetBuildInfo())
if ver < 30000 then
    ZL.verLess2 = true
end
if ver >= 30000 then
    ZL.verOver3 = true
end
if ver >= 40000 then
    ZL.verOver4 = true
else
    ZL.verLess3 = true
end
if ver >= 50000 then
    ZL.verOver5 = true
else
    ZL.verLess4 = true
end

if ver < 20000 then
    ZL.IsVanilla = true
    ZL.onlyOneHard = true
    if (C_Engraving and C_Engraving.IsEngravingEnabled()) then
        ZL.IsVanilla_Sod = true
    else
        ZL.IsVanilla_60 = true
    end
end

if ver >= 20000 and ver < 30000 then
    ZL.IsTBC = true
    ZL.onlyOneHard = true
end

if ver >= 30000 and ver < 40000 then
    ZL.IsWLK = true
    if ver >= 38000 then
        ZL.IsTitan = true
        ZL.onlyOneHard = true
    else
        ZL.IsWLK_80 = true
    end
end

if ver >= 40000 and ver < 50000 then
    ZL.IsCTM = true
end

if ver >= 50000 and ver < 60000 then
    ZL.IsMOP = true
    if ZL.IsTW then
        ZL.IsMOP_TW = true
    else
        ZL.IsMOP_CN = true
    end
    -- ZL.IsTW = true
    -- ZL.IsMOP_TW = true
    -- ZL.IsMOP_CN = nil
end

if ver >= 110000 then
    ZL.IsRetail = true
end

ZL.IsNewUI = true


function ZL.IsWLKFB(FB)
    local FB = FB or ZL.FB1
    if (FB == "NAXX" and not ZL.IsVanilla) or FB == "ULD" or FB == "TOC" or FB == "ICC" then
        return true
    end
end

local tbl = { "SW", "BT", "HS", "TK", "SSC", "ZA", "KZ", "BWL", "TAQ", }
function ZL.IsTBCFB(FB)
    if not ZL.IsWLK then return false end
    local FB = FB or ZL.FB1
    for _, _FB in ipairs(tbl) do
        if FB == _FB then
            return true
        end
    end
end

-- 阵营
if UnitFactionGroup("player") == "Alliance" then
    ZL.IsAlliance = true
end

if UnitFactionGroup("player") == "Horde" then
    ZL.IsHorde = true
end

function ZL.GN(unit)
    unit = unit or "player"
    if unit == "t" then
        unit = "target"
    end
    return GetUnitName(unit, true)
end

ZL.playerName = ZL.GN()
ZL.realmName = GetRealmName():gsub(" ", ""):gsub("%-", "")
ZL.realmID = GetRealmID()

function ZL.GFN(name)
    if not name then return end
    local name, realm = strsplit("-", name)
    realm = realm or ZL.realmName
    return name .. "-" .. realm
end

function ZL.GSN(name)
    if not name then return end
    local name, realm = strsplit("-", name)
    if not realm or realm == "" or realm == ZL.realmName then
        return name
    else
        return name .. "-" .. realm
    end
end

function ZL.SPN(name)
    if not name then return end
    if ZL.IsSecret(name) then return end
    return strsplit("-", name, 2)
end

-- 增加节日掉落
function ZL.AddHolidayLoot(lootInfo)
    ZL.hasHolidayLoot = true
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
    f:SetScript("OnEvent", function(self, event, isLogin, isReload)
        if event == "PLAYER_ENTERING_WORLD" then
            if isLogin then
                return
            else
                self:UnregisterEvent("PLAYER_ENTERING_WORLD")
            end
        end

        local all = {}

        local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
        local day = currentCalendarTime.monthDay
        local numEvents = C_Calendar.GetNumDayEvents(0, day)
        if numEvents <= 0 then
            return
        end

        for i = 1, numEvents do
            local event = C_Calendar.GetDayEvent(0, day, i)
            if event and lootInfo[event.eventID] then
                ZL.hasHoliday = true
                tinsert(all, lootInfo[event.eventID])
            end
        end

        for _, FB in pairs(ZL.FBtable) do
            ZL.Loot[FB].Holiday = all
        end

        if ZL.hasHoliday then
            ZL.InitHoliday()
        end
    end)
end

-- 特殊兑换物
function ZL.InsertExLoot(FB, tbl)
    for exItem, loot in pairs(tbl) do
        ZL.Loot[FB].ExchangeItems[exItem] = ZL.Loot[FB].ExchangeItems[exItem] or {}
        for _, itemID in pairs(loot.items) do
            tinsert(ZL.Loot[FB].ExchangeItems[exItem], itemID)
            for _, bossInfo in pairs(loot.boss) do
                local boss, hard = strsplit("-", bossInfo)
                ZL.Loot[FB][hard]["boss" .. boss .. "other"] =
                    ZL.Loot[FB][hard]["boss" .. boss .. "other"] or {}
                tinsert(ZL.Loot[FB][hard]["boss" .. boss .. "other"], itemID)
            end
        end
    end
end

-- 套装相关
function ZL.InsertSetLoot(FB, tbl)
    for boss, loot in pairs(tbl) do
        for hard, _loot in pairs(loot) do
            ZL.Loot[FB][hard]["boss" .. boss .. "other"] =
                ZL.Loot[FB][hard]["boss" .. boss .. "other"] or {}
            for exItemID, items in pairs(_loot) do
                ZL.Loot[FB].ExchangeItems[exItemID] = items
                for _, itemID in pairs(items) do
                    tinsert(ZL.Loot[FB][hard]["boss" .. boss .. "other"], itemID)
                end
            end
        end
    end
end
