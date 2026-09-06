local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L
local GetClassColor = ns.GetClassColor

local Maxb = ns.Maxb
local HopeMaxn = ns.HopeMaxn
local HopeMaxb = ns.HopeMaxb
local HopeMaxi = ns.HopeMaxi
local RGB = ns.RGB

local pt = print
local RealmID = GetRealmID()
local player = ZL.playerName
ZL.After = C_Timer.After

------------------函数：四舍五入------------------ 数字，小数点数
local function Round(number, decimal_places)
    local mult = 10 ^ (decimal_places or 0)
    return math.floor(number * mult + 0.5) / mult
end
ns.Round = Round

------------------函数：设置颜色（0-1代码变为16进制颜色）------------------
local function RGB_16(name, r, g, b)
    if not r then
        r, g, b = name:GetTextColor()
        name = name:GetText()
    end

    local r = string.format("%X", tonumber(r) * 255)
    if r and strlen(r) == 1 then
        r = "0" .. r
    end
    local g = string.format("%X", tonumber(g) * 255)
    if g and strlen(g) == 1 then
        g = "0" .. g
    end
    local b = string.format("%X", tonumber(b) * 255)
    if b and strlen(b) == 1 then
        b = "0" .. b
    end
    local c = r .. g .. b

    if name then
        return "|cff" .. c .. name .. "|r"
    else
        return c
    end
end
ns.RGB_16 = RGB_16

------------------在文本里插入材质图标------------------
local function AddTexture(Texture, y, coord, width)
    if not Texture then
        return ""
    end
    local x = 0
    if not y then
        y = "-0"
    end
    local tex = ""
    local coord = coord or ""
    if Texture == "MAINTANK" then                      -- 主坦克
        tex = "132064"
    elseif Texture == "MAINASSIST" then                -- 主助理
        tex = "132063"
    elseif Texture == "TANK" then                      -- 坦克职责
        return "|A:ui-lfg-roleicon-tank:0:0|a"
    elseif Texture == "HEALER" then                    -- 治疗职责
        return "|A:ui-lfg-roleicon-healer:0:0|a"
    elseif Texture == "DAMAGER" then                   -- 输出职责
        return "|A:ui-lfg-roleicon-dps:0:0|a"
    elseif Texture == 137000 or Texture == 136998 then -- 战场荣誉
        coord = ":100:100:10:60:0:55"
        local t = "|T" .. Texture .. ":0:0:0:0" .. coord .. "|t"
        return t
    elseif Texture == "QUEST" then -- 黄色感叹号
        tex = "Interface\\GossipFrame\\AvailableQuestIcon"
    elseif Texture == "logo" then
        tex = ns.Interface .. "Media\\icon\\icon.png"
    elseif Texture == "LEFT" then
        return "|A:NPE_LeftClick:0:0|a"
    elseif Texture == "RIGHT" then
        return "|A:NPE_RightClick:0:0|a"
    else
        tex = Texture
    end
    width = width or 0
    return "|T" .. tex .. ":" .. width .. ":" .. width .. ":" .. x .. ":" .. y .. coord .. "|t"
end
ns.AddTexture = AddTexture

local classNameTbl = {
    WARRIOR = GetClassInfo(1),
    PALADIN = GetClassInfo(2),
    HUNTER = GetClassInfo(3),
    ROGUE = GetClassInfo(4),
    PRIEST = GetClassInfo(5),
    DEATHKNIGHT = GetClassInfo(6),
    SHAMAN = GetClassInfo(7),
    MAGE = GetClassInfo(8),
    WARLOCK = GetClassInfo(9),
    MONK = GetClassInfo(10),
    DRUID = GetClassInfo(11),
    DEMONHUNTER = GetClassInfo(12),
    EVOKER = GetClassInfo(13),
}
local function GetClassName(classFile)
    return classNameTbl[classFile]
end
ns.GetClassName = GetClassName

------------------获取文字（删掉材质）------------------
local function GetText_T(bt)
    local text
    if type(bt) == "table" then
        text = bt:GetText()
    else
        text = bt
    end
    local t = text:gsub("|T.-|t", ""):gsub("|A.-|a", "")
    return t
end
ns.GetText_T = GetText_T

------------------函数：获取名字的职业颜色RGB------------------
local function GetClassRGB(name, player, Alpha)
    local _, class
    if player then
        _, class = UnitClass(player)
    else
        _, class = UnitClass(ZL.GSN(name))
    end
    local c1, c2, c3 = 1, 1, 1
    if class then
        c1, c2, c3 = GetClassColor(class)
    end
    return c1, c2, c3, Alpha
end
ns.GetClassRGB = GetClassRGB

------------------函数：设置名字为职业颜色CFF代码（|cffFFFFFF名字|r）------------------
local function SetClassCFF(name, player, type)
    if type then return name end
    local _, class
    if player then
        _, class = UnitClass(player)
    else
        _, class = UnitClass(ZL.GSN(name))
    end
    if class then
        local color = select(4, GetClassColor(class))
        return "|c" .. color .. name .. "|r"
    else
        return name
    end
end
ns.SetClassCFF = SetClassCFF

------------------函数：仅提取链接文本------------------
local function GetItemID(text)
    if not text then return end
    return tonumber(text:match("item:(%d+):"))
end
ns.GetItemID = GetItemID

------------------隐藏提示工具------------------
local function GameTooltip_Hide()
    GameTooltip:Hide()
end
function ZL.GameTooltip_Hide(frame)
    frame:SetScript("OnLeave", GameTooltip_Hide)
end

------------------隐藏全部Tab按钮------------------
function ZL.HideTab(Buttons, Show)
    for i, v in ipairs(Buttons) do
        v:Hide()
        v:GetParent():SetEnabled(true)
    end
    Show:Show()
    Show:GetParent():SetEnabled(false)
end

------------------计时器------------------
function ZL.OnUpdateTime(func)
    local updateFrame = CreateFrame("Frame")
    updateFrame.timeElapsed = 0
    updateFrame:SetScript("OnUpdate", func)
    return updateFrame
end

--[[
ZL.OnUpdateTime(function(self,elapsed)
    self.timeElapsed=self.timeElapsed+elapsed
    if self.timeElapsed then
        self:SetScript("OnUpdate",nil)
        self:Hide()
    end
end)
 ]]

------------------菜单：点文本也能打开菜单------------------
function ZL.dropDownToggle(dropDown)
    dropDown:SetScript("OnMouseDown", function(self)
        if dropDown.isDisabled then return end
        LibBG:ToggleDropDownMenu(nil, nil, self)
        ZL.PlaySound(1)
    end)
    ZL.SkinDropDown(dropDown)
