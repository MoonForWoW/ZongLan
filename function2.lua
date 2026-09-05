local AddonName, ns = ...

local L = ns.L
local GetClassColor = ns.GetClassColor

local BossNum = ns.BossNum

------------------创建：金额下拉列表------------------
do

    function BG.GetGeZiTardeInfo(FB, b, i, isHistory)
        local tbl
        if isHistory then
            local DT = BiaoGe.HistoryList[FB][BG.History.chooseNum][1]
            tbl = BiaoGe.History[FB][DT].tradeTbl
        else
            tbl = BiaoGe[FB].tradeTbl
        end
        if not tbl then return end
        for ii, _ in ipairs(tbl) do
            for _, v in ipairs(tbl[ii]) do
                if FB == v.FB and b == v.b and i == v.i then
                    return tbl[ii], ii
                end
            end
        end
    end

end

------------------单元格内容交换------------------
function BG.JiaoHuan(button, FB, b, i, t)
    if not BG.copy1 then
        BG.copy1 = {
            fb = FB,
            b = BossNum(FB, b, t),
            i = i,
            btzhuangbei = BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["zhuangbei" .. i],
            btmaijia = BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["maijia" .. i],
            btjine = BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["jine" .. i],
            btqiankuan = BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["qiankuan" .. i],
            btguanzhu = BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["guanzhu" .. i],

            zhuangbei = BiaoGe[FB]["boss" .. BossNum(FB, b, t)]["zhuangbei" .. i],
            maijia = BiaoGe[FB]["boss" .. BossNum(FB, b, t)]["maijia" .. i],
            jine = BiaoGe[FB]["boss" .. BossNum(FB, b, t)]["jine" .. i],
            qiankuan = BiaoGe[FB]["boss" .. BossNum(FB, b, t)]["qiankuan" .. i],
            guanzhu = BiaoGe[FB]["boss" .. BossNum(FB, b, t)]["guanzhu" .. i],

            tradeInfo = BG.GetGeZiTardeInfo(FB, BossNum(FB, b, t), i),
            loot = BiaoGe[FB]["boss" .. BossNum(FB, b, t)]["loot" .. i],
        }
        for k, v in pairs(BG.playerClass) do
            BG.copy1[k] = BiaoGe[FB]["boss" .. BossNum(FB, b, t)][k .. i]
        end

        BG.PlaySound(1)

        local bt = BG.CreateButton(BG["Frame" .. FB])
        bt:SetSize(80, 20)
        bt:SetPoint("RIGHT", BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["zhuangbei" .. i], "LEFT", -5, 0)
        bt:SetFrameLevel(BG.MainFrame:GetFrameLevel() + 15)
        bt:SetText(L["取消交换"])
        BG.copyButton = bt
        bt:SetScript("OnHide", function(self)
            self:Hide()
        end)
        bt:SetScript("OnClick", function()
            if BG.copy1 then
                BG.copy1 = nil
            end
            BG.copyButton:Hide()
            BG.PlaySound(1)
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:SetText(BG.STC_b1(L["你正在交换该行全部内容"]) .. L["\n点击取消交换"])
        end)
        BG.GameTooltip_Hide(bt)
        BG.CreateHighLightAnim(bt)
        local f = BG.Create_BlinkHilight(bt, BG.MainFrame:GetFrameLevel() + 1)
        f:SetPoint("TOPLEFT", BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["zhuangbei" .. i], "TOPLEFT", -80, 5)
        f:SetPoint("BOTTOMRIGHT", BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["jine" .. i], "BOTTOMRIGHT", 90, -5)
    else
        BG.copy2 = {
            fb = FB,
            b = BossNum(FB, b, t),
            i = i,
            btzhuangbei = BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["zhuangbei" .. i],
            btmaijia = BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["maijia" .. i],
            btjine = BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["jine" .. i],
            btqiankuan = BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["qiankuan" .. i],
            btguanzhu = BG.Frame[FB]["boss" .. BossNum(FB, b, t)]["guanzhu" .. i],

            zhuangbei = BiaoGe[FB]["boss" .. BossNum(FB, b, t)]["zhuangbei" .. i],
            maijia = BiaoGe[FB]["boss" .. BossNum(FB, b, t)]["maijia" .. i],
            jine = BiaoGe[FB]["boss" .. BossNum(FB, b, t)]["jine" .. i],
            qiankuan = BiaoGe[FB]["boss" .. BossNum(FB, b, t)]["qiankuan" .. i],
            guanzhu = BiaoGe[FB]["boss" .. BossNum(FB, b, t)]["guanzhu" .. i],

            tradeInfo = BG.GetGeZiTardeInfo(FB, BossNum(FB, b, t), i),
            loot = BiaoGe[FB]["boss" .. BossNum(FB, b, t)]["loot" .. i],
        }
        for k, v in pairs(BG.playerClass) do
            BG.copy2[k] = BiaoGe[FB]["boss" .. BossNum(FB, b, t)][k .. i]
        end

        if BG.copy1.fb == BG.copy2.fb then -- 是同一个副本
            -- 打包交易
            if not (BG.copy1.tradeInfo and BG.copy2.tradeInfo and BG.copy1.tradeInfo == BG.copy2.tradeInfo) then
                if BG.copy1.tradeInfo then
                    -- 修改该打包交易中，格子1的b和i改为格子2的b和i
                    for i, v in ipairs(BG.copy1.tradeInfo) do
                        if BG.copy1.b == v.b and BG.copy1.i == v.i then
                            v.b = BG.copy2.b
                            v.i = BG.copy2.i
                        end
                    end
                end
                if BG.copy2.tradeInfo then
                    for i, v in ipairs(BG.copy2.tradeInfo) do
                        if BG.copy2.b == v.b and BG.copy2.i == v.i then
                            v.b = BG.copy1.b
                            v.i = BG.copy1.i
                        end
                    end
                end
            else
                local copy1_b = BG.copy1.b
                local copy1_i = BG.copy1.i
                local copy2_b = BG.copy2.b
                local copy2_i = BG.copy2.i
                for i, v in ipairs(BG.copy1.tradeInfo) do
                    if copy1_b == v.b and copy1_i == v.i then
                        v.b = copy2_b
                        v.i = copy2_i
                    elseif copy2_b == v.b and copy2_i == v.i then
                        v.b = copy1_b
                        v.i = copy1_i
                    end
                end
            end

            BG.copy1.btzhuangbei:SetText(BG.copy2.zhuangbei or "")
            BG.copy1.btzhuangbei:SetCursorPosition(0)
            BG.copy1.btmaijia:SetText(BG.copy2.maijia or "")
            BG.copy1.btmaijia:SetCursorPosition(0)
            BG.copy1.btmaijia:SetTextColor(unpack(BG.copy2.color or { 1, 1, 1 }))
            BG.copy1.btjine:SetText(BG.copy2.jine or "")

            BG.copy2.btzhuangbei:SetText(BG.copy1.zhuangbei or "")
            BG.copy2.btzhuangbei:SetCursorPosition(0)
            BG.copy2.btmaijia:SetText(BG.copy1.maijia or "")
            BG.copy2.btmaijia:SetCursorPosition(0)
            BG.copy2.btmaijia:SetTextColor(unpack(BG.copy1.color or { 1, 1, 1 }))
            BG.copy2.btjine:SetText(BG.copy1.jine or "")

            local FB = BG.copy1.fb
            local b1, i1 = BG.copy1.b, BG.copy1.i
            local b2, i2 = BG.copy2.b, BG.copy2.i

            for k, v in pairs(BG.playerClass) do
                BiaoGe[FB]["boss" .. b1][k .. i1] = BG.copy2[k]
                BiaoGe[FB]["boss" .. b2][k .. i2] = BG.copy1[k]
            end
            -- 拾取记录
            BiaoGe[FB]["boss" .. b1]["loot" .. i1], BiaoGe[FB]["boss" .. b2]["loot" .. i2] =
                BiaoGe[FB]["boss" .. b2]["loot" .. i2], BiaoGe[FB]["boss" .. b1]["loot" .. i1]
            -- 关注
            BiaoGe[FB]["boss" .. b1]["guanzhu" .. i1], BiaoGe[FB]["boss" .. b2]["guanzhu" .. i2] =
                BiaoGe[FB]["boss" .. b2]["guanzhu" .. i2], BiaoGe[FB]["boss" .. b1]["guanzhu" .. i1]
            if BiaoGe[FB]["boss" .. b1]["guanzhu" .. i1] then
                BG.Frame[FB]["boss" .. b1]["guanzhu" .. i1]:Show()
            else
                BG.Frame[FB]["boss" .. b1]["guanzhu" .. i1]:Hide()
            end
            if BiaoGe[FB]["boss" .. b2]["guanzhu" .. i2] then
                BG.Frame[FB]["boss" .. b2]["guanzhu" .. i2]:Show()
            else
                BG.Frame[FB]["boss" .. b2]["guanzhu" .. i2]:Hide()
            end
            -- 欠款
            BiaoGe[FB]["boss" .. b1]["qiankuan" .. i1], BiaoGe[FB]["boss" .. b2]["qiankuan" .. i2] =
                BiaoGe[FB]["boss" .. b2]["qiankuan" .. i2], BiaoGe[FB]["boss" .. b1]["qiankuan" .. i1]
            if BiaoGe[FB]["boss" .. b1]["qiankuan" .. i1] then
                BG.Frame[FB]["boss" .. b1]["qiankuan" .. i1]:Show()
            else
                BG.Frame[FB]["boss" .. b1]["qiankuan" .. i1]:Hide()
            end
            if BiaoGe[FB]["boss" .. b2]["qiankuan" .. i2] then
                BG.Frame[FB]["boss" .. b2]["qiankuan" .. i2]:Show()
            else
                BG.Frame[FB]["boss" .. b2]["qiankuan" .. i2]:Hide()
            end

            local text = BG.copy2.btzhuangbei:CreateFontString()
            text:SetPoint("RIGHT", BG.copy2.btzhuangbei, "LEFT", -5, 0)
            text:SetFont(ns.Font, 15, "OUTLINE")
            text:SetText(BG.STC_b1(L["交换成功"]))
            C_Timer.After(1, function()
                BG.DongHuaAlpha(text)
            end)

            BG.copy1 = nil
            BG.copy2 = nil
            BG.copyButton:Hide()
        else -- 不是同一个副本
            BG.copy1 = nil
            BG.copy2 = nil
            BG.copyButton:Hide()
            BG.JiaoHuan(button, FB, b, i, t)
        end

        BG.PlaySound(1)
    end
