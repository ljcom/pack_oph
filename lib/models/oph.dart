import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:oph_core/utils/browse_service.dart';
import 'package:oph_core/utils/form_service.dart';
import 'package:oph_core/models/preset.dart';

class BrowseList {
  List<BrowseService> service;
  VoidCallback? callback;
  VoidCallback? errorback;
  //static Preset _preset;
  BrowseList(
    this.service,
  );

  static Future<void> add(
      BrowseList list, String accountId, String name, String code,
      {String q = '',
      String f = '',
      String o = '',
      int p = 1,
      int r = 20,
      int s = 0,
      required Preset preset}) async {
    //_preset = preset;
    BrowseService brwSvc;
    if (list.service
            .where((s) => s.name == name && s.accountId == accountId)
            .toList()
            .length >
        0)
      brwSvc = list.service
          .where((s) => s.name == name && s.accountId == accountId)
          .toList()[0];
    else {
      brwSvc = BrowseService(accountId, name, code);
      list.service.add(brwSvc);
    }
    brwSvc.setContext(callback: list.callback, errorback: list.errorback);
    if (brwSvc.getHead() == null)
      await brwSvc.init(name, code, list.callback, list.errorback,
          q: q, f: f, o: o, p: p, r: r, s: s);
    else
      await brwSvc.fetchData(q: q, f: f, o: o, p: p, r: r, s: s);
  }

  static void clear(BrowseList list) {
    list.service.clear();
    //list.service.forEach((h) async {
    //if (h.getHead() != null) h.getHead().rows = [];
    //});
  }

  static void dispose(BrowseList list) {
    //list.service.forEach((h) async {
    //h.dispose();
    //});
  }

  static BrowseService? getList(
      String accountId, String name, BrowseList list) {
    BrowseService? bs;

    if (list.service
            .where((l) => l.name == name && l.accountId == accountId)
            .toList()
            .length >
        0) {
      bs = list.service
          .where((l) => l.name == name && l.accountId == accountId)
          .toList()[0];
    }
    return bs;
  }
}

class BrowseHead {
  String? name;
  String? code;
  Map<String, BrowseRow> rows = {};
  int pg;
  int nbrows;
  String? curSearch;
  String? curFilter;
  String? curOrder;
  int curStatus = 0;
  ScrollController controller = ScrollController();
  bool isLoaded = false;
  List<Menu> menu = [];
  List<OState> state = [];
  //BrowseService brwSvc = BrowseService();
  FormService newSvc = FormService();
  //Frm _curForm;

  BrowseHead({
    this.name,
    this.code,
    required this.rows,
    this.pg = 1,
    this.nbrows = 20,
    this.curStatus = 0,
    this.isLoaded = false,
  });
}

class BrowseRow {
  //String guid;  map key
  Map<String, Field> fields = {};
  FormService? frmSvc = FormService();
  String? docStatus;

  BrowseRow({required this.fields, this.frmSvc, this.docStatus});
}

class Field {
  //String caption; //map key
  String title;
  int mandatory = 0;
  String? val;
  String? rawVal;

  Field(
      {required this.title,
      //required this.caption,
      required this.mandatory,
      this.rawVal,
      this.val});
}

class Submenu {
  String? type;
  String? desc;
  String? caption;
  String? pageURL;
  List<Submenu>? submenu = [];

  Submenu({this.type, this.desc, this.caption, this.pageURL, this.submenu});
}

class Menu {
  String menuName;
  List<Submenu> submenu = [];

  Menu({required this.menuName, required this.submenu});
}

class OState {
  String name;
  String code;
  List<OSubState>? substate = [];

  OState({required this.name, required this.code, this.substate});
}

class OSubState {
  String name;
  String code;
  int? tRecord;

  OSubState({required this.name, required this.code, this.tRecord});
}

class Frm {
  String code;
  String guid;
  String? docNo;
  String? docRefNo;
  DateTime? docDate;
  int status = 0;
  List<FrmPage>? pages = [];
  List<FrmChild>? children = [];
  List<FrmField>? fields = [];
  Permission? permission;
  bool isLoaded = false;
  Frm(
      {required this.code,
      required this.guid,
      this.pages,
      this.children,
      this.fields});
}

class FrmInfos {
  FrmInfo? info;
}

class FrmInfo {
  Map<String, String>? info;
}

class FrmPage {
  int no;
  String? title;
  List<FrmSection> sections = [];

  FrmPage({required this.no, this.title, required this.sections});
}

class FrmSection {
  int no;
  String? title;
  List<FrmCol> cols = [];

  FrmSection({required this.no, this.title, required this.cols});
}

class FrmCol {
  int no;
  String? title;
  List<FrmRow> rows = [];

  FrmCol({required this.no, this.title, required this.rows});
}

class FrmRow {
  int no;
  String? title;
  List<FrmField> fields = [];

  FrmRow({required this.no, this.title, required this.fields});
}

class FrmField {
  int no;
  String fieldName;
  int? isEditable = 0;
  bool? isNullable = false;
  int? primaryCol;
  String? value;
  String? combovalue;
  String? caption;
  String boxType = '';
  int? maxLength;
  int? pageNo;
  int? sectionNo;
  AutosuggestBoxPar? autosuggestBoxPar;
  TextEditingController? controller = TextEditingController();
  String? imageName;
  File? imageFile;

  FrmField(
      {required this.no,
      required this.fieldName,
      this.isEditable,
      this.isNullable,
      this.primaryCol,
      this.value,
      this.combovalue,
      this.caption,
      this.boxType = '',
      this.maxLength,
      this.pageNo,
      this.sectionNo,
      this.autosuggestBoxPar,
      this.controller});
}

class AutosuggestBoxPar {
  String code;
  String? caption;
  int isAllowAdd = 0;
  int isAllowEdit = 0;
  String? wf1, wf2;
  List<Map<String, dynamic>> list = [];

  AutosuggestBoxPar(
      {required this.code,
      this.caption,
      required this.isAllowAdd,
      required this.isAllowEdit,
      this.wf1,
      this.wf2});
}

class FrmChild {
  String code;
  String? title;
  String? parentKey;
  String? browseMode;
  int? pageNo;
  int? sectionNo;
  Permission? permission;
  BrowseService? service;
  //BrowseHead head;

  FrmChild(
      {required this.code,
      this.title,
      this.parentKey,
      this.browseMode,
      this.pageNo,
      this.sectionNo,
      this.permission,
      this.service});
}

class Permission {
  int allowBrowse = 0;
  int allowAdd = 0;
  int allowEdit = 0;
  int allowDelete = 0;

  Permission(
      {required this.allowBrowse,
      required this.allowAdd,
      required this.allowEdit,
      required this.allowDelete});
}
