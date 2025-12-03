sub init()
    print "ImageLoaderTask: Initializing"    
    m.urlTransfer = CreateObject("roURLTransfer")
    m.fs = CreateObject("roFileSystem")
    m.transferPort = CreateObject("roMessagePort")
end sub

sub onImagePathChange(event as Object)
    path = event.GetData()
    print "ImageLoaderTask: imagePath changed to " + path
    if path = "trigger"
        loadImage()
    end if
end sub

sub loadImage()
    print "ImageLoaderTask: Starting image load"
    
    ' Construct the URL
    url = "http://" + m.top.serverHost + "/" + m.top.apiEndpoint
    print "ImageLoaderTask: Loading from URL: " + url
    
    ' Create URL transfer object    
    m.urlTransfer.SetUrl(url)
    m.urlTransfer.EnableEncodings(false)
    
    ' Add headers
    m.urlTransfer.AddHeader("Accept", "image/*")
    
    m.urlTransfer.setMessagePort(m.transferPort)

    ' Create a temporary file to store the image
    previous = m.path
    time = CreateObject("roDateTime")
    timestamp = time.AsSecondsLong().ToStr()
    m.path = "tmp:/current_image" + timestamp + ".jpg"
    ' Get the image data directly to file
    print "ImageLoaderTask: Downloading image to " + m.path
    if m.urlTransfer.AsyncGetToFile(m.path)
        print "ImageLoaderTask: Download completed with success"
    
        event = wait(0, m.transferPort)

        if type(event) = "roUrlEvent"
            print "urlTransfer success"
            print "ImageLoaderTask: Image downloaded successfully to " + m.path
            m.top.imagePath = m.path
            if previous <> invalid and previous <> ""
                print "ImageLoaderTask: Deleting previous " + previous            
                m.fs.Delete(previous)
                DeleteFile(previous)                
            end if
        else if event <> invalid
            print "ImageLoaderTask: event emitted: " + type(event)
        else
            m.urlTransfer.asyncCancel()
            print "ImageLoaderTask: Failed to download image from " + url
            m.top.imagePath = ""
        end if
    end if
end sub