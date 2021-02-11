RequestStreamedTextureDict("CommonMenu")

CustomUI = { }

CustomUI.debug = false

local menus = { }
local keys = { 
    up = 172, 
    down = 173, 
    left = 174, 
    right = 175, 
    select = 176, 
    back = 177,
    mup = 181,
    mdown = 180,
}

local optionCount = 0

local currentKey = nil

local currentMenu = nil

local menuWidth = 0.23

local titleHeight = 0.11
local titleYOffset = 0.03
local titleScale = 1.0

local buttonHeight = 0.038
local buttonFont = 0
local buttonScale = 0.365
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.005

local continuity = {}

local function HudColourToTable(r,g,b,a) return { r, g, b, a or 255 } end

local function debugPrint(text)
    if CustomUI.debug then
        Citizen.Trace('[CustomUI] '..tostring(text))
    end
end


local function setMenuProperty(id, property, value)
    if id and menus[id] then
        menus[id][property] = value
        debugPrint(id..' menu property changed: { '..tostring(property)..', '..tostring(value)..' }')
    end
end


local function isMenuVisible(id)
    if id and menus[id] then
        return menus[id].visible
    else
        return false
    end
end

local function setMenuVisible(id, visible, holdCurrent)
    if id and menus[id] then
        setMenuProperty(id, 'visible', visible)

        if visible then
            if id ~= currentMenu and isMenuVisible(currentMenu) then
                setMenuVisible(currentMenu, false, true)
            else
                setMenuProperty(id, 'currentOption', 1)
            end

            currentMenu = id
        end
    end
end


function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
    BeginTextCommandDisplayText("STRING")
        if color then 
            SetTextColour(color[1], color[2], color[3], color[4])
        else
            SetTextColour(255, 255, 255, 255)
        end
        SetTextFont(font)
        SetTextScale(scale, scale)

        if shadow then
            SetTextDropShadow(2, 2, 0, 0, 0)
        end

        if menus[currentMenu] then
            if center then
                SetTextCentre(center)
            elseif alignRight then
                SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menuWidth - buttonTextXOffset)
                SetTextRightJustify(true)
            end
        end
        AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end


function drawRect(x, y, width, height, color)
    DrawRect(x, y, width, height, color[1], color[2], color[3], color[4])
end

function drawSprite(textDict, sprite, x, y, scale, color)
    if HasStreamedTextureDictLoaded(textDict) then
        DrawSprite(textDict, sprite, x, y, 0.0265, 0.05, 0, color[1], color[2], color[3], color[4])
    else
        RequestStreamedTextureDict(textDict, false)
    end
end

local function drawTitle()
    if menus[currentMenu] then
        local x = menus[currentMenu].x + menuWidth / 2
        local y = menus[currentMenu].y + titleHeight / 2

		if menus[currentMenu].titleFont == "!sprite!" then
			local color = menus[currentMenu].titleBackgroundColor
			local textDict, sprite = table.unpack(menus[currentMenu].titleColor)
		elseif menus[currentMenu].titleFont == "~sprite~" then
			local color = menus[currentMenu].titleBackgroundColor
			local textDict, sprite = table.unpack(menus[currentMenu].titleColor)

		else
            if HasStreamedTextureDictLoaded("CommonMenu") then
                SetScriptGfxDrawOrder(0)
            end

        end

        x,y,color,textDict,sprite = nil
    end
end

local function drawSubTitle()
    if menus[currentMenu] then
        local x = menus[currentMenu].x + (menuWidth / 2)
        local y = menus[currentMenu].y + (titleHeight + buttonHeight / 2)
        local subtitle = menus[currentMenu].subTitle

        drawRect(x, y, menuWidth, buttonHeight, menus[currentMenu].subTitleBackgroundColor)
        if subtitle:find("|") then
            drawText(subtitle:sub(1,subtitle:find("|")-1), menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, false, buttonScale, false)
            drawText(subtitle:sub(subtitle:find("|")+1), menus[currentMenu].x + menuWidth, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, false, buttonScale, false, false, true)
        else
            drawText(menus[currentMenu].subTitle, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, false, buttonScale, false)
            drawText(tostring(menus[currentMenu].currentOption)..' / '..tostring(optionCount), menus[currentMenu].x + menuWidth, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, false, buttonScale, false, false, true)
        end

        x,y,subTitleColor = nil
    end
