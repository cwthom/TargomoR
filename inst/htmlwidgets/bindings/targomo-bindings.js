/* global LeafletWidget, L, r360 */

LeafletWidget.methods.addTargomoPolygons = function(api_key, lng, lat, options) {

  (function() {

    // get the map
    var map = this;

    // create a layer for the polygons
    var polygonLayer = r360.leafletPolygonLayer().addTo(map);

    // hack in extra methods which r360.leafletPolygonLayer() seems to lack
    polygonLayer.remove = function() {
      return this;
    };
    polygonLayer.fire = function(method) {
      return this;
    };

    // create a source
    var source = L.marker(([lat, lng]));

    // define a set of travel options for the polygons
    var travelOptions = r360.travelOptions();

    travelOptions.setServiceKey(api_key);
    travelOptions.setServiceUrl('https://api.targomo.com/britishisles/');
    travelOptions.addSource(source);
    travelOptions.setTravelTimes(options.times);
    travelOptions.setTravelType(options.transport);

    // set the strokewidth
    polygonLayer.setStrokeWidth(options.stroke);
    polygonLayer.setInverse(options.invert);

    // query the API
    r360.PolygonService.getTravelTimePolygons(travelOptions, function(polygons){
      polygonLayer.clearAndAddLayers(polygons, true);
    });

    // add polygons to map
    // map.layerManager.addLayer(polygonLayer, 'multiPolygon');

  }).call(this);

};
