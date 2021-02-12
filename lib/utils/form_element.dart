import 'package:flutter/material.dart';
import 'package:pack_oph/models/oph.dart';
import 'package:pack_oph/utils/form_service.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:pack_oph/models/preset.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:pack_oph/utils/camera_service.dart';
//import 'package:image_picker/image_picker.dart';
import 'dart:io';
//import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:pack_oph/utils/imageFolder.dart';
import 'package:pack_oph/utils/map_service.dart';

import 'map_service.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';

//import './aspectCamera.dart';
//
class FormEl {
  VoidCallback _callback;
  //VoidCallback _errorback;
  String _msg = '';
  File _image;
  Preset preset;
  //image_picker
  //PickedFile _imageFile;
  //dynamic _pickImageError;
  //final ImagePicker _picker = ImagePicker();

  Future<void> init(VoidCallback callback, Preset preset
      //VoidCallback errorback,
      ) async {
    _callback = callback;
    //_errorback = errorback;
  }

  Widget textBox(FrmField f,
      {VoidCallback onChanged,
      bool isExpandable = false,
      Widget
          suffixIcon}) //, String fieldName, String titleName, TextEditingController controller) {
  {
    return Padding(
      padding: EdgeInsets.only(left: 0, right: 0),
      child: TextField(
        //initialValue: value,
        controller: f.controller,
        minLines: null,
        maxLines: null,
        decoration: InputDecoration(
            hintText: f.caption != '' ? f.caption : f.fieldName,
            labelText: f.caption != '' ? f.caption : f.fieldName,
            fillColor: preset.color2,
            suffixIcon: suffixIcon
            //focusedBorder: OutlineInputBorder(),
            ),
        expands: isExpandable,
      ),
    );
  }

