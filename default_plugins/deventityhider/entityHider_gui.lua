require("./entityHider")
require("./themes")
require("./asyncTaskHandler")

-- Creates GUI Table
hider_gui = {

    -- UI Elements
    panel = nil,
    window = nil,
    npcBox = nil,
    npc2DBox = nil,
    playerBox = nil,
    player2DBox = nil,
    projectileBox = nil,
    friendBox = nil,
    otherBox = nil,
    chatFriendBox = nil,
    ignoredBox = nil,
    localBox = nil,
    local2DBox = nil,
    clanBox = nil,
    otherFollowerBox = nil,
    deadNpcBox = nil,
    attackerBox = nil,
    thrallBox = nil,
    eventBox = nil,
    themeDropdown = nil,
    resetButton = nil,
    closeButton = nil,

    -- Sets up entityHider system and imgui elements
    initialize = function(self)
        osrs.print("GUI Initialized...")
        local taskList = AsyncTaskList.New() 
        AsyncTaskList.schedule(taskList,function(callback) hider:initialize(callback) end)  
        AsyncTaskList.schedule(taskList,function(callback) self:refresh() callback() end)      
        AsyncTaskList.schedule(taskList,function(callback) self:showHider() callback() end)
        AsyncTaskList.runTaskList(taskList)
    end,

    -- Destroys old elements if they exist and redefines them. 
    -- Used to set elements to retrieved values from system 
    refresh = function(self)
        osrs.print("Refreshing Hider...")
        self:clear()

        self.panel = osrs.Ui:pane(
            {
                border = false
            }
        )
        self.window = osrs.Ui:window(
            {
                title = "Entity Hider",
                collapsable = false
            }
        )
        self.window.sizeMode = 1
        self.window.width = 250
        self.window.height = 700
        self.window.positionMode = 1
        self.window.x = 0
        self.window.y = 0
        self.npcBox = osrs.Ui:checkbox(
        {
            label = "Hide NPCs",
            value = hider.isHiddenNPC,
            changed = function(value)
                hider:toggleAllNPC(not value)
            end
        }
        )
        self.npc2DBox = osrs.Ui:checkbox(
            {
                label = "Hide NPCs 2D",
                value = hider.isHiddenNPC2D,
                changed = function(value)
                    hider:toggleAllNPC2D(not value)
                end
            }
            )
        self.playerBox = osrs.Ui:checkbox(
            {
                label = "Hide Players",
                value = hider.isHiddenPlayers,
                changed = function(value)
                    hider:togglePlayers(not value)
                end
            }
        )
        self.player2DBox = osrs.Ui:checkbox(
            {
                label = "Hide Players 2D",
                value = hider.isHiddenPlayers2D,
                changed = function(value)
                    hider:togglePlayers2D(not value)
                end
            }
        )
        self.projectileBox = osrs.Ui:checkbox(
            {
                label = "Hide Projectiles",
                value = hider.isHiddenProjectiles,
                changed = function(value)
                    hider:toggleProjectiles(not value)
                end
            }
        )
        self.friendBox = osrs.Ui:checkbox(
            {
                label = "Hide Friends",
                value = hider.isHiddenFriends,
                changed = function(value)
                    hider:toggleFriends(not value)
                end
            }
        )
        self.otherBox = osrs.Ui:checkbox(
            {
                label = "Hide Others",
                value = hider.isHiddenOthers,
                changed = function(value)
                    hider:toggleOthers(not value)
                end
            }
        )
        self.chatFriendBox = osrs.Ui:checkbox(
            {
                label = "Hide Chat Friends",
                value = hider.isHiddenChatFriends,
                changed = function(value)
                    hider:toggleChatFriends(not value)
                end
            }
        )
        self.ignoredBox = osrs.Ui:checkbox(
            {
                label = "Hide Ignored",
                value = hider.isHiddenIgnored,
                changed = function(value)
                    hider:toggleIgnored(not value)
                end
            }
        )
        self.localBox = osrs.Ui:checkbox(
            {
                label = "Hide Local",
                value = hider.isHiddenLocal,
                changed = function(value)
                    hider:toggleLocal(not value)
                end
            }
        )
        self.local2DBox = osrs.Ui:checkbox(
            {
                label = "Hide Local 2D",
                value = hider.isHiddenLocal2D,
                changed = function(value)
                    hider:toggleLocal2D(not value)
                end
            }
        )
        self.clanBox = osrs.Ui:checkbox(
            {
                label = "Hide Clan",
                value = hider.isHiddenClan,
                changed = function(value)
                    hider:toggleClan(not value)
                end
            }
        )
        self.otherFollowerBox = osrs.Ui:checkbox(
            {
                label = "Hide Other Followers",
                value = hider.isHiddenOtherFollower,
                changed = function(value)
                    hider:toggleOtherFollower(not value)
                end
            }
        )
        self.deadNpcBox = osrs.Ui:checkbox(
            {
                label = "Hide Dead NPCs",
                value = hider.isHiddenDeadNPC,
                changed = function(value)
                    hider:toggleDeadNpc(not value)
                end
            }
        )
        self.attackerBox = osrs.Ui:checkbox(
            {
                label = "Hide Attackers",
                value = hider.isHiddenAttackers,
                changed = function(value)
                    hider:toggleAttackers(not value)
                end
            }
        )
        self.thrallBox = osrs.Ui:checkbox(
            {
                label = "Hide Thralls",
                value = hider.isHiddenThralls,
                changed = function(value)
                    hider:toggleThralls(not value)
                end
            }
        )
        self.eventBox = osrs.Ui:checkbox(
            {
                label = "Hide Random Events",
                value = hider.isHiddenEvents,
                changed = function(value)
                    hider:toggleEvents(not value)
                end
            }
        )
        self.themeDropdown = osrs.Ui:dropdown(
            {
                label = "Theme",
                selected = hider.currentTheme,
                changed = function ()
                    self:themeChange(self.themeDropdown.selected)
                    hider:toggleTheme(self.themeDropdown.selected)
                end
            }
        )
        for i, theme in pairs(themeTable) do
            self.themeDropdown.values[i] = theme.name
        end
        self.resetButton = osrs.Ui:textButton(
            {
                text = "Reset",
                onClick = function ()
                    hider:reset(
                        function ()
                            self:clear()
                            self:refresh()
                            self:showHider()
                        end
                    )
                end
            }
        )
        self.closeButton = osrs.Ui:textButton(
            {
                text = "Close",
                onClick = function()
                    self:clear()
                end
            }
        )
    end,
    
    -- Destroys Imgui Elements
    clear = function(self) 
        if self.panel ~= nil then 
            osrs.print("Cleared Entity Hider GUI")
            self.panel:removeChild(self.npcBox)
            self.panel:removeChild(self.npc2DBox)
            self.panel:removeChild(self.playerBox)
            self.panel:removeChild(self.player2DBox)
            self.panel:removeChild(self.projectileBox)    
            self.panel:removeChild(self.friendBox)  
            self.panel:removeChild(self.otherBox)  
            self.panel:removeChild(self.chatFriendBox)
            self.panel:removeChild(self.ignoredBox)  
            self.panel:removeChild(self.localBox) 
            self.panel:removeChild(self.local2DBox)     
            self.panel:removeChild(self.clanBox)   
            self.panel:removeChild(self.otherFollowerBox) 
            self.panel:removeChild(self.deadNpcBox)
            self.panel:removeChild(self.attackerBox)
            self.panel:removeChild(self.thrallBox)
            self.panel:removeChild(self.eventBox)
            self.panel:removeChild(self.themeDropdown)
            self.panel:removeChild(self.resetButton)   
            self.panel:removeChild(self.closeButton)
            self.window:removeChild(self.panel)
            osrs.Ui.canvas:removeChild(self.window)
        end
    end,

    -- Adds Imgui Elements to canvas
    showHider = function(self)
        osrs.print("Showing Hider...")
        self.panel:addChild(self.npcBox)
        self.panel:addChild(self.npc2DBox)
        self.panel:addChild(self.playerBox)
        self.panel:addChild(self.player2DBox)
        self.panel:addChild(self.friendBox)
        self.panel:addChild(self.otherBox)
        self.panel:addChild(self.chatFriendBox)
        self.panel:addChild(self.projectileBox)
        self.panel:addChild(self.clanBox) 
        self.panel:addChild(self.localBox)  
        self.panel:addChild(self.local2DBox)  
        self.panel:addChild(self.ignoredBox)
        self.panel:addChild(self.otherFollowerBox)
        self.panel:addChild(self.deadNpcBox)
        self.panel:addChild(self.attackerBox)
        self.panel:addChild(self.thrallBox)
        self.panel:addChild(self.eventBox)
        self.panel:addChild(self.themeDropdown)
        self.panel:addChild(self.resetButton) 
        self.panel:addChild(self.closeButton)    
        self.window:addChild(self.panel)
        osrs.Ui.canvas:addChild(self.window)
        -- Set Theme
        self:themeChange(self.themeDropdown.selected)
    end,

    -- Change the theme of the UI
    themeChange = function(self, theme)
        osrs.print(theme)
        -- set theme 
        for i, t in pairs(themeTable) do
            if t.name == theme then
                if t.colourArray.colourText ~= nil then 
                    self.window.style.colour.text = t.colourArray.colourText
                end
                if t.colourArray.colourButton ~= nil then 
                    self.window.style.colour.button = t.colourArray.colourButton
                end 
                if t.colourArray.colourCheckMark ~= nil then 
                    self.window.style.colour.checkMark = t.colourArray.colourCheckMark
                end
                if t.colourArray.colourButtonHovered ~= nil then 
                    self.window.style.colour.buttonHovered = t.colourArray.colourButtonHovered
                end 
                if t.colourArray.colourFrameBackgroundHovered ~= nil then 
                    self.window.style.colour.frameBackgroundHovered = t.colourArray.colourFrameBackgroundHovered
                end
                if t.colourArray.colourFrameBackground ~= nil then 
                    self.window.style.colour.frameBackground = t.colourArray.colourFrameBackground
                end
                if t.colourArray.colourTitleBackgroundActive ~= nil then 
                    self.window.style.colour.titleBackgroundActive = t.colourArray.colourTitleBackgroundActive
                end
                if t.colourArray.colourWindowBackground ~= nil then 
                    self.window.style.colour.windowBackground = t.colourArray.colourWindowBackground
                end
            end
        end
    end
}