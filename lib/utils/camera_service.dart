import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:pack_oph/utils/imageProcessor.dart';

class CamService extends StatefulWidget {
  @override
  _CamServiceState createState() => _CamServiceState();
}

class _CamServiceState extends State<CamService> {
  CameraController controller;
  List<CameraDescription> cameras = [];

  bool isCameraReady = false;
  bool showCapturedPhoto = false;
  String imagePath;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _initializeCamera();
  }

  void back(String result) async {
    if (result != '' && result != null) {
      String croppedFile =
          await ImageProcessor.cropImg(result, flip: false, ratioWH: 1.5);
      if (croppedFile != '') Navigator.pop(context, croppedFile);
    } else
      Navigator.pop(context, '');
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      isCameraReady = true;
    });
  }

/*
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (controller != null)
        _initializeControllerFuture = controller.initialize();
      //: null; //on pause camera is disposed, so we need to call again "issue is only for android"
    }
  }
*/
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    //final deviceRatio = size.width / (size.height);
    return Scaffold(
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      showCapturedPhoto
          ? AspectRatio(
              aspectRatio: 1.5,
              child: ClipRect(
                child: Transform.scale(
                  scale: 1.5 / controller.value.aspectRatio,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: imagePath == null
                          ? Center(
                              child: Text('Loading...',
                                  style: TextStyle(fontSize: 10.0)))
                          : Image.file(File(imagePath), fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
            )
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  //controller.value.aspectRatio = 1;
                  //controller.
                  return AspectRatio(
                    aspectRatio: 1.5,
                    child: ClipRect(
                      child: Transform.scale(
                        scale: 1.5 / controller.value.aspectRatio,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: CameraPreview(controller),
                          ),
                        ),
                      ),
                    ),
                  );

                  /*return Padding(
                    padding: EdgeInsets.all(10),
                    child: AspectRatio(
                      aspectRatio: deviceRatio,
                      child: CameraPreview(controller), //cameraPreview
                    ),
                  );*/
                } else {
                  return Center(
                      child:
                          CircularProgressIndicator()); // Otherwise, display a loading indicator.
                }
              },
            ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          showCapturedPhoto
              ? TextButton(
                  child: Text('Try Again'),
                  onPressed: () {
                    setState(() {
                      showCapturedPhoto = false;
                      imagePath = null;
                    });
                  },
                )
              : TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    back('');
                  },
                ),
          showCapturedPhoto
              ? TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    back(imagePath);
                  },
                )
              : TextButton(
                  child: Text('Take Picture'),
                  onPressed: () async {
                    try {
                      //final path = join(
                      //(await getTemporaryDirectory()).path, //Temporary path
                      //'photo_${DateTime.now()}.png',
                      //);

                      controller.takePicture().then((XFile file) {
                        if (mounted) {
                          setState(() {
                            imagePath = file.path;
                            //videoController?.dispose();
                            //videoController = null;
                          });
                          //if (file != null)
                          //showInSnackBar('Picture saved to ${file.path}');
                        }
                      });

                      //await controller.takePicture(path); //take photo

                      setState(() {
                        showCapturedPhoto = true;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                )
        ],
      )
    ]));
  }
}