end

local function drawMenuBackground()
    if menus[currentMenu] then
        local x = menus[currentMenu].x + menuWidth / 2
        local menuHeight = buttonHeight*( (optionCount <= menus[currentMenu].maxOptionCount) and optionCount or menus[currentMenu].maxOptionCount )
        local y = menus[currentMenu].y + titleHeight + buttonHeight + menuHeight / 2

        if HasStreamedTextureDictLoaded("CommonMenu") then
            SetScriptGfxDrawOrder(0)
            DrawSprite("CommonMenu", "Gradient_Bgd", x, y, menuWidth, menuHeight, 0.0, 255, 255, 255, 255, 0)
        else
            RequestStreamedTextureDict("CommonMenu")
        end

       x,y,menuHeight = nil
    end
end

local function drawArrows()
    local x = menus[currentMenu].x + menuWidth / 2
    local menuHeight = buttonHeight*(menus[currentMenu].maxOptionCount+1)
    local y = menus[currentMenu].y + titleHeight + menuHeight + buttonHeight/2

    if HasStreamedTextureDictLoaded("CommonMenu") then
        local colour = menus[currentMenu].subTitleBackgroundColor
        drawRect(x, y, menuWidth, buttonHeight, {colour[1], colour[2], colour[3], 182})
        DrawSprite("CommonMenu", "shop_arrows_upanddown", x, y, 0.0265, 0.05, 0.0, 255, 255, 255, 255, 0)
    else
        RequestStreamedTextureDict("CommonMenu")
    end

    x,menuHeight,y,color = nil
end

local function drawButton(text, subText)
    local x = menus[currentMenu].x + menuWidth / 2
    local multiplier

    if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
        multiplier = optionCount
    elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
        multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
    end

    if multiplier then
        local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
        local backgroundColor = nil
        local textColor = nil
        local subTextColor = nil
        local shadow = false

        if menus[currentMenu].currentOption == optionCount and text ~= "" then
            backgroundColor = menus[currentMenu].menuFocusBackgroundColor
            textColor = menus[currentMenu].menuFocusTextColor
            subTextColor = menus[currentMenu].menuFocusTextColor
        else
            backgroundColor = menus[currentMenu].menuBackgroundColor
            textColor = menus[currentMenu].menuTextColor
            subTextColor = menus[currentMenu].menuSubTextColor
            shadow = true
        end

        if text ~= "!!separator!!" then
            if menus[currentMenu].currentOption == optionCount and HasStreamedTextureDictLoaded("CommonMenu") then
                SetScriptGfxDrawOrder(1)
                DrawSprite("CommonMenu", "Gradient_Nav", x, y, menuWidth, buttonHeight, 0.0, 255, 255, 255, 255, 0)
            end
 
            drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow)

            if subText then
                drawText(subText, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTextColor, buttonScale, false, shadow, true)
            end
        end
    end

    x,y,backgroundColor,textColor,subTextColor,shadow,multiplier = nil
end

local function drawDisabledButton(text, subText)
    local x = menus[currentMenu].x + menuWidth / 2
    local multiplier

    if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
        multiplier = optionCount
    elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
        multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
    end

    if multiplier then
        local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
        local backgroundColor = menus[currentMenu].menuBackgroundColor
        local textColor = HudColourToTable(GetHudColour(5))
        local subTextColor = HudColourToTable(GetHudColour(5))
        local shadow = false
        drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow)

        if subText then
            drawText(subText, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTextColor, buttonScale, false, shadow, true)
        end
    end

    x,y,backgroundColor,textColor,subTextColor,shadow,multiplier = nil
end

