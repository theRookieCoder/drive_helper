# Changelog

## `1.4.0`
### 04.02.2023

This update mostly focuses on improving the ergonomics than adding functionality.

- Updated dependencies
- Improved a lot of the documentation, readme, and tutorial
- Moved `ExportMimeTypes` to `export_mime_types.dart` and split them into categories according to the [new documentation](https://developers.google.com/drive/api/guides/ref-export-formats)
- Removed `DriveHelper.openFile()` as it is too unreliable
- Made the `DriveHelper` class's constructor named and private, forcing use of the `DriveHelper.initialise()` function
- Improved most of the internal code to be more concise

## [1.3.1]

Update dependencies

## [1.3.0]

- Update dependencies
- Remove example
- Remove deprecated items

## [1.2.6]

- Edited text in README.md
- Made the doc into a tutorial file and moved all API References to the dartdocs
- Deprecated `DriveHelper.mime.files`. Use `FileMimeTypes`
- Deprecated `DriveHelper.mime.export`. Use `ExportMimeTypes`
- Deprecated `DriveHelper.scopes`. Use `DriveScopes`
- Updated dart docs in `drive_helper.dart` to add missing comments from `doc/DriveHelper.md`
- Updated example app to abide by the deprecation notices
- Made `exportFile()` fix [issue #1](https://github.com/theRookieCoder/drive_helper/issues/1) as well

## [1.2.5]

- Edited README.md file

Library:
- Fixed [issue #1](https://github.com/theRookieCoder/drive_helper/issues/1) about `getData()`
- Upgraded dependencies
- Added error checking to `getData` 
- Made `GoogleAuthClient` private

Example:
- Added `GET data` button

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
