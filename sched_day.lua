module(..., package.seeall)
local widget = require("widget")
local mylib = require "mylib"

----Parameters
local dbFilename = "db.sqlite"
local directorParams2 = {}
local list2Show = {}
local list2Show_i = {}
local _H = display.contentHeight;
local _W = display.contentWidth;
local currentScreen = "ItemList"
--- Visual  parameters
local weekdays = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" }
local weekdaysRU = {"Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс" }
local weekdayPointerX = {20, 68, 115, 162, 209, 255, 301 }

local weekdayPointerY = 95
local contentAreaYOffset = 115
local rowHeight = 80
local touchInProcess = false

local pointerArea = 48
local pointerAreaY = 50
local vertSplit = 75


function new(directorParams)
    directorParams2 = directorParams
    local iPhone5;
    local phoneDiff;
    local widgetGroup = display.newGroup();

    -- Check if this is iPhone5 or lower (Android to be added)
    -- resolution for iPhone5 320x568 for other iPhones 320x480
    if string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then iPhone5 = true else iPhone5 = false end


    ---------------------background
--    local bg = display.newImageRect ("images2/scr7/s7_bg.jpg", _W, 568);
    local bg = display.newRect (0,0, _W, _H);
    bg:setReferencePoint( display.TopLeftReferencePoint )
    bg.x, bg.y = 0,0;
    bg:setFillColor(209, 209, 209)
    widgetGroup:insert(bg);

    --------TopBar
    local topBar = display.newImageRect ("images/common/top-bar.png", 40, 40);

    --------week day pointer
    local weekdayPointer = display.newImageRect ("images2/scr7/s7_navigator.png", 320, 49);
    weekdayPointer.x = weekdayPointerX[table.indexOf( weekdays, directorParams2.weekday)]
    weekdayPointer.y = weekdayPointerY
    widgetGroup:insert(weekdayPointer);
    print ("==================check3")

    ------Item header
    local itemHeader = display.newText( "Header", 0, 0, _W, 0, native.systemFont, 16)
    itemHeader.x = display.contentWidth + 0.5 * display.contentWidth
    itemHeader.y = 80
    ------Item selected
    local itemSelected = display.newText( "Text", 0, 0, _W - 15, 0, native.systemFont, 12)
    itemSelected.x = display.contentWidth + itemSelected.contentWidth * 0.5
    itemSelected.y = itemSelected.contentHeight * 0.5

    -------Create the back button
    local function onBackRelease()
       -- local params = {direction = directorParams.direction}
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

    local backButton = widget.newButton{
        defaultFile = "images2/back.png",
        overFile = "images2/back.png",
        width = 60, height = 44,
        top = 0,
        left = 0,
        onRelease = onBackRelease
    }

    local function readScheduleData()
        local sqlite3 =require("sqlite3")
        local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
        local db = sqlite3.open( path )
        local row2
        local startTimeBuf  = 0
        local arr = {}
    --    prepare SQL Query
        local SELECT = "SELECT s.fTime, s.fTrainer, t.fRGB, s.fWeekday, s.fDurationH, s.fDurationM, "
        SELECT = SELECT .."s.fRoom, s.rowid, t.fName, t.fDescr, t.fShortDescr, t.fImageName "
        local FROM = "FROM `tSchedule` as s INNER JOIN tTrainings as t ON s.fID = t.fID "
        local WHERE = "WHERE s.fWeekday = '" .. directorParams2.weekday .. "' "
        local ORDER = "ORDER BY s.fTime ASC"
        local SQL = SELECT .. FROM .. WHERE .. ORDER
        print("sched_day.lua readScheduleData(): ", SQL)

        for row2 in db:nrows(SQL) do
            print ("ID_" .. row2.rowid)
            arr = mylib.split(",", row2.fRGB)
            list2Show["ID_" .. row2.rowid] = {}
            list2Show["ID_" .. row2.rowid].trainer = row2.fTrainer
            list2Show["ID_" .. row2.rowid].R = arr[1]
            list2Show["ID_" .. row2.rowid].G = arr[2]
            list2Show["ID_" .. row2.rowid].B = arr[3]
            list2Show["ID_" .. row2.rowid].weekday = row2.fWeekday
            list2Show["ID_" .. row2.rowid].durationh = row2.fDurationH
            list2Show["ID_" .. row2.rowid].durationm = row2.fDurationM
            list2Show["ID_" .. row2.rowid].room = row2.fRoom
            list2Show["ID_" .. row2.rowid].caption = row2.fName
            list2Show["ID_" .. row2.rowid].shrtdescr = row2.fShortDescr
            list2Show["ID_" .. row2.rowid].description = row2.fDescr
            list2Show["ID_" .. row2.rowid].image = row2.fImageName
            list2Show["ID_" .. row2.rowid].trainer = row2.fTrainer
            list2Show["ID_" .. row2.rowid].time = row2.fTime
            list2Show["ID_" .. row2.rowid].id = "ID_" .. row2.rowid
            if startTimeBuf == list2Show["ID_" .. row2.rowid].time then
                list2Show["ID_" .. row2.rowid].time = nil
            else
                startTimeBuf = list2Show["ID_" .. row2.rowid].time
            end
        end
        db:close()
    end
    readScheduleData()
---================
    local function onRowRender( event )
        local row = event.row
        local color = 255
        local path = system.pathForFile( "", system.DocumentsDirectory )
        print("event.row.index " .. event.row.index )
        print("list2Show_i[event.row.index].id " .. list2Show_i[event.row.index].id )
