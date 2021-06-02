# Drive Helper tutorial

This is a tutorial on how to set up your app to use DriveHelper and the common methods needed. If you're looking for API reference, see the [generated Dartdocs](https://pub.dev/documentation/drive_helper/latest/) in the pub page.

- [Drive Helper tutorial](#drive-helper-tutorial)
  - [Using Drive Helper in your app](#using-drive-helper-in-your-app)
    - [Adding Firebase to your app](#adding-firebase-to-your-app)
      - [For Android](#for-android)
      - [For iOS](#for-ios)
    - [Enabling Google sign in and Google Drive API](#enabling-google-sign-in-and-google-drive-api)
    - [Setting up Drive Helper in your Flutter app](#setting-up-drive-helper-in-your-flutter-app)
  - [API tutorial](#api-tutorial)
    - [Working with files](#working-with-files)
    - [Reading a file](#reading-a-file)
    - [Writing to a file](#writing-to-a-file)
    - [Working with Google accounts](#working-with-google-accounts)

## Using Drive Helper in your app

### Adding Firebase to your app

In this 'tutorial' you will learn how to enable Google sign in for your project by using Firebase and enable the Drive API for your project

1. Make sure to have a Google account handy for Firebase and testing
2. Firebase is super easy to use and can also provide (optional) analytics without any additional steps
3. First, go to the [Firebase console](https://console.firebase.google.com)
4. Select 'Add project'
5. Enter a name for your project, this is just an alias and is not displayed publicly
6. Next, you will be asked whether you would like to enable Google Analytics. While Analytics is useful, it may not be necessary. You can enable or disable this later if you can't decide
7. Click next and your project will be created
8. Firebase projects are really just a wrapper for _much_ more complicated Google Cloud projects. So you can actually go to the [Google Cloud console ](https://console.cloud.google.com) and you will see the same project there. **Don't delete the Google Cloud project acccidently**
9.  Once Firebase is finished setting up your project, select the platform which you would like to use your Flutter app in

#### For Android

1. Under package name, enter your Android app's `applicationID`
2. You `applicationID` can be found under `flutter_project/android/app/build.gradle` under
```
android {
  defaultConfig {
    applicationID: "com.devname.appname"
  }
}
```
1. If this hasn't been filled out yet, or contains some example IDs, fill in your own. See the Android [website](https://developer.android.com/studio/build/application-id.html) for intructions on making the `applicationID`
2. You can enter anything you want under app nickname
3. Under debug signing certificate, enter the SHA-1 of the machine you will be compiling on (this is dependant on the device you're compiling with so you will have to add new SHA-1s if you switch your computer)
4. Even though it says optional, this is required to enable Google sign in
5. To find out how to get this SHA-1, go [here](https://developers.google.com/android/guides/client-auth)
6. Next, click the download button and save the `google-services.json` file under `flutter_project/android/app`. This file is _very very_ important and if it doesn't exist, the Google sign in API will not know what app is asking the user to sign in and will error out
7. You can skip the next page because `pub` does this for you automatically
8.  Next, click continue to console

#### For iOS

1. Enter your target app's (called `Runner` in Flutter iOS apps) bundle ID
2. You will find this in the iOS project's general tab in the target's page in Xcode
3. If this is not filled in yet, then do so
4. You can provide a nickname and the App Store ID if you have published the app
5. In the next page, download the `GoogleService-Info.plist` and save it in the `flutter_project/ios/Runner` folder
6. This file is _very very_ important and if it doesn't exist, the Google sign in API will not know what app is asking the user to sign in and will error out
7. You can skip steps 3 and 4 in the setup process because `pub` does them for you automatically

### Enabling Google sign in and Google Drive API

12. After configuring the apps, you will have to configure the
    - Firebase project to allow Google Authentication
    - Google Cloud project to enable the Drive API
1.  First, in your project's Firebase console, there should be an item in the sidebar called Authentication, click on that
2.  Click on get started, then go to the sign-in method tab
3.  Click on the Edit button to the right of the Google option
4.  Enable the Google sign in
5.  Change the project public-facing-name to something that makes sense like `dev-name-project-name`, add your email address as a support email, then click save
6.  Congratulations, you have enabled Google sign in for your project!
7.  Now, you need to enable the Google Drive API in Google Cloud
8.  Go to the [Google Cloud console](https://console.cloud.google.com) and select your Firebase project in the top-leftish dropdown menu
9.  Are you extremely confused as too what you're seeing, that's why we use Firebase!
10. Open the navigation menu and at the top there should be an option called APIs and services, click that
11. At the top of this screen, click on `+ ENABLE APIS AND SERVICES` and search for 'drive'
12. Click on the API called Google Drive API and click `ENABLE`
13. Finally, after about half an hour, all you have done is enable Google sign in and the Drive API.

### Setting up Drive Helper in your Flutter app

For DriveHelper to function properly, you have to first instantiate it, then run `signInAndInit` to log in with Google and initialise the Drive API. Here are intructions for a simple implementation of that using `FutureBuilder`

1. Add drive_helper as a dependancy for your app by running `flutter pub add drive_helper` in your project folder
2. In `main.dart` in `main()` in `runApp()` you will be providing a `StatelessWidget` as your app. I recommend using `flutter_phoenix` here to restart your app after log outs
3. This app widget should return a `MaterialApp` or whatever Cupertino uses in its `build()` method
4. In your `MaterialApp` or equivalent, instead of passing a homepage or whatever directly to its body, use a FutureBuilder. 
5. You can take this project's [example app's](https://github.com/theRookieCoder/drive_helper/blob/main/example/lib/main.dart) `MyApp`'s build method as an example
6. Before the build method, define a drive helper instance in the class. For example:
```dart
class App extends StatelessWidget {
  // Important:
  final driveHelper = DriveHelper();

  @override
  Widget build() {
    return FutureBuilder() {
      ...
      ...
    }
  }
}
```
6. Then in the `FutureBuilder`, you should pass the `driveHelper.signInAndInit(scope)` as the future
7. In the build method of the `FutureBuilder`, you should return 
   - A progress indicator if the Future is completing
   - An error page if the Future completed and errored out
   - The homepage of your app only if the Future completed and has no errors
8. After that, you can carry on using the rest of DriveHelper methods

## API tutorial
  
### Working with files

- To create a file, use `createFile()`
- To delete a file, use `deleteFile()`
- To get a file's file id fom its name, use `getFileID()`

### Reading a file

To read a file, there are multiple methods

- To get the raw data of the file, you can use `getData()`
- To get the data of a Google Doc file (Sheets, Docs, Slides) in a more standard format (e.g. export Sheets file as csv), use `exportFile()`

### Writing to a file

There are also multiple methods to write to a file

- To append data to the end of a file, you can use `appendFile()`
- To overwrite all existing content with new data, you can use `updateData()`

### Working with Google accounts

- You can get the `name`, `email`, and `avatar` of the Google accont using their respective getters
- You can sign out the account with `signOut()`*
- You can disconnect the account from your app using `disconnect()`*

\* Do be sure to use a package like flutter_phoenix to restart the app after sign outs or disconnects
