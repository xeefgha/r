print('Hello world from R!')

#requires RTools
install.packages('httr')
install.packages('jsonlite')

library(httr)
library(jsonlite)

endpoint <- 'https://api.openweathermap.org/data/2.5/weather?q=Warszawa&appid=1765994b51ed366c506d5dc0d0b07b77&units=metric'
gotweather <- httr::GET(endpoint)
weatherText <- httr::content(gotweather, 'text')
weatherJson = jsonlite::fromJSON(weatherText)
weatherDF = as.data.frame(weatherText)

x <- 100
class(x)
is.numeric(x)
is.vector(x)
a <- seq(1:10)
b <- seq(11:20)
