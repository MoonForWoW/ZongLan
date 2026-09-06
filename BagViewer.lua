local AddonName, ns = ...

local ITEM_SIZE = 30
local ITEM_GAP = 4
local ITEM_COLUMNS = 14
local CONTENT_WIDTH = ITEM_COLUMNS * ITEM_SIZE + (ITEM_COLUMNS - 1) * ITEM_GAP
local EQUIPMENT_NORMAL_GAP = 0 -- 装备与普通物品之间的垂直间距

local bagFrame
local itemPool

local function ResetItemButton(_, button)
    button:Hide()
    button:SetScript("OnUpdate", nil)
    button.isOnEnter = false
    button:ClearAllPoints()
    button.itemID = nil
    button.itemLink = nil
    button.expectedLink = nil
    button.itemCount = nil
    button.locationText = nil
    button.stackable = nil
    if button.icon then
        button.icon:SetTexture(nil)
    end
    if button.count then
        button.count:SetText("")
    end
    if button.itemLevel then
        button.itemLevel:SetText("")
        button.itemLevel:SetTextColor(1, .82, 0)
    end
    if button.SetBackdropBorderColor and button.icon then
        button:SetBackdropBorderColor(.35, .35, .35, 1)
    end
end

local function ItemOnEnter(self)
    GameTooltip:SetOwner(self, ZL.ButtonIsInRight(self) and "ANCHOR_LEFT" or "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    if self.itemLink then
        GameTooltip:SetHyperlink(self.itemLink)
    else
        GameTooltip:SetItemByID(self.itemID)
    end
    GameTooltip:Show()
end

local function ItemOnLeave(self)
    GameTooltip:Hide()
end

local function InitializeItemButton(button)
    button:SetSize(ITEM_SIZE, ITEM_SIZE)
    button:SetBackdrop({
        edgeFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeSize = 1.5,
    })
    button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")

    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetAllPoints()
    button.icon:SetTexCoord(unpack(ZL.iconTexCoord))

    button.count = button:CreateFontString(nil, "OVERLAY")
    button.count:SetFont(ns.Font, 11, "OUTLINE")
    button.count:SetPoint("BOTTOMRIGHT", -1, 1)
    button.count:SetTextColor(1, 1, 1)

    button.itemLevel = button:CreateFontString(nil, "OVERLAY")
    button.itemLevel:SetFont(ns.Font, 11, "OUTLINE")
    button.itemLevel:SetPoint("BOTTOM", 0, 1)
    button.itemLevel:SetTextColor(1, .82, 0)

    ZL.OnEnterDelay(button, ItemOnEnter, ZL.itemOnEnterDelay)
    ZL.OnLeaveDelay(button, ItemOnLeave)
end

local function AddCounts(target, source)
    if type(source) ~= "table" then return end
    for itemID, count in pairs(source) do
        itemID = tonumber(itemID)
        count = tonumber(count)
        if itemID and count and count > 0 then
            target[itemID] = (target[itemID] or 0) + count
        end
    end
end

local function IsEquipmentLoc(equipLoc)
    return equipLoc and equipLoc ~= ""
        and equipLoc ~= "INVTYPE_NON_EQUIP_IGNORE"
        and equipLoc ~= "INVTYPE_BAG"
end

local function InsertItems(items, itemID, link, count, stackable)
    local _, _, _, equipLoc, _, classID = GetItemInfoInstant(link or itemID)
    local isEquipment = IsEquipmentLoc(equipLoc)
    local maxStack = select(8, GetItemInfo(link or itemID))
    if not maxStack and C_Item and C_Item.GetItemMaxStackSizeByID then
        maxStack = C_Item.GetItemMaxStackSizeByID(itemID)
    end
    stackable = stackable or (maxStack and maxStack > 1) or equipLoc == "INVTYPE_AMMO" or classID == 6
    if isEquipment and not stackable then
        for _ = 1, count do
            items[#items + 1] = { itemID = itemID, link = link, count = 1, stackable = false }
        end
    else
        items[#items + 1] = { itemID = itemID, link = link, count = count, stackable = not not stackable }
    end
end

local function GetItems(...)
    local counts = {}
    for i = 1, select("#", ...) do
        AddCounts(counts, select(i, ...))
    end

    local items = {}
    local total = 0
    for itemID, count in pairs(counts) do
        InsertItems(items, itemID, nil, count)
        total = total + count
    end
    return items, total
end

local function AddLinkCounts(target, source)
    if type(source) ~= "table" then return end
    for link, value in pairs(source) do
        local count = type(value) == "table" and tonumber(value.count) or tonumber(value)
        if type(link) == "string" and count and count > 0 then
            target[link] = target[link] or { count = 0 }
            target[link].count = target[link].count + count
            if type(value) == "table" and value.stackable then
                target[link].stackable = true
            end
        end
    end
end

local function GetLinkItems(...)
    local counts = {}
    for i = 1, select("#", ...) do
        AddLinkCounts(counts, select(i, ...))
    end

    local items = {}
    local total = 0
    for link, value in pairs(counts) do
        local itemID = GetItemInfoInstant(link)
        if itemID then
            InsertItems(items, itemID, link, value.count, value.stackable)
            total = total + value.count
        end
    end
    return items, total
end

local function CreateBagFrame()
    local frame = CreateFrame("Frame", "ZongLanBagViewer", UIParent, "BackdropTemplate")
    frame:SetFrameStrata("TOOLTIP")
    frame:EnableMouse(true)
    frame:SetSize(CONTENT_WIDTH + 20, 200)
    frame:SetBackdrop({
        bgFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame:SetBackdropColor(0, 0, 0, .8)
    frame:SetBackdropBorderColor(.3, .7, 1, 1)

    frame.content = CreateFrame("Frame", nil, frame)
    frame.content:SetPoint("TOPLEFT", 10, -5)
    frame.content:SetWidth(CONTENT_WIDTH)
    frame.content:SetHeight(1)

    frame.headers = {}
    frame.emptyTexts = {}
    for i = 1, 2 do
        local header = frame.content:CreateFontString(nil, "OVERLAY")
        header:SetFont(ns.Font, 13, "OUTLINE")
        header:SetTextColor(1, .82, 0)
        header:SetJustifyH("LEFT")
        frame.headers[i] = header

        local emptyText = frame.content:CreateFontString(nil, "OVERLAY")
        emptyText:SetFont(ns.Font, 12, "OUTLINE")
        emptyText:SetTextColor(.5, .5, .5)
        emptyText:SetText(EMPTY or NONE or "Empty")
        frame.emptyTexts[i] = emptyText
    end

    itemPool = CreateFramePool("Button", frame.content, "BackdropTemplate", ResetItemButton)

    frame:SetScript("OnHide", function(self)
        self.renderID = (self.renderID or 0) + 1
        self.owner = nil
        itemPool:ReleaseAll()
        GameTooltip:Hide()
    end)
    frame:Hide()
    return frame
end

local function GetItemLevel(itemRef, fallbackLevel)
    if GetDetailedItemLevelInfo then
        return GetDetailedItemLevelInfo(itemRef) or fallbackLevel
    elseif C_Item and C_Item.GetDetailedItemLevelInfo then
        return C_Item.GetDetailedItemLevelInfo(itemRef) or fallbackLevel
    end
    return fallbackLevel
end

local EQUIP_LOC_RANK = {
    INVTYPE_WEAPON = 1,
    INVTYPE_2HWEAPON = 1,
    INVTYPE_WEAPONMAINHAND = 1,
    INVTYPE_WEAPONOFFHAND = 1,
    INVTYPE_HOLDABLE = 1,
    INVTYPE_SHIELD = 1,
    INVTYPE_RANGED = 1,
    INVTYPE_RANGEDRIGHT = 1,
    INVTYPE_THROWN = 1,
    INVTYPE_RELIC = 1,
    INVTYPE_HEAD = 2,
    INVTYPE_SHOULDER = 3,
    INVTYPE_CHEST = 4,
    INVTYPE_ROBE = 4,
    INVTYPE_WRIST = 5,
    INVTYPE_HAND = 6,
    INVTYPE_WAIST = 7,
    INVTYPE_LEGS = 8,
    INVTYPE_FEET = 9,
    INVTYPE_NECK = 10,
    INVTYPE_CLOAK = 11,
    INVTYPE_FINGER = 12,
    INVTYPE_TRINKET = 13,
    INVTYPE_BODY = 14,
    INVTYPE_TABARD = 15,
}

local ITEM_CLASS_RANK = {
    [0] = 2,  -- 消耗品
    [3] = 3,  -- 宝石
    [8] = 3,  -- 物品强化
    [16] = 3, -- 雕文
    [12] = 4, -- 任务物品
    [9] = 5,  -- 配方
    [5] = 6,  -- 材料
    [7] = 6,  -- 专业材料
    [1] = 7,  -- 容器
}

local function SetSortInfo(info)
    local itemRef = info.link or info.itemID
    local name, _, quality, itemLevel, _, _, _, _, equipLoc, _, _, classID, subclassID = GetItemInfo(itemRef)
    local _, _, _, instantEquipLoc, _, instantClassID, instantSubclassID = GetItemInfoInstant(itemRef)
    equipLoc = equipLoc or instantEquipLoc
    classID = classID or instantClassID
    subclassID = subclassID or instantSubclassID

    local isEquipment = not info.stackable and IsEquipmentLoc(equipLoc)
    info.sortGroup = isEquipment and 1 or (ITEM_CLASS_RANK[classID] or 8)
    info.sortSlot = isEquipment and (EQUIP_LOC_RANK[equipLoc] or 99) or 0
    info.sortLevel = isEquipment and (GetItemLevel(itemRef, itemLevel) or 0) or 0
    info.sortQuality = quality or -1
    info.sortSubclass = subclassID or -1
    info.sortName = name or ""
end

local function SortItems(items)
    for _, info in ipairs(items) do
        SetSortInfo(info)
    end
    sort(items, function(a, b)
        if a.sortGroup ~= b.sortGroup then
            return a.sortGroup < b.sortGroup
        elseif a.sortGroup == 1 and a.sortSlot ~= b.sortSlot then
            return a.sortSlot < b.sortSlot
        elseif a.sortGroup == 1 and a.sortLevel ~= b.sortLevel then
            return a.sortLevel > b.sortLevel
        elseif a.sortQuality ~= b.sortQuality then
            return a.sortQuality > b.sortQuality
        elseif a.sortSubclass ~= b.sortSubclass then
            return a.sortSubclass < b.sortSubclass
        elseif a.sortName ~= b.sortName then
            return a.sortName < b.sortName
        elseif a.itemID ~= b.itemID then
            return a.itemID < b.itemID
        end
        return (a.link or "") < (b.link or "")
    end)
end

local function ContinueOnItemsLoaded(bagItems, bankItems, renderID, callback)
    local itemRefs = {}
    for _, items in ipairs({ bagItems, bankItems }) do
        for _, info in ipairs(items) do
            itemRefs[info.link or info.itemID] = true
        end
    end

    local requests = {}
    if Item then
        for itemRef in pairs(itemRefs) do
            local item
            if type(itemRef) == "string" and Item.CreateFromItemLink then
                item = Item:CreateFromItemLink(itemRef)
            elseif Item.CreateFromItemID then
                item = Item:CreateFromItemID(itemRef)
            end
            if item then
                requests[#requests + 1] = item
            end
        end
    end

    if #requests == 0 then
        callback()
        return
    end

    local remaining = #requests
    local finished
    local function Finish()
        if finished or not bagFrame or bagFrame.renderID ~= renderID then return end
        finished = true
        callback()
    end
    for _, item in ipairs(requests) do
        item:ContinueOnItemLoad(function()
            if finished then return end
            remaining = remaining - 1
            if remaining == 0 then
                Finish()
            end
        end)
    end
    C_Timer.After(.5, Finish)
end

local function SetItemInfo(button, itemLink, itemID, stackable, renderID)
    local itemRef = itemLink or itemID
    local _, loadedLink, quality, itemLevel, _, _, _, _, equipLoc = GetItemInfo(itemRef)
    if itemLink or loadedLink then
        button.itemLink = itemLink or loadedLink
    end
    if quality then
        local r, g, b = GetItemQualityColor(quality)
        button:SetBackdropBorderColor(r, g, b, 1)
        button.itemLevel:SetTextColor(r, g, b)
    end
    itemLevel = GetItemLevel(itemRef, itemLevel)
    button.itemLevel:SetText(not stackable and IsEquipmentLoc(equipLoc) and itemLevel or "")

    if not Item then return end
    local item
    if itemLink and Item.CreateFromItemLink then
        item = Item:CreateFromItemLink(itemLink)
    elseif Item.CreateFromItemID then
        item = Item:CreateFromItemID(itemID)
    end
    if not item then return end
    item:ContinueOnItemLoad(function()
        if not bagFrame or bagFrame.renderID ~= renderID or button.itemID ~= itemID or button.expectedLink ~= itemLink then return end
        local _, asyncLink, loadedQuality, loadedItemLevel, _, _, _, _, loadedEquipLoc = GetItemInfo(itemRef)
        button.itemLink = itemLink or asyncLink
        if loadedQuality then
            local r, g, b = GetItemQualityColor(loadedQuality)
            button:SetBackdropBorderColor(r, g, b, 1)
            button.itemLevel:SetTextColor(r, g, b)
        end
        loadedItemLevel = GetItemLevel(itemRef, loadedItemLevel)
        button.itemLevel:SetText(not stackable and IsEquipmentLoc(loadedEquipLoc) and loadedItemLevel or "")
    end)
end

local function RenderSection(frame, sectionIndex, title, items, top)
    local header = frame.headers[sectionIndex]
    header:ClearAllPoints()
    header:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -top)
    header:SetText(title)
    header:Show()
    top = top + 22

    local emptyText = frame.emptyTexts[sectionIndex]
    emptyText:ClearAllPoints()
    if #items == 0 then
        emptyText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 2, -top)
        emptyText:Show()
        return top + 24
    end
    emptyText:Hide()

    local column = 0
    local itemTop = top
    local previousGroup
    for _, info in ipairs(items) do
        if previousGroup == 1 and info.sortGroup ~= 1 then
            if column > 0 then
                itemTop = itemTop + ITEM_SIZE + ITEM_GAP
                column = 0
            end
            itemTop = itemTop + EQUIPMENT_NORMAL_GAP
        end
        local button, isNew = itemPool:Acquire()
        if isNew then
            InitializeItemButton(button)
        end
        button:SetPoint("TOPLEFT", frame.content, "TOPLEFT", column * (ITEM_SIZE + ITEM_GAP), -itemTop)
        button.itemID = info.itemID
        button.itemLink = info.link
        button.expectedLink = info.link
        button.itemCount = info.count
        button.locationText = title
        button.stackable = info.stackable
        button.icon:SetTexture(select(5, GetItemInfoInstant(info.link or info.itemID)))
        button.count:SetText(info.count > 1 and info.count or "")
        button:Show()
        SetItemInfo(button, info.link, info.itemID, info.stackable, frame.renderID)
        column = column + 1
        if column == ITEM_COLUMNS then
            itemTop = itemTop + ITEM_SIZE + ITEM_GAP
            column = 0
        end
        previousGroup = info.sortGroup
    end

    if column > 0 then
        itemTop = itemTop + ITEM_SIZE + ITEM_GAP
    end
    return itemTop + 8
end

local function RenderBagFrame(owner, bagItems, bankItems, renderID)
    if not bagFrame or bagFrame.renderID ~= renderID or not owner:IsShown() or not owner.click then return end

    SortItems(bagItems)
    SortItems(bankItems)
    itemPool:ReleaseAll()

    local top = 4
    top = RenderSection(bagFrame, 1, BAGSLOT or INVENTORY_TOOLTIP or "Bags", bagItems, top)
    top = RenderSection(bagFrame, 2, BANK or "Bank", bankItems, top)
    local contentHeight = max(1, top)
    bagFrame.content:SetHeight(contentHeight)
    bagFrame:SetHeight(contentHeight + 10)
    bagFrame:ClearAllPoints()
    bagFrame:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, 0)
    bagFrame:Show()
end

function ZL.ShowBagFrame(owner, isAccounts, realmID, player, colorplayer, class)
    if not bagFrame then
        bagFrame = CreateBagFrame()
    end

    local db = isAccounts and ZongLanDB or ZongLan
    local playerBag = db and db.bag and db.bag[realmID] and db.bag[realmID][player]
    local bagItems = GetLinkItems(playerBag and playerBag.bagLink, playerBag and playerBag.bagKeyLink)
    local bankItems = GetLinkItems(playerBag and playerBag.bankLink)
    if #bagItems == 0 then
        bagItems = GetItems(playerBag and playerBag.bag, playerBag and playerBag.bagKey)
    end
    if #bankItems == 0 then
        bankItems = GetItems(playerBag and playerBag.bank)
    end

    if bagFrame:IsShown() then
        bagFrame:Hide()
    else
        itemPool:ReleaseAll()
    end
    bagFrame.renderID = (bagFrame.renderID or 0) + 1
    local renderID = bagFrame.renderID
    bagFrame.owner = owner
    bagFrame:SetParent(owner)
    bagFrame:SetFrameLevel(owner:GetFrameLevel() + 20)
    local r, g, b = GetClassColor(class)
    bagFrame:SetBackdropBorderColor(r, g, b, 1)
    if not owner.ZongLanBagViewerHooked then
        owner.ZongLanBagViewerHooked = true
        owner:HookScript("OnHide", function()
            ZL.HideBagFrame()
        end)
    end
    ContinueOnItemsLoaded(bagItems, bankItems, renderID, function()
        RenderBagFrame(owner, bagItems, bankItems, renderID)
    end)
end

function ZL.HideBagFrame()
    if bagFrame then
        bagFrame:Hide()
    end
end
