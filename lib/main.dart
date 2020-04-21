import 'package:flutter/material.dart';
import 'package:imagepickerapp/image_caption_preview.dart';
import 'dart:async';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(home: new HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    bool status = await checkPermissionState();
    if (status == true) {
      ImagesAndCaption imageCaption =
          await getImagesWithCaption(context, multiple: true);
      print(imageCaption);
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Center(child: Text('Error: $_error')),
          RaisedButton(
            child: Text("Pick images"),
            onPressed: loadAssets,
          ),
          Expanded(
            child: buildGridView(),
          )
        ],
      ),
    );
  }

  Future<bool> checkPermissionState() async {
    if (_status == PermissionStatus.granted &&
        _status2 == PermissionStatus.granted) {
      return true;
    } else {
      return await _askPermission();
    }
  }

  Future<bool> _askPermission() async {
    var status = await PermissionHandler().requestPermissions([
      PermissionGroup.camera,
      PermissionGroup.microphone,
      PermissionGroup.storage,
    ]);

    return await _onStatusRequested(status);
  }

  Future<bool> _onStatusRequested(
      Map<PermissionGroup, PermissionStatus> statuses) async {
    if (statuses[PermissionGroup.camera] != PermissionStatus.granted &&
        statuses[PermissionGroup.microphone] != PermissionStatus.granted &&
        statuses[PermissionGroup.storage] != PermissionStatus.granted) {
      PermissionHandler().openAppSettings();
      return false;
    } else {
      _updateStatus(statuses[PermissionGroup.camera]);
      _updateStatus2(statuses[PermissionGroup.microphone]);
      return true;
    }
  }

  PermissionStatus _status;

  void _updateStatus(PermissionStatus status) {
    if (status != _status) {
      setState(() {
        _status = status;
      });
    }
  }

  PermissionStatus _status2;
  void _updateStatus2(PermissionStatus status) {
    if (status != _status2) {
      setState(() {
        _status2 = status;
      });
    }
  }
}
