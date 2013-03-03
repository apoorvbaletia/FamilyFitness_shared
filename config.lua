if string.sub(system.getInfo("model"),1,4) == "iPad" then
    application = 
    {
        content =
        {
            width = 360,
--            height = 480,
            height = 568,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0
            }
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }

elseif string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then --this is iPhone5
    application = 
    {
        content =
        {
            width = 320,
            height = 568,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix =
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0
            }
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }

elseif string.sub(system.getInfo("model"),1,2) == "iP" then -- iPhones below 5 and iPods
    application =
    {
        content =
        {
            width = 320,
            height = 480,
            scale = "zoomStretch",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0
            }
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
else --- By now this is a common section for all the Android devices (to be adjusted)
    application =
    {
        content =
        {
            width = 320,
            height = 480,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix =
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification =
        {
            google =
            {
                -- This Project Number (also known as a Sender ID) tells Corona to register this application
                -- for push notifications with the Google Cloud Messaging service on startup.
                -- This number can be obtained from the Google API Console at:  https://code.google.com/apis/console
                projectNumber = "798521839038",
            },
        },

    }
end
--[[


elseif display.pixelHeight / display.pixelWidth > 1.72 then
    application =
    {
        content =
        {
            width = 320,
            height = 570,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix =
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0
            },
        },
    }
else
    application =
    {
        content =
        {
            width = 320,
            height = 512,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix =
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification =
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
end
]]
