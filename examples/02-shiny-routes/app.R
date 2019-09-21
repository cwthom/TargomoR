library(shiny)
library(leaflet)
library(colourpicker)
library(TargomoR)

ui <- fluidPage(

  titlePanel("TargomoR Demo 02"),

  sidebarLayout(

    sidebarPanel(
      checkboxGroupInput("travelType", "Mode(s) of Transport",
                         choices = c("Walking" = "walk",
                                     "Cycling" = "bike",
                                     "Car" = "car",
                                     "Public Transport" = "transit"),
                         selected = "bike"),
      hr(),
      strong("Speeds"),
      sliderInput("bikeSpeed", "Bike", min = 5, max = 30, step = 5, value = 15, post = "kph"),
      sliderInput("walkSpeed", "Walk", min = 1, max = 10, step = 1, value = 5, post = "kph"),
      hr(),

      strong("Colours"),
      fluidRow(
        column(width = 6,
              colourInput("walkColour", "Walk", "forestgreen"),
              colourInput("bikeColour", "Bike", "orange")
        ),
        column(width= 6,
               colourInput("carColour", "Car", "blue"),
               colourInput("transitColour", "Transit", "red")
        )
      ),
      hr(),
      strong("Other"),
      checkboxInput("showTransfers", "Show Transfers?", value = TRUE)

    ),
    mainPanel(
      leafletOutput("map")
    )
  )
)

server <- function(input, output, session) {

  basemap <- leaflet(options = leaflet::leafletOptions(zoomSnap = 0.5)) %>%
    addProviderTiles("CartoDB.Positron")

  source_data <- data.frame(lat = 51.5267, lng = -0.1925)
  target_data <- data.frame(lat = 51.512, lng = -0.11)

  routes <- reactive({

    getTargomoRoutes(source_data = source_data, target_data = target_data,
                     options = targomoOptions(travelType = input$travelType,
                                              bikeSpeed = input$bikeSpeed,
                                              walkSpeed = input$walkSpeed,
                                              maxEdgeWeight = "1h"))
  })

  output$map <- renderLeaflet({
    map <- basemap %>%
      drawRoutes(routes = routes(),
                 drawOptions = routeDrawOptions(showTransfers = input$showTransfers,
                                                walkColour = input$walkColour,
                                                bikeColour = input$bikeColour,
                                                carColour = input$carColour,
                                                transitColour = input$transitColour),
                 group = "Routes"
      ) %>%
      addLayersControl(overlayGroups = c("Routes"),
                       position = "topleft",
                       options = layersControlOptions(collapsed = FALSE))
    return(map)
  })

}

shinyApp(ui, server)