end

------------------是国服或亚服吗------------------
function ZL.IsCN()
    if GetCurrentRegionName() == "CN" or GetCurrentRegionName() == "TW" or GetCurrentRegionName() == "KR" then
        return true
    end
end

------------------按键声音------------------
function ZL.PlaySound(id)
    if ZongLan.options['buttonSound'] == 1 and type(id) == "number" then
        if ZL["sound" .. id] then
            if id == 2 then
                PlaySoundFile(ZL["sound" .. id])
            else
                PlaySound(ZL["sound" .. id])
            end
        end
    elseif ZongLan.options['tipsSound'] == 1 and type(id) == "string" then
        if ZL["sound_" .. id .. ZongLan.options.Sound] then
            if not PlaySoundFile(ZL["sound_" .. id .. ZongLan.options.Sound] .. ".mp3", "Master") then
                if not PlaySoundFile(ZL["sound_" .. id .. ZongLan.options.Sound] .. ".ogg", "Master") then
                    if ZL["sound_" .. id .. "AI"] then
                        PlaySoundFile(ZL["sound_" .. id .. "AI"] .. ".mp3", "Master")
                        PlaySoundFile(ZL["sound_" .. id .. "AI"] .. ".ogg", "Master")
                    end
                end
            end
        end
    end
end

------------------按钮的文本截断------------------
function ZL.ButtonTextSetWordWrap(bt)
    local t = bt:GetFontString()
    t:SetWidth(bt:GetWidth())
    t:SetWordWrap(false)
end

----------高亮按钮----------
function ZL.SetTextHighlightTexture(bt)
    local tex = bt:CreateTexture()
    tex:SetPoint("TOPLEFT", bt, "TOPLEFT", -8, 0)
    tex:SetPoint("BOTTOMRIGHT", bt, "BOTTOMRIGHT", 8, 0)
    tex:SetTexture("Interface/PaperDollInfoFrame/UI-Character-Tab-Highlight")
    bt:SetHighlightTexture(tex)
end

----------鼠标/按钮是否在右边----------
do
    function ZL.ButtonIsInRight(self)
        if self:GetCenter() > UIParent:GetWidth() * 0.5 then
            return true
        end
    end

    function ZL.ButtonIsInTop(self)
        if self:GetTop() > UIParent:GetHeight() * 0.5 then
            return true
        end
    end
end

----------把time转换为时或分----------
function ZL.SecondsToTime(second, short)
    local h = floor(second / 3600)
    if h >= 1 then
        return h .. (short and "h" or L["小时"])
    end

    local m = floor(second / 60)
    if m >= 1 then
        return m .. (short and 'm' or L["分钟"])
    end

    local s = floor(second)
    if s then
        return s .. (short and 's' or L["秒"])
    end
end

----------是否已经拥有某物品----------
function ZL.GetItemCount(itemIDorLink)
    local itemID = itemIDorLink
    if not tonumber(itemIDorLink) then
        itemID = tonumber(itemIDorLink:match("item:(%d+)"))
    end
    for _, FB in pairs(ZL.FBtable) do
        local items = ZL.Loot[FB].ExchangeItems[itemID]
        if items then
            for _, itemID3 in ipairs(items) do
                local count = GetItemCount(itemID3, true)
                if count ~= 0 then
                    return count
                end
            end
        end
    end
    return GetItemCount(itemID, true)
end

function ZL.SendSystemMessage(msg)
    SendSystemMessage(ZL.STC_b1("<" .. AddonName .. ">") .. " " .. msg)
end

ns.SendSystemMessage = ZL.SendSystemMessage

function ZL.FormatNumber(num, type)
    if not tonumber(num) or num % 1 ~= 0 then return num end
    num = tonumber(num)
    type = type or 1
    if type == 0 or type == 5 then -- 添加分隔符
        local formatted = tostring(num)
        formatted = formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
        return formatted
    end
    if ns.enUS then
        if type == 1 then
            if num >= 1000000 then
                return format("%.1fm", floor(num / 1000000 * 10) / 10)
            elseif num >= 1000 then
                return format("%.1fk", floor(num / 1000 * 10) / 10)
            else
                return num
            end
        elseif type == 2 then -- 添加分隔符
            local formatted = tostring(num)
            formatted = formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
            return formatted
        elseif type == 3 then
            if num >= 1000000 then
                return format("%.1fm", floor(num / 1000000 * 10) / 10)
            elseif num >= 10000 then
                return format("%dk", floor(num / 1000 * 10) / 10)
            elseif num >= 1000 then
                return format("%.1fk", floor(num / 1000 * 10) / 10)
            else
                return num
            end
        end
    else
        if type == 1 then -- 省略百十个位
            if num >= 10000 then
                return format(L["%.1f万"], floor(num / 10000 * 10) / 10)
            else
                return num
            end
        elseif type == 2 then -- 输出所有小数点
            if num >= 10000 then
                local wanNum = num / 10000
                if num % 10000 == 0 then
                    return format("%d" .. L["万"], wanNum)
                elseif num % 1000 == 0 then
                    return format("%.1f" .. L["万"], wanNum)
                elseif num % 100 == 0 then
                    return format("%.2f" .. L["万"], wanNum)
                elseif num % 10 == 0 then
                    return format("%.3f" .. L["万"], wanNum)
                else
                    return format("%.4f" .. L["万"], wanNum)
                end
            else
                return num
            end
        elseif type == 3 then -- 省略十个位
            if num >= 10000 then
                return format(L["%.1f万"], floor(num / 10000 * 10) / 10)
            elseif num >= 1000 then
                return format(L["%.1fk"], floor(num / 1000 * 10) / 10)
            else
                return num
            end
        end
    end
    return num
end

function ZL.Copy(table)
    if type(table) == "table" then
        local t = {}
        for k, v in pairs(table) do
            if type(v) == "table" then
                t[k] = ZL.Copy(v) -- 递归拷贝子表
            else
                t[k] = v
            end
        end
        return t
    else
        return table
    end
end

