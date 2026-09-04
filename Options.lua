if BG.IsBlackListPlayer then return end
local AddonName, ns = ...

local LibBG         = ns.LibBG
local L             = ns.L
local GetClassColor = ns.GetClassColor

local RR            = ns.RR
local NN            = ns.NN
local RN            = ns.RN
local Size          = ns.Size
local RGB           = ns.RGB
local RGB_16        = ns.RGB_16
local GetClassRGB   = ns.GetClassRGB
local GetText_T     = ns.GetText_T
local AddTexture    = ns.AddTexture
local GetItemID     = ns.GetItemID
local Maxb          = ns.Maxb
local Round         = ns.Round

local player        = BG.playerName
local realmID       = GetRealmID()

local pt            = print

local O             = {}
ns.O                = O

local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded

function BG.AddOption(frame, addOn, position)
    local category, layout = Settings.RegisterCanvasLayoutCategory(frame, frame.name, frame.name)
    BG.optionsID = category:GetID()
    Settings.RegisterAddOnCategory(category)
    return category
end

function BG.OpenOption()
    if InCombatLockdown() then
        BG.SendSystemMessage(L['战斗中无法打开设置界面。'])
    else
        Settings.OpenToCategory(BG.optionsID)
    end
end

BG.optionsName = "BiaoGe"
BG.Init(function()
    local main = CreateFrame("Frame", nil, UIParent)
    do
        main:Hide()
        main.name = BG.optionsName
        BG.AddOption(main)
        local t = main:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 16, "OUTLINE")
        t:SetText("|cff" .. "00BFFF" .. L["<BiaoGe> 金团表格"] .. "|r")
        t:SetPoint("TOPLEFT", main, 15, 0)
        local top = t
        local t = main:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
        t:SetText(L["|cff808080（带*的设置需要重载才能生效）|r"])
        t:SetPoint("BOTTOMLEFT", top, "BOTTOMRIGHT", 5, 0)
        -- 重载
        local rlButton = BG.CreateButton(main)
        rlButton:SetSize(80, 20)
        rlButton:SetPoint("TOPRIGHT", -5, 0)
        rlButton:SetText(L["重载界面"])
        rlButton:SetScript("OnClick", function(self)
            ReloadUI()
        end)
        rlButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self:GetText(), 1, 1, 1, true)
            GameTooltip:AddLine(L["不能即时生效的设置在重载后生效。"], 1, .82, 0, true)
            GameTooltip:Show()
        end)
        rlButton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        -- 重置配置
        local bt = BG.CreateButton(main)
        bt:SetSize(80, 20)
        bt:SetPoint("RIGHT", rlButton, "LEFT", -10, 0)
        bt:SetText(L["重置配置"])
        bt:SetScript("OnClick", function(self)
            if not StaticPopupDialogs["BiaoGe_ResetOptions"] then
                StaticPopupDialogs["BiaoGe_ResetOptions"] = {
                    text = L["确认重置BiaoGe插件的所有配置文件？包括心愿清单、历史表格、角色总览、设置选项等等全部都会被重置。"],
                    button1 = L["是"],
                    button2 = L["否"],
                    OnAccept = function()
                        BiaoGe = nil
                        ReloadUI()
                    end,
                    OnCancel = function()
                    end,
                    timeout = 0,
                    whileDead = true,
                    hideOnEscape = true,
                    showAlert = true,
                }
            end
            StaticPopup_Show("BiaoGe_ResetOptions")
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self:GetText(), 1, 1, 1, true)
            GameTooltip:AddLine(L["重置BiaoGe插件的所有配置文件，包括心愿清单、历史表格、角色总览、设置选项等等全部都会被重置。"], 1, 0.82, 0, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        -- 打开角色总览
        do
            local bt = BG.CreateButton(main)
            bt:SetSize(170, 22)
            bt:SetPoint("TOPRIGHT", -5, -35)
            bt:SetText(L["打开角色总览"])
            bt:SetScript("OnClick", function(self)
                BG.SetFBCD(nil, nil, true)
            end)
        end
    end
    -- 背景框
    do
        local f = CreateFrame("Frame", nil, main, "BackdropTemplate")
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        f:SetBackdropColor(0, 0, 0, 0.4)
        f:SetPoint("TOPLEFT", SettingsPanel.Container, 5, -60)
        f:SetPoint("BOTTOMRIGHT", SettingsPanel.Container, -5, 0)
        BG.optionsBackground = f
    end

    -- 子选项
    local Frames = {}
    local base, roleOverview, config
    do
        local last

        function BG.OptionsCreateTab(name, text) -- "Options_biaoge",L["表格"]
            local bt = CreateFrame("Button", "BG.Button" .. name, main)
            bt:SetHeight(25)
            bt:SetNormalFontObject(BG.FontBlue15)
            bt:SetDisabledFontObject(BG.FontWhite18)
            bt:SetHighlightFontObject(BG.FontWhite15)
            local tex = bt:CreateTexture(nil, "ARTWORK") -- 高亮材质
            tex:SetTexture("interface/paperdollinfoframe/ui-character-tab-highlight")
            bt:SetHighlightTexture(tex)
            if not last then
                bt:SetPoint("TOPLEFT", 15, -35)
            else
                bt:SetPoint("LEFT", last, "RIGHT", 0, 0)
            end
            bt:SetText(text)
            local t = bt:GetFontString()
            bt:SetWidth(t:GetStringWidth() + 20)
            BG["Button" .. name] = bt
            last = bt
            bt:SetScript("OnClick", function(self)
                BG.HideTab(Frames, BG["Frame" .. name])
                BiaoGe.options.lastFrame = "Frame" .. name
                BG.PlaySound(1)
            end)

            local f = CreateFrame("Frame", nil, bt)
            tinsert(Frames, f)
            f:Hide()
            BG["Frame" .. name] = f
            local frame = CreateFrame("Frame", nil, f)
            frame:SetSize(1, 1)
            local scroll = CreateFrame("ScrollFrame", nil, f, BG.scrollTemplate)
            local frameName = "Frame" .. name
            scroll:SetPoint("TOPLEFT", SettingsPanel.Container, 15, -70)
            scroll:SetPoint("BOTTOMRIGHT", SettingsPanel.Container, -35, 10)
            scroll.ScrollBar.scrollStep = BG.scrollStep
            BG.CreateSrollBarBackdrop(scroll.ScrollBar)
            BG.HookScrollBarShowOrHide(scroll)
            scroll:SetScrollChild(frame)
            frame.scroll = scroll
            BiaoGe.options.optionsScrollPosition = BiaoGe.options.optionsScrollPosition or {}
            scroll:HookScript("OnVerticalScroll", function(self, offset)
                BiaoGe.options.optionsScrollPosition[frameName] = offset
            end)
            f:HookScript("OnShow", function()
                BG.After(0, function()
                    if not f:IsShown() then return end
                    local offset = BiaoGe.options.optionsScrollPosition[frameName] or 0
                    local _, maxOffset = scroll.ScrollBar:GetMinMaxValues()
                    scroll:SetVerticalScroll(min(offset, maxOffset))
                end)
            end)
            scroll:HookScript("OnMouseDown", function(self, enter)
                local f = GetCurrentKeyBoardFocus()
                if f then
                    f:ClearFocus()
                end
            end)
            return frame
        end

        base = BG.OptionsCreateTab("Options_base", L["常规"])
        roleOverview = BG.OptionsCreateTab("Options_roleOverview", L["显示内容"])
        config = BG.OptionsCreateTab("Options_config", L["角色管理"])

        BG.Init2(function()
            if BiaoGe.options.lastFrame and BG[BiaoGe.options.lastFrame] then
                BG[BiaoGe.options.lastFrame]:Show()
                BG[BiaoGe.options.lastFrame]:GetParent():SetEnabled(false)
            else
                BG.FrameOptions_roleOverview:Show()
                BG.FrameOptions_roleOverview:GetParent():SetEnabled(false)
            end
        end)
    end

    -- 模板
    do
        -- 滑块
        do
            local function OnValueChanged(self, value)
                value = Round(tonumber(value), 2)
                BiaoGe.options[self.name] = value
                self.Text:SetText(value)
                local minValue, maxValue = self:GetMinMaxValues()
                if value == minValue then
                    self.leftButton:Disable()
                else
                    self.leftButton:Enable()
                end
                if value == maxValue then
                    self.rightButton:Disable()
                else
                    self.rightButton:Enable()
                end
            end
            local function Button_OnClick(self)
                local slider = self:GetParent()
                local value = slider:GetValue()
                if self.type == "left" then
                    slider:SetValue(value - slider.step)
                else
                    slider:SetValue(value + slider.step)
                end
                BG.PlaySound(1)
            end
            function O.CreateSlider(name, text, parent, minValue, maxValue, step, x, y, ontext, width, isSmall)
                local f = CreateFrame("Frame", nil, parent)
                f:SetSize(30, 30)
                f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
                local t = f:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("CENTER")
                t:SetTextColor(1, 1, 1)
                t:SetText(text)
                f:SetWidth(t:GetStringWidth())
                f:SetScript("OnEnter", function(self)
                    if ontext then
                        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
                        GameTooltip:ClearLines()
                        for i, text in ipairs(ontext) do
                            if i == 1 then
                                GameTooltip:AddLine(text, 1, 1, 1, true)
                            else
                                GameTooltip:AddLine(text, 1, 0.82, 0, true)
                            end
                        end
                        GameTooltip:Show()
                    end
                end)
                f:SetScript("OnLeave", GameTooltip_Hide)
                f:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" and BiaoGe.options[name .. "reset"] then
                        self.slider:SetValue(BiaoGe.options[name .. "reset"])
                    end
                end)

                local slider = CreateFrame("Slider", nil, f, "MinimalSliderTemplate")
                slider:SetPoint("LEFT", f, "RIGHT", isSmall and 20 or 30, 0)
                slider:SetWidth(width or 150)
                slider:SetMinMaxValues(minValue, maxValue)
                slider:SetValueStep(step)
                slider:SetObeyStepOnDrag(true)
                slider:SetHitRectInsets(0, 0, 0, 0)
                slider:SetValue(BiaoGe.options[name])
                slider.name = name
                slider.step = step
                f.slider = slider
                slider:SetScript("OnValueChanged", OnValueChanged)
                BG.options["button" .. name] = slider

                local bt = CreateFrame("Button", nil, slider)
                bt:SetSize(13, 19)
                bt:SetPoint("RIGHT", slider, "LEFT", -4, 0)
                bt:RegisterForClicks("AnyUp")
                bt.type = "left"
                bt:SetNormalAtlas("Minimal_SliderBar_Button_Left")
                slider.leftButton = bt
                bt:SetScript("OnClick", Button_OnClick)

                local bt = CreateFrame("Button", nil, slider)
                bt:SetSize(13, 19)
                bt:SetPoint("LEFT", slider, "RIGHT", 4, 0)
                bt:RegisterForClicks("AnyUp")
                bt.type = "right"
                bt:SetNormalAtlas("Minimal_SliderBar_Button_Right")
                slider.rightButton = bt
                bt:SetScript("OnClick", Button_OnClick)

                local t = slider:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("LEFT", slider, "RIGHT", isSmall and 20 or 30, 0)
                t:SetTextColor(1, .82, 0)
                t:SetText(BiaoGe.options[name])
                slider.Text = t

                return slider, f
            end
        end
        -- 多选按钮
        do
            local function OnClick(self)
                if self:GetChecked() then
                    BiaoGe.options[self.name] = 1
                else
                    BiaoGe.options[self.name] = 0
                end
                if self.child then
                    for _, f in pairs(self.child) do
                        f:SetShown(self:GetChecked())
                    end
                end
                if self.callback then
                    local func, arg1, arg2, arg3, arg4, arg5 = unpack(self.callback)
                    func(arg1, arg2, arg3, arg4, arg5)
                end
                BG.PlaySound(1)
            end
            local function OnEnter(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
                GameTooltip:ClearLines()
                if type(self.ontext) == "table" then
                    for i, text in ipairs(self.ontext) do
                        if i == 1 then
                            GameTooltip:AddLine(text, 1, 1, 1, true)
                        else
                            GameTooltip:AddLine(text, 1, 0.82, 0, true)
                        end
                        GameTooltip:Show()
                    end
                else
                    GameTooltip:SetText(self.ontext)
                end
            end
            local function OnLeave(self)
                GameTooltip:Hide()
            end
            local function OnShow(self)
                self:SetChecked(BiaoGe.options[self.name] == 1)
            end
            function O.CreateCheckButton(name, text, parent, x, y, ontext, long, callback)
                local bt = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
                bt:SetSize(30, 30)
                bt:SetPoint("TOPLEFT", parent, x, y)
                bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                bt.Text:SetText(text)
                bt.Text:SetWordWrap(false)
                bt.Text:SetWidth(min(bt.Text:GetStringWidth() + 20, (type(long) == 'number' and long) or (long and 500 or 160)))
                bt:SetHitRectInsets(0, -bt.Text:GetWidth(), 0, 0)
                bt.name = name
                bt.ontext = ontext
                bt.callback = callback
                BG.options["button" .. name] = bt
                bt:SetChecked(BiaoGe.options[name] == 1)
                bt:SetScript("OnClick", OnClick)
                bt:SetScript("OnEnter", OnEnter)
                bt:SetScript("OnLeave", OnLeave)
                bt:SetScript("OnShow", OnShow)
                return bt
            end
        end
        -- 输入框
        do
            function O.CreateEditBox(name, text, parent, x, y, isNumeric, callback, width)
                local t = parent:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("TOPLEFT", parent, x, y)
                t:SetTextColor(1, 1, 1)
                t:SetText(text)
                BG.options["Text" .. name] = t

                local edit = CreateFrame("EditBox", nil, parent, BG.editTemplate)
                edit:SetSize(width or 50, 20)
                edit:SetPoint("LEFT", t, "RIGHT", 10, 0)
                edit:SetText(BiaoGe.options[name] or (isNumeric and 0 or ""))
                edit:SetAutoFocus(false)
                edit:SetNumeric(isNumeric)
                BG.SetEditBaseClass(edit)
                BG.options["button" .. name] = edit
                edit:SetScript("OnTextChanged", function(self)
                    local value = self:GetText()
                    if isNumeric then
                        value = tonumber(value) or 0
                    end
                    BiaoGe.options[name] = value
                    if callback then
                        callback(self, value)
                    end
                end)

                return edit
            end
        end
        -- 线
        do
            function O.CreateLine(parent, y, height)
                local l = parent:CreateLine()
                l:SetColorTexture(RGB("808080", 1))
                l:SetStartPoint("TOPLEFT", 5, y)
                l:SetEndPoint("TOPLEFT", SettingsPanel.Container:GetWidth() - 20, y)
                l:SetThickness(height or 1.5)
                return l
            end
        end
        -- 快捷键
        do
            function O.CreateBindKey(parent, x, y, wdith, bindKey, name)
                local bt = BG.CreateButton(parent)
                bt:SetSize(wdith or 150, 25)
                bt.bindKey = bindKey
                bt:SetScript("OnClick", function(self)
                    local category
                    for i, v in pairs(SettingsPanel:GetAllCategories()) do
                        if v.name == SETTINGS_KEYBINDINGS_LABEL then
                            category = v
                            break
                        end
                    end
                    if category then
                        SettingsPanel:SelectCategory(category)
                        SettingsPanel.Container.SettingsList.ScrollBox:ScrollToEnd()
                        for _, f in pairs({ SettingsPanel.Container.SettingsList.ScrollBox.ScrollTarget:GetChildren() }) do
                            if f.Button and f.Button.Text and f.Button.Text:GetText() == AddonName then
                                local initializer = f:GetElementData()
                                local data = initializer.data
                                data.expanded = nil;
                                f.Button:Click()
                            end
                        end
                        BG.After(0, function()
                            SettingsPanel.Container.SettingsList.ScrollBox:ScrollToEnd()
                        end)
                    end
                end)
                bt:SetScript("OnShow", function(self)
                    local key1, key2 = GetBindingKey(self.bindKey)
                    if key1 or key2 then
                        bt:SetText(key1 or key2)
                    else
                        bt:SetText(L["无"])
                    end
                end)
                local f = CreateFrame("Frame", nil, parent)
                f:SetSize(20, 20)
                f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
                local t = f:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("CENTER")
                t:SetText(name)
                f:SetWidth(t:GetStringWidth())
                bt:SetPoint("LEFT", f, "RIGHT", 15, 0)
            end
        end
        -- 下拉菜单
        do
            function O.CreateDropDown(name, text, parent, tbl, x, y, callback, width)
                local t = parent:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("TOPLEFT", parent, x, y)
                t:SetTextColor(1, 1, 1)
                t:SetText(text)
                BG.options["Text" .. name] = t

                local function GetText(key)
                    for _, v in ipairs(tbl) do
                        if v.key == key then
                            return v.text
                        end
                    end
                end

                local dropDown = LibBG:Create_UIDropDownMenu(nil, parent)
                dropDown:SetPoint("LEFT", t, "RIGHT", -10, -3)
                LibBG:UIDropDownMenu_SetWidth(dropDown, width or 150)
                LibBG:UIDropDownMenu_SetText(dropDown, GetText(BiaoGe.options[name]))
                LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "TOP", dropDown, "BOTTOM")
                BG.dropDownToggle(dropDown)
                BG.options["button" .. name] = dropDown

                LibBG:UIDropDownMenu_Initialize(dropDown, function(self, level)
                    for _, v in ipairs(tbl) do
                        local option = v
                        local info = LibBG:UIDropDownMenu_CreateInfo()
                        info.text = option.text
                        info.func = function()
                            BiaoGe.options[name] = option.key
                            LibBG:UIDropDownMenu_SetText(dropDown, GetText(option.key))
                            if callback then
                                callback(dropDown, option.key, option)
                            end
                        end
                        info.checked = BiaoGe.options[name] == option.key
                        LibBG:UIDropDownMenu_AddButton(info)
                    end
                end)

                return dropDown
            end
        end
    end

    local function SetParent(self, key)
        if BiaoGe.options[key] ~= 1 then
            self:Hide()
        end
        local parent = BG.options["button" .. key]
        parent.child = parent.child or {}
        tinsert(parent.child, self)
        if not parent.hookDisable then
            parent.hookDisable = true
            hooksecurefunc(parent, "Disable", function()
                if parent.Text then
                    parent.Text:SetTextColor(.5, .5, .5)
                end
                for i, child in ipairs(parent.child) do
                    child:Hide()
                end
            end)
        end
    end
    --------------------------------------------------------------------------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------------------------------------------------------------

    -- 常规
    do
        local parent = base
        local height = 0
        local h = 10

        -- UI缩放
        do
            local name = "roleOverviewScale"
            BG.options[name .. "reset"] = 1
            BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]
            local ontext = nil
            local f = O.CreateSlider(name, (L["UI缩放："]), parent, 0.5, 1.5, 0.01, 15, height - h, ontext)
            f:HookScript("OnValueChanged", function(self, value)
                BG.UpdateFBCDFrameScale()
            end)
        end
        h = h + 30
        -- 背景透明度
        do
            local name = "roleOverviewAlpha"
            BG.options[name .. "reset"] = .9
            BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]
            local ontext = nil
            local f = O.CreateSlider(name, (L["背景透明度："]), parent, 0.1, 1.0, 0.01, 15, height - h, ontext)
            f:HookScript("OnValueChanged", function(self, value)
                if BG.FBCDFrame then
                    BG.FBCDFrame:SetBackdropColor(0, 0, 0, value)
                end
            end)
        end
        h = h + 35
        -- 快捷键
        do
            O.CreateBindKey(parent, 15, -h, nil, "RoleOverview", L["快捷键："])
        end

        h = h + 35
        -- 排序
        do
            local name = "roleOverviewSort1"
            BG.options[name .. "reset"] = "iLevel-class-player"
            BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]
            local tbl = {
                { key = "iLevel-class-player", text = L["装等-职业-名字"] },
                { key = "class-iLevel-player", text = L["职业-装等-名字"] },
                { key = "iLevel-player", text = L["装等-名字"] },
                { key = "class-player", text = L["职业-名字"] },
                { key = "player", text = L["名字"] },
                { key = "custom", text = L["自定义排序"] },
            }

            local dropDown = O.CreateDropDown(name, L["排序方式："], parent, tbl, 15, -h,
                function(self, key)
                    if key == "custom" and BG.InitializeRoleOverviewCustomSort then
                        BG.InitializeRoleOverviewCustomSort()
                    elseif BG.RoleOverviewSortFrame and BG.RoleOverviewSortFrame:IsVisible() then
                        BG.RoleOverviewSortFrame:Hide()
                    end
                    self.bt:SetShown(key == "custom")
                    BG.RefreshFBCDFrame()
                end)

            dropDown.bt = BG.CreateButton(dropDown)
            dropDown.bt:SetSize(100, 25)
            dropDown.bt:SetPoint("LEFT", dropDown, "RIGHT", 0, 3)
            dropDown.bt:SetText(L["修改排序"])
            dropDown.bt:SetShown(BiaoGe.options[name] == "custom")
            dropDown.bt:SetScript("OnClick", function(self)
                BG.PlaySound(1)
                if BG.RoleOverviewSortFrame and BG.RoleOverviewSortFrame:IsVisible() then
                    BG.RoleOverviewSortFrame:Hide()
                else
                    BG.CreateRoleOverviewSortFrame(self)
                end
            end)
        end

        h = h + 35
        -- 默认显示
        do
            local name = "roleOverviewDefaultShow"
            BG.options[name .. "reset"] = "one"
            BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]
            local tbl = {
                { key = "one", text = L["当前服务器角色"] },
                { key = "all", text = L["全部服务器角色"] },
            }

            O.CreateDropDown(name, L["默认显示："], parent, tbl, 15, -h,
                function()
                    BG.RefreshFBCDFrame()
                end)
        end

        h = h + 35
        -- 布局
        do
            local name = "roleOverviewLayout"
            if BG.IsRetail then
                BG.options[name .. "reset"] = "new"
            else
                BG.options[name .. "reset"] = "up_down"
            end
            BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]
            local tbl = {
                { key = "up_down", text = L["横向布局1"] },
                { key = "left_right", text = L["横向布局2"] },
                { key = "new", text = L["竖向布局"] },
            }

            O.CreateDropDown(name, L["布局方式："], parent, tbl, 15, -h,
                function()
                    BG.RefreshFBCDFrame()
                end)
        end

        h = h + 35
        -- 屏蔽等级
        do
            local name = "roleOverviewNotShowLevel"
            BG.options[name .. "reset"] = 0
            BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]

            O.CreateEditBox(name, L["仅显示高于该等级的角色："], parent, 15, -h, true)
        end

        h = h + 35
        -- 屏蔽装等
        do
            local name = "roleOverviewNotShowiLevel"
            BG.options[name .. "reset"] = 0
            BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]

            O.CreateEditBox(name, L["仅显示高于该装等的角色："], parent, 15, -h, true)
        end

        h = h + 30
        -- 团本CD显示为BOSS击杀数量
        do
            local name = "showRaidCDKillNum"
            BG.options[name .. "reset"] = BG.IsRetail and 1 or 0
            BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]
            local ontext = {
                L["团本CD显示为BOSS击杀数量"],
                L["没全通的副本，现在会显示击杀的BOSS数量，而不是显示一个绿色钩子。"],
            }
            O.CreateCheckButton(name, L["团本CD显示为BOSS击杀数量"], base, 15, -h, ontext, true, { BG.RefreshFBCDFrame })
        end

        -- 显示牌子总上限
        if BG.IsMOP then
            h = h + 30
            local name = "showCurrencyTop"
            local ontext = {
                L["显示牌子总上限"],
                L["像勇气点数、征服点数有总上限的牌子，在角色总览里会显示其总上限。"],
            }
            O.CreateCheckButton(name, L["显示牌子总上限"] .. L["（需重载）"], base, 15, -h, ontext, true, { BG.RefreshFBCDFrame })
        end

        h = h + 30
        -- 显示其他装备部位
        do
            local name = "roleOverviewShowOtherEquip"
            BiaoGe.options[name] = BiaoGe.options[name] or 0
            local choiceName = "roleOverviewOtherEquipSlots"
            if type(BiaoGe.options[choiceName]) ~= "table" then
                BiaoGe.options[choiceName] = {}
            end
            local ontext = {
                L["显示其他装备部位"],
                L["在饰品后面增加显示其他装备部位。"],
            }
            local f = O.CreateCheckButton(name, AddTexture('QUEST') .. L["显示其他装备部位"], base, 15, -h, ontext, true, { BG.RefreshFBCDFrame })

            local chooseBT = BG.CreateButton(f)
            chooseBT:SetSize(120, 22)
            chooseBT:SetPoint("LEFT", f.Text, "RIGHT", 0, 0)
            SetParent(chooseBT, name)

            local function UpdateChooseButtonText()
                local count = 0
                for _, equipInfo in ipairs(BG.RoleOverviewOtherEquipSlots) do
                    if BiaoGe.options[choiceName][equipInfo.id] == 1 then
                        count = count + 1
                    end
                end
                local color = count == 0 and "808080" or "00ff00"
                chooseBT:SetText(format("%s(|cff%s%d|r)", L["选择部位"], color, count))
            end
            UpdateChooseButtonText()

            local chooseFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            chooseFrame:SetPoint("TOPLEFT", chooseBT, "BOTTOMLEFT", 0, -5)
            chooseFrame:SetSize(230, 195)
            chooseFrame:SetFrameStrata("DIALOG")
            chooseFrame:SetClampedToScreen(true)
            chooseFrame:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                edgeSize = 16,
                insets = { left = 3, right = 3, top = 3, bottom = 3 },
            })
            chooseFrame:SetBackdropColor(0, 0, 0, .95)
            chooseFrame:SetBackdropBorderColor(.5, .5, .5)
            chooseFrame:Hide()

            local closeBT = CreateFrame("Button", nil, chooseFrame, "UIPanelCloseButton")
            closeBT:SetPoint("TOPRIGHT", 2, 2)

            local title = chooseFrame:CreateFontString()
            title:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            title:SetPoint("TOP", 0, -7)
            title:SetText(L["显示其他装备部位"])
            title:SetTextColor(1, 1, 1)

            for i, equipInfo in ipairs(BG.RoleOverviewOtherEquipSlots) do
                local bt = CreateFrame("CheckButton", nil, chooseFrame, "ChatConfigCheckButtonTemplate")
                local column = floor((i - 1) / 6)
                local row = (i - 1) % 6
                bt:SetPoint("TOPLEFT", 10 + column * 110, -30 - row * 25)
                bt:SetSize(25, 25)
                bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                bt.Text:SetText(equipInfo.name)
                bt.Text:SetTextColor(1, .82, 0)
                bt:SetHitRectInsets(0, -75, 0, 0)
                bt:SetChecked(BiaoGe.options[choiceName][equipInfo.id] == 1)
                bt:SetScript("OnClick", function(self)
                    if self:GetChecked() then
                        BiaoGe.options[choiceName][equipInfo.id] = 1
                    else
                        BiaoGe.options[choiceName][equipInfo.id] = nil
                    end
                    UpdateChooseButtonText()
                    BG.RefreshFBCDFrame()
                    BG.PlaySound(1)
                end)
            end

            chooseBT:SetScript("OnClick", function()
                BG.PlaySound(1)
                chooseFrame:SetShown(not chooseFrame:IsShown())
            end)
            chooseBT:HookScript("OnHide", function()
                chooseFrame:Hide()
            end)
        end

        h = h + 30
        -- 备注
        do
            local name = "roleOverviewShowNote"
            BiaoGe.options[name] = BiaoGe.options[name] or 0
            local ontext = {
                L["显示角色备注"],
                L["在角色名字后面，增加显示一段自定义文本。"],
                " ",
                L["使用方法：/BGR，把角色总览面板固定，然后鼠标点击角色对应的备注栏即可修改备注。"]
            }
            local f = O.CreateCheckButton(name, L["显示角色备注"], base, 15, -h, ontext, true, { BG.RefreshFBCDFrame })

            local t = f:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            t:SetPoint("LEFT", f.Text, "RIGHT", 10, 0)
            t:SetTextColor(1, 1, 1)
            t:SetText(L["文本宽度："])
            SetParent(t, "roleOverviewShowNote")

            local miniWidth = 60
            local name2 = "roleOverviewShowNote_width"
            BiaoGe.options[name2] = BiaoGe.options[name2] or 100
            local edit = CreateFrame("EditBox", nil, f, BG.editTemplate)
            edit:SetSize(100, 20)
            edit:SetPoint("LEFT", t, "RIGHT", 5, 0)
            edit:SetText(BiaoGe.options[name2])
            edit:SetAutoFocus(false)
            edit:SetNumeric(true)
            BG.SetEditBaseClass(edit)
            SetParent(edit, "roleOverviewShowNote")
            edit:SetScript("OnTextChanged", function(self)
                BiaoGe.options[name2] = max(miniWidth, tonumber(self:GetText()) or 0)
            end)

            local t = f:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            t:SetPoint("LEFT", edit, "RIGHT", 20, 0)
            t:SetTextColor(1, 1, 1)
            t:SetText(L["文本使用职业颜色："])
            SetParent(t, "roleOverviewShowNote")

            local name3 = "roleOverviewShowNote_useClassColor"
            BiaoGe.options[name3] = BiaoGe.options[name3] or 1
            local buttons = {}
            local numOptions = {
                { name = L["是"], key = 1, },
                { name = L["否"], key = 0, },
            }
            for i = 1, #numOptions do
                local bt = CreateFrame("CheckButton", nil, f, "UIRadioButtonTemplate")
                bt:SetPoint("LEFT", t, "RIGHT", (i - 1) * 40 + 2, -1)
                bt:SetSize(15, 15)
                SetParent(bt, "roleOverviewShowNote")
                tinsert(buttons, bt)
                bt.Text = bt:CreateFontString()
                bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                bt.Text:SetPoint("LEFT", bt, "RIGHT", 0, 0)
                bt.Text:SetText(numOptions[i].name)
                bt.Text:SetTextColor(1, .82, 0)
                bt:SetHitRectInsets(0, -bt.Text:GetWidth(), -5, -5)
                if numOptions[i].key == BiaoGe.options[name3] then
                    bt:SetChecked(true)
                    bt.Text:SetTextColor(0, 1, 0)
                end
                bt:SetScript("OnClick", function(self)
                    BG.PlaySound(1)
                    for _, radioButton in ipairs(buttons) do
                        if radioButton ~= self then
                            radioButton:SetChecked(false)
                            radioButton.Text:SetTextColor(1, .82, 0)
                        end
                    end
                    self:SetChecked(true)
                    self.Text:SetTextColor(0, 1, 0)
                    BiaoGe.options.roleOverviewShowNote_useClassColor = numOptions[i].key
                end)
            end
        end

        h = h + 30
        -- 显示专精图标
        do
            local name = "roleOverviewShowTalent"
            BiaoGe.options[name] = BiaoGe.options[name] or 1
            local ontext = {
                L["显示角色专精"],
                L["在角色名字前面增加显示专精图标。"],
            }
            O.CreateCheckButton(name, L["显示角色专精"], base, 15, -h, ontext, true, { BG.RefreshFBCDFrame })
        end

        h = h + 30
        -- 显示阵营
        do
            local name = "roleOverviewShowFaction"
            BiaoGe.options[name] = BiaoGe.options[name] or 0
            local ontext = {
                L["显示角色阵营"],
                L["角色装等和等级会根据阵营染色为浅蓝色（联盟）或浅红色（部落），用来区分该角色是哪个阵营。"],
            }
            O.CreateCheckButton(name, L["显示角色阵营"], base, 15, -h, ontext, true, { BG.RefreshFBCDFrame })
        end

        h = h + 30
        -- 使用黑白着色
        do
            local name = "roleOverviewblackWhite"
            BiaoGe.options[name] = BiaoGe.options[name] or 0
            local ontext = {
                L["使用黑白着色"],
                L["勾选后每行使用黑白着色。否则使用下横线作分割。该选项仅对横向布局有效。"],
            }
            O.CreateCheckButton(name, L["使用黑白着色"], base, 15, -h, ontext, true, { BG.RefreshFBCDFrame })
        end
    end

    do
        local h = 0

        -- 创建多选按钮
        local lastFrame
        local titles = {}
        local frameWidth = roleOverview.scroll:GetWidth() - 20
        local frameHeight = 25
        local function CreateFBCDbutton(n1, n2, collapse, tblName, dbName)
            local right
            local first
            local buttonWidth = 100
            local buttonHeight = 25
            local row = 1
            tblName = tblName or "FBCDall_table"
            dbName = dbName or "FBCDchoice"
            for i = n1, n2 do
                local name = dbName == "FBCDchoice" and BG[tblName][i].name or BG[tblName][i].id
                local name2 = BG[tblName][i].name2
                local color = BG[tblName][i].color
                local fbId = BG[tblName][i].fbId
                local type = BG[tblName][i].type
                local diff = BG.GetDiffShortName(BG[tblName][i].diff) or ""
                local bt = CreateFrame("CheckButton", nil, lastFrame.child2, "ChatConfigCheckButtonTemplate")
                bt:SetSize(buttonHeight, buttonHeight)
                bt:SetHitRectInsets(0, -buttonWidth + 45, 0, 0)
                if not right then
                    bt:SetPoint("TOPLEFT", 0, -5)
                    first = bt
                elseif roleOverview.scroll:GetRight() - right.Text:GetRight() > buttonWidth then
                    bt:SetPoint("TOPLEFT", right, "TOPLEFT", buttonWidth, 0)
                else
                    bt:SetPoint("TOPLEFT", first, "BOTTOMLEFT", 0, 0)
                    first = bt
                    row = row + 1
                end
                right = bt
                bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                bt.Text:SetText("|cff" .. color .. diff .. (name2 or name):gsub("sod", "") .. RR)
                bt.Text:SetWidth(buttonWidth - buttonHeight)
                bt.Text:SetWordWrap(false)
                if not BiaoGe[dbName][name] or BiaoGe[dbName][name] == 0 then
                    BiaoGe[dbName][name] = nil
                    bt:SetChecked(false)
                else
                    BiaoGe[dbName][name] = 1
                    bt:SetChecked(true)
                end
                bt:SetScript("OnClick", function(self)
                    if self:GetChecked() then
                        BiaoGe[dbName][name] = 1
                    else
                        BiaoGe[dbName][name] = nil
                    end
                    BG.RefreshFBCDFrame()
                    BG.PlaySound(1)
                end)
                bt:SetScript("OnEnter", function(self)
                    local text
                    if dbName == "FBCDchoice" then
                        local maxplayers = BG[tblName][i].num and (BG[tblName][i].num .. L["人"]) or ""
                        text = "|cff" .. color .. maxplayers .. diff .. (name2 or GetRealZoneText(fbId)) .. RR
                        if type ~= "fb" then
                            text = self.Text:GetText()
                        end
                    else
                        text = self.Text:GetText()
                    end
                    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
                    GameTooltip:ClearLines()
                    GameTooltip:SetText(text)
                end)
                bt:SetScript("OnLeave", GameTooltip_Hide)
            end
            lastFrame.height = buttonHeight * row + 5
            lastFrame.child:SetHeight(lastFrame.height)
            if collapse then
                lastFrame:GetScript("OnMouseDown")(lastFrame)
            end
        end
        local function CreateMONEYbutton(n1, n2, hide)
            local right
            local first
            local buttonWidth = 65
            local buttonHeight = 25
            local row = 1
            for i = n1, n2 do
                local name = BG.MONEYall_table[i].name
                local tex = BG.MONEYall_table[i].tex
                local color = BG.MONEYall_table[i].color
                local id = BG.MONEYall_table[i].id
                local itemType = BG.MONEYall_table[i].type
                local bt = CreateFrame("CheckButton", nil, lastFrame.child2, "ChatConfigCheckButtonTemplate")
                bt:SetSize(buttonHeight, buttonHeight)
                bt:SetHitRectInsets(0, -buttonWidth + 40, 0, 0)
                if not right then
                    bt:SetPoint("TOPLEFT", 0, -5)
                    first = bt
                elseif roleOverview.scroll:GetRight() - right.Text:GetRight() > buttonWidth then
                    bt:SetPoint("TOPLEFT", right, "TOPLEFT", buttonWidth, 0)
                else
                    bt:SetPoint("TOPLEFT", first, "BOTTOMLEFT", 0, 0)
                    first = bt
                    row = row + 1
                end
                right = bt
                bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                bt.Text:SetText(AddTexture(tex))
                if not BiaoGe.MONEYchoice[id] or BiaoGe.MONEYchoice[id] == 0 then
                    BiaoGe.MONEYchoice[id] = nil
                    bt:SetChecked(false)
                else
                    BiaoGe.MONEYchoice[id] = 1
                    bt:SetChecked(true)
                end
                bt:SetScript("OnClick", function(self)
                    if self:GetChecked() then
                        BiaoGe.MONEYchoice[id] = 1
                    else
                        BiaoGe.MONEYchoice[id] = nil
                    end
                    BG.RefreshFBCDFrame()
                    BG.PlaySound(1)
                end)
                bt:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
                    GameTooltip:ClearLines()
                    GameTooltip:SetText("|cff" .. color
                        .. (itemType and (itemType:find('item') or itemType:find('equip')) and L['物品：'] or '')
                        .. name .. RR)
                end)
                bt:SetScript("OnLeave", GameTooltip_Hide)
            end
            lastFrame.height = buttonHeight * row + 5
            lastFrame.child:SetHeight(lastFrame.height)
            if hide then
                lastFrame:GetScript("OnMouseDown")(lastFrame)
            end
        end
        local function CreateTitle(name, color)
            local frame = CreateFrame("Frame", nil, roleOverview, "BackdropTemplate")
            frame:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
            })
            frame:SetBackdropColor(0, 0, 0, 0)
            if lastFrame then
                frame:SetPoint("TOPLEFT", lastFrame.child, "BOTTOMLEFT", 0, 0)
            else
                frame:SetPoint("TOPLEFT", 15, -h)
            end
            frame:SetSize(frameWidth, frameHeight)
            frame.name = name
            tinsert(titles, frame)
            frame.tex = frame:CreateTexture()
            frame.tex:SetPoint("BOTTOMLEFT", 0, 0)
            frame.tex:SetSize(18, 18)
            frame.tex:SetTexture(130821)
            frame.text = frame:CreateFontString()
            frame.text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            frame.text:SetPoint("LEFT", frame.tex, "RIGHT", 2, 0)
            frame.text:SetText(name)
            frame.open = true
            if type(color) == "table" then
                frame.text:SetTextColor(unpack(color))
            else
                frame.text:SetTextColor(RGB(color))
            end
            local l = frame:CreateLine()
            l:SetColorTexture(.5, .5, .5)
            l:SetStartPoint("BOTTOMLEFT", 0, 0)
            l:SetEndPoint("BOTTOMLEFT", frameWidth, 0)
            l:SetThickness(1.5)
            local child = CreateFrame("Frame", nil, frame)
            child:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0)
            child:SetSize(frameWidth, 20)
            frame.child = child
            local child2 = CreateFrame("Frame", nil, child)
            child2:SetAllPoints()
            frame.child2 = child2
            frame:SetScript("OnMouseDown", function(self, button)
                if self.open then
                    self.child2:Hide()
                    self.child:SetHeight(1)
                    self.tex:SetTexture(130838)
                    self.open = nil
                    BiaoGe.options['roleOverviewTitleCollapse' .. name] = true
                else
                    self.child2:Show()
                    self.child:SetHeight(self.height)
                    self.tex:SetTexture(130821)
                    self.open = true
                    BiaoGe.options['roleOverviewTitleCollapse' .. name] = nil
                end
                if button then
                    BG.PlaySound(1)
                end
            end)
            frame:SetScript("OnEnter", function(self)
                self:SetBackdropColor(1, 1, 0, .1)
            end)
            frame:SetScript("OnLeave", function(self)
                self:SetBackdropColor(0, 0, 0, 0)
            end)
            return frame
        end
        if BG.IsVanilla_Sod then
            local z = { 10, 3 }     -- 3是专业
            local x = {}
            for i, v in ipairs(z) do
                x[i] = (x[i - 1] or 0) + v
            end
            local startNum = 1
            lastFrame = CreateTitle(L["团本"], "00BFFF")
            CreateFBCDbutton(1, x[startNum])
            lastFrame = CreateTitle(L["专业CD"], "ADFF2F")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
        elseif BG.IsVanilla_60 then
            local z = { 7, BG.skillCount, #BG.factionTbl }     -- 3是专业
            local x = {}
            for i, v in ipairs(z) do
                x[i] = (x[i - 1] or 0) + v
            end
            local startNum = 1
            lastFrame = CreateTitle(L["团本"], "00BFFF")
            CreateFBCDbutton(1, x[startNum])
            lastFrame = CreateTitle(L["专业CD"], "ADFF2F")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
            startNum = startNum + 1
            lastFrame = CreateTitle(L["声望"], "FFFF00")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
        elseif BG.IsTBC then
            local z = { BG.FBCount, BG.dayQuestCount, #BG.factionTbl }
            local x = {}
            for i, v in ipairs(z) do
                x[i] = (x[i - 1] or 0) + v
            end
            local startNum = 1
            lastFrame = CreateTitle(L["团本"], "00BFFF")
            CreateFBCDbutton(1, x[startNum])
            lastFrame = CreateTitle(QUESTS_LABEL, "FF8C00")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
            startNum = startNum + 1
            lastFrame = CreateTitle(L["声望"], "FFFF00")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
        elseif BG.IsWLK_80 then
            local z = { 18, 11, 5, 6, 10, #BG.factionTbl }     -- 6是日常，10是专业
            local x = {}
            for i, v in ipairs(z) do
                x[i] = (x[i - 1] or 0) + v
            end
            local startNum = 1
            lastFrame = CreateTitle(EXPANSION_NAME2, "00BFFF")
            CreateFBCDbutton(1, x[startNum])
            lastFrame = CreateTitle(EXPANSION_NAME1, "FF69B4")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
            startNum = startNum + 1
            lastFrame = CreateTitle(LFG_LIST_LEGACY, "40c040")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
            startNum = startNum + 1
            lastFrame = CreateTitle(QUESTS_LABEL, "FF8C00")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
            startNum = startNum + 1
            lastFrame = CreateTitle(L["专业CD"], "ADFF2F")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
            startNum = startNum + 1
            lastFrame = CreateTitle(L["声望"], "FFFF00")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
        elseif BG.IsTitan then
            local z = { BG.FBCount, BG.dayQuestCount, BG.skillCount, #BG.factionTbl }
            local x = {}
            for i, v in ipairs(z) do
                x[i] = (x[i - 1] or 0) + v
            end
            local startNum = 1
            lastFrame = CreateTitle(L["团本"], "00BFFF")
            CreateFBCDbutton(1, x[startNum])
            lastFrame = CreateTitle(QUESTS_LABEL, "FF8C00")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
            startNum = startNum + 1
            lastFrame = CreateTitle(L["专业CD"], "ADFF2F")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
            startNum = startNum + 1
            lastFrame = CreateTitle(L["声望"], "FFFF00")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
        elseif BG.IsCTM then
            local z = { 7, 18, 11, 5, 3, #BG.factionTbl }     -- 3是日常
            local x = {}
            for i, v in ipairs(z) do
                x[i] = (x[i - 1] or 0) + v
            end
            local startNum = 1
            lastFrame = CreateTitle(EXPANSION_NAME3, "FF4500")
            CreateFBCDbutton(1, x[startNum])
            lastFrame = CreateTitle(EXPANSION_NAME2, "00BFFF")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
            startNum = startNum + 1
            lastFrame = CreateTitle(EXPANSION_NAME1, "FF69B4")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
            startNum = startNum + 1
            lastFrame = CreateTitle(LFG_LIST_LEGACY, "40c040")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
            startNum = startNum + 1
            lastFrame = CreateTitle(QUESTS_LABEL, "FF8C00")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
            startNum = startNum + 1
            lastFrame = CreateTitle(L["声望"], "FFFF00")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
        elseif BG.IsMOP then
            local z = { BG.FBCount, 7, 18, 11, 5, BG.dayQuestCount, BG.skillCount, #BG.factionTbl }
            local x = {}
            for i, v in ipairs(z) do
                x[i] = (x[i - 1] or 0) + v
            end
            local startNum = 1
            lastFrame = CreateTitle(EXPANSION_NAME4, "00FF00")
            CreateFBCDbutton(1, x[startNum])
            lastFrame = CreateTitle(EXPANSION_NAME3, "FF4500")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
            startNum = startNum + 1
            lastFrame = CreateTitle(EXPANSION_NAME2, "00BFFF")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
            startNum = startNum + 1
            lastFrame = CreateTitle(EXPANSION_NAME1, "FF69B4")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
            startNum = startNum + 1
            lastFrame = CreateTitle(LFG_LIST_LEGACY, "40c040")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
            startNum = startNum + 1
            lastFrame = CreateTitle(QUESTS_LABEL, "FF8C00")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
            startNum = startNum + 1
            lastFrame = CreateTitle(L["专业CD"], "ADFF2F")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
            startNum = startNum + 1
            lastFrame = CreateTitle(L["声望"], "FFFF00")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
        elseif BG.IsRetail then
            local z = { BG.FBCount, }
            local x = {}
            for i, v in ipairs(z) do
                x[i] = (x[i - 1] or 0) + v
            end
            local startNum = 1
            lastFrame = CreateTitle(L["团本"], "00BFFF")
            CreateFBCDbutton(1, x[startNum])
        end
        if not BG.IsRetail then
            lastFrame = CreateTitle(L["专业技能点"], BG.SKILLall_table[1].color)
            CreateFBCDbutton(1, #BG.SKILLall_table, nil, "SKILLall_table", "SKILLchoice")
        end
        lastFrame = CreateTitle(L["货币"], "FFFFFF")
        CreateMONEYbutton(1, #BG.MONEYall_table)

        for i, title in ipairs(titles) do
            if BiaoGe.options['roleOverviewTitleCollapse' .. title.name] and title.open then
                title:GetScript("OnMouseDown")(title)
            end
        end
    end

    -- 角色配置
    do
        local width = 15
        local height = 5
        local width2 = 200
        local width3 = 160
        local height2 = 450

        do
            local text = config:CreateFontString()
            text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            text:SetPoint("TOPLEFT", width, height - 15)
            text:SetText(L["角色列表"])
            text:SetTextColor(0, 1, 0)
            text:SetWidth(width2)

            local text = config:CreateFontString()
            text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            text:SetPoint("TOPLEFT", width + width2 + 15, height - 15)
            text:SetText(L["操作"])
            text:SetTextColor(0, 1, 0)
            text:SetWidth(width3)
        end

        height = height - 15

        local f, child = BG.CreateScrollFrame(config, width2, height2)
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        f:SetBackdropColor(0, 0, 0, 0.3)
        f:SetPoint("TOPLEFT", width, height - 15)

        local choose = { realmID = nil, player = nil }
        local buttons = {}

        local function UpdateDeleteButton()
            BG.options.configDeleteButton:Disable()
            if choose.realmID and choose.player then
                BG.options.configDeleteButton:Enable()
            end
        end

        -- 创建角色列表
        local function UpdateAllButtons()
            for i, bt in ipairs(buttons) do
                bt:Hide()
            end
            wipe(buttons)

            for realmID, v in pairs(BiaoGe.playerInfo) do
                if next(v) then
                    if next(BiaoGe.playerInfo[realmID]) then
                        local bt = CreateFrame("Button", nil, child)
                        if not buttons[1] then
                            bt:SetPoint("TOPLEFT", child, 0, 0)
                        else
                            bt:SetPoint("TOPLEFT", buttons[#buttons], "BOTTOMLEFT", 0, 0)
                        end
                        bt:SetNormalFontObject(BG.FontWhite15)
                        if BiaoGe.realmName[realmID] then
                            bt:SetText(BiaoGe.realmName[realmID])
                        else
                            bt:SetText(realmID)
                        end
                        bt:SetSize(child:GetWidth(), 20)
                        BG.SetTextHighlightTexture(bt)
                        tinsert(buttons, bt)
                        local t = bt:GetFontString()
                        t:SetPoint("LEFT")
                        t:SetTextColor(1, 0.82, 0)
                        bt:Disable()
                    end

                    for player in pairs(BiaoGe.playerInfo[realmID]) do
                        local bt = CreateFrame("Button", nil, child)
                        if not buttons[1] then
                            bt:SetPoint("TOPLEFT", child, 0, 0)
                        else
                            bt:SetPoint("TOPLEFT", buttons[#buttons], "BOTTOMLEFT", 0, 0)
                        end
                        bt:SetNormalFontObject(BG.FontWhite15)
                        bt:SetText("   " .. player)
                        bt:SetSize(child:GetWidth(), 20)
                        bt.realmID = realmID
                        bt.player = player
                        tinsert(buttons, bt)

                        local tex = bt:CreateTexture()
                        tex:SetAllPoints()
                        tex:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
                        bt:SetHighlightTexture(tex)

                        bt.chooseTex = bt:CreateTexture()
                        bt.chooseTex:SetAllPoints()
                        bt.chooseTex:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
                        bt.chooseTex:SetVertexColor(0, 1, 0)
                        bt.chooseTex:Hide()

                        local t = bt:GetFontString()
                        t:SetPoint("LEFT")
                        if BiaoGe.playerInfo[realmID] and BiaoGe.playerInfo[realmID][player] and BiaoGe.playerInfo[realmID][player].class then
                            local r, g, b = GetClassColor(BiaoGe.playerInfo[realmID][player].class)
                            t:SetTextColor(r, g, b)
                            tex:SetVertexColor(r, g, b)
                            bt:SetText("   " .. player .. " (" .. BiaoGe.playerInfo[realmID][player].level .. ")")
                        else
                            t:SetTextColor(.5, .5, .5)
                            tex:SetVertexColor(.5, .5, .5)
                        end

                        bt:SetScript("OnClick", function(self)
                            BG.PlaySound(1)
                            if self.isChoose then
                                choose.realmID = nil
                                choose.player = nil
                                self.isChoose = false
                                self.chooseTex:Hide()
                            else
                                for i, bt in ipairs(buttons) do
                                    bt.isChoose = false
                                    if bt.chooseTex then
                                        bt.chooseTex:Hide()
                                    end
                                end
                                choose.realmID = self.realmID
                                choose.player = self.player
                                self.isChoose = true
                                self.chooseTex:Show()
                            end
                            UpdateDeleteButton()
                        end)
                    end
                end
            end
        end
        UpdateAllButtons()


        local f = CreateFrame("Frame", nil, config, "BackdropTemplate")
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        f:SetBackdropColor(0, 0, 0, 0.3)
        f:SetSize(width3, height2)
        f:EnableMouse(true)
        f:SetPoint("TOPLEFT", width + width2 + 15, height - 15)

        -- 删除角色
        local function DeletePlayerData()
            local realmID = GetRealmID()
            local player = BG.playerName
            BG.DeletePlayerData(choose.realmID, choose.player)
            if realmID == choose.realmID and player == choose.player then
                ReloadUI()
            else
                UpdateAllButtons()
            end
        end
        local bt = BG.CreateButton(f)
        bt:SetSize(100, 25)
        bt:SetPoint("TOP", 0, -15)
        bt:SetText(L["删除角色"])
        bt:Disable()
        BG.options.configDeleteButton = bt
        bt:SetScript("OnEnter", function(self)
            local c2 = "ffFFFFFF"
            if BiaoGe.playerInfo[choose.realmID] and BiaoGe.playerInfo[choose.realmID][choose.player]
                and BiaoGe.playerInfo[choose.realmID][choose.player].class then
                c2 = select(4, GetClassColor(BiaoGe.playerInfo[choose.realmID][choose.player].class))
            end
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self:GetText(), 1, 1, 1, true)
            GameTooltip:AddLine(format(L["删除%s的全部配置文件。"],
                    "|c" .. c2 .. choose.player .. RR),
                1, 0.82, 0, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
        bt:SetScript("OnClick", function(self)
            DeletePlayerData()
            BG.PlaySound(1)
        end)
    end
end)

-- debug
BG.Init2(function(self, event, ...)
    BG.OpenOption()
end)
