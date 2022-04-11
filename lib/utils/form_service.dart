import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import 'package:oph_core/oph_core.dart';
//import 'package:pack_oph/models/form.dart';
import 'dart:convert';
import 'package:oph_core/models/oph.dart';
import 'package:path/path.dart';
//import 'package:async/async.dart';
import 'package:oph_core/utils/http_service.dart';
import 'package:oph_core/utils/browse_service.dart';

const timeout = 20;

HttpService httpSvc = HttpService();

class FormService {
  String _msg = '';
  String _unique = '';
  Frm _frm;
  String _code;
  //String _guid;
  VoidCallback _callback;
  VoidCallback _errorback;
  bool isInit = false;
  //String formError() => _msg;
  String formGUID() => _frm.guid;
  String formUnique() => _unique;
  Frm curForm() => _frm;
  // browse
  //Future<void> newForm() async {
  //await loadForm(guid: '00000000-0000-0000-0000-000000000000');
  //}
  Future<void> newForm() async {
    _frm.guid = '00000000-0000-0000-0000-000000000000';
    await loadForm();
  }

  Future<void> loadForm() async {
    //_guid = guid;

    _frm.fields = [];
    _frm.pages = [];
    if (_frm.code != '') {
      await httpSvc.loadAccount(_code, hostguid: Oph.curPreset.hostguid);
      if (Oph.curPreset.hostguid != null &&
          Oph.curPreset.hostguid != '' &&
          Oph.curPreset.isLogin) {
        String url = Oph.curPreset.serverURL +
            //Oph.curPreset.rootAccountId +
            '/' +
            Oph.curPreset.apiURL +
            '?suba=' +
            Oph.curPreset.accountId +
            '&mode=form&code=' +
            _frm.code +
            '&guid=' +
            _frm.guid;
        _frm.isLoaded = false;
        var body = {'hostguid': Oph.curPreset.hostguid};
        _frm.isLoaded = false;
        String value = await httpSvc.getXML(url, body: body);
        if (value != null && value != '') {
          XmlDocument xmlDoc = XmlDocument.parse(value);
          //_msg = xmlDoc.findAllElements('message');
          List<XmlElement> mx = xmlDoc.findAllElements("message").toList();
          if (mx.length == 0) {
            List<FrmPage> fp = [];
            List<XmlElement> px = xmlDoc.findAllElements("formPage").toList();
            for (XmlElement p in px) {
              List<FrmSection> fs = [];
              List<XmlElement> sx = p.findAllElements("formSection").toList();
              int fpno = int.parse(p.getAttribute("pageNo"));
              for (XmlElement s in sx) {
                List<FrmCol> fc = [];
                List<XmlElement> cx = s.findAllElements("formCol").toList();
                int fsno = int.parse(s.getAttribute("sectionNo"));
                for (XmlElement c in cx) {
                  List<FrmRow> fr = [];
                  List<XmlElement> rx = c.findAllElements("formRow").toList();
                  int fcno = int.parse(c.getAttribute("colNo"));
                  for (XmlElement r in rx) {
                    List<FrmField> ff = [];
                    List<XmlElement> fx = r.findAllElements("field").toList();
                    for (XmlElement f in fx) {
                      int no = 0;
                      String fieldName = f.getAttribute("fieldName").toString();
                      int isEditable =
                          int.parse((f.getAttribute("isEditable") ?? '0'));
                      bool isNullable =
                          (f.getAttribute("isNullable") ?? '1').toString() ==
                                  '0'
                              ? false
                              : true;
                      int primaryCol =
                          int.parse((f.getAttribute("mandatory") ?? '0'));
                      int maxLength =
                          int.parse((f.getAttribute("rows") ?? '0'));
                      String boxType = 'hiddenBox';
                      String value, caption, wf1, wf2, combovalue;
                      AutosuggestBoxPar autosuggestBoxPar;
                      List<XmlElement> tBox =
                          f.findAllElements("textBox").toList();
                      if (tBox.length > 0) //textbox
                      {
                        boxType = 'textBox';
                        value =
                            tBox[0].findAllElements("value").toList().length ==
                                    0
                                ? ''
                                : tBox[0].findAllElements("value").first.text;
                        caption = tBox[0]
                                    .findAllElements("titlecaption")
                                    .toList()
                                    .length ==
                                0
                            ? ''
                            : tBox[0]
                                .findAllElements("titlecaption")
                                .first
                                .text;
                      } else {
                        List<XmlElement> asBox =
                            f.findAllElements("autoSuggestBox").toList();
                        if (asBox.length > 0) {
                          String comboCode =
                              asBox[0].getAttribute("comboCode").toString();
                          int allowAdd = int.parse(
                              asBox[0].getAttribute("allowAdd").toString());
                          int allowEdit = int.parse(
                              asBox[0].getAttribute("allowEdit").toString());
                          wf1 =
                              asBox[0].findAllElements("wf1").toList().length >
                                      0
                                  ? asBox[0].findAllElements("wf1").first.text
                                  : '';
                          wf2 =
                              asBox[0].findAllElements("wf2").toList().length >
                                      0
                                  ? asBox[0].findAllElements("wf2").first.text
                                  : '';
                          value = asBox[0]
                                      .findAllElements("value")
                                      .toList()
                                      .length ==
                                  0
                              ? ''
                              : asBox[0].findAllElements("value").first.text;
                          combovalue = asBox[0]
                                      .findAllElements("combovalue")
                                      .toList()
                                      .length ==
                                  0
                              ? ''
                              : asBox[0]
                                  .findAllElements("combovalue")
                                  .first
                                  .text;
                          caption = asBox[0]
                              .findAllElements("titlecaption")
                              .first
                              .text;
                          boxType = 'autosuggestBox';
                          autosuggestBoxPar = AutosuggestBoxPar(
                              code: comboCode,
                              isAllowAdd: allowAdd,
                              isAllowEdit: allowEdit,
                              wf1: wf1,
                              wf2: wf2);

                          autosuggestBoxPar.list = [];
                        } else {
                          List<XmlElement> chBox =
                              f.findAllElements("checkBox").toList();
                          if (chBox.length > 0) {
                            boxType = 'checkBox';
                            caption = chBox[0]
                                .findAllElements("titlecaption")
                                .first
                                .text;
                            value = chBox[0]
                                        .findAllElements("value")
                                        .toList()
                                        .length ==
                                    0
                                ? '0'
                                : chBox[0].findAllElements("value").first.text;
                          } else {
                            List<XmlElement> pBox =
                                f.findAllElements("profileBox").toList();
                            if (pBox.length > 0) {
                              boxType = 'profileBox';
                              caption = pBox[0]
                                  .findAllElements("titlecaption")
                                  .first
                                  .text;
                              value = pBox[0]
                                          .findAllElements("value")
                                          .toList()
                                          .length ==
                                      0
                                  ? ''
                                  : pBox[0].findAllElements("value").first.text;
                            } else {
                              List<XmlElement> sgpsBox =
                                  f.findAllElements("setGPSBox").toList();
                              if (sgpsBox.length > 0) //textbox
                              {
                                boxType = 'setGPSBox';
                                caption = sgpsBox[0]
                                    .findAllElements("titlecaption")
                                    .first
                                    .text;
                                value = sgpsBox[0]
                                            .findAllElements("value")
                                            .toList()
                                            .length ==
                                        0
                                    ? ''
                                    : sgpsBox[0]
                                        .findAllElements("value")
                                        .first
                                        .text;
                              }
                            }
                          }
                        }
                      }
                      ff.add(FrmField(
                          no: no,
                          fieldName: fieldName,
                          isEditable: isEditable,
                          isNullable: isNullable,
                          primaryCol: primaryCol,
                          value: value,
                          combovalue: combovalue,
                          caption: caption,
                          boxType: boxType,
                          maxLength: maxLength,
                          pageNo: fpno,
                          sectionNo: fsno,
                          autosuggestBoxPar: autosuggestBoxPar));
                    }
                    int frno = int.parse(r.getAttribute("rowNo"));
                    fr.add(FrmRow(no: frno, fields: ff));
                  }
                  fc.add(FrmCol(no: fcno, rows: fr));
                }
                String fstitle = s.getAttribute("sectionTitle");
                fs.add(FrmSection(no: fsno, title: fstitle, cols: fc));
              }
              String fptitle = p.getAttribute("pageTitle");
              fp.add(FrmPage(no: fpno, title: fptitle, sections: fs));
            }

            //_frm.guid = guid;
            _frm.pages = fp;
            List<XmlElement> ff = xmlDoc.findAllElements("form").toList();
            List<XmlElement> ffi = ff[0].findAllElements("info").toList();
            String docno = ffi[0].findAllElements("docNo").toList().length > 0
                ? ffi[0].findAllElements("docNo").toList()[0].text
                : '';
            _frm.docNo = docno;
            String docRefNo =
                ffi[0].findAllElements("docRefNo").toList().length > 0
                    ? ffi[0].findAllElements("docRefNo").toList()[0].text
                    : '';
            _frm.docRefNo = docRefNo;

            List<XmlElement> fip = ff[0].findAllElements("permission").toList();
            int allowBrowse = int.parse(
                fip[0].findAllElements("allowBrowse").toList().length > 0
                    ? fip[0].findAllElements("allowBrowse").toList()[0].text
                    : '0');
            int allowAdd = int.parse(
                fip[0].findAllElements("allowAdd").toList().length > 0
                    ? fip[0].findAllElements("allowAdd").toList()[0].text
                    : '0');
            int allowEdit = int.parse(
                fip[0].findAllElements("allowEdit").toList().length > 0
                    ? fip[0].findAllElements("allowEdit").toList()[0].text
                    : '0');
            int allowDelete = int.parse(
                fip[0].findAllElements("allowDelete").toList().length > 0
                    ? fip[0].findAllElements("allowDelete").toList()[0].text
                    : '0');
            _frm.permission = Permission(
                allowAdd: allowAdd,
                allowBrowse: allowBrowse,
                allowDelete: allowDelete,
                allowEdit: allowEdit);
            if (_frm != null && _frm.pages != null) {
              _frm.fields.clear();
              _frm.pages.forEach((p) {
                p.sections.forEach((s) {
                  s.cols.forEach((c) {
                    c.rows.forEach((r) {
                      //if (_frm.fields.where((f)=>f.caption==).toList().length==0)
                      _frm.fields.addAll(r.fields);
                    });
                  });
                });
              });
              _frm.fields?.forEach((f) {
                f.controller = TextEditingController();
                if (f.boxType == 'autosuggestBox' && f.value != '')
                  autosuggest(f.fieldName, dv: f.value).then((dv) {
                    print(dv);
                    f.controller.text = dv[0]['text'];
                    if (_callback != null) _callback();
                  });
                else
                  f.controller.text =
                      f.boxType != 'autosuggestBox' ? f.value ?? '' : '';
              });
            } //else
            _frm.isLoaded = true;
            _frm.children = [];
            List<XmlElement> hx = xmlDoc.findAllElements("child").toList();
            hx.forEach((h) {
              String code = h.findAllElements("code").toList().length > 0
                  ? h.findAllElements("code").toList()[0].text.toString()
                  : '';
              String title = h.findAllElements("childTitle").toList().length > 0
                  ? h.findAllElements("childTitle").toList()[0].text.toString()
                  : '';
              String parentKey =
                  h.findAllElements("parentkey").toList().length == 0
                      ? ''
                      : h
                          .findAllElements("parentkey")
                          .toList()[0]
                          .text
                          .toString();
              int allowBrowse = int.parse(
                  h.findAllElements("allowBrowse").toList().length == 0
                      ? '0'
                      : h.findAllElements("allowBrowse").toList()[0].text);
              int allowAdd = int.parse(
                  h.findAllElements("allowAdd").toList().length == 0
                      ? '0'
                      : h.findAllElements("allowAdd").toList()[0].text);
              int allowEdit = int.parse(
                  h.findAllElements("allowEdit").toList().length == 0
                      ? '0'
                      : h.findAllElements("allowEdit").toList()[0].text);
              int allowDelete = int.parse(
                  h.findAllElements("allowDelete").toList().length == 0
                      ? '0'
                      : h.findAllElements("allowDelete").toList()[0].text);

              BrowseService childSvc =
                  BrowseService(Oph.curPreset.accountId, code, code);
              String filter = //guid == '00000000-0000-0000-0000-000000000000'
                  parentKey + '=\'' + _frm.guid + '\'';
              _frm.children.add(FrmChild(
                  code: code,
                  title: title,
                  parentKey: parentKey,
                  permission: Permission(
                      allowAdd: allowAdd,
                      allowBrowse: allowBrowse,
                      allowDelete: allowDelete,
                      allowEdit: allowEdit),
                  service: childSvc));
              childSvc.init(code, code, _callback, _errorback, f: filter);
              if (_callback != null) _callback();
            });
          } else {
            _msg = mx[0].toString();
          }
        }
      } else {
        _msg = "Unauthorized";
        print(_msg);
      }

      //} catch (e) {
      //_msg = e.message;
      //}
    }

    //return _form;
  }

