shinyUI(fluidPage(
  headerPanel("Crime Outlook"),
  sidebarPanel(
    dateInput(
      'caldate',
      'Shift Date',
      value = '2014-04-13',
      min = '2014-01-01',
      max = '2014-04-15',
      startview = 'month'
      ),
    selectInput(
      'hourstart',
      'First hour of shift',
      choices = c(0:23),
      selected = 8
      ),
    conditionalPanel(condition = 'input.tabs1 == Neighborhood Level',
                     radioButtons(
                       'selectNeighborhoods',
                       'Neighborhoods',
                       choices = c('Bayview','Central','Ingleside','Mission','Northern','Park',
                                   'Richmond','Southern','Taraval','Tenderloin'),
                       selected = c('Mission')
                       ))
    ),
  mainPanel(
    fluidRow(
      column(12,
             sliderInput('shifthr','Shift Hours',
                         min=1, max=10, value=1, animate=animationOptions(interval=2000, loop=T)
             )
      ),
      
      column(7,plotOutput('cityPlot',height='600px')),
      column(3,tableOutput('neibTable'))
    )
  )
      
#       column(12,
#              sliderInput('shifthr','Shift Hours',
#                          min=1, max=10, value=1, animate=animationOptions(interval=2000, loop=T)
#              )
#       ),
#       column(4,
#              tableOutput('neibTable'),
#       )),
#       
#       plotOutput('cityPlot',height='600px')
#       
# 
#       )
    
#     ,
#     tabsetPanel(id = 'tabs1',
#       tabPanel('City Level',plotOutput('cityPlot',height='600px')),
#       tabPanel('Neighborhood Level',tableOutput('neibTable'))
#         )
# 
#     )
))