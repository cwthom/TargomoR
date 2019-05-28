/* global LeafletWidget, tgm */

async function callPolygonService(api_key, region, sources, options) {

  // create targomo client
  let client = new tgm.TargomoClient(region, api_key);

  // define the polygon overlay
  let layer = new tgm.leaflet.TgmLeafletPolygonOverlay({
    strokeWidth: options.strokeWidth,
    inverse: options.inverse
  });

  // set other options
  options = {
    travelType: options.travelType,
    travelEdgeWeights: options.travelTimes,
    edgeWeight: 'time',
    srid: 4326,
    serializer: 'json',
    intersectionMode: options.intersectionMode
  };

  // get the polygons
  let targomoData = await client.polygons.fetch(sources, options);

  // set the data to the layer
  layer.setData(targomoData);

}

LeafletWidget.methods.addTargomoPolygons = function(api_key, region, points, layerId, group, options, popup, popupOptions, label, labelOptions) {

  (function() {

    // encapsulate data for layer in a DataFrame
    let df = new LeafletWidget.DataFrame()
      .col('api_key', api_key)
      .col('region', region)
      .col('points', points)
      .col('layerId', layerId)
      .col('group', group)
      .col('popup', popup)
      .col('popupOptions', popupOptions)
      .col('label', label)
      .col('labelOptions', labelOptions)
      .col('options', options);

    // add the layers
    LeafletWidget.methods.addGenericLayers(this, 'shape', df, function(df, i) {

      let api_key = df.get(i, 'api_key');
      let region  = df.get(i, 'region');
      let points  = df.get(i, 'points');
      let options = df.get(i, 'options');

      let sources = [];
      for (let j = 0; j < Object.keys(points).length; j++) {
        let source = {'id': j, 'lat': points.lat[j], 'lng': points.lng[j]};
        sources.push(source);
      }

      return callPolygonService(api_key, region, sources, options);

    });

  }).call(this);

};