local function drawSpriteButton(text, textDict, sprite, focusSprite)
    local x = menus[currentMenu].x + menuWidth / 2
    local multiplier

    if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
        multiplier = optionCount
    elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
        multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
    end

    if multiplier then
        local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
        local backgroundColor = nil
        local textColor = nil
        local subTextColor = nil
        local shadow = false

        if menus[currentMenu].currentOption == optionCount then
            backgroundColor = menus[currentMenu].menuFocusBackgroundColor
            textColor = menus[currentMenu].menuFocusTextColor
            subTextColor = menus[currentMenu].menuFocusTextColor
        else
            backgroundColor = menus[currentMenu].menuBackgroundColor
            textColor = menus[currentMenu].menuTextColor
            subTextColor = menus[currentMenu].menuSubTextColor
            shadow = true
        end

        if menus[currentMenu].currentOption == optionCount and HasStreamedTextureDictLoaded("CommonMenu") then
            SetScriptGfxDrawOrder(1)
            DrawSprite("CommonMenu", "Gradient_Nav", x, y, menuWidth, buttonHeight, 0.0, 255, 255, 255, 255, 0)
        end
        
        drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow)

        if textDict and sprite then
			if focusSprite then
                if menus[currentMenu].currentOption == optionCount then
                    SetScriptGfxDrawOrder(2)
					drawSprite(textDict, focusSprite, menus[currentMenu].x + menuWidth - buttonTextXOffset*2 , y - buttonHeight / 2 + (buttonTextYOffset*3.75), buttonScale, menus[currentMenu].menuSubTextColor)
                else
                    SetScriptGfxDrawOrder(2)
					drawSprite(textDict, sprite, menus[currentMenu].x + menuWidth - buttonTextXOffset*2 , y - buttonHeight / 2 + (buttonTextYOffset*3.75), buttonScale, subTextColor)
				end
            else
                SetScriptGfxDrawOrder(2)
				drawSprite(textDict, sprite, menus[currentMenu].x + menuWidth - buttonTextXOffset*2 , y - buttonHeight / 2 + (buttonTextYOffset*3.75), buttonScale, subTextColor)
			end
        end
    end

    x,y,backgroundColor,textColor,subTextColor,shadow,multiplier = nil
end

local function stopConflictingInputs()
   

    for _,key in pairs(keys) do
        SetInputExclusive(0, key)
    end
   
    DisableControlAction(0, 22, true) 
    DisableControlAction(0, 37, true)
    DisableControlAction(0, 200, true)
end


