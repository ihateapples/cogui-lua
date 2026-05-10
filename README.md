# cogui-lua

A minimal gui library for roblox lua (exploiting)

![Lua](https://img.shields.io/badge/Language-Lua-blue)
![License](https://img.shields.io/badge/License-MIT-green)

---

## About

**cogui** is a easy to use gui library designed for roblox exploiting. It provides a dark theme with dragging, tab support, and simple ui elements.

---

## Example

```lua
local cogui = loadstring(game:HttpGet('https://raw.githubusercontent.com/ihateapples/cogui-lua/refs/heads/main/cogui.lua'))()

local window = cogui:CreateWindow("cogui example", UDim2.fromOffset(680, 720))

local tab = window:CreateTab("Main")
local left = tab:CreateSector("Left Sector", "left")
local right = tab:CreateSector("Right Sector", "right")

left:AddButton("test button", function()
    print("clicked")
end)

left:AddToggle("test toggle", true, function(state)
    print("toggle:", state)
end)
```
