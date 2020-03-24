-- Aseprite Script to open dialog with relevant color shades (BACKGROUND COLOR VERSION)
-- Written by Dominick John, 2019
-- https://github.com/dominickjohn/aseprite/

function lerp(first, second, by)
  return first * (1 - by) + second * by
end

function lerpRGBInt(color1, color2, amount)
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

function colorToIntBG(color)
  return (color.red << 16) + (color.green << 8) + (color.blue)
end

function colorShiftBG(color, hueShift, satShift, lightShift, shadeShift)
  local newColor = Color(color) -- Make a copy of the color so we don't modify the parameter

  -- SHIFT HUE
  newColor.hue = newColor.hue + hueShift * 359

  -- SHIFT SATURATION
  if (satShift > 0) then
    newColor.saturation = lerp(newColor.saturation, 1, satShift)
  elseif (satShift < 0) then
    newColor.saturation = lerp(newColor.saturation, 0, -satShift)
  end

  -- SHIFT LIGHTNESS
  if (lightShift > 0) then
    newColor.lightness = lerp(newColor.lightness, 1, lightShift)
  elseif (lightShift < 0) then
    newColor.lightness = lerp(newColor.lightness, 0, -lightShift)
  end

  -- SHIFT SHADING
  local newShade = Color {red = newColor.red, green = newColor.green, blue = newColor.blue}
  local shadeInt = 0
  if (shadeShift >= 0) then
    newShade.hue = 50
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), shadeShift)
  elseif (shadeShift < 0) then
    newShade.hue = 215
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), -shadeShift)
  end
  newColor.red = shadeInt >> 16
  newColor.green = shadeInt >> 8 & 255
  newColor.blue = shadeInt & 255

  return newColor
end

function showColorsBG()
  local dlgbg
  dlgbg =
    Dialog {
    title = "Color Shading (BG)",
    onclose = function()
      ColorShadingWindowBoundsBG = dlgbg.bounds
    end
  }

  -- CURRENT FOREGROUND COLOR
  local Cbg = app.bgColor

  -- SHADING COLORS
  local S1bg = colorShift(C, 0, 0.3, -0.6, -0.6)
  local S2bg = colorShift(C, 0, 0.2, -0.2, -0.3)
  local S3bg = colorShift(C, 0, 0.1, -0.1, -0.1)
  local S5bg = colorShift(C, 0, 0.1, 0.1, 0.1)
  local S6bg = colorShift(C, 0, 0.2, 0.2, 0.2)
  local S7bg = colorShift(C, 0, 0.3, 0.5, 0.4)

  -- LIGHTNESS COLORS
  local L1bg = colorShift(C, 0, 0, -0.4, 0)
  local L2bg = colorShift(C, 0, 0, -0.2, 0)
  local L3bg = colorShift(C, 0, 0, -0.1, 0)
  local L5bg = colorShift(C, 0, 0, 0.1, 0)
  local L6bg = colorShift(C, 0, 0, 0.2, 0)
  local L7bg = colorShift(C, 0, 0, 0.4, 0)

  -- SATURATION COLORS
  local C1bg = colorShift(C, 0, -0.5, 0, 0)
  local C2bg = colorShift(C, 0, -0.2, 0, 0)
  local C3bg = colorShift(C, 0, -0.1, 0, 0)
  local C5bg = colorShift(C, 0, 0.1, 0, 0)
  local C6bg = colorShift(C, 0, 0.2, 0, 0)
  local C7bg = colorShift(C, 0, 0.5, 0, 0)

  -- HUE COLORS
  local H1bg = colorShift(C, -0.15, 0, 0, 0)
  local H2bg = colorShift(C, -0.1, 0, 0, 0)
  local H3bg = colorShift(C, -0.05, 0, 0, 0)
  local H5bg = colorShift(C, 0.05, 0, 0, 0)
  local H6bg = colorShift(C, 0.1, 0, 0, 0)
  local H7bg = colorShift(C, 0.15, 0, 0, 0)

  -- DIALOGUE
  dlgbg:color {label = "Current Color", color = Cbg}:button {
    text = "Get",
    onclick = function()
      dlgbg:close()
      showColors()
    end
  }:shades {
    -- SHADING
    id = "sha",
    label = "Shading",
    colors = {S1bg, S2bg, S3bg, Cbg, S5bg, S6bg, S7bg},
    onclick = function(ev)
      app.bgColor = ev.color
    end
  }:shades {
    -- LIGHTNESS
    id = "lit",
    label = "Lightness",
    colors = {L1bg, L2bg, L3bg, Cbg, L5bg, L6bg, L7bg},
    onclick = function(ev)
      app.bgColor = ev.color
    end
  }:shades {
    -- SATURATION
    id = "sat",
    label = "Saturation",
    colors = {C1bg, C2bg, C3bg, Cbg, C5bg, C6bg, C7bg},
    onclick = function(ev)
      app.bgColor = ev.color
    end
  }:shades {
    -- HUE
    id = "hue",
    label = "Hue",
    colors = {H1bg, H2bg, H3bg, Cbg, H5bg, H6bg, H7bg},
    onclick = function(ev)
      app.bgColor = ev.color
    end
  }

  dlgbg:show {wait = false, bounds = ColorShadingWindowBoundsBG}
end

-- Run the script
do
  showColorsBG()
end