  void init(String code, String guid) async {
    _code = code;
    //_guid = guid;
    _frm = Frm(
        code: '',
        guid: '00000000-0000-0000-0000-000000000000',
        children: [],
        pages: [],
        fields: []);
    _frm.code = code;
    _frm.guid = guid;
    isInit = true;
    //if (_frm != null && guid != null) {
    //await loadForm();
    //}
  }

  void setContext({VoidCallback callback, VoidCallback errorback}) {
    if (_callback != null) _callback = callback;
    if (_errorback != null) _errorback = errorback;
  }

  String view(fieldname, {int mode = 0}) {
    String r1 = '';
    if (_frm.fields.where((f) => f.fieldName == fieldname).toList().length >
            0 &&
        _frm.fields
                .where((f) => f.fieldName == fieldname)
                .toList()[0]
                .boxType ==
            'autosuggestBox' &&
        mode == 1) {
      r1 = _frm.fields
          .where((f) => f.fieldName == fieldname)
          .toList()[0]
          .combovalue;
    } else if (_frm != null &&
        _frm.fields != null &&
        _frm.fields.where((f) => f.fieldName == fieldname).length > 0)
      r1 = _frm.fields
              .firstWhere((f) => f.fieldName == fieldname, orElse: null)
              .controller
              .value
              .text ??
          _frm.fields
              .firstWhere((f) => f.fieldName == fieldname, orElse: null)
              ?.value;

    return r1;
  }

