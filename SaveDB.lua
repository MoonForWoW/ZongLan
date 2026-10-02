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
local dbNames = { AddonName, "ZongLanDB" }

ZL.RoleOverviewOtherEquipSlots = {
    { id = "head", name = INVTYPE_HEAD, slots = { { id = "1", name = "HeadSlot" } } },
    { id = "neck", name = INVTYPE_NECK, slots = { { id = "2", name = "NeckSlot" } } },
    { id = "shoulder", name = INVTYPE_SHOULDER, slots = { { id = "3", name = "ShoulderSlot" } } },
    { id = "back", name = INVTYPE_CLOAK, slots = { { id = "15", name = "BackSlot" } } },
    { id = "chest", name = INVTYPE_CHEST, slots = { { id = "5", name = "ChestSlot" } } },
    { id = "wrist", name = INVTYPE_WRIST, slots = { { id = "9", name = "WristSlot" } } },
    { id = "hands", name = INVTYPE_HAND, slots = { { id = "10", name = "HandsSlot" } } },
    { id = "waist", name = INVTYPE_WAIST, slots = { { id = "6", name = "WaistSlot" } } },
    { id = "legs", name = INVTYPE_LEGS, slots = { { id = "7", name = "LegsSlot" } } },
    { id = "feet", name = INVTYPE_FEET, slots = { { id = "8", name = "FeetSlot" } } },
    {
        id = "finger",
        name = INVTYPE_FINGER,
        slots = {
            { id = "11", name = "Finger0Slot" },
            { id = "12", name = "Finger1Slot" },
        },
    },
}

ZL.RoleOverviewOtherEquipInfo = {
    name = L["装备"],
    color = "C084FC",
    type = "equip",
    id = "otherEquips",
    tex = select(2, GetInventorySlotInfo("ChestSlot")),
    width = 55,
}

ZL.RoleOverviewCustomItemsInfo = {
    name = L["物品"],
    color = "FFFF00",
    type = "items",
    id = "customItems",
    tex = 134842,
    minWidth = 55,
    width = 55,
}

