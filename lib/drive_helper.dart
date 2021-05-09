library drive_helper;

import 'package:flutter/material.dart' show Widget;
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInAccount, GoogleUserCircleAvatar;
import 'package:googleapis/drive/v3.dart'
    show DriveApi, File, Media, DownloadOptions;
import 'dart:convert' show ascii;
import 'GoogleAuthClient.dart';

/// DriveHelperMimeTypes let you choose a simple mime type for file creation and exporting
class _DriveHelperMimeTypes {
  // Regular MIME types

  /// File
  ///
  /// You may provide a file extension with the file name and Drive will convert the mime type later
  ///
  /// For example, if you create a file with this mime type and call it `test.csv`, that file will convert into a Google Sheets file
  ///
  /// Do not worry however, as you can choose to export a Google Sheets file to the csv format
  final file = "application/vnd.google-apps.file";

  /// Folder
  final folder = "application/vnd.google-apps.folder";

  /// Image
  final image = "application/vnd.google-apps.photo";

  /// Video
  final video = "application/vnd.google-apps.video";

  /// Unknown/undetermined
  final unknown = "application/vnd.google-apps.unknown	";

  // Google Apps

  /// Google Docs
  final gdoc = "application/vnd.google-apps.document";

  /// Google Forms
  final gform = "application/vnd.google-apps.form";

  /// Google Slides
  final gslides = "application/vnd.google-apps.presentation";

  /// Google Sites
  final gsites = "application/vnd.google-apps.site";

  /// Google Sheets
  final gsheets = "application/vnd.google-apps.spreadsheet";
}

/// DriveHelperScope lets you choose from 4 simple scopes of data access for Google Drive
class _DriveHelperScope {
  /// See, create, edit, and delete all Google Drive files created by anyone
  ///
  /// Only use this if absolutely necessary.
  /// `app` should be fine for most
  final full = DriveApi.driveScope;

  /// See, create, edit, and delete all Google Drive files created by this app only
  ///
  /// This is the recommended scope for most apps
  final app = DriveApi.driveFileScope;

  /// See, create, edit, and delete files that can only be created and viewed by this app
  ///
  /// Perfect for configuration files, databases, etc
  final appData = DriveApi.driveAppdataScope;

  /// Only be able to read all Google Drive files created by anyone
  final read = DriveApi.driveReadonlyScope;
}

/// DriveHelper
class DriveHelper {
  // Variables
  /// The Google Drive API
  late DriveApi driveAPI;

  /// The Google account
  late GoogleSignInAccount account;

  /// The Google account settings
  late GoogleSignIn signIn;

  // Getters
  /// Returns the Google account's display name, assuming it exists
  String? get name => account.displayName;

  /// Returns the Google account's email
  String get email => account.email;

  /// Returns a widget that shows the Google account avatar
  Widget get avatar => GoogleUserCircleAvatar(identity: account);

  /// Mime types for use in creating and exporting files
  static _DriveHelperMimeTypes get mime => _DriveHelperMimeTypes();

  /// Scopes for use in `signInAndInit`
  static _DriveHelperScope get scopes => _DriveHelperScope();

  // Methods
  /// MUST CALL `signInAndInit` ASYNCHRONOUSLY ON THE HELPER INSTANCE TO INITIALIZE APIS
  DriveHelper();

  /// MUST BE CALLED ASYNCHRONOUSLY AFTER INSTANTIATION
  ///
  /// Must provide a valid [scope] from `DriveHelper.scopes`
  ///
  /// The app must not continue to use the helper if this function errored out
  ///
  /// Consider using a `FutureBuilder` to show an error page if this method fails
  Future<void> signInAndInit(List<String> scopes) async {
    // Sign in
    signIn = GoogleSignIn.standard(scopes: scopes);
    GoogleSignInAccount? testAccount =
        await signIn.signInSilently() ?? await signIn.signIn();

    if (testAccount != null) {
      account = testAccount;
    } else {
      throw "Account was null";
    }

    // Initialise driveAPI
    final authHeaders = await account.authHeaders;
    final authClient = GoogleAuthClient(authHeaders);

    driveAPI = DriveApi(authClient);
  }

  /// Creates a new file
  ///
  /// Must provide a [fileName], and a [mime] type from `DriveHelper.mime`
  ///
  /// Returns the fileID of the file created, store this to use this file in the future
  Future<String> createFile(String fileName, String mime) async {
    var file = new File();
    file.name = fileName;
    file.mimeType = mime;
    file = await driveAPI.files.create(file);
    return file.id!;
  }

  /// Append data to an existing file
  ///
  /// Must provide the [fileID] of a file and the [data] to append to the file
  ///
  /// Optionally, you can provide a seperator which is what must be added between the existing data and the provided data.
  /// Defaults to a newline (\n)
  Future<void> appendFile(
    String fileID,
    String newData, [
    String seperator = '\n',
  ]) async {
    String? data = await exportFileData(fileID, "text/plain");
    late String finalData;
    if (data != null) {
      finalData = data + seperator + newData;
    } else {
      throw "Could not receive data";
    }
    updateFile(fileID, finalData);
  }

  /// Deletes a file
  ///
  /// Must provide a [fileID] of the file to delete
  ///
  /// It may seem obvious but please use this command with extreme caution, especially with `DriveHelper.scopes.full`
  Future<void> deleteFile(String fileID) => driveAPI.files.delete(fileID);

  /// Overwrite an existing file with new data
  ///
  /// Must provide the [fileID] of a file and [data] to overwrite with
  ///
  /// It may not be obvious but please use this command with extreme caution as this is equivalent to deleting a file
  ///
  /// If you need to add a line to the end of a file, use `appendFile`
  Future<void> updateFile(String fileID, String data) async {
    final dataList = List.from(ascii.encode(data)).cast<int>().toList();

    Stream<List<int>> mediaStream =
        Future.value(dataList).asStream().asBroadcastStream();

    var media = new Media(
      mediaStream,
      dataList.length,
    );

    await driveAPI.files.update(new File(), fileID, uploadMedia: media);
  }

  /// Export a file's data in the intended format/mime type
  ///
  /// Must provide a [fileID] and the [mime] type of the export format from `DriveApi.mime`
  Future<String?> exportFileData(String fileID, String mime) async {
    Media? fileMedia = await driveAPI.files.export(
      fileID,
      mime,
      downloadOptions: DownloadOptions.fullMedia,
    );

    String? fileData;
    await fileMedia!.stream.listen((event) {
      fileData = String.fromCharCodes(event);
    }).asFuture();
    return fileData;
  }

  /// Get the fileID of a file from its name.
  ///
  /// If multiple files with the same name exist, all their IDs will be returned in a list
  ///
  /// Must provide a [fileName] to search with
  Future<List<String>> getFileID(String fileName) async {
    final search = await driveAPI.files.list(
      q: "name=$fileName and trashed=false",
      spaces: signIn.scopes.contains(DriveApi.driveAppdataScope)
          ? "appDataFolder"
          : "drive",
    );

    List<String> result = List.empty();

    if (search.files!.length == 0) {
      throw "File not found";
    } else {
      search.files!.forEach((file) {
        result.add(file.id!);
      });
    }

    return result;
  }
}