--        local dataA = list2Show[event.id]
        local dataA = list2Show[list2Show_i[event.row.index].id]
        local m = ""
        local timeStr = ""
        local txt
        -------Backgroundrect
        local _width = _W - vertSplit - 5
        local _height= rowHeight - 20
        row.bgRect = display.newRoundedRect(0, 0, _width, _height, 6)
        row.bgRect:setReferencePoint( display.CenterReferencePoint )
        row.bgRect.x =  vertSplit  + _width/2 - 7
        row.bgRect.y =  rowHeight/2
        row.bgRect.alpha = 0.5
        row.bgRect:setFillColor(dataA.R, dataA.G, dataA.B)
        row:insert( row.bgRect )
        -----caption
        row.caption = display.newRetinaText( row,  dataA.caption, 0, 0, native.systemFont, 16 )
        row.caption:setTextColor( color )
        row.caption:setReferencePoint( display.CenterLeftReferencePoint )
        row.caption.x, row.caption.y = vertSplit, rowHeight/2 - 15
        -----details
        if dataA.durationm < 10 then m=":0" else m=":" end
        txt = dataA.durationh .. m .. dataA.durationm
        txt = "Продолжительность " .. txt .. ", " .. dataA.room
        row.details = display.newText( row, txt , 0, 0, _width  - 8, 0, native.systemFont, 12 )
        row.details:setTextColor( color )
        row.details:setReferencePoint( display.CenterLeftReferencePoint )
        row.details.x, row.details.y = vertSplit, rowHeight/2 - 15 + row.caption.contentHeight
        -----time
        if dataA.time then
            if dataA.time%1*60 < 10 then m=":0" else m=":" end
            timeStr = (dataA.time - dataA.time%1) .. m .. (dataA.time%1)*60
            row.time = display.newRetinaText(  row, timeStr, 0, 0, native.systemFont, 16 )
            row.time:setTextColor( color )
            row.time:setReferencePoint( display.CenterLeftReferencePoint )
            row.time.x, row.time.y = 5, rowHeight/2
        end
    end
---================
    local function onRowRender2( event )
        local phase = event.phase
        local row = event.row

        local rowTitle = display.newText( row, "Row x" , 0, 0, nil, 14 )
        rowTitle.x = row.x - ( row.contentWidth * 0.5 ) + ( rowTitle.contentWidth * 0.5 )
        rowTitle.y = row.contentHeight * 0.5
        rowTitle:setTextColor( 0, 0, 0 )
    end

    local list, list_sm

    if iPhone5 then
        list = widget.newTableView{
            width = 320,
            height = 453,
            hideBackground = true,
            maskFile = "images2/mask-320x453.png"
        }
    else
        list = widget.newTableView{
            width = 320,
            height = 365,
            hideBackground = true,
            onRowRender = onRowRender,
            maskFile = "images2/mask-320x365.png"
        }

        list_sm = widget.newTableView{
            width = 320,
            height = 365,
            hideBackground = true,
            onRowRender = onRowRender2,
            maskFile = "images2/mask-320x365.png"
        }

    end
    list.y = contentAreaYOffset

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
--    =========================================
    list_sm.y = contentAreaYOffset + 150

    for i = 1, 20  do
        list_sm:insertRow{
            rowHeight  = rowHeight,
            rowColor = { 255, 255, 255, 0 }
        }
    end


    --    ================== ======================
    local function ontouch(event)
        if event.phase == "began" then
            touchInProcess = true
        elseif event.phase == "moved"  and false then
            local dx = math.abs( event.x - event.xStart )
            local dy = math.abs( event.y - event.yStart )
            local i
            local animation
            local params = {}
            params = directorParams2
            if dx < 10 and dy > 5 then
            elseif dx > 20 and dy < 15 then
                touchInProcess = false
                if event.xStart > event.x then      -- if go right
                    i = table.indexOf( weekdays, directorParams2.weekday)
                    if i == 7 then i=1 else i=i+1 end
                    animation = "moveFromRight"
                elseif event.xStart < event.x then
                    i = table.indexOf( weekdays, directorParams2.weekday)
                    if i == 1 then i=7 else i=i-1 end
                    animation = "moveFromLeft"
                end
                params.weekday =  weekdays[i]
                print(weekdays[i],params.weekday)
                director:changeScene(params, "sched_day");
            end
        elseif event.phase == "ended" then
            local params = {}
            params = directorParams2
            local i
            local animation


            if touchInProcess  and math.abs(weekdayPointerY - event.yStart) < pointerAreaY then
--                touchInProcess = false

                for i = 1, 7 do
                    if math.abs(weekdayPointerX[i]-event.xStart) < pointerArea then
                        params.weekday =  weekdays[i]
                        if table.indexOf( weekdays, directorParams2.weekday) > i  then
                            animation = "moveFromLeft"
                        else
                            animation = "moveFromRigth"
                        end
                        director:changeScene(params, "sched_day");
                    end
                end

            end
        end

        return true
    end
--    bg:addEventListener( "touch", ontouch )

    --Handle row touch events
    local function onRowTouch( event )
--        local row = event.row
--        local background = event.background

        print("onRowTouch() event.phase = " .. event.phase)
        return false
    end
    --Insert elements into list  in list2Show


    ------

    --Insert widgets/images into a group
    widgetGroup:insert( itemHeader )
    widgetGroup:insert( itemSelected )
    widgetGroup:insert( list )
--    widgetGroup:insert( listSuppl )

    widgetGroup:insert( backButton )
    return widgetGroup;
end

