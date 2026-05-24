library drive_helper;

import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInAccount, GoogleUserCircleAvatar;
import 'package:googleapis/drive/v3.dart'
    show DriveApi, File, Media, DownloadOptions;
import 'dart:convert' show utf8;
import 'package:http/http.dart'
    show BaseClient, Client, StreamedResponse, BaseRequest;

/// A [BaseClient] that stores the Google authentication headers
/// and uses them to authenticate each request
class _GoogleAuthClient extends BaseClient {
  _GoogleAuthClient(this._headers);

  final Map<String, String> _headers;
  final _client = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) =>
      _client.send(request..headers.addAll(_headers));
}

/// MIME types that Google Drive uses for files
abstract class FileMIMETypes {
  /// If you provide a file extension with the file name,
  /// and the file type will be automatically inferred.
  ///
  /// For example, if you create a file with this mime type and call it
  /// `test.csv`, it will be automatically converted into a Google Sheets file.
  ///
  /// You can still get back a CSV file by choosing the appropriate export type.
  static final file = "application/vnd.google-apps.file";

  /// # Folder
  ///
  /// To put a file into a folder, create a file using this type,
  /// and specify the file's parent as the folder created.
  static final folder = "application/vnd.google-apps.folder";
}

/// Scopes of data access
///
/// [Official Documentation](https://developers.google.com/drive/api/guides/api-specific-auth#drive-scopes)
abstract class DriveScopes {
  /// See, create, edit, and delete all Google Drive files created by anyone
  ///
  /// Only use this if absolutely necessary,
  /// [app] should be enough for most purposes.
  static const full = DriveApi.driveScope;

  /// See, create, edit, and delete all Google Drive files created by this app only
  ///
  /// This is the recommended scope for most apps.
  static const app = DriveApi.driveFileScope;

  /// See, create, edit, and delete files that can only be created and viewed by this app
  ///
  /// Perfect for configuration files, databases, etc.
  ///
  /// Files stored in this special folder cannot be seen by the user,
  /// but can be deleted by them.
  static const appData = DriveApi.driveAppdataScope;

  /// Only read (not edit or create) all Google Drive files created by anyone
  static const read = DriveApi.driveReadonlyScope;
}

final class DriveHelper {
  /// Google API Drive v3 instance
  DriveApi driveAPI;

  /// The signed-in Google account
  GoogleSignInAccount account;

  /// Google sign in configuration settings
  GoogleSignIn signIn;

  /// Signed-in account's display name
  get name => account.displayName;

  /// Signed-in account's email address
  get email => account.email;

  /// A widget that shows the signed-in account's avatar
  get avatar => GoogleUserCircleAvatar(identity: account);

  /// Private constructor
  DriveHelper._construct(this.driveAPI, this.account, this.signIn);

  /// Sign in to Google Drive and intialise [DriveHelper]
  ///
  /// You can find some standard [scopes] in [DriveScopes].
  static Future<DriveHelper> initialise(List<String> scopes) async {
    final signIn = GoogleSignIn.standard(scopes: scopes);

    final account = (await signIn.isSignedIn()
        ? await signIn.signInSilently() ?? await signIn.signIn()
        : await signIn.signIn());

    if (account == null) {
      throw "Account authentication failed";
    }

    return DriveHelper._construct(
      DriveApi(_GoogleAuthClient(await account.authHeaders)),
      account,
      signIn,
    );
  }

  /// Mark the current user as being in the signed out state
  ///
  /// After calling, you must prompt the user to sign in again.
  Future<void> signOut() async => signIn.signOut();

  /// Disconnect the user from the app,
  /// and revoke all permissions the user provided
  ///
  /// Requires the user to sign in and accept the permissions
  /// the next time the user tries to sign in.
  ///
  /// After calling, you must prompt the user to sign in again.
  Future<void> disconnect() => signIn.disconnect();

  /// Create a new file with [fileName], and a [mime] type
  /// that is from [FileMIMETypes] or a custom string
  ///
  /// Optionally, specify the ID(s) of the parent folder(s) in [parents].
  ///
  /// You can provide some text to initialise the file with
  /// (e.g. for headers or boilerplate).
  ///
  /// Returns the ID of the file created,
  /// store this to refer to this file in the future.
  Future<String> createFile(
    String fileName,
    String mime, {
    List<String>? parents,
    String text = "",
  }) async {
    final file = await driveAPI.files.create(
      File(
        name: fileName,
        mimeType: mime,
        parents: parents,
      ),
      uploadMedia: Media(
        Stream.value(utf8.encode(text)),
        text.length,
      ),
    );
    return file.id!;
  }

  /// GET the data of [fileID]'s file as a string
  Future<String> getData(String fileID) async {
    final file = await driveAPI.files.get(
      fileID,
      downloadOptions: DownloadOptions.fullMedia,
    ) as Media;

    String fileData = "";
    await file.stream.listen((bytes) {
      fileData += String.fromCharCodes(bytes);
    }).asFuture();
    return fileData;
  }

  /// Append [data] to an existing file of [fileID]
  ///
  /// You may also provide the [mime] type of the format to export the file in,
  /// this defaults to plain text.
  ///
  /// Optionally, you can provide a [seperator] which will be added
  /// between the existing data and the provided [data].
  /// This defaults to a newline `\n`.
  Future<void> appendFile(
    String fileID,
    String data, {
    String mime = "text/plain",
    String seperator = '\n',
  }) async {
    final oldData = await exportFile(fileID, mime);
    updateFile(fileID, oldData + seperator + data);
  }

  /// Delete the file of [fileID]
  ///
  /// Use with caution, especially with [DriveScopes.full]!
  Future<void> deleteFile(String fileID) => driveAPI.files.delete(fileID);

  /// Overwrite an existing file of [fileID] with new data
  ///
  /// This effectively deletes the existing data in the file,
  /// so be careful when using it.
  ///
  /// If you need to append data to the end of a file, use [appendFile].
  Future<void> updateFile(String fileID, String data) => driveAPI.files.update(
        File(),
        fileID,
        uploadMedia: Media(
          Stream.value(utf8.encode(data)),
          data.length,
        ),
      );

  /// Exports the file of [fileID] in the provided [mime] type
  Future<String> exportFile(String fileID, String mime) async {
    final fileMedia = await driveAPI.files.export(
      fileID,
      mime,
      downloadOptions: DownloadOptions.fullMedia,
    );

    String fileData = "";
    await fileMedia!.stream.listen((bytes) {
      fileData += String.fromCharCodes(bytes);
    }).asFuture();
    return fileData;
  }

  /// Gets the file ID(s) of files named [fileName]
  ///
  /// Only searches for items that are trashed if [trashed] is true.
  Future<List<String>> getFileID(String fileName,
      {bool trashed = false}) async {
    final search = await driveAPI.files.list(
      q: "name='$fileName' and trashed=$trashed",

      // ignore: prefer_interpolation_to_compose_strings
      spaces: "drive" +
          (signIn.scopes.contains(DriveApi.driveAppdataScope)
              ? ", appDataFolder"
              : ""),
    );

    if (search.files == null || search.files!.isEmpty) {
      throw "File not found";
    } else {
      return search.files!.map((file) => file.id!).toList();
    }
  }
}
