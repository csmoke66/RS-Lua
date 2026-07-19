-- colour-picker.lua

---@class ColourPicker
---@field window Window
---@field redSlider SliderInt
---@field greenSlider SliderInt
---@field blueSlider SliderInt
---@field alphaSlider SliderInt
---@field originalPreview Pane
---@field preview Pane
---@field hueSlider Pane
---@field doneButton Button
local ColourPicker = {}

function ColourPicker:remove()
    osrs.Ui.canvas:removeChild(self.window)
end

function ColourPicker:updatePreview()
    -- The preview overlay is the second child of the preview pane. Intend to refactor to child object later.
    self.preview:child(1).style.colour.childBackground = osrs.Colour4.new(
        self.redSlider.value / 255,
        self.greenSlider.value / 255,
        self.blueSlider.value / 255,
        self.alphaSlider.value / 255
    )
end

---@param colour Colour
function ColourPicker:setColour(colour)
    self.redSlider.value = colour.r
    self.redSlider.display = tostring(colour.r)
    self.greenSlider.value = colour.g
    self.greenSlider.display = tostring(colour.g)
    self.blueSlider.value = colour.b
    self.blueSlider.display = tostring(colour.b)
    self.alphaSlider.value = colour.a
    self.alphaSlider.display = tostring(colour.a)
    self:updatePreview()
end

---@param r number
---@param g number
---@param b number
function ColourPicker:setColourFromRGB(r, g, b)
    self.redSlider.value = r
    self.redSlider.display = tostring(r)
    self.greenSlider.value = g
    self.greenSlider.display = tostring(g)
    self.blueSlider.value = b
    self.blueSlider.display = tostring(b)
    self:updatePreview()
end

---@param onClose fun(colour:Colour)
---@param startingColour Colour | nil
function ColourPicker:pickColour(onClose, startingColour)
    self.doneButton.onClick = function()
        onClose(osrs.Colour.new(
            self.redSlider.value,
            self.greenSlider.value,
            self.blueSlider.value,
            self.alphaSlider.value
        ))
        self:remove()
    end
    if startingColour ~= nil then
        self:setColour(startingColour)
        self.originalPreview:child(1).style.colour.childBackground = osrs.Colour4.new(
            startingColour.r / 255,
            startingColour.g / 255,
            startingColour.b / 255,
            startingColour.a / 255
        )
    end
    osrs.Ui.canvas:addChild(self.window)
end

---@param label string
---@param value integer
---@param y number
---@param updatePreview fun()
---@return SliderInt
local function buildSlider(label, value, y, updatePreview)
    local slider = osrs.Ui.sliderInt({
        display = tostring(value),
        label = label,
        min = 0,
        max = 255,
        value = value,
        sizeMode = osrs.Ui.LayoutMode.MANUAL,
        height = 255,
        width = 500,
        positionMode = osrs.Ui.LayoutMode.MANUAL,
        x = 60,
        y = y,
    })
    slider.onValueChange = function(newValue)
        slider.display = tostring(newValue)
        updatePreview()
    end
    return slider
end