local info = {
    "Hope",
    "FilterClassItemDB",
    "filterClassNum",
    "MeetingHorn",
    "MeetingHornWhisper",
    "FBCD",
    "RaidCD",
    "QuestCD",
    "Money",
    "MONEY",
    "tradeSkillCooldown",
    "PlayerItemsLevel",
    "playerInfo",
    "equip",
    "bag",
    "worldBossCD",
    "roleOverviewNote",
    "buffCD",
    "legendaryCloak",
    "bestPrice",
    "mailHistory",
    "tradeHistory",
    "lastChooseLFD",
    -- "",
}
function ZL.DeletePlayerData(realmID, player)
    for _, key in pairs(info) do
        if ZongLan[key] and ZongLan[key][realmID] then
            ZongLan[key][realmID][player] = nil
        end
    end
    local sortDB = ZongLan.RoleOverviewSort and ZongLan.RoleOverviewSort[realmID]
    if sortDB then
        for i = #sortDB, 1, -1 do
            if sortDB[i].player == player then
                tremove(sortDB, i)
            end
        end
    end
end

function ZL.GetSpecID()
    return GetSpecializationInfo(GetSpecialization())
end

function ZL.SetSpecIDToLink(link)
    if ZL.IsRetail then
        local k = link:match("item:%d+:[%d-:]+")
        local _, s = k:find("item:%d+:%d-:%d-:%d-:%d-:%d-:%d-:%d-:")
        local _, e = k:find("item:%d+:%d-:%d-:%d-:%d-:%d-:%d-:%d-:%d-:%d-:")
        k = k:sub(1, s) .. "80:" .. ZL.GetSpecID() .. k:sub(e, #k)
        return link:gsub("item:%d+:[%d-:]+", k)
    else
        return link
    end
end

-- function ZL.GsubLink(link1,link2)
--     return link1:gsub("(item:)%d+:[%d-:]+","%1"..link2)
-- end

function ZL.ValueInTable(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
end

function ZL.OnEnterDelay(self, func, delay, isHook)
    delay = delay or .4
    local script = isHook and self.HookScript or self.SetScript
    script(self, "OnEnter", function(self)
        self.isOnEnter = true
        if func then
            self.t = 0
            self:SetScript("OnUpdate", function(self, t)
                self.t = self.t + t
                if self.t >= delay then
                    self:SetScript("OnUpdate", nil)
                    func(self)
                end
            end)
        end
    end)
end

function ZL.OnLeaveDelay(self, func)
    self:SetScript("OnLeave", function(self)
        self.isOnEnter = false
        self:SetScript("OnUpdate", nil)
        GameTooltip:Hide()
        if func then
            func(self)
        end
    end)
end

function ZL.IsMe(realmID, player)
    return realmID == ZL.realmID and player == ZL.playerName
end

function ZL.GetNextWeekTime() -- 距离下周四还有多少秒
    local resetDay = 2
    if ZL.IsCN() then
        resetDay = 4
    end

    local currentTimestamp = GetServerTime()
    local currentWeekday = date("%w", currentTimestamp)
    local daysToThursday = resetDay - currentWeekday
    local nextThursdayTimestamp

    local today = date("*t", currentTimestamp)
    if daysToThursday == 0 and today.hour < 7 then
        -- 如果时间小于当天凌晨7点
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
    return nextThursdayTimestamp - currentTimestamp, nextThursdayTimestamp
end

function ZL.GetNextDayTime() -- 距离明天7点还有多少秒
    local currentTimestamp = GetServerTime()
    local tomorrow7amTimestamp
    local today = date("*t", currentTimestamp)
    -- 如果时间小于当天凌晨7点
    if today.hour < 7 then
        today.hour = 7
        today.min = 0
        today.sec = 0
        tomorrow7amTimestamp = time(today)
    else
        -- 获取明天凌晨7点的时间戳
        local tomorrow = date("*t", currentTimestamp + 86400) -- 加上一天的秒数
        tomorrow.hour = 7
        tomorrow.min = 0
        tomorrow.sec = 0
        tomorrow7amTimestamp = time(tomorrow)
    end
    return tomorrow7amTimestamp - currentTimestamp, tomorrow7amTimestamp
end

function ZL.SetMixin(f, mixin)
    if type(f) == "table" then
        for k, v in pairs(mixin) do
            if f.HasScript and f:HasScript(k) then
                f:SetScript(k, v)
            else
                f[k] = v
            end
        end
    end
end

function ZL.CreateCloseButton(f, x, y, point)
    f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.CloseButton:SetPoint(point or "TOPRIGHT", x or ZL.IsRetail and 0 or 5, y or ZL.IsRetail and 0 or 5)
    f.CloseButton:SetScript("OnClick", function(self)
        f:Hide()
    end)
end

function ZL.GetDiffShortName(diff)
    if diff == 14 then
        return "|cff00BFFFN|r"
    elseif diff == 15 then
        return "|cffFF0000H|r"
    elseif diff == 16 then
        return "|cffa335eeM|r"
    end
end

function ZL.IsSecret(value)
    return issecretvalue and value and issecretvalue(value)
end

-- 创建右下角可拖动的缩放按钮
do
    local btMixin = {}
    local ag = 0.002 -- 灵敏度可调整
    local function SetValue(optionName, newScale)
        ZongLan.options[optionName] = newScale
        ZL.options["button" .. optionName]:SetValue(newScale)
        if ZL.options["button" .. optionName].edit then
            ZL.options["button" .. optionName].edit:SetText(newScale)
        end
    end
    function btMixin:OnMouseDown(btn)
        if btn == "LeftButton" then
            self.isDragging = true
            self.startX = GetCursorPosition()
            self.startScale = self:GetParent():GetScale()
        elseif btn == "RightButton" then
            local newScale = ZL.options[self.optionName .. "reset"]
            self:GetParent():SetScale(newScale)
            SetValue(self.optionName, newScale)
        end
    end

    function btMixin:OnMouseUp()
        self.isDragging = false
    end

    function btMixin:OnUpdate()
        if not self.isDragging then return end
        local uiScale = UIParent:GetScale()
        local curX = GetCursorPosition()
        local deltaX = (curX - self.startX) / uiScale
        local newScale = self.startScale + deltaX * ag
        newScale = format("%.3f", math.max(self.minValue, math.min(newScale, self.maxValue)))
        self:GetParent():SetScale(newScale)
        SetValue(self.optionName, newScale)
    end

    function ZL.CreateFrameResizeHandle(parent, optionName, minValue, maxValue, size, x, y)
        size = size or 20
        x = x or 0
        y = y or 0
        local bt = CreateFrame("Button", nil, parent)
        bt:SetSize(size, size)
        bt:SetPoint("BOTTOMRIGHT", x, y)
        bt:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        bt:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        bt:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        bt.optionName = optionName
        bt.minValue = minValue
        bt.maxValue = maxValue
        ZL.SetMixin(bt, btMixin)
        return bt
    end
end

------------------复原一个设置------------------
function ZL.Once(name, dt, func)
    if ZongLan and ZongLan.options and ZongLan.options.SearchHistory then
        if not ZongLan.options.SearchHistory[name .. dt] then
            func()
            ZongLan.options.SearchHistory[name .. dt] = true
        end
    end
end

------------------创建滚动框------------------
do
    function ZL.CreateScrollFrame(parent, w, h, isEdit, alwaysHide)
        local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        f:SetBackdropColor(0, 0, 0, 0.8)
        f:SetBackdropBorderColor(0, 0, 0, 0)
        if w and h then
            f:SetSize(w, h)
        end
        f:EnableMouse(true)

        local scroll = CreateFrame("ScrollFrame", nil, f, ZL.scrollTemplate)
        scroll:SetWidth(f:GetWidth() - 31)
        scroll:SetHeight(f:GetHeight() - 9)
        scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -5)
        scroll.ScrollBar.scrollStep = ZL.scrollStep
        f.scroll = scroll
        ZL.CreateSrollBarBackdrop(scroll.ScrollBar)
        ZL.HookScrollBarShowOrHide(scroll, alwaysHide)

        local child
        if isEdit then
            child = CreateFrame("EditBox", nil, scroll)
            child:SetWidth(scroll:GetWidth())
            child:SetHeight(scroll:GetHeight())
            child:SetAutoFocus(false)
            child:EnableMouse(false)
            child:SetMultiLine(true)
            child:SetFont(ns.Font, 15, "OUTLINE")
        else
            child = CreateFrame("Frame", nil, scroll)
            child:SetWidth(scroll:GetWidth())
            child:SetHeight(scroll:GetHeight())
        end
        scroll:SetScrollChild(child)

        return f, child
    end

    function ZL.CreateSrollBarBackdrop(bar)
        if bar.ThumbButton then return end
        local tex = bar:CreateTexture()
        tex:SetPoint("TOPLEFT", bar.ScrollUpButton, -0, 0)
        tex:SetPoint("BOTTOMRIGHT", bar.ScrollDownButton, 0, -0)
        tex:SetColorTexture(0, 0, 0, 0.3)
    end

    function ZL.HookScrollBarShowOrHide(scroll, alwaysHide)
        if scroll.ScrollBar.ThumbButton then
            scroll.alwaysHideScrollBar = alwaysHide
            if scroll.ScrollBar:GetOrientation() == "HORIZONTAL" then
                ZongLan_ModernHorizontalScrollFrameTemplate_Update(scroll)
            else
                ZongLan_ModernScrollFrameTemplate_Update(scroll)
            end
            return
        end
        scroll.ScrollBar:Hide()
        scroll:HookScript("OnScrollRangeChanged", function(self, xrange, yrange)
            if alwaysHide then
                scroll.ScrollBar:Hide()
            else
                if yrange == 0 then
                    self.ScrollBar:Hide()
                else
                    self.ScrollBar:Show()
                end
            end
        end)
    end
end

------------------现代滚动框模板------------------
do
    local c1 = { .4, .4, .4, .5 }
    local c2 = { .8, .8, .8, .5 }

    local function SetModernScrollThumbButtonColor(self, color)
        self.Top:SetColorTexture(unpack(color))
        self.Middle:SetColorTexture(unpack(color))
        self.Bottom:SetColorTexture(unpack(color))
    end

    function ZongLan_ModernScrollThumbButton_UpdateShape(self)
        local textureWidth = self.textureWidth or 8
        local radius = math.min(textureWidth / 2, self:GetHeight() / 2)

        self.Top:ClearAllPoints()
        self.Top:SetSize(textureWidth, radius)
        self.Top:SetPoint("TOP")

        self.Middle:ClearAllPoints()
        self.Middle:SetWidth(textureWidth)
        self.Middle:SetPoint("TOP", 0, -radius)
        self.Middle:SetPoint("BOTTOM", 0, radius)

        self.Bottom:ClearAllPoints()
        self.Bottom:SetSize(textureWidth, radius)
        self.Bottom:SetPoint("BOTTOM")

        if self.TopMask then
            self.TopMask:ClearAllPoints()
            self.TopMask:SetSize(textureWidth, radius * 2)
            self.TopMask:SetPoint("CENTER", self.Top, "BOTTOM")

            self.BottomMask:ClearAllPoints()
            self.BottomMask:SetSize(textureWidth, radius * 2)
            self.BottomMask:SetPoint("CENTER", self.Bottom, "TOP")
        end
    end

    function ZongLan_ModernScrollThumbButton_UpdatePosition(bar)
        local thumbButton = bar.ThumbButton
        if not thumbButton then return end

        local minValue, maxValue = bar:GetMinMaxValues()
        local valueRange = maxValue - minValue
        local ratio = 0
        if valueRange > 0 then
            ratio = (bar:GetValue() - minValue) / valueRange
        end

        local travel = math.max(0, bar:GetHeight() - 4 - thumbButton:GetHeight())
        thumbButton:ClearAllPoints()
        thumbButton:SetPoint("TOP", bar, "TOP", 0, -2 - travel * ratio)
    end

    function ZongLan_ModernScrollFrameTemplate_Update(self)
        local bar = self.ScrollBar
        if not bar then return end

        local trackHeight = bar:GetHeight() - 4
        if trackHeight <= 0 then return end

        local visibleExtent
        local totalExtent
        if self.modernVisibleExtent ~= nil and self.modernTotalExtent ~= nil then
            visibleExtent = self.modernVisibleExtent
            totalExtent = self.modernTotalExtent
        else
            visibleExtent = self:GetHeight()
            totalExtent = visibleExtent + self:GetVerticalScrollRange()
        end

        local thumbHeight = trackHeight
        if totalExtent and totalExtent > 0 then
            thumbHeight = trackHeight * math.min(1, visibleExtent / totalExtent)
        end

        local minThumbHeight = self.minThumbHeight or 24
        thumbHeight = math.max(math.min(minThumbHeight, trackHeight), thumbHeight)
        thumbHeight = math.min(trackHeight, thumbHeight)
        bar:GetThumbTexture():SetHeight(thumbHeight)
        if bar.ThumbButton then
            bar.ThumbButton:SetWidth(bar:GetWidth())
            bar.ThumbButton:SetHeight(thumbHeight)
            ZongLan_ModernScrollThumbButton_UpdateShape(bar.ThumbButton)
            ZongLan_ModernScrollThumbButton_UpdatePosition(bar)
        end

        local _, maxValue = bar:GetMinMaxValues()
        local noOverflow
        if self.modernVisibleExtent ~= nil and self.modernTotalExtent ~= nil then
            noOverflow = self.modernTotalExtent <= self.modernVisibleExtent
        else
            noOverflow = maxValue <= 1
        end
        if self.alwaysHideScrollBar or noOverflow then
            bar:Hide()
        else
            bar:Show()
        end
    end

    function ZongLan_ModernScrollFrameTemplate_SetScrollExtent(self, visibleExtent, totalExtent)
        self.modernVisibleExtent = visibleExtent
        self.modernTotalExtent = totalExtent
        ZongLan_ModernScrollFrameTemplate_Update(self)
    end

    function ZongLan_ModernScrollFrameTemplate_ClearScrollExtent(self)
        self.modernVisibleExtent = nil
        self.modernTotalExtent = nil
        ZongLan_ModernScrollFrameTemplate_Update(self)
    end

    function ZongLan_ModernScrollFrameTemplate_OnLoad(self)
        self:EnableMouse(true)
        self:EnableMouseWheel(true)
        self.SetScrollExtent = ZongLan_ModernScrollFrameTemplate_SetScrollExtent
        self.ClearScrollExtent = ZongLan_ModernScrollFrameTemplate_ClearScrollExtent
        self.ScrollBar.scrollStep = ZL.scrollStep
        ZongLan_ModernScrollFrameTemplate_Update(self)
    end

    function ZongLan_ModernScrollFrameTemplate_OnScrollRangeChanged(self, xRange, yRange)
        if self.modernVisibleExtent ~= nil then
            ZongLan_ModernScrollFrameTemplate_Update(self)
            return
        end

        local bar = self.ScrollBar
        yRange = math.max(0, yRange or 0)

        self.modernScrollSyncing = true
        bar:SetMinMaxValues(0, yRange)
        local value = math.min(bar:GetValue(), yRange)
        bar:SetValue(value)
        self:SetVerticalScroll(value)
        self.modernScrollSyncing = nil

        ZongLan_ModernScrollFrameTemplate_Update(self)
    end

    function ZongLan_ModernScrollFrameTemplate_OnVerticalScroll(self, offset)
        if self.modernVisibleExtent ~= nil then return end
        if self.modernScrollSyncing then return end
        self.modernScrollSyncing = true
        self.ScrollBar:SetValue(offset)
        self.modernScrollSyncing = nil
    end

    function ZongLan_ModernScrollFrameTemplate_OnMouseWheel(self, delta)
        local bar = self.ScrollBar
        local minValue, maxValue = bar:GetMinMaxValues()
        local value = bar:GetValue() - delta * (bar.scrollStep or ZL.scrollStep or 20)
        bar:SetValue(math.max(minValue, math.min(value, maxValue)))
    end

    function ZongLan_ModernScrollBarTemplate_OnLoad(self)
        self:SetMinMaxValues(0, 0)
        self:SetValue(0)
        self:SetValueStep(1)
        self:EnableMouseWheel(true)
        self:Hide()
    end

    function ZongLan_ModernScrollBarTemplate_OnValueChanged(self, value)
        local scroll = self:GetParent()
        ZongLan_ModernScrollThumbButton_UpdatePosition(self)
        if scroll.modernVisibleExtent ~= nil then return end
        if scroll.modernScrollSyncing then return end
        scroll.modernScrollSyncing = true
        scroll:SetVerticalScroll(value)
        scroll.modernScrollSyncing = nil
    end

    function ZongLan_ModernScrollBarTemplate_OnMouseWheel(self, delta)
        ZongLan_ModernScrollFrameTemplate_OnMouseWheel(self:GetParent(), delta)
    end

    function ZongLan_ModernScrollBarTemplate_OnEnter(self)
        -- self:GetThumbTexture():SetColorTexture(unpack(c2))
    end

    function ZongLan_ModernScrollBarTemplate_OnLeave(self)
        -- self:GetThumbTexture():SetColorTexture(unpack(c1))
    end

    function ZongLan_ModernScrollTrackButton_OnLoad(self)
        self:SetFrameLevel(self:GetParent():GetFrameLevel() + 1)
        self:EnableMouseWheel(true)
    end

    function ZongLan_ModernScrollTrackButton_OnMouseDown(self, button)
        if button ~= "LeftButton" then return end

        local bar = self:GetParent()
        local thumbButton = bar.ThumbButton
        local minValue, maxValue = bar:GetMinMaxValues()
        local valueRange = maxValue - minValue
        local travel = bar:GetHeight() - 4 - thumbButton:GetHeight()
        local top = bar:GetTop()
        if travel <= 0 or valueRange <= 0 or not top then return end

        local _, cursorY = GetCursorPosition()
        cursorY = cursorY / bar:GetEffectiveScale()
        local ratio = (top - 2 - thumbButton:GetHeight() / 2 - cursorY) / travel
        ratio = math.max(0, math.min(ratio, 1))
        bar:SetValue(minValue + ratio * valueRange)
    end

    function ZongLan_ModernScrollTrackButton_OnMouseWheel(self, delta)
        ZongLan_ModernScrollBarTemplate_OnMouseWheel(self:GetParent(), delta)
    end

    local function ModernScrollThumbButton_StopDragging(self)
        self.modernDragging = nil
        self.modernStartCursorY = nil
        self.modernStartValue = nil
        self:SetScript("OnUpdate", nil)
        SetModernScrollThumbButtonColor(self, self:IsMouseOver() and c2 or c1)
    end

    local function ModernScrollThumbButton_OnUpdate(self)
        if not IsMouseButtonDown("LeftButton") then
            ModernScrollThumbButton_StopDragging(self)
            return
        end

        local bar = self:GetParent()
        local minValue, maxValue = bar:GetMinMaxValues()
        local valueRange = maxValue - minValue
        local travel = (bar:GetHeight() - 4 - self:GetHeight()) * bar:GetEffectiveScale()
        if travel <= 0 or valueRange <= 0 then return end

        local _, cursorY = GetCursorPosition()
        local deltaY = cursorY - self.modernStartCursorY
        local value = self.modernStartValue - deltaY / travel * valueRange
        bar:SetValue(math.max(minValue, math.min(value, maxValue)))
    end

    function ZongLan_ModernScrollThumbButton_OnLoad(self)
        local bar = self:GetParent()
        self:SetFrameLevel(bar:GetFrameLevel() + 2)
        self:SetWidth(bar:GetWidth())

        self.TopMask = self:CreateMaskTexture()
        self.TopMask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMaskSmall")
        self.Top:AddMaskTexture(self.TopMask)

        self.BottomMask = self:CreateMaskTexture()
        self.BottomMask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMaskSmall")
        self.Bottom:AddMaskTexture(self.BottomMask)

        ZongLan_ModernScrollThumbButton_UpdateShape(self)
        ZongLan_ModernScrollThumbButton_UpdatePosition(bar)
        SetModernScrollThumbButtonColor(self, c1)
    end

    function ZongLan_ModernScrollThumbButton_OnEnter(self)
        if not self.modernDragging then
            SetModernScrollThumbButtonColor(self, c2)
        end
    end

    function ZongLan_ModernScrollThumbButton_OnLeave(self)
        if not self.modernDragging then
            SetModernScrollThumbButtonColor(self, c1)
        end
    end

    function ZongLan_ModernScrollThumbButton_OnMouseDown(self, button)
        if button ~= "LeftButton" then return end

        local _, cursorY = GetCursorPosition()
        self.modernDragging = true
        self.modernStartCursorY = cursorY
        self.modernStartValue = self:GetParent():GetValue()
        self:SetScript("OnUpdate", ModernScrollThumbButton_OnUpdate)
    end

    function ZongLan_ModernScrollThumbButton_OnMouseUp(self, button)
        if button == "LeftButton" and self.modernDragging then
            ModernScrollThumbButton_StopDragging(self)
        end
    end

    local function SetModernHorizontalScrollThumbButtonColor(self, color)
        self.Left:SetColorTexture(unpack(color))
        self.Middle:SetColorTexture(unpack(color))
        self.Right:SetColorTexture(unpack(color))
    end

    function ZongLan_ModernHorizontalScrollThumbButton_UpdateShape(self)
        local textureHeight = self.textureHeight or 8
        local radius = math.min(textureHeight / 2, self:GetWidth() / 2)

        self.Left:ClearAllPoints()
        self.Left:SetSize(radius, textureHeight)
        self.Left:SetPoint("LEFT")

        self.Middle:ClearAllPoints()
        self.Middle:SetHeight(textureHeight)
        self.Middle:SetPoint("LEFT", radius, 0)
        self.Middle:SetPoint("RIGHT", -radius, 0)

        self.Right:ClearAllPoints()
        self.Right:SetSize(radius, textureHeight)
        self.Right:SetPoint("RIGHT")

        if self.LeftMask then
            self.LeftMask:ClearAllPoints()
            self.LeftMask:SetSize(radius * 2, textureHeight)
            self.LeftMask:SetPoint("CENTER", self.Left, "RIGHT")

            self.RightMask:ClearAllPoints()
            self.RightMask:SetSize(radius * 2, textureHeight)
            self.RightMask:SetPoint("CENTER", self.Right, "LEFT")
        end
    end

    function ZongLan_ModernHorizontalScrollThumbButton_UpdatePosition(bar)
        local thumbButton = bar.ThumbButton
        if not thumbButton then return end

        local minValue, maxValue = bar:GetMinMaxValues()
        local valueRange = maxValue - minValue
        local ratio = 0
        if valueRange > 0 then
            ratio = (bar:GetValue() - minValue) / valueRange
        end

        local travel = math.max(0, bar:GetWidth() - 4 - thumbButton:GetWidth())
        thumbButton:ClearAllPoints()
        thumbButton:SetPoint("LEFT", bar, "LEFT", 2 + travel * ratio, 0)
    end

    function ZongLan_ModernHorizontalScrollFrameTemplate_Update(self)
        local bar = self.ScrollBar
        if not bar then return end

        local trackWidth = bar:GetWidth() - 4
        if trackWidth <= 0 then return end

        local visibleExtent
        local totalExtent
        if self.modernVisibleExtent ~= nil and self.modernTotalExtent ~= nil then
            visibleExtent = self.modernVisibleExtent
            totalExtent = self.modernTotalExtent
        else
            visibleExtent = self:GetWidth()
            totalExtent = visibleExtent + self:GetHorizontalScrollRange()
        end

        local thumbWidth = trackWidth
        if totalExtent and totalExtent > 0 then
            thumbWidth = trackWidth * math.min(1, visibleExtent / totalExtent)
        end

        local minThumbWidth = self.minThumbWidth or 24
        thumbWidth = math.max(math.min(minThumbWidth, trackWidth), thumbWidth)
        thumbWidth = math.min(trackWidth, thumbWidth)
        bar:GetThumbTexture():SetWidth(thumbWidth)
        if bar.ThumbButton then
            bar.ThumbButton:SetWidth(thumbWidth)
            bar.ThumbButton:SetHeight(bar:GetHeight())
            ZongLan_ModernHorizontalScrollThumbButton_UpdateShape(bar.ThumbButton)
            ZongLan_ModernHorizontalScrollThumbButton_UpdatePosition(bar)
        end

        local _, maxValue = bar:GetMinMaxValues()
        local noOverflow
        if self.modernVisibleExtent ~= nil and self.modernTotalExtent ~= nil then
            noOverflow = self.modernTotalExtent <= self.modernVisibleExtent
        else
            noOverflow = maxValue <= 1
        end
        if self.alwaysHideScrollBar or noOverflow then
            bar:Hide()
        else
            bar:Show()
        end
    end

    function ZongLan_ModernHorizontalScrollFrameTemplate_SetScrollExtent(self, visibleExtent, totalExtent)
        self.modernVisibleExtent = visibleExtent
        self.modernTotalExtent = totalExtent
        ZongLan_ModernHorizontalScrollFrameTemplate_Update(self)
    end

    function ZongLan_ModernHorizontalScrollFrameTemplate_ClearScrollExtent(self)
        self.modernVisibleExtent = nil
        self.modernTotalExtent = nil
        ZongLan_ModernHorizontalScrollFrameTemplate_Update(self)
    end

    function ZongLan_ModernHorizontalScrollFrameTemplate_OnLoad(self)
        self:EnableMouse(true)
        self:EnableMouseWheel(true)
        self.SetScrollExtent = ZongLan_ModernHorizontalScrollFrameTemplate_SetScrollExtent
        self.ClearScrollExtent = ZongLan_ModernHorizontalScrollFrameTemplate_ClearScrollExtent
        self.ScrollBar.scrollStep = ZL.scrollStep
        ZongLan_ModernHorizontalScrollFrameTemplate_Update(self)
    end

    function ZongLan_ModernHorizontalScrollFrameTemplate_OnScrollRangeChanged(self, xRange, yRange)
        if self.modernVisibleExtent ~= nil then
            ZongLan_ModernHorizontalScrollFrameTemplate_Update(self)
            return
        end

        local bar = self.ScrollBar
        xRange = math.max(0, xRange or 0)

        self.modernScrollSyncing = true
        bar:SetMinMaxValues(0, xRange)
        local value = math.min(bar:GetValue(), xRange)
        bar:SetValue(value)
        self:SetHorizontalScroll(value)
        self.modernScrollSyncing = nil

        ZongLan_ModernHorizontalScrollFrameTemplate_Update(self)
    end

    function ZongLan_ModernHorizontalScrollFrameTemplate_OnHorizontalScroll(self, offset)
        if self.modernVisibleExtent ~= nil then return end
        if self.modernScrollSyncing then return end
        self.modernScrollSyncing = true
        self.ScrollBar:SetValue(offset)
        self.modernScrollSyncing = nil
    end

    function ZongLan_ModernHorizontalScrollFrameTemplate_OnMouseWheel(self, delta)
        local bar = self.ScrollBar
        local minValue, maxValue = bar:GetMinMaxValues()
        local value = bar:GetValue() - delta * (bar.scrollStep or ZL.scrollStep or 20)
        bar:SetValue(math.max(minValue, math.min(value, maxValue)))
    end

    function ZongLan_ModernHorizontalScrollBarTemplate_OnLoad(self)
        self:SetMinMaxValues(0, 0)
        self:SetValue(0)
        self:SetValueStep(1)
        self:EnableMouseWheel(true)
        self:Hide()
    end

    function ZongLan_ModernHorizontalScrollBarTemplate_OnValueChanged(self, value)
        local scroll = self:GetParent()
        ZongLan_ModernHorizontalScrollThumbButton_UpdatePosition(self)
        if scroll.modernVisibleExtent ~= nil then return end
        if scroll.modernScrollSyncing then return end
        scroll.modernScrollSyncing = true
        scroll:SetHorizontalScroll(value)
        scroll.modernScrollSyncing = nil
    end

    function ZongLan_ModernHorizontalScrollBarTemplate_OnMouseWheel(self, delta)
        ZongLan_ModernHorizontalScrollFrameTemplate_OnMouseWheel(self:GetParent(), delta)
    end

    function ZongLan_ModernHorizontalScrollTrackButton_OnLoad(self)
        self:SetFrameLevel(self:GetParent():GetFrameLevel() + 1)
        self:EnableMouseWheel(true)
    end

    function ZongLan_ModernHorizontalScrollTrackButton_OnMouseDown(self, button)
        if button ~= "LeftButton" then return end

        local bar = self:GetParent()
        local thumbButton = bar.ThumbButton
        local minValue, maxValue = bar:GetMinMaxValues()
        local valueRange = maxValue - minValue
        local travel = bar:GetWidth() - 4 - thumbButton:GetWidth()
        local left = bar:GetLeft()
        if travel <= 0 or valueRange <= 0 or not left then return end

        local cursorX = GetCursorPosition()
        cursorX = cursorX / bar:GetEffectiveScale()
        local ratio = (cursorX - left - 2 - thumbButton:GetWidth() / 2) / travel
        ratio = math.max(0, math.min(ratio, 1))
        bar:SetValue(minValue + ratio * valueRange)
    end

    function ZongLan_ModernHorizontalScrollTrackButton_OnMouseWheel(self, delta)
        ZongLan_ModernHorizontalScrollBarTemplate_OnMouseWheel(self:GetParent(), delta)
    end

    function ZongLan_ModernHorizontalScrollBarTemplate_OnSizeChanged(self)
        ZongLan_ModernHorizontalScrollFrameTemplate_Update(self:GetParent())
    end

    local function ModernHorizontalScrollThumbButton_StopDragging(self)
        self.modernDragging = nil
        self.modernStartCursorX = nil
        self.modernStartValue = nil
        self:SetScript("OnUpdate", nil)
        SetModernHorizontalScrollThumbButtonColor(self, self:IsMouseOver() and c2 or c1)
    end

    local function ModernHorizontalScrollThumbButton_OnUpdate(self)
        if not IsMouseButtonDown("LeftButton") then
            ModernHorizontalScrollThumbButton_StopDragging(self)
            return
        end

        local bar = self:GetParent()
        local minValue, maxValue = bar:GetMinMaxValues()
        local valueRange = maxValue - minValue
        local travel = (bar:GetWidth() - 4 - self:GetWidth()) * bar:GetEffectiveScale()
        if travel <= 0 or valueRange <= 0 then return end

        local cursorX = GetCursorPosition()
        local deltaX = cursorX - self.modernStartCursorX
        local value = self.modernStartValue + deltaX / travel * valueRange
        bar:SetValue(math.max(minValue, math.min(value, maxValue)))
    end

    function ZongLan_ModernHorizontalScrollThumbButton_OnLoad(self)
        local bar = self:GetParent()
        self:SetFrameLevel(bar:GetFrameLevel() + 2)
        self:SetHeight(bar:GetHeight())

        self.LeftMask = self:CreateMaskTexture()
        self.LeftMask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMaskSmall")
        self.Left:AddMaskTexture(self.LeftMask)

        self.RightMask = self:CreateMaskTexture()
        self.RightMask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMaskSmall")
        self.Right:AddMaskTexture(self.RightMask)

        ZongLan_ModernHorizontalScrollThumbButton_UpdateShape(self)
        ZongLan_ModernHorizontalScrollThumbButton_UpdatePosition(bar)
        SetModernHorizontalScrollThumbButtonColor(self, c1)
    end

    function ZongLan_ModernHorizontalScrollThumbButton_OnEnter(self)
        if not self.modernDragging then
            SetModernHorizontalScrollThumbButtonColor(self, c2)
        end
    end

    function ZongLan_ModernHorizontalScrollThumbButton_OnLeave(self)
        if not self.modernDragging then
            SetModernHorizontalScrollThumbButtonColor(self, c1)
        end
    end

    function ZongLan_ModernHorizontalScrollThumbButton_OnMouseDown(self, button)
        if button ~= "LeftButton" then return end

        local cursorX = GetCursorPosition()
        self.modernDragging = true
        self.modernStartCursorX = cursorX
        self.modernStartValue = self:GetParent():GetValue()
        self:SetScript("OnUpdate", ModernHorizontalScrollThumbButton_OnUpdate)
    end

    function ZongLan_ModernHorizontalScrollThumbButton_OnMouseUp(self, button)
        if button == "LeftButton" and self.modernDragging then
            ModernHorizontalScrollThumbButton_StopDragging(self)
        end
    end
end

local r, g, b = GetClassColor(select(2, UnitClass("player")))
local blackup = CreateColor(.3, .3, .3, .7)
local blackdown = CreateColor(0, 0, 0, .7)
local classColorup = CreateColor(r, g, b, .7)
local classColordown = CreateColor(r, g, b, .1)
local disColorup = CreateColor(.5, .5, .5, .7)
local disColordown = CreateColor(0, 0, 0, .3)
local borderAlpha = 1
function ZL.CreateButton(parent)
    local bt = CreateFrame("Button", nil, parent, "BackdropTemplate")
    bt:SetBackdrop({
        edgeFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeSize = 1,
    })
    bt:SetBackdropBorderColor(0, 0, 0, borderAlpha)
    bt.bg = bt:CreateTexture(nil, "BACKGROUND")
    bt.bg:SetAllPoints()
    bt.bg:SetTexture("Interface\\Buttons\\WHITE8x8")
    bt.bg:SetGradient("VERTICAL", blackdown, blackup)
    local t = bt:CreateFontString()
    t:SetAllPoints()
    t:SetTextColor(1, .82, 0)
    t:SetFont(ns.Font, 15, "OUTLINE")
    bt:SetFontString(t)

    hooksecurefunc(bt, "SetScript", function(arg1, arg2, ...)
        if arg2 == "OnEnter" then
            bt:HookScript("OnEnter", function()
                bt.bg:SetGradient("VERTICAL", classColordown, classColorup)
                bt:SetBackdropBorderColor(r, g, b, borderAlpha)
                bt:GetFontString():SetTextColor(1, 1, 1)
            end)
        elseif arg2 == "OnLeave" then
            bt:HookScript("OnLeave", function()
                GameTooltip:Hide()
                bt.bg:SetGradient("VERTICAL", blackdown, blackup)
                bt:SetBackdropBorderColor(0, 0, 0, borderAlpha)
                bt:GetFontString():SetTextColor(1, .82, 0)
            end)
        end
    end)
    hooksecurefunc(bt, "SetEnabled", function(arg1, arg2, ...)
        if arg2 == true then
            bt.bg:SetGradient("VERTICAL", blackdown, blackup)
            bt:GetFontString():SetTextColor(1, .82, 0)
        elseif arg2 == false then
            bt.bg:SetGradient("VERTICAL", disColordown, disColorup)
            bt:GetFontString():SetTextColor(.5, .5, .5)
        end
    end)
    function bt:Disable()
        self:SetEnabled(false)
    end

    function bt:Enable()
        self:SetEnabled(true)
    end

    bt:SetScript("OnEnter", nil)
    bt:SetScript("OnLeave", nil)
    return bt
end

function ZL.SkinDropDown(dropDown)
    local borderAlpha = 1
    local bt = dropDown.Button
    bt:Hide()
    dropDown.Left:Hide()
    dropDown.Middle:Hide()
    dropDown.Right:Hide()
    dropDown.Text:ClearAllPoints()
    dropDown.Text:SetPoint("TOPLEFT", 18, -8)
    dropDown.Text:SetPoint("TOPRIGHT", -40, -8)
    dropDown.Text:SetJustifyH("RIGHT")

    local f = CreateFrame("Frame", nil, dropDown, "BackdropTemplate")
    f:SetBackdrop({
        bgFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeSize = 1,

    })
    f:SetBackdropColor(0, 0, 0, 0.5)
    f:SetBackdropBorderColor(.3, .3, .3, borderAlpha)
    f:SetPoint("TOPLEFT", 15, 0)
    f:SetPoint("BOTTOMRIGHT", -15, 7)
    f:SetFrameLevel(dropDown:GetFrameLevel())
    dropDown.bg = f

    local tex = dropDown:CreateTexture("OVERLAY")
    tex:SetPoint("TOPLEFT", bt, "TOPLEFT", 2, -2)
    tex:SetPoint("BOTTOMRIGHT", bt, "BOTTOMRIGHT", -2, 2)
    tex:SetTexture("Interface/AddOns/" .. AddonName .. "/Media/textures/arrow.tga")
    tex:SetRotation(math.pi)
    dropDown:HookScript("OnEnter", function(self)
        if dropDown.isDisabled then return end
        f:SetBackdropColor(r, g, b, 0.3)
        f:SetBackdropBorderColor(r, g, b, borderAlpha)
    end)
    dropDown:HookScript("OnLeave", function(self)
        if dropDown.isDisabled then return end
        f:SetBackdropColor(0, 0, 0, 0.5)
        f:SetBackdropBorderColor(.3, .3, .3, borderAlpha)
    end)
end

function ZL.CreateHighLightAnim(self, w, h)
    local f = CreateFrame("Frame", nil, self)
    f:SetPoint("CENTER")
    f:SetSize(self:GetSize())
    local tex = f:CreateTexture()
    tex:SetSize(f:GetWidth() + (w or 0), f:GetHeight() + (h or 0))
    tex:SetPoint("CENTER", 0, -1)
    tex:SetAtlas("ShipMission_FollowerListButton-Select")
    local tex = f:CreateTexture()
    tex:SetSize(f:GetWidth(), f:GetHeight())
    tex:SetPoint("CENTER", 0, -1)
    tex:SetAtlas("GarrMission_ListGlow-Select")

    f.flashGroup = f:CreateAnimationGroup()
    for i = 1, 3 do
        local fade = f.flashGroup:CreateAnimation('Alpha')
        fade:SetChildKey('flash')
        fade:SetOrder(i * 2)
        fade:SetDuration(.4)
        fade:SetFromAlpha(.1)
        fade:SetToAlpha(1)

        local fade = f.flashGroup:CreateAnimation('Alpha')
        fade:SetChildKey('flash')
        fade:SetOrder(i * 2 + 1)
        fade:SetDuration(.4)
        fade:SetFromAlpha(1)
        fade:SetToAlpha(.1)
    end
    f.flashGroup:Play()
    f.flashGroup:SetLooping("REPEAT")
    return f
end

local editMixin = {}
function editMixin:HasStickyFocus()
    return true
end

function ZL.SetEditStickyFocus(edit)
    edit.HasStickyFocus = editMixin.HasStickyFocus
end

function ZL.SetEditBaseClass(edit, notClearOnRightButton)
    edit:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    edit:HookScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    edit:HookScript("OnEditFocusGained", function(self)
        ZL.lastfocus = self
    end)
    if not notClearOnRightButton then
        edit:HookScript("OnMouseDown", function(self, button)
            if button == "RightButton" then
                self:SetEnabled(false)
                self:SetText("")
            end
        end)
        edit:HookScript("OnMouseUp", function(self, enter)
            if enter == "RightButton" then
                self:SetEnabled(true)
            end
        end)
    end
    ZL.SetEditStickyFocus(edit)
end
