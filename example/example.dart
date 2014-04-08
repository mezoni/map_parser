import 'dart:convert';
import 'package:map_parser/map_parser.dart';

// Input data

String jsonData =
'''
{"web-app": {
  "servlet": [
    {
      "servlet-name": "cofaxCDS",
      "servlet-class": "org.cofax.cds.CDSServlet",
      "init-param": {
        "configGlossary:installationAt": "Philadelphia, PA",
        "configGlossary:adminEmail": "ksm@pobox.com",
        "configGlossary:poweredBy": "Cofax",
        "configGlossary:poweredByIcon": "/images/cofax.gif",
        "configGlossary:staticPath": "/content/static",
        "templateProcessorClass": "org.cofax.WysiwygTemplate",
        "templateLoaderClass": "org.cofax.FilesTemplateLoader",
        "templatePath": "templates",
        "templateOverridePath": "",
        "defaultListTemplate": "listTemplate.htm",
        "defaultFileTemplate": "articleTemplate.htm",
        "useJSP": false,
        "jspListTemplate": "listTemplate.jsp",
        "jspFileTemplate": "articleTemplate.jsp",
        "cachePackageTagsTrack": 200,
        "cachePackageTagsStore": 200,
        "cachePackageTagsRefresh": 60,
        "cacheTemplatesTrack": 100,
        "cacheTemplatesStore": 50,
        "cacheTemplatesRefresh": 15,
        "cachePagesTrack": 200,
        "cachePagesStore": 100,
        "cachePagesRefresh": 10,
        "cachePagesDirtyRead": 10,
        "searchEngineListTemplate": "forSearchEnginesList.htm",
        "searchEngineFileTemplate": "forSearchEngines.htm",
        "searchEngineRobotsDb": "WEB-INF/robots.db",
        "useDataStore": true,
        "dataStoreClass": "org.cofax.SqlDataStore",
        "redirectionClass": "org.cofax.SqlRedirection",
        "dataStoreName": "cofax",
        "dataStoreDriver": "com.microsoft.jdbc.sqlserver.SQLServerDriver",
        "dataStoreUrl": "jdbc:microsoft:sqlserver://LOCALHOST:1433;DatabaseName=goon",
        "dataStoreUser": "sa",
        "dataStorePassword": "dataStoreTestQuery",
        "dataStoreTestQuery": "SET NOCOUNT ON;select test='test';",
        "dataStoreLogFile": "/usr/local/tomcat/logs/datastore.log",
        "dataStoreInitConns": 10,
        "dataStoreMaxConns": 100,
        "dataStoreConnUsageLimit": 100,
        "dataStoreLogLevel": "debug",
        "maxUrlLength": 500}},
    {
      "servlet-name": "cofaxEmail",
      "servlet-class": "org.cofax.cds.EmailServlet",
      "init-param": {
      "mailHost": "mail1",
      "mailHostOverride": "mail2"}},
    {
      "servlet-name": "cofaxAdmin",
      "servlet-class": "org.cofax.cds.AdminServlet"},

    {
      "servlet-name": "fileServlet",
      "servlet-class": "org.cofax.cds.FileServlet"},
    {
      "servlet-name": "cofaxTools",
      "servlet-class": "org.cofax.cms.CofaxToolsServlet",
      "init-param": {
        "templatePath": "toolstemplates/",
        "log": 1,
        "logLocation": "/usr/local/tomcat/logs/CofaxTools.log",
        "logMaxSize": "",
        "dataLog": 1,
        "dataLogLocation": "/usr/local/tomcat/logs/dataLog.log",
        "dataLogMaxSize": "",
        "removePageCache": "/content/admin/remove?cache=pages&id=",
        "removeTemplateCache": "/content/admin/remove?cache=templates&id=",
        "fileTransferFolder": "/usr/local/tomcat/webapps/content/fileTransferFolder",
        "lookInContext": 1,
        "adminGroupID": 4,
        "betaServer": true}}],
  "servlet-mapping": {
    "cofaxCDS": "/",
    "cofaxEmail": "/cofaxutil/aemail/*",
    "cofaxAdmin": "/admin/*",
    "fileServlet": "/static/*",
    "cofaxTools": "/tools/*"},

  "taglib": {
    "taglib-uri": "cofax.tld",
    "taglib-location": "/WEB-INF/tlds/cofax.tld"}}}
''';