  bool dirty(fieldname) {
    bool b = false;
    if (_frm.fields.where((f) => f.fieldName == fieldname).toList().length > 0)
      b = _frm.fields
              .where((f) => f.fieldName == fieldname)
              .toList()[0]
              .controller
              .text !=
          _frm.fields.where((f) => f.fieldName == fieldname).toList()[0].value;
    return b;
  }

  bool edit(fieldname, value) {
    bool r1 = false;
    _frm.pages.forEach((p) {
      p.sections.forEach((s) {
        s.cols.forEach((c) {
          c.rows.forEach((r) {
            r.fields.forEach((f) {
              if (f.fieldName == fieldname) {
                f.value = value;
                r1 = true;
              }
            });
          });
        });
      });
    });
    if (_frm.fields.length > 0) {
      try {
        _frm.fields
            .firstWhere((f) => f.fieldName == fieldname, orElse: null)
            .controller
            ?.text = value;
      } catch (e) {}
    }
    return r1;
  }

  Future<bool> save({String parentguid, int flag = 0}) async {
    bool r = false;
    if (_code != '') {
      //await httpSvc.loadAccount(code: _code);
      if (Oph.curPreset.hostguid != null &&
          Oph.curPreset.hostguid != '' &&
          Oph.curPreset.isLogin) {
        String url = Oph.curPreset.serverURL +
            //Oph.curPreset.rootAccountId +
            '/' +
            Oph.curPreset.apiURL +
            '?suba=' +
            Oph.curPreset.accountId +
            '&mode=save&code=' +
            _code;
        var client = new http.Client();
        var request = new http.MultipartRequest('POST', Uri.parse(url));
        print(url);

        var body = {
          'hostguid': Oph.curPreset.hostguid,
          'cfunctionlist': _frm.guid,
          'cid': parentguid ?? _frm.guid,
          'mode': 'save',
          'unique': DateFormat('yyyyMMddHHmmss').format(DateTime.now())
        };
        if (_frm != null && _frm.fields != null) {
          for (FrmField f in _frm.fields) {
            if ((f.controller.text != null || f.value != null) &&
                f.boxType != 'profileBox') {
              body[f.fieldName] = f.boxType == 'autosuggestBox'
                  ? f.value
                  : (f.controller.text != null)
                      ? f.controller.text
                      : f.value;
            } else {
              File imageFile = f.imageFile;
              if (imageFile != null) {
                body[f.fieldName] = basename(imageFile.path);
                var stream = new http.ByteStream(imageFile.openRead());
                stream.cast();
                imageFile.length().then((length) {
                  var multipartFile = new http.MultipartFile(
                      'file', stream, length,
                      filename: basename(imageFile.path));
                  //contentType: new MediaType('image', 'png'));
                  request.files.add(multipartFile);
                });
              }
            }
          }
          request.fields.addAll(body);
          //request.bodyFields = body;

          try {
            var response = await client
                .send(request)
                .timeout(const Duration(seconds: timeout));
            var value = await response.stream.bytesToString();
            if (value != '') {
              XmlDocument xmlDoc = XmlDocument.parse(value);
              List<String> l1 = xmlDoc
                  .findAllElements("guid")
                  .map((node) => node.text)
                  .toList();
              List<String> l2 = xmlDoc
                  .findAllElements("message")
                  .map((node) => node.text)
                  .toList();
              List<String> l3 = xmlDoc
                  .findAllElements("unique")
                  .map((node) => node.text)
                  .toList();
              if (l1.length > 0 && l1[0].length > 0) {
                //_guid=l1[0];
                _frm.guid = l1[0];
                r = true;
                if (l3.length > 0 && l3[0].length > 0) {
                  _unique = l3[0];
                  //_frm=getForm(code:code,guid:guid);
                }
              }
              if (l2[0] != '') {
                _msg = l2[0];
                print(_msg);
              } else
                r = true;
            }
          } on SocketException catch (e) {
            _msg = "Socket Error: " + e.message;
            _errorback();
          } catch (e) {
            //_msg = e.message;
            //_errorback();
          }
        }
        //} else {
        //_msg = "Unauthorized";
        //print(_msg);
      }
    }
    return r;
  }

