##install.packages("leaflet")
##install.packages("sp")
##install.packages("sf")
##install.packages("RColorBrewer")
##install.packages("leaflet.extras")
##install.packages("leaflet.minicharts")
##install.packages("htmlwidgets")
##install.packages("raster")
##install.packages("mapview")
##install.packages("leafem")
##install.packages("leafpop")
##install.packages("htmltools")

## Call the libraries
library(leaflet)
library(sp)
library(sf)
library(RColorBrewer)
library(leaflet.extras)
library(leaflet.minicharts)
library(htmlwidgets)
library(raster)
library(mapview)
library(leafem)
library(leafpop)
library(htmltools)

## PART 1 - IN THIS PART THE CODE READS THE FILES AND ATTRIBUTES COLORS AND ICONS TO ELEMENTS

## Read the shapefile
countries <- st_read('data/shp/countries/countries-polygon.shp')

## Create the palette of colors for the shapefiles
palette_countries <- colorNumeric(palette = "YlOrRd", domain = countries$number)

## Read the csv
data <- read.csv("data/csv/pizzamap.csv")
## Create a html popup
content <- paste(sep = "<br/>",
                        paste0("<div class='leaflet-popup-scrolled' style='max-width:200px;max-height:200px'>"),
                        paste0("<b>", data$name, "</b>", " in ", data$city, " (", data$country, ")"),
                        paste0("They have ","<b>", data$pizzas, "</b>", " pizzas", " and ", "<b>", data$places_circa, "</b>", " places"),
                        paste0(data$image),
                        paste0("<small>", "Takeaway: ", "<b>", data$take_away, "</b>", "</small>"),
                        paste0("</div>"))
## Create the palette of colors
palette_data <- colorNumeric("YlGn", data$price_euro_average)

## Create an image through the use of a link
url <- "http://miam-images.m.i.pic.centerblog.net/o/b0cb1d85.png"
## url <- data$url
pizza_icon <-  makeIcon(url, url, 40, 40)


## PART 2 - IN THIS PART THE CODE ADDS ELEMENT ON THE MAP LIKE POLYGONS, POINTS AND IMAGES.

map <- leaflet() %>%
  ## Basemap
  ##addTiles(tile)        %>%
  addProviderTiles(providers$CartoDB.Positron)  %>%
  
  ## Add a zoom reset button
  addResetMapButton() %>%
  ## Add a Minimap to better navigate the map
  addMiniMap() %>%
  ## Add a coordinates reader
  leafem::addMouseCoordinates() %>%
  ## define the view
  setView(lng = 60.27444399596726, 
          lat = 27.808314896631217, 
          zoom = 2 ) %>%
  
  ## Add the polygons of the shapefiles
  addPolygons(data = countries,
              fillColor = ~palette_countries(countries$number),
              weight = 0.1,
              color = "brown",
              dashArray = "3",
              opacity = 0.7,
              stroke = TRUE,
              fillOpacity = 0.5,
              smoothFactor = 0.5,
              group = "Countries",
              label = ~paste("In", COUNTRY, "there are", number, " pizzerias", sep = " "),
              highlightOptions = highlightOptions(
                weight = 0.6,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE))%>%
              
  ## Add a legend with the occurrences of the toponyms according to the macro areas
  addLegend("bottomleft", 
            pal = palette_countries, 
            values = countries$number,
            title = "Pizzerias by country:",
            labFormat = labelFormat(suffix = " pizzerias"),
            opacity = 1,
            group = "Countries") %>%
  
  ## Add Markers with clustering options
  addAwesomeMarkers(data = data, 
                    lng = ~lng,
                    lat = ~lat, 
                    popup = c(content), 
                    group = "Pizzerias",
                    options = popupOptions(maxWidth = 100, maxHeight = 150), 
                    clusterOptions = markerClusterOptions())%>%
  
  ## Add Circles with quatitative options
  addCircleMarkers(data = data, 
                   lng = data$lng,
                   lat = data$lat,
                   fillColor = ~palette_data(price_euro_average),
                   color = "black",
                   weight = 1,
                   radius = ~sqrt(data$price_euro_average) * 3,
                   stroke = TRUE,
                   fillOpacity = 0.5,
                   group = "By price",
                   label = ~paste("In the pizzeria ", data$name, 
                                  " pizza costs approximately ",
                                  data$price_euro_average, 
                                  " euros")) %>%
  
  ## Add a legend with the occurrences of the toponyms according to the macro areas
  addLegend("bottomleft", 
            pal = palette_data, 
            values = data$price_euro_average,
            title = "Pizzerias ordered by prices:",
            labFormat = labelFormat(suffix = " euros"),
            opacity = 1,
            group = "By price") %>%
  
## Add Markers with special icons
  addMarkers(data = data,
             lng = ~lng, 
             lat = ~lat, 
             icon = pizza_icon,
             group = "Pizza Marker",
             popup = ~paste0(name)) %>%
  
  ## Add a legend with the credits
  addLegend("topright", 
            
            colors = c("trasparent"),
            labels=c("Giovanni Pietro Vitali - giovannipietrovitali@gmail.com"),
            
            title="Pizza Map (Learn R to make maps): ") %>%
  
 
  ## PART 3 - IN THIS PART THE CODE MANAGE THE LAYERS' SELECTOR
  
  ## Add the layer selector which allows you to navigate the possibilities offered by this map
  
  addLayersControl(baseGroups = c("Pizzerias",
                                  "Empty layer"),
                   
                   overlayGroups = c("Countries",
                                     "By price",
                                     "Pizza Marker"),
                   
                   options = layersControlOptions(collapsed = TRUE)) %>%
  
  ## Hide the layers that the users can choose as they like
  hideGroup(c("Empty",
              "Countries",
              "By price",
              "Pizza Marker"))

## Show the map  
map

