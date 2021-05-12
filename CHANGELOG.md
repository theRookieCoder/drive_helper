# Changelog

## [1.2.4]

- Fixed erranous `getFileID` function

## [1.2.3]

- Changed all positional optional arguments to named optional arguments

## [1.2.2]

- Added the ability to specify parents to files in `createFile()`

## [1.2.1]

- Removed author label in pubspec.yaml
- Made the README.md a lot better
- Renamed the docs folder to doc

## [1.2.0]

API:
- Added API documentation to complement dartdocs
- Drive helper now interactively signs in if the user is signed out
- Added sign out and disconnect methods to the API
- Renamed `exportFileData` to `exportFile`

Example app:
- Added sign out and disconnect functionality to the app in the account page
- Added flutter phoenix to restart the app after sign out or disconnect

## [1.1.0]

- Updated `pubspec.yaml`
- Added example application called example
- Updated the way the mime types are accessed
- Changed `createFile` function to include preliminary data
- Added export mime type option to `appendFile`
- Added command to open file from fileID
- Added `getData` to get data as plain text

## [1.0.0]

- Initial commit