  void preview(int flag) async {
    save(flag: flag);
  }

  Future<bool> function(
      {@required String action,
      //String guid,
      String userid,
      String pwd,
      String comment}) async {
    bool r = false;
    //String curguid = _guid;
    if (_code != '') {
      //if (guid != null && guid != '') curguid = guid;
      var url = Oph.curPreset.serverURL +
          //Oph.curPreset.rootAccountId +
          '/' +
          Oph.curPreset.apiURL +
          '?suba=' +
          Oph.curPreset.accountId +
          '&mode=function&code=' +
          _code;

      var body = {
        'hostguid': Oph.curPreset.hostguid,
        'cfunctionlist': _frm.guid,
        'cfunction': action,
        'comment': comment != null ? comment : '',
        'approvaluserguid': userid != null ? userid : '',
        'pwd': pwd != null ? pwd : ''
      };

      String value = await httpSvc.getXML(url, body: body);
      if (value != '') {
        XmlDocument xmlDoc = XmlDocument.parse(value);
        List<String> l1 =
            xmlDoc.findAllElements("guid").map((node) => node.text).toList();
        List<String> l2 =
            xmlDoc.findAllElements("message").map((node) => node.text).toList();
        List<String> l3 =
            xmlDoc.findAllElements("unique").map((node) => node.text).toList();
        r = true;
        if ((l1.length > 0 && l1[0].length > 0) || l2.length == 0) {
          //if (guid == null || guid == '') {
          //_frm.guid = l1[0];
          //}
          r = true;
          if (l3.length > 0 && l3[0].length > 0) {
            _unique = l3[0];
          }
        } else if (l2.length > 0 && l2[0].length > 0) {
          _msg = l2[0];
          print(_msg);
        }
      }
    }
    return r;
  }

