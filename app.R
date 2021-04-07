
library(shiny)
library(plotly)
library(ggplot2)
library(parallel)
library(dplyr)

ui <- fluidPage(
   HTML("<center><h1 style='color:red'>A shiny App for <strong style='color:blue'>Soudabeh Masoudi</strong>.</h1></center>"),
   tags$br(),
   tabsetPanel(id = "tabs",
       tabPanel(title = "Import data",
                sidebarLayout(sidebarPanel = sidebarPanel(
                    fileInput("file",label = "import your data"),
                    uiOutput("slider")
                ),
                              mainPanel = mainPanel(
                                  tableOutput("tbl"),
                                  verbatimTextOutput("txt")
                              ))
                ),
       tabPanel(title = "Visualization",
                sidebarLayout(sidebarPanel = sidebarPanel(
                    radioButtons("scatter",label = "type of figure",choices = c("histogram","scatter")),
                    textInput("figColor",label = "figure Color",value = "red"),
                                         uiOutput("VisSliders")
                                       ),
                                       mainPanel = mainPanel(
                    plotOutput("myplt",width = "100%",height = "800px")
                ))
                   
                   ),
       tabPanel(title = "descriptive Statistics",
                sidebarLayout(sidebarPanel = sidebarPanel(
                    HTML("<p style='color:blue'>desctiptive statistics for numeric variables.</p>")
                ),
                              mainPanel = mainPanel(
                                  tableOutput("desStr")
                              ))
                ),
       tabPanel(title = "Regression",
                sidebarLayout(sidebarPanel = sidebarPanel(
                    uiOutput("regSliders")
                ),
                              mainPanel = mainPanel(
                                  verbatimTextOutput("strReg")
                              ))
                )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output,session) {
    observe({
        hideTab("tabs",target = "Visualization",session = session)
        hideTab("tabs",target = "descriptive Statistics",session = session)
        hideTab("tabs",target = "Regression",session = session)
    })
    data <- eventReactive(input$file,{
        read.csv(input$file$datapath)
    })
    nameData <- reactive(
        names(data())
    )
    observeEvent(input$file,{
        # updateSliderInput(session = session,inputId = "numHead",
        #               label = "number of observations to show",min = 0,max = nrow(data()))
        output$slider <- renderUI(sliderInput("numHead",label = "number of observations to show",
                                              min = 0,max = nrow(data()),value = 6))

# -------------------------------------------------------------------------

        
        showTab("tabs",target = "Visualization",session = session)
        showTab("tabs",target = "descriptive Statistics",session = session)
        showTab("tabs",target = "Regression",session = session)
        

# -------------------------------------------------------------------------
        output$VisSliders <- renderUI(
            tags$div(
            selectInput("xscale",label = "select variable for x scale",choices = nameData()),
            conditionalPanel("input.scatter=='scatter'",
                             selectInput("yscale",label = "select variable for y scale",choices = nameData()),
                             sliderInput("scaterSize",label = "size",min = 0.1,max = 10,value = 1,step = 0.1)
                             )
            )
        )
        # reg
        output$regSliders <- renderUI(
            tags$div(
                selectInput("tarVar",label = "select target Variable",choices = nameData()),
                selectInput("predVar",label = "select predictor variables",choices = nameData(),multiple = TRUE),
                checkboxInput("regSummary","show Summary of the OLS Model")
            )
        )

# -------------------------------------------------------------------------
        })
    output$tbl <- renderTable({
        req(input$numHead)
        head(data(),input$numHead)
    })
    output$txt <- renderPrint({
        req(data())
        str(data())
    })
# -------------------------------------------------------------------------
    # Visualization:
    output$myplt <- renderPlot({
        req(input$figColor%in%colors())
        if(input$scatter=="scatter") {
            ggplot(data = data(),aes(x = get(input$xscale), y =get(input$yscale)))+geom_point(color = input$figColor,size = input$scaterSize)
        } else {
            ggplot(data = data(),aes(x = get(input$xscale)))+geom_histogram(color = 'black',fill = input$figColor)
        }
    })

# -------------------------------------------------------------------------

# descriptive statistics    
    output$desStr <- renderTable({
        cores <- detectCores()
        cl <- makeCluster(cores-1)
        newData <- data() %>% select_if(is.numeric)
        x <- parLapply(cl = cl,newData,function(x) {
            summary(x)
        })
        stopCluster(cl)
        tbl <- do.call(rbind,x)
        tbl <- as.data.frame(tbl)
        cbind("var"=names(x),tbl)
    })
    

# -------------------------------------------------------------------------

# regression

    observeEvent(input$tarVar,
    updateSelectInput(session = session,"predVar",label = "select predictor variables",choices = nameData()[!nameData()%in%input$tarVar]))
        
    output$strReg <- renderPrint({
        req(input$tarVar)
        req(input$predVar)
        form <- paste0(input$tarVar,"~",paste0(input$predVar,collapse = "+"))
        lmModel <- lm(as.formula(form),data = data())
        if(input$regSummary) {
            summary(lmModel)
        } else {
            lmModel
        }
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

