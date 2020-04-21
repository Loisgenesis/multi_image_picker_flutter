import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

Future<ImagesAndCaption> getImagesWithCaption(BuildContext context,
    {bool fromCamera = false,
    bool video = false,
    bool multiple = false}) async {
  List<Asset> files;

  try {
    File file;
    files = [];
    if (fromCamera) {
      if (video) {
        file = await ImagePicker.pickVideo(source: ImageSource.camera);
      } else {
        file = await ImagePicker.pickImage(source: ImageSource.camera);
      }
    } else {
      if (multiple) {
        try {
          files = await MultiImagePicker.pickImages(
              maxImages: 15,
              materialOptions: MaterialOptions(
                actionBarColor: "#D63D41",
                actionBarTitleColor: "#FFFFFF",
                statusBarColor: '#D63D41',
              ),
              cupertinoOptions: CupertinoOptions(
                selectionFillColor: "#D63D41",
                selectionTextColor: "#FFFFFF",
                selectionCharacter: "✓",
              ));
        } on Exception catch (e) {
          print("image pick exception: ${e.toString()}");
        }
      } else {
        if (video) {
          file = await ImagePicker.pickVideo(source: ImageSource.gallery);
        } else {
          file = await ImagePicker.pickImage(source: ImageSource.gallery);
        }
      }
    }

    if (files == null || files.isEmpty) {
      return null;
    }

    ImagesAndCaption imagesAndCaption = await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new ImageCaptionPreview(files)));

    return imagesAndCaption;
  } on Exception catch (e) {
    print("image pick exception: ${e.toString()}");
    Navigator.pop(context);
  }

}

class ImageCaptionPreview extends StatefulWidget {
  List<Asset> files;
  ImageCaptionPreview(this.files);

  @override
  _ImageCaptionPreviewState createState() => _ImageCaptionPreviewState();
}

class _ImageCaptionPreviewState extends State<ImageCaptionPreview> {
  var captionController = TextEditingController();
  var pageController = PageController();
  @override
  void dispose() {
    captionController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  AppBar(
                    brightness: Brightness.light,
                    backgroundColor: Colors.black45,
                  ),
                  Positioned.fill(
                    child: getImagePreview(widget.files),
                  ),
                  Positioned(
                      child: SafeArea(
                    child: IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context)),
                  )),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Container(
                          color: Colors.black45,
                          padding: EdgeInsets.only(
                              left: 16, right: 100, top: 8, bottom: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: captionController,
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                  decoration: InputDecoration.collapsed(
                                    hintText: "Add a caption...",
                                    hintStyle: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  Positioned(
                      bottom: 70,
                      right: 16,
                      child: FloatingActionButton(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(
                                context,
                                ImagesAndCaption()
                                  ..files = widget.files
                                  ..caption = captionController.text);
                          })),
                ],
              ),
            ),
            SizedBox(
                width: double.maxFinite,
                height: 100,
                child: ListView.builder(
                    itemCount: widget.files.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          if (selectedIndex != index) {
                            print('going...');
                            pageController.animateToPage(index,
                                duration: Duration(milliseconds: 200),
                                curve: Curves.linear);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.all(4.0),
                          width: 110,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AssetThumb(
                            asset: widget.files[index],
                            width: 110,
                            height: 110,
                          ),
                        ),
                      );
                    }))
          ],
        ));
  }

  int selectedIndex = 0;
  Widget getImagePreview(List<Asset> images) {
    if (images.length > 1) {
      return Container(
          child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: AssetThumb(
              asset: images[index],
              height: 700,
              width: MediaQuery.of(context).size.width.toInt(),
            ),
          );
        },
        itemCount: images.length,
        controller: pageController,
        onPageChanged: (i) {
          setState(() {
            selectedIndex = i;
          });
        },
      ));
    }
    return Container(
      child: AssetThumb(
        asset: images[0],
        height: 700,
        width: MediaQuery.of(context).size.width.toInt(),
      ),
    );
  }
}

class ImagesAndCaption {
  List<Asset> files = [];
  List<ByteData> byteData = [];
  String caption = "";
}
