sub init()
    m.imagePoster = m.top.findNode("imagePoster")
    m.imagePosterNext = m.top.findNode("imagePosterNext")
        
    ' Observe for when the image is actually loaded
    m.imagePosterNext.observeField("loadStatus", "onNextImageLoadComplete")
    m.imagePoster.observeField("loadStatus", "onNextImageLoadComplete")

    print "MediaScreenSaver: Load configuration from registry"
    loadConfig()

    ' Set up proper screen dimensions
    setupScreenDimensions()

    m.imageLoader = CreateObject("roSGNode", "ImageLoaderTask")
    m.imageLoader.observeField("imagePath", "onImageLoaded")

    print "MediaScreenSaver: Start the image display cycle"
    m.imageTimer = m.top.findNode("imageTimer")
    m.imageTimer.observeField("fire", "loadNextImage")
        
    print "MediaScreenSaver: Start timer"
    m.imageTimer.control = "start"
    m.top.setFocus(true)
end sub

sub setupScreenDimensions()
    ' Get the actual screen dimensions
    screen = CreateObject("roDeviceInfo")
    displaySize = screen.GetDisplaySize()
    
    if displaySize <> invalid
        screenWidth = displaySize.w
        screenHeight = displaySize.h
        print "MediaScreenSaver: Screen dimensions: " + screenWidth.toStr() + "x" + screenHeight.toStr()
        
        ' Set poster dimensions to match screen
        m.imagePoster.width = screenWidth
        m.imagePoster.height = screenHeight
        m.imagePosterNext.width = screenWidth
        m.imagePosterNext.height = screenHeight
        
        ' Center the posters
        m.imagePoster.translation = [0, 0]
        m.imagePosterNext.translation = [0, 0]
    else
        print "MediaScreenSaver: Using default 1920x1080 dimensions"
    end if
end sub

sub loadNextImage()
    print "MediaScreenSaver: Timer fired, loading next image..."
    m.imageLoader.serverHost = m.config.mediaServerHost
    m.imageLoader.apiEndpoint = m.config.apiEndpoint
    print "MediaScreenSaver: Configured ImageLoaderTask with serverHost: " + m.imageLoader.serverHost + " and apiEndpoint: " + m.imageLoader.apiEndpoint
    
    print "MediaScreenSaver: Creating image timer with duration: " + m.config.displayTime.toStr() + " seconds"
    m.imageTimer.duration = m.config.displayTime     

    ' Start the task by setting imagePath to trigger the load
    m.imageLoader.imagePath = "trigger"
    m.imageLoader.control = "start"
end sub

sub onImageLoaded(event as Object)
    path = event.getData()

    if path <> invalid and path <> "" and path <> "trigger"
        print "MediaScreenSaver: Image loaded successfully: " + path
        
        ' Load the new image into the hidden poster
        m.imagePosterNext.loadDisplayMode = "scaleToFit"
        m.imagePosterNext.uri = path
    else
        print "MediaScreenSaver:  Failed to load image from " + m.config.mediaServerHost
    end if
end sub

sub onNextImageLoadComplete(event as Object)
    loadStatus = event.getData()
    
    if loadStatus = "ready"
        print "MediaScreenSaver: Next image ready, performing transition"
        ' Swap the posters - hide current, show next
        m.imagePoster.visible = false
        m.imagePosterNext.visible = true
        
        ' Swap references for next cycle
        tempPoster = m.imagePoster
        m.imagePoster = m.imagePosterNext
        m.imagePosterNext = tempPoster
        
        ' Clear the old poster's URI for next use
        m.imagePosterNext.uri = ""
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "options" or key = "*" ' Options key or * key
        print "MediaScreenSaver: Opening settings screen"
        openSettings()
        return true
    end if

    return false
end function

sub openSettings()
    print "MediaScreenSaver: Pause the timer while settings are open"
    
    if m.imageTimer <> invalid
        m.imageTimer.control = "stop"
    end if

    print "MediaScreenSaver: Create settings screen"
    settingsScreen = m.top.createChild("SettingsScreen")
    settingsScreen.ObserveField("close", "onSettingsClosed")
    settingsScreen.visible = true
end sub

sub loadConfig()
    registry = CreateObject("roRegistry")
    section = CreateObject("roRegistrySection", "MediaScreensaver")

    m.config = {
        mediaServerHost: "192.168.0.4:8984" ' Default
        apiEndpoint: "v1/nextImage" ' Default
        displayTime: 15 ' Default seconds
    }

    if section <> invalid
        if section.Exists("serverHost")
            print "MediaScreenSaver: Reading serverHost from registry"
            host = section.Read("serverHost")
            if host <> invalid and host <> ""
                print "MediaScreenSaver: Setting mediaServerHost to: " + host
                m.config.mediaServerHost = host
            end if
        end if
        
        if section.Exists("apiEndpoint")
            endpoint = section.Read("apiEndpoint")
            if endpoint <> invalid and endpoint <> ""
                print "MediaScreenSaver: Setting apiEndpoint to: " + endpoint
                m.config.apiEndpoint = endpoint
            end if
        end if
        
        if section.Exists("displayTime")
            time = section.Read("displayTime")
            if time <> invalid and time <> ""
                displayTime = time.toInt()
                if displayTime > 0 and displayTime <= 300
                    print "MediaScreenSaver: Setting displayTime to: " + displayTime.toStr() + " seconds"
                    m.config.displayTime = displayTime
                end if
            end if
        end if
    end if
end sub

sub onSettingsClosed(event as Object)
    print "MediaScreenSaver: Remove settings screen"
    settingsScreen = event.getRoSGNode()
    settingsScreen.visible = false
    m.top.removeChild(settingsScreen)

    print "MediaScreenSaver: Reload configuration in case it changed"
    loadConfig()

    print "MediaScreenSaver: Update timer duration if display time changed"
    
    if m.imageTimer <> invalid
        print "MediaScreenSaver: Updating timer duration to: " + m.config.displayTime.toStr() + " seconds"
        m.imageTimer.duration = m.config.displayTime * 1000
    end if

    print "MediaScreenSaver: Restart timer and load new image"
    loadNextImage()
    m.imageTimer.control = "start"
end sub
