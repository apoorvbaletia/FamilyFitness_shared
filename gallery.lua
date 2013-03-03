module(..., package.seeall)
local widget = require("widget")
local list2Show = {}
local dbFilename = "db.sqlite"
local directorParams2 = {}

local imgHeight = 90
local imgWidth = 90
local rowHeight = 120
local strokeWidth = 2
local currentPic
local touchedImageID
local go2BigPicture
local json = require "json"



function new(directorParams)
    local _H = display.contentHeight;
    local _W = display.contentWidth;
    local bigPicture
    local currentScreen = "ItemList"
    directorParams2 = directorParams
    local iPhone5;
    local phoneDiff;
    if _H == 480 then iPhone5 = false else iPhone5 = true end

    ------------background
    local widgetGroup = display.newGroup();
    ----background
    local bg = display.newImageRect ("images2/blank_bg.jpg", _W, 568);
    bg:setReferencePoint( display.TopLeftReferencePoint )
    bg.x, bg.y = 0,0;
    widgetGroup:insert(bg);
    -----Header text
    local screenHeader = display.newText("Фотографии", 0, 0, native.systemFontBold, 20)
    screenHeader:setReferencePoint( display.CenterReferencePoint )
    screenHeader.x, screenHeader.y = _W/2 , 21;
    widgetGroup:insert(screenHeader);
    -----

    local itemHeader = display.newText( "lotsOfText", 0, 0, native.systemFontBold, 20   )
    itemHeader:setReferencePoint( display.CenterReferencePoint )
    itemHeader.x = _W+_W/2
    itemHeader.y = 60
    widgetGroup:insert( itemHeader )

    --Forward reference for our back button
    local backButton
    --Create Table view
    local list
    local function onTableTouch( event )

        print ("onTableTouch ID =" .. touchedImageID)
        print ("onTableTouch event.name =" .. event.name)
        go2BigPicture = false
        return true
    end
    if iPhone5 then
        list = widget.newTableView{
            width = 320,
            height = 523,
            listener = onTableTouch,
            hideBackground = true,
            maskFile = "images2/mask-320x523.png"
        }
    else
        list = widget.newTableView{
            width = 320,
            height = 435,
            hideBackground = true,
            listener = onTableTouch,
            maskFile = "images2/mask-320x435.png"
        }
    end
    list.y = 45

    local function showBigPicture(ID, direction)
        -- direction maybe "fromLeft" and "fromRight"
        itemHeader.text  = list2Show[ID].name

        if bigPicture ~= nil then
            bigPicture:removeSelf()
        end
        ----------Big picture
        currentPic = ID;
        local picPath = directorParams2.tableName .. "/" ..  list2Show[ID].image;
        bigPicture = display.newImageRect (picPath, system.DocumentsDirectory, 310, 310);
        bigPicture:setReferencePoint( display.CenterReferencePoint )
        if direction == "fromRight" then bigPicture.x = display.contentCenterX + _W end
        if direction == "fromLef" then bigPicture.x = display.contentCenterX - _W end
        bigPicture.y = display.contentCenterY
        transition.to( bigPicture, { x = display.contentCenterX, time = 900, transition = easing.outExpo } )

        ---Picture touch handling
        function bigPicture:touch( event )
            if event.phase == "ended" then
                if (event.x < event.xStart) and (event.xStart - event.x > 10) then
                    if list2Show[ID].nextID ~= "NO" then showBigPicture(list2Show[ID].nextID, "fromRight") end
                elseif (((event.x > event.xStart) and (event.x - event.xStart > 10))) then
                    if list2Show[ID].prevID ~= "NO" then showBigPicture(list2Show[ID].prevID, "fromLeft") end
                elseif (event.x > _W/2) then
--                    print( "move next event2 " ..  list2Show[ID].nextID)
                    if list2Show[ID].nextID ~= "NO" then showBigPicture(list2Show[ID].nextID, "fromRight") end
                elseif (event.x < _W/2) then
--                    print( "move prev event2" ..  list2Show[ID].prevID )
                    if list2Show[ID].prevID ~= "NO" then showBigPicture(list2Show[ID].prevID, "fromLeft") end
                end
            end
            return true
        end
        bigPicture:addEventListener( "touch", bigPicture )
    end

local function go2BigPic()
    if go2BigPicture then
        print("go2BigPic(): here we go to the big picture " .. touchedImageID)
        showBigPicture(touchedImageID, "fromRight")
        transition.to( itemHeader, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
        transition.to( list, { x = -2 * _W, time = 400, transition = easing.outExpo } )
        currentScreen = "OneItem"
    else
        print("go2BigPic(): ignore icon touch")
    end
end

     local function onIconRelease(event)
         print ("onButtonRelease = " .. event.phase)
         if event.phase == "began" then
             touchedImageID =  event.target.id
             go2BigPicture = true
             timer.performWithDelay( 300, go2BigPic,1 )
             return false
         else
            return true
         end
    end
    ---------------------------------

    local function onRowTouch( event )

        print ("onRowTouch event.phase = " .. event.phase)
        return true
    end
    ---------------------------------
    local function onRowRender( event )
        local row = event.row
        local rowGroup = event.view
        local i
        local myW = rowGroup.contentWidth
        local myH = rowGroup.contentHeigth
        -----------Image
        row.img  = {}
        row.frame = {}
        print ("rendering a row " .. event.id , "Pics qty: " .. list2Show[event.id .. "_1"].picQty )
        local rowHeight = rowGroup.contentHeight;
        for i =1, list2Show[event.id .. "_1"].picQty do
            local imageName = list2Show[event.id .. "_" .. i].image
            if imageName and imageName ~= "" then
--                row.img[i] = widget.newButton{
--                    id = event.id .. "_" .. i,
--                    left = 0,
--                    top = 0,
--                    width = imgWidth, height = imgHeight,
--                    baseDir=system.DocumentsDirectory,
--                    default =  directorParams2.tableName .. "/" ..  imageName,
--                onRelease = onButtonRelease
--                }
                row.img[i] = display.newImageRect (directorParams2.tableName .. "/" ..  imageName,system.DocumentsDirectory, imgWidth, imgHeight);
                row.img[i].id = event.id .. "_" .. i
                row.img[i]:addEventListener( "touch", onIconRelease )

                row.img[i]:setReferencePoint( display.CenterReferencePoint )
                row.img[i].x = imgWidth/2 + 12 + (i-1)* (imgWidth + 10)
                row.img[i].y = rowHeight * 0.5

                 ----------------------
                row.frame[i] = display.newRect( 0, 0, imgWidth+strokeWidth*2, imgHeight+strokeWidth*2 )
                row.frame[i]:setFillColor(90, 180, 190)
                row.frame[i]:setReferencePoint( display.CenterReferencePoint )
                row.frame[i].x, row.frame[i].y = row.img[i].x, row.img[i].y
                rowGroup:insert( row.frame[i] )
                rowGroup:insert( row.img[i] )
            end
        end
    end

    --Handle the back button release event
    local function onBackRelease()
        --Transition in the list, transition out the item selected text and the back button
        local params = {}
        if currentScreen == "ItemList" then
            director:changeScene(params, "menu", "moveFromLeft");
        elseif currentScreen == "OneItem" then
            transition.to( list, { x = 0, time = 400, transition = easing.outExpo } )
            transition.to( bigPicture, { x = _W*2, time = 400, transition = easing.outExpo } )
            transition.to( itemHeader, { x = _W*2, time = 400, transition = easing.outExpo } )
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


    local sqlite3 =require("sqlite3")
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )
    local row2
    local i =1
    local counter = 1
    local prevID, nextID
    local SQL = "SELECT rowid, fName, fImageName, fType, fSortField FROM " .. directorParams2.tableName .. " ORDER BY fSortField ASC"
    print("Tablelist SQL: ", SQL)
    for row2 in db:nrows(SQL) do
        list2Show["ID_" .. counter .. "_" .. i] = {name = row2.fName, image = row2.fImageName }
        list2Show["ID_" .. counter .. "_" .. i].type = row2.fType

        ----Define pointer to the previous and the next picture
        --Pointer to the previous
        if counter == 1 and i == 1 then
            prevID = "NO"
        elseif counter == 1 and i > 1 then
            prevID = "ID_" .. counter .. "_" .. i-1
        elseif counter ~= 1 and i == 1 then
            prevID = "ID_" .. counter - 1 .. "_" .. 3
        elseif counter ~= 1 and i > 1 then
            prevID = "ID_" .. counter .. "_" .. i - 1
        end
        -- Pointer to the next
        print ("P1", prevID)
        print ("P2", "ID_" .. counter .. "_" .. i)
        list2Show["ID_" .. counter .. "_" .. i].prevID = prevID
        if prevID ~= "NO" then
                list2Show[prevID].nextID = "ID_" .. counter .. "_" .. i
        end  -- setup pointer of the prev image here
--        list2Show["ID_" .. counter .. "_" .. i].nextID = "NO"  -- in case this is a last image

        print("ID_" .. counter .. "_" .. i, list2Show["ID_" .. counter .. "_" .. i].image)

        if i == 3 then  -- if this is the las image in the line
            i = 1;
            list2Show["ID_" .. counter .. "_" .. 1].picQty = 3   -- # of pictures id contained within 1st picture element
            list:insertRow{
                id = "ID_" .. counter,
                height = rowHeight,
                rowColor = { 255, 255, 255, 0 },
                onRender = onRowRender
            }
            counter = counter + 1
        else
            i = i + 1
        end
    end

    if i ~=1 then --- it means that last row contains less than 3 pictures
        list2Show["ID_" .. counter .. "_" .. 1].picQty = i-1
        list2Show["ID_" .. counter .. "_" .. 1].picQty = i-1
        list:insertRow{
            id = "ID_" .. counter,
            height = rowHeight,
            rowColor = { 255, 255, 255, 0 },
            onRender = onRowRender,
--            onEvent=onRowTouch
                            listener = onRowTouch
        }
    end


    db:close()
    widgetGroup:insert( list )
    widgetGroup:insert( backButton )
    return widgetGroup;
end

