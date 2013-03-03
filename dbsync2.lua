module(..., package.seeall)


local dbSync = {} -- global storage

local json = require("json")
local url = require("socket.url")
local baseUrl = "https://api.parse.com/1/classes/"
local headers = {}
headers["X-Parse-Application-Id"] = "MyyVvgEqIDrucG1bvJpb6EbyqALo25nc4I6ShCaV" -- your Application-Id
headers["X-Parse-REST-API-Key"] = "6Xn0iym4WCwu5QL4gBLbEHVi30Td9sfNpjtioRuI" -- your REST-API-Key
headers["X-Parse-Session-Token"] = nil -- session token for altering User object
headers["Content-Type"] = "application/x-www-form-urlencoded"
---Variables are used globally across the file
local entity = "FamilyFitness" --ID of fitness club
local tableWithVersions = "tVersions"
local nextScene
local dbFilename = "db.sqlite"
local StatusScreenText
local replicaVersion, masterVersion
local fieldsList  = {}
local directorParams2 = {}
local notSync = false
local i = 1
syncInProcess = false
tablesArray = {"tTrainings", "tSchedule", "tNews", "tTeam", "tServices", "tPictures", "tClubs", "tDictionary" }
globalTableName = ""


--- entry point for syncroniztion
  function startSyncronization()
      print("Point9")
      director:changeScene("updating");
      syncTables(true, "ok")
  end


local function syncTable(tableName)
    local _H = display.contentHeight;
    local _W = display.contentWidth;
    print("Start updating table ", tableName)

    globalTableName = tableName
    initFieldsList(tableName);

    local criteria = {}
    criteria.fTableName = tableName
    criteria.fEntity = entity

    local params = {}
    params.headers = headers
    params.body = nil

    -- Request Master Version from PARSE
    local sqlString = "?where=" .. url.escape(json.encode(criteria))

    if notSync then
        local syncResult = {}
        syncResult.message = "!!We do not check DB now!!!"
        syncResult.status = "err"
        syncProcessIsOver(syncResult)
    else
        print("syncTable(): request to parse " .. baseUrl .. tableWithVersions .. sqlString)
        network.request(baseUrl .. tableWithVersions .. sqlString, "GET", networkListener2, params)
    end
end
function syncTables (firstCall, status)
    local retValue
    local directorParams = {}
    if firstCall then
        if syncInProcess then
            retValue =  "another call" --another update is already in process
            return retValue
        else
            syncInProcess = true
        end
    end

    if i > #tablesArray then
        i = 1
        retValue = "OK"
        if status == "ok" then
        native.showAlert( "Статус", "Данные обновлены", { "OK" } )
        print("Data is updated!")
        directorParams.status = "Data updated"
        else
            native.showAlert( "Статус", "Не удалось подключиться к интернету", { "OK" } )
            print("No inet access!")
            directorParams.status = "No access"
        end
        syncInProcess = false
        director:changeScene(directorParams, "menu");
        return retValue
    else
        print( "Call update of " .. tablesArray[i] )
        syncTable(tablesArray[i])
        i = i+1
    end
end

function networkListener2(event)
    local response2
    local syncResult = {}

    if (event.isError) then
        print("Network error!")
        syncResult.message = "No network connection!"
        syncResult.status = "err"
        syncProcessIsOver(syncResult)

    else
        response2 = json.decode(event.response)
        if response2["error"] then
            print("Connection error code:", response2["code"])
            syncResult.message = "Error while connection!"
            syncResult.status = "err"
            syncProcessIsOver(syncResult)
        else

            print("Status code: ", event.status)
            masterVersion = response2.results[1].fVer
            replicaVersion = getReplicaVersion()
            print("compare ", masterVersion, " vs. ", replicaVersion, " for ", globalTableName)
            if masterVersion == replicaVersion then
                syncResult.message = "Data is up to date"
                syncResult.status = "ok"
                syncProcessIsOver(syncResult)
            elseif masterVersion < replicaVersion then
                syncResult.message = "Replica version is greater than Master version"
                syncResult.status = "err"
                syncProcessIsOver(syncResult)
            else
                -- replica ver is lower than master ver ==> we make sync

                local criteria = {}
                criteria.fEntity = entity

                local params = {}
                params.headers = headers
                params.body = nil
                local sqlString = "?where=" .. url.escape(json.encode(criteria))

                local params2 = {masterVersion = masterVersion}
                print("Parse 2nd request: " .. baseUrl .. globalTableName .. sqlString)

                network.request(baseUrl .. globalTableName .. sqlString, "GET", networkListener3, params)

            end
        end
    end
end