---@param setColourFromRGB fun(r: number, g: number, b: number)
---@return Pane
-- Builds a pane that contains a Hue Slider.
local function buildHueSlider(setColourFromRGB)
    local hueSlider = osrs.Ui.pane({
        border = false,
        sizeMode = osrs.Ui.LayoutMode.MANUAL,
        height = 255,
        width = 30,
        scrollable = false,
        positionMode = osrs.Ui.LayoutMode.MANUAL,
        x = 20,
        y = 50,
        style = {
            windowPadding = osrs.Vector2.new(0, 0),
        }
    })
    local hueSliderBackground = osrs.Ui.pane({
        border = false,
        sizeMode = osrs.Ui.LayoutMode.MANUAL,
        height = 255,
        width = 20,
        positionMode = osrs.Ui.LayoutMode.MANUAL,
        x = 0,
        y = 0,
        style = {
            windowPadding = osrs.Vector2.new(0, 0),
        }
    })

       local hueSliderForeground = osrs.Ui.pane({
        border = false,
        sizeMode = osrs.Ui.LayoutMode.MANUAL,
        height = 255,
        width = 50,
        positionMode = osrs.Ui.LayoutMode.MANUAL,
        x = 0,
        y = 0,
        style = {
            windowPadding = osrs.Vector2.new(0, 0),
        }
    })
    hueSlider:addChild(hueSliderBackground)
    hueSlider:addChild(hueSliderForeground)
    for i = 1, 255, 1 do
        local hueBox = osrs.Ui.pane({
            sizeMode = osrs.Ui.LayoutMode.MANUAL,
            height = 1,
            width = 0,
            border = false,
            style = {
                colour = { childBackground = HSBtoColour4(1 - i / (255 - 1), 1, 1) },
                itemSpacing = osrs.Vector2.new(0, 0),
            }
        })
        hueSliderBackground:addChild(hueBox)
    end

    local hueSliderInt = osrs.Ui.vSliderInt({
        sizeMode = osrs.Ui.LayoutMode.MANUAL,
        height = 255,
        width = 42.5,
        positionMode = osrs.Ui.LayoutMode.MANUAL,
        x = -20, -- This should overlap the hueSliderBackground, but for some reason the background always appears on top making the slider un clickable.
        y = 0,
        min = 0,
        max = 255,
        display = '',
        label = '',
        value = 0,
        style = {
            colour = { frameBackground = osrs.Colour4.new(0, 0, 0, 0) }
        }
    })
    hueSliderInt.onValueChange = function(newValue)
        local r, g, b = HSBtoRGB(newValue / 255, 1, 1)
        setColourFromRGB(r, g, b)
    end
    hueSliderForeground:addChild(hueSliderInt)
    return hueSlider
end

---@param x number
---@param y number
---@return Pane
-- Builds a pane that contains a 10x10 background grid and a preview of the current colour.
local function buildPreview(x, y)
    local preview = osrs.Ui.pane({
        scrollable = false,
        sizeMode = osrs.Ui.LayoutMode.MANUAL,
        height = 100,
        width = 100,
        positionMode = osrs.Ui.LayoutMode.MANUAL,
        x = x,
        y = y,
        style = {
            itemSpacing = osrs.Vector2.new(0, 0),
            windowPadding = osrs.Vector2.new(0, 0),
        }
    })
    local previewBackground = osrs.Ui.pane({
        scrollable = false,
        sizeMode = osrs.Ui.LayoutMode.MANUAL,
        height = 100,
        width = 100,
        positionMode = osrs.Ui.LayoutMode.MANUAL,
        x = 0,
        y = 0,
        style = {
            windowPadding = osrs.Vector2.new(0, 0),
        }
    })
    preview:addChild(previewBackground)

    for x = 0, 100, 10 do
        for y = 0, 100, 10 do
            local gridBackground = osrs.Ui.pane({
                sizeMode = osrs.Ui.LayoutMode.MANUAL,
                height = 10,
                width = 10,
                positionMode = osrs.Ui.LayoutMode.MANUAL,
                x = x,
                y = y,
                border = false,
                style = {
                    colour = {
                        childBackground = ((math.floor(x / 10) + math.floor(y / 10)) % 2 == 0)
                            and osrs.Colour4.new(1, 1, 1, 1)
                            or osrs.Colour4.new(0.25, 0.25, 0.25, 1)
                    },
                    itemSpacing = osrs.Vector2.new(0, 0),
                }
            })
            previewBackground:addChild(gridBackground)
        end
    end

    local previewColour = osrs.Ui.pane({
        sizeMode = osrs.Ui.LayoutMode.MANUAL,
        height = 100,
        width = 100,
        positionMode = osrs.Ui.LayoutMode.MANUAL,
        x = 0,
        y = 0,
        columns = 10,
        rows = 10,
    })
    preview:addChild(previewColour)
    return preview
