
module(..., package.seeall)
local widget = require( "widget" )


function new()
    local _H = display.contentHeight;
    local _W = display.contentWidth;

    local iPhone5;
    local phoneDiff;
    if _H == 480 then iPhone5 = false else iPhone5 = true end

--    local image = display.newImageRect ("images2/scr2/s2_bg_4.png", 640, 1136);
--    image:setReferencePoint( display.CenterReferencePoint )
--    image.x = display.contentCenterX
--    image.y = display.contentCenterY

    local bgFileName;
    if iPhone5 then
        bgFileName = "images2/scr2/s2_bg_retina.jpg";
    else
        bgFileName = "images2/scr2/s2_bg.jpg";
    end
    local image = display.newImageRect (bgFileName, _W, _H);
    image:setReferencePoint( display.CenterReferencePoint )
    image.x = display.contentCenterX
    image.y = display.contentCenterY

    ---------------------------------------
    local txtHeader = display.newText( "Идет обновление... Подождите ", 0, 0, display.contentWidth, 0, native.systemFontBold, 24)
    txtHeader:setReferencePoint( display.CenterReferencePoint )

    txtHeader.x = display.contentCenterX
    txtHeader.y = display.contentCenterY + display.contentCenterY/2

    --create display groups

    local localGroup = display.newGroup();
    localGroup:insert(image);
    localGroup:insert(txtHeader);

    return localGroup;
end




