library(shiny)
library(leaflet)

ui <- fluidPage(

  titlePanel("TargomoR Test"),

  sidebarLayout(

    sidebarPanel(
      selectInput("transport", "Mode of Transport",
                  choices = c("Walking" = "walk",
                              "Cycling" = "bike",
                              "Car" = "car",
                              "Public Transport" = "transit"),
                  selected = "bike"),
      sliderInput("stroke", "Stroke Width",
                  min = 5, max = 30, value = 20, step = 5),
      checkboxInput("invert", "Invert Polygons?")

    ),
    mainPanel(
      leafletOutput("map")
    )
  )
)

server <- function(input, output, session) {

  basemap <- leaflet() %>% addProviderTiles("CartoDB.Positron")

  output$map <- renderLeaflet({
    map <- basemap %>%
      addMarkers(lat = 55.8, lng = -3.1) %>%
      addTargomoPolygons(lat = 55.8, lng = -3.1,
                         options = targomoOptions(travelType = input$transport,
                                                  strokeWidth = input$stroke,
                                                  inverse = input$invert))
    return(map)
  })

}

shinyApp(ui, server)
