import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MaterialApp(
  home: Detect(),
  debugShowCheckedModeBanner: false,
));


// stateless widget to load main home widget
class Detect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DetectMain();
  }
}

class DetectMain extends StatefulWidget {
  // private camera object: get assigned to global one
  DetectMain();
  @override
  _DetectMainState createState() => new _DetectMainState();
}

class _DetectMainState extends State<DetectMain> {

  File _image;
  double _imageWidth;
  double _imageHeight;
  var _recognitions;
  var _pLabel;

  loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
        model: "assets/mobilenet.tflite",
        labels: "assets/labels.txt",
      );
      print(res);
    } on PlatformException {
      print("Failed to load the model");
    }
  }

  // run prediction using TFLite on given image
  Future<String> predict(File image) async {

    String pLabel;

    var recognitions = await Tflite.runModelOnImage(
        path: image.path,   // required
        imageMean: 0.0,   // defaults to 117.0
        imageStd: 255.0,  // defaults to 1.0
        numResults: 2,    // defaults to 5
        threshold: 0.2,   // defaults to 0.1
        asynch: true      // defaults to true
    );

    print(recognitions);

    setState(() {
      _recognitions = recognitions;
    });

    if(_recognitions.isNotEmpty) {
      pLabel = _recognitions[0]['label'].toString().toUpperCase();
    }

    return pLabel;

  }

  // send image to predict method selected from gallery or camera
  sendImage(File image) async {
    if(image == null) return;
    String pLabel = await predict(image);

    // get the width and height of selected image
    FileImage(image).resolve(ImageConfiguration()).addListener((ImageStreamListener((ImageInfo info, bool _){
      setState(() {
        _imageWidth = info.image.width.toDouble();
        _imageHeight = info.image.height.toDouble();
      });
    })));

    setState(() {
      _image = image;
      _pLabel = pLabel;
    });
  }

  // select image from gallery
  selectFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image == null) return;
    setState(() {

    });
    sendImage(image);
  }

  // select image from camera
  selectFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if(image == null) return;
    setState(() {

    });
    sendImage(image);
  }

  @override
  void initState() {
    super.initState();

    loadModel().then((val) {
      setState(() {});
    });
  }


  Widget printValue(rcg) {
    if (rcg == null) {
      return Text('', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700));
    }else if(rcg.isEmpty){
      return Center(
        child: Text("Could not recognize", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(0,0,0,0),
      child: Center(
        child: Text(
          "Prediction: "+_pLabel,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // gets called every time the widget need to re-render or build
  @override
  Widget build(BuildContext context) {

    // get the width and height of current screen the app is running on
    Size size = MediaQuery.of(context).size;

    // initialize two variables that will represent final width and height of the segmentation
    // and image preview on screen
    double finalW;
    double finalH;

    // when the app is first launch usually image width and height will be null
    // therefore for default value screen width and height is given
    if(_imageWidth == null && _imageHeight == null) {
      finalW = size.width;
      finalH = size.height;
    }else {

      // ratio width and ratio height will given ratio to
//      // scale up or down the preview image
      double ratioW = size.width / _imageWidth;
      double ratioH = size.height / _imageHeight;

      // final width and height after the ratio scaling is applied
      finalW = _imageWidth * ratioW*.85;
      finalH = _imageHeight * ratioH*.50;
    }

//    List<Widget> stackChildren = [];


    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Text("Flutter x TF-Lite", style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0,30,0,30),
              child: printValue(_recognitions),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0,0,0,10),
              child: _image == null ? Center(child: Text("Select image from camera or gallery"),): Center(child: Image.file(_image, fit: BoxFit.fill, width: finalW, height: finalH)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Container(
                    height: 50,
                    width: 150,
                    color: Colors.redAccent,
                    child: FlatButton.icon(
                      onPressed: selectFromCamera,
                      icon: Icon(Icons.camera_alt, color: Colors.white, size: 30,),
                      color: Colors.deepPurple,
                      label: Text(
                        "Camera",style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  ),
                ),
                Container(
                  height: 50,
                  width: 150,
                  color: Colors.tealAccent,
                  child: FlatButton.icon(
                    onPressed: selectFromGallery,
                    icon: Icon(Icons.file_upload, color: Colors.white, size: 30,),
                    color: Colors.blueAccent,
                    label: Text(
                      "Gallery",style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                ),
              ],
            ),
          ],
        )
    );
  }
}