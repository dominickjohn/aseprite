-- Aseprite Script to open dialog with relevant color shades
-- Written by Dominick John, 2019
-- https://github.com/alpineboarder/aseprite/

local windowBounds = Rectangle(8, 8, 295, 295)

function lerp(first, second, by)
  return first * (1 - by) + second * by
end

function lerpRGBInt (color1, color2, amount)
  local X1 = 1 - amount
  local X2 = color1 >> 24 & 255
  local X3 = color1 >> 16 & 255
  local X4 = color1 >> 8 & 255
  local X5 = color1 & 255
  local X6 = color2 >> 24 & 255
  local X7 = color2 >> 16 & 255
  local X8 = color2 >> 8 & 255
  local X9 = color2 & 255
  local X10 = X2 * X1 + X6 * amount
  local X11 = X3 * X1 + X7 * amount
  local X12 = X4 * X1 + X8 * amount
  local X13 = X5 * X1 + X9 * amount
  return X10 << 24 | X11 << 16 | X12 << 8 | X13
end

function colorToInt(color)
  return (color.red << 16) + (color.green << 8) + (color.blue)
end

function colorShift(color, hueShift, satShift, lightShift, shadeShift)
  local newColor = color

  -- SHIFT HUE
  newColor.hue = newColor.hue + hueShift * 359

  -- SHIFT SATURATION
  if (satShift > 0)
  then
    newColor.saturation = lerp(newColor.saturation, 1, satShift)
  elseif (satShift < 0)
  then
    newColor.saturation = lerp(newColor.saturation, 0, -satShift)
  end

  -- SHIFT LIGHTNESS
  if (lightShift > 0)
  then
    newColor.lightness = lerp(newColor.lightness, 1, lightShift)
  elseif (lightShift < 0)
  then
    newColor.lightness = lerp(newColor.lightness, 0, -lightShift)
  end

  -- SHIFT SHADING
  local newShade = Color{red = newColor.red, green = newColor.green, blue = newColor.blue}
  local shadeInt = 0
  if (shadeShift >= 0)
  then 
    newShade.hue = 50
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), shadeShift)
  elseif (shadeShift < 0)
  then
    newShade.hue = 215
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), -shadeShift)
  end
  newColor.red = shadeInt >> 16
  newColor.green = shadeInt >> 8 & 255
  newColor.blue = shadeInt & 255

  return newColor
end

function showColors()
  local dlg = Dialog("Color Shading")

  -- Set the window size and position to be the same as last refresh (prevents window jumping)
  local bounds = dlg.bounds
  dlg.bounds = windowBounds

  -- CURRENT FOREGROUND COLOR
  local currentColor = colorShift(app.fgColor, 0, 0, 0, 0)

  -- SHADING COLORS
  local S1 = colorShift(app.fgColor, 0, 0.3, -0.6, -0.6)
  local S2 = colorShift(app.fgColor, 0, 0.2, -0.2, -0.3)
  local S3 = colorShift(app.fgColor, 0, 0.1, -0.1, -0.1)
  local S5 = colorShift(app.fgColor, 0, 0.1, 0.1, 0.1)
  local S6 = colorShift(app.fgColor, 0, 0.2, 0.2, 0.2)
  local S7 = colorShift(app.fgColor, 0, 0.3, 0.5, 0.4)

  -- LIGHTNESS COLORS
  local L1 = colorShift(app.fgColor, 0, 0, -0.4, 0)
  local L2 = colorShift(app.fgColor, 0, 0, -0.2, 0)
  local L3 = colorShift(app.fgColor, 0, 0, -0.1, 0)
  local L5 = colorShift(app.fgColor, 0, 0, 0.1, 0)
  local L6 = colorShift(app.fgColor, 0, 0, 0.2, 0)
  local L7 = colorShift(app.fgColor, 0, 0, 0.4, 0)

  -- SATURATION COLORS
  local C1 = colorShift(app.fgColor, 0, -0.5, 0, 0)
  local C2 = colorShift(app.fgColor, 0, -0.2, 0, 0)
  local C3 = colorShift(app.fgColor, 0, -0.1, 0, 0)
  local C5 = colorShift(app.fgColor, 0, 0.1, 0, 0)
  local C6 = colorShift(app.fgColor, 0, 0.2, 0, 0)
  local C7 = colorShift(app.fgColor, 0, 0.5, 0, 0)

  -- HUE COLORS
  local H1 = colorShift(app.fgColor, -0.15, 0, 0, 0)
  local H2 = colorShift(app.fgColor, -0.1, 0, 0, 0)
  local H3 = colorShift(app.fgColor, -0.05, 0, 0, 0)
  local H5 = colorShift(app.fgColor, 0.05, 0, 0, 0)
  local H6 = colorShift(app.fgColor, 0.1, 0, 0, 0)
  local H7 = colorShift(app.fgColor, 0.15, 0, 0, 0)

  -- DIALOGUE
  dlg
  :label{ text="Current Color" }
  :color{ color = currentColor }
  :button{ text="Get Current Color", onclick=function()
    windowBounds = dlg.bounds
    dlg:close()
    showColors()
    end }

  -- SHADING
  :label { text="Shading" }
  :color { color = S1 }
  :color { color = S2 }
  :color { color = S3 }
  :color { color = currentColor }
  :color { color = S5 }
  :color { color = S6 }
  :color { color = S7 }
  :button{ text="Set", onclick=function()
    app.fgColor = S1
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = S2
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = S3
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = currentColor
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = S5
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = S6
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = S7
    end }

  -- LIGHTNESS
  :label{ text="Lightness" }
  :color{ color = L1 }
  :color{ color = L2 }
  :color{ color = L3 }
  :color{ color = currentColor }
  :color{ color = L5 }
  :color{ color = L6 }
  :color{ color = L7 }
  :button{ text="Set", onclick=function()
    app.fgColor = L1
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = L2
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = L3
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = currentColor
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = L5
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = L6
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = L7
    end }

  -- SATURATION
  :label{ text="Saturation" }
  :color{ color = C1 }
  :color{ color = C2 }
  :color{ color = C3 }
  :color{ color = currentColor }
  :color{ color = C5 }
  :color{ color = C6 }
  :color{ color = C7 }
  :button{ text="Set", onclick=function()
    app.fgColor = C1
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = C2
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = C3
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = currentColor
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = C5
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = C6
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = C7
    end }

  -- HUE
  :label{ text="Hue" }
  :color{ color = H1 }
  :color{ color = H2 }
  :color{ color = H3 }
  :color{ color = currentColor }
  :color{ color = H5 }
  :color{ color = H6 }
  :color{ color = H7 }
  :button{ text="Set", onclick=function()
    app.fgColor = H1
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = H2
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = H3
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = currentColor
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = H5
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = H6
    end }
  :button{ text="Set", onclick=function()
    app.fgColor = H7
    end }

  dlg:show{ wait=false }

end

-- Run the script
do
  showColors()
end
