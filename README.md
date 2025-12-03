# Media Screensaver Roku App

A Roku screensaver that displays images from a configurable media server REST API.

## Features

- Connects to a media server via REST API
- Configurable display time (default: 20 seconds)
- Configurable media server host/IP
- Configurable API endpoint (default: v1/nextImage)
- Displays JPG and GIF images

## Configuration

The app currently has default configuration settings that can be modified in the source code:

- **Media Server Host**: Change `m.config.mediaServerHost` in `source/components/MediaScreensaver.xml`
- **API Endpoint**: Change `m.config.apiEndpoint` in `source/components/MediaScreensaver.xml`
- **Display Time**: Change `m.config.displayTime` in `source/components/MediaScreensaver.xml`

## Building and Installing

1. Set your Roku device IP address:
   ```bash
   export ROKU_DEV_TARGET=192.168.1.XXX
   ```

2. Build the app:
   ```bash
   make
   ```

3. Install to your Roku device:
   ```bash
   make install
   ```

## API Requirements

The media server should provide an endpoint that returns image data (JPG/GIF). The default endpoint is `v1/nextImage` and should respond with image content that can be displayed by the Roku app.

## Project Structure

```
media-screensaver/
├── source/
│   ├── manifest              # Roku app manifest
│   ├── source/
│   │   └── Main.brs         # Main entry point
│   ├── components/
│   │   └── MediaScreensaver.xml  # Main screensaver component
│   └── images/              # App icons and splash screens
└── makefile/                # Build system
```

## Future Enhancements

- Settings screen for user configuration
- Error handling improvements
- Image transitions/effects
- Support for different image formats
- Caching of images