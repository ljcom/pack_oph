import 'package:flutter/material.dart';
import 'package:oph_core/utils/google_service.dart';
import 'oph.dart';
//import '../global.dart' as g;
import '../utils/auth_service.dart';

class Preset {
  String msg;
  String hostguid;
  String userguid;
  String accountId;
  bool isLogin;
  Map<String, String> curState = {};
  BrowseList dataList;
  String serverURL; // = 'https://app02.operahouse.systems/';
  String indexURL; // = 'index.aspx';
  String apiURL; // = 'ophcore/api/default.aspx';
  String autosuggestURL; // = 'ophcore/api/msg_autosuggest.aspx';
  String reportURL; // = 'ophcore/api/msg_reportdialog.aspx';
  String documentURL; // = 'ophcontent/documents/';
  String rootAccountId; // = 'nebberhub';
  String apiKey; // = 'AIzaSyCQWTJDmSyQH3J5mtAR7fsUZxDp0Usqf3M';
  Color color1;
  Color color2;
  Color color3;
  Color color4;
  double imgRatio;
  AuthService appAuth;
  GoogleService gService;
  String gToken;

  //String msg() => _msg;
  //String hostguid() => _hostguid;
  //String accountId() => _accountId;
  //bool isLogin() => _isLogin;
  //Map<String, String> getCurState() => _curState;
  //BrowseList dataList() => _dataList;

  static void setServer(
    Preset preset, {
    String serverURL, // = 'https://app02.operahouse.systems/';
    String indexURL, // = 'index.aspx';
    String apiURL, // = 'ophcore/api/default.aspx';
    String autosuggestURL, // = 'ophcore/api/msg_autosuggest.aspx';
    String reportURL, // = 'ophcore/api/msg_reportdialog.aspx';
    String documentURL, // = 'ophcontent/documents/';
    String rootAccountId, // = 'nebberhub';
    String apiKey,
    //String accountId,
    //String userid,
    //String pwd
  } // = 'nebberhub';
      ) {
    preset.serverURL = serverURL; // = 'https://app02.operahouse.systems/';
    preset.indexURL = indexURL; // = 'index.aspx';
    preset.apiURL = apiURL; // = 'ophcore/api/default.aspx';
    preset.autosuggestURL =
        autosuggestURL; // = 'ophcore/api/msg_autosuggest.aspx';
    preset.reportURL = reportURL; // = 'ophcore/api/msg_reportdialog.aspx';
    preset.documentURL = documentURL; // = 'ophcontent/documents/';
    preset.rootAccountId = rootAccountId; // = 'nebberhub';
    preset.apiKey = apiKey; //'AIzaSyCQWTJDmSyQH3J5mtAR7fsUZxDp0Usqf3M';
    preset.accountId = rootAccountId;
    //g.accountId = accountId; // = 'nebberhub';
    //g.userid = userid; // = '';
    //g.pwd = pwd; // = '';
  }

  static setColor(Preset preset,
      {Color color1,
      Color color2,
      Color color3,
      Color color4,
      double imgRatio}) {
    //g.appTitle = preset.appTitle; // = 'NEBBERHUB';
    //g.gToken = preset.gToken; // = '';
    //g.hostguid = preset.hostguid; // = '';
    //g.isLogin = preset.isLogin; // = false;
    //g.curState = preset.curState;

    preset.color1 = color1;
    preset.color2 = color2;
    preset.color3 = color3;
    preset.color4 = color4;
    preset.imgRatio = imgRatio;
  }
}