  Future<List<Map<String, dynamic>>> autosuggest(
    String colkey, {
    String dv = '',
    String combodv = '',
    String q = '',
    String wf1 = '',
    String wf2 = '',
  }) async {
    List<Map<String, dynamic>> r = [];
    if (_code != '') {
      await httpSvc.loadAccount(_code, hostguid: Oph.curPreset.hostguid);
      if (Oph.curPreset.hostguid != null &&
          Oph.curPreset.hostguid != '' &&
          Oph.curPreset.isLogin) {
        var url = Oph.curPreset.serverURL +
            //Oph.curPreset.rootAccountId +
            '/' +
            Oph.curPreset.autosuggestURL +
            '?suba=' +
            Oph.curPreset.accountId +
            '&code=' +
            _code +
            '&colkey=' +
            colkey +
            '&defaultvalue=' +
            dv +
            '&q=' +
            q +
            '&wf1value=' +
            wf1 +
            '&wf2value=' +
            wf2 +
            '&parentCode=' +
            _code; //+
        //'&hostguid=' +
        //Oph.curPreset.hostguid;

        //var client = new http.Client();
        //var request = new http.Request('GET', Uri.parse(url));

        var body = {'hostguid': Oph.curPreset.hostguid};
        /*
      //request.bodyFields = body;
      try {
        var response = await client
            .send(request)
            .timeout(const Duration(seconds: timeout));
        
        var value = await response.stream.bytesToString();
        */
        String value = await httpSvc.getXML(url, body: body);
        if (value != null && value != '') {
          var rsp = jsonDecode(value);
          var x = (rsp as Map)["results"] as List;
          x.forEach((m) {
            r.add(m);
          });
          //} catch (e) {
          //_msg = e.message;
          //}
        }
      }
    }
    return r;
  }

