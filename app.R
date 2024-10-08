# Load required libraries
library(shiny)          # Core Shiny library for building interactive web apps
library(shinydashboard) # For dashboard layout
library(dplyr)          # Data manipulation library
library(reshape2)       # For reshaping data between wide and long formats
library(ggplot2)        # For data visualization
library(plotly)         # For interactive plots
library(shinyWidgets)   # Enhances UI components for Shiny
library(gridExtra)      # Provides grid functions for arranging multiple plots
library(data.table)     # Efficient data manipulation
library(DT)             # For displaying data tables in the UI (https://shiny.rstudio.com/articles/datatables.html)
library(grid)           # For graphical annotations (e.g., annotation_custom)

## app.R ##
data <- read.csv("DF_tech2.csv")  # Load the dataset

# Define the user interface (UI) layout using fluidPage
ui <- fluidPage(
  
  h2("3,185 pharmacies ranked according to user selected definitions of `Best`"), # Main header
  h5("Code available on https://github.com/TamsinELee/PharmaRank"),
  fixedRow(  # Layout rows in a fixed position
    column(12,
           wellPanel(
             fixedRow(  # Layout inner rows for input selection and plots
               column(4,  # First column: input sliders and data filters
                      tags$h4(tags$b("Define `Best` by selecting the weight (significance) of five different components.")),
                      # Slider for weighting 'Tier'
                      sliderInput("Tier",           # input ID
                                  "Select a weighting for the Importance of the pharamacy (Tier):",  # label
                                  min = 0,            # minimum value
                                  max = 100,          # maximum value
                                  value = 20),        # Default value
                      # Slider for weighting 'Potential'
                      sliderInput("Potential",           # input ID
                                 "Select a weighting for the Total Sales of the Pharmacy (Potential):",  # label
                                 min = 0,            # minimum value
                                 max = 100,          # maximum value
                                 value = 20),        # initial/default value
                      # Slider for weighting 'Adoption'
                      sliderInput("Adoption",           # input ID
                                 "Select a weighting for the level of engagement with the pharmacy (Adoption):",  # label
                                 min = 0,            # minimum value
                                 max = 100,          # maximum value
                                 value = 20),        # initial/default value
                      # Slider for weighting 'DiffInteraction' (difference between actual and planned interactions)
                      sliderInput("DiffInteraction",           # input ID
                                 "Select a weighting for the Past interaction performance (Actual - Planned):",  # label
                                 min = 0,            # minimum value
                                 max = 100,          # maximum value
                                 value = 20),         # initial/default value
                      # Slider for weighting 'Total' (past orders in $)
                      sliderInput("Total",           # input ID
                                 "Select a weighting for the Past orders (orders in $):",  # label
                                 min = 0,            # minimum value
                                 max = 100,          # maximum value
                                 value = 20) ,        # initial/default value),
                      # Filter data by province
                      tags$h4(tags$b("Filter data by Province.")),
                      h5(pickerInput(inputId  = "Province",
                                     label    = "Provinces to include (out of 11)",
                                     choices  = sort(unique(data$Province)), # Populate choices from data
                                     options  = list(`actions-box` = TRUE),
                                     multiple = TRUE,
                                     selected = unique(data$Province))),
                      # h5(pickerInput(inputId  = "Town",
                      #                label    = "Towns to include (out of 1185)",
                      #                choices  = sort(unique(data$Town)),
                      #                options  = list(`actions-box` = TRUE),
                      #                multiple = TRUE,
                      #                selected = unique(data$Town))),
                      # Display data summaries
                      tags$h4(tags$b("Summarising the filtered data.")),
                      # Plot for 'Tier' and 'Adoption'
                      column(6, plotOutput("plotTier", height= 200),
                                plotOutput("plotAdoption", height= 200)),
                      # Plot for 'DiffInteraction' and 'Potential'
                      column(6, plotOutput("plotDiffInteraction", height= 200),
                                plotOutput("plotPotential", height= 200)),
                      # Plot for 'Total'
                      plotOutput("plotTotal", height= 200),
               ),
               # Data table output in the second column
               column(8, DT::dataTableOutput("table")),
               # Download button for the data
               downloadButton("downloadData", "Download to csv")
           ), #close fixed row
    ), # close well panel
    )
  ) # close fixedRow
) # close fluidPage

