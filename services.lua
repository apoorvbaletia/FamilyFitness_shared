module(..., package.seeall)
local widget = require("widget")
local list2Show = {}
local dbFilename = "db.sqlite"
local directorParams2 = {}

local imgHeight = 70
local imgWidth = 70
local rowHeight = 81



function new(directorParams)

    local _H = display.contentHeight;
    local _W = display.contentWidth;
    local bigPicture
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
    local screenHeader = display.newText("Услуги", 0, 0, native.systemFontBold, 20)
    screenHeader:setReferencePoint( display.CenterReferencePoint )
    screenHeader.x, screenHeader.y = _W/2 , 21;
    widgetGroup:insert(screenHeader);

    local itemHeader = display.newText( "lotsOfText", 0, 0, 0, 0, "Helvetica", 20)
    itemHeader.x = display.contentWidth + 0.5 * display.contentWidth
    itemHeader.y = 65
    widgetGroup:insert( itemHeader )

    local itemSelected = display.newText( "lotsOfText", 0, 0, _W-50, 0, "Helvetica", 12)
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
    list.y = 45

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

        row.background = display.newImageRect ("images2/scr6/s6_services_line.png", 0, 0 );
        rowGroup:insert( row.background )
        -----------Image
        local imageName = list2Show[event.id].image
        if imageName and imageName ~= "" then
            row.img = display.newImageRect ( directorParams2.tableName .. "/" ..  imageName, system.DocumentsDirectory, imgHeight,  imgWidth)
            row.img.x = imgWidth/2 + 2
            row.img.y = rowGroup.contentHeight * 0.5
            rowGroup:insert( row.img )
        else
            row.img = {width = 0}
        end
    -------------Caption
    row.caption = display.newRetinaText( rowGroup,  list2Show[event.id].caption, 0, 0, native.systemFontBold, 12)
    row.caption:setTextColor( color )
    row.caption:setReferencePoint( display.CenterLeftReferencePoint )
    row.caption.x, row.caption.y = row.img.width + 8, row.caption.height * 0.5
    rowGroup:insert( row.caption )

    ----------------Text preview
    local w = myW -(row.img.width + 28)
    local w2
    if row.img.width == 0 then w2 = 8 else w2 = row.img.width + 12 end

    row.txtPreview = display.newText( rowGroup, list2Show[event.id].shortTxt,w2,row.caption.height + 5 , w, 0,  native.systemFont, 12 )
    row.txtPreview:setTextColor( color )
    rowGroup:insert( row.txtPreview )
    row.txtPreview:setReferencePoint( display.TopLeftReferencePoint )

    ----------------Arrow
    row.arrow = display.newImage( "images2/scr3/s3_flash.png", false )
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
            transition.to( list, { x = 0, time = 400, transition = easing.outExpo } )
            transition.to( itemSelected, { x = display.contentWidth + itemSelected.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
            transition.to( itemHeader, { x = display.contentWidth + itemHeader.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
            currentScreen = "ItemList"
            transition.to( bigPicture, { x = 2*_W, time = 400, transition = easing.outExpo } )

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
    --Insert widgets/images into a group
    widgetGroup:insert( list )
    widgetGroup:insert( backButton )
    return widgetGroup;
end