  //image Folder
  Future<String> getImageFile(context, VoidCallback onChanged) async {
    String ret =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageFolderPage(this.preset);
    }));
    if (ret != null) {
      _image = File(ret);
      if (onChanged != null) onChanged();
    }
    return ret;
  }

  //camera
  Future<String> getImage(
      context, //ImgSource source,
      VoidCallback onChanged) async {
    String ret =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CamService();
    }));
    if (ret != null) {
      _image = File(ret);
      if (onChanged != null) onChanged();
    }
    return ret;
    /*
    var image = await ImagePickerGC.pickImage(
        context: context,
        source: source,
        cameraIcon: Icon(
          Icons.camera_alt,
          color: Colors.red,
        ), //cameraIcon and galleryIcon can change. If no icon provided default icon will be present
        cameraText: Text(
          "From Camera",
          style: TextStyle(color: Colors.red),
        ),
        galleryText: Text(
          "From Gallery",
          style: TextStyle(color: Colors.blue),
        ));
    _image = image;
    onChange();
    //setState(() {
    //});
    */
  }

  /*
  //image_picker
  Future<String> _onImageButtonPressed(ImageSource source,
      {BuildContext context,
      double maxWidth: 600,
      double maxHeight: 1000,
      int quality,
      VoidCallback onChanged}) async {
    //if (_controller != null) {
    //await _controller.setVolume(0.0);
    //}
    //if (isVideo) {
    //final PickedFile file = await _picker.getVideo(
    //  source: source, maxDuration: const Duration(seconds: 10));
    //await _playVideo(file);
    //} else {
    //await _displayPickImageDialog(context,
    //  (double maxWidth, double maxHeight, int quality) async {
    String fp = '';
    try {
      final pickedFile = await _picker.getImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );

      //setState(() {
      //print(pickedFile);
      _imageFile = pickedFile;
      _image = File(pickedFile.path);
      fp = _imageFile.path;
      if (onChanged!=null ) onChanged();
      //});
    } catch (e) {
      //setState(() {
      _pickImageError = e;
      //});
    }
    //});
    //}
    return fp;
  }
*/
  Widget profileBox(BuildContext context, FrmField f, double scrw, double scrh,
      {VoidCallback
          onChanged}) //, String fieldName, String titleName, TextEditingController controller) {
  {
    Image curImg;
    if (_image == null)
      curImg = Image.network(
        preset.serverURL +
            preset.rootAccountId +
            '/' +
            preset.documentURL +
            preset.rootAccountId +
            f.value,
        width: scrw,
        height: scrh,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace stackTrace) {
          return Image.asset('assets/noimage.jpg',
              height: scrh, width: scrw, fit: BoxFit.cover);
        },
      );
    else
      curImg = Image.file(
        _image,
        width: scrw,
        height: scrh,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace stackTrace) {
          return Image.asset('assets/noimage.jpg');
        },
      );

    return Padding(
        padding: EdgeInsets.all(0),
        child: Column(children: [
          AspectRatio(aspectRatio: scrw / scrh, child: curImg),
          Row(children: [
            TextButton(
              child: Text('Take a photo'),
              onPressed: () async {
                //camera
                String fp = await getImage(
                    context, //ImgSource.Camera,
                    onChanged);
                f.imageName = fp;
                f.imageFile = File(fp);
                //= File(imageFile.path);

                /*
                 //image_picker
                String fp = await _onImageButtonPressed(ImageSource.camera,
                    context: context, onChange: () {
                  onChange();
                });
                f.imageName = fp;
                f.imageFile = File(fp);
                */
              },
            ),
            TextButton(
              child: Text('Get from Gallery'),
              onPressed: () async {
                String fp = await getImageFile(
                    context, //ImgSource.Gallery,
                    onChanged);
                f.imageName = fp;
                if (fp != null) f.imageFile = File(fp);

                /*
                //image_picker
                String fp = await _onImageButtonPressed(ImageSource.gallery,
                    context: context, onChange: () {
                  f.imageFile = File(_imageFile.path);
                  onChange();
                });
                f.imageName = fp;
                f.imageFile = File(fp);
                */
              },
            )
          ]),
        ]));
  }

  Widget switchBox(BuildContext context, FrmField f,
      {VoidCallback
          onChanged}) //String fieldName, String titleName, TextEditingController controller) {
  {
    bool val = f.controller?.text == '1';
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Switch(
              activeColor: preset.color1,
              value: val,
              onChanged: (i) {
                f.controller?.text = i ? '1' : '0';
                _callback();
              },
            ),
            Text(f.caption),
          ],
        ));
  }

  Widget chooseBox(
      BuildContext context, String code, FrmField f, FormService appForm,
      {VoidCallback
          onChanged}) //String fieldName, String titleName, TextEditingController controller)
  {
    if (f.value != '') {
      String combovalue = appForm.view(f.combovalue);
      //String wf1val = appForm.view(f.autosuggestBoxPar.wf1);
      //String wf2val = appForm.view(f.autosuggestBoxPar.wf2);

      //appForm
      //  .autosuggest(f.fieldName, dv: f.value, wf1: wf1val, wf2: wf2val)
      //  .then((dv) {
      //print(dv);
      if (f.controller.text == '' || f.controller.text == null)
        f.controller.text = combovalue;
      //f.controller.text = dv[0]['text'];
      //});
    }
    return Padding(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: f.controller,
              decoration: InputDecoration(
                hintText: f.caption,
                labelText: f.caption,
                fillColor: preset.color2,
                //border: OutlineInputBorder()
              )),
          suggestionsCallback: (pattern) async {
            String wf1val = appForm.view(f.autosuggestBoxPar.wf1);
            String wf2val = appForm.view(f.autosuggestBoxPar.wf2);
            var r = await appForm.autosuggest(f.fieldName,
                q: pattern, wf1: wf1val, wf2: wf2val);
            return r;
          },
          itemBuilder: (context, Map suggestion) {
            return ListTile(
              title: Text(suggestion['text']),
            );
          },
          onSuggestionSelected: (Map suggestion) {
            f.controller.text = suggestion['text'];
            f.value = suggestion['id'];
            if (onChanged != null) onChanged();
            _callback();
          },
        ));
  }

  Widget passwordBox(FrmField f,
      {VoidCallback
          onSubmitted}) //, String fieldName, String titleName, TextEditingController controller) {
  {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 0),
        child: TextField(
          //initialValue: value,
          obscureText: true,
          obscuringCharacter: '*',
          controller: f.controller,
          decoration: InputDecoration(
            hintText: f.caption != '' ? f.caption : f.fieldName,
            labelText: f.caption != '' ? f.caption : f.fieldName,
            fillColor: preset.color2,
            //focusedBorder: OutlineInputBorder(),
          ),
        ));
  }

  Widget tokenBox(String code, FrmField f, FormService appForm) {
    List<Map<String, dynamic>> d = [];
    if (f.value != '')
      f.value.split('*').forEach((x) {
        String wf1val = appForm.view(f.autosuggestBoxPar.wf1);
        String wf2val = appForm.view(f.autosuggestBoxPar.wf2);

        appForm
            .autosuggest(f.fieldName, dv: x, wf1: wf1val, wf2: wf2val)
            .then((dv) {
          print(dv);
          d.addAll(dv);
        });
      });

    return ChipsInput(
      initialValue: d,
      decoration: InputDecoration(
        labelText: f.caption,
      ),
      maxChips: 3,
      findSuggestions: (String query) async {
        String wf1val = appForm.view(f.autosuggestBoxPar.wf1);
        String wf2val = appForm.view(f.autosuggestBoxPar.wf2);

        var r = await appForm.autosuggest(f.fieldName,
            q: query, wf1: wf1val, wf2: wf2val);

        if (query.length != 0) {
          var lowercaseQuery = query.toLowerCase();
          return r.where((rx) {
            return rx['text'].toLowerCase().contains(query.toLowerCase());
          }).toList(growable: false)
            ..sort((a, b) => a['text']
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b['text'].toLowerCase().indexOf(lowercaseQuery)));
        } else {
          return const <Map<String, dynamic>>[];
        }
      },
      onChanged: (data) {
        print(data);
      },
      chipBuilder: (context, state, d) {
        return InputChip(
          key: ObjectKey(d),
          label: Text((d as Map)['text']),
          //avatar: CircleAvatar(
          //    backgroundImage: NetworkImage(Icons.access_alarms),
          //),
          onDeleted: () => state.deleteChip(d),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
      suggestionBuilder: (context, state, d) {
        return ListTile(
          key: ObjectKey(d),
          //leading: CircleAvatar(
          //    backgroundImage: NetworkImage(profile.imageUrl),
          //),
          title: Text((d as Map)['text']),
          //subtitle: Text(profile.email),
          onTap: () => state.selectSuggestion(d),
        );
      },
    );
  }

  Widget statusHead(String title, {double fontSize}) {
    return Padding(
        padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20),
        child: Container(
            //height: 150,
            child: Text(
          title,
          style: TextStyle(fontSize: fontSize, color: preset.color2),
        )));
  }

  Widget statusText(String title,
      {Widget icon,
      Function() onClick,
      String subtitle,
      bool titleBold: false,
      @required double width}) {
    List<Widget> w = [];
    List<Widget> w2 = [];
    if (title != '')
      w2.add(Text(
        title ?? '',
        style: TextStyle(
            fontSize: 14,
            fontWeight: titleBold ? FontWeight.bold : FontWeight.normal),
      ));

    if (subtitle != null && subtitle != '')
      w2.add(Text(
        subtitle,
        maxLines: 3,
        style: TextStyle(fontSize: 11),
      ));
    w.add(
      Expanded(
          flex: 3,
          child: Container(
              //width: (width - 40) * (icon != null ? 0.75 : 1),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: w2))),
      //subtitle: subtitle != null ? Text(subtitle) : null,
    );
    if (icon != null)
      w.add(Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.topRight,
            //width: (width - 40) * 0.45,
            child: InkWell(child: icon, onTap: onClick),
          )));
    //w.add(Text(subtitle, style: TextStyle(fontSize: 12)));
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: 40.0,
              minWidth: 200.0,
            ),
            //
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: w)));
  }

  Widget setGPSBox(BuildContext context, FrmField f, {Function onChanged}) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          //textBox(f, isExpandable: false),
          ElevatedButton(
              child: Text(f.controller.text == null || f.controller.text == ''
                  ? 'Set location'
                  : 'Location is pinned. Click for new one.'),
              onPressed: () async {
                List<String> ret = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return MapxPage(f, 'Choose Location', this.preset);
                }));
                if (ret != null && ret.length > 0) {
                  f.controller.text = ret[1];
                  //setState(() {});
                  //addressField.controller.text = ret[1];
                  if (onChanged != null) onChanged();
                }
                //return ret;
              })
        ]));
  }

  Future<void> inputDialog(
      BuildContext context, String title, FormService frmsvc,
      {int pageno, int sectionno}) async {
    List<Widget> w = [];
    if (frmsvc
            .curForm()
            .fields
            .where((f) => f.pageNo == pageno || f.sectionNo == sectionno)
            .toList()
            .length >
        0) {
      frmsvc
          .curForm()
          .fields
          .where((f) => f.pageNo == pageno || f.sectionNo == sectionno)
          .toList()
          .forEach((f) {
        w.add(Padding(
            padding: EdgeInsets.only(left: 20, right: 20), child: textBox(f)));
      });
    }
    w.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.pop(context, true);
            },
          )
        ],
      ),
    );
    await showDialog<void>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(title),
            children: w,
          );
        });
  }

  String error() {
    return _msg;
  }
}
