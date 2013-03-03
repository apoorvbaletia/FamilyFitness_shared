module(..., package.seeall)
local widget = require("widget")
local list2Show = {}
local dbFilename = "db.sqlite"
local directorParams2 = {}
local photoSize = 100
local rowHeight = 140


function new(directorParams)

    local _H = display.contentHeight;
    local _W = display.contentWidth;
    local currentScreen = "ItemList"
    directorParams2 = directorParams
    local iPhone5;
    local phoneDiff;
    if _H == 480 then iPhone5 = false else iPhone5 = true end

    local widgetGroup = display.newGroup();
    ----background
    local bg = display.newImageRect ("images2/blank_bg.jpg", _W, 568);
    bg:setReferencePoint( display.TopLeftReferencePoint )
    bg.x, bg.y = 0,0;
    widgetGroup:insert(bg);
    -----Header text
    local screenHeader = display.newText("Команда", 0, 0, native.systemFontBold, 20)
    screenHeader:setReferencePoint( display.CenterReferencePoint )
    screenHeader.x, screenHeader.y = _W/2 , 21;
    widgetGroup:insert(screenHeader);
    -----

    local itemHeader = display.newText( "Header", 0, 0, display.contentWidth, 0, native.systemFontBold, 16)
    itemHeader.x = display.contentWidth + 0.5 * display.contentWidth
    widgetGroup:insert( itemHeader )

    local itemSelected = display.newText( "Text", 0, 0, display.contentWidth - 30, 0, native.systemFont, 12)
    itemSelected.x = display.contentWidth + itemSelected.contentWidth * 0.5
    itemSelected.y = itemSelected.contentHeight * 0.5
    widgetGroup:insert( itemSelected )

    --Forward reference for our back button
    local backButton
    --Create Table view
    local list
    if iPhone5 then
        list = widget.newTableView{
            width = 320,
            height = 523,
            hideBackground = true,
            maskFile = "images2/mask-320x523.png"
        }
    else
        list = widget.newTableView{
            width = 320,
            height = 435,
            hideBackground = true,
            maskFile = "images2/mask-320x435.png"
        }
    end
    list.y = 45;

    local function onRowRender( event )
        local row = event.row
        local rowGroup = event.view
        local label = "List item "
        local color = 255
        local path = system.pathForFile( "", system.DocumentsDirectory )

        local myW = rowGroup.contentWidth
        local myH = rowGroup.contentHeigth
        ------------------photo
        local imageName = list2Show[event.id].image
        if imageName and imageName ~= "" then
            row.img = display.newImageRect ( directorParams2.tableName .. "/" ..  imageName, system.DocumentsDirectory, photoSize,  photoSize)
            row.img.x = photoSize/2 + 5
            row.img.y = rowGroup.contentHeight * 0.5
            rowGroup:insert( row.img )
        else
            row.img = {width = 0}
        end
        ------------------bubble
        row.bubble = display.newImageRect ( "images2/scr4/s4_description.png", 208,  126)
        row.bubble.x = photoSize + 111
        row.bubble.y = rowGroup.contentHeight * 0.5
        rowGroup:insert( row.bubble )

        ------------------text
        local txt_x, txt_y = row.bubble.x + 14 , row.bubble.y
        row.shortDescr = display.newText( rowGroup, list2Show[event.id].shortTxt,0,0, 150, 0,  native.systemFont, 12 )
        row.shortDescr:setReferencePoint( display.CenterReferencePoint )
        row.shortDescr.x, row.shortDescr.y = txt_x, txt_y
        row.shortDescr:setTextColor( color )
        rowGroup:insert( row.shortDescr )
    end
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
        default = "images2/back.png",
        width = 60, height = 44,
        left = 0,
        top = 0,
        onRelease = onBackRelease
    }

    --Handle row touch events
    local function onRowTouch( event )
        local row = event.row
        local background = event.background

if event.phase == "release" or event.phase == "tap" then
            itemSelected.text =  list2Show[event.id].txt
            itemHeader.text  = list2Show[event.id].caption
            itemHeader.y = 80

            itemSelected.y = itemSelected.contentHeight * 0.5 + itemHeader.contentHeight  + 80-- display.contentCenterY
            transition.to( list, { x = - list.contentWidth, time = 400, transition = easing.outExpo } )
            transition.to( itemSelected, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
            transition.to( itemHeader, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )

            currentScreen = "OneItem"
            background:setFillColor( 0, 110, 233, 255 )
            row.reRender = true
        end
    end
    --Insert elements into list
    local sqlite3 =require("sqlite3")
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )
    local row2
    local SQL = "SELECT rowid, fName, fDirections, fDescription, fImageName from " .. directorParams2.tableName --.. " ORDER BY fDate DESC"
    print("Tablelist SQL: ", SQL)
    for row2 in db:nrows(SQL) do
        list2Show["ID_" .. row2.rowid] = {caption = row2.fName, image = row2.fImageName, txt = row2.fDescription }
        list2Show["ID_" .. row2.rowid].shortTxt = row2.fDirections
        list:insertRow{
            id = "ID_" .. row2.rowid,
            height = rowHeight,
            rowColor = { 255, 255, 255, 0 },
            onRender = onRowRender,
            listener = onRowTouch
        }
    end
    db:close()
    --Insert widgets/images into a group
    widgetGroup:insert( list )
    widgetGroup:insert( backButton )
    return widgetGroup;
end

