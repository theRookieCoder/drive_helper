import 'package:flutter/material.dart';
import 'package:drive_helper/drive_helper.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() {
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  final driveHelper = DriveHelper();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        accentColor: Colors.blueAccent,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blueAccent,
        fontFamily: 'Roboto',
      ),
      home: FutureBuilder(
        future: driveHelper.signInAndInit([DriveScopes.app]),
        builder: (context, snapshot) {
          // Future done and no errors
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            return HomePage(driveHelper: driveHelper);
          }

          // Future done and erraneous
          else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "An error has occured",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(snapshot.error.toString()),
                  ),
                ],
              ),
            );
          }

          // Future not done
          else {
            return Scaffold(
              body: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  height: MediaQuery.of(context).size.width / 1.5,
                  child: CircularProgressIndicator(strokeWidth: 10),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.driveHelper}) : super(key: key);
  final DriveHelper driveHelper;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Late because cannot access `widget.driveHelper`
  late DriveHelper driveHelper;
  String fileID = "";
  TextEditingController tec = TextEditingController();

  // Runs when the widget is first displayed
  @override
  void initState() {
    super.initState();
    driveHelper = widget.driveHelper;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Drive Helper demo"),
          bottom: TabBar(tabs: [
            Tab(icon: Icon(Icons.add_to_drive)),
            Tab(icon: Icon(Icons.account_circle)),
          ]),
        ),
        body: TabBarView(children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: tec,
                  decoration: InputDecoration(labelText: "Data"),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (fileID == "") {
                    final localFileID = await driveHelper.createFile(
                      "drive_helper.csv",
                      FileMimeTypes.file,
                    );
                    setState(() => fileID = localFileID);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("File created"),
                      behavior: SnackBarBehavior.floating,
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("File already created"),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
                child: Text("Create file"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (fileID != "") {
                    await driveHelper.deleteFile(fileID);
                    setState(() {
                      fileID = "";
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("File deleted"),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
                child: Text("Delete file"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (tec.text != "" && fileID != "") {
                    await driveHelper.updateFile(fileID, tec.text);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("File updated"),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
                child: Text("Overwrite file with data"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (tec.text != "" && fileID != "") {
                    await driveHelper.appendFile(
                      fileID,
                      tec.text,
                      mime: ExportMimeTypes.csv,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("File appended"),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
                child: Text("Append data to file"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (fileID != "") {
                    String fileData =
                        await driveHelper.getData(fileID).catchError((e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.toString()),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 10),
                      ));
                    });
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("File data from GET"),
                          content: Text(fileData),
                        );
                      },
                    );
                  }
                },
                child: Text("GET file data"),
              ),
              ElevatedButton(
                onPressed: () async => await driveHelper.openFile(fileID),
                child: Text("View file"),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(fileID),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  child: driveHelper.avatar,
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.width / 2,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  driveHelper.name ?? "",
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  driveHelper.email,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await driveHelper.signOut();
                  Phoenix.rebirth(context);
                },
                child: Text("Sign out"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await driveHelper.disconnect();
                  Phoenix.rebirth(context);
                },
                child: Text("Disconnect"),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
