/* global LeafletWidget, L, tgm */

async function callPolygonService(api_key, region, sources, options) {

  // create targomo client
  let client = new tgm.TargomoClient(region, api_key);

  // define the polygon overlay
  let layer = new tgm.leaflet.TgmLeafletPolygonOverlay({
        strokeWidth: options.strokeWidth,
        inverse: options.inverse
  });

  // get the polygons
  let targomoData = await client.polygons.fetch(sources, options);

  // set the data to the layer
  layer.setData(targomoData);

  // return the layer
  return layer;

}

LeafletWidget.methods.addTargomoPolygons = function(api_key, region, sources, layerId, group, options, popup, popupOptions, label, labelOptions) {

  // encapsulate data for layer in a DataFrame
  let df = new LeafletWidget.DataFrame()
    .col('sources', sources)
    .col('layerId', layerId)
    .col('group', group)
    .col('popup', popup)
    .col('popupOptions', popupOptions)
    .col('label', label)
    .col('labelOptions', labelOptions)
    .cbind(options);

  // add the layers
  LeafletWidget.methods.addGenericLayers(this, 'shape', df, function(df, i) {

    let api_key = df.get(i, 'api_key');
    let region  = df.get(i, 'region');
    let sources = df.get(i, 'sources');
    let options = df.get(i);

    return callPolygonService(api_key, region, sources, options);

  }).call(this);

};
