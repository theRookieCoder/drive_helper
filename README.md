# Drive Helper

Drive Helper is an easy to use library for interfacing with Google Drive and Google sign in.  
It is a thin wrapper around `google_sign_in` and `googleapis`, making it much more intuitive for developers to use and integrate Google Drive into a project. If you already use the Drive API, then you probably have a wrapper class for initialisation and read/write, you can likely easily replace it with Drive Helper.

## Get started

Follow the instruction in the [tutorial](https://github.com/theRookieCoder/drive_helper/blob/main/doc/DriveHelper.md) to start using Drive Helper in your Flutter project, or migrate to it for an existing app.

## Features

- Signs in to Google and maintains the account for you
- Exposed `DriveAPI`, `GoogleSignIn`, and `GoogleSignInAccount` to help with possibly missing functionality
- Provides methods for
  - Signing in to and signing out or disconnecting from Google accounts
  - Searching, creating, reading, overwriting, appending, and deleting files
  - Getting the account's name, email address, or avatar
- Predefined MIME types for use in creating and exporting files
- Predefined permission scopes for easily picking a suitable permission level apt for your purposes

## Example

To have a look at an app that uses this library, see the app that inspired Drive Helper, [BP Logger](https://www.github.com/theRookieCoder/bp_logger).

The code below shows how to initialise the library:

```dart
class MyApp extends StatelessWidget {
  late DriveHelper driveHelper;

  Widget build() {
    return MaterialApp(
      // Theming and other setting
      body: FutureBuilder(
        future: () async => await driveHelper = DriveHelper.initialise([
            // Choose your scopes
        ]),
        builder: (snapshot, context) {
          if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
            return HomePage(driveHelper: driveHelper);
          } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasError) {
            return ErrorPage(error: snapshot.error);
          } else {
            return Container(
              width: MediaQuery.of(context).size.width / 1.5,
              height: MediaQuery.of(context).size.width / 1.5,
              child: CircularProgrssIndicator(strokeWidth: 10),
            );
          }
        }
      ),
    );
  }
}
```
