module(..., package.seeall)
local widget = require "widget"
---------- Predefined variables
local dbFilename = "db.sqlite"
local currentScreen = "ItemList"
local directorParams2 = {}
local list2Show_i = {}
local list2Show = {}
--Positioning prams
local screenHeader_y  = 21
local mainListOffset = 45
local rowHeight = 80
local imgHeight = 70
local imgWidth = 70
local _H = display.contentHeight;
local _W = display.contentWidth;


function new(directorParams)
    print("newa.lua new() Enter")
    directorParams2 = directorParams
    local iPhone5;
    local phoneDiff;
    local localGroup = display.newGroup();
    -- Check if this is iPhone5 or lower (Android to be added)
    -- resolution for iPhone5 320x568 for other iPhones 320x480
    if string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then iPhone5 = true else iPhone5 = false end
    ---===================VISUAL PART
    -- show the same background for any device with maximum height, if screen is smaller - no prob
    local bg = display.newImageRect ("images/common/bg.png", _W, 568);
    bg:setReferencePoint( display.TopLeftReferencePoint )
    bg.x, bg.y = 0,0;
    localGroup:insert(bg);
    --topbar
    local logoImage = display.newImage ("images/common/top-bar.png");
    logoImage:setReferencePoint( display.TopCenterReferencePoint )
    logoImage.x = display.contentCenterX
    logoImage.y = 0
    

    ---Header text
    local screenHeader = display.newText("News",0, 0,native.systemFontBold, 25)
    screenHeader:setTextColor( 130, 130, 130 )
    screenHeader:setReferencePoint( display.CenterReferencePoint )
    screenHeader.x, screenHeader.y = _W/2 , screenHeader_y;
    
    ---One-item-screen elements, by default are located outside of the screen
    local itemHeader = display.newText( "InitialHeader", 0, 0, _W, 0, native.systemFontBold, 16)
    itemHeader.x = 1.5 * _W
    localGroup:insert( itemHeader )

    local itemSelected = display.newText( "Initial Description", 0, 0, _W - 15, 0, native.systemFont, 12)
    itemSelected.x = 1.5 * _W
    localGroup:insert( itemSelected )
    ---========Createmain Table view
    local listOptions = {
        
        height = 445,
    	width = 300,
        maskFile = "mask-320x366.png"
    }

    local list = widget.newTableView( listOptions )
    list:setReferencePoint( display.CenterReferencePoint )
	list.x = (display.contentWidth * 0.5) 
    list.y = 20 + display.contentHeight * 0.5
	
-- onEvent listener for the tableView
local function onRowTouch( event )
        local row = event.target
        local rowGroup = event.view
		local background = event.background
		
		if event.phase == "press" then
		print( "Pressed row: " .. row.index )
		background:setFillColor( 0, 110, 233, 255 ) 
        end
		
        if event.phase == "press" then  

            if not row.isCategory then rowGroup.alpha = 0.5; end

        elseif event.phase == "swipeLeft" then
                print( "Swiped left." )

        elseif event.phase == "swipeRight" then
                print( "Swiped right." )

        elseif event.phase == "release" then

                if not row.isCategory then
                        -- reRender property tells row to refresh if still onScreen when content moves
                        row.reRender = true
                        print( "You touched row #" .. event.index )
                end
        end

        return true
end

-- onRender listener for the tableView
local function onRowRender( event )
        local row = event.target
        local rowGroup = event.view
				
		 --------Background
        row.background = display.newImageRect ("images/common/bg-row.png", 300, 111);
		row.background:setReferencePoint( display.TopLeftReferencePoint )
        row.background.x = 0
        row.background.y = 0
        rowGroup:insert( row.background )
			
		
		local text = display.newRetinaText( "Image #" .. event.index, 12, 0, "Helvetica-Bold", 18 )
        text:setReferencePoint( display.CenterLeftReferencePoint )
        text.y = row.height * 0.5
		
        if not row.isCategory then
                text.x = 15
                text:setTextColor( 0 )
        end

        -- must insert everything into event.view:
        rowGroup:insert( text )
end

-- Create 100 rows, and two categories to the tableView:
for i=1,4 do
        local rowHeight, rowColor, lineColor, isCategory
		rowHeight = 110
        -- function below is responsible for creating the row
        list:insertRow{
                onEvent=onRowTouch,
                onRender=onRowRender,
                height=rowHeight,
                isCategory=isCategory,
                rowColor=rowColor,
                lineColor=lineColor
        }

end
---======BACK BUTTON
    --Handle the back button release event
    local function onBackRelease()
        --Transition in the list, transition out the item selected text and the back button
        local params = {}
        if currentScreen == "ItemList" then
            director:changeScene(params, "menu", "moveFromLeft");
        elseif currentScreen == "OneItem" then
            transition.to( list, { x = 0, time = 400, transition = easing.outExpo } )
            transition.to( itemSelected, { x = display.contentWidth + itemSelected.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
            transition.to( itemHeader, { x = display.contentWidth + itemHeader.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
            currentScreen = "ItemList"
        end
    end
    --Create the back button
    local backButton = widget.newButton{
        default = "images/common/button-back.png", 
        over = "images/common/button-back-pressed.png",
        width = 25, height = 20,
        left = 10,
        top = 13,
        onRelease = onBackRelease
    }
    --Insert widgets/images into a group
    localGroup:insert( list )
	localGroup:insert(logoImage)
	localGroup:insert(screenHeader)
    localGroup:insert( backButton )
	
    return localGroup;
end
