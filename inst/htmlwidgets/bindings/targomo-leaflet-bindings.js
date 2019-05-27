/* global LeafletWidget, L, tgm */

LeafletWidget.methods.addTargomoPolygons = function(api_key, lat, lng, options, fitBounds) {

  async function addPolygons() {

    // get the map
    var map = this;

    // create targomo client
    const client = new tgm.TargomoClient('britishisles', api_key);

    // set options
    options = {
      travelType: options.travelType,
      travelEdgeWeights: options.travelTimes,
      strokeWidth: options.strokeWidth,
      inverse: options.inverse,
      edgeWeight: 'time',
      srid: 4326,
      serializer: 'json'
    };

    // define the polygon overlay
    const polygonOverlayLayer = new tgm.leaflet.TgmLeafletPolygonOverlay(
      {
        strokeWidth: options.strokeWidth,
        inverse: options.inverse
      }
    );
    polygonOverlayLayer.addTo(map);

    // define the starting points
    var sources = [{ id: 0, lat: lat, lng: lng }];

    // get the polygons
    const polygons = await client.polygons.fetch(sources, options);

    // calculate bounding box for polygons
    const bounds = polygons.getMaxBounds();

    // add polygons to overlay
    polygonOverlayLayer.setData(polygons);

    // zoom to the polygon bounds
    if (fitBounds) {
      map.fitBounds(new L.latLngBounds(bounds.northEast, bounds.southWest));
    }

  }

  addPolygons.call(this);

};