# Define the server logic that creates plots and calculations based on user inputs
server <- function(input, output, session) {
  # Reactive expression to generate data based on user input
  get.data1 = reactive({
    # Vector of input values (weights from the sliders)
    vec <- c(input$Tier, input$Potential, input$Adoption, input$DiffInteraction, input$Total)
    # Check if all slider values are the same (prevent division by zero)
    if ((max(vec) - min(vec)==0)){
      vec <- vec
    } else {
      # Scale the vector values between 0 and 1
      vec <- (vec - min(vec)) / (max(vec) - min(vec))
    }
    # Calculate a weighted score for each pharmacy based on user-selected weights
    data$Score <- (vec[1] * data$Tier_norm) + 
      (vec[2] * data$Potential_norm) + 
      (vec[3] * data$Adoption_norm) + 
      (vec[4] * data$DiffInteraction_norm) + 
      (vec[5] * data$Total_norm)
    
    # Sort the data based on the calculated 'Score'
    DF <- data[order(data$Score, decreasing = TRUE), ]
    
    # Assign rank to each row
    DF$Rank <- seq(1, nrow(DF), by = 1)
     
    # Select and filter the relevant columns for display
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
    # Filter data based on the selected province
    DFF <- DFF %>% dplyr::filter(Province %in% input$Province)
      #DFF <- DFF %>% dplyr::filter(Town %in% input$Town)
    # Rename columns for better readability in the output table
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
      # Round the 'Score' column to 3 decimal places for neater visuals
      DFF$Score <- round(DFF$Score, 3)
      # Return the filtered and formatted data
      data <- DFF
    
  })
  
  # Generate a bar plot for 'Tier' distribution
  output$plotTier = renderPlot({
    #obtain the reactive data
    data = get.data1()
    ggplot(data, aes(y = 100*(after_stat(count))/sum(after_stat(count)), x = Tier)) +
      geom_bar(color = "black", fill ="#0070C0") +
      scale_y_continuous(name = "%") + 
      theme_bw(base_size = 16)
  })

  # Generate a bar plot for 'Potential' distribution
  output$plotPotential = renderPlot({
    #obtain the reactive data
    data = get.data1()
    data$Potential <- factor(data$Potential, levels=c('H', 'M', 'L'))
    ggplot(data, aes(y = 100*(after_stat(count))/sum(after_stat(count)), x = Potential)) +
      geom_bar(color = "black", fill ="#0070C0") +
      scale_y_continuous(name = "%") + 
      theme_bw(base_size = 16)
  })
  
  # Generate a bar plot for 'Adoption' distribution
  output$plotAdoption= renderPlot({
    #obtain the reactive data
    data = get.data1()
    ggplot(data, aes(y = 100*(after_stat(count))/sum(after_stat(count)), x = Adoption)) +
      geom_bar(color = "black", fill ="#0070C0") +
      scale_y_continuous(name = "%") + 
      theme_bw(base_size = 16)
  })

  # Generate a bar plot for 'DiffInteraction' distribution
  output$plotDiffInteraction = renderPlot({
    #obtain the reactive data
    data = get.data1()
    ggplot(data, aes(y = 100*(after_stat(count))/sum(after_stat(count)), x = `Actual - Planned`)) +
      geom_bar(color = "black", fill ="#0070C0") +
      scale_y_continuous(name = "%") + 
      theme_bw(base_size = 16)
  })
  
  # Generate a bar plot for 'Total' distribution
  output$plotTotal= renderPlot({
    #obtain the reactive data
    data = get.data1()
    data$`Total_orders ($)` <- 0.01 * data$`Total_orders ($)`
    ggplot(data, aes(y = 100*(after_stat(count))/sum(after_stat(count)),  x = `Total_orders ($)`)) +
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
