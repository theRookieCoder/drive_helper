# Drive Helper tutorial

This is a tutorial on how to set up your app to use Drive Helper and the common methods needed. If you're looking for the API reference, see the [generated Dartdocs](https://pub.dev/documentation/drive_helper/latest/).

- [Drive Helper tutorial](#drive-helper-tutorial)
  - [Using Drive Helper in your app](#using-drive-helper-in-your-app)
    - [Adding Firebase to your app](#adding-firebase-to-your-app)
      - [For Android](#for-android)
      - [For iOS](#for-ios)
    - [Enabling Google sign in and Google Drive API](#enabling-google-sign-in-and-google-drive-api)
    - [Setting up Drive Helper in your Flutter app](#setting-up-drive-helper-in-your-flutter-app)
  - [API tutorial](#api-tutorial)
    - [Working with files](#working-with-files)
      - [`createFile()`](#createfile)
      - [`deleteFile()`](#deletefile)
      - [`getFileID()`](#getfileid)
    - [Reading a file](#reading-a-file)
      - [`getData()`](#getdata)
      - [`exportFile()`](#exportfile)
    - [Writing to a file](#writing-to-a-file)
      - [`appendFile()`](#appendfile)
      - [`updateData()`](#updatedata)
    - [Working with the Google account](#working-with-the-google-account)

## Using Drive Helper in your app

### Adding Firebase to your app

In this 'tutorial' you will learn how to enable Google sign in and the Drive API for your project by using Firebase.

1. Make sure to have a Google account handy for Firebase and testing
2. Firebase is super easy to use and can also provide (optional) analytics without any additional steps
3. First, go to the [Firebase console](https://console.firebase.google.com)
4. Select 'Add project'
5. Enter a name for your project, this is just an alias and is not displayed publicly
6. Next, you will be asked whether you would like to enable Google Analytics. While Analytics is useful, it may not be necessary. You can enable or disable this later if you can't decide
7. Click next, and your project will be created
8. A Firebase project is really just a wrapper around a (_much_ more complex) Google Cloud project. So, you can actually go to the [Google Cloud console](https://console.cloud.google.com), and you will see the same project there. **Don't delete the Google Cloud project as it is tied to the Firebase project**
9.  Once Firebase is finished setting up your project, select the platform(s) you would like to use your Flutter app in

#### For Android

1. Under package name, enter your Android app's `applicationID`
2. The `applicationID` can be found in `android/app/build.gradle` under
```groovy
android {
  defaultConfig {
    applicationID: "com.devname.appname"
  }
}
```
1. If this hasn't been filled out yet, or contains a placeholder ID, fill in your own. See the Android [website](https://developer.android.com/studio/build/application-id.html) for intructions on making an `applicationID`
2. You can enter anything you want under the app nickname
3. Under debug signing certificate, enter the SHA-1 hash of the machine you will be compiling on (this depends on the device you're compiling with so you will have to add new hashes if you switch your computer)
4. Even though it says it is optional, _this step is required_ to enable Google sign in
5. To find out how to get this SHA-1 hash, go [here](https://developers.google.com/android/guides/client-auth)
6. Next, click the download button and save the `google-services.json` file under `flutter_project/android/app`. This file is _very_ important and if it doesn't exist, the Google sign in API will error out
7. You can skip the next page because `pub` does this step for you automatically
8. Next, click continue to console

#### For iOS

1. Enter your target app's (called `Runner` in Flutter iOS apps) bundle ID
2. You will find this in the iOS project's general tab in the targets page in Xcode
3. If this is not filled in yet, do so
4. You can provide a nickname and the App Store ID if you have published the app
5. In the next page, download the `GoogleService-Info.plist` and save it in the `flutter_project/ios/Runner` folder
6. This file is _very_ important and if it doesn't exist, the Google sign in API will error out
7. You can skip steps 3 and 4 in the setup process because `pub` does them for you automatically

### Enabling Google sign in and Google Drive API

After configuring the platform apps, you will have to configure the
   - Firebase project to allow Google authentication
   - Google Cloud project to enable the Drive API

1. In your project's Firebase console, there should be an item in the sidebar called Authentication, click on that
2. Click on get started, then go to the sign-in method tab
3. Click on the Edit button to the right of the Google option
4. Enable Google sign in
5. Change the project's `public-facing-name` to something that makes sense like `dev-name-project-name`, add your email address as a support email, then click save
6. Congratulations, you have enabled Google sign in for your project!

Now, you need to enable the Google Drive API in Google Cloud

1. Go to the [Google Cloud console](https://console.cloud.google.com) and select your Firebase project in the top-leftish dropdown menu
2. Open the navigation menu and at the top, there should be an option called APIs and services, click that
3. At the top of this screen, click on `+ ENABLE APIS AND SERVICES` and search for 'drive'
4. Click on the Google Drive API and click `ENABLE`

### Setting up Drive Helper in your Flutter app

To use Drive Helper, you need to add it as a dependency, and run the `DriveHelper.initialise()` function to asynchronously sign in to Google and initialise the Drive API.

1. Add drive_helper as a dependancy for your app by running `flutter pub add drive_helper` in your project folder
2. In `main.dart` in `main()` in `runApp()` you will be providing a `StatelessWidget` as your app. I recommend using `flutter_phoenix` here to restart your app after log outs
3. In your `MaterialApp` or equivalent, enclose your UI in a `FutureBuilder` and pass an async anonymous function that runs `DriveHelper.initialise()` and assigns it to a state variable
4. In the builder parameter, you should return 
   - A progress indicator if the `Future` is completing
   - An error page if the `Future` completed and errored out
   - The homepage of your app only if the `Future` completed and has no errors

Use the following code as an example:

```dart
class App extends StatelessWidget {
  late DriveHelper driveHelper;

  @override
  Widget build() {
    return FutureBuilder() {
      future: () async => driveHelper = await driveHelper.initialise(
        // Choose your required permission scopes
      ),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          // Return your app's homepage
        } else if (snapshot.hasError) {
          // Return an error page
        } else {
          // Return a progress indicator like `CircularProgressIndicator`
      }
    }
  }
}
```

After this, you can use the assigned state variable (`driveHelper` in this case) to access the Drive API

## API tutorial
  
### Working with files

#### `createFile()`

Create a file 
```dart
final imagePath = "$docPath/$imageName.jpg";
if (File(imagePath).existsSync()) {
  final existingFileID = await driveHelper
      .getFileID("$imageName.jpg")
      .then((files) => files.isNotEmpty ? files[0] : null)
      .catchError((_) => null);

  if (existingFileID == null) {
    final imageBytes = await File(imagePath).readAsBytes();
    await driveHelper!.createFile(
      "$imageName.jpg",
      "image/jpeg", // Correct MIME type for JPEG
      parents: [imagesFolderID],
      content: imageBytes,
    );
  }
}
```
```dart
final jsonData = jsonEncode(syncData);

await driveHelper.updateFile(
  await driveHelper!
      .getFileID("app_settings.json")
      .then((files) => files[0])
      .catchError((error) async => await driveHelper!.createFile(
      "app_settings.json",
      "application/json",      // MIME type
      parents: [appFolderID],
      text: jsonEncode(syncData)   // JSON content
  )),
  jsonData,
);
```
#### `deleteFile()`

Delete a file

#### `getFileID()`

Get a file's file ID fom its name

### Reading a file

#### `getData()`

Get the raw data of the file

#### `exportFile()`

Get the data of a Google Workspace file (Sheets, Docs, Slides, etc) in a more standard format (e.g. export a Sheets file as csv).

### Writing to a file

#### `appendFile()`

Append data to the end of a file

#### `updateData()`

Overwrite all existing content with new data

### Working with the Google account

Get the `name`, `email`, and `avatar` of the Google account using their respective getters.

Temporarily sign out the account with `signOut()`.

Fully disconnect the account from your app using `disconnect()`.

Do be sure to use a package like [`flutter_phoenix`](https://pub.dev/packages/flutter_phoenix) to restart the app after sign outs and disconnects.
