library(shiny)
library(plotly)
library(shinycssloaders)
library(rsconnect)
topWidget <- function(icon, category, title, iconFooter, labelFooter) {
  div(
    class = "card card-stats",
    div(
      class = "card-body",
      div(
        class = "row",
        div(
          class = "col-4",     
          div(
            class = "info-icon text-center icon-warning",  
            span(class = paste("las", icon))  # icon taken from lineawesome, pass as parameter 
          )
        ),
        div(
          class = "col-8",  
          div(
            class = "numbers",
            p(class = "card-category", category),
            h3(class = "card-title", title) 
          )
        )
      )
    )
  )
}

bottomWidget <- function(content) {
  div(
    class = "card card-stats",
    div(
      class = "card-body",
      content
    )
  )
}

ui <- div(
  class = "wrapper",
  tags$style(HTML("
    @import url('https://fonts.googleapis.com/css?family=Poppins');
    @import url('https://demos.creative-tim.com/marketplace/black-dashboard-pro/assets/css/black-dashboard.min.css?v=1.1.1');
    @import url('https://maxst.icons8.com/vue-static/landings/line-awesome/line-awesome/1.3.0/css/line-awesome.min.css');

    .navbar {
      top: auto;
    }
    .card-stats .info-icon span {
      color: #fff;
      font-size: 1.7em;
      padding: 13px 5px;
    }
    .card-chart .chart-area {
      height: 350px;
    }
    .plotly {
      height: auto !important;
    }
  ")),
  div(
    class = "main-panel",
    div(
      class = "navbar justify-content-center",
      div(class = "navbar-brand", "COVID-19 VACCINATION DASHBOARD")
    ),
    div(
      class = "p-4",
      div(
        class = "row",
        div(
          class = "col-lg-3 col-md-6", 
          topWidget(icon = "la-exclamation", category = "Total Covid Cases", title = textOutput("total_covid_cases"), iconFooter = "la-random", labelFooter ="Last Updated: xxxx")
        ),
        div(
          class = "col-lg-3 col-md-6", 
          topWidget(icon = "la-skull-crossbones", category = "Total Deaths", title = textOutput("total_covid_death"), iconFooter = "la-random", labelFooter ="Last Updated: xxxx")
        ),
        div(
          class = "col-lg-3 col-md-6", 
          topWidget(icon = "la-syringe", category = "Total Vaccine Doses", title = textOutput("sum_total_vaccinations"), iconFooter = "la-random", labelFooter ="Last Updated: xxxx")
        ),
        div(
          class = "col-lg-3 col-md-6", 
          topWidget(icon = "la-thumbs-up", category = "People Fully Vaccinated", title = textOutput("sum_people_fully_vaccinated"), iconFooter = "la-random", labelFooter ="Last Updated: xxxx")
        ),
        div(
          class = "col-12",   
          div(
            class = "card card-chart",  
            div(
              class = "card-header",
              div(
                class = "row",
                div(
                  class = "col-sm-6 text-left",
                  h5(class = "card-category", "By Country"),
                  h2(class = "card-title", span(class = "las la-bell text-primary"), "Total Vaccination")
                ), 
                div(
                  class = "col-sm-6",
                  uiOutput("slider_year")
                )
              )
            ),
            div(
              class = "card-body",
              div(
                actionButton("go", "Refresh"),
                shinycssloaders::withSpinner(plotlyOutput("sum_total_vaccinations_by_country"), type = getOption("spinner.type", 7)),
                align = "center", 
                br(), 
                br()
              )
            )
          )
        ),
        div(
          class = "col-lg-6 col-md-12", 
          bottomWidget(content = plotlyOutput("sum_progress_vaccinations_daily"))
        ),
        div(
          class = "col-lg-6 col-md-12", 
          bottomWidget(content = plotlyOutput("sum_progress_people_vaccinated_daily"))
        )
      )
    )
  )
)
