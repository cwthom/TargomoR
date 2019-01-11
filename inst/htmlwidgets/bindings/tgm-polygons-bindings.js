LeafletWidget.methods.addTargomoPolygons = function(api_key, lng, lat, times, transport, stroke) {

  (function() {

    // get the map
    var map = this;
    console.log(map);

    // create a layer for the polygons
    var polygonLayer = r360.leafletPolygonLayer().addTo(map);

    // create a source
    var source = L.marker(([lat, lng]));

    // define a set of travel options for the polygons
    var travelOptions = r360.travelOptions();

    travelOptions.setServiceKey(api_key);
    travelOptions.setServiceUrl("https://api.targomo.com/britishisles/");
    travelOptions.addSource(source);
    travelOptions.setTravelTimes(times);
    travelOptions.setTravelType(transport);

    // set the strokewidth
    polygonLayer.setStrokeWidth(stroke);

    // query the API
    r360.PolygonService.getTravelTimePolygons(travelOptions, function(polygons){
      polygonLayer.clearAndAddLayers(polygons, true);

    });

  }).call(this);

};