ZL.Init(function()
    -- 获取副本CD
    do
        local colorplayer = SetClassCFF(ZL.myName, "player")

        function ZL.UpdateFBCD()
            local time = GetServerTime()
            local cd = {}

            for i = 1, GetNumSavedInstances() do
                local name, lockoutId, resettime, difficultyId, locked,
                extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName,
                numEncounters, encounterProgress, extendDisabled, instanceId =
                    GetSavedInstanceInfo(i)
                if locked then
                    local killInfo = {}
                    local killNum = 0
                    for encounterIndex = 1, numEncounters do
                        local bossName, fileDataID, isKilled = GetSavedInstanceEncounterInfo(i, encounterIndex)
                        tinsert(killInfo, { name = bossName, isKilled = isKilled })
                        if isKilled then
                            killNum = killNum + 1
                        end
                    end
                    local a = {
                        player = ZL.myName,
                        colorplayer = colorplayer,
                        fbId = instanceId,
                        num = maxPlayers,
                        resettime = resettime,
                        endtime = resettime + time,
                        diff = difficultyId,
                        bossSum = numEncounters,
                        killNum = killNum,
                        killInfo = killInfo,
                    }
                    tinsert(cd, a)
                end
            end
            if ZL.IsTitan then
                for i = 1, GetNumSavedWorldBosses() do
                    local name, bossID, resettime = GetSavedWorldBossInfo(i)
                    if bossID then
                        local a = {
                            player = ZL.myName,
                            colorplayer = colorplayer,
                            fbId = bossID,
                            num = 0,
                            resettime = resettime,
                            endtime = resettime + time,
                            isWorldBoss = true,
                        }
                        tinsert(cd, a)
                    end
                end
            end
            if next(cd) then
                ZongLan[FBCD][realmID][ZL.myName] = cd
            else
                ZongLan[FBCD][realmID][ZL.myName] = {
                    {
                        player = ZL.myName,
                        colorplayer = colorplayer,
                    }
                }
            end

            -- 检查其他角色cd是否到期
            for _, db in pairs(dbNames) do
                if _G[db] and _G[db][FBCD] then
                    for realmID in pairs(_G[db][FBCD]) do
                        if type(realmID) == "number" and type(_G[db][FBCD][realmID]) == "table" then
                            local playerList = {}
                            for _player in pairs(_G[db][FBCD][realmID]) do
                                tinsert(playerList, _player)
                            end
                            for _, _player in ipairs(playerList) do
                                if _player ~= ZL.myName then
                                    local yes
                                    local player0, colorplayer0
                                    for i = #_G[db][FBCD][realmID][_player], 1, -1 do
                                        local cd = _G[db][FBCD][realmID][_player][i]
                                        if cd and not player0 and not colorplayer0 then
                                            player0 = cd.player
                                            colorplayer0 = cd.colorplayer
                                        end
                                        if cd and cd.endtime then
                                            if time >= cd.endtime then
                                                tremove(_G[db][FBCD][realmID][_player], i)
                                            elseif time < cd.endtime then
                                                cd.resettime = cd.endtime - time
                                                yes = true
                                            end
                                        end
                                    end
                                    if not yes then
                                        _G[db][FBCD][realmID][_player] = {
                                            {
                                                player = player0,
                                                colorplayer = colorplayer0,
                                            }
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        local cd
        local function RequestRaidInfoWithCD()
            if not cd then
                cd = true
                ZL.After(0.5, function()
                    cd = nil
                    RequestRaidInfo()
                end)
            end
        end
        ZL.Init2(RequestRaidInfoWithCD)
        ZL.RegisterEvent("ENCOUNTER_END", function(self, event, _, _, _, _, success)
            if success == 1 then
                RequestRaidInfoWithCD()
            end
        end)
        ZL.RegisterEvent("CHAT_MSG_SYSTEM", function(self, event, msg)
            if not ZL.IsSecret(msg) and msg == INSTANCE_SAVED then
                RequestRaidInfoWithCD()
            end
        end)

        ZL.Init2(function()
            ZL.After(1, ZL.UpdateFBCD)
        end)
        ZL.RegisterEvent("ENCOUNTER_END", function(self, event, _, _, _, _, success)
            if success == 1 then
                ZL.After(1, ZL.UpdateFBCD)
            end
        end)
        ZL.RegisterEvent("UPDATE_INSTANCE_INFO", function()
            ZL.After(1, ZL.UpdateFBCD)
        end)

        for realmID, players in pairs(ZongLan[MONEY]) do
            for player, v in pairs(players) do
                if not ZongLan[FBCD][realmID][player] then
                    ZongLan[FBCD][realmID][player] = {
                        {
                            player = player,
                            colorplayer = v.colorplayer,
                        }
                    }
                end
            end
        end
    end

    -- 世界BOSS（MOP）
    ZongLan.worldBossCD = ZongLan.worldBossCD or {}
    ZongLan.worldBossCD[realmID] = ZongLan.worldBossCD[realmID] or {}
    ZongLan.worldBossCD[realmID][ZL.myName] = ZongLan.worldBossCD[realmID][ZL.myName] or {}
    if ZL.IsMOP then
        local function SaveWorldBoss(bossIndex)
            local resetDay = 2
            if ZL.IsCN() then
                resetDay = 4
            end

            local currentTimestamp = GetServerTime()
            local currentWeekday = date("%w", currentTimestamp)
            local daysToThursday = resetDay - currentWeekday
            local nextThursdayTimestamp

            local today = date("*t", currentTimestamp)
            -- 如果时间小于当天凌晨7点
            if daysToThursday == 0 and today.hour < 7 then
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
            -- 计算时间差
            local secondsToNextThursday = nextThursdayTimestamp - currentTimestamp -- 距离下周四还有多少秒
            local timestamp = currentTimestamp + secondsToNextThursday             -- 到下周四的实际时间戳

            local colorplayer = SetClassCFF(ZL.myName, "player")
            ZongLan.worldBossCD[realmID][ZL.myName]["worldBoss" .. bossIndex] = {
                name = "worldBoss" .. bossIndex,
                player = ZL.myName,
                colorplayer = colorplayer,
                resettime = secondsToNextThursday,
                endtime = timestamp
            }
        end

        local function GetBossIsKill()
            if InCombatLockdown() then return end
            for bossIndex, questID in ipairs(ZL.worldBossID) do
                if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                    if not ZongLan.worldBossCD[realmID][ZL.myName]["worldBoss" .. bossIndex] then
                        SaveWorldBoss(bossIndex)
                    end
                else
                    ZongLan.worldBossCD[realmID][ZL.myName]["worldBoss" .. bossIndex] = nil
                end
            end
        end

        local function UpdateWorldBossEndTime()
            local time = GetServerTime()
            for _, db in pairs(dbNames) do
                if _G[db] and _G[db].worldBossCD then
                    for realmID in pairs(_G[db].worldBossCD) do
                        if type(realmID) == "number" and type(_G[db].worldBossCD[realmID]) == "table" then
                            for player in pairs(_G[db].worldBossCD[realmID]) do
                                local questList = {}
                                for questName in pairs(_G[db].worldBossCD[realmID][player]) do
                                    tinsert(questList, questName)
                                end
                                for _, questName in ipairs(questList) do
                                    local v = _G[db].worldBossCD[realmID][player][questName]
                                    if time < v.endtime then
                                        v.resettime = v.endtime - time
                                    else
                                        _G[db].worldBossCD[realmID][player][questName] = nil
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        ZL.Init2(function()
            UpdateWorldBossEndTime()
        end)
        C_Timer.NewTicker(60, function()
            UpdateWorldBossEndTime()
        end)
        C_Timer.NewTicker(5, function()
            GetBossIsKill()
        end)
    elseif ZL.IsTitan then
        local function GetBossIsKill()
            if InCombatLockdown() then return end
            local level = UnitLevel("player")
            local instanceID = select(8, GetInstanceInfo())
            if level >= ZL.fullLevel and (instanceID == 0 or instanceID == 1 or instanceID == 530) then
                RequestRaidInfo()
            end
        end
        C_Timer.NewTicker(5, function()
            GetBossIsKill()
        end)
    end

    -- 日常任务
    local holidayDungeonIDs = { 286, 285, 287, 288 }                           -- 火焰节、万圣节、美酒节、情人节
    local holidayEventIDs = { [324] = true, [341] = true, [372] = true, [423] = true } -- 火焰节、万圣节、美酒节、情人节
    do
        ZongLan.QuestCD = ZongLan.QuestCD or {}
        ZongLan.QuestCD[realmID] = ZongLan.QuestCD[realmID] or {}
        ZongLan.QuestCD[realmID][ZL.myName] = ZongLan.QuestCD[realmID][ZL.myName] or {}

        local function IsLearnSkill(skillID)
            return ZongLan[MONEY][realmID][ZL.myName].skill[skillID]
        end

        local function GetQuestSkillID(questName)
            return ZL.dayQuests and ZL.dayQuests[questName] and ZL.dayQuests[questName].skillID
        end

        -- 日常
        if ZL.IsVanilla_Sod then
            ZL.dayQuests = {
                huiguweek = { questIDs = { 79090, 79098 }, }, -- 灰谷
            }
        elseif ZL.IsWLK then
            ZL.dayQuests = {
                zhubao = {
                    questIDs = { 12959, 12962, 12961, 12958, 12963, 12960 },
                    skillID = 755,
                },
                cooking = {
                    questIDs = { 13114, 13116, 13113, 13115, 13112, 13102, 13100, 13107, 13101, 13103 },
                    skillID = 185,
                },
                fish = {
                    questIDs = { 13836, 13833, 13834, 13832, 13830 },
                    skillID = 356,
                },
            }
            if ZL.IsWLK_80 then
                ZL.dayQuests.gamma = { questIDs = { 83717, 83713, 78752 } }
                ZL.dayQuests.heroe = { questIDs = { 87379, 83714, 84552, 78753 } }
            end
        elseif ZL.IsCTM then
            ZL.dayQuests = {
                zhubao = {
                    questIDs = { 25156, 25161, 25159, 25158, 25162, 25160, 25154, 25155, 25105, 25157 },
                    skillID = 755,
                },
                cooking = {
                    questIDs = { 29316, 29352, 29314, 29356, 29351, 26190, 26153, 29313, 26183, 29362, 26192, 29358, 26235, 26233, 29333, 29334, 26177, 29318, 29364, 29365, 26234, 26220, 29357, 29363, 26226, 26227, 29332, 29315, 29353, 29355, 29360 },
                    skillID = 185,
                },
                fish = {
                    questIDs = { 26557, 29322, 29354, 29361, 26588, 29317, 26572, 29320, 29345, 29348, 29346, 26543, 29319, 26556, 29349, 26420, 29342, 26536, 29321, 29324, 29344, 29343, 29350, 29347, 29359, 26488, 29323, 29325, 26414, 26442 },
                    skillID = 356,
                },
            }
        elseif ZL.IsMOP then
            ZL.dayQuests = {
                cooking = {
                    questIDs = { 30331, 30328, 30330, 30332, 30329, },
                    skillID = 185,
                },
            }
        end
        local function SaveDayQuest(questName, questID, count)
            local currentTimestamp = GetServerTime()
            local secondsUntilNext7am = ZL.GetNextDayTime()
            local timestamp = currentTimestamp + secondsUntilNext7am

            local colorplayer = SetClassCFF(ZL.myName, "player")
            ZongLan.QuestCD[realmID][ZL.myName][questName] = {
                name = questName,
                player = ZL.myName,
                colorplayer = colorplayer,
                questID = questID,
                resettime = secondsUntilNext7am,
                endtime = timestamp,
                count = count,
            }
        end
        local function UpdateDayQuest(questID)
            if not ZL.dayQuests then return end
            for questName in pairs(ZL.dayQuests) do
                for _, _questID in pairs(ZL.dayQuests[questName].questIDs) do
                    if _questID == questID then
                        SaveDayQuest(questName, questID)
                        return
                    end
                end
            end
        end
        -- 日常数量
        local function UpdateDayQuestCount()
            if not GetDailyQuestsCompleted then return end
            local count = GetDailyQuestsCompleted()
            if count > 0 then
                SaveDayQuest('dayQuestCount', nil, count)
            else
                ZongLan.QuestCD[realmID][ZL.myName].dayQuestCount = nil
            end
        end

        -- 周常
        if ZL.IsWLK then
            ZL.weekQuests = {
                week1 = {
                    questIDs = { 24579, 24580, 24581, 24582, 24583, 24584, 24585, 24586, 24587, 24588, 24589, 24590,
                        93975, 94577, 94579, 95037, 96312 -- 时光服
                    }
                },
                -- 祖格宝石周常
                week2 = {
                    questIDs = { 98183, }
                },
            }
        end
        local function SaveWeekQuest(questName, questID)
            local currentTimestamp = GetServerTime()
            local secondsToNextThursday = ZL.GetNextWeekTime()         -- 距离下周四还有多少秒
            local timestamp = currentTimestamp + secondsToNextThursday -- 到下周四的实际时间戳

            local colorplayer = SetClassCFF(ZL.myName, "player")
            ZongLan.QuestCD[realmID][ZL.myName][questName] = {
                name = questName,
                player = ZL.myName,
                colorplayer = colorplayer,
                questID = questID,
                resettime = secondsToNextThursday,
                endtime = timestamp
            }
        end
        local function UpdateWeekQuest(questID)
            if not ZL.weekQuests then return end
            for questName in pairs(ZL.weekQuests) do
                for _, _questID in pairs(ZL.weekQuests[questName].questIDs) do
                    if _questID == questID then
                        SaveWeekQuest(questName, questID)
                        return
                    end
                end
            end
        end

        -- MOP收菜
        if ZL.IsMOP then
            -- 开垦：开始计时，收菜显示打勾
            -- 倒计时生效时，无视开垦
            -- 倒计时结束，回到第一步，收菜清除打勾
            ZL.RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", function(self, event, ...)
                local unit, _, spellID = ...
                if unit == "player" and (spellID == 111003 or spellID == 116357 or spellID == 139892) then -- 开垦和万能犁
                    SaveDayQuest("shoucai", 111003)
                end
            end)
        end

        -- 节日本
        if ZL.IsTitan or ZL.IsMOP then
            local init
            function ZL.InitHoliday()
                if init then return end
                init = true
                ZL.RegisterEvent("LFG_COMPLETION_REWARD", function()
                    local dungeonID = select(10, GetInstanceInfo())
                    if dungeonID and ZL.ValueInTable(holidayDungeonIDs, dungeonID) then
                        SaveDayQuest("holiday")
                    end
                end)
            end

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

                local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
                local day = currentCalendarTime.monthDay
                local numEvents = C_Calendar.GetNumDayEvents(0, day)
                if numEvents <= 0 then
                    return
                end

                for i = 1, numEvents do
                    local event = C_Calendar.GetDayEvent(0, day, i)
                    if event and holidayEventIDs[event.eventID] then
                        ZL.hasHoliday = true
                    end
                end

                if ZL.hasHoliday then
                    ZL.InitHoliday()
                end
            end)
        end


        -- 交任务时触发
        ZL.RegisterEvent("QUEST_TURNED_IN", function(self, event, questID)
            UpdateDayQuest(questID)
            UpdateWeekQuest(questID)
            ZL.After(1, function()
                UpdateDayQuestCount()
            end)
        end)

        -- 检查全部角色的任务重置cd是否到期（日常是第二天凌晨7点）
        local function UpdateQuestEndTime()
            local time = GetServerTime()
            for _, db in pairs(dbNames) do
                if _G[db] and _G[db].QuestCD then
                    for realmID in pairs(_G[db].QuestCD) do
                        if type(realmID) == "number" and type(_G[db].QuestCD[realmID]) == "table" then
                            for player in pairs(_G[db].QuestCD[realmID]) do
                                local questList = {}
                                for questName in pairs(_G[db].QuestCD[realmID][player]) do
                                    tinsert(questList, questName)
                                end
                                for _, questName in ipairs(questList) do
                                    local v = _G[db].QuestCD[realmID][player][questName]
                                    if v.endtime and time < v.endtime then
                                        v.resettime = v.endtime - time
                                    else
                                        local skillID = GetQuestSkillID(questName)
                                        if skillID then
                                            -- 专业任务，加上notFinish标记，用于显示X
                                            _G[db].QuestCD[realmID][player][questName].endtime = nil
                                            _G[db].QuestCD[realmID][player][questName].resettime = nil
                                            _G[db].QuestCD[realmID][player][questName].notFinish = true
                                            -- 但如果自己没学这个专业了，则清空
                                            if ZL.IsMe(realmID, player) and not IsLearnSkill(skillID) then
                                                _G[db].QuestCD[realmID][player][questName] = nil
                                            end
                                        else
                                            _G[db].QuestCD[realmID][player][questName] = nil
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        -- 追溯已完成的任务
        local function CheckQuestsCompleted()
            if ZL.dayQuests then
                for questName, v in pairs(ZL.dayQuests) do
                    if not ZongLan.QuestCD[realmID][ZL.myName][questName] then
                        local skillID = v.skillID
                        if skillID and IsLearnSkill(skillID) then
                            ZongLan.QuestCD[realmID][ZL.myName][questName] = {
                                notFinish = true,
                            }
                        end
                    end
                    for _, _questID in pairs(ZL.dayQuests[questName].questIDs) do
                        if C_QuestLog.IsQuestFlaggedCompleted(_questID) then
                            SaveDayQuest(questName, _questID)
                            break
                        end
                    end
                end
            end
            if ZL.weekQuests then
                for questName in pairs(ZL.weekQuests) do
                    for _, _questID in pairs(ZL.weekQuests[questName].questIDs) do
                        if C_QuestLog.IsQuestFlaggedCompleted(_questID) then
                            SaveWeekQuest(questName, _questID)
                            break
                        end
                    end
                end
            end
            UpdateDayQuestCount()
        end

        ZL.Init2(function()
            ZL.After(3, function()
                CheckQuestsCompleted()
                UpdateQuestEndTime()
            end)
        end)
        C_Timer.NewTicker(60, function()
            UpdateQuestEndTime()
        end)
    end

    -- 橙披
    if ZL.IsMOP then
        ZongLan.legendaryCloak = ZongLan.legendaryCloak or {}
        ZongLan.legendaryCloak[realmID] = ZongLan.legendaryCloak[realmID] or {}
        local db = ZongLan.legendaryCloak[realmID]
        local ids = {
            { id = 31488, name = L['正在第1章'] },
            { id = 31454, name = L['正在第1章'] },
            { id = 31482, name = L['已完成第1章'] },
            { id = 32390, name = L['已完成第2章'] },
            { id = 32597, name = L['已完成第3章'] },
            { id = 32861, name = L['已完成第4章'] },
            -- { id = 7536, name = L['已完成第5章'] },
            { id = 33104, name = L['|cff00ff00已完成|r'] },
        }
        local function UpdateLegendaryCloak()
            for i, v in ipairs(ids) do
                if C_QuestLog.IsQuestFlaggedCompleted(v.id) then
                    db[ZL.myName] = v.name
                end
            end
        end
        ZL.RegisterEvent("QUEST_TURNED_IN", function(self, event, questID)
            ZL.After(.5, function()
                UpdateLegendaryCloak()
            end)
        end)
        ZL.Init2(function()
            ZL.After(3, function()
                UpdateLegendaryCloak()
            end)
        end)
    end

    ZongLan.buffCD = nil

    -- 专业技能CD
    if not ZL.IsNewUI then
        ZongLan.tradeSkillCooldown = ZongLan.tradeSkillCooldown or {}
        ZongLan.tradeSkillCooldown[realmID] = ZongLan.tradeSkillCooldown[realmID] or {}
        ZongLan.tradeSkillCooldown[realmID][ZL.myName] = ZongLan.tradeSkillCooldown[realmID][ZL.myName] or {}

        local tbl = {}
        if ZL.IsVanilla then
            tbl = {
                alchemy = {
                    name = L["炼金转化"],
                    name2 = L["炼金术"],
                    spell = 17187, -- 转化奥金
                    icon = "Interface/Icons/trade_alchemy",
                },
                leatherworking = {
                    name = L["制皮筛盐"],
                    name2 = L["制皮"],
                    spell = 19566, --筛盐
                    icon = "Interface/Icons/trade_leatherworking",
                },
                tailor = {
                    name = L["裁缝洗布"],
                    name2 = L["裁缝"],
                    spell = 18560, --月布
                    icon = "Interface/Icons/trade_tailoring",
                },
            }
        elseif ZL.IsWLK then
            tbl = {
                alchemy_yanjiu = {
                    name = L["炼金研究"],
                    name2 = L["炼金术"],
                    spell = 60893,
                    icon = "Interface/Icons/trade_alchemy",
                },
                alchemy_zhuanhua = {
                    name = L["炼金转化"],
                    name2 = L["炼金术"],
                    spell = 66660,
                    icon = 237235,
                },
                inscription_dadiaowen = {
                    name = L["大雕文"],
                    name2 = L["铭文"],
                    spell = 61177,
                    icon = "Interface/Icons/inv_inscription_tradeskill01",
                },
                inscription_xiaodiaowen = {
                    name = L["小雕文"],
                    name2 = L["铭文"],
                    spell = 61288,
                    icon = 237132,
                },
                jewelcrafting_bingdonglingzhu = {
                    name = L["冰冻棱柱"],
                    name2 = L["珠宝加工"],
                    spell = 62242,
                    icon = "Interface/Icons/inv_misc_gem_01",
                },
                forge_taitanjinggang = {
                    name = L["泰坦精钢"],
                    name2 = L["采矿"],
                    spell = 55208,
                    icon = "Interface/Icons/trade_mining",
                },
                tailor_fawenbu = {
                    name = L["法纹布"],
                    name2 = L["裁缝"],
                    spell = 56003,
                },
                tailor_wuwenbu = {
                    name = L["乌纹布"],
                    name2 = L["裁缝"],
                    spell = 56002,
                },
                tailor_yueyingbu = {
                    name = L["月影布"],
                    name2 = L["裁缝"],
                    spell = 56001,
                },
                tailor_bingchuanbeibao = {
                    name = L["冰川背包"],
                    name2 = L["裁缝"],
                    spell = 56005,
                    icon = 133666,
                },
            }
            if ZongLan.FBCDchoice["ignore_jewelcrafting_yanjiu"] == 1 then
                tbl.jewelcrafting_yanjiu = nil
            end
        elseif ZL.IsMOP then
            tbl = {
                alchemy_huohuagang = {
                    name = L["炼金转化"],
                    name2 = L["炼金术"],
                    spell = 114780,
                    icon = "Interface/Icons/trade_alchemy",
                },
                forge_piligangding = {
                    name = L["霹雳钢锭"],
                    name2 = L["锻造"],
                    spell = 138646,
                    icon = "Interface/Icons/trade_blacksmithing",
                },
                enchanting_xieshashuijing = {
                    name = L["邪煞水晶"],
                    name2 = L["附魔"],
                    spell = 116499,
                    icon = "Interface/Icons/trade_engraving",
                },
                inscription_zhihuijuanzhou = {
                    name = L["智慧卷轴"],
                    name2 = L["铭文"],
                    spell = 112996,
                    icon = "Interface/Icons/inv_inscription_tradeskill01",
                },
                jewelcrafting_yanjiu = {
                    name = L["珠宝研究"],
                    name2 = L["珠宝加工"],
                    spell = 131686,
                    icon = "Interface/Icons/inv_misc_gem_01",
                },
                jewelcrafting_shenlongzhixin = {
                    name = L["神龙之心"],
                    name2 = L["珠宝加工"],
                    spell = 140050,
                    icon = 651736,
                },
                leatherworking_hualizhipi = {
                    name = L["华丽制皮"],
                    name2 = L["制皮"],
                    spell = 140040,
                    icon = "Interface/Icons/trade_leatherworking",
                },
                tailoring_diwangsichou = {
                    name = L["帝王丝绸"],
                    name2 = L["裁缝"],
                    spell = 125557,
                    icon = "Interface/Icons/trade_tailoring",
                },
                engineering_jiade = {
                    name = L["贾德的特制能量源"],
                    name2 = L["工程"],
                    spell = 139176,
                    icon = "Interface/Icons/trade_engineering",
                },
            }
        end
        local names = {}
        for name in pairs(tbl) do
            if ZongLan.FBCDchoice["ignore_" .. name] == 1 then
                names[name] = true
            end
        end
        for name in pairs(names) do
            tbl[name] = nil
        end
        for profession, v in pairs(tbl) do
            if not v.icon then
                v.icon = C_Spell.GetSpellTexture(v.spell)
            end
        end
        ZL.professionCDInfo = tbl

        local function GetCooldown()
            local time = GetServerTime()
            local getTime = GetTime()
            for profession, v in pairs(tbl) do
                local startTime, duration, cooldown
                if ZL.IsNewUI then
                    local info = C_Spell.GetSpellCooldown(v.spell)
                    startTime = info.startTime
                    duration = info.duration
                else
                    startTime, duration = GetSpellCooldown(v.spell)
                end
                startTime = startTime > getTime and (startTime - 2 ^ 32 / 1000) or startTime
                cooldown = startTime + duration - getTime
                if cooldown > 0 then
                    if ZL.IsMOP then
                        cooldown = ZL.GetNextDayTime()
                    end
                    ZongLan.tradeSkillCooldown[realmID][ZL.myName][profession] = {
                        class = select(2, UnitClass("player")),
                        resettime = cooldown,
                        endtime = cooldown + time,
                        ready = nil,
                    }
                end
            end
        end
        local professionCooldownPending
        local delay = 1
        local function Go()
            professionCooldownPending = nil
            GetCooldown()
        end
        ZL.RegisterEvent("TRADE_SKILL_UPDATE", function()
            if professionCooldownPending then return end
            professionCooldownPending = true
            ZL.After(delay, Go)
        end)
        ZL.RegisterEvent("SPELL_UPDATE_COOLDOWN", function(self, event)
            if InCombatLockdown() then return end
            if professionCooldownPending then return end
            professionCooldownPending = true
            ZL.After(delay, Go)
        end)

        -- 检查其他角色cd是否到期
        local delay = 3
        local function UpdateProfessionCD()
            local time = GetServerTime()
            for _, db in pairs(dbNames) do
                if _G[db] and _G[db].tradeSkillCooldown then
                    for realmID in pairs(_G[db].tradeSkillCooldown) do
                        if type(realmID) == "number" and type(_G[db].tradeSkillCooldown[realmID]) == "table" then
                            for player in pairs(_G[db].tradeSkillCooldown[realmID]) do
                                for profession, v in pairs(_G[db].tradeSkillCooldown[realmID][player]) do
                                    if v.endtime then
                                        if time >= v.endtime then
                                            v.resettime = nil
                                            v.endtime = nil
                                            v.ready = true
                                            -- 限定只提醒当前账号是因为没办法删掉其他子账号的endtime，其他子账号会重复提醒
                                            if db == "ZongLan" and ZongLan.FBCDchoice[profession] and ZongLan.FBCDchoice[profession] == 1 then
                                                local color
                                                if v.class then
                                                    color = select(4, GetClassColor(v.class))
                                                end
                                                local name = ZL.IsMe(realmID, player) and L["我"] or player
                                                local colorName = color and "|c" .. color .. name .. "|r" or name
                                                local msg = ZL.STC_g1(format(L["%s：%s已就绪！"], colorName, tbl[profession].name))
                                                ZL.After(delay, function()
                                                    ZL.SendSystemMessage(msg)
                                                    PlaySoundFile(ns.Interface .. "Media\\sound\\other\\done.mp3", "Master")
                                                end)
                                                delay = delay + 3
                                            end
                                        elseif time < v.endtime then
                                            v.resettime = v.endtime - time
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- 检查专业技能是否忘记了，如果忘记了，则删掉对应的专业CD记录
        do
            local function CheckSkillIsForget()
                for profession, v in pairs(tbl) do
                    local isLearned
                    for i = 1, GetNumSkillLines() do
                        if GetSkillLineInfo(i) == v.name2 then
                            isLearned = true
                            break
                        end
                    end
                    if not isLearned then
                        ZongLan.tradeSkillCooldown[realmID][ZL.myName][profession] = nil
                    end
                end
            end
            ZL.RegisterEvent("SKILL_LINES_CHANGED", function()
                ZL.After(2, function()
                    CheckSkillIsForget()
                end)
            end)
        end

        ZL.Init2(function()
            ZL.After(2, function()
                GetCooldown()
                UpdateProfessionCD()
            end)
        end)
        C_Timer.NewTicker(19, function()
            UpdateProfessionCD()
        end)
    end

    -- 专业技能点数
    if not ZL.IsRetail then
        local skillInfo = {
            [L["锻造"]] = { id = 164, icon = 136241, isMain = true },
            [L["工程学"]] = { id = 202, icon = 136243, isMain = true },
            [L["炼金术"]] = { id = 171, icon = 136240, isMain = true },
            [L["制皮"]] = { id = 165, icon = 133611, isMain = true },
            [L["裁缝"]] = { id = 197, icon = 136249, isMain = true },
            [L["附魔"]] = { id = 333, icon = 136244, isMain = true },
            [L["采矿"]] = { id = 186, icon = 136248, isMain = true },
            [L["草药学"]] = { id = 182, icon = 136065, isMain = true },
            [L["剥皮"]] = { id = 393, icon = 134366, isMain = true },
            [L["铭文"]] = { id = 773, icon = 237171, isMain = true },
            [L["珠宝加工"]] = { id = 755, icon = 134071, isMain = true },
            [L["考古学"]] = { id = 794, icon = 441139, isMain = nil },
            [L["钓鱼"]] = { id = 356, icon = 136245, isMain = nil },
            [L["烹饪"]] = { id = 185, icon = 133971, isMain = nil },
            [L["急救"]] = { id = 129, icon = 135966, isMain = nil },
        }
        local function UpdatetradeSkill()
            if ZL.IsForever then
                local profession1, profession2, archaeology, fishing, cooking = GetProfessions()
                local professionIndexes = { profession1, profession2, archaeology, fishing, cooking }
                local tbl = {}
                for _, professionIndex in pairs(professionIndexes) do
                    local _, icon, rank, _, _, _, skillLine = GetProfessionInfo(professionIndex)
                    if skillLine then
                        tbl[skillLine] = {
                            level = rank,
                            icon = icon,
                            isMain = professionIndex == profession1 or professionIndex == profession2 or nil,
                        }
                    end
                end
                ZongLan[MONEY][realmID][ZL.myName].skill = tbl
            else
                if SkillFrame and SkillFrame:IsVisible() then return end
                if WardrobeFrame and WardrobeFrame:IsVisible() then return end
                ExpandSkillHeader(0)
                local tbl = {}
                for i = 1, GetNumSkillLines() do
                    local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier,
                    skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType,
                    skillDescription = GetSkillLineInfo(i)
                    if not header and skillInfo[skillName] then
                        local id = skillInfo[skillName].id
                        tbl[id] = {
                            level = skillRank,
                            icon = skillInfo[skillName].icon,
                            isMain = skillInfo[skillName].isMain,
                        }
                    end
                end
                ZongLan[MONEY][realmID][ZL.myName].skill = tbl
            end
        end

        ZL.Init2(function()
            UpdatetradeSkill()
        end)
        if ZL.IsForever then
            ZL.RegisterEvent("SKILL_LINES_CHANGED", UpdatetradeSkill)
        end
        C_Timer.NewTicker(5, function()
            UpdatetradeSkill()
        end)
    end

    -- 获取货币信息
    do
        function ZL.MONEYupdate()
            local tbl = {}
            tbl.player = ZL.myName
            tbl.colorplayer = SetClassCFF(ZL.myName, "player")
            tbl.skill = ZongLan[MONEY][realmID][ZL.myName].skill
            for i, v in ipairs(ZL.MONEYall_table) do
                if v.type == "money" then
                    tbl.money = floor(GetMoney() / 1e4)
                elseif v.type == "items" then
                    local itemsTbl = {}
                    for _, v in ipairs(v.ids) do
                        if type(v) == "table" then
                            local items = v
                            for _, itemID in ipairs(items) do
                                local count = GetItemCount(itemID, true)
                                if count and count > 0 then
                                    tinsert(itemsTbl, {
                                        id = itemID,
                                        count = count,
                                    })
                                    break
                                end
                            end
                        else
                            local itemID = v
                            local count = GetItemCount(itemID, true)
                            if count and count > 0 then
                                tinsert(itemsTbl, {
                                    id = itemID,
                                    count = count,
                                })
                            end
                        end
                    end
                    tbl[v.id] = itemsTbl
                elseif v.type == "item" then
                    local id = v.id
                    local tex = v.tex
                    if v.quest2 and not C_QuestLog.IsQuestFlaggedCompleted(v.quest2) then
                        id = v.id2
                        tex = v.tex2
                    end
                    local count
                    if v.id_gold and v.id_copper then
                        count = GetItemCount(v.id_gold, true) * 100 + GetItemCount(v.id, true) + floor(GetItemCount(v.id_copper, true) / 100)
                    else
                        count = GetItemCount(id, true)
                    end
                    local questsCompleted
                    if v.quest and C_QuestLog.IsQuestFlaggedCompleted(v.quest) then
                        questsCompleted = true
                    end
                    tbl[v.id] = { count = count, tex = tex, isItem = true, quest = questsCompleted, }
                elseif v.type == "xp" then
                    tbl.xp = ZongLan[MONEY][realmID][ZL.myName].xp
                elseif v.type ~= "equip" and C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
                    local info = C_CurrencyInfo.GetCurrencyInfo(v.id)
                    if info then
                        local count = info.quantity
                        local tex = info.iconFileID
                        tbl[v.id] = {
                            count = count,
                            tex = tex,
                        }
                        local weekMax = info.maxWeeklyQuantity
                        if weekMax and weekMax > 0 then
                            local weekCount = info.quantityEarnedThisWeek
                            tbl[v.id].weekCount = weekCount
                            tbl[v.id].weekMax = weekMax
                            if weekCount >= weekMax then
                                tbl[v.id].weekTimestamp = select(2, ZL.GetNextWeekTime())
                            end
                        end
                        local totalMax = info.maxQuantity
                        if totalMax and totalMax > 0 then
                            if info.useTotalEarnedForMaxQty then
                                local totalCount = info.totalEarned
                                tbl[v.id].totalCount = totalCount
                                tbl[v.id].totalMax = totalMax
                                if totalCount >= totalMax then
                                    tbl[v.id].weekTimestamp = select(2, ZL.GetNextWeekTime())
                                end
                            else
                                if count >= totalMax then
                                    tbl[v.id].isFull = true
                                end
                            end
                        end
                    end
                end
            end
            ZongLan[MONEY][realmID][ZL.myName] = tbl
        end

        local function UpdateCD()
            local time = GetServerTime()
            for _, db in ipairs(dbNames) do
                if _G[db] and _G[db][MONEY] then
                    for realmID in pairs(_G[db][MONEY]) do
                        if type(realmID) == "number" and type(_G[db][MONEY][realmID]) == "table" then
                            for player in pairs(_G[db][MONEY][realmID]) do
                                for id, v in pairs(_G[db][MONEY][realmID][player]) do
                                    if type(v) == "table" and v.weekTimestamp and time >= v.weekTimestamp then
                                        _G[db][MONEY][realmID][player][id].weekTimestamp = nil
                                        if v.weekCount then
                                            _G[db][MONEY][realmID][player][id].weekCount = 0
                                        end
                                        if v.totalMax then
                                            _G[db][MONEY][realmID][player][id].totalMax = 0
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- 事件
        ZL.Init2(function()
            UpdateCD()
            C_Timer.After(0.5, ZL.MONEYupdate)
        end)
        ZL.RegisterEvent({ "CURRENCY_DISPLAY_UPDATE", "PLAYER_MONEY", "BAG_UPDATE_DELAYED" }, function()
            C_Timer.After(0.5, ZL.MONEYupdate)
        end)
    end

    -- 获取双倍经验
    do
        -- 创建插件框架
        local race = select(2, UnitRace("player"))
        local isPanda = race == "Pandaren"
        local function UpdateXP()
            local exhaustion = GetXPExhaustion() -- 获取剩余双倍经验值
            local per = 0
            if exhaustion then
                local maxXP = UnitXPMax("player")
                per = exhaustion / maxXP * 100
            end
            ZongLan[MONEY][realmID][ZL.myName].xp = {
                per = format("%.1f", per),
                perNow = format("%d", per),
                time = GetServerTime(),
                resting = IsResting(),
                isPanda = isPanda,
            }
        end
        ZL.Init2(UpdateXP)
        ZL.RegisterEvent({ "PLAYER_XP_UPDATE", "UPDATE_EXHAUSTION", "PLAYER_LEVEL_UP", "PLAYER_UPDATE_RESTING" }, UpdateXP)

        function ZL.UpdateXP()
            local time = GetServerTime()
            local function Update(db)
                if not (db and db[MONEY]) then return end
                for realmID, v in pairs(db[MONEY]) do
                    if (type(realmID) == "number" and type(db[MONEY][realmID]) == "table") then
                        for player, v in pairs(db[MONEY][realmID]) do
                            if type(v.xp) == "table" then
                                local num = 4
                                if v.xp.resting then
                                    num = 1
                                end
                                local panda = 1
                                if v.xp.isPanda then
                                    panda = 0.5
                                end
                                v.xp.perNow = min(150, format("%d", tonumber(v.xp.per) + (time - v.xp.time) / (60 * 60 * 8 * num * panda) * 5))
                            end
                        end
                    end
                end
            end
            Update(ZongLan)
            Update(ZongLanDB)
        end
    end

    -- 角色装备和装等
    do
        ZongLan.equip = ZongLan.equip or {}
        ZongLan.equip[realmID] = ZongLan.equip[realmID] or {}
        ZongLan.equip[realmID][ZL.myName] = ZongLan.equip[realmID][ZL.myName] or {}

        local ItemLevelPattern = gsub(ITEM_LEVEL, "%%d", "(%%d+)")
        local function GetItemLevelByTooltip(slot, link)
            ZongLanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
            ZongLanTooltip:SetInventoryItem("player", slot)
            local text, level
            for i = 2, 5 do
                if _G[ZongLanTooltip:GetName() .. "TextLeft" .. i] then
                    text = _G[ZongLanTooltip:GetName() .. "TextLeft" .. i]:GetText() or ""
                    level = string.match(text, ItemLevelPattern)
                    if level then
                        return tonumber(level)
                    end
                end
            end
            level = select(4, GetItemInfo(link)) or 0
            return level
        end

        function ZL.GetPlayerEquip()
            local tbl = ZongLan.equip[realmID][ZL.myName]
            wipe(tbl)
            for slot = 1, 19 do
                local link = GetInventoryItemLink("player", slot)
                if link then
                    local itemID = GetInventoryItemID("player", slot)
                    local quality = GetInventoryItemQuality("player", slot)
                    local level
                    if ZL.IsMOP then
                        level = GetItemLevelByTooltip(slot, link)
                    else
                        level = select(4, GetItemInfo(link))
                    end
                    slot = tostring(slot)
                    tbl[slot] = {
                        link = link,
                        itemID = itemID,
                        quality = quality,
                        level = level,
                    }
                end
            end
        end

        local function GetPlayerAverageItemLevel()
            local _, avgLevel = GetAverageItemLevel()
            ZongLan.playerInfo[realmID][ZL.myName].iLevel = avgLevel or 0
        end

        local delay
        local again
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:SetScript("OnEvent", function(self, event, ...)
            if event == "PLAYER_ENTERING_WORLD" then
                self:UnregisterEvent("PLAYER_ENTERING_WORLD")
                delay = 3
                again = true
                ZL.After(delay, function()
                    self:RegisterEvent("UNIT_INVENTORY_CHANGED")
                end)
            else
                delay = 1
            end
            self.t = 0
            self:SetScript("OnUpdate", function(_, t)
                self.t = self.t + t
                if self.t > delay then
                    self:SetScript("OnUpdate", nil)
                    ZL.GetPlayerEquip()
                    GetPlayerAverageItemLevel()
                    if again then
                        again = nil
                        ZL.After(5, function()
                            ZL.GetPlayerEquip()
                            GetPlayerAverageItemLevel()
                        end)
                    end
                end
            end)
        end)
    end

    -- 背包
    do
        ZongLan.bag = ZongLan.bag or {}
        ZongLan.bag[realmID] = ZongLan.bag[realmID] or {}
        ZongLan.bag[realmID][ZL.myName] = ZongLan.bag[realmID][ZL.myName] or {}
        ZongLan.bag[realmID][ZL.myName].bag = ZongLan.bag[realmID][ZL.myName].bag or {}
        ZongLan.bag[realmID][ZL.myName].bagKey = ZongLan.bag[realmID][ZL.myName].bagKey or {}
        ZongLan.bag[realmID][ZL.myName].bank = ZongLan.bag[realmID][ZL.myName].bank or {}
        ZongLan.bag[realmID][ZL.myName].bagLink = ZongLan.bag[realmID][ZL.myName].bagLink or {}
        ZongLan.bag[realmID][ZL.myName].bagKeyLink = ZongLan.bag[realmID][ZL.myName].bagKeyLink or {}
        ZongLan.bag[realmID][ZL.myName].bankLink = ZongLan.bag[realmID][ZL.myName].bankLink or {}

        local function GetBagSlots(bagType)
            if bagType == "bag" then
                if ZL.IsNewUI then
                    return BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS
                else
                    return BACKPACK_CONTAINER, BACKPACK_CONTAINER + NUM_BAG_SLOTS
                end
            elseif bagType == "bank" then
                if ZL.IsNewUI then
                    return NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS
                else
                    return NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
                end
            end
        end

        local function SaveFromBagNum(bag, bagType)
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info then
                    ZongLan.bag[realmID][ZL.myName][bagType][info.itemID] =
                        (ZongLan.bag[realmID][ZL.myName][bagType][info.itemID] or 0) + info.stackCount
                    local link = info.hyperlink
                    if not link and C_Container.GetContainerItemLink then
                        link = C_Container.GetContainerItemLink(bag, slot)
                    end
                    if link then
                        local linkType = bagType .. "Link"
                        local oldInfo = ZongLan.bag[realmID][ZL.myName][linkType][link]
                        local oldCount = type(oldInfo) == "table" and oldInfo.count or tonumber(oldInfo) or 0
                        local maxStack = select(8, GetItemInfo(link))
                        ZongLan.bag[realmID][ZL.myName][linkType][link] = {
                            count = oldCount + info.stackCount,
                            stackable = (type(oldInfo) == "table" and oldInfo.stackable)
                                or info.stackCount > 1 or (maxStack and maxStack > 1) or nil,
                        }
                    end
                end
            end
        end

        function ZL.SaveBag()
            wipe(ZongLan.bag[realmID][ZL.myName].bag)
            wipe(ZongLan.bag[realmID][ZL.myName].bagKey)
            wipe(ZongLan.bag[realmID][ZL.myName].bagLink)
            wipe(ZongLan.bag[realmID][ZL.myName].bagKeyLink)
            local startBag, endBag = GetBagSlots("bag")
            for bag = startBag, endBag do
                SaveFromBagNum(bag, "bag")
            end
            SaveFromBagNum(-2, "bagKey")
        end

        function ZL.SaveBank()
            if ZL.IsNewUI then return end
            if not ZL.bankIsOpen then return end
            wipe(ZongLan.bag[realmID][ZL.myName].bank)
            wipe(ZongLan.bag[realmID][ZL.myName].bankLink)
            local startBag, endBag = GetBagSlots("bank")
            for bag = startBag, endBag do
                SaveFromBagNum(bag, "bank")
            end
            SaveFromBagNum(-1, "bank")
        end

        function ZL.GetItemBagCount(tbl, itemID)
            return (tbl.bag and tbl.bag[itemID] or 0)
                + (tbl.bagKey and tbl.bagKey[itemID] or 0)
                + (tbl.bank and tbl.bank[itemID] or 0)
        end

        ZL.RegisterEvent("BAG_UPDATE_DELAYED", function()
            ZL.SaveBag()
            ZL.SaveBank()
        end)
        ZL.RegisterEvent("BANKFRAME_OPENED", function()
            ZL.bankIsOpen = true
            ZL.SaveBank()
        end)
        ZL.RegisterEvent("BANKFRAME_CLOSED", function()
            ZL.bankIsOpen = false
        end)
    end

    -- 声望
    if not ZL.IsRetail then
        ZongLan.bag[realmID][ZL.myName].faction = ZongLan.bag[realmID][ZL.myName].faction or {}

		local function SaveReputation()
			for _, factionID in ipairs(ZL.factionTbl) do
				local name, standingID, barMin, barMax, barValue
				if ZL.IsForever then
					local factionData = C_Reputation.GetFactionDataByID(factionID)
					if factionData then
						name = factionData.name
						standingID = factionData.reaction
						barMin = factionData.currentReactionThreshold
						barMax = factionData.nextReactionThreshold
						barValue = factionData.currentStanding
					end
				else
					name, _, standingID, barMin, barMax, barValue = GetFactionInfoByID(factionID)
				end
				if name then
					ZongLan.bag[realmID][ZL.myName].faction[factionID] = {
                        name = name,
                        standingID = standingID,
                        currentValue = barValue - barMin,
                        maxValue = barMax - barMin,
                        factionID = factionID,
                    }
                end
            end
        end

        ZL.Init2(function()
            ZL.After(10, function()
                SaveReputation()
            end)
        end)

        ZL.RegisterEvent("UPDATE_FACTION", function()
            ZL.After(.5, function()
                SaveReputation()
            end)
        end)
    end

    -- 删除重复角色装备数据
    for realmID, v in pairs(ZongLan.equip) do
        if type(realmID) == "number" and type(v) == "table" then
            if ZongLan.playerInfo[realmID] then
                for player in pairs(ZongLan.equip[realmID]) do
                    if not ZongLan.playerInfo[realmID][player] then
                        ZongLan.equip[realmID][player] = nil
                    end
                end
            else
                ZongLan.equip[realmID] = nil
            end
        end
    end
end)