// Classes that represents data (output data)

class WebApp {
  List<Servlet> servlet = [];
  Map<String, ServletMapping> mappings;
  Taglib taglib;
}

class Servlet {
  String clazz;
  String name;
  Map initParams = {};
}

class ServletMapping {
  String url;
  ServletMapping(this.url);
}

class Taglib {
  String location;
  String uri;
}

// Map parser

class WebAppParser {
  MapParser _parser;
  bool hasErrors = false;
  List<String> errors = [];

  WebApp parse(Map map) {
    errors = [];
    hasErrors = false;
    var webapp = new WebApp();
    _parser = new MapParser(_getFormat());
    _parser.parse(map, webapp);
    if(_parser.errors.length > 0) {
      _parser.errors.forEach((error) {
        errors.add('Invalid section ${error} in data.');
      });

      return null;
    }

    if(hasErrors) {
      return null;
    }

    return webapp;
  }

  // Parser format

  Map<String, ParserCallback> _getFormat() {
    Map<String, ParserCallback> format =
      {'{web-app}': web_app,
       '{web-app}:[servlet]': servlets,
       '{web-app}:[servlet]:{*}': servlet,
       '{web-app}:[servlet]:{*}:{init-param}': servlet_init_params,
       '{web-app}:[servlet]:{*}:{init-param}:"*"': servlet_init_param,
       '{web-app}:[servlet]:{*}:"servlet-class"': servlet_class,
       '{web-app}:[servlet]:{*}:"servlet-name"': servlet_name,
       '{web-app}:{servlet-mapping}': servlet_mappings,
       '{web-app}:{servlet-mapping}:"*"': servlet_mapping,
       '{web-app}:{taglib}': taglib,
       '{web-app}:{taglib}:"taglib-location"': taglib_location,
       '{web-app}:{taglib}:"taglib-uri"': taglib_uri,
       };

    return format;
  }

  Servlet servlet(String key, dynamic value, List<Servlet> parent) {
    var servlet = new Servlet();
    parent.add(servlet);
    return servlet;
  }

  List<Servlet> servlets(String key, dynamic value, WebApp parent) {
    parent.servlet = [];
    return parent.servlet;
  }

  Map servlet_init_params(String key, dynamic value, Servlet parent) {
    parent.initParams = {};
    return parent.initParams;
  }

  void servlet_init_param(String key, dynamic value, Map parent) {
    parent[key] = value;
  }

  Map servlet_mappings(String key, dynamic value, WebApp parent) {
    parent.mappings = new Map<String, ServletMapping>();
    return parent.mappings;
  }

  void servlet_mapping(String key, dynamic value, Map<String, ServletMapping> parent) {
    parent[key] = new ServletMapping(value);
  }

  void servlet_class(String key, dynamic clazz, Servlet parent) {
    parent.clazz = "$clazz";
  }

  void servlet_name(String key, dynamic name, Servlet parent) {
    parent.name = "$name";
  }

  Taglib taglib(String key, dynamic value, WebApp parent) {
    parent.taglib = new Taglib();
    return parent.taglib;
  }

  void taglib_location(String key, dynamic location, Taglib parent) {
    parent.location = "$location";
  }

  void taglib_uri(String key, dynamic uri, Taglib parent) {
    parent.uri = "$uri";
  }

  WebApp web_app(String key, dynamic value, dynamic parent) {
    return parent;
  }
}

// Program
void main() {
  var parser = new WebAppParser();
  var data = JSON.decode(jsonData);
  var webapp = parser.parse(data);

  if (parser.errors.length > 0) {
    parser.errors.forEach((error) {
      print(error);
    });

    return;
  }

  var sep = '-------------------';

  print('Servlet count: ${webapp.servlet.length}');
  print(sep);

  webapp.servlet.forEach((servlet) {
    print('Servlet: ${servlet.name}');
  });
  print(sep);

  webapp.servlet.forEach((servlet) {
    print('Servlet: ${servlet.name}');
    print('Servlet params (${servlet.initParams.length})');
    servlet.initParams.keys.forEach((key) {
      print('  $key: ${servlet.initParams[key]}');
    });
    print(sep);
  });

  print('Mappings:');
  webapp.mappings.keys.forEach((key) {
    print('  $key: ${webapp.mappings[key].url}');
  });
  print(sep);
}