  String error() {
    return _msg;
  }

  String get(fieldName) {
    String r;
    if (_frm.fields.where((f) => f.fieldName == fieldName).length > 0)
      r = _frm.fields.firstWhere((f) => f.fieldName == fieldName).value;

    return r;
  }

  void set(String fieldName, dynamic newVal) {
    if (_frm != null && _frm.fields != null) {
      if (_frm.fields.where((f) => f.fieldName == fieldName).toList().length >
          0) {
        _frm.fields.firstWhere((f) => f.fieldName == fieldName).value = newVal;
        _frm.fields
            .firstWhere((f) => f.fieldName == fieldName)
            .controller
            .text = newVal;
      } else {
        TextEditingController tec = TextEditingController(text: newVal);
        _frm.fields.add(FrmField(
            no: _frm.fields.length,
            fieldName: fieldName,
            //value: newVal,
            controller: tec));
      }
    }
  }

  Frm frm() {
    return _frm;
  }

  FrmChild getChild(String code) {
    FrmChild c = _frm.children.where((c) => c.code == code).toList().length > 0
        ? _frm.children.where((c) => c.code == code).first
        : null;
    //if (c!=null && c.service.getBrowseRow())
    return c;
  }

  void dispose() {
    _frm = null;
    //_guid = null;
  }
}
