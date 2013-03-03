
module(..., package.seeall)
----------Modules
local widget = require "widget"
local dbFilename = "db.sqlite"
local mylib = require "mylib"
local json = require "json"
local dbsync2 = require "dbsync2"
---------- Predefined variables
local _H = display.contentHeight;
local _W = display.contentWidth;
local iPhone5;
local phoneDiff;
local updPopupHeader = "Внимание"
local updPopupBody = "Доступны обновления. Хотите обновить?"

function new(directorParams)
    print("directorParams = " .. json.encode(directorParams))
    local localGroup = display.newGroup();
    -- Check if this is iPhone5 or lower (Android to be added)
    -- resolution for iPhone5 320x568 for other iPhones 320x480
    if string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then iPhone5 = true else iPhone5 = false end
    ---=========== If this is a first run then we create a necessary folder structure and copy initial folders
    if (mylib.isFirstRun() == "Yes" ) then
        print("menu.lua: First Run!!!")
        mylib.setSetting("IsFirstRun", "No")
        mylib.createFoldersinDocs(dbsync2.tablesArray)
        mylib.copyFilesFromSrcDirectoryToDocuments()
    end
    ---=====================  Here we check if updates are available and if so, the ask user if he wants to make an update
    local function onComplete( event ) -- Update message box button handler
        if event.action  == "clicked" and event.index == 1 then -- If user want to perform upgrade now
                dbsync2.startSyncronization()
        end
    end
    -- directorParams.status = "Data updated" means that we came to the menu after an masterdata update
    if(directorParams.status == "Data updated") then
        print("menu.lua: update just happened")
        mylib.setSetting("UpdatesAvailable", "No")
    end
    -- directorParams.status == "ask4update" means that this is a first time user comes to menu
    if(mylib.getSetting("UpdatesAvailable") == "Yes" and directorParams.status == "ask4update") then
        local alert = native.showAlert( updPopupHeader, updPopupBody, { "Да, сейчас", "Позже" }, onComplete )
    end
---===================VISUAL PART
    --background
    local bgFileName;
    if iPhone5 then
        phoneDiff = 88; -- button Y coordinate adjustment
        bgFileName = "images/common/bg.png";
    else
        phoneDiff = 0;
        bgFileName = "images/common/bg.png";
    end
    -- put background picture
    local bgImage = display.newImageRect (bgFileName, _W, _H);
    bgImage:setReferencePoint( display.CenterReferencePoint )
    bgImage.x = display.contentCenterX
    bgImage.y = display.contentCenterY
    ------Logo
    local logoImage = display.newImage ("images/scr_main/logo.png");
    logoImage:setReferencePoint( display.TopCenterReferencePoint )
    logoImage.x = display.contentCenterX
    logoImage.y = 40

    ---------------------------------------
    local function onButtonRelease(event)
        local directorParams = {}
        local gotoScene = ""
        if event.target.id == "btnPhoto" then
            gotoScene = "gallery"
            directorParams.tableName = "tServices"
        elseif event.target.id == "btnServices" then
            gotoScene = "services"
            directorParams.tableName = "tServices"
        elseif event.target.id == "btnContacts" then
            gotoScene = "contacts"
            directorParams.nextScene = "contacts"
        elseif event.target.id == "btnNews" then
            directorParams.nextScene = "news"
            gotoScene = "news"
            directorParams.tableName = "tNews"
        elseif event.target.id == "btnSched" then
            gotoScene = "sched_day"
            directorParams.tableName = "tSchedule"
            directorParams.weekday = os.date("%A")
        elseif event.target.id == "btnTeam" then
            gotoScene = "team"
            directorParams.tableName = "tTeam"
        elseif event.target.id == "btnPhoto" then
            gotoScene = "gallery"
            directorParams.tableName = "tPictures"
        end
        director:changeScene (directorParams, gotoScene);
    end
    ---------------------------------------
    local buttons = {}
    local buttonsGroup = display.newGroup();
    ------
    buttons["btnNews"] = {}
    buttons["btnNews"].iconFile = "images/scr_main/main-news.png"
    buttons["btnNews"].text = "Новости"
    buttons["btnNews"].y = 0
    ------
    buttons["btnSched"] = {}
    buttons["btnSched"].iconFile = "images/scr_main/main-schedule.png"
    buttons["btnSched"].text = "Расписание"
    buttons["btnSched"].y = 50
    ------
    buttons["btnPhoto"] = {}
    buttons["btnPhoto"].iconFile = "images/scr_main/main-photo.png"
    buttons["btnPhoto"].text = "Фотографии"
    buttons["btnPhoto"].y = 100
    ------
    buttons["btnServices"] = {}
    buttons["btnServices"].iconFile = "images/scr_main/main-services.png"
    buttons["btnServices"].text = "Услуги"
    buttons["btnServices"].y = 150
    ------
    buttons["btnContacts"] = {}
    buttons["btnContacts"].iconFile = "images/scr_main/main-contacts.png"
    buttons["btnContacts"].text = "Контакты"
    buttons["btnContacts"].y = 200
    ------
    for k,v in pairs(buttons) do
        print("making button " .. k)
        ----------
        buttons[k].btnObject = widget.newButton{
            id = k,
            left = 0,
            top = v.y,
            defaultFile = "images/common/bg-row-light.png",
            overFile = "images/common/bg-row-dark.png",
            onRelease = onButtonRelease,
        }
        buttonsGroup:insert(buttons[k].btnObject);
        ---------
        buttons[k].iconObject = display.newImage(v.iconFile, system.ResourceDirectory, 10, v.y)
        buttons[k].iconObject:setReferencePoint( display.CenterLeftReferencePoint )
        buttons[k].iconObject.x, buttons[k].iconObject.y = 20 , v.y + 25
        buttonsGroup:insert(buttons[k].iconObject);
        ---------
        buttons[k].textObject = display.newText( buttonsGroup, v.text, 0, 0, "Ubuntu", 20 )
        buttons[k].textObject:setTextColor( 89, 44, 13 )
        buttons[k].textObject:setReferencePoint( display.CenterLeftReferencePoint )
        buttons[k].textObject.x, buttons[k].textObject.y = 70 , v.y + 25
        buttonsGroup:insert(buttons[k].textObject);
        ---------
        buttons[k].arrowObject = display.newImage("images/common/arrow.png", system.ResourceDirectory, 0, 0)
        buttons[k].arrowObject:setReferencePoint( display.CenterLeftReferencePoint )
        buttons[k].arrowObject.x, buttons[k].arrowObject.y = 300 , v.y + 25
        buttonsGroup:insert(buttons[k].arrowObject);
    end

    buttonsGroup.x = 0
    buttonsGroup.y = 230 + phoneDiff


--    local sysFonts = native.getFontNames()
--    for k,v in pairs(sysFonts) do
--
--       if string.find(v,"Ubuntu") then  print(v) end
----       print(string.sub(v,1,1))
--    end
    localGroup:insert(bgImage);
    localGroup:insert(buttonsGroup);
    return localGroup;
end




