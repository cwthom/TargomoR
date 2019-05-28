This example demonstrates how to use the polygons functions of the `TargomoR` package:

* `addTargomoPolygons()`  -  this queries the Targomo API and adds the returned polygons to the map.
* `targomoOptions()` - this allows you to specify different options, like:
  + `travelType` - "walk", "bike", "car", "transit"
  + `strokeWidth` - how defined the shapes are
  + `inverse` - whether to invert the shapes
  + `travelTimes` - the different time bands to use
  + `intersectionMode` - whether to find the 'union' or 'intersection' of multiple sources
