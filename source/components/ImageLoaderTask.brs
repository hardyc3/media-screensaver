sub init()
    print "ImageLoaderTask: Initializing"    
    m.fs = CreateObject("roFileSystem")
    m.urlTransfer = CreateObject("roURLTransfer")
end sub

sub onImagePathChange(event as Object)
    path = event.GetData()
    'print "ImageLoaderTask: imagePath changed to " + path
    if path = "trigger"
        loadImage()
    end if
end sub

sub loadImage()
    'print "ImageLoaderTask: Starting image load"
    
    ' Construct the URL
    url = "http://" + m.top.serverHost + "/" + m.top.apiEndpoint
    'print "ImageLoaderTask: Loading from URL: " + url
    ' Create a temporary file to store the image

    timestamp = CreateObject("roDateTime").AsSecondsLong().ToStr()
    previous = m.path
    m.path = "tmp:/current_image" + timestamp + ".jpg"
    ' Get the image data directly to file
    'print "ImageLoaderTask: Downloading image to " + m.path

    ' Create URL transfer object    
    m.urlTransfer.setUrl(url)
    m.urlTransfer.enableEncodings(false)
    m.urlTransfer.addHeader("Accept", "image/*")
    responseCode = m.urlTransfer.getToFile(m.path)
    if responseCode = 200
        'print "ImageLoaderTask: Download completed with success"
        print "ImageLoaderTask: Image downloaded successfully to " + m.path
        m.top.imagePath = m.path
        if previous <> invalid and previous <> ""
            'print "ImageLoaderTask: Deleting previous " + previous            
            m.fs.Delete(previous)
            DeleteFile(previous)                
        end if
    else
        print "ImageLoaderTask: Failed to download image from " + url
        m.top.imagePath = ""
    end if
end sub