function CustomUI.CreateMenu(id, title, closeCallback)
  
    menus[id] = { }
 
    menus[id].subTitle = 'INTERACTION MENU'

    menus[id].visible = false

    menus[id].previousMenu = nil

    menus[id].aboutToBeClosed = false

  
    menus[id].x = 0.0175
    menus[id].y = 0

    menus[id].currentOption = 1
    menus[id].maxOptionCount = 12

    menus[id].menuTextColor = {255, 255, 255, 255}
    menus[id].menuSubTextColor = {255, 255, 255, 255}
    menus[id].menuFocusTextColor = {0, 0, 0, 255}
    menus[id].menuFocusBackgroundColor = {198, 25, 66, 255}
    menus[id].menuBackgroundColor = {198, 25, 66, 160}

    menus[id].subTitleBackgroundColor = {menus[id].menuBackgroundColor[1], menus[id].menuBackgroundColor[2], menus[id].menuBackgroundColor[3], 255 }

    menus[id].buttonPressedSound = { name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" } 

    menus[id].closeCallback = closeCallback or function() return true end

    debugPrint(tostring(id)..' menu created')
end


function CustomUI.CreateSubMenu(id, parent, subTitle, closeCallback)
    if menus[parent] then
        CustomUI.CreateMenu(id, menus[parent].title)

        if subTitle then
            setMenuProperty(id, 'subTitle', string.upper(subTitle))
        else
            setMenuProperty(id, 'subTitle', string.upper(menus[parent].subTitle))
        end

        setMenuProperty(id, 'previousMenu', parent)

        setMenuProperty(id, 'x', menus[parent].x)
        setMenuProperty(id, 'y', menus[parent].y)
        setMenuProperty(id, 'maxOptionCount', menus[parent].maxOptionCount)

        setMenuProperty(id, 'menuTextColor', menus[parent].menuTextColor)
        setMenuProperty(id, 'menuSubTextColor', menus[parent].menuSubTextColor)
        setMenuProperty(id, 'menuFocusTextColor', menus[parent].menuFocusTextColor)
        setMenuProperty(id, 'menuFocusBackgroundColor', menus[parent].menuFocusBackgroundColor)
        setMenuProperty(id, 'menuBackgroundColor', menus[parent].menuBackgroundColor)
        setMenuProperty(id, 'subTitleBackgroundColor', menus[parent].subTitleBackgroundColor)
        setMenuProperty(id, 'closeCallback', closeCallback or function() return true end)
      
    else
        debugPrint('Failed to create '..tostring(id)..' submenu: '..tostring(parent)..' parent menu doesn\'t exist')
    end
end


function CustomUI.CurrentMenu()
    return currentMenu
end

function CustomUI.MenuTable()
    return menus
end


function CustomUI.OpenMenu(id)
    if id and menus[id] then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        setMenuVisible(id, true)

        continuity.lastPedWeapon = GetCurrentPedWeapon(PlayerPedId())
        SetPedCurrentWeaponVisible(PlayerPedId(), false, true)

        debugPrint(tostring(id)..' menu opened')
    else
        debugPrint('Failed to open '..tostring(id)..' menu: it doesn\'t exist')
    end
end


function CustomUI.IsMenuOpened(id)
    return isMenuVisible(id)
end


function CustomUI.IsAnyMenuOpened()
    for id, _ in pairs(menus) do
        if isMenuVisible(id) then return true end
    end

    return false
end

function CustomUI.IsAnyMenuWithTitleOpened(subtitle)
    for id, v in pairs(menus) do
		if isMenuVisible(id) then
			if v.title == subtitle then
				return true
			end
		end
    end

    return false
end

function CustomUI.IsMenuAboutToBeClosed()
    if menus[currentMenu] then
        return menus[currentMenu].aboutToBeClosed
    else
        return false
    end
end

function CustomUI.IsThisMenuAboutToBeClosed(id)
    if menus[id] then
        return menus[id].aboutToBeClosed
    else
        return false
    end
end


function CustomUI.CloseMenu()
    if menus[currentMenu] then
        if menus[currentMenu].aboutToBeClosed then
            menus[currentMenu].aboutToBeClosed = false
            setMenuVisible(currentMenu, false)
            debugPrint(tostring(currentMenu)..' menu closed')
            PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            optionCount = 0
            currentMenu = nil
            currentKey = nil

        
            if continuity.lastPedWeapon then
                SetCurrentPedWeapon(PlayerPedId(), continuity.lastPedWeapon, true)
            end
            
            continuity = {}

            Citizen.CreateThread(function()
                while IsDisabledControlPressed(0, 200) or IsDisabledControlJustReleased(0, 200) do
                    Citizen.Wait(0)
                    DisableControlAction(0, 200, true)
                end
            end)
        else
            if menus[currentMenu].closeCallback() then
                menus[currentMenu].aboutToBeClosed = true
                debugPrint(tostring(currentMenu)..' menu about to be closed')
            end
        end
    end
end


function CustomUI.Button(text, subText)
    local buttonText = text
    if subText then
        buttonText = '{ '..tostring(buttonText)..', '..tostring(subText)..' }'
    end

    if menus[currentMenu] then
        optionCount = optionCount + 1

        local isCurrent = menus[currentMenu].currentOption == optionCount

        drawButton(text, subText)

        if isCurrent then
			if text == "!!separator!!" then
				if IsDisabledControlPressed(0, keys.up) then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
				elseif IsDisabledControlPressed(0, keys.down) then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
				end
			elseif currentKey == keys.select then
				if text ~= "" then PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true) end
				debugPrint(buttonText..' button pressed')
				return true, isCurrent
			elseif currentKey == keys.left or currentKey == keys.right then
				if text ~= "" then PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) end
			end
        end

        return false, isCurrent
    else
        debugPrint('Failed to create '..buttonText..' button: '..tostring(currentMenu)..' menu doesn\'t exist')

        return false
    end

    buttonText,isCurrent = nil
