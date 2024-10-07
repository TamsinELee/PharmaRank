library(shiny)
library(shinydashboard)
library(dplyr)
library(reshape2)
library(ggplot2)
library(plotly)
library(shinyWidgets)
library(gridExtra)
library(data.table)
library(DT) # to show data table https://shiny.rstudio.com/articles/datatables.html
library(grid) # for text at same location annotation_custom(grob)
### PLot ON MAP
# https://stackoverflow.com/questions/11225343/how-to-create-a-world-map-in-r-with-specific-countries-filled-in

#setwd("C:/Users/LENOVO/Documents/jobs_2024/Roche")
## app.R ##
data               <- read.csv("DF_tech2.csv")

ui <- fluidPage(
  
  h2("3,189 pharmacies ranked according to user selected definitions of `Best`"),
    fixedRow(
    column(12,
           wellPanel(
             fixedRow(
               column(4, 
                      tags$h4(tags$b("Define `Best` by selecting the weight (significance) of five different components.")),
                      sliderInput("Tier",           # input ID
                                  "Select a weighting for the Importance of the pharamacy (Tier):",  # label
                                  min = 0,            # minimum value
                                  max = 100,          # maximum value
                                  value = 20),
                      sliderInput("Potential",           # input ID
                                 "Select a weighting for the Total Sales of the Pharmacy (Potential):",  # label
                                 min = 0,            # minimum value
                                 max = 100,          # maximum value
                                 value = 20),         # initial/default value
                      sliderInput("Adoption",           # input ID
                                 "Select a weighting for the level of engagement with the pharmacy (Adoption):",  # label
                                 min = 0,            # minimum value
                                 max = 100,          # maximum value
                                 value = 20),        # initial/default value
                      sliderInput("DiffInteraction",           # input ID
                                 "Select a weighting for the Past interaction performance (Actual - Planned):",  # label
                                 min = 0,            # minimum value
                                 max = 100,          # maximum value
                                 value = 20),         # initial/default value
                      sliderInput("Total",           # input ID
                                 "Select a weighting for the Past orders (orders in $):",  # label
                                 min = 0,            # minimum value
                                 max = 100,          # maximum value
                                 value = 20) ,        # initial/default value),
                      tags$h4(tags$b("Filter data by Province.")),
                      h5(pickerInput(inputId  = "Province",
                                     label    = "Provinces to include (out of 11)",
                                     choices  = sort(unique(data$Province)),
                                     options  = list(`actions-box` = TRUE),
                                     multiple = TRUE,
                                     selected = unique(data$Province))),
                      # h5(pickerInput(inputId  = "Town",
                      #                label    = "Towns to include (out of 1185)",
                      #                choices  = sort(unique(data$Town)),
                      #                options  = list(`actions-box` = TRUE),
                      #                multiple = TRUE,
                      #                selected = unique(data$Town))),
                      tags$h4(tags$b("Summarising the filtered data.")),
                      column(6, plotOutput("plotTier", height= 200),
                                plotOutput("plotAdoption", height= 200)),
                      column(6, plotOutput("plotDiffInteraction", height= 200),
                                plotOutput("plotPotential", height= 200)),
                      plotOutput("plotTotal", height= 200),
                      
               ),
               column(8, DT::dataTableOutput("table")),
               downloadButton("downloadData", "Download to csv")
           ), #close fixed row
    ), # close well panel
    )
  ) # close fixedRow
) # close fluidPage