function networkListener3(event, params)
    local response3
    local syncResult = {}

    if (event.isError) then
        print("2nd Network error!")
        syncResult.message = "No network connection!"
        syncResult.status = "err"
        syncProcessIsOver(syncResult)

    else
        response3 = json.decode(event.response)
        if response3["error"] then
            print("2nd Connection error code:", response3["code"])
            syncResult.message = "Error while connection!"
            syncResult.status = "err"
            syncProcessIsOver(syncResult)
        else
            print("2nd Status code: ", event.status)
            local buf = response3.results[1]
            for i = 1, #response3.results do
                local buf = response3.results[i]
            end


            if  not #response3.results then
                -- if request to parse returned nothing
                syncResult.message = "No result returned"
                syncResult.status = "err"
                syncProcessIsOver(syncResult)
            elseif #response3.results == 0 then
                syncResult.message = "Zero records returned"
                syncResult.status = "ok"
                syncProcessIsOver(syncResult)
            else
                local tableWithImages = true
                if globalTableName == "tSchedule" then tableWithImages = false end


                if tableWithImages then SaveImageNames(globalTableName) end

                ClearSQLiteTable(globalTableName)
                for i = 1, #response3.results do
                    InsertIntoSQLiteTable(globalTableName,fieldsList,response3.results[i])
                end
                SetReplicaVersion(tableWithVersions,globalTableName,masterVersion)

                if tableWithImages then
--                    CheckIfImageDirExists(globalTableName)
                    DeleteOldImages(globalTableName)
                    DownloadNewImages(globalTableName)
                end

                syncResult.message = "New ver is " .. masterVersion .. " and ".. #response3.results .. " recs are added"
                syncResult.status = "ok"
                syncProcessIsOver(syncResult)
            end

        end
    end
end



function syncProcessIsOver(pSyncResult)
    print("pSyncResult.message", pSyncResult.message)

    if pSyncResult.status ~= "ok" then
        print("SyncProcessIsOver: Status not ok")
        syncTables(false, pSyncResult.status)
    else
        syncTables(false, "ok")
    end
end


 function getReplicaVersion()
    local sqlite3 =require("sqlite3")
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )
    local SQL
    local replicaVersion;

    SQL = "SELECT fVer FROM tVersions WHERE fTableName = '" .. globalTableName .. "' AND fEntity = '" .. entity .. "'"
    local i = 0
    print("getReplicaVersion(): " .. SQL)
    for row in db:nrows(SQL) do
        replicaVersion = row.fVer
        i= i+1
    end
    if i == 0 then
            local q = "INSERT INTO tVersions (fEntity, fVer, fTableName) VALUES ('" .. entity .. "', '1', '" .. globalTableName .."');"
            db:exec( q )
            print("getReplicaVersion(): " .. q)
            replicaVersion = 1
    end
    db:close()
    return replicaVersion
 end

function ClearSQLiteTable (pTableName)
    -- delete row
    local sqlite3 =require("sqlite3")
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )

    local SQL = "DELETE FROM '" .. pTableName .. "';"
    print("ClearSQLiteTable(): " .. SQL)

    db:exec( SQL )
    db:close()
end

function InsertIntoSQLiteTable(pTableName, pFieldsList, pValues)
    local sqlite3 =require("sqlite3")
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )
    local SQL_values = "";
    local SQL_fields = "";
    local SQL = "INSERT INTO '" .. pTableName .. "'"
    local Q;
    print("InsertIntoSQLiteTable(): #pFieldsList = " .. #pFieldsList)
    print("InsertIntoSQLiteTable(): pFieldsList[1] = " .. pFieldsList[1])
    print("InsertIntoSQLiteTable(): pFieldsList[2] = " .. pFieldsList[2])
    print("InsertIntoSQLiteTable(): pFieldsList[3] = " .. pFieldsList[3])
    for i=1,#pFieldsList do
        if pValues[pFieldsList[i]]  then
            print("InsertIntoSQLiteTable(): pFieldsList[" .. i .."] = " .. pFieldsList[i])
            print("InsertIntoSQLiteTable(): step " .. i .." SQL_fields = " .. SQL_fields)

            if pValues[pFieldsList[i]] ~= "number" then Q = "'" else Q ="" end
            if SQL_values ~= "" then

                SQL_values = SQL_values .. ", " .. Q .. pValues[pFieldsList[i]] .. Q
                SQL_fields = SQL_fields .. ", " .. pFieldsList[i]
            else
                SQL_values = Q .. pValues[pFieldsList[i]] .. Q
                SQL_fields = pFieldsList[i]
            end
        end
    end

    SQL = SQL .. " (" .. SQL_fields .. ") VALUES (" .. SQL_values .. ");";
    print("InsertIntoSQLiteTable(): " .. SQL)
    db:exec( SQL )
    db:close()
end

function SetReplicaVersion(pTableWithVersions, pTableName, pVersion)
    local sqlite3 =require("sqlite3")
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )
    local d = os.date ("*t")
    local today = d.year .. "-" .. d.month .. "-" .. d.day
    local SQL = "UPDATE " .. pTableWithVersions .. " SET fVer='" .. pVersion .. "', fUpdated='" .. today .. "' WHERE fTableName='" .. pTableName.. "';"
    print("SetReplicaVersion(): " .. SQL)
    db:exec( SQL )
    db:close()
