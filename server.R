library(shiny)
library(tidyverse)

server <- function(input, output, session) {

  vaccinations_df <- reactive({
    withProgress(message = 'Preparing vaccination dataset', value = 0, {
      vaccinations_df <- read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv') %>%
        drop_na(daily_vaccinations)
    })
  })
  
  covid_df <- reactive({
    withProgress(message = 'Preparing daily covid dataset', value = 0, {
      covid_df <- read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv')
    })
  })
  
  daily_total_cases <- reactive({
    covid_df() %>% drop_na(total_cases) %>% group_by(date) %>% 
      summarise(daily_total_cases = sum(total_cases)) %>% arrange(date) %>% 
      tail(20)
  })
  
  latest_covid_df <- reactive({
    withProgress(message = 'Preparing latest data available', value = 0, {
      latest_covid_df <- read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/latest/owid-covid-latest.csv')
    })
  })
  
  #Output Rendering
  output$total_covid_cases <- renderText({
    format(sum(latest_covid_df()$total_cases, na.rm = T), nsmall=0, big.mark=",")
  })
  
  output$total_covid_death <- renderText({
    format(sum(latest_covid_df()$total_deaths, na.rm = T), nsmall=0, big.mark=",")
  })
  
  output$sum_people_fully_vaccinated <- renderText({
    x <- vaccinations_df() %>% 
      drop_na(people_fully_vaccinated) %>% 
      group_by(location) %>% 
      filter(date == max(date)) %>% 
      summarize(sum_people_fully_vaccinated = sum(people_fully_vaccinated)) %>%
      summarize(sum_people_fully_vaccinated = sum(sum_people_fully_vaccinated))
    
    format(x$sum_people_fully_vaccinated, nsmall=0, big.mark=",")
  })
  
  output$sum_total_vaccinations <- renderText({
    x <- vaccinations_df() %>% 
      drop_na(total_vaccinations) %>% 
      group_by(location) %>% 
      filter(date == max(date)) %>% 
      summarize(sum_total_vaccinations = sum(total_vaccinations)) %>% 
      summarize(sum_total_vaccinations = sum(sum_total_vaccinations))
    
    format(x$sum_total_vaccinations, nsmall=0, big.mark=",")
  })
  
  output$slider_year <- renderUI({
    data <- vaccinations_df() %>%
      drop_na(total_vaccinations)
    
    sliderInput(
      "slider_year", 
      "Select a date:", 
      min=min(data$date), 
      max=max(data$date), 
      value=max(data$date), 
      animate=animationOptions(loop = TRUE, interval = 1000)
    )
  })
  
  output$sum_total_vaccinations_by_country <- renderPlotly({
    input$go 
    Sys.sleep(1)
    plot(runif(10))
    data <- vaccinations_df() %>% 
      drop_na(total_vaccinations) %>%
      filter(date <= input$slider_year) %>% 
      group_by(location) %>% 
      filter(date == max(date)) 
    data$hover <- with(
      data, paste(
        location, '<br>', 
        "Date:", date, "<br>",
        "Total vaccinations:", total_vaccinations, "<br>",
        "People Vaccinated:", people_vaccinated, "<br>",
        "People Fully Vaccinated:", people_fully_vaccinated, "<br>"
      ))
    
    data %>% highlight_key(~iso_code) %>%
      plot_ly(
        source="sum_total_vaccinations_by_country", 
        type='choropleth', 
        locations=~iso_code, 
        z=~total_vaccinations, 
        text=~hover,
        colorscale="Electric"
      ) %>% 
      layout(
        paper_bgcolor = '#232640', 
        font = list(
          color = '#bdbdbd'
        ),
        geo = list(
          showframe = FALSE,
          showcoastlines = FALSE,
          bgcolor = '#232640'
        )
      ) %>%
      highlight(on = "plotly_click", off = "plotly_doubleclick")
  })
  
  output$sum_progress_vaccinations_daily <- renderPlotly({
    vaccinations_df() %>%
      drop_na(total_vaccinations) %>%
      group_by(date) %>%
      summarize(sum_total_vaccinations = sum(total_vaccinations)) %>%
      highlight_key(~date) %>%
      plot_ly(
        x = ~date, 
        y = ~sum_total_vaccinations,
        mode = "lines+markers"
      ) %>% 
      layout(
        height = 200,
        paper_bgcolor = '#222327', 
        plot_bgcolor = '#222327', 
        font = list(
          color = '#bdbdbd'
        ),
        xaxis = list(title='Date'),
        yaxis = list(title = 'Total Vaccinations')
      ) %>% 
      highlight(on = "plotly_click", off = "plotly_doubleclick")
  })
  
  output$sum_progress_people_vaccinated_daily <- renderPlotly({
    vaccinations_df() %>%
      drop_na(people_vaccinated) %>%
      group_by(date) %>%
      summarize(sum_people_vaccinated = sum(people_vaccinated)) %>%
      highlight_key(~date) %>%
      plot_ly(
        x = ~date, 
        y = ~sum_people_vaccinated,
        mode = "lines+markers"
      ) %>% 
      layout(
        height = 200,
        paper_bgcolor = '#222327', 
        plot_bgcolor = '#222327', 
        font = list(
          color = '#bdbdbd'
        ),
        xaxis = list(title = 'Date'),
        yaxis = list(title = 'Total People Vaccinated')
      ) %>% 
      highlight(on = "plotly_click", off = "plotly_doubleclick")
  })
  
}