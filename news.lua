module(..., package.seeall)
local widget = require "widget1"
---------- Predefined variables
local dbFilename = "db.sqlite"
local currentScreen = "ItemList"
local directorParams2 = {}
local list2Show_i = {}
local list2Show = {}
--Positioning prams
local screenHeader_y  = 21
local mainListOffset = 45
local rowHeight = 110
local imgHeight = 80
local imgWidth = 80
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
    local topbarImage = display.newImage ("images/common/top-bar.png");
    topbarImage:setReferencePoint( display.TopCenterReferencePoint )
    topbarImage.x = display.contentCenterX
    topbarImage.y = 0
    

    ---Header text
    local screenHeader = display.newText("News",0, 0,native.systemFontBold, 25)
    screenHeader:setTextColor( 130, 130, 130 )
    screenHeader:setReferencePoint( display.CenterReferencePoint )
    screenHeader.x, screenHeader.y = _W/2 , screenHeader_y;
    
    ---One-item-screen elements, by default are located outside of the screen
    local itemHeader = display.newText( "lotsOfText", 0, 0, 0, 0, "Helvetica", 20)
    itemHeader.x = display.contentWidth + 0.5 * display.contentWidth
    itemHeader.y = 65
    localGroup:insert( itemHeader )

    local itemSelected = display.newText( "lotsOfText", 0, 0, _W-50, 0, "Helvetica", 12)
    itemSelected.x = display.contentWidth + itemSelected.contentWidth * 0.5
    itemSelected.y = itemSelected.contentHeight * 0.5
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
    list.y = 26 + display.contentHeight * 0.5
	
 local function onRowRender( event )
        local row = event.row
        local rowGroup = event.view
        local label = "List item "
        local color = 255
        local path = system.pathForFile( "", system.DocumentsDirectory )

        local myW = rowGroup.contentWidth
        local myH = rowGroup.contentHeigth
        local imageName = list2Show[event.id].image
        ------------background

        row.background = display.newImageRect ("images/common/bg-row.png", 300, 111);
		row.background:setReferencePoint( display.TopLeftReferencePoint )
        row.background.x = 0
        row.background.y = 0
        rowGroup:insert( row.background )
        -----------Image
        local imageName = list2Show[event.id].image
        if imageName and imageName ~= "" then
            row.img = display.newImageRect ( directorParams2.tableName .. "/" ..  imageName, system.DocumentsDirectory, imgHeight,  imgWidth)
            row.img.x = imgWidth/2 + 10
            row.img.y = rowGroup.contentHeight * 0.5
            rowGroup:insert( row.img )
        else
            row.img = {width = 0}
        end
    -------------Caption
    row.caption = display.newRetinaText( rowGroup,  list2Show[event.id].caption, 0, 0, native.systemFontBold, 18)
    row.caption:setTextColor( 255,140,0 )
    row.caption:setReferencePoint( display.CenterLeftReferencePoint )
    row.caption.x, row.caption.y = row.img.width + 18, 5 + row.caption.height * 0.5
    rowGroup:insert( row.caption )

    ----------------Text preview
    local w = myW -(row.img.width + 28)
    local w2
    if row.img.width == 0 then w2 = 8 else w2 = row.img.width + 18 end

    row.txtPreview = display.newText( rowGroup, list2Show[event.id].shortTxt,w2,row.caption.height + 5 , w, 0,  native.systemFont, 12 )
    row.txtPreview:setTextColor( 0,0,0 )
    rowGroup:insert( row.txtPreview )
    row.txtPreview:setReferencePoint( display.TopLeftReferencePoint )

    ----------------Arrow
    row.arrow = display.newImage( "images/common/arrow.png", false )
    row.arrow.x = rowGroup.contentWidth - row.arrow.contentWidth * 2
    row.arrow.y = rowGroup.contentHeight * 0.5
    rowGroup:insert( row.arrow )
    end

    --Handle the back button release event
    local function onBackRelease()
        --Transition in the list, transition out the item selected text and the back button
        local params = {}
        if currentScreen == "ItemList" then
            director:changeScene(params, "menu", "moveFromLeft");
        elseif currentScreen == "OneItem" then
            transition.to( list, { x = 160, time = 400, transition = easing.outExpo } )
            transition.to( itemSelected, { x = display.contentWidth + itemSelected.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
            transition.to( itemHeader, { x = display.contentWidth + itemHeader.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
            currentScreen = "ItemList"
            transition.to( bigPicture, { x = 2*_W, time = 400, transition = easing.outExpo } )

        end


    end

     --Handle row touch events
    local function onRowTouch( event )
        local row = event.row
        local background = event.background

        if event.phase == "press" then

        elseif event.phase == "release" or event.phase == "tap" then

            if bigPicture ~= nil then
                bigPicture:removeSelf()
            end

            ----------Big picture
            bigPicture = display.newImage (directorParams2.tableName .. "/" ..  list2Show[event.id].image, system.DocumentsDirectory, 0, 0, true);
            bigPicture:setReferencePoint( display.TopCenterReferencePoint )
            bigPicture.x = display.contentCenterX + _W*2
            bigPicture.y = 90

            transition.to( bigPicture, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )

            --Update the item selected text
            itemSelected.text =  list2Show[event.id].txt
            itemHeader.text  = list2Show[event.id].caption

            itemSelected:setReferencePoint( display.TopCenterReferencePoint )

            itemSelected.y = bigPicture.contentHeight  + itemHeader.contentHeight + 80
            transition.to( list, { x = - 2*_W, time = 400, transition = easing.outExpo } )
            transition.to( itemSelected, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
            transition.to( itemHeader, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )

            currentScreen = "OneItem"
            row.reRender = true
        end
    end
    --Insert elements into list
    local sqlite3 =require("sqlite3")
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )
    local row2
    local SQL = "SELECT rowid, fCaption, fText, fImageName, fShortText from " .. directorParams2.tableName --.. " ORDER BY fDate DESC"
    print("Tablelist SQL: ", SQL)
    for row2 in db:nrows(SQL) do
        list2Show["ID_" .. row2.rowid] = {caption = row2.fCaption, image = row2.fImageName, txt = row2.fText }
        list2Show["ID_" .. row2.rowid].shortTxt = row2.fShortText
        list:insertRow{
            id = "ID_" .. row2.rowid,
            height = rowHeight,
            rowColor = { 255, 255, 255, 0 },
            onRender = onRowRender,
            listener = onRowTouch
        }
    end
    db:close()
---======BACK BUTTON
    --Handle the back button release event
    local function onBackRelease()
        --Transition in the list, transition out the item selected text and the back button
        local params = {}
        if currentScreen == "ItemList" then
            director:changeScene(params, "menu", "moveFromLeft");
        elseif currentScreen == "OneItem" then
            transition.to( list, { x = 160, time = 400, transition = easing.outExpo } )
            transition.to( itemSelected, { x = display.contentWidth + itemSelected.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
            transition.to( itemHeader, { x = display.contentWidth + itemHeader.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
            currentScreen = "ItemList"
            transition.to( bigPicture, { x = 2*_W, time = 400, transition = easing.outExpo } )
        end
    end
	
    --Create the back button
    local backButton = widget.newButton{
        default = "images/common/button-back.png", 
        over = "images/common/button-back-pressed.png",
        width = 25, height = 18,
        left = 10,
        top = 13,
        onRelease = onBackRelease
    }
    --Insert widgets/images into a group
    localGroup:insert( list )
	localGroup:insert(topbarImage)
	localGroup:insert(screenHeader)
    localGroup:insert( backButton )
    return localGroup;
end
