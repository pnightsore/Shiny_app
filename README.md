# Shiny_app
Shiny app for Coding(R module)
# Creating a shiny_app for my R module midterm:

This is a documentation for my shiny app.

## How it works
Shiny package consists of two parts: **ui** and **server**.

ui is the graphic environment and server will do the calculations.

at first a **.csv** file is uploaded using the below command:
```
fileinput("file", label = "import your data") #ui side

data <- eventReactive(input$file, {
  read.csv(input$file$datapath)
}) #server side
```

At the beginning all other tabs are hidden using **hideTab** command except for the data upload section.

## Data

As soon as the data is uploaded in the form of a **.csv** to the app, other tabs are activated.
in order to have a more userfriendly environment I have used the **sidebarLayout** in each of the panels using the suitable commands.
the data is up loadable in the form of .csv using the browse button and its possible to control the number of observations to show.

### Variable:
* Sepal length
* Sepal width
* Petal length
* Petal width
 the **id** and **species** are the categorical attributes.
 
## Visualization

It's possible to visualize the data in two forms of **histogram** and **scatter plot** and the figure color is personalizable.
the variable for x scale should be chosen among the available variable.

## Descriptive statistics

In this section, some basic statistical summeries are provided such as:
* Minimum
* Maximum
* Mean
* Median
* 1st quarter
* 3rd quarter

## Regression

This panel makes it possible to choose the *target variable* and the *predictor variable* and to analyze the regression and the correlation between them.

## Optimization

For this end **the package parallel** is used with the function **parlapply** 
and finally to have the output in the form of a table, the output is transformed into a **data frame** :
```
cores <- detectCores()
cl <- makeCluster(cores - 1)
newData <- data() %>% select_if(is.numeric)
x <- parLapply(cl = cl, newData, function(x) {
  summary(x)
})
stopCluster(cl)
tbl <- do.call(rbind, x) tbl <- as.data.frame(tbl) cbind(var = names(x), tbl)
```
## Interactivity

To make the app a bit more interactive and to give it the possibility of personalization, it is made possible to change the figure color in the **visualization** panel and of course to try accessing the **regression** and the **discriptive statistics** panel using the variables of the users' choice.

# The End!
