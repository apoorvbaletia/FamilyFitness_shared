module(..., package.seeall)

local _H = display.contentHeight;
local _W = display.contentWidth;


local director = require ("director");

local launchArgs = ...

local json = require "json"

local dbsync2 = require "dbsync2"
local dbFilename = "db.sqlite"

function copyOneFileFromSrcDirectoryToDocuments(pTbl, pImg)
    print( "X1 beg: " .. pTbl .. ", " .. pImg )

    local file_src_path, file_dst_path
    file_src_path = system.pathForFile(  "data2copy/" .. pTbl .. "/" .. pImg .. ".dummy", system.ResourceDirectory)
    print( "X1 01")

    file_dst_path = system.pathForFile( nil , system.DocumentsDirectory) .. "/" .. pTbl .. "/" .. pImg
    print( "X1 02")
    local fh = io.open( file_src_path, "rb" )
    print( "X1 03")
    local contents = fh:read( "*a" )
    print( "X1 04")
    local fhs = io.open( file_dst_path, "wb" )
    print( "X1 05")
    fhs:write(contents)
    print( "X1 06")
    io.close( fhs )
    io.close(fh)
    fhs = nil
    fh = nil
    print( " copied file: "..  pImg)
end

function copyFilesFromSrcDirectoryToDocuments()
    print("copyFilesFromSrcDirectoryToDocuments(): beg " )
--    ==========================
    --we init DB connection
    print("CF: Point 01")
    if not fileExists(dbFilename) == true then
        print("CF: Point 02")
        InitialDBCopy(dbFilename)
        return "Yes"
    end
    print("CF: Point 03")

    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    print("CF: Point 04")

    local db = sqlite3.open( path )
    print("CF: Point 05")

    local SQL, SQL2
    local currTable, currImageName
    -- make a query to select names of all the tables
    SQL = "SELECT fTableName FROM tVersions where fHasDataToCopy='Y'"
    print("CF: Point 06")

    for row in db:nrows(SQL) do
        print("Point 1")
        currTable = row.fTableName
        print("Point 2")

        print("copyFilesFromSrcDirectoryToDocuments next table ".. currTable)

        SQL2 = "SELECT fImageName FROM " .. currTable
        print("Point 3")

        for row2 in db:nrows(SQL2) do
            print("Point 4")

            currImageName = row2.fImageName
            print("Point 5")

            if currImageName then
                print("copyFilesFromSrcDirectoryToDocuments next image ".. currImageName)
                print("Point 6")
                copyOneFileFromSrcDirectoryToDocuments(currTable, currImageName)
                print("Point 7")
            end
        end
        print("Point 8")

    end
    print("Point 9")

end
--    ==========================



-------Create empty foldes in documents if there are not
function createFoldersinDocs(folders)
    local i
    local lfs = require("lfs")
    local buf
    local doc_path = system.pathForFile( "", system.DocumentsDirectory )
    local success
    for i=1, #folders do
        print("createFoldersinDocs(): Check if ", folders[i], " exists")
        success = lfs.chdir( doc_path .. "/" .. folders[i] ) -- returns true on success
        if not success then
            print("createFoldersinDocs(): Creating folder " .. doc_path .. "/" .. folders[i])
            buf  = lfs.chdir( doc_path)
            lfs.mkdir( folders[i] )
        end
    end
    print("createFoldersinDocs(): finish " )

end
-----------Split string----------------------------------------------------------------------------
function split (regex, str)
    local tab = {}
    local startt = 1
    local s1, e1 = string.find(str, regex, startt)
    while s1 do
        table.insert(tab, string.sub(str, startt, s1-1))
        startt = e1 + 1
        s1, e1 = string.find(str, regex, startt)
    end
    table.insert(tab, string.sub(str, startt, -1))
    return(tab)
end
-----------Dummy callback function----------------------------------------------------------------------------
function ParseRegistrationWorked(event, params)
    print("ParseRegistrationWorked(): event.response" .. event.response)