server <- function(input, output, session) {
  
  get.data1 = reactive({
    # Vector of input values
    vec <- c(input$Tier, input$Potential, input$Adoption, input$DiffInteraction, input$Total)
    
    if ((max(vec) - min(vec)==0)){
      vec <- vec
    } else {
      # Scale the vector to 0-1
      vec <- (vec - min(vec)) / (max(vec) - min(vec))
    }
    data$Score <- (vec[1] * data$Tier_norm) + 
      (vec[2] * data$Potential_norm) + 
      (vec[3] * data$Adoption_norm) + 
      (vec[4] * data$DiffInteraction_norm) + 
      (vec[5] * data$Total_norm)
    
    # Sort the dataframe by the 'Score' column
    DF <- data[order(data$Score, decreasing = TRUE), ]
    

     DF$Rank <- seq(1, nrow(DF), by = 1)
     
      DFF <- DF %>% dplyr::select(Rank, 
                                  Score,
                                  Customer.Code,
      Customer.Name,
      Province,
     # Town,
      ZipCode,
      Tier,
      Potential,
      Adoption,
      Planned.Interaction,
      Actual.Interaction, 
      DiffInteraction,
      Total
      )
      
      DFF <- DFF %>% dplyr::filter(Province %in% input$Province)
      #DFF <- DFF %>% dplyr::filter(Town %in% input$Town)
      
      colnames(DFF) <- c("Rank", "Score",
                            "Customer Code",
                            "Customer Name",
                            "Province", 
                            #"Town", 
                            "ZipCode", "Tier",
                            "Potential",
                            "Adoption",
                            "Planned Interaction",
                            "Actual Interaction",
                            "Actual - Planned",
                            "Total_orders ($)"
                            )
      
      DFF$Score <- round(DFF$Score, 3)
    data <- DFF
    
  })
  
  output$plotTier = renderPlot({
    
    #obtain the reactive data
    data = get.data1()
    ggplot(data, aes(y = 100*(..count..)/sum(..count..), x = Tier)) +
      geom_bar(color = "black", fill ="#0070C0") +
      scale_y_continuous(name = "%") + 
      theme_bw(base_size = 16)
  })

  output$plotPotential = renderPlot({
    
    #obtain the reactive data
    data = get.data1()
    data$Potential <- factor(data$Potential, levels=c('H', 'M', 'L'))
    ggplot(data, aes(y = 100*(..count..)/sum(..count..), x = Potential)) +
      geom_bar(color = "black", fill ="#0070C0") +
      scale_y_continuous(name = "%") + 
      theme_bw(base_size = 16)
  })
  
  output$plotAdoption= renderPlot({
    
    #obtain the reactive data
    data = get.data1()
    ggplot(data, aes(y = 100*(..count..)/sum(..count..), x = Adoption)) +
      geom_bar(color = "black", fill ="#0070C0") +
      scale_y_continuous(name = "%") + 
      theme_bw(base_size = 16)
  })

  output$plotDiffInteraction= renderPlot({
    
    #obtain the reactive data
    data = get.data1()
    ggplot(data, aes(y = 100*(..count..)/sum(..count..), x = `Actual - Planned`)) +
      geom_bar(color = "black", fill ="#0070C0") +
      scale_y_continuous(name = "%") + 
      theme_bw(base_size = 16)
  })
  
  output$plotTotal= renderPlot({
    
    #obtain the reactive data
    data = get.data1()
    data$`Total_orders ($)` <- 0.01 * data$`Total_orders ($)`
    ggplot(data, aes(y = 100*(..count..)/sum(..count..),  x = `Total_orders ($)`)) +
      geom_histogram(color = "black", fill ="#0070C0") +
      scale_x_continuous(name = "Total_orders (in 100$)") + 
      scale_y_continuous(name = "%") + 
      theme_bw(base_size = 16)
  })
  

  
  output$table <- DT::renderDataTable({
    table1            = get.data1()
    DT::datatable(table1, options = list(pageLength = 25))
  })

output$downloadTSData = downloadHandler(
  filename = function() {
    paste("data_", Sys.Date(), ".csv", sep="")
  },
  content = function(file) {
    table1         = get.data1()
    #table1 <- table1[c(1:10), ]
    write.csv(table1, file, row.names = FALSE)
  })

}

shinyApp(ui, server)
