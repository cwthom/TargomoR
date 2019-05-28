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
      serializer: 'json',
      intersectionMode: options.intersectionMode
    };

    // define the polygon overlay
    const polygonOverlayLayer = new tgm.leaflet.TgmLeafletPolygonOverlay(
      {
        strokeWidth: options.strokeWidth,
        inverse: options.inverse
      }
    );
    polygonOverlayLayer.addTo(map);

    // if lat/lng not arrays then make them so
    if (!Array.isArray(lat)) {
      lat = [lat];
    }

    // if lat/lng not arrays then make them so
    if (!Array.isArray(lng)) {
      lng = [lng];
    }

    // define the starting points
    var sources = [];
    for (var i = 0; i < lat.length; i++) {
      sources.push({'id': i, 'lat': lat[i], 'lng': lng[i] });
    }

    // get the polygons
    const polygons = await client.polygons.fetch(sources, options);

    // add polygons to overlay
    polygonOverlayLayer.setData(polygons);

    // zoom to the polygon bounds
    if (fitBounds) {
      // calculate bounding box for polygons
      const bounds = polygons.getMaxBounds();
      map.fitBounds(new L.latLngBounds(bounds.northEast, bounds.southWest));
    }

  }

  addPolygons.call(this);

};
