This example demonstrates how to use the routes functions of the `TargomoR` package:

* `addTargomoRoutes()`  -  this queries the Targomo API and adds the returned routes to the map.
* `targomoOptions()` - this allows you to specify different API options, like:
  + `travelType` - "walk", "bike", "car", or "transit" (public transport).
  + `carRushHour` - whether to account for rush hour in car travel
  + `transitMaxTransfers` - how many times are you prepared to change transport
* `routeDrawOptions()` - this allows you to change how the routes are shown on the map.
  + `{walk/car/bike/transit}Colour` - set the colour of different lines
  + `{walk/car/bike/transit}Weight` - set the weight of different lines
  + `showTransfers` - whether to mark the transfer points
