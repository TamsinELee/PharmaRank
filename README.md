# PharmaRank
An app that ranks different pharmacies in Belgium based on different factors.

README Chat GPT generated - checked by me - a human!

# README for R Shiny Application: Pharmacy Ranking

## Overview

This R Shiny application ranks 3,189 pharmacies based on user-defined criteria for what constitutes the "best" pharmacy. Users can interactively adjust the weighting of five components to define the ranking system and filter the data by province. The app provides summary plots and a detailed data table of the rankings, with an option to download the results as a CSV file.

---

## Key Features

- **Interactive Component Weighting**: Users can adjust sliders to assign different weights to the following components:
  - **Tier**: The importance level of the pharmacy.
  - **Potential**: The total sales potential of the pharmacy.
  - **Adoption**: Engagement level with the pharmacy.
  - **Interaction Difference**: The past interaction performance (difference between actual and planned interactions).
  - **Total Orders**: The total orders (in $) made by the pharmacy.

- **Filtering**: Users can filter the data by province.
  
- **Visual Summaries**: The app provides bar plots summarizing the distribution of the selected components:
  - Tier
  - Potential
  - Adoption
  - Interaction Difference
  - Total Orders

- **Data Table**: The ranked pharmacies are displayed in a sortable, searchable table, allowing users to view detailed information.

- **Download Option**: Users can download the ranked data as a CSV file.

---

## Files in This Project

- **app.R**: Contains the user interface (UI) and server logic for the Shiny app.
- **DF_tech2.csv**: The CSV file containing the raw data for the pharmacies (should be placed in the same directory as the app).
  
---

## Requirements

This app requires R and several R packages. To install the necessary packages, run the following command in your R console:

```r
install.packages(c("shiny", "shinydashboard", "dplyr", "reshape2", "ggplot2", "plotly", "shinyWidgets", "gridExtra", "data.table", "DT", "grid"))
```

### R Packages Used

- `shiny`: Core Shiny framework for creating interactive web applications.
- `shinydashboard`: Provides dashboard layout and design features.
- `dplyr`: Data manipulation functions.
- `reshape2`: Used for reshaping data for visualization.
- `ggplot2`: For creating visualizations.
- `plotly`: For adding interactivity to `ggplot2` plots.
- `shinyWidgets`: Enhances UI elements such as input sliders and pickers.
- `gridExtra`: Allows arranging multiple plots.
- `data.table`: Efficient data manipulation functions.
- `DT`: Provides functions to display data in a dynamic, interactive table format.
- `grid`: For graphical annotations and text placement on plots.

---

## Running the App

To run the app, follow these steps:

1. **Set up your working directory**: Make sure the app files (`app.R` and `DF_tech2.csv`) are in the same directory.
2. **Start R or RStudio**: Open R or RStudio and set the working directory to the folder where your app is located.
3. **Run the app**: Use the following command to launch the Shiny app:

   ```r
   library(shiny)
   runApp('path/to/your/app')
   ```

   Replace `'path/to/your/app'` with the actual path to your app directory.

---

## How to Use the App

1. **Adjust Component Weightings**: Use the sliders on the left side to assign weightings (0–100) to the five components of the ranking system.
   
2. **Filter by Province**: Select one or more provinces from the dropdown picker to filter the results.

3. **View Summary Plots**: The summary plots update in real-time as you adjust the sliders or filter the data.

4. **View and Sort the Data Table**: The table on the right shows the ranked pharmacies. You can sort or search the table.

5. **Download the Data**: Click the **Download to csv** button to save the ranked data to a CSV file.

---

## Folder Structure

```
/project-directory
  |-- app.R                 # The Shiny app code
  |-- DF_tech2.csv           # Dataset with pharmacy information
```

---

## How It Works

- The app allows users to assign weights to different components (Tier, Potential, Adoption, etc.), which are then normalized and used to compute a **Score** for each pharmacy.
  
- The pharmacies are ranked based on this computed score, and the results are displayed in both graphical form (bar plots) and in a data table.

- The app is fully reactive, meaning that changes to any inputs (sliders, filters) will automatically update the outputs (plots and table).

---

## Customization

You can modify the app by:
- Changing the components in the sliders.
- Adjusting the filter options.
- Adding additional data or plots to further explore the rankings.

---

## Known Limitations

- The app assumes that the dataset (`DF_tech2.csv`) is formatted correctly. If the structure of the dataset changes, some elements of the app may need to be adjusted.
  
- Large datasets may result in slower performance, particularly when updating plots or rendering the table.

---

## Future Enhancements

Some potential improvements:
- Adding more filtering options (e.g., by town or zip code).
- Implementing more advanced visualization techniques.
- Providing more detailed tooltips or interactivity in the plots using `plotly`.


--- 

Enjoy using the Pharmacy Ranking app! If you encounter any issues or have suggestions, feel free to reach out.