end

---@param hue number
---@param saturation number
---@param brightness number
---@return integer, integer, integer
function HSBtoRGB(hue, saturation, brightness)
    local r, g, b = 0, 0, 0
    if saturation == 0 then
        r = math.floor(brightness * 255.0 + 0.5)
        g = r
        b = r
    else
        local h = (hue - math.floor(hue)) * 6.0
        local f = h - math.floor(h)
        local p = brightness * (1.0 - saturation)
        local q = brightness * (1.0 - saturation * f)
        local t = brightness * (1.0 - saturation * (1.0 - f))
        local i = math.floor(h)
        if i == 0 then
            r = math.floor(brightness * 255.0 + 0.5)
            g = math.floor(t * 255.0 + 0.5)
            b = math.floor(p * 255.0 + 0.5)
        elseif i == 1 then
            r = math.floor(q * 255.0 + 0.5)
            g = math.floor(brightness * 255.0 + 0.5)
            b = math.floor(p * 255.0 + 0.5)
        elseif i == 2 then
            r = math.floor(p * 255.0 + 0.5)
            g = math.floor(brightness * 255.0 + 0.5)
            b = math.floor(t * 255.0 + 0.5)
        elseif i == 3 then
            r = math.floor(p * 255.0 + 0.5)
            g = math.floor(q * 255.0 + 0.5)
            b = math.floor(brightness * 255.0 + 0.5)
        elseif i == 4 then
            r = math.floor(t * 255.0 + 0.5)
            g = math.floor(p * 255.0 + 0.5)
            b = math.floor(brightness * 255.0 + 0.5)
        elseif i == 5 then
            r = math.floor(brightness * 255.0 + 0.5)
            g = math.floor(p * 255.0 + 0.5)
            b = math.floor(q * 255.0 + 0.5)
        end
    end
    return r, g, b
end

---@param hue number
---@param saturation number
---@param brightness number
---@return Colour4
function HSBtoColour4(hue, saturation, brightness)
    local r, g, b = HSBtoRGB(hue, saturation, brightness)
    return osrs.Colour4.new(r / 255, g / 255, b / 255, 1.0)
end

---@return ColourPicker
function ColourPicker.new()
    ---@type ColourPicker
    local self = setmetatable({}, ColourPicker)
    self.window = osrs.Ui.window({
        title = 'Colour Picker',
        collapsable = false,
        resizable = false,
        sizeMode = osrs.Ui.LayoutMode.MANUAL,
        width = 370,
        height = 350,
    })

    local defaultColour = osrs.Colour.new(255, 255, 255, 255)

    
    self.hueSlider = buildHueSlider(function(r, g, b) self:setColourFromRGB(r, g, b) end)
    self.window:addChild(self.hueSlider)

    self.originalPreview = buildPreview(60, 50)
    self.window:addChild(self.originalPreview)

    self.preview = buildPreview(170, 50)
    self.window:addChild(self.preview)

    self.redSlider = buildSlider('Red', defaultColour.r, 170, function() self:updatePreview() end)
    self.window:addChild(self.redSlider)

    self.greenSlider = buildSlider('Green', defaultColour.g, 200, function() self:updatePreview() end)
    self.window:addChild(self.greenSlider)

    self.blueSlider = buildSlider('Blue', defaultColour.b, 230, function() self:updatePreview() end)
    self.window:addChild(self.blueSlider)

    self.alphaSlider = buildSlider('Opacity', defaultColour.a, 260, function() self:updatePreview() end)
    self.window:addChild(self.alphaSlider)

    self.doneButton = osrs.Ui.textButton({
        text = 'Done',
        sizeMode = osrs.Ui.LayoutMode.MANUAL,
        width = 50,
        positionMode = osrs.Ui.LayoutMode.MANUAL,
        x = 160,
        y = 300,
    })
    self.window:addChild(self.doneButton)

    return self
end

function ColourPicker.__index(tab, key)
    return ColourPicker[key]
end

return ColourPicker