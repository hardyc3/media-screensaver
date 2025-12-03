'*************************************************************
'** Media Screensaver
'** Copyright (c) 2025 Media Screensaver. All rights reserved.
'** Use of the Roku Platform is subject to the Roku SDK License Agreement:
'** https://docs.roku.com/doc/developersdk/en-us
'*************************************************************

' replace Main with RunScreenSaver
sub Main()
    print "Starting Media Screensaver"
    
    'Indicate this is a Roku SceneGraph application
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    
    'Create a scene and load /components/MediaScreensaver.xml
    scene = screen.CreateScene("MediaScreensaver")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub