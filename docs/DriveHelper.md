# Drive Helper API Reference

This is the API documentation for DriveHelper. While the dartdocs are useful, that is only if you know what to look for. For example, there is no function `readFile()` for reading a file. Hence this document acts as a pseudo index of some sorts to help you find the function you need

> Disclaimer:  
> All errors, whether it be null checks or API request errors, encountered in DriveHelper's methods are directly thrown and not handled. It is the developer's responsibility to handle these errors and notify the user that the intended action has not been completed successfully

- [Drive Helper API Reference](#drive-helper-api-reference)
  - [Set up tutorial](#set-up-tutorial)
    - [Adding Firebase to your app](#adding-firebase-to-your-app)
      - [For Android](#for-android)
      - [For iOS](#for-ios)
    - [Enabling Google sign in and Google Drive API](#enabling-google-sign-in-and-google-drive-api)
    - [Setting up Drive Helper](#setting-up-drive-helper)
  - [API Reference](#api-reference)
    - [DriveHelper variables](#drivehelper-variables)
      - [`driveApi`](#driveapi)
      - [`signIn`](#signin)
      - [`account`](#account)
    - [DriveHelper getters](#drivehelper-getters)
      - [`name`](#name)
      - [`email`](#email)
      - [`avatar`](#avatar)
      - [`mime.files`](#mimefiles)
        - [`file`](#file)
        - [`folder`](#folder)
      - [`mime.export`](#mimeexport)
      - [`scopes`](#scopes)
        - [`full`](#full)
        - [`app`](#app)
        - [`appData`](#appdata)
        - [`read`](#read)
    - [DriveHelper methods](#drivehelper-methods)
      - [`DriveHelper()`](#drivehelper)
      - [`signInAndInit()`](#signinandinit)
      - [`signOut()`](#signout)
      - [`disconnect()`](#disconnect)
      - [`createFile()`](#createfile)
      - [`openFile()`](#openfile)
      - [`getData()`](#getdata)
      - [`appendData()`](#appenddata)
      - [`deleteFile()`](#deletefile)
      - [`updateFile()`](#updatefile)
      - [`exportFile()`](#exportfile)
      - [`getFileID()`](#getfileid)
  - [API tutorial?](#api-tutorial)
    - [Creating a file](#creating-a-file)
    - [Reading a file](#reading-a-file)
    - [Writing to a file](#writing-to-a-file)
    - [Working with files](#working-with-files)
    - [Working with Google accounts](#working-with-google-accounts)

## Set up tutorial

### Adding Firebase to your app

1. Make sure to have a Google account handy for Firebase and testing
2. In this 'tutorial' you will learn how to enable Google sign in for your project by using Firebase
3. Firebase is super easy to use and can also provide (optional) analytics without any additional steps
4. First, go to [Firebase](https://console.firebase.google.com)
5. Select 'Add project'
6. Enter a name for your project, this is just an alias and is not displayed publicly
7. I also recommend you click on the tiny chip (that's what they're called in Material design) to change your Project ID, _this_ is shown publicly and I recommend using something like `dev-name-project-name`
8. Next, you will be asked whether you would like to enable Google Analytics. While Analytics is useful, it may not be necessary. You can change this later
9. Click next and your project will be created
10. Firebase projects are really just a wrapper for _much_ more complicated Google Cloud projects so you can actually go to [Google Cloud](https://console.cloud.google.com) and you will see the same project there. **Don't delete the Google Cloud project**
11. Once it is finished setting up your project, select the platform which you would like to use your Flutter app in

#### For Android

1. Under package name, enter your Android app's applicationID
2. You applicationID can be found under `flutter_project/android/app/build.gradle` under
```
android {
  defaultConfig {
    applicationID: "com.devname.appname"
  }
}
```
3. If this hasn't been filled out yet, or contains some example IDs, fill in your own. See the Android [website](https://developer.android.com/studio/build/application-id.html) for intructions on making your own
4. You can enter anything you want under app nickname
5. Under debug signing certificate, enter the SHA-1 of the machine you will be compiling on (this is dependant on the device you're compiling with so you will have to add new SHA-1s if you switch your computer)
6. Even though it says optional, this is required to enable Google sign in
7. To find out how to get this SHA-1, go [here](https://developers.google.com/android/guides/client-auth)
8. Next, click the download button and save the `google-services.json` file under `flutter_project/android/app`. This file is _very very_ important and if it doesn't exist, the Google sign in API will not know what app is asking the user to sign in and will error out
9. You can skip the next part because `pub` does this for you
10. Next, click continue to console

#### For iOS

1. Enter your target app's (called `Runner` in Flutter iOS apps) bundle ID
2. You fill find this in the iOS project's general tab in Xcode where you will also sign the app etc
3. If this is not filled in yet, then do so
4. You can provide a nickname and the App Store ID is optional
5. In the next page, download the `GoogleService-Info.plist` and save it in the `flutter_project/ios/Runner` folder
6. This file is _very very_ important and if it doesn't exist, the Google sign in API will not know what app is asking the user to sign in and will error out
7. Skip steps 3 and 4 becuase you're using Flutter

### Enabling Google sign in and Google Drive API

12. After configuring the apps, you will have to configure the Firebase project to allow Google Authentication and the Google Cloud project to enable the Drive API
13. First, in your project's Firebase console, there shouls be an item in the sidebar called Authentication, click on that
14. Click on get started, then go to the sign-in method tab
15. Click on the Edit button to the right of the Google option
16. Enable the Google sign in
17. Change the project public-facing-name to something that makes sense like `dev-name-project-name` then add your email address as a support email, then click save
18. Congratulations, you have enabled Google sign in for your project
19. Now, you need to enable the Google Drive API in Google Cloud
20. Go to [Google Cloud](https://console.cloud.google.com) and select your Firebase project in the top-leftish dropdown menu
21. Are you extremely confused as too what you're seeing, that's why we use Firebase!
22. Open the navigation menu and at the top there should be an option called APIs and services, click that
23. At the top of this screen, click on `+ ENABLE APIS AND SERVICES` and search for 'drive'
24. Click on the API called Google Drive API and click `ENABLE`
25. Finally, after about half an hour, all you have done is enable Google sign in and the Drive API. Trying to use the Drive API itself is even harder. Understand why I made Drive Helper?
26. Now you can add Drive Helper in your `pubspec.yaml` and take advantage of all the hardwork I put into Drive Helper, for free

### Setting up Drive Helper

For DriveHelper to function properly, you have to first instantiate it to a variable, then run `signInAndInit` to log in with Google and initialise the Drive API. Here is intruction for a simple implementation of that using `FutureBuilder`

1. Add drive_helper as a dependancy for your app by running `flutter pub add drive_helper` in your project folder
2. In `main.dart` in `main()` in `runApp` you will be providing a `StatelessWidget` as your app which returns a `MaterialApp` or whatever Cupertino uses in `build()`
3. In your `MaterialApp` or equivalent, instead of passing a homepage or whatever directly to the body, use a FutureBuilder. 
4. You can take this project's [example app](../example/lib/main.dart) `MyApp`'s build method as an example
5. Before the build method, define a drive helper instance in the class. For example:
```dart
class App extends StatelessWidget {
  // Important:
  final driveHelper = DriveHelper();

  @override
  Widget build() {
  ...
  ...
}
```
6. Then in the `FutureBuilder`, you should pass the `driveHelper.signInAndInit(scope)` as the future
7. In the build method of the `FutureBuilder`, you should return 
   - A progress indicator if the Future is completing
   - An error page if the Future completed and is erraneous
   - And the main homepage of your app only if the Future completed and has no errors
8. After that, you can carry on to use DriveHelper whichever way you like

## API Reference

### DriveHelper variables

While using the methods is recommended, if you encounter missing functionality, the `DriveApi`, `GoogleSignIn`, and `GoogleSignInAccount` variables are exposed to allow full funtionality

#### `driveApi`

```dart
late DriveApi driveAPI;
```

`DriveApi` in `googleapis/drive/v3.dart`

#### `signIn`

```dart
late GoogleSignIn signIn;
```

`GoogleSignIn` in `google_sign_in/google_sign_in.dart`

#### `account`

```dart
late GoogleSignInAccount account;
```

`GoogleSignInAccount` in `google_sign_in/google_sign_in.dart`

### DriveHelper getters

#### `name`

Get the display name of the Google account

#### `email`

Get the email address of the Google account

#### `avatar`

Get the Google account's avater as a widget

`GoogleUserCircleAvatar` in `google_sign_in/google_sign_in.dart`

#### `mime.files`

##### `file`

Create a new file. File extension will be derived from the file name

##### `folder`

Can be used when creating a file to create a folder instead  
You can specify a folder's id as the parent of a new file/folder to place that file/folder in the folder

#### `mime.export`

See dartdocs or [source file](../lib/drive_helper.dart#L18)

#### `scopes`

A class with 4 scopes to pick from. These are like read write access controls and these let you choose how much Google Drive access your app needs

##### `full`

This scope allows the app to see, create, edit, and delete all Google Drive files created by anyone.  
This is not required for most apps and should be used very sparingly

##### `app`

This scope allows the app to see, create, edit, and delete Google Drive files created by this app only.  
This is the recommended scope for most apps

##### `appData`

This scope allows the app to see, create, edit, and delete Google Drive files in the apps special app data folder. This folder can not be viewed by the user.  
This scope is perfect for storing configuration files, databases and what not.  
Beware that the files in this folder can be deleted by the user is they want to

##### `read`

This scope allows the app to see all Google Drive files

### DriveHelper methods

#### `DriveHelper()`

Empty constructor.  
***You must initialise the class by aynchronously calling `signInAndInit()`***

#### `signInAndInit()`

`List<String>` of scopes to create the [`signIn`](#signin) with.  
Recommend picking a scope from `DriveHelper.scopes`

The app must not continue to use the class if this function fails

#### `signOut()`

You should restart the app using [flutter_pheonix](https://pub.dev/packages/flutter_phoenix) for example

Mark the current user as being in the sign out state. Requires interactive sign in on the next sign in

#### `disconnect()`

You should restart the app using [flutter_pheonix](https://pub.dev/packages/flutter_phoenix) for example

Disconnect the user from the app entirely.  
All authentication between the user and the app even on other devices will be revoked.  
Requires the user to accept the scope again as part of connecting the user back

#### `createFile()`

Must provide a file name, and mime type of the file to create. Can also provide some text to intitialise the file with (e.g. header data)

Returns the file's file id. Store this to use in the future for accessing this file

#### `openFile()`

Requires the file to open's file id. Gets the metadata of the file and uses url launcher to launch the web view link property of the file. The web view link might not always exist

#### `getData()`

Requires the file id of the file to get the data from.  
Returns the file's data in text format

#### `appendData()`

Requires the file id of the file to append data to and the data to append. You may also provide a mime type to export the file as before data is appended to it

#### `deleteFile()`

Requires the file id of the file to delete. Rather self explanetary

#### `updateFile()`

Requires the file id of the file to update and the data to overwrite that file with. This method sort of deletes the existing file data so be careful while using it

#### `exportFile()`

Requires the file id of the file to export and the mime type of the format to export the file as.  
Returns the exported data as text

#### `getFileID()`

Requires the file name to search for.  
Returns a list of of fileIDs of all the files found with the given name.  

Does not search for items in the trash

## API tutorial?

### Creating a file

To create a file, there is just one simple method, `createFile()`

### Reading a file

To read a file, there are multiple methods

- To get the raw data of the file, you can use `getData()`
- To get the data of a Google Workspace file in a more standard format (e.g. export Sheets file as csv), use `exportFile()`

### Writing to a file

There are also multiple methods to write to a file

- To add data to the end of a file, you can use `appendFile`
- To overwrite all existing content with new data, you can use `updateData()`
  
### Working with files

- To create a file, use `createFile()`
- To delete a file, use `deleteFile()`
- To get a file's file id using its name, use `getFileID()`

### Working with Google accounts

- You can get the `name`, `email`, and `avatar` using their respective getters
- You can sign out the account with `signOut()`
- You can disconnect the account from your app using `disconnect()`
Do be sure to use a package like flutter_phoenix to restart the app after sign out or disconnect