end
--------Writes device token to the Parse server----------------------------------------------------------------------------
 function writeToParse(inst)

     local baseUrl = "https://api.parse.com/1/installations"
    local headers = {}
    local url = require("socket.url")
    local params = {}
    local data = {}
    headers["X-Parse-Application-Id"] = "RNvFyOaFmth2DtsenQRwjToK5XjUQdQBRQyzdSOt" -- your Application-Id
    headers["X-Parse-REST-API-Key"] = "qQF0CH2sPeWpVqIFBKkWcGbDSGNIM8OGGquRM7l2" -- your REST-API-Key
    headers["X-Parse-Session-Token"] = nil -- session token for altering User object
    headers["Content-Type"] = "application/json"
    params.headers = headers
    if system.getInfo("platformName") == "Android" then
        baseUrl = "https://api.parse.com/1/classes/tAndroidInstallations"
        data.Token = inst
        data.Channel = "Channel1"
    else
        baseUrl = "https://api.parse.com/1/installations"
        data.deviceType = "ios"
        data.deviceToken = inst
    end

    params.body =  json.encode(data)
    print("Write to parse: ", params.body)
    network.request(baseUrl, "POST", ParseRegistrationWorked, params)
end
--------Checks file existance in the Documents directory (returns true or false)----------------------------------------------------------------------------
 function fileExists(theFile)
    local filePath = system.pathForFile(theFile, system.DocumentsDirectory)
    local results = false
    if filePath == nil then
        return false
    else
        local file = io.open(filePath, "r")
        --If the file exists, return true
        if file then
            io.close(file)
            results = true
        end
        return results
    end
end
--------Copies DB from the source directory to the documents directory----------------------------------------------------------------------------
 function InitialDBCopy(fName)
    local path = system.pathForFile( fName, system.ResourceDirectory )
    local path2 = system.pathForFile( fName, system.DocumentsDirectory )
    local fh = io.open( path, "rb" )
    local contents = fh:read( "*a" )
    local fhs = io.open( path2, "wb" )
    fhs:write(contents)
    io.close( fhs )
    io.close(fh)
    contents = nil
end
---checks if DB file exists and  if not copies a template from resource directory----------------------------------------------------------------------------
function ValidateDBFile()
    if not fileExists(dbFilename) == true then
        InitialDBCopy(dbFilename)
        print("fileExists(): copy " .. dbFilename)

    end
end
----------------- checks if this is a first run (return "Yes" or "No")----------------------------------------------------------------------------
 function isFirstRun()
    local sqlite3 =require("sqlite3")
    if not fileExists(dbFilename) == true then
        InitialDBCopy(dbFilename)
        return "Yes"
    end
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )
    local SQL
    local replicaVersion;
    local flag = true
    SQL = "SELECT fValue FROM fSettings WHERE fName = 'IsFirstRun'"
    print("isFirstRun(): " .. SQL)
    local i = 0
    for row in db:nrows(SQL) do
        flag = row.fValue
    end
    return flag
end
---Set a value for a setting in fSettings table----------------------------------------------------------------------------
function setSetting( name, value)
    local sqlite3 =require("sqlite3")
    local SQL
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )
    SQL = "UPDATE `fSettings` SET fValue = '" .. value .. "' WHERE fName = '" .. name .. "'"
    print("setSetting(): " .. SQL)
    db:exec( SQL )
    db:close()
end
---Get a value from a fSettings table----------------------------------------------------------------------------
function getSetting(name)
    local sqlite3 =require("sqlite3")
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )
    local SQL
    local val
    SQL = "SELECT fValue FROM fSettings WHERE fName = '" .. name .. "'"
    print("getSetting(): " .. SQL)
    val="nothing"
    for row in db:nrows(SQL) do
        val = row.fValue
    end
    print("getSetting(): value = " .. val)
    db:close()
    return val
end
--------Get current club info----------------------------------------------------------------------------
function GetCurrentClubInfo()
    local club = {}
    local sqlite3 =require("sqlite3")
    local SQL
    local path = system.pathForFile( dbFilename, system.DocumentsDirectory )
    local db = sqlite3.open( path )
    club.id = getSetting("CurrentClubID")
    if club.id  == "nothing" then return club end

    SQL = "SELECT * FROM tClubs WHERE fID = '" .. club.id .. "'"
    print("GetCurrentClubInfo(): " .. SQL)
    for row in db:nrows(SQL) do
        club.address = row.fAddress
        club.lat = row.fLat
        club.long = row.fLong
        club.name = row.fName
        print("GetCurrentClubInfo(): club.address = " .. club.address)
        print("GetCurrentClubInfo(): club.lat = " .. club.lat)
        print("GetCurrentClubInfo(): club.long = " .. club.long)
        print("GetCurrentClubInfo(): club.name = " .. club.name)
        print("GetCurrentClubInfo(): club.id = " .. club.id)
    end
    db:close()
    return club
end
