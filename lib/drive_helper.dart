library drive_helper;

import 'package:flutter/material.dart' show Widget;
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInAccount, GoogleUserCircleAvatar;
import 'package:googleapis/drive/v3.dart'
    show DriveApi, File, Media, DownloadOptions;
import 'dart:convert' show ascii;
import 'package:http/http.dart'
    show BaseClient, Client, StreamedResponse, BaseRequest;
import 'package:url_launcher/url_launcher_string.dart';

class _GoogleAuthClient extends BaseClient {
  final Map<String, String> _headers;
  final Client _client = new Client();

  _GoogleAuthClient(this._headers);

  Future<StreamedResponse> send(BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

/// ExportMimeTypes lets you choose a mime type for exporting Google Doc files
class ExportMimeTypes {
  /// Don't instantiate externally
  ExportMimeTypes._();

  /// Plain text
  ///
  /// For presentations and documents
  static final text = "text/plain";

  /// PDF format
  ///
  /// For documents, spreadsheets, drawings(images), and presentations
  static final pdf = "application/pdf";

  /// CSV format
  ///
  /// For spreadsheets (first sheet only)
  static final csv = "text/csv";

  /// MS Excel format
  ///
  /// For spreadsheets
  static final excel =
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

  /// JPEG format
  ///
  /// For drawing(images)
  static final jpeg = "image/jpeg";

  /// PNG format
  ///
  /// For drawing(images)
  static final png = "image/png";

  /// SVG format
  ///
  /// For drawing(images)
  static final svg = "image/svg+xml";

  /// JSON format
  ///
  /// For app scripts
  static final json = "application/vnd.google-apps.script+json";
}

/// FileMimeTypes lets you choose a mime type for creating files
class FileMimeTypes {
  /// Don't instantiate externally
  FileMimeTypes._();

  /// File
  ///
  /// You may provide a file extension with the file name and Drive will convert
  /// the file type later
  ///
  /// For example, if you create a file with this mime type and call it
  /// `test.csv`, that file will convert into a Google Sheets file
  ///
  /// Do not worry however, as you can choose to export a Google Sheets file to
  /// the csv format
  static final file = "application/vnd.google-apps.file";

  /// Folder
  ///
  /// To put a file in to a folder, specify the folder's file ID as the parent
  /// of the file
  static final folder = "application/vnd.google-apps.folder";
}

/// DriveScopes lets you choose from 4 scopes of data access for Google Drive
class DriveScopes {
  /// Don't instantiate externally
  DriveScopes._();

  /// See, create, edit, and delete all Google Drive files created by anyone
  ///
  /// Only use this if absolutely necessary.
  /// `app` should be plenty for most purposes
  static final full = DriveApi.driveScope;

  /// See, create, edit, and delete all Google Drive files created by this app
  /// only
  ///
  /// This is the recommended scope for most apps
  static final app = DriveApi.driveFileScope;

  /// See, create, edit, and delete files that can only be created and viewed by
  /// this app
  ///
  /// Perfect for configuration files, databases, etc
  ///
  /// Files stored in this special folder cannot be seen by the user but can be
  /// deleted by the user
  static final appData = DriveApi.driveAppdataScope;

  /// Be able to read (not write) all Google Drive files created by anyone
  static final read = DriveApi.driveReadonlyScope;
}

/// DriveHelper
///
/// Warning: All errors encountered are directly passed. It is the developer's
/// responsibility to inform the user that the intended action has not been
/// completed successfully
class DriveHelper {
  // Variables

  /// The Google Drive API
  late DriveApi driveAPI;

  /// The Google account
  late GoogleSignInAccount account;

  /// The Google account settings
  late GoogleSignIn signIn;

  // Getters

  /// Get the Google account's display name, assuming it exists
  String? get name => account.displayName;

  /// Get the Google account's email
  String get email => account.email;

  /// Get a widget that shows the Google account's avatar
  Widget get avatar => GoogleUserCircleAvatar(identity: account);

  // Methods

  /// Empty constructor
  ///
  /// MUST CALL `signInAndInit` ASYNCHRONOUSLY ON THE INSTANCE TO INITIALIZE
  /// PIS
  DriveHelper();

  /// MUST BE CALLED ASYNCHRONOUSLY AFTER INSTANTIATION
  ///
  /// Must provide valid [scopes] from `DriveScopes`
  ///
  /// The app must not continue to use the helper instance if this function
  /// errored out
  ///
  /// Consider using a `FutureBuilder` to show an error page if this method
  /// fails
  Future<void> signInAndInit(List<String> scopes) async {
    // Sign in
    signIn = GoogleSignIn.standard(scopes: scopes);
    late GoogleSignInAccount? testAccount;

    await signIn.isSignedIn()
        ? testAccount = await signIn.signInSilently() ?? await signIn.signIn()
        : testAccount = await signIn.signIn();

    if (testAccount != null) {
      account = testAccount;
    } else {
      throw "Account was null";
    }

    // Initialise driveAPI
    final authHeaders = await account.authHeaders;
    final authClient = _GoogleAuthClient(authHeaders);

    driveAPI = DriveApi(authClient);
  }

  /// Mark the current user as being in the signed out state
  ///
  /// You should restart the app afterwards using a package such as
  /// flutter_phoenix
  Future<void> signOut() async => signIn.signOut();

  /// Disconnect the user from the app and revokes all authentication between
  /// the user and this app
  ///
  ///
  /// Requires the user to sign in and accept the scopes the next time the user
  /// tries to sign in
  ///
  /// You should restart the app afterwards using a package such as
  /// flutter_phoenix
  Future<void> disconnect() async => signIn.disconnect();

  /// Creates a new file
  ///
  /// Must provide a [fileName], and a [mime] type from `FileMimeTypes`
  ///
  /// You can also providd some text to initialise the file with (e.g. header
  /// data/boilerplate)
  ///
  /// Returns the fileID of the file created, store this to use this file in the
  /// future
  Future<String> createFile(
    String fileName,
    String mime, {
    List<String>? parents,
    String text = "",
  }) async {
    var file = new File();
    file.name = fileName;
    file.mimeType = mime;
    file.parents = parents;

    Media mediaStream = Media(
      Future.value(
        List.from(ascii.encode(text)).cast<int>().toList(),
      ).asStream().asBroadcastStream(),
      text.length,
    );

    file = await driveAPI.files.create(file, uploadMedia: mediaStream);
    return file.id!;
  }

  /// Open the file in the relevant editor or viewer in a browser
  ///
  /// THis uses url_launcher to launch the webViewLink property of a file. This
  /// may be null, in which case a null error is thrown
  ///
  /// Must provide [fileID] of the file to open
  Future<void> openFile(String fileID) async {
    final file = await driveAPI.files.get(fileID) as File;
    launchUrlString(file.webViewLink!);
  }

  /// GET the data of a file
  ///
  /// Must provide [fileID] of file to get data from
  ///
  /// Returns data of the file in text format
  Future<String> getData(String fileID) async {
    final file = await driveAPI.files.get(
      fileID,
      downloadOptions: DownloadOptions.fullMedia,
    ) as Media;
    String fileData = "";
    await file.stream.listen((event) {
      fileData += String.fromCharCodes(event);
    }).asFuture();
    return fileData;
  }

  /// Append data to an existing file
  ///
  /// Must provide the [fileID] of a file and the [data] to append to the file
  ///
  /// You may also provide a [mime] type of the format to export the file in.
  /// This defaults to `ExportMimeTypes.text`
  ///
  /// Optionally, you can provide a seperator which is what must be added
  /// between the existing data and the provided data.
  /// This defaults to a newline (\n)
  Future<void> appendFile(
    String fileID,
    String newData, {
    String mime = "text/plain",
    String seperator = '\n',
  }) async {
    String? data = await exportFile(fileID, mime);
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
  /// It may seem obvious but please use this command with extreme caution,
  /// especially with `DriveScopes.full`
  Future<void> deleteFile(String fileID) => driveAPI.files.delete(fileID);

  /// Overwrite an existing file with new data
  ///
  /// Must provide the [fileID] of a file and [data] to overwrite with
  ///
  /// It may not be obvious but please use this command with extreme caution as
  /// this is equivalent to deleting the existing the existing data in the file
  ///
  /// If you need to append data to the end of a file, use `appendFile`
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

  /// Export a Google Doc file's data in the intended format/mime type
  ///
  /// Returns the exported data in text format
  ///
  /// Must provide the [fileID] of the file to export and the [mime] type of the
  /// export format from `ExportMimeTypes`
  Future<String?> exportFile(String fileID, String mime) async {
    Media? fileMedia = await driveAPI.files.export(
      fileID,
      mime,
      downloadOptions: DownloadOptions.fullMedia,
    );

    String fileData = "";
    await fileMedia!.stream.listen((event) {
      fileData += String.fromCharCodes(event);
    }).asFuture();
    return fileData;
  }

  /// Get the fileID of a file from its name.
  ///
  /// If multiple files with the same name exist, all their IDs will be returned
  /// in a list
  ///
  /// This only searches for items that are not trashed
  ///
  /// Must provide a [fileName] to search with
  Future<List<String>> getFileID(String fileName) async {
    final search = await driveAPI.files.list(
      q: "name='$fileName' and trashed=false",
      spaces: signIn.scopes.contains(DriveApi.driveAppdataScope)
          ? "appDataFolder"
          : "drive",
    );

    List<String> result = List.empty(growable: true);

    if (search.files!.length == 0) {
      throw "File not found";
    } else {
      for (var file in search.files!) {
        result.add(file.id!);
      }
    }

    return result;
  }
}