end

function initFieldsList(table)
    if table == "tSchedule" then
        fieldsList = { "fID", "fTrainer", "fDurationH", "fDurationM", "fWeekday", "fRoom", "fTime", "fEntity", "fBuilding"}
    elseif table == "tNews" then
        fieldsList = {"fCaption", "fEntity", "fText", "fShortText", "fImageName", "fImageURL", "fDate" }
    elseif table == "tTeam" then
        fieldsList = {"fTrainerID", "fEntity", "fName", "fDescription", "fDirections", "fImageName", "fImageURL"}
    elseif table == "tServices" then
        fieldsList = {"fEntity", "fCaption", "fText", "fImageName", "fImageURL", "fShortText" }
    elseif table == "tTrainings" then
        fieldsList = {"fDescr", "fShortDescr", "fID", "fRGB", "fName", "fImageName", "fImageURL", "fShortDescr", "fDirection", "fDifficulty", "fAgeRank", "fIsPaid", "fTrainerID"}
    elseif table == "tPictures" then
        fieldsList = {"fName", "fImageName", "fImageURL", "fSortField", "fType"}
    elseif table == "tClubs" then
        fieldsList = {"fName", "fAddress", "fID", "fImageName", "fMapLink", "fLat", "fLong"}
    elseif table == "tDictionary" then
        fieldsList = {"fDictionaryValue", "fDictionaryID", "fName", "fImageURL", "fImageName"}
    end
end

function SaveImageNames(pTableName)
    local sqlite3 =require("sqlite3")
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )

    ---clear tTemp Table
    local SQL = "DELETE FROM 'tTemp';"
    db:exec( SQL )
    -- add image names to tTemp
    SQL = "INSERT INTO tTemp (fValue1) SELECT fImageName FROM '" .. pTableName .. "';"
    print("SaveImageNames(): " .. SQL)
    db:exec(SQL)
    db:close()
end
--------------------------------------------
function CheckIfImageDirExists(pTableName)
    local lfs = require("lfs")
    local buf
    local doc_path = system.pathForFile( "", system.DocumentsDirectory )
    print("CheckIfImageDirExists(): Check if ", pTableName, " exists")
    -- change current working directory
    local success = lfs.chdir( doc_path .. "/" .. pTableName ) -- returns true on success

    if not success then
        print("CheckIfImageDirExists(): Creating folder " .. pTableName)
        buf  = lfs.chdir( doc_path)
        lfs.mkdir( pTableName )
    end
end
--------------------------------------------
function DeleteOldImages(pTableName)
    local sqlite3 =require("sqlite3")
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )
    local row
    local SQL = "SELECT tTemp.fValue1 'val', " .. pTableName .. ".fImageName "
    SQL = SQL .. "FROM tTemp LEFT OUTER JOIN " .. pTableName .. " ON tTemp.fValue1=" .. pTableName .. ".fImageName "
    SQL = SQL .. "WHERE " .. pTableName .. ".fImageName is null and tTemp.fValue1 is not null"

    path = system.pathForFile( "", system.DocumentsDirectory )
    path = path .. "/" .. pTableName .. "/"
    print("DeleteOldImages(): " .. SQL)
    for row in db:nrows(SQL) do
            -- here we delete images
        os.remove( path .. row.val)
    end
    db:close()
end
--------------------------------------------
function DownloadNewImages(pTableName)
    local sqlite3 =require("sqlite3")
    local http = require("socket.http")
    local ltn12 = require("ltn12")
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )
    local folderFullPath, imageFullPath, myFile, img
    local SQL = "SELECT  " .. pTableName .. ".fImageName 'name', " .. pTableName .. ".fImageURL 'url' FROM " .. pTableName
    SQL = SQL .. " LEFT OUTER JOIN tTemp ON " .. pTableName .. ".fImageName=tTemp.fValue1 WHERE tTemp.fValue1 is null "
    SQL = SQL .. "AND " .. pTableName .. ".fImageName is not null"

    path = system.pathForFile( "", system.DocumentsDirectory )
    folderFullPath =  path .. "/" .. pTableName .. "/"
    print("DownloadNewImages(): " .. SQL)

    for img in db:nrows(SQL) do
        if img.name and img.url then
            imageFullPath =  folderFullPath .. img.name
            print("Saving image to: ", imageFullPath)
            local myFile = io.open( imageFullPath, "w+b" )
            http.request{
                url = img.url,
                sink = ltn12.sink.file(myFile),
            }
        end
    end
    db:close()
end