end

------------------模板：创建蓝底高光材质------------------
function BG.Create_BlinkHilight(Parent, level)
    local f = CreateFrame("Frame", nil, Parent)
    f:SetFrameLevel(level or Parent:GetFrameLevel() - 1)
    local texture = f:CreateTexture(nil, "BACKGROUND") -- 高亮材质
    texture:SetAllPoints()
    texture:SetTexture("Interface/ChatFrame/UI-ChatIcon-BlinkHilight")
    return f
end

------------------动画：慢慢透明然后隐藏------------------
function BG.DongHuaAlpha(bt, time)
    if not time then
        time = 2
    end
    local T = 50 * time
    local t = time / T
    for i = T, 1, -1 do
        C_Timer.After(t, function()
            bt:SetAlpha(1 * ((i - 1) / T))
        end)
        t = t + time / T
    end
    C_Timer.After(time, function()
        bt:Hide()
    end)
end

------------------复原一个设置------------------
function BG.Once(name, dt, func)
    if BiaoGe and BiaoGe.options and BiaoGe.options.SearchHistory then
        if not BiaoGe.options.SearchHistory[name .. dt] then
            func()
            BiaoGe.options.SearchHistory[name .. dt] = true
        end
    end
end

------------------创建滚动框------------------
do
    function BG.CreateScrollFrame(parent, w, h, isEdit, alwaysHide)
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

        local scroll = CreateFrame("ScrollFrame", nil, f, BG.scrollTemplate)
        scroll:SetWidth(f:GetWidth() - 31)
        scroll:SetHeight(f:GetHeight() - 9)
        scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -5)
        scroll.ScrollBar.scrollStep = BG.scrollStep
        f.scroll = scroll
        BG.CreateSrollBarBackdrop(scroll.ScrollBar)
        BG.HookScrollBarShowOrHide(scroll, alwaysHide)

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

    function BG.CreateSrollBarBackdrop(bar)
        if bar.ThumbButton then return end
        local tex = bar:CreateTexture()
        tex:SetPoint("TOPLEFT", bar.ScrollUpButton, -0, 0)
        tex:SetPoint("BOTTOMRIGHT", bar.ScrollDownButton, 0, -0)
        tex:SetColorTexture(0, 0, 0, 0.3)
    end

    function BG.HookScrollBarShowOrHide(scroll, alwaysHide)
        if scroll.ScrollBar.ThumbButton then
            scroll.alwaysHideScrollBar = alwaysHide
            if scroll.ScrollBar:GetOrientation() == "HORIZONTAL" then
                BiaoGe_ModernHorizontalScrollFrameTemplate_Update(scroll)
            else
                BiaoGe_ModernScrollFrameTemplate_Update(scroll)
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

    function BiaoGe_ModernScrollThumbButton_UpdateShape(self)
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

    function BiaoGe_ModernScrollThumbButton_UpdatePosition(bar)
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

    function BiaoGe_ModernScrollFrameTemplate_Update(self)
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
            BiaoGe_ModernScrollThumbButton_UpdateShape(bar.ThumbButton)
            BiaoGe_ModernScrollThumbButton_UpdatePosition(bar)
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

    function BiaoGe_ModernScrollFrameTemplate_SetScrollExtent(self, visibleExtent, totalExtent)
        self.modernVisibleExtent = visibleExtent
        self.modernTotalExtent = totalExtent
        BiaoGe_ModernScrollFrameTemplate_Update(self)
    end

    function BiaoGe_ModernScrollFrameTemplate_ClearScrollExtent(self)
        self.modernVisibleExtent = nil
        self.modernTotalExtent = nil
        BiaoGe_ModernScrollFrameTemplate_Update(self)
    end

    function BiaoGe_ModernScrollFrameTemplate_OnLoad(self)
        self:EnableMouse(true)
        self:EnableMouseWheel(true)
        self.SetScrollExtent = BiaoGe_ModernScrollFrameTemplate_SetScrollExtent
        self.ClearScrollExtent = BiaoGe_ModernScrollFrameTemplate_ClearScrollExtent
        self.ScrollBar.scrollStep = BG.scrollStep
        BiaoGe_ModernScrollFrameTemplate_Update(self)
    end

    function BiaoGe_ModernScrollFrameTemplate_OnScrollRangeChanged(self, xRange, yRange)
        if self.modernVisibleExtent ~= nil then
            BiaoGe_ModernScrollFrameTemplate_Update(self)
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

        BiaoGe_ModernScrollFrameTemplate_Update(self)
    end

    function BiaoGe_ModernScrollFrameTemplate_OnVerticalScroll(self, offset)
        if self.modernVisibleExtent ~= nil then return end
        if self.modernScrollSyncing then return end
        self.modernScrollSyncing = true
        self.ScrollBar:SetValue(offset)
        self.modernScrollSyncing = nil
    end

    function BiaoGe_ModernScrollFrameTemplate_OnMouseWheel(self, delta)
        local bar = self.ScrollBar
        local minValue, maxValue = bar:GetMinMaxValues()
        local value = bar:GetValue() - delta * (bar.scrollStep or BG.scrollStep or 20)
        bar:SetValue(math.max(minValue, math.min(value, maxValue)))
    end

    function BiaoGe_ModernScrollBarTemplate_OnLoad(self)
        self:SetMinMaxValues(0, 0)
        self:SetValue(0)
        self:SetValueStep(1)
        self:EnableMouseWheel(true)
        self:Hide()
    end

    function BiaoGe_ModernScrollBarTemplate_OnValueChanged(self, value)
        local scroll = self:GetParent()
        BiaoGe_ModernScrollThumbButton_UpdatePosition(self)
        if scroll.modernVisibleExtent ~= nil then return end
        if scroll.modernScrollSyncing then return end
        scroll.modernScrollSyncing = true
        scroll:SetVerticalScroll(value)
        scroll.modernScrollSyncing = nil
    end

    function BiaoGe_ModernScrollBarTemplate_OnMouseWheel(self, delta)
        BiaoGe_ModernScrollFrameTemplate_OnMouseWheel(self:GetParent(), delta)
    end

    function BiaoGe_ModernScrollBarTemplate_OnEnter(self)
        -- self:GetThumbTexture():SetColorTexture(unpack(c2))
    end

    function BiaoGe_ModernScrollBarTemplate_OnLeave(self)
        -- self:GetThumbTexture():SetColorTexture(unpack(c1))
    end

    function BiaoGe_ModernScrollTrackButton_OnLoad(self)
        self:SetFrameLevel(self:GetParent():GetFrameLevel() + 1)
        self:EnableMouseWheel(true)
    end

    function BiaoGe_ModernScrollTrackButton_OnMouseDown(self, button)
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

    function BiaoGe_ModernScrollTrackButton_OnMouseWheel(self, delta)
        BiaoGe_ModernScrollBarTemplate_OnMouseWheel(self:GetParent(), delta)
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

    function BiaoGe_ModernScrollThumbButton_OnLoad(self)
        local bar = self:GetParent()
        self:SetFrameLevel(bar:GetFrameLevel() + 2)
        self:SetWidth(bar:GetWidth())

        self.TopMask = self:CreateMaskTexture()
        self.TopMask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMaskSmall")
        self.Top:AddMaskTexture(self.TopMask)

        self.BottomMask = self:CreateMaskTexture()
        self.BottomMask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMaskSmall")
        self.Bottom:AddMaskTexture(self.BottomMask)

        BiaoGe_ModernScrollThumbButton_UpdateShape(self)
        BiaoGe_ModernScrollThumbButton_UpdatePosition(bar)
        SetModernScrollThumbButtonColor(self, c1)
    end

    function BiaoGe_ModernScrollThumbButton_OnEnter(self)
        if not self.modernDragging then
            SetModernScrollThumbButtonColor(self, c2)
        end
    end

    function BiaoGe_ModernScrollThumbButton_OnLeave(self)
        if not self.modernDragging then
            SetModernScrollThumbButtonColor(self, c1)
        end
    end

    function BiaoGe_ModernScrollThumbButton_OnMouseDown(self, button)
        if button ~= "LeftButton" then return end

        local _, cursorY = GetCursorPosition()
        self.modernDragging = true
        self.modernStartCursorY = cursorY
        self.modernStartValue = self:GetParent():GetValue()
        self:SetScript("OnUpdate", ModernScrollThumbButton_OnUpdate)
    end

    function BiaoGe_ModernScrollThumbButton_OnMouseUp(self, button)
        if button == "LeftButton" and self.modernDragging then
            ModernScrollThumbButton_StopDragging(self)
        end
    end

    local function SetModernHorizontalScrollThumbButtonColor(self, color)
        self.Left:SetColorTexture(unpack(color))
        self.Middle:SetColorTexture(unpack(color))
        self.Right:SetColorTexture(unpack(color))
    end

    function BiaoGe_ModernHorizontalScrollThumbButton_UpdateShape(self)
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

    function BiaoGe_ModernHorizontalScrollThumbButton_UpdatePosition(bar)
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

    function BiaoGe_ModernHorizontalScrollFrameTemplate_Update(self)
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
            BiaoGe_ModernHorizontalScrollThumbButton_UpdateShape(bar.ThumbButton)
            BiaoGe_ModernHorizontalScrollThumbButton_UpdatePosition(bar)
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

    function BiaoGe_ModernHorizontalScrollFrameTemplate_SetScrollExtent(self, visibleExtent, totalExtent)
        self.modernVisibleExtent = visibleExtent
        self.modernTotalExtent = totalExtent
        BiaoGe_ModernHorizontalScrollFrameTemplate_Update(self)
    end

    function BiaoGe_ModernHorizontalScrollFrameTemplate_ClearScrollExtent(self)
        self.modernVisibleExtent = nil
        self.modernTotalExtent = nil
        BiaoGe_ModernHorizontalScrollFrameTemplate_Update(self)
    end

    function BiaoGe_ModernHorizontalScrollFrameTemplate_OnLoad(self)
        self:EnableMouse(true)
        self:EnableMouseWheel(true)
        self.SetScrollExtent = BiaoGe_ModernHorizontalScrollFrameTemplate_SetScrollExtent
        self.ClearScrollExtent = BiaoGe_ModernHorizontalScrollFrameTemplate_ClearScrollExtent
        self.ScrollBar.scrollStep = BG.scrollStep
        BiaoGe_ModernHorizontalScrollFrameTemplate_Update(self)
    end

    function BiaoGe_ModernHorizontalScrollFrameTemplate_OnScrollRangeChanged(self, xRange, yRange)
        if self.modernVisibleExtent ~= nil then
            BiaoGe_ModernHorizontalScrollFrameTemplate_Update(self)
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

        BiaoGe_ModernHorizontalScrollFrameTemplate_Update(self)
    end

    function BiaoGe_ModernHorizontalScrollFrameTemplate_OnHorizontalScroll(self, offset)
        if self.modernVisibleExtent ~= nil then return end
        if self.modernScrollSyncing then return end
        self.modernScrollSyncing = true
        self.ScrollBar:SetValue(offset)
        self.modernScrollSyncing = nil
    end

    function BiaoGe_ModernHorizontalScrollFrameTemplate_OnMouseWheel(self, delta)
        local bar = self.ScrollBar
        local minValue, maxValue = bar:GetMinMaxValues()
        local value = bar:GetValue() - delta * (bar.scrollStep or BG.scrollStep or 20)
        bar:SetValue(math.max(minValue, math.min(value, maxValue)))
    end

    function BiaoGe_ModernHorizontalScrollBarTemplate_OnLoad(self)
        self:SetMinMaxValues(0, 0)
        self:SetValue(0)
        self:SetValueStep(1)
        self:EnableMouseWheel(true)
        self:Hide()
    end

    function BiaoGe_ModernHorizontalScrollBarTemplate_OnValueChanged(self, value)
        local scroll = self:GetParent()
        BiaoGe_ModernHorizontalScrollThumbButton_UpdatePosition(self)
        if scroll.modernVisibleExtent ~= nil then return end
        if scroll.modernScrollSyncing then return end
        scroll.modernScrollSyncing = true
        scroll:SetHorizontalScroll(value)
        scroll.modernScrollSyncing = nil
    end

    function BiaoGe_ModernHorizontalScrollBarTemplate_OnMouseWheel(self, delta)
        BiaoGe_ModernHorizontalScrollFrameTemplate_OnMouseWheel(self:GetParent(), delta)
    end

    function BiaoGe_ModernHorizontalScrollTrackButton_OnLoad(self)
        self:SetFrameLevel(self:GetParent():GetFrameLevel() + 1)
        self:EnableMouseWheel(true)
    end

    function BiaoGe_ModernHorizontalScrollTrackButton_OnMouseDown(self, button)
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

    function BiaoGe_ModernHorizontalScrollTrackButton_OnMouseWheel(self, delta)
        BiaoGe_ModernHorizontalScrollBarTemplate_OnMouseWheel(self:GetParent(), delta)
    end

    function BiaoGe_ModernHorizontalScrollBarTemplate_OnSizeChanged(self)
        BiaoGe_ModernHorizontalScrollFrameTemplate_Update(self:GetParent())
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

    function BiaoGe_ModernHorizontalScrollThumbButton_OnLoad(self)
        local bar = self:GetParent()
        self:SetFrameLevel(bar:GetFrameLevel() + 2)
        self:SetHeight(bar:GetHeight())

        self.LeftMask = self:CreateMaskTexture()
        self.LeftMask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMaskSmall")
        self.Left:AddMaskTexture(self.LeftMask)

        self.RightMask = self:CreateMaskTexture()
        self.RightMask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMaskSmall")
        self.Right:AddMaskTexture(self.RightMask)

        BiaoGe_ModernHorizontalScrollThumbButton_UpdateShape(self)
        BiaoGe_ModernHorizontalScrollThumbButton_UpdatePosition(bar)
        SetModernHorizontalScrollThumbButtonColor(self, c1)
    end

    function BiaoGe_ModernHorizontalScrollThumbButton_OnEnter(self)
        if not self.modernDragging then
            SetModernHorizontalScrollThumbButtonColor(self, c2)
        end
    end

    function BiaoGe_ModernHorizontalScrollThumbButton_OnLeave(self)
        if not self.modernDragging then
            SetModernHorizontalScrollThumbButtonColor(self, c1)
        end
    end

    function BiaoGe_ModernHorizontalScrollThumbButton_OnMouseDown(self, button)
        if button ~= "LeftButton" then return end

        local cursorX = GetCursorPosition()
        self.modernDragging = true
        self.modernStartCursorX = cursorX
        self.modernStartValue = self:GetParent():GetValue()
        self:SetScript("OnUpdate", ModernHorizontalScrollThumbButton_OnUpdate)
    end

    function BiaoGe_ModernHorizontalScrollThumbButton_OnMouseUp(self, button)
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
function BG.CreateButton(parent)
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

function BG.SkinDropDown(dropDown)
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

function BG.CreateHighLightAnim(self, w, h)
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

function BG.SetEditStickyFocus(edit)
    edit.HasStickyFocus = editMixin.HasStickyFocus
end

function BG.SetEditBaseClass(edit, notClearOnRightButton)
    edit:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    edit:HookScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    edit:HookScript("OnEditFocusGained", function(self)
        BG.lastfocus = self
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
    BG.SetEditStickyFocus(edit)
end
