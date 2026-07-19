local ColourPicker = require('colour-picker')
local colourPicker = ColourPicker.new()
colourPicker:pickColour(
    function(colour)
        osrs.print(string.format('Picked colour: r=%d, g=%d, b=%d, a=%d', colour.r, colour.g, colour.b, colour.a))
    end,
    osrs.Colour.new(255, 255, 0, 100)
) 