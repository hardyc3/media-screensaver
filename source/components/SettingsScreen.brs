function init()
    m.background = m.top.findNode("background")
    m.titleLabel = m.top.findNode("titleLabel")
    m.serverHostLabel = m.top.findNode("serverHostLabel")
    m.serverHostInput = m.top.findNode("serverHostInput")
    m.apiEndpointLabel = m.top.findNode("apiEndpointLabel")
    m.apiEndpointInput = m.top.findNode("apiEndpointInput")
    m.displayTimeLabel = m.top.findNode("displayTimeLabel")
    m.displayTimeInput = m.top.findNode("displayTimeInput")
    m.saveButton = m.top.findNode("saveButton")
    m.cancelButton = m.top.findNode("cancelButton")
    m.statusLabel = m.top.findNode("statusLabel")
    
    ' Load current settings
    loadSettings()
    
    ' Set up button observers
    m.saveButton.observeField("buttonSelected", "onSaveSelected")
    m.cancelButton.observeField("buttonSelected", "onCancelSelected")
    
    ' Set up focus management
    m.top.setFocus(true)
    m.serverHostInput.setFocus(true)
end function


function loadSettings()
    config = getConfig()
    
    if config.mediaServerHost <> invalid
        m.serverHostInput.text = config.mediaServerHost
    else
        m.serverHostInput.text = "192.168.1.100" ' Default
    end if
    
    if config.apiEndpoint <> invalid
        m.apiEndpointInput.text = config.apiEndpoint
    else
        m.apiEndpointInput.text = "v1/nextImage" ' Default
    end if
    
    if config.displayTime <> invalid
        m.displayTimeInput.text = config.displayTime.toStr()
    else
        m.displayTimeInput.text = "20" ' Default
    end if
end function

function getConfig() as Object
    registry = CreateObject("roRegistry")
    section = CreateObject("roRegistrySection", "MediaScreensaver")
    
    
    config = {}
    if section <> invalid
        if section.Exists("serverHost")
            print "MediaScreenSaver: Reading serverHost from registry"
            host = section.Read("serverHost")
            if host <> invalid and host <> ""
                print "MediaScreenSaver: Setting mediaServerHost to: " + host
                config.mediaServerHost = host
            end if
        end if
        
        if section.Exists("apiEndpoint")
            endpoint = section.Read("apiEndpoint")
            if endpoint <> invalid and endpoint <> ""
                print "MediaScreenSaver: Setting apiEndpoint to: " + endpoint
                config.apiEndpoint = endpoint
            end if
        end if
        
        if section.Exists("displayTime")
            time = section.Read("displayTime")
            if time <> invalid and time <> ""
                displayTime = time.toInt()
                if displayTime > 0 and displayTime <= 300
                    print "MediaScreenSaver: Setting displayTime to: " + displayTime.toStr() + " seconds"
                    config.displayTime = displayTime
                end if
            end if
        end if
    end if
    
    return config
end function

function saveConfig(config as Object)
    registry = CreateObject("roRegistry")
    section = CreateObject("roRegistrySection", "MediaScreensaver")
    
    if config.mediaServerHost <> invalid
        section.Write("serverHost", config.mediaServerHost)
    end if
    
    if config.apiEndpoint <> invalid
        section.Write("apiEndpoint", config.apiEndpoint)
    end if
    
    if config.displayTime <> invalid
        section.Write("displayTime", config.displayTime.toStr())
    end if
    
    registry.Flush()
end function
    
function onSaveSelected()
    if validateSettings()
        config = {
            mediaServerHost: m.serverHostInput.text,
            apiEndpoint: m.apiEndpointInput.text,
            displayTime: m.displayTimeInput.text.toInt()
        }
        
        saveConfig(config)
        m.statusLabel.text = "Settings saved successfully!"
        m.statusLabel.color = "0x00FF00FF"
        
        ' Close settings after a short delay
        m.top.timer = m.top.createChild("Timer")
        m.top.timer.duration = 1.5
        m.top.timer.observeField("fire", "closeSettings")
        m.top.timer.control = "start"
    else
        m.statusLabel.text = "Please check your input values"
        m.statusLabel.color = "0xFF0000FF"
    end if
end function
    
function onCancelSelected()
    closeSettings()
end function
    
function validateSettings() as Boolean
    ' Validate server host (basic check)
    if m.serverHostInput.text = "" or m.serverHostInput.text.Len() < 3
        m.statusLabel.text = "Invalid server host"
        return false
    end if
    
    ' Validate API endpoint
    if m.apiEndpointInput.text = "" or m.apiEndpointInput.text.Len() < 1
        m.statusLabel.text = "Invalid API endpoint"
        return false
    end if
    
    ' Validate display time
    displayTime = m.displayTimeInput.text.toInt()
    if displayTime <= 0 or displayTime > 300
        m.statusLabel.text = "Display time must be between 1 and 300 seconds"
        return false
    end if
    
    return true
end function
    
function closeSettings()
    m.top.visible = false
    if m.top.getParent() <> invalid
        m.top.getParent().removeChild(m.top)
    end if
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    
    if key = "back"
        closeSettings()
        return true
    end if
    
    if key = "down"
        ' Navigate between fields
        if m.serverHostInput.isInFocusChain()
            m.apiEndpointInput.setFocus(true)
        else if m.apiEndpointInput.isInFocusChain()
            m.displayTimeInput.setFocus(true)
        else if m.displayTimeInput.isInFocusChain()
            m.saveButton.setFocus(true)
        else if m.saveButton.isInFocusChain()
            m.cancelButton.setFocus(true)
        else if m.cancelButton.isInFocusChain()
            m.serverHostInput.setFocus(true)
        end if
        return true
    end if
    
    if key = "up"
        ' Navigate between fields in reverse
        if m.serverHostInput.isInFocusChain()
            m.cancelButton.setFocus(true)
        else if m.apiEndpointInput.isInFocusChain()
            m.serverHostInput.setFocus(true)
        else if m.displayTimeInput.isInFocusChain()
            m.apiEndpointInput.setFocus(true)
        else if m.saveButton.isInFocusChain()
            m.displayTimeInput.setFocus(true)
        else if m.cancelButton.isInFocusChain()
            m.saveButton.setFocus(true)
        end if
        return true
    end if
    
    if key = "left"
        ' Navigate between buttons
        if m.saveButton.isInFocusChain()
            m.cancelButton.setFocus(true)
        else if m.cancelButton.isInFocusChain()
            m.saveButton.setFocus(true)
        end if
        return true
    end if
    
    if key = "right"
        ' Navigate between buttons
        if m.saveButton.isInFocusChain()
            m.cancelButton.setFocus(true)
        else if m.cancelButton.isInFocusChain()
            m.saveButton.setFocus(true)
        end if
        return true
    end if
    
    return false
end function