import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:storage_path/storage_path.dart';
import 'package:pack_oph/models/file.dart';
import 'package:pack_oph/utils/imageProcessor.dart';
//import 'package:pack_oph/global.dart' as g;
import 'package:permission_handler/permission_handler.dart';
import '../pack_oph.dart';

class ImageFolderPage extends StatefulWidget {
  ImageFolderPage();
  //final Preset preset;
  @override
  _ImageFolderPageState createState() => _ImageFolderPageState();
}

class _ImageFolderPageState extends State<ImageFolderPage> {
  String imagePath = "";
  List<Folder> allFolders = [];
  int curFolder = -1;
  getPermission() async {
    if (await Permission.storage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    } else {
// You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[Permission.location]);
    }
  }

  @override
  void initState() {
    super.initState();
    getPath().then((l) {
      allFolders = l;
      setState(() {});
    });
    //getAudioPath();
    //getVideoPath();
    getPermission();
  }

  void back(String result) async {
    if (result != '' && result != null) {
      String croppedFile =
          await ImageProcessor.cropImg(result, flip: false, ratioWH: 1.5);
      if (croppedFile == '') croppedFile = result;
      Navigator.pop(context, croppedFile);
    }
  }

  void openFolder(Folder curFolder) async {
    String fp =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageFilePage(curFolder);
    }));
    if (fp != '') back(fp);
  }

  Future<List<Folder>> getPath() async {
    List<Folder> list = [];
    String imagespath = "";
    try {
      imagespath = await StoragePath.imagesPath;
      var response = jsonDecode(imagespath);
      //print(response);
      //var imageList = response as List;
      list = Folder.fromJson(response);

      //setState(() {
      return list;
      //imagePath = list[11].files[0];
      //});
    } on PlatformException {
      imagespath = 'Failed to get path';
    }
    return list;
  }

  Future<void> getVideoPath() async {
    String videoPath = "";
    try {
      videoPath = await StoragePath.videoPath;
      var response = jsonDecode(videoPath);
      print(response);
    } on PlatformException {
      videoPath = 'Failed to get path';
    }
    //return videoPath;
  }

  Future<void> getAudioPath() async {
    String audioPath = "";
    try {
      audioPath = await StoragePath.audioPath;
      var response = jsonDecode(audioPath);
      print(response);
    } on PlatformException {
      audioPath = 'Failed to get path';
    }
    //return audioPath;
  }

  Future<void> getFilePath() async {
    String filePath = "";
    try {
      filePath = await StoragePath.filePath;
      var response = jsonDecode(filePath);
      print(response);
    } on PlatformException {
      filePath = 'Failed to get path';
    }
    //return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: WillPopScope(
      onWillPop: () async {
        //bool ret = false;
        if (curFolder >= 0) {
          curFolder = -1;
          setState(() {});
        } else
          back('');
        return false;
      },
      child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(36.0),
              child: AppBar(
                elevation: 0,
                backgroundColor: Oph.curPreset.color2,
                title:
                    const Text('Choose Image', style: TextStyle(fontSize: 16)),
              )),
          body: allFolders.length == 0
              ? Center(child: Text('No Files Found'))
              : curFolder == -1
                  ? ListView.builder(
                      itemBuilder: (context, i) {
                        return InkWell(
                            child: ListTile(
                              title: Text(allFolders[i].folderName),
                            ),
                            onTap: () {
                              curFolder = i;
                              openFolder(allFolders[i]);
                              //setState(() {});
                            });
                      },
                      itemCount: allFolders.length,
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, i) {
                        return InkWell(
                            child: Card(
                                child: Image.file(
                              File((allFolders[curFolder].files[i].path)),
                            )),
                            onTap: () {
                              back(allFolders[curFolder].files[i].path);
                            });
                      },
                      itemCount: allFolders[curFolder].files.length,
                    )),
    ));
  }
}

class ImageFilePage extends StatefulWidget {
  ImageFilePage(this.curFolder);
  final Folder curFolder;
  @override
  _ImageFilePageState createState() => _ImageFilePageState();
}

class _ImageFilePageState extends State<ImageFilePage> {
  void back(String result) async {
    if (result != '') {
      String croppedFile =
          await ImageProcessor.cropImg(result, flip: false, ratioWH: 1.5);
      if (croppedFile == '') croppedFile = result;
      Navigator.pop(context, croppedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, i) {
          return InkWell(
              child: Card(
                  child: Image.file(
                File((widget.curFolder.files[i].path)),
              )),
              onTap: () {
                back(widget.curFolder.files[i].path);
              });
        },
        itemCount: widget.curFolder.files.length,
      ),
    ));
  }
}