end

function CustomUI.DisabledButton(text, subText)
    local buttonText = text
    if subText then
        buttonText = '{ '..tostring(buttonText)..', '..tostring(subText)..' }'
    end

    if menus[currentMenu] then
        optionCount = optionCount + 1

        local isCurrent = menus[currentMenu].currentOption == optionCount

        drawDisabledButton(text ~= "!!separator!!" and text or "", subText)

        if isCurrent then
            if IsDisabledControlPressed(0, 172) then
                menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
            elseif IsDisabledControlPressed(0, 173) then
                menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
            end
        end

        return false, isCurrent
    else
        debugPrint('Failed to create '..buttonText..' button: '..tostring(currentMenu)..' menu doesn\'t exist')

        return false
    end

    buttonText,isCurrent = nil
end

function CustomUI.SpriteButton(text, textDict, sprite, focusSprite)
    local buttonText = text

    if menus[currentMenu] then
        optionCount = optionCount + 1

        local isCurrent = menus[currentMenu].currentOption == optionCount

        drawSpriteButton(text, textDict, sprite, focusSprite)

        if isCurrent then
            if currentKey == keys.select then
                PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
                debugPrint(buttonText..' button pressed')
                return true, isCurrent
            elseif currentKey == keys.left or currentKey == keys.right then
                PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
        end

        return false, isCurrent
    else
        debugPrint('Failed to create '..buttonText..' button: '..tostring(currentMenu)..' menu doesn\'t exist')

        return false, isCurrent
    end

    buttonText,isCurrent = nil
end

function CustomUI.SpriteMenuButton(text, textDict, sprite, focusSprite, id)
    if menus[id] then
        local clicked, hovered = CustomUI.SpriteButton(text, textDict, sprite, focusSprite)
        if clicked then
            setMenuVisible(currentMenu, false)
            setMenuVisible(id, true, true)
        end
        return clicked, hovered
    else
        debugPrint('Failed to create '..tostring(text)..' menu button: '..tostring(id)..' submenu doesn\'t exist')
    end

    clicked,hovered = nil
end

function CustomUI.MenuButton(text, id, secondtext)
    if menus[id] then
        if CustomUI.Button(text, (secondtext and secondtext or "→")) then
            setMenuVisible(currentMenu, false)
            setMenuVisible(id, true, true)

            return true
        end
    else
        debugPrint('Failed to create '..tostring(text)..' menu button: '..tostring(id)..' submenu doesn\'t exist')
    end

    return false
end

function CustomUI.SwitchMenu(id)
	setMenuVisible(currentMenu, false)
    setMenuVisible(id, true, true)
end


function CustomUI.CheckBox(text, bool, callback)

    local sprite = bool and "shop_box_tick" or "shop_box_blank"
    local focusSprite = bool and "shop_box_tickb" or "shop_box_blankb"

    if CustomUI.SpriteButton(text, "commonmenu", sprite, focusSprite) then
        bool = not bool
        debugPrint(tostring(text)..' checkbox changed to '..tostring(bool))
        callback(bool)

        return true
    end

    sprite,focusSprite = nil

    return false
end


function CustomUI.ComboBox(text, items, currentIndex, selectedIndex, callback, displaycb)
    local itemsCount = #items
    local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)
	local getDisplayText = displaycb or (function(t) return tostring(t or "") end)
	local selectedItem = getDisplayText(items[currentIndex])

    if itemsCount > 1 and isCurrent then
        selectedItem = '← '..selectedItem..' →'
    end

    if CustomUI.Button(text, selectedItem) then
        selectedIndex = currentIndex
        callback(currentIndex, selectedIndex)
        return true,isCurrent
    elseif isCurrent then
        if currentKey == keys.left then
            if currentIndex > 1 then currentIndex = currentIndex - 1 else currentIndex = itemsCount end
        elseif currentKey == keys.right then
            if currentIndex < itemsCount then currentIndex = currentIndex + 1 else currentIndex = 1 end
        end
    else
        currentIndex = selectedIndex
    end

    callback(currentIndex, selectedIndex)
    itemsCount,isCurrent,getDisplayText,selectedItem = nil
    return false, isCurrent
