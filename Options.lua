if ZL.IsBlackListPlayer then return end
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

local realmID       = GetRealmID()

local pt            = print

local O             = {}
ns.O                = O

local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded

function ZL.AddOption(frame, addOn, position)
    local category, layout = Settings.RegisterCanvasLayoutCategory(frame, frame.name, frame.name)
    ZL.optionsID = category:GetID()
    Settings.RegisterAddOnCategory(category)
    return category
end

function ZL.OpenOption()
    if InCombatLockdown() then
        ZL.SendSystemMessage(L['战斗中无法打开设置界面。'])
    else
        Settings.OpenToCategory(ZL.optionsID)
    end
end

ZL.optionsName = AddonName
ZL.Init(function()
    local main = CreateFrame("Frame", nil, UIParent)
    do
        main:Hide()
        main.name = ZL.optionsName
        ZL.AddOption(main)
        local t = main:CreateFontString()
        t:SetFont(ns.Font, 16, "OUTLINE")
        t:SetText("|cff" .. "00BFFF" .. L["<ZongLan> 角色总览"] .. "|r")
        t:SetPoint("TOPLEFT", main, 15, 0)
        local top = t
        -- local t = main:CreateFontString()
        -- t:SetFont(ns.Font, 13, "OUTLINE")
        -- t:SetText(L["|cff808080（带*的设置需要重载才能生效）|r"])
        -- t:SetPoint("BOTTOMLEFT", top, "BOTTOMRIGHT", 5, 0)
        -- 重载
        local rlButton = ZL.CreateButton(main)
        rlButton:SetSize(80, 22)
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
        local bt = ZL.CreateButton(main)
        bt:SetSize(80, 22)
        bt:SetPoint("RIGHT", rlButton, "LEFT", -10, 0)
        bt:SetText(L["重置配置"])
        bt:SetScript("OnClick", function(self)
            if not StaticPopupDialogs["ZongLan_ResetOptions"] then
                StaticPopupDialogs["ZongLan_ResetOptions"] = {
                    text = L["确认重置ZongLan插件的所有配置文件？包括角色总览、设置选项等等全部都会被重置。"],
                    button1 = L["是"],
                    button2 = L["否"],
                    OnAccept = function()
                        ZongLan = nil
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
            StaticPopup_Show("ZongLan_ResetOptions")
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self:GetText(), 1, 1, 1, true)
            GameTooltip:AddLine(L["重置ZongLan插件的所有配置文件，包括角色总览、设置选项等等全部都会被重置。"], 1, 0.82, 0, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        -- 打开角色总览
        do
            local bt = ZL.CreateButton(main)
            bt:SetSize(170, 22)
            bt:SetPoint("TOPRIGHT", -5, -35)
            bt:SetText(L["打开角色总览"])
            bt:SetScript("OnClick", function(self)
                ZL.SetFBCD(nil, nil, true)
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
        ZL.optionsBackground = f
    end

    -- 子选项
    local Frames = {}
    local base, roleOverview, config
    do
        local last

        function ZL.OptionsCreateTab(name, text) -- "Options_biaoge",L["表格"]
            local bt = CreateFrame("Button", "ZL.Button" .. name, main)
            bt:SetHeight(25)
            bt:SetNormalFontObject(ZL.FontBlue15)
            bt:SetDisabledFontObject(ZL.FontWhite18)
            bt:SetHighlightFontObject(ZL.FontWhite15)
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
            ZL["Button" .. name] = bt
            last = bt
            bt:SetScript("OnClick", function(self)
                ZL.HideTab(Frames, ZL["Frame" .. name])
                ZongLan.options.lastFrame = "Frame" .. name
                ZL.PlaySound(1)
            end)

            local f = CreateFrame("Frame", nil, bt)
            tinsert(Frames, f)
            f:Hide()
            ZL["Frame" .. name] = f
            local frame = CreateFrame("Frame", nil, f)
            frame:SetSize(1, 1)
            local scroll = CreateFrame("ScrollFrame", nil, f, ZL.scrollTemplate)
            local frameName = "Frame" .. name
            scroll:SetPoint("TOPLEFT", SettingsPanel.Container, 15, -70)
            scroll:SetPoint("BOTTOMRIGHT", SettingsPanel.Container, -35, 10)
            scroll.ScrollBar.scrollStep = ZL.scrollStep
            ZL.CreateSrollBarBackdrop(scroll.ScrollBar)
            ZL.HookScrollBarShowOrHide(scroll)
            scroll:SetScrollChild(frame)
            frame.scroll = scroll
            ZongLan.options.optionsScrollPosition = ZongLan.options.optionsScrollPosition or {}
            scroll:HookScript("OnVerticalScroll", function(self, offset)
                ZongLan.options.optionsScrollPosition[frameName] = offset
            end)
            f:HookScript("OnShow", function()
                ZL.After(0, function()
                    if not f:IsShown() then return end
                    local offset = ZongLan.options.optionsScrollPosition[frameName] or 0
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

        base = ZL.OptionsCreateTab("Options_base", L["常规"])
        roleOverview = ZL.OptionsCreateTab("Options_roleOverview", L["显示内容"])
        config = ZL.OptionsCreateTab("Options_config", L["角色管理"])

        ZL.Init2(function()
            if ZongLan.options.lastFrame and ZL[ZongLan.options.lastFrame] then
                ZL[ZongLan.options.lastFrame]:Show()
                ZL[ZongLan.options.lastFrame]:GetParent():SetEnabled(false)
            else
                ZL.FrameOptions_roleOverview:Show()
                ZL.FrameOptions_roleOverview:GetParent():SetEnabled(false)
            end
        end)
    end

    -- 模板
    do
        -- 滑块
        do
            local function OnValueChanged(self, value)
                value = Round(tonumber(value), 2)
                ZongLan.options[self.name] = value
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
                ZL.PlaySound(1)
            end
            function O.CreateSlider(name, text, parent, minValue, maxValue, step, x, y, ontext, width, isSmall)
                local f = CreateFrame("Frame", nil, parent)
                f:SetSize(30, 30)
                f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
                local t = f:CreateFontString()
                t:SetFont(ns.Font, 15, "OUTLINE")
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
                    if button == "RightButton" and ZongLan.options[name .. "reset"] then
                        self.slider:SetValue(ZongLan.options[name .. "reset"])
                    end
                end)

                local slider = CreateFrame("Slider", nil, f, "MinimalSliderTemplate")
                slider:SetPoint("LEFT", f, "RIGHT", isSmall and 20 or 30, 0)
                slider:SetWidth(width or 150)
                slider:SetMinMaxValues(minValue, maxValue)
                slider:SetValueStep(step)
                slider:SetObeyStepOnDrag(true)
                slider:SetHitRectInsets(0, 0, 0, 0)
                slider:SetValue(ZongLan.options[name])
                slider.name = name
                slider.step = step
                f.slider = slider
                slider:SetScript("OnValueChanged", OnValueChanged)
                ZL.options["button" .. name] = slider

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
                t:SetFont(ns.Font, 15, "OUTLINE")
                t:SetPoint("LEFT", slider, "RIGHT", isSmall and 20 or 30, 0)
                t:SetTextColor(1, .82, 0)
                t:SetText(ZongLan.options[name])
                slider.Text = t

                return slider, f
            end
        end
        -- 多选按钮
        do
            local function OnClick(self)
                if self:GetChecked() then
                    ZongLan.options[self.name] = 1
                else
                    ZongLan.options[self.name] = 0
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
                ZL.PlaySound(1)
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
                self:SetChecked(ZongLan.options[self.name] == 1)
            end
            function O.CreateCheckButton(name, text, parent, x, y, ontext, long, callback)
                local bt = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
                bt:SetSize(30, 30)
                bt:SetPoint("TOPLEFT", parent, x, y)
                bt.Text:SetFont(ns.Font, 15, "OUTLINE")
                bt.Text:SetText(text)
                bt.Text:SetWordWrap(false)
                bt.Text:SetWidth(min(bt.Text:GetStringWidth() + 20, (type(long) == 'number' and long) or (long and 500 or 160)))
                bt:SetHitRectInsets(0, -bt.Text:GetWidth(), 0, 0)
                bt.name = name
                bt.ontext = ontext
                bt.callback = callback
                ZL.options["button" .. name] = bt
                bt:SetChecked(ZongLan.options[name] == 1)
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
                t:SetFont(ns.Font, 15, "OUTLINE")
                t:SetPoint("TOPLEFT", parent, x, y)
                t:SetTextColor(1, 1, 1)
                t:SetText(text)
                ZL.options["Text" .. name] = t

                local edit = CreateFrame("EditBox", nil, parent, ZL.editTemplate)
                edit:SetSize(width or 50, 20)
                edit:SetPoint("LEFT", t, "RIGHT", 10, 0)
                edit:SetText(ZongLan.options[name] or (isNumeric and 0 or ""))
                edit:SetAutoFocus(false)
                edit:SetNumeric(isNumeric)
                ZL.SetEditBaseClass(edit)
                ZL.options["button" .. name] = edit
                edit:SetScript("OnTextChanged", function(self)
                    local value = self:GetText()
                    if isNumeric then
                        value = tonumber(value) or 0
                    end
                    ZongLan.options[name] = value
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
                local bt = ZL.CreateButton(parent)
                bt:SetSize(wdith or 130, 25)
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
                        ZL.After(0, function()
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
                t:SetFont(ns.Font, 15, "OUTLINE")
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
                t:SetFont(ns.Font, 15, "OUTLINE")
                t:SetPoint("TOPLEFT", parent, x, y)
                t:SetTextColor(1, 1, 1)
                t:SetText(text)
                ZL.options["Text" .. name] = t

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
                LibBG:UIDropDownMenu_SetText(dropDown, GetText(ZongLan.options[name]))
                LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "TOP", dropDown, "BOTTOM")
                ZL.dropDownToggle(dropDown)
                ZL.options["button" .. name] = dropDown

                LibBG:UIDropDownMenu_Initialize(dropDown, function(self, level)
                    for _, v in ipairs(tbl) do
                        local option = v
                        local info = LibBG:UIDropDownMenu_CreateInfo()
                        info.text = option.text
                        info.arg1 = option.key
                        info.func = function()
                            ZongLan.options[name] = option.key
                            LibBG:UIDropDownMenu_SetText(dropDown, GetText(option.key))
                            if callback then
                                callback(dropDown, option.key, option)
                            end
                        end
                        info.checked = ZongLan.options[name] == option.key
                        LibBG:UIDropDownMenu_AddButton(info)
                    end
                end)

                return dropDown
            end
        end
    end

    local function SetParent(self, key)
        if ZongLan.options[key] ~= 1 then
            self:Hide()
        end
        local parent = ZL.options["button" .. key]
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
            ZL.options[name .. "reset"] = 1
            ZongLan.options[name] = ZongLan.options[name] or ZL.options[name .. "reset"]
            local ontext = nil
            local f = O.CreateSlider(name, (L["UI缩放："]), parent, 0.5, 1.5, 0.01, 15, height - h, ontext)
            f:HookScript("OnValueChanged", function(self, value)
                ZL.UpdateFBCDFrameScale()
            end)
        end
        local roleOverviewPopups = {}
        local function ToggleRoleOverviewPopup(frame)
            local shown = not frame:IsShown()
            if shown then
                for _, popup in ipairs(roleOverviewPopups) do
                    if popup ~= frame then
                        popup:Hide()
                    end
                end
            end
            frame:SetShown(shown)
        end

        h = h + 30
        -- 背景透明度
        do
            local name = "roleOverviewAlpha"
            ZL.options[name .. "reset"] = .9
            ZongLan.options[name] = ZongLan.options[name] or ZL.options[name .. "reset"]
            local ontext = nil
            local f = O.CreateSlider(name, (L["背景透明度："]), parent, 0.1, 1.0, 0.01, 15, height - h, ontext)
            f:HookScript("OnValueChanged", function(self, value)
                if ZL.FBCDFrame then
                    ZL.FBCDFrame:SetBackdropColor(0, 0, 0, value)
                end
            end)
        end
        h = h + 35
        -- 快捷键
        do
            O.CreateBindKey(parent, 15, -h, nil, "ZONGLAN_ROLEOVERVIEW", L["快捷键："])
        end
        h = h + 35
        -- 字体
        if ZL.fontList then
            local name = "font"
            local tbl = {}
            for _, font in ipairs(ZL.fontList) do
                tinsert(tbl, { key = font, text = font })
            end
            ZongLan.options[name] = ZongLan.font
            local dropDown = O.CreateDropDown(name, L["字体（需重载）"] .. "：", parent, tbl, 15, -h,
                function(_, key)
                    ZongLan.font = key
                end)

            local preview = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            preview:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeSize = 1,
            })
            preview:SetBackdropColor(0, 0, 0, 0.5)
            preview:SetBackdropBorderColor(0, 0, 0, 1)
            preview.text = preview:CreateFontString()
            preview.text:SetPoint("CENTER")
            preview.text:SetTextColor(1, 1, 1)
            preview.text:SetJustifyH("LEFT")
            preview:Hide()

            function preview:Update(button, font)
                self:SetParent(button)
                self:ClearAllPoints()
                self:SetPoint("BOTTOMLEFT", button, "TOPRIGHT", 0, 0)
                self.text:SetFont(format("Fonts\\%s", font), 15, "OUTLINE")
                self.text:SetText(font .. L["字体预览\n\nZongLan插件\n1234567890"])
                self:SetSize(self.text:GetStringWidth() + 10, self.text:GetStringHeight() + 10)
                self:Show()
            end

            for i = 1, L_UIDROPDOWNMENU_MAXBUTTONS do
                local button = _G["L_DropDownList1Button" .. i]
                if button then
                    button:HookScript("OnEnter", function()
                        if not L_DropDownList1 or L_DropDownList1.dropdown ~= dropDown then return end
                        if button.arg1 then
                            preview:Update(button, button.arg1)
                        end
                    end)
                    button:HookScript("OnLeave", function()
                        if not L_DropDownList1 or L_DropDownList1.dropdown ~= dropDown then return end
                        preview:Hide()
                    end)
                end
            end
        end

        h = h + 35
        -- 排序
        do
            local name = "roleOverviewSort1"
            ZL.options[name .. "reset"] = "iLevel-class-player"
            ZongLan.options[name] = ZongLan.options[name] or ZL.options[name .. "reset"]
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
                    if key == "custom" and ZL.InitializeRoleOverviewCustomSort then
                        ZL.InitializeRoleOverviewCustomSort()
                    elseif ZL.RoleOverviewSortFrame and ZL.RoleOverviewSortFrame:IsVisible() then
                        ZL.RoleOverviewSortFrame:Hide()
                    end
                    self.bt:SetShown(key == "custom")
                    ZL.RefreshFBCDFrame()
                end)

            dropDown.bt = ZL.CreateButton(dropDown)
            dropDown.bt:SetSize(100, 25)
            dropDown.bt:SetPoint("LEFT", dropDown, "RIGHT", 0, 3)
            dropDown.bt:SetText(L["修改排序"])
            dropDown.bt:SetShown(ZongLan.options[name] == "custom")
            dropDown.bt:SetScript("OnClick", function(self)
                ZL.PlaySound(1)
                if ZL.RoleOverviewSortFrame and ZL.RoleOverviewSortFrame:IsVisible() then
                    ZL.RoleOverviewSortFrame:Hide()
                else
                    ZL.CreateRoleOverviewSortFrame(self)
                end
            end)
        end

        h = h + 35
        -- 默认显示
        do
            local name = "roleOverviewDefaultShow"
            ZL.options[name .. "reset"] = "one"
            ZongLan.options[name] = ZongLan.options[name] or ZL.options[name .. "reset"]
            local tbl = {
                { key = "one", text = L["当前服务器角色"] },
                { key = "all", text = L["全部服务器角色"] },
            }

            O.CreateDropDown(name, L["默认显示："], parent, tbl, 15, -h,
                function()
                    ZL.RefreshFBCDFrame()
                end)
        end

        h = h + 35
        -- 布局
        do
            local name = "roleOverviewLayout"
            if ZL.IsRetail then
                ZL.options[name .. "reset"] = "new"
            else
                ZL.options[name .. "reset"] = "up_down"
            end
            ZongLan.options[name] = ZongLan.options[name] or ZL.options[name .. "reset"]
            local tbl = {
                { key = "up_down", text = L["横向布局1"] },
                { key = "left_right", text = L["横向布局2"] },
                { key = "new", text = L["竖向布局"] },
            }

            O.CreateDropDown(name, L["布局方式："], parent, tbl, 15, -h,
                function()
                    ZL.RefreshFBCDFrame()
                end)
        end

        h = h + 35
        -- 屏蔽等级
        do
            local name = "roleOverviewNotShowLevel"
            ZL.options[name .. "reset"] = 0
            ZongLan.options[name] = ZongLan.options[name] or ZL.options[name .. "reset"]

            O.CreateEditBox(name, L["仅显示高于该等级的角色："], parent, 15, -h, true)
        end

        h = h + 35
        -- 屏蔽装等
        do
            local name = "roleOverviewNotShowiLevel"
            ZL.options[name .. "reset"] = 0
            ZongLan.options[name] = ZongLan.options[name] or ZL.options[name .. "reset"]

            O.CreateEditBox(name, L["仅显示高于该装等的角色："], parent, 15, -h, true)
        end

        h = h + 30
        -- 悬浮框
        do
            local name = "mainIcon"
            ZL.options[name .. "reset"] = 0
            ZongLan.options[name] = ZongLan.options[name] or ZL.options[name .. "reset"]
            local ontext = {
                L["显示悬浮框"],
            }
            O.CreateCheckButton(name, L["显示悬浮框"], parent, 15, -h, ontext, true, {
                function()
                    if ZL.MainIcon then
                        ZL.MainIcon:SetShown(ZongLan.options[name] == 1)
                    end
                end,
            })
        end

        -- 悬浮框缩放
        do
            local name = "mainIconScale"
            ZL.options[name .. "reset"] = 1
            ZongLan.options[name] = tonumber(ZongLan.options[name]) or ZL.options[name .. "reset"]
            local ontext = nil
            local slider, sliderLabel = O.CreateSlider(name, L["缩放："], parent, 0.5, 1.5, 0.01, 170, -h + 2, ontext, 80, true)
            SetParent(slider, "mainIcon")
            SetParent(sliderLabel, "mainIcon")
            slider:HookScript("OnValueChanged", function(_, value)
                if ZL.MainIcon then
                    ZL.MainIcon:SetScale(value)
                end
            end)
        end

        -- 悬浮框层级
        do
            local name = "mainIconFrameLevel"
            ZL.options[name .. "reset"] = "HIGH"
            ZongLan.options[name] = ZongLan.options[name] or ZL.options[name .. "reset"]
            local tbl = {}
            for _, strata in ipairs({ "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }) do
                tinsert(tbl, { key = strata, text = strata })
            end
            local dropDown = O.CreateDropDown(name, L["层级"] .. "：", parent, tbl, 400, -h - 5,
                function(_, key)
                    if ZL.MainIcon then
                        ZL.MainIcon:SetFrameStrata(key)
                    end
                end, 90)
            SetParent(dropDown, "mainIcon")
            SetParent(ZL.options["Text" .. name], "mainIcon")
        end

        h = h + 30
        -- 团本CD显示为BOSS击杀数量
        do
            local name = "showRaidCDKillNum"
            ZL.options[name .. "reset"] = ZL.IsRetail and 1 or 0
            ZongLan.options[name] = ZongLan.options[name] or ZL.options[name .. "reset"]
            local ontext = {
                L["团本CD显示为BOSS击杀数量"],
                L["没全通的副本，现在会显示击杀的BOSS数量，而不是显示一个绿色钩子。"],
            }
            O.CreateCheckButton(name, L["团本CD显示为BOSS击杀数量"], base, 15, -h, ontext, true, { ZL.RefreshFBCDFrame })
        end

        -- 显示牌子总上限
        if ZL.IsMOP then
            h = h + 30
            local name = "showCurrencyTop"
            local ontext = {
                L["显示牌子总上限"],
                L["像勇气点数、征服点数有总上限的牌子，在角色总览里会显示其总上限。"],
            }
            O.CreateCheckButton(name, L["显示牌子总上限"] .. L["（需重载）"], base, 15, -h, ontext, true, { ZL.RefreshFBCDFrame })
        end

        h = h + 30
        -- 显示其他装备部位
        do
            local name = "roleOverviewShowOtherEquip"
            ZongLan.options[name] = ZongLan.options[name] or 0
            local choiceName = "roleOverviewOtherEquipSlots"
            if type(ZongLan.options[choiceName]) ~= "table" then
                ZongLan.options[choiceName] = {}
            end
            local ontext = {
                L["显示其他装备部位"],
                L["在饰品后面增加显示其他装备部位。"],
            }
            local f = O.CreateCheckButton(name, L["显示其他装备部位"], base, 15, -h, ontext, true, { ZL.RefreshFBCDFrame })

            local chooseBT = ZL.CreateButton(f)
            chooseBT:SetSize(120, 22)
            chooseBT:SetPoint("LEFT", f.Text, "RIGHT", 0, 0)
            SetParent(chooseBT, name)

            local function UpdateChooseButtonText()
                local count = 0
                for _, equipInfo in ipairs(ZL.RoleOverviewOtherEquipSlots) do
                    if ZongLan.options[choiceName][equipInfo.id] == 1 then
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
            chooseFrame:SetFrameStrata("HIGH")
            chooseFrame:SetClampedToScreen(true)
            chooseFrame:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                edgeSize = 16,
                insets = { left = 3, right = 3, top = 3, bottom = 3 },
            })
            chooseFrame:SetBackdropColor(0, 0, 0, .95)
            chooseFrame:SetBackdropBorderColor(.5, .5, .5)
            chooseFrame:EnableMouse(true)
            chooseFrame:Hide()
            tinsert(roleOverviewPopups, chooseFrame)

            ZL.CreateCloseButton(chooseFrame)

            local title = chooseFrame:CreateFontString()
            title:SetFont(ns.Font, 15, "OUTLINE")
            title:SetPoint("TOP", 0, -7)
            title:SetText(L["显示其他装备部位"])
            title:SetTextColor(1, 1, 1)

            for i, equipInfo in ipairs(ZL.RoleOverviewOtherEquipSlots) do
                local bt = CreateFrame("CheckButton", nil, chooseFrame, "ChatConfigCheckButtonTemplate")
                local column = floor((i - 1) / 6)
                local row = (i - 1) % 6
                bt:SetPoint("TOPLEFT", 10 + column * 110, -30 - row * 25)
                bt:SetSize(25, 25)
                bt.Text:SetFont(ns.Font, 15, "OUTLINE")
                bt.Text:SetText(equipInfo.name)
                bt.Text:SetTextColor(1, .82, 0)
                bt:SetHitRectInsets(0, -75, 0, 0)
                bt:SetChecked(ZongLan.options[choiceName][equipInfo.id] == 1)
                bt:SetScript("OnClick", function(self)
                    if self:GetChecked() then
                        ZongLan.options[choiceName][equipInfo.id] = 1
                    else
                        ZongLan.options[choiceName][equipInfo.id] = nil
                    end
                    UpdateChooseButtonText()
                    ZL.RefreshFBCDFrame()
                    ZL.PlaySound(1)
                end)
            end

            chooseBT:SetScript("OnClick", function()
                ZL.PlaySound(1)
                ToggleRoleOverviewPopup(chooseFrame)
            end)
            chooseBT:HookScript("OnHide", function()
                chooseFrame:Hide()
            end)
        end

        h = h + 30
        -- 显示自定义物品
        do
            local name = "roleOverviewShowCustomItem"
            ZongLan.options[name] = ZongLan.options[name] or 1
            local itemListName = "roleOverviewCustomItems"
            local presetPotionIDs = ns.presetPotionIDs or {}
            local presetFlaskIDs = ns.presetFlaskIDs or {}
            if type(ZongLan.options[itemListName]) ~= "table" then
                ZongLan.options[itemListName] = {}
                local oldItemID = tonumber(ZongLan.options.roleOverviewCustomItemID)
                local oldItemLink = ZongLan.options.roleOverviewCustomItemLink
                if oldItemID and oldItemLink then
                    tinsert(ZongLan.options[itemListName], {
                        id = oldItemID,
                        link = oldItemLink,
                    })
                end
            end
            local defaultItemsName = "roleOverviewDefaultCustomItemsAdded"
            if not ZongLan.options[defaultItemsName] then
                local existing = {}
                for _, info in ipairs(ZongLan.options[itemListName]) do
                    if info.id then
                        existing[info.id] = true
                    end
                end
                local function AddDefaultItem(itemID)
                    if existing[itemID] then return end
                    existing[itemID] = true
                    local info = {
                        id = itemID,
                        link = select(2, GetItemInfo(itemID)),
                    }
                    tinsert(ZongLan.options[itemListName], info)
                    Item:CreateFromItemID(itemID):ContinueOnItemLoad(function()
                        info.link = select(2, GetItemInfo(itemID))
                    end)
                end
                for _, itemID in ipairs(presetPotionIDs) do
                    AddDefaultItem(itemID)
                end
                for _, itemID in ipairs(presetFlaskIDs) do
                    AddDefaultItem(itemID)
                end
                ZongLan.options[defaultItemsName] = true
            end
            local ontext = {
                L["显示自定义物品"],
                L["在角色总览中显示自定义物品。"],
            }
            local function RefreshCustomItems()
                if ZL.MONEYupdate then
                    ZL.MONEYupdate()
                end
                ZL.RefreshFBCDFrame()
            end
            local f = O.CreateCheckButton(name, AddTexture('QUEST')..L["显示自定义物品"], base, 15, -h, ontext, true, { RefreshCustomItems })

            local itemBT = ZL.CreateButton(f)
            itemBT:SetSize(120, 22)
            itemBT:SetPoint("LEFT", f.Text, "RIGHT", 10, 0)
            SetParent(itemBT, name)

            local itemFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            itemFrame:SetPoint("TOPLEFT", itemBT, "BOTTOMLEFT", 0, -5)
            itemFrame:SetSize(280, 300)
            itemFrame:SetFrameStrata("HIGH")
            itemFrame:SetClampedToScreen(true)
            itemFrame:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                edgeSize = 16,
                insets = { left = 3, right = 3, top = 3, bottom = 3 },
            })
            itemFrame:SetBackdropColor(0, 0, 0, .95)
            itemFrame:SetBackdropBorderColor(.5, .5, .5)
            itemFrame:EnableMouse(true)
            itemFrame:Hide()
            tinsert(roleOverviewPopups, itemFrame)

            ZL.CreateCloseButton(itemFrame)

            local title = itemFrame:CreateFontString()
            title:SetFont(ns.Font, 15, "OUTLINE")
            title:SetPoint("TOP", 0, -9)
            title:SetText(L["自定义物品"])
            title:SetTextColor(1, 1, 1)

            local idText = itemFrame:CreateFontString()
            idText:SetFont(ns.Font, 15, "OUTLINE")
            idText:SetPoint("TOPLEFT", 15, -40)
            idText:SetText(L["物品ID："])
            idText:SetTextColor(1, 1, 1)

            local edit = CreateFrame("EditBox", nil, itemFrame, ZL.editTemplate)
            edit:SetSize(100, 20)
            edit:SetPoint("LEFT", idText, "RIGHT", 10, 0)
            edit:SetText("")
            edit:SetAutoFocus(false)
            edit:SetNumeric(true)
            ZL.SetEditBaseClass(edit)

            local addBT = ZL.CreateButton(itemFrame)
            addBT:SetSize(60, 22)
            addBT:SetPoint("LEFT", edit, "RIGHT", 10, 0)
            addBT:SetText(L["添加"])

            local listFrame, listChild = ZL.CreateScrollFrame(itemFrame, itemFrame:GetWidth() - 20, itemFrame:GetHeight() - 110)
            listFrame:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeSize = 1,
            })
            listFrame:SetPoint("TOPLEFT", 10, -70)
            listFrame:SetBackdropColor(0, 0, 0, .35)
            listFrame:SetBackdropBorderColor(.5, .5, .5)

            local presetPotionBT = ZL.CreateButton(itemFrame)
            presetPotionBT:SetSize(120, 22)
            presetPotionBT:SetPoint("TOPLEFT", listFrame, "BOTTOMLEFT", 0, -8)
            presetPotionBT:SetText(L["添加爆发药水"])

            local presetFlaskBT = ZL.CreateButton(itemFrame)
            presetFlaskBT:SetSize(120, 22)
            presetFlaskBT:SetPoint("TOPRIGHT", listFrame, "BOTTOMRIGHT", 0, -8)
            presetFlaskBT:SetText(L["添加合剂"])

            local function ShowPresetTooltip(self, presetIDs)
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
                GameTooltip:ClearLines()
                GameTooltip:AddLine(self:GetText(), 1, 1, 1, true)
                GameTooltip:AddLine(' ', 1, 1, 1, true)
                for _, itemID in ipairs(presetIDs) do
                    local itemLink = select(2, GetItemInfo(itemID))
                    local tex=select(5, GetItemInfoInstant(itemID))
                    GameTooltip:AddLine(AddTexture(tex)..(itemLink or format("%s%d", L["物品ID："], itemID)), 1, .82, 0, true)
                end
                GameTooltip:Show()
            end
            presetPotionBT:SetScript("OnEnter", function(self)
                ShowPresetTooltip(self, presetPotionIDs)
            end)
            presetFlaskBT:SetScript("OnEnter", function(self)
                ShowPresetTooltip(self, presetFlaskIDs)
            end)
            presetPotionBT:SetScript("OnLeave", GameTooltip_Hide)
            presetFlaskBT:SetScript("OnLeave", GameTooltip_Hide)

            local loadID = 0
            local function SetAddButtonsEnabled(enabled)
                if enabled then
                    addBT:Enable()
                    presetPotionBT:Enable()
                    presetFlaskBT:Enable()
                else
                    addBT:Disable()
                    presetPotionBT:Disable()
                    presetFlaskBT:Disable()
                end
            end
            local rows = {}
            local emptyText = listChild:CreateFontString()
            emptyText:SetFont(ns.Font, 15, "OUTLINE")
            emptyText:SetPoint("TOPLEFT", 5, -5)
            emptyText:SetText(L["尚未添加物品。"])
            emptyText:SetTextColor(.5, .5, .5)

            local function UpdateItemList()
                local items = ZongLan.options[itemListName]
                table.sort(items, function(a, b)
                    return (a.id or 0) < (b.id or 0)
                end)
                for _, row in ipairs(rows) do
                    row.linkBT:Hide()
                    row.deleteBT:Hide()
                end

                for i, info in ipairs(items) do
                    local row = rows[i]
                    if not row then
                        row = {}
                        rows[i] = row

                        row.linkBT = CreateFrame("Button", nil, listChild)
                        row.linkBT:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
                        local linkText = row.linkBT:CreateFontString()
                        linkText:SetFont(ns.Font, 15, "OUTLINE")
                        linkText:SetPoint("LEFT")
                        linkText:SetPoint("RIGHT")
                        linkText:SetJustifyH("LEFT")
                        linkText:SetWordWrap(false)
                        row.linkBT:SetFontString(linkText)
                        row.linkBT:SetScript("OnEnter", function(self)
                            if not self.link then return end
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetHyperlink(self.link)
                            GameTooltip:Show()
                        end)
                        row.linkBT:SetScript("OnLeave", GameTooltip_Hide)

                        row.deleteBT = ZL.CreateButton(listChild)
                        row.deleteBT:SetSize(50, 20)
                        row.deleteBT:SetText(L["删除"])
                        row.deleteBT:SetScript("OnClick", function(self)
                            ZL.PlaySound(1)
                            tremove(ZongLan.options[itemListName], self.index)
                            UpdateItemList()
                            RefreshCustomItems()
                        end)
                    end

                    row.linkBT:ClearAllPoints()
                    row.linkBT:SetPoint("TOPLEFT", 5, -(i - 1) * 24)
                    row.linkBT:SetSize(listChild:GetWidth() - 60, 22)
                    local texture = select(5, GetItemInfoInstant(info.id))
                    row.linkBT:SetText(AddTexture(texture) .. (info.link or info.id))
                    row.linkBT.link = info.link
                    row.linkBT:Show()

                    row.deleteBT:ClearAllPoints()
                    row.deleteBT:SetPoint("LEFT", row.linkBT, "RIGHT", 5, 0)
                    row.deleteBT.index = i
                    row.deleteBT:Show()
                end

                local count = #items
                local color = count == 0 and "808080" or "00ff00"
                itemBT:SetText(format("%s(|cff%s%d|r)", L["设置物品"], color, count))
                emptyText:SetShown(count == 0)
                listChild:SetHeight(max(listFrame.scroll:GetHeight(), count * 24))
            end
            UpdateItemList()

            local function AddPresetItems(presetIDs)
                local existing = {}
                for _, info in ipairs(ZongLan.options[itemListName]) do
                    existing[info.id] = true
                end

                local itemIDs = {}
                for _, itemID in ipairs(presetIDs) do
                    if not existing[itemID] and GetItemInfoInstant(itemID) then
                        existing[itemID] = true
                        tinsert(itemIDs, itemID)
                    end
                end
                if #itemIDs == 0 then
                    return
                end

                loadID = loadID + 1
                local expectedLoadID = loadID
                local pending = #itemIDs
                local added = 0
                SetAddButtonsEnabled(false)

                for _, itemID in ipairs(itemIDs) do
                    Item:CreateFromItemID(itemID):ContinueOnItemLoad(function()
                        if expectedLoadID ~= loadID then return end
                        local _, link = GetItemInfo(itemID)
                        if link then
                            tinsert(ZongLan.options[itemListName], {
                                id = itemID,
                                link = link,
                            })
                            added = added + 1
                        end
                        pending = pending - 1
                        if pending == 0 then
                            SetAddButtonsEnabled(true)
                            UpdateItemList()
                            RefreshCustomItems()
                        end
                    end)
                end
            end

            local function AddItem()
                local itemID = tonumber(edit:GetText())
                if not itemID or itemID <= 0 or itemID ~= floor(itemID) or not GetItemInfoInstant(itemID) then
                    return
                end

                for _, info in ipairs(ZongLan.options[itemListName]) do
                    if info.id == itemID then
                        return
                    end
                end

                loadID = loadID + 1
                local expectedLoadID = loadID
                SetAddButtonsEnabled(false)
                Item:CreateFromItemID(itemID):ContinueOnItemLoad(function()
                    if expectedLoadID ~= loadID then return end
                    SetAddButtonsEnabled(true)
                    local _, link = GetItemInfo(itemID)
                    if not link then
                        return
                    end
                    tinsert(ZongLan.options[itemListName], {
                        id = itemID,
                        link = link,
                    })
                    edit:SetText("")
                    edit:ClearFocus()
                    UpdateItemList()
                    RefreshCustomItems()
                end)
            end

            addBT:SetScript("OnClick", function()
                ZL.PlaySound(1)
                AddItem()
            end)
            presetPotionBT:SetScript("OnClick", function()
                ZL.PlaySound(1)
                AddPresetItems(presetPotionIDs)
            end)
            presetFlaskBT:SetScript("OnClick", function()
                ZL.PlaySound(1)
                AddPresetItems(presetFlaskIDs)
            end)
            edit:SetScript("OnEnterPressed", AddItem)
            edit:SetScript("OnEscapePressed", function(self)
                self:ClearFocus()
                itemFrame:Hide()
            end)
            itemBT:SetScript("OnClick", function()
                ZL.PlaySound(1)
                ToggleRoleOverviewPopup(itemFrame)
                if itemFrame:IsShown() then
                    edit:SetText("")
                    UpdateItemList()
                    edit:SetFocus()
                end
            end)
            itemFrame:SetScript("OnHide", function()
                loadID = loadID + 1
                SetAddButtonsEnabled(true)
            end)
            itemBT:HookScript("OnHide", function()
                itemFrame:Hide()
            end)
        end

        h = h + 30
        -- 备注
        do
            local name = "roleOverviewShowNote"
            ZongLan.options[name] = ZongLan.options[name] or 0
            local ontext = {
                L["显示角色备注"],
                L["在角色名字后面，增加显示一段自定义文本。"],
                " ",
                L["使用方法：/zl，把角色总览面板固定，然后鼠标点击角色对应的备注栏即可修改备注。"]
            }
            local f = O.CreateCheckButton(name, L["显示角色备注"], base, 15, -h, ontext, true, { ZL.RefreshFBCDFrame })

            local t = f:CreateFontString()
            t:SetFont(ns.Font, 15, "OUTLINE")
            t:SetPoint("LEFT", f.Text, "RIGHT", 10, 0)
            t:SetTextColor(1, 1, 1)
            t:SetText(L["文本宽度："])
            SetParent(t, "roleOverviewShowNote")

            local miniWidth = 60
            local name2 = "roleOverviewShowNote_width"
            ZongLan.options[name2] = ZongLan.options[name2] or 100
            local edit = CreateFrame("EditBox", nil, f, ZL.editTemplate)
            edit:SetSize(100, 20)
            edit:SetPoint("LEFT", t, "RIGHT", 5, 0)
            edit:SetText(ZongLan.options[name2])
            edit:SetAutoFocus(false)
            edit:SetNumeric(true)
            ZL.SetEditBaseClass(edit)
            SetParent(edit, "roleOverviewShowNote")
            edit:SetScript("OnTextChanged", function(self)
                ZongLan.options[name2] = max(miniWidth, tonumber(self:GetText()) or 0)
            end)

            local t = f:CreateFontString()
            t:SetFont(ns.Font, 15, "OUTLINE")
            t:SetPoint("LEFT", edit, "RIGHT", 20, 0)
            t:SetTextColor(1, 1, 1)
            t:SetText(L["文本使用职业颜色："])
            SetParent(t, "roleOverviewShowNote")

            local name3 = "roleOverviewShowNote_useClassColor"
            ZongLan.options[name3] = ZongLan.options[name3] or 1
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
                bt.Text:SetFont(ns.Font, 15, "OUTLINE")
                bt.Text:SetPoint("LEFT", bt, "RIGHT", 0, 0)
                bt.Text:SetText(numOptions[i].name)
                bt.Text:SetTextColor(1, .82, 0)
                bt:SetHitRectInsets(0, -bt.Text:GetWidth(), -5, -5)
                if numOptions[i].key == ZongLan.options[name3] then
                    bt:SetChecked(true)
                    bt.Text:SetTextColor(0, 1, 0)
                end
                bt:SetScript("OnClick", function(self)
                    ZL.PlaySound(1)
                    for _, radioButton in ipairs(buttons) do
                        if radioButton ~= self then
                            radioButton:SetChecked(false)
                            radioButton.Text:SetTextColor(1, .82, 0)
                        end
                    end
                    self:SetChecked(true)
                    self.Text:SetTextColor(0, 1, 0)
                    ZongLan.options.roleOverviewShowNote_useClassColor = numOptions[i].key
                end)
            end
        end

        h = h + 30
        -- 显示专精图标
        do
            local name = "roleOverviewShowTalent"
            ZongLan.options[name] = ZongLan.options[name] or 1
            local ontext = {
                L["显示角色专精图标"],
                L["在角色名字前面增加显示专精图标。"],
            }
            O.CreateCheckButton(name, L["显示角色专精图标"], base, 15, -h, ontext, true, { ZL.RefreshFBCDFrame })
        end

        h = h + 30
        -- 显示阵营
        do
            local name = "roleOverviewShowFaction"
            ZongLan.options[name] = ZongLan.options[name] or 0
            local ontext = {
                L["显示角色阵营"],
                L["角色装等和等级会根据阵营染色为浅蓝色（联盟）或浅红色（部落），用来区分该角色是哪个阵营。"],
            }
            O.CreateCheckButton(name, L["显示角色阵营"], base, 15, -h, ontext, true, { ZL.RefreshFBCDFrame })
        end

        h = h + 30
        -- 使用黑白着色
        do
            local name = "roleOverviewblackWhite"
            ZongLan.options[name] = ZongLan.options[name] or 0
            local ontext = {
                L["使用黑白着色"],
                L["勾选后每行使用黑白着色。否则使用下横线作分割。该选项仅对横向布局有效。"],
            }
            O.CreateCheckButton(name, L["使用黑白着色"], base, 15, -h, ontext, true, { ZL.RefreshFBCDFrame })
        end

        h = h + 30
        -- 显示小地图图标
        do
            local name = "miniMap"
            ZongLan.options[name] = ZongLan.options[name] or 1
            local ontext = {
                L["显示小地图图标"],
                L["显示小地图图标。"],
            }
            local function UpdateMinimapIcon()
                ZongLan.minimap = ZongLan.minimap or {}
                ZongLan.minimap.hide = ZongLan.options[name] ~= 1
                if ZL.MinimapIcon then
                    if ZongLan.minimap.hide then
                        ZL.MinimapIcon:Hide(AddonName)
                    else
                        ZL.MinimapIcon:Show(AddonName)
                    end
                end
            end
            O.CreateCheckButton(name, L["显示小地图图标"], base, 15, -h, ontext, true, { UpdateMinimapIcon })
        end
    end

    -- 显示内容
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
                local name = dbName == "FBCDchoice" and ZL[tblName][i].name or ZL[tblName][i].id
                local name2 = ZL[tblName][i].name2
                local color = ZL[tblName][i].color
                local fbId = ZL[tblName][i].fbId
                local type = ZL[tblName][i].type
                local diff = ZL.GetDiffShortName(ZL[tblName][i].diff) or ""
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
                bt.Text:SetFont(ns.Font, 15, "OUTLINE")
                bt.Text:SetText("|cff" .. color .. diff .. (name2 or name):gsub("sod", "") .. RR)
                bt.Text:SetWidth(buttonWidth - buttonHeight)
                bt.Text:SetWordWrap(false)
                if not ZongLan[dbName][name] or ZongLan[dbName][name] == 0 then
                    ZongLan[dbName][name] = nil
                    bt:SetChecked(false)
                else
                    ZongLan[dbName][name] = 1
                    bt:SetChecked(true)
                end
                bt:SetScript("OnClick", function(self)
                    if self:GetChecked() then
                        ZongLan[dbName][name] = 1
                    else
                        ZongLan[dbName][name] = nil
                    end
                    ZL.RefreshFBCDFrame()
                    ZL.PlaySound(1)
                end)
                bt:SetScript("OnEnter", function(self)
                    local text
                    if dbName == "FBCDchoice" then
                        local maxplayers = ZL[tblName][i].num and (ZL[tblName][i].num .. L["人"]) or ""
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
                local name = ZL.MONEYall_table[i].name
                local tex = ZL.MONEYall_table[i].tex
                local color = ZL.MONEYall_table[i].color
                local id = ZL.MONEYall_table[i].id
                local itemType = ZL.MONEYall_table[i].type
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
                bt.Text:SetFont(ns.Font, 15, "OUTLINE")
                bt.Text:SetText(AddTexture(tex))
                if not ZongLan.MONEYchoice[id] or ZongLan.MONEYchoice[id] == 0 then
                    ZongLan.MONEYchoice[id] = nil
                    bt:SetChecked(false)
                else
                    ZongLan.MONEYchoice[id] = 1
                    bt:SetChecked(true)
                end
                bt:SetScript("OnClick", function(self)
                    if self:GetChecked() then
                        ZongLan.MONEYchoice[id] = 1
                    else
                        ZongLan.MONEYchoice[id] = nil
                    end
                    ZL.RefreshFBCDFrame()
                    ZL.PlaySound(1)
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
            frame.text:SetFont(ns.Font, 15, "OUTLINE")
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
                    ZongLan.options['roleOverviewTitleCollapse' .. name] = true
                else
                    self.child2:Show()
                    self.child:SetHeight(self.height)
                    self.tex:SetTexture(130821)
                    self.open = true
                    ZongLan.options['roleOverviewTitleCollapse' .. name] = nil
                end
                if button then
                    ZL.PlaySound(1)
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
        if ZL.IsVanilla_Sod then
            local z = { 10, 3 } -- 3是专业
            local x = {}
            for i, v in ipairs(z) do
                x[i] = (x[i - 1] or 0) + v
            end
            local startNum = 1
            lastFrame = CreateTitle(L["团本"], "00BFFF")
            CreateFBCDbutton(1, x[startNum])
            lastFrame = CreateTitle(L["专业CD"], "ADFF2F")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
        elseif ZL.IsVanilla_60 then
            local z = { 7, ZL.skillCount, #ZL.factionTbl } -- 3是专业
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
        elseif ZL.IsTBC then
            local z = { ZL.FBCount, ZL.dayQuestCount, #ZL.factionTbl }
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
        elseif ZL.IsWLK_80 then
            local z = { 18, 11, 5, 6, 10, #ZL.factionTbl } -- 6是日常，10是专业
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
        elseif ZL.IsTitan then
            local z = { ZL.FBCount, ZL.dayQuestCount, ZL.skillCount, #ZL.factionTbl }
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
        elseif ZL.IsCTM then
            local z = { 7, 18, 11, 5, 3, #ZL.factionTbl } -- 3是日常
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
        elseif ZL.IsMOP then
            local z = { ZL.FBCount, 7, 18, 11, 5, ZL.dayQuestCount, ZL.skillCount, #ZL.factionTbl }
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
        elseif ZL.IsRetail then
            local z = { ZL.FBCount, }
            local x = {}
            for i, v in ipairs(z) do
                x[i] = (x[i - 1] or 0) + v
            end
            local startNum = 1
            lastFrame = CreateTitle(L["团本"], "00BFFF")
            CreateFBCDbutton(1, x[startNum])
        elseif ZL.IsForever then
            local z = { ZL.FBCount, #ZL.factionTbl }
            local x = {}
            for i, v in ipairs(z) do
                x[i] = (x[i - 1] or 0) + v
            end
            local startNum = 1
            lastFrame = CreateTitle(L["团本"], "00BFFF")
            CreateFBCDbutton(1, x[startNum])
            lastFrame = CreateTitle(L["声望"], "FFFF00")
            CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
        end
        if not ZL.IsRetail then
            lastFrame = CreateTitle(L["专业技能点"], ZL.SKILLall_table[1].color)
            CreateFBCDbutton(1, #ZL.SKILLall_table, nil, "SKILLall_table", "SKILLchoice")
        end
        lastFrame = CreateTitle(L["货币"], "FFFFFF")
        CreateMONEYbutton(1, #ZL.MONEYall_table)

        for i, title in ipairs(titles) do
            if ZongLan.options['roleOverviewTitleCollapse' .. title.name] and title.open then
                title:GetScript("OnMouseDown")(title)
            end
        end
    end

    -- 角色管理
    do
        local width = 15
        local height = 5
        local width2 = 200
        local width3 = 160
        local height2 = 450

        do
            local text = config:CreateFontString()
            text:SetFont(ns.Font, 15, "OUTLINE")
            text:SetPoint("TOPLEFT", width, height - 15)
            text:SetText(L["角色列表"])
            text:SetTextColor(0, 1, 0)
            text:SetWidth(width2)

            local text = config:CreateFontString()
            text:SetFont(ns.Font, 15, "OUTLINE")
            text:SetPoint("TOPLEFT", width + width2 + 15, height - 15)
            text:SetText(L["操作"])
            text:SetTextColor(0, 1, 0)
            text:SetWidth(width3)
        end

        height = height - 15

        local f, child = ZL.CreateScrollFrame(config, width2, height2)
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
            ZL.options.configDeleteButton:Disable()
            if choose.realmID and choose.player then
                ZL.options.configDeleteButton:Enable()
            end
        end

        -- 创建角色列表
        local function UpdateAllButtons()
            for i, bt in ipairs(buttons) do
                bt:Hide()
            end
            wipe(buttons)

            for realmID, v in pairs(ZongLan.playerInfo) do
                if next(v) then
                    if next(ZongLan.playerInfo[realmID]) then
                        local bt = CreateFrame("Button", nil, child)
                        if not buttons[1] then
                            bt:SetPoint("TOPLEFT", child, 0, 0)
                        else
                            bt:SetPoint("TOPLEFT", buttons[#buttons], "BOTTOMLEFT", 0, 0)
                        end
                        bt:SetNormalFontObject(ZL.FontWhite15)
                        if ZongLan.realmName[realmID] then
                            bt:SetText(ZongLan.realmName[realmID])
                        else
                            bt:SetText(realmID)
                        end
                        bt:SetSize(child:GetWidth(), 20)
                        ZL.SetTextHighlightTexture(bt)
                        tinsert(buttons, bt)
                        local t = bt:GetFontString()
                        t:SetPoint("LEFT")
                        t:SetTextColor(1, 0.82, 0)
                        bt:Disable()
                    end

                    for player in pairs(ZongLan.playerInfo[realmID]) do
                        local bt = CreateFrame("Button", nil, child)
                        if not buttons[1] then
                            bt:SetPoint("TOPLEFT", child, 0, 0)
                        else
                            bt:SetPoint("TOPLEFT", buttons[#buttons], "BOTTOMLEFT", 0, 0)
                        end
                        bt:SetNormalFontObject(ZL.FontWhite15)
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
                        if ZongLan.playerInfo[realmID] and ZongLan.playerInfo[realmID][player] and ZongLan.playerInfo[realmID][player].class then
                            local r, g, b = GetClassColor(ZongLan.playerInfo[realmID][player].class)
                            t:SetTextColor(r, g, b)
                            tex:SetVertexColor(r, g, b)
                            bt:SetText("   " .. player .. " (" .. ZongLan.playerInfo[realmID][player].level .. ")")
                        else
                            t:SetTextColor(.5, .5, .5)
                            tex:SetVertexColor(.5, .5, .5)
                        end

                        bt:SetScript("OnClick", function(self)
                            ZL.PlaySound(1)
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
            ZL.DeletePlayerData(choose.realmID, choose.player)
            if realmID == choose.realmID and ZL.myName == choose.player then
                ReloadUI()
            else
                UpdateAllButtons()
            end
        end
        local bt = ZL.CreateButton(f)
        bt:SetSize(100, 25)
        bt:SetPoint("TOP", 0, -15)
        bt:SetText(L["删除角色"])
        bt:Disable()
        ZL.options.configDeleteButton = bt
        bt:SetScript("OnEnter", function(self)
            local c2 = "ffFFFFFF"
            if ZongLan.playerInfo[choose.realmID] and ZongLan.playerInfo[choose.realmID][choose.player]
                and ZongLan.playerInfo[choose.realmID][choose.player].class then
                c2 = select(4, GetClassColor(ZongLan.playerInfo[choose.realmID][choose.player].class))
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
            ZL.PlaySound(1)
        end)
    end
end)

-- debug
-- ZL.Init2(function(self, event, ...)
--     ZL.OpenOption()
-- end)
