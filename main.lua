local launchArgs = ...
----------Modules
local director = require "director"
local json = require "json"
local dbsync2 = require "dbsync2"
local mylib = require "mylib"
---------- Predefined variables
local dbFilename = "db.sqlite"
local tableNames = {"tSchedule", "tNews", "tTeam", "tServices" }
local updateTriggerMessage = "Обновления в содержании приложения!"  -- if we got this message then we setup an update flag
local _H = display.contentHeight;
local _W = display.contentWidth;
-------------------------
local function main()
    -----Notification listener registration
    local function onNotification( event )
        local token
        print("main.lua: enter onNotification()")
        print("launchArgs = " .. json.encode( launchArgs.notification ))
        print("Notification type = " .. event.type)
        if event.type == "remoteRegistration" then
            token = mylib.getSetting("token")
            print("token = " .. event.token)
            if token ~= event.token then   -- if we have received a new token
                mylib.setSetting("token", event.token)
                mylib.writeToParse(event.token)
            end
        elseif event.type == "remote" then
            if event.alert == updateTriggerMessage then  -- if we got a specific message the we setup an update flag
                mylib.setSetting("UpdatesAvailable", "Yes")
                ----- Go to the menu screen
                local params = {}
                params.status = "ask4update"
                print("main.lua: Exit#2 onNotification()")
                director:changeScene(params, "menu");
                return true;
            else
                native.showAlert( "Сообщение", event.alert, { "OK" } )
            end
        end
        print("main.lua: Exit#1 onNotification()")
    end
    Runtime:addEventListener( "notification", onNotification )

    ------- process launchArgs (in case push is received while offline)
    if launchArgs then
        print( "main.lua: launchArgs process ENTER")
        print( "launchArgs = " .. json.encode( launchArgs ))
        -----------------------------
        if launchArgs.notification then
            if launchArgs.notification.alert then
                if launchArgs.notification.alert == updateTriggerMessage then
                    mylib.setSetting("UpdatesAvailable", "Yes")
                end
            else
                print("launchArgs.notification.alert is not defined ")
            end
        else
            print("launchArgs.notification not defined ")
        end
        print( "main.lua: launchArgs process exit#1")
    end
    -------- Goto menu screen
	local mainGroup = display.newGroup();
    mainGroup:insert(director.directorView);
    local params = {}
    params.status = "ask4update"
    director:changeScene(params, "menu");
    return true;
end


main();
--> Starts our app


    
