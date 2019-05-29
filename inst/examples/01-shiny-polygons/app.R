library(shiny)
library(leaflet)
library(TargomoR)

ui <- fluidPage(

  titlePanel("TargomoR Demo 01"),

  sidebarLayout(

    sidebarPanel(
      selectInput("travelType", "Mode of Transport",
                  choices = c("Walking" = "walk",
                              "Cycling" = "bike",
                              "Car" = "car",
                              "Public Transport" = "transit"),
                  selected = "bike"),
      hr(),
      selectInput("intersection", "Intersection Mode",
                  choices = c("Union" = "union",
                              "Intersection" = "intersection"),
                  selected = "union")

    ),
    mainPanel(
      leafletOutput("map")
    )
  )
)

server <- function(input, output, session) {

  basemap <- leaflet(options = leaflet::leafletOptions(zoomSnap = 0)) %>%
    addProviderTiles("CartoDB.Positron")

  lats <- c(55.9, 55.85)
  lngs <- c(-3.1, -3.15)

  output$map <- renderLeaflet({
    map <- basemap %>%
      addMarkers(lat = lats, lng = lngs, layerId = c(1, 2), group = "Markers") %>%
      addTargomoPolygons(lat = lats, lng = lngs,
                         options = targomoOptions(travelType = input$travelType,
                                                  intersectionMode = input$intersection),
                         layerId = "isochrone",
                         group = "Polygons"
      ) %>%
      addLayersControl(overlayGroups = c("Markers", "Polygons"),
                       position = "topleft",
                       options = layersControlOptions(collapsed = FALSE))
    return(map)
  })

}

shinyApp(ui, server)
