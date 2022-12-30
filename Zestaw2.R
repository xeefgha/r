library(RSelenium)
library(rvest)
library(gtools)
library(DBI)
library(RMySQL)
library(rstudioapi)
cityNames = c('bydgoszcz', 'gdansk', 'katowice', 'krakow', 'lublin', 'lodz', 'poznan', 'szczecin', 'warszawa', 'wroclaw')
scrapingDate = '2022-12-29'
baseUrl = 'https://www.otodom.pl'
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4445L, browserName = "firefox")
remDr$open()

getLinks = function(cityName, remDr) {
  startUrl = paste0('https://www.otodom.pl/pl/oferty/sprzedaz/mieszkanie/', cityName, '?areaMax=38&page=1')
  remDr$navigate(startUrl)
  remDr$refresh
  pageHtml = rvest::read_html(remDr$getPageSource()[[1]])
  buttons = html_elements(pageHtml, css='button[class="eoupkm71 css-190hi89 e11e36i3"]')
  buttonMax = buttons[length(buttons) - 1]
  pageNumMax = as.numeric(html_text2(buttonMax))
  linksAll = c()
  for (i in 1:pageNumMax) {
    nextUrl = paste0(url, i)
    Sys.sleep(1)
    remDr$navigate(nextUrl)
    pageHtml = rvest::read_html(remDr$getPageSource()[[1]])
    listings = html_elements(pageHtml, css='.css-14cy79a.e3x1uf06')
    if (length(listings) >= 2) {
      listingAll = listings[2]
      links = html_attr(html_elements(listingAll, css='li > a'), 'href')
      linksAll = c(linksAll, links)
    }
  }  
  linksAll
}
readAppartment = function(city, scrapingDate, linksAll, baseUrl, remDr) {
  cityDf = data.frame()
  for (link in linksAll) {
    nextUrl = paste0(baseUrl, link)
    Sys.sleep(1)
    remDr$navigate(nextUrl)
    remDr$refresh
    appartmentHtml = rvest::read_html(remDr$getPageSource()[[1]])    
    price = html_text2(html_elements(appartmentHtml, css='strong[class="css-8qi9av eu6swcv19"]'))
    info = html_text2(html_elements(appartmentHtml, css='div[class="css-1ccovha estckra9"]'))
    labels = c()
    values = c()
    for (element in info) {
      splited = strsplit(element, '\n')
      labels = c(labels, splited[[1]][1])
      values = c(values, splited[[1]][2])
    }
    appartmentDf = data.frame(t(values), check.names = FALSE)
    colnames(appartmentDf) = labels
    appartmentDf = cbind(appartmentDf, city)
    appartmentDf = cbind(appartmentDf, scrapingDate)
    appartmentDf = cbind(appartmentDf, price)
    cityDf = smartbind(cityDf, appartmentDf)
  }
  cityDf
}
citiesDf = data.frame()
for (cityName in cityNames) {
  linksAll = getLinks(cityName, remDr)
  cityDf = readAppartment(cityName, scrapingDate, linksAll, baseUrl, remDr)
  citiesDf = smartbind(citiesDf, cityDf)
}

