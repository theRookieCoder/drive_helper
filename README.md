# Drive Helper
> This project is open source on [Github](https://www.github.com/theRookieCoder/drive_helper)  
> By [theRookieCoder](https://www.github.com/theRookieCoder)

Drive Helper is an easy to use library for interfacing with Google Drive and Google sign in.  
Drive Helper is better than using `google_sign_in` and `googleapis` because it is much more intuitive for you as a developer to use and integrate into a project. If you already use Drive API, then you probably wrote a wrapper class anyways for initialisation and read/write so why not use Drive Helper as a drop in replacement?

## Get started

Follow the instruction in the [documentation](docs/drive) to start using Drive Helper in your Flutter project, or migrate to it for an existing app using Drive API

## Features

- Signs in to Google and maintains the account seperately from your app
- Exposed drive API and Google sign in & sign in account for limitless possibility
- 2 methods for reading, 2 for writing, one for creating files, and one for deleting them
- Predefined mime types for use in creating and exporting files
- Predefined scopes also exist for you to easily select a scope to create your Google account with
- Getters defined for getting the account's name, email address, and avatar

## Examples

For examples, see the [example app](example/lib/main.dart). There are simply too many methods and variables to show one example for. However the code below does show how to initialise the library

To see a commercial app that uses this library, see the app that inspired this libray [BP Logger](https://www.github.com/theRookieCoder/bp_logger)

```dart
class MyApp extends StatelessWidget {
  DriveHelper driveHelper = DriveHelper();

  Widget build() {
    return MaterialApp(
      // Theming etc, etc
      body: FutureBuilder(
        future: driveHelper.signInAndInit(DriveHelper.scopes.app),
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

## Compatibility

This library of sorts is actually just a wrapper around [Google sign in](https://pub.dev/packages/google_sign_in) and [Google APIs](https://pub.dev/packages/googleapis) and so the contraints of those packages are inherited by this library
