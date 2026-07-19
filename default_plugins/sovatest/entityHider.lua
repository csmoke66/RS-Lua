local json = require("./json")
require("./asyncTaskHandler")

hider = {

    updateLoop = function(self)
        -- Get Local Player
        _, Local = osrs.ClientOp.playerFindSelf();

        -- npcs
        npcs = osrs.ClientOp.getNpcIdAll()
        for index, npc_id in pairs(npcs) do
            npc = osrs.ClientOp.getNpcObj(npc_id)
            npc:render3D(self:renderNPC3D(npc))
            npc:render2D(not self.isHiddenNPC2D)
        end

        -- players
        players = osrs.ClientOp.getPlayerIdAll()
        for index, player_id in pairs(players) do
            player = osrs.ClientOp.getPlayerObj(player_id)
            player:render3D(self:renderPlayer3D(player))
            player:render2D(self:renderPlayer2D(player))
        end

        -- projectiles 
        osrs.ClientOp.renderProjectiles(not self.isHiddenProjectiles)
    end,

    renderNPC3D = function(self, npc)
        if(self.isHiddenNPC) then 
            return false
        elseif(self.isHiddenOtherFollower and npc:isFollower() and not npc:isLocalFollower()) then
            return false
        elseif(self.isHiddenDeadNPC and npc:isDead()) then
            return false
        elseif(self.isHiddenThralls and npc:getType() == self.thralls) then
            return false
        elseif(self.isHiddenAttackers and npc:isInteracting() == Local and npc:getType() ~= self.randomEventNpc) then 
            return false
        elseif(self.isHiddenEvents and npc:getType() == self.randomEventNpc and not npc:isInteracting() == Local) then
            return false
        end
        return true
    end,

    renderPlayer3D = function(self, player)
        if(self.isHiddenPlayers and not player:isLocalPlayer()) then
            return false
        elseif(self.isHiddenFriends and player:isOnlineFriend()) then
            return false
        elseif(self.isHiddenOthers and not player:isLocalPlayer() and not player:isOnlineFriend() 
        and not player:isGroup() and not player:isIgnored() 
        and not player:isFriendChat()) and not player:isInteracting() == Local then 
            return false
        elseif(self.isHiddenChatFriends and player:isFriendChat()) then
            return false
        elseif(self.isHiddenClan and player:isGroup() and not player:isLocalPlayer()) then
            return false
        elseif(self.isHiddenLocal and player:isLocalPlayer()) then
            return false
        elseif(self.isHiddenIgnored and player:isIgnored()) then
            return false
        elseif(self.isHiddenAttackers and player:isInteracting() == Local) then 
            return false
        end
        return true
    end,

    renderPlayer2D = function(self, player)
        if(self.isHiddenPlayers2D and not player:isLocalPlayer()) then
            return false
        elseif(self.isHiddenLocal2D and player:isLocalPlayer()) then
            return false
        end
        return true
    end,

    -- Controls NPC Visibility
    toggleAllNPC = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenNPC = false
            osrs.print("Enabled Show NPCs.") 
            osrs.Persistence.setValue("hideNPC", "0")
        else
            self.isHiddenNPC = true
            osrs.print("Disabled Show NPCs.") 
            osrs.Persistence.setValue("hideNPC", "1")
        end
    end,

    -- Controls NPC 2D Element Visibility
    toggleAllNPC2D = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenNPC2D = false
            osrs.print("Enabled Show NPCs 2D Elements.") 
            osrs.Persistence.setValue("hideNPC2D", "0")
        else
            self.isHiddenNPC2D = true
            osrs.print("Disabled Show NPCs 2D Elements.") 
            osrs.Persistence.setValue("hideNPC2D", "1")
        end
    end,

    -- Controls Visibility of other players
    togglePlayers = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenPlayers = false;
            osrs.print("Enabled Show Players.") 
            osrs.Persistence.setValue("hidePlayers", "0")
        else
            self.isHiddenPlayers = true;
            osrs.print("Disabled Show Players.") 
            osrs.Persistence.setValue("hidePlayers", "1")
        end
    end,

    -- Controls Visibility of other players 2D Element
    togglePlayers2D = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenPlayers2D = false;
            osrs.print("Enabled Show Players 2D Elements.") 
            osrs.Persistence.setValue("hidePlayers2D", "0")
        else
            self.isHiddenPlayers2D = true;
            osrs.print("Disabled Show Players 2D Elements.") 
            osrs.Persistence.setValue("hidePlayers2D", "1")
        end
    end,

    -- Controls Friend Visibility
    toggleFriends = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenFriends = false
            osrs.print("Enabled Show Friends.") 
            osrs.Persistence.setValue("hideFriends", "0")
        else
            self.isHiddenFriends = true
            osrs.print("Disabled Show Friends.") 
            osrs.Persistence.setValue("hideFriends", "1")
        end
    end,

    -- Controls Others Visibility
    toggleOthers = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenOthers = false
            osrs.print("Enabled Show Others.") 
            osrs.Persistence.setValue("hideOthers", "0")
        else
            self.isHiddenOthers = true
            osrs.print("Disabled Show Others.") 
            osrs.Persistence.setValue("hideOthers", "1")
        end
    end,

    -- Controls Chat Friend Visibility
    toggleChatFriends = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenChatFriends = false
            osrs.print("Enabled Show Chat Friends.") 
            osrs.Persistence.setValue("hideChatFriends", "0")
        else
            self.isHiddenChatFriends = true
            osrs.print("Disabled Show Chat Friends.") 
            osrs.Persistence.setValue("hideChatFriends", "1")
        end
    end,

    -- Controls Projectiles Visibility
    toggleProjectiles = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenProjectiles = false
            osrs.print("Enabled Show Projectiles.") 
            osrs.Persistence.setValue("hideProjectiles", "0")
        else
            self.isHiddenProjectiles = true
            osrs.print("Disabled Show Projectiles.") 
            osrs.Persistence.setValue("hideProjectiles", "1")
        end
    end,

    -- Controls Visibility of Players in Clan
    toggleClan = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenClan = false
            osrs.print("Enabled Show Clan.") 
            osrs.Persistence.setValue("hideProjectiles", "0")
        else
            self.isHiddenClan = true
            osrs.print("Disabled Show Clan.") 
            osrs.Persistence.setValue("hideClan", "1")
        end
    end,

    -- Controls Local Player Visibility
    toggleLocal = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenLocal = false
            osrs.print("Enabled Show Local.") 
            osrs.Persistence.setValue("hideLocal", "0")
        else
            self.isHiddenLocal = true
            osrs.print("Disabled Show Local.") 
            osrs.Persistence.setValue("hideLocal", "1")
        end
    end,

    -- Controls Local Player 2D Element Visibility
    toggleLocal2D = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenLocal2D = false
            osrs.print("Enabled Show Local 2D Elements.") 
            osrs.Persistence.setValue("hideLocal2D", "0")
        else
            self.isHiddenLocal2D = true
            osrs.print("Disabled Show Local 2D Elements.") 
            osrs.Persistence.setValue("hideLocal2D", "1")
        end
    end,

    -- Controls Ignored Players Visibility
    toggleIgnored = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenIgnored = false;
            osrs.print("Enabled Show Ignored.") 
            osrs.Persistence.setValue("hideIgnored", "0")
        else
            self.isHiddenIgnored = true;
            osrs.print("Disabled Show Ignored.") 
            osrs.Persistence.setValue("hideIgnored", "1")
        end
    end,

    -- Controls other players followers Visibility
    toggleOtherFollower = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenOtherFollower = false;
            osrs.print("Enabled Show Other Followers.") 
            osrs.Persistence.setValue("hideOtherFollower", "0")
        else
            self.isHiddenOtherFollower = true;
            osrs.print("Disabled Show Other Followers.") 
            osrs.Persistence.setValue("hideOtherFollower", "1")
        end
    end,

    -- Controls Dead Npc Visibility
    toggleDeadNpc = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenDeadNPC = false;
            osrs.print("Enabled Show Dead NPCs.") 
            osrs.Persistence.setValue("hideDeadNpc", "0")
        else
            self.isHiddenDeadNPC = true;
            osrs.print("Disabled Show Dead NPCs.") 
            osrs.Persistence.setValue("hideDeadNpc", "1")
        end
    end,

    -- Controls Attackers Visibility
    toggleAttackers = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenAttackers = false;
            osrs.print("Not currently setup.") 
            osrs.Persistence.setValue("hideAttackers", "0")
        else
            self.isHiddenAttackers = true;
            osrs.print("Not currently setup.") 
            osrs.Persistence.setValue("hideAttackers", "1")
        end
    end,

    -- Controls thralls Visibility
    toggleThralls = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenThralls = false;
            osrs.print("Enabled Show Thralls.") 
            osrs.Persistence.setValue("hideThralls", "0")
        else
            self.isHiddenThralls = true;
            osrs.print("Disabled Show Thralls.") 
            osrs.Persistence.setValue("hideThralls", "1")
        end
    end,

    -- Controls random event npc Visibility
    toggleEvents = function(self, shouldShow)
        if(shouldShow) then
            self.isHiddenEvents = false;
            osrs.print("Enabled Show Random Events.") 
            osrs.Persistence.setValue("hideEvents", "0")
        else
            self.isHiddenEvents = true;
            osrs.print("Disabled Show Random Events.") 
            osrs.Persistence.setValue("hideEvents", "1")
        end
    end,

    -- Controls current UI theme
    toggleTheme = function(self, theme)
        self.currentTheme = theme
        osrs.Persistence.setValue("currentTheme", theme)
    end,

    -- Resets all flags to default
    reset = function(self, callback)
        osrs.Persistence.clear(
            function(ok) 
                if ok then 
                    osrs.print("Clear all flags OK!")
                    self:toggleAllNPC(true)
                    self:toggleAllNPC2D(true)
                    self:togglePlayers(true)
                    self:togglePlayers2D(true)
                    self:toggleFriends(true)
                    self:toggleOthers(true)
                    self:toggleChatFriends(true)
                    self:toggleProjectiles(true)
                    self:toggleClan(true)
                    self:toggleLocal(true)
                    self:toggleLocal2D(true)
                    self:toggleIgnored(true)
                    self:toggleOtherFollower(true)
                    self:toggleDeadNpc(true)
                    self:toggleAttackers(true)
                    self:toggleThralls(true)
                    self:toggleEvents(true)
                    if(callback ~= nil) then
                        callback()
                    end
                else 
                    osrs.print("Clear failed")
                end
            end,
            -- false because we dont want thing to be global?
            false
        )
        -- keep theme
        self:toggleTheme(self.currentTheme)
        osrs.Persistence.setValue("initialized", "yes")
    end,

    -- Clears all specific hidden NPCs
    clearAllHidden = function ()
        osrs.print("Cleared All Hidden NPCs from log.") 
        osrs.Persistence.setValue("hiddenNpcs","")
        osrs.EntityHider:clearHiddenNpcs()
    end,

    -- Prints list of all NPCs specified to be hidden
    printAllHidden = function()
        osrs.Persistence.getValue("hiddenNpcs",
        function(key, value) 
            if(value == nil) then
                return
            end
            local hiddenIds = json.decode(value)
            osrs.print("Printing All Hidden NPCs: ")
            for _, id in ipairs(hiddenIds) do
                osrs.print("ID: " .. tostring(id))
            end
        end)
    end,

    -- Updates the theme using the specified by looking up the stored value of the past theme
    queryTheme = function(self, callback)
        osrs.print("Reviewing UI Theme..")
        osrs.Persistence.getValue("currentTheme",
            function(key, value)
                if(value == nil) then
                    osrs.print("RESULT: No theme logged.") 
                    if(callback ~= nil) then
                        callback()
                    end
                    return
                end
                osrs.print("Theme is: " .. value)
                self:toggleTheme(value)
                if(callback ~= nil) then
                    callback()
                end
            end
        )
    end,

    -- Updates the visibility using the specified toggleFunction by looking up the stored value of the 
    -- specified flag
    queryFlag = function(self, callback, flagName, toggleFunction)
        osrs.print("Reviewing ".. flagName .. " Flag...")
        osrs.Persistence.getValue(flagName, 
            function(key, value) 
                if(value == nil) then
                    osrs.print("RESULT: No " .. flagName .. " Flag logged.")
                    if(callback ~= nil) then
                        callback() 
                    end
                    return
                end
                if(tonumber(value) == 0) then
                    osrs.print("RESULT: " .. flagName .. " was false.") 
                else
                    osrs.print("RESULT: " .. flagName .. " was true.") 
                end
                osrs.print(type(toggleFunction))
                toggleFunction(self, tonumber(value) == 0)
                if(callback ~= nil) then
                    callback()
                end
            end
        )
    end,

    -- Initialize Entity Hider Lua System
    initialize = function(self, __callback)
        local taskList = AsyncTaskList.New()
        AsyncTaskList.schedule(taskList, function (callback)
            osrs.Persistence.getValue("initialized",
                function(key,value)
                    if(value == nil) then
                        osrs.print("Initialized for the first time.")
                        osrs.Persistence.setValue("initialized", "yes")
                        if(callback ~= nil) then
                            AsyncTaskList.schedule(taskList,function(_callback)  _callback()  if(__callback ~= nil) then __callback() end end)
                            callback()
                        end
                        return
                    else
                        osrs.print("Welcome back to Entity Hider")
                        osrs.print("Initializing with Existing Settings. Use Reset command to wipe all settings.")
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideNPC", self.toggleAllNPC) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideNPC2D", self.toggleAllNPC2D) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hidePlayers", self.togglePlayers) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hidePlayers2D", self.togglePlayers2D) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideFriends", self.toggleFriends) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideOthers", self.toggleOthers) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideChatFriends", self.toggleChatFriends) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideProjectiels", self.toggleProjectiles) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideIgnored", self.toggleIgnored) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideLocal", self.toggleLocal) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideLocal2D", self.toggleLocal2D) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideClan", self.toggleClan) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideOtherFollower", self.toggleOtherFollower) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideDeadNpc", self.toggleDeadNpc) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideAttackers", self.toggleAttackers) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideThralls", self.toggleThralls) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryFlag(_callback, "hideEvents", self.toggleEvents) end)
                        AsyncTaskList.schedule(taskList,function(_callback) self:queryTheme(_callback) end)
                        AsyncTaskList.schedule(taskList,function(_callback) 
                            osrs.Events.subscribe(
                                function() self:updateLoop() end,
                                osrs.Events.ON_GAME_TICK) 
                            _callback()
                        end)
                        AsyncTaskList.schedule(taskList,function(_callback)  _callback()  if(__callback ~= nil) then __callback() end end)
                        if(callback ~= nil) then
                            callback()
                        end
                    end
                end
            )
            end
        )
        AsyncTaskList.runTaskList(taskList)
    end,

    -- List of Hidden NPCs
    hiddenNpcs = {},

    -- Hiding Flags
    isHiddenNPC = false,
    isHiddenNPC2D = false,
    isHiddenPlayers = false,
    isHiddenPlayers2D = false,
    isHiddenProjectiles = false,
    isHiddenFriends = false,
    isHiddenOthers = false,
    isHiddenChatFriends = false,
    isHiddenIgnored = false,
    isHiddenLocal = false,
    isHiddenClan = false,
    isHiddenOtherFollower = false,
    isHiddenDeadNPC = false,
    isHiddenAttackers = false,
    isHiddenThralls = false,
    isHiddenEvents = false,

    -- Past Selected Theme
    currentTheme = "RuneScape",

    -- NPC Types
    thralls = 1540,
    randomEventNpc = 771
}