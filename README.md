# oph_core

Package for integrate OPH API to Flutter. This package support for Android and Web version.

For OPH, please check https://operahouse.dev

## Installation
	 
	//put in pubspec.yaml
	oph_core: ^0.0.1

	//put in every dart file you need:
	import 'package:oph_core/oph_core.dart';


## Example:

### Init
	Put this in main.dart:
	
	Oph.init(
        serverURL: <server name>,
        indexURL: <index path>,
        apiURL: <api path>,
        autosuggestURL: <autosuggest path>,
        reportURL: <report path>,
        documentURL: <document path>,
        rootAccountId: <root account>,
        color1: <OPH color theme 1>,
        color2: <OPH color theme 2>,
        color3: <OPH color theme 3>,
        color4: <OPH color theme 4>,
        imgRatio: <image ratio>);

### Load current preset:
	
	Preset p = Oph.curPreset;


### Login
    
	Oph.auth().setSuba(<sub account>);
    Oph.auth().setUserId(<user id>);
    Oph.auth().setPwd(<pwd>);
    bool _result = await Oph.auth().login();

### Load and retrieve data:

	Put these before you use it:

	//add to list
    Oph.addToList('<name>', '<code>', s: <state>, r: <nb rows>);

	//get datalist
	BrowseList d = Oph.getList('<name>');
    
	//reload
	await Oph.fetchData('<name>', isForced: <true/false>, q: <search keyword>);

	//get data rows
    BrowseRows r = Oph.getList('<name>').getBrowseRow();

	//get field value
	Oph.getValFromCaption(row, '<field name>')
	
