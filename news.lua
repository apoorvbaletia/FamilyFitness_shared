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
    local bg = display.newImageRect ("images2/blank_bg.jpg", _W, 568);
    bg:setReferencePoint( display.TopLeftReferencePoint )
    bg.x, bg.y = 0,0;
    localGroup:insert(bg);
    ---Header text
    local screenHeader = display.newText("Новости", 0, 0, native.systemFontBold, 20)
    screenHeader:setReferencePoint( display.CenterReferencePoint )
    screenHeader.x, screenHeader.y = _W/2 , screenHeader_y;
    localGroup:insert(screenHeader);
    ---One-item-screen elements, by default are located outside of the screen
    local itemHeader = display.newText( "InitialHeader", 0, 0, _W, 0, native.systemFontBold, 16)
    itemHeader.x = 1.5 * _W
    localGroup:insert( itemHeader )

    local itemSelected = display.newText( "Initial Description", 0, 0, _W - 15, 0, native.systemFont, 12)
    itemSelected.x = 1.5 * _W
    localGroup:insert( itemSelected )
    ---========Createmain Table view
    local function getNewsFromDB()
--        here we init list2Show with a data from database
        local sqlite3 = require "sqlite3"
        local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
        local db = sqlite3.open( path )
        local row2
        local SQL = "SELECT rowid, fDate, fCaption, fImageName, fText, fShortText from " .. directorParams2.tableName .. " ORDER BY fDate DESC"
        print("Tablelist SQL: ", SQL)
        for row2 in db:nrows(SQL) do
            list2Show["ID_" .. row2.rowid] = {caption = row2.fCaption, image = row2.fImageName, txt = row2.fText }
            list2Show["ID_" .. row2.rowid].date = row2.fDate
            list2Show["ID_" .. row2.rowid].shortTxt = row2.fShortText
            list2Show["ID_" .. row2.rowid].id = "ID_" .. row2.rowid
        end
        db:close()
    end
    getNewsFromDB();
    ----------
    local function onRowRender( event )
        local row = event.row
        local label = "List item "
        local color = 255
        local path = system.pathForFile( "", system.DocumentsDirectory )
        local myW = row.contentWidth
        local myH = row.contentHeigth
        print("onRowRender(): list2Show_i[event.row.index].id " .. list2Show_i[event.row.index].id )
        --        local dataA = list2Show[event.id]
        local dataA = list2Show[list2Show_i[event.row.index].id]

        --------Background
        row.background = display.newImageRect ("images2/scr3/s3_news_line.png", 320, 80);
        row:insert( row.background )
        row.background:setReferencePoint( display.TopLeftReferencePoint )
        row.background.x, row.background.y = 0 , 0;
        -------------Image
        local imageName = dataA.image
        if imageName and imageName ~= "" then
            row.img = display.newImageRect ( directorParams2.tableName .. "/" ..  imageName, system.DocumentsDirectory, imgHeight,  imgWidth)
            row.img.x = imgWidth/2 + 5
            row.img.y = row.contentHeight * 0.5
            row:insert( row.img )
        else
            row.img = {width = 0}
        end
        -------------Caption
        row.caption = display.newRetinaText( row, dataA.date .. ": " .. dataA.caption, 0, 0, native.systemFontBold, 12 )
        row.caption:setTextColor( color )
        row.caption:setReferencePoint( display.CenterLeftReferencePoint )
        row.caption.x, row.caption.y = row.img.width + 15, row.caption.height * 0.5
        row:insert( row.caption )
        ----------------Text preview
        local w = myW -(row.img.width + 27)
        local w2
        if row.img.width == 0 then w2 = 8 else w2 = row.img.width + 12 end
        row.txtPreview = display.newText( row, dataA.shortTxt,w2,row.caption.height +10, w, 0,  native.systemFont, 10 )
        row.txtPreview:setTextColor( color )
        row:insert( row.txtPreview )
        row.txtPreview:setReferencePoint( display.TopLeftReferencePoint )
    end
    local list

    local function onRowTouch( event )
        local row = event.row
        local background = event.background
        print("onRowTouch(): list2Show_i[event.row.index].id " .. list2Show_i[event.row.index].id )
        --        local dataA = list2Show[event.id]
        local dataA = list2Show[list2Show_i[event.row.index].id]


        if event.phase == "press" then
            background:setFillColor( 0, 110, 233, 255 )

        elseif event.phase == "release" or event.phase == "tap" then
            --Update the item selected text
            itemSelected.text =  dataA.txt
            itemHeader.text  = dataA.caption
            itemHeader.y  = 80


            itemSelected.y = itemSelected.contentHeight * 0.5 + itemHeader.contentHeight  + 80
            transition.to( list, { x = - list.contentWidth, time = 400, transition = easing.outExpo } )
            transition.to( itemSelected, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
            transition.to( itemHeader, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )

            currentScreen = "OneItem"
            print( "Tapped and/or Released row: " .. row.index )
            print("_W", _W)
            print("list.x", list.x)
            row.reRender = true
        end
    end

    if iPhone5 then
        list = widget.newTableView{
            width = 320,
            height = 523,
            hideBackground = true,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch,
            maskFile = "images2/mask-320x523.png"
        }
    else
        list = widget.newTableView{
            width = 320,
            height = 435,
            hideBackground = true,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch,
            maskFile = "images2/mask-320x435.png"
        }
    end
    list.y = mainListOffset

    local count = 1
    for k,v in pairs(list2Show) do
        list2Show_i[count] = v
        print("count = " .. count, "ID  =  " .. k)
        list:insertRow{
            id = k,
            rowHeight  = rowHeight,
            rowColor = { 255, 255, 255, 0 }
        }
        count = count + 1
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
        defaultFile = "images2/back.png",
        overFile = "images2/back.png",
        width = 60, height = 44,
        left = 0,
        top = 0,
        onRelease = onBackRelease
    }
    --Insert widgets/images into a group
    localGroup:insert( list )
    localGroup:insert( backButton )
    return localGroup;
end

