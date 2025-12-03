# AGENTS.md - Media Screensaver Roku App

## Build Commands
- `make` - Build the app zip file
- `make install` - Build and install to Roku device (requires ROKU_DEV_TARGET env var)
- `make check` - Run BrightScript compiler/check tool
- `make check-strict` - Run strict mode checking
- `make clean` - Remove build artifacts
- `make run` - Remove and reinstall app

## Code Style Guidelines

### BrightScript/SceneGraph
- Use 2-space indentation
- Function names: PascalCase for functions, camelCase for variables
- Use `m.` prefix for member variables
- Print statements for debugging are acceptable
- Error handling: check for `invalid` objects before use
- Registry operations: always check section exists before read/write

### XML Components
- Use proper XML formatting with 4-space indentation
- Component names: PascalCase
- Node IDs: camelCase
- Layout: use absolute positioning with translation arrays
- Colors: use 0xRRGGBBAA format

### File Structure
- Main entry: `source/source/Main.brs`
- Components: `source/components/*.xml`
- Manifest: `source/manifest`
- Images: `source/images/`

### Configuration
- Store settings in Roku registry under "MediaScreensaver" section
- Default values should be defined in code
- Validate user input before saving to registry