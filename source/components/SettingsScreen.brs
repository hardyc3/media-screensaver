function init()
    m.top.setFocus(true)
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
    
    ' Set initial focus
    m.serverHostInput.setFocus(true)
    
    ' Set up key handling
    m.top.observeField("keyEvent", "onKeyEvent")
end function

function loadSettings()
    config = getConfig()
    
    if config.serverHost <> invalid
        m.serverHostInput.text = config.serverHost
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
    section = registry.GetSection("MediaScreensaver")
    
    if section = invalid
        return {}
    end if
    
    config = {}
    
    if section.Exists("serverHost")
        config.serverHost = section.Read("serverHost")
    end if
    
    if section.Exists("apiEndpoint")
        config.apiEndpoint = section.Read("apiEndpoint")
    end if
    
    if section.Exists("displayTime")
        config.displayTime = section.Read("displayTime").toInt()
    end if
    
    return config
end function

function saveConfig(config as Object)
    registry = CreateObject("roRegistry")
    section = registry.GetSection("MediaScreensaver")
    
    if section = invalid
        section = registry.CreateSection("MediaScreensaver")
    end if
    
    if config.serverHost <> invalid
        section.Write("serverHost", config.serverHost)
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
            serverHost: m.serverHostInput.text,
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
    m.top.close = true
    end function
    
    function onKeyEvent(event as Object) as Boolean
    key = event.getKey()
    press = event.isPressed()
    
    if not press then return false
    
    if key = "back"
        closeSettings()
        return true
    end if
    
    return false
end function