local AddonName, ns = ...
if ZL.IsBlackListPlayer then return end

local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not ldb then return end

local plugin = ldb:NewDataObject(AddonName, {
    text = AddonName,
    type = "launcher",
    icon = ns.Interface .. "Media\\icon\\icon.png",
})

local function ToggleRoleOverview()
    ZL.SetFBCD(nil, nil, true)
end

local function OpenOptions()
    ZL.OpenOption()
end

function plugin:OnClick(button)
    if button == "LeftButton" then
        ToggleRoleOverview()
    elseif button == "RightButton" then
        OpenOptions()
    else
        return
    end
    ZL.PlaySound(1)
end

function plugin:OnEnter()
    ZL.SetFBCD(self, "minimap")
end

function plugin:OnLeave()
    if ZL.FBCDFrame and not ZL.FBCDFrame.click then
        ZL.FBCDFrame:Hide()
    end
end

local function CreateMainIcon()
    local frameName = "ZongLanMainIcon"
    local frame = CreateFrame("Button", frameName, UIParent, "BackdropTemplate")
    frame:SetBackdrop({
        bgFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0, 0, 0, 0)
    frame:SetBackdropBorderColor(0, 0, 0, 0)
    frame:SetSize(100, 22)
    frame:SetFrameStrata(ZongLan.options.mainIconFrameLevel)
    frame:SetScale(ZongLan.options.mainIconScale)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    frame:RegisterForDrag("LeftButton")

    ZongLan.point = ZongLan.point or {}
    local point = ZongLan.point[frameName]
    if point then
        frame:SetPoint(point[1], UIParent, point[2], point[3], point[4])
    else
        frame:SetPoint("TOP", UIParent, "TOP", 0, 0)
    end
    frame:SetShown(ZongLan.options.mainIcon == 1)
    ZL.MainIcon = frame

    frame:SetScript("OnDragStart", function(self)
        self.moved = true
        self:StartMoving()
        if ZL.FBCDFrame and not ZL.FBCDFrame.click then
            ZL.FBCDFrame:Hide()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local anchor, _, relativeAnchor, x, y = self:GetPoint(1)
        ZongLan.point[frameName] = { anchor, relativeAnchor, x, y }
        C_Timer.After(0, function()
            self.moved = nil
        end)
    end)
    frame:SetScript("OnClick", function(self, button)
        if self.moved then return end
        if button == "LeftButton" then
            ToggleRoleOverview()
        elseif button == "RightButton" then
            OpenOptions()
        else
            return
        end
        ZL.PlaySound(1)
    end)
    frame:SetScript("OnEnter", function(self)
        if not self.moved then
            ZL.SetFBCD(self, "minimap")
        end
    end)
    frame:SetScript("OnLeave", function()
        if ZL.FBCDFrame and not ZL.FBCDFrame.click then
            ZL.FBCDFrame:Hide()
        end
    end)

    local texture = frame:CreateTexture()
    texture:SetSize(20, 20)
    texture:SetPoint("LEFT")
    texture:SetTexture(plugin.icon)

    local text = frame:CreateFontString()
    text:SetFont(ns.Font, 15, "OUTLINE")
    text:SetPoint("LEFT", texture, "RIGHT", 0, -1)
    text:SetTextColor(1, 0.82, 0)
    text:SetText(AddonName)
    frame:SetWidth(texture:GetWidth() + text:GetStringWidth())
end

ZL.Init(function()
    ZongLan.options.mainIcon = ZongLan.options.mainIcon or 0
    ZongLan.options.mainIconScale = tonumber(ZongLan.options.mainIconScale) or 1
    ZongLan.options.mainIconFrameLevel = ZongLan.options.mainIconFrameLevel or "HIGH"
    CreateMainIcon()

    local icon = LibStub("LibDBIcon-1.0", true)
    if not icon then return end
    ZongLan.minimap = ZongLan.minimap or {}
    ZongLan.minimap.hide = ZongLan.options.miniMap == 0
    ZongLan.minimap.minimapPos = ZongLan.minimap.minimapPos or 185
    icon:Register(AddonName, plugin, ZongLan.minimap)
    ZL.MinimapIcon = icon
end)
