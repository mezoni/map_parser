part of parser;

/* WebAppParser uses Mezoni Parser to parse data */
class WebAppParser {
  MezoniParser _parser;
  bool hasErrors = false;
  List<String> errors = [];

  WebApp parse(Map map) {
    errors = [];
    hasErrors = false;
    var webapp = new WebApp();
    _parser = new MezoniParser(_getFormat());
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

  void servlet_mapping(String key, String value, Map<String, ServletMapping> parent) {
    parent[key] = new ServletMapping(value);
  }

  void servlet_class(String key, String clazz, Servlet parent) {
    parent.clazz = clazz;
  }

  void servlet_name(String key, String name, Servlet parent) {
    parent.name = name;
  }

  Taglib taglib(String key, dynamic value, WebApp parent) {
    parent.taglib = new Taglib();
    return parent.taglib;
  }

  void taglib_location(String key, String location, Taglib parent) {
    parent.location = location;
  }

  void taglib_uri(String key, String uri, Taglib parent) {
    parent.uri = uri;
  }

  WebApp web_app(String key, dynamic value, dynamic parent) {
    return parent;
  }
}
