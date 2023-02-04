/// Export MIME types that Google Workspace documents map to
///
/// [Official Documentation](https://developers.google.com/drive/api/guides/ref-export-formats)
abstract class DocumentExportMIMETypes {
  /// Microsoft Word `.docx` file
  static final msWord =
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document";

  /// OpenDocument `.odt` word processing file
  static final opendoc = "application/vnd.oasis.opendocument.text";

  /// Rich text `.rtf` file
  static final richText = "application/rtf";

  /// PDF `.pdf` file
  static final pdf = "application/pdf";

  /// Plain text `.txt` file
  static final plainText = "text/plain";

  /// HTML web page in a `.zip` file
  static final webPage = "application/zip";

  /// EPUB `.epub` file
  static final epub = "application/epub+zip";
}

/// Export MIME types that Google Workspace spreadsheets map to
///
/// [Official Documentation](https://developers.google.com/drive/api/guides/ref-export-formats)
abstract class SpreadsheetExportMIMETypes {
  /// Microsoft Excel `.xlsx` file
  static final excel =
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

  /// OpenDocument `.ods` spreadsheet file
  static final opendoc = "application/x-vnd.oasis.opendocument.spreadsheet";

  /// PDF `.pdf` file
  static final pdf = "application/pdf";

  /// HTML web page in a `.zip` file
  static final webPage = "application/zip";

  /// Comma Separated Values `.csv` file
  ///
  /// Only exports the first sheet
  static final csv = "text/csv";

  /// Tab Separated Values `.tsv` file
  ///
  /// Only exports the first sheet
  static final tsv = "text/tab-separated-values";
}

/// Export MIME types that Google Workspace presentations map to
///
/// [Official Documentation](https://developers.google.com/drive/api/guides/ref-export-formats)
abstract class PresentationExportMIMETypes {
  /// Microsoft Powerpoint `.pptx` file
  static final powerpoint =
      "application/vnd.openxmlformats-officedocument.presentationml.presentation";

  //// OpenDocument `.odp` presentation file
  static final opendoc = "application/vnd.oasis.opendocument.presentation";

  /// PDF `.pdf` file
  static final pdf = "application/pdf";

  /// Plain text `.txt` file
  static final plainText = "text/plain";

  /// JPEG `.jpg` image
  ///
  /// Only exports the first slide
  static final jpeg = "image/jpeg";

  /// PNG `.png` image
  ///
  /// Only exports the first slide
  static final png = "image/png";

  /// Scalable Vector Graphics `.svg` image
  ///
  /// Only exports the first slide
  static final svg = "image/svg+xml";
}

/// Export MIME types that Google Workspace drawings map to
///
/// [Official Documentation](https://developers.google.com/drive/api/guides/ref-export-formats)
abstract class DrawingExportMIMETypes {
  /// PDF `.pdf` file
  static final pdf = "application/pdf";

  /// JPEG `.jpg` image
  static final jpeg = "image/jpeg";

  /// Portable Network Graphics `.png` image
  static final png = "image/png";

  /// Scalable Vector Graphics `.svg` image
  static final svg = "image/svg+xml";
}

/// Export MIME types that Google Apps Script scripts map to
///
/// [Official Documentation](https://developers.google.com/drive/api/guides/ref-export-formats)
abstract class AppsScriptExportMIMETypes {
  /// JavaScript Object Notation `.json` file
  static final json = "application/vnd.google-apps.script+json";
}
