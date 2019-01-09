LeafletWidget.methods.addTargomoRoutes = function(api_key) {

  (function() {

    // get the map
    var map = this;

    // define a route layer
    var routeLayer = L.featureGroup().addTo(map);

    // To Do: Define sources and targets and add them to the travelOptions

    // define a set of travel options for the polygons
    var travelOptions = r360.travelOptions();

    travelOptions.setServiceKey(api_key);
    travelOptions.setServiceUrl("https://api.targomo.com/britishisles/");

    // query the API
    r360.RouteService.getRoutes(travelOptions, function(routes){
      r360.LeafletUtil.fadeIn(routeLayer, route, 1000, "travelDistance");
    });

  }).call(this);

};
