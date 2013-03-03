module(..., package.seeall)
local widget = require("widget")
local mylib = require "mylib"
local list2Show = {}
local imgHeight = 70
local imgWidth = 70
local statusbagHeight = 10


function new()
    local _H = display.contentHeight;
    local _W = display.contentWidth;
    local currentScreen = "ItemList"
--    directorParams2 = directorParams
    local club
    club  = mylib.GetCurrentClubInfo()
    ----background
    local widgetGroup = display.newGroup();

    ----background
    local bg = display.newImageRect ("images2/blank_bg.jpg", _W, 568);
    bg:setReferencePoint( display.TopLeftReferencePoint )
    bg.x, bg.y = 0,0;
    widgetGroup:insert(bg);

    local function onPickRelease(event)
        local columnData = {}
        columnData[1] = { "На кондратьевском", "На Типанова"}
        local picker = widget.newPickerWheel
            {
                top = 480,
                font = native.systemFontBold,
                columns = columnData,
            }
        transition.to( picker, { time = 350, y = 258, transition = easing.inOutExpo } )
    end
    local pickButton = widget.newButton
        {
            label = "Выбор клуба",
            onRelease = onPickRelease
        }
    pickButton:setReferencePoint( display.CenterReferencePoint )
    pickButton.x, pickButton.y = _W/2,460;
    widgetGroup:insert(pickButton);


    -----Header text
    local screenHeader = display.newText("Контакты", 0, 0, native.systemFontBold, 20)
    screenHeader:setReferencePoint( display.CenterReferencePoint )
    screenHeader.x, screenHeader.y = _W/2 , 21;
    widgetGroup:insert(screenHeader);
    ------Map

    local myMap
    myMap = native.newMapView( display.contentCenterX -155, 3*_H/5-110, 310, 223 )
    myMap.mapType = "standard"
    myMap.isZoomEnabled = true
    myMap.isScrollEnabled = true
    myMap:setRegion( club.lat, club.long, 0.005, 0.03 )
    myMap:addMarker( club.lat, club.long, { title=club.name, title=club.address } )
    widgetGroup:insert(myMap);
    --------header text
    local txtHeader = display.newText( "Клуб " .. club.name, 0, 0, display.contentWidth, 0, native.systemFontBold, 24)
    txtHeader:setReferencePoint( display.CenterReferencePoint )
    txtHeader.x = display.contentCenterX
    txtHeader.y = 90

    widgetGroup:insert( txtHeader )
    --------body text
    local mainText = {"Телефон: +7 (495) 124-12-53", "Адрес: " .. club.address }
    local mainTextObj = {}
    local i
    local txtY = 105
    for i = 1, #mainText do
        mainTextObj[i] = display.newText( mainText[i], 0, 0, native.systemFont, 12)
        mainTextObj[i]:setReferencePoint( display.TopLeftReferencePoint )

        mainTextObj[i].x = txtHeader.x -txtHeader.contentWidth/2
        mainTextObj[i].y = txtY
        widgetGroup:insert( mainTextObj[i] )
        txtY = txtY + mainTextObj[i].contentHeight + 2
    end
    --------back button
    local function onBackRelease()
        --Transition in the list, transition out the item selected text and the back button
        local params = {}
        director:changeScene(params, "menu", "moveFromLeft");
    end
    --Create the back button
    local backButton = widget.newButton{
        default = "images2/back.png",
        width = 60, height = 44,
        left = 0,
        top = 0,
        onRelease = onBackRelease
    }
    widgetGroup:insert( backButton )
    return widgetGroup
end