end


function CustomUI.Display()
    if isMenuVisible(currentMenu) and not IsPauseMenuActive() then

        stopConflictingInputs()

        if menus[currentMenu].aboutToBeClosed then
            CustomUI.CloseMenu()
        else
            ClearAllHelpMessages()

            drawTitle()
            drawSubTitle()
            drawMenuBackground()
            if optionCount > menus[currentMenu].maxOptionCount then
                drawArrows()
            end

            currentKey = nil

            if IsDisabledControlJustPressed(0, keys.down) or IsDisabledControlJustPressed(0, keys.mdown) then
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

                if menus[currentMenu].currentOption < optionCount then
                    menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
                else
                    menus[currentMenu].currentOption = 1
                end
            elseif IsDisabledControlJustPressed(0, keys.up) or IsDisabledControlJustPressed(0, keys.mup) then
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

                if menus[currentMenu].currentOption > 1 then
                    menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
                else
                    menus[currentMenu].currentOption = optionCount
                end
            elseif IsDisabledControlJustPressed(0, keys.left) then
                currentKey = keys.left
            elseif IsDisabledControlJustPressed(0, keys.right) then
                currentKey = keys.right
            elseif IsDisabledControlJustPressed(0, keys.select) then
                currentKey = keys.select
            elseif IsDisabledControlJustPressed(0, keys.back) then
                if menus[menus[currentMenu].previousMenu] then
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    menus[currentMenu].closeCallback()
                    setMenuVisible(menus[currentMenu].previousMenu, true)
                else
                    CustomUI.CloseMenu()
                end
            end

            optionCount = 0
        end
    end
end


function CustomUI.SetMenuWidth(id, width)
    setMenuProperty(id, 'width', width)
end


function CustomUI.SetMenuX(id, x)
    setMenuProperty(id, 'x', x)
end


function CustomUI.SetMenuY(id, y)
    setMenuProperty(id, 'y', y)
end


function CustomUI.SetMenuMaxOptionCountOnScreen(id, count)
    setMenuProperty(id, 'maxOptionCount', count)
end


function CustomUI.SetTitleColor(id, r, g, b, a)
    setMenuProperty(id, 'titleColor', { r, g, b, a or  menus[id].titleColor[4] })
end


function CustomUI.SetTitleBackgroundColor(id, r, g, b, a)
    setMenuProperty(id, 'titleBackgroundColor', { 198, 25, 66, a })
end


function CustomUI.UseSpriteAsBackground(id, textDict, sprite, r, g, b, a, stillDrawText)
	if stillDrawText then setMenuProperty(id, 'titleFont', "~sprite~") else setMenuProperty(id, 'titleFont', "!sprite!") end
    setMenuProperty(id, 'titleColor', {textDict, sprite})
	setMenuProperty(id, 'titleBackgroundColor', { 198, 25, 66, a or menus[id].titleBackgroundColor[4] })
end


function CustomUI.SetSubTitle(id, text)
    setMenuProperty(id, 'subTitle', string.upper(text))
end


function CustomUI.SetMenuBackgroundColor(id, r, g, b, a)
    setMenuProperty(id, 'menuBackgroundColor', {198, 25, 66, a or menus[id].menuBackgroundColor[4] })
end


function CustomUI.SetMenuTextColor(id, r, g, b, a)
    setMenuProperty(id, 'menuTextColor', { r, g, b, a or menus[id].menuTextColor[4] })
end

function CustomUI.SetMenuSubTextColor(id, r, g, b, a)
    setMenuProperty(id, 'menuSubTextColor', { r, g, b, a or menus[id].menuSubTextColor[4] })
end

function CustomUI.SetMenuFocusColor(id, r, g, b, a)
    setMenuProperty(id, 'menuFocusColor', { r, g, b, a or menus[id].menuFocusColor[4] })
end


function CustomUI.SetMenuButtonPressedSound(id, name, set)
    setMenuProperty(id, 'buttonPressedSound', { ['name'] = name, ['set'] = set })
end
