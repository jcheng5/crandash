function(input, output, session) {

  pkgData <- connectToLogs(session)
  startTime <- as.numeric(Sys.time())

  output$rate <- renderUI({
    elapsed <- as.numeric(Sys.time()) - startTime
    downloadRate <- nrow(pkgData()) / elapsed

    valueBox(
      value = formatC(downloadRate, digits = 1, format = "f"),
      subtitle = "Downloads per sec",
      icon = icon("area-chart"),
      color = if (downloadRate >= input$rateThreshold) "yellow" else "aqua"

    )
  })

  output$count <- renderUI({
    valueBox(
      value = nrow(pkgData()),
      subtitle = "Total downloads",
      icon = icon("download")
    )
  })

  output$users <- renderUI({
    valueBox(
      length(unique(pkgData()$ip_id)),
      "Unique users",
      icon = icon("users")
    )
  })

  output$packagePlot <- renderBubbles({
    if (nrow(pkgData()) == 0)
      return()

    order <- unique(pkgData()$package)
    df <- pkgData() %>%
      group_by(package) %>%
      tally() %>%
      arrange(match(package, order))

    bubbles(df$n, df$package)
  })

  output$packageTable <- renderTable({
    pkgData() %>%
      group_by(package) %>%
      tally() %>%
      arrange(desc(n), tolower(package)) %>%
      select(Package = package, Downloads = n) %>%
      as.data.frame() %>%
      head(15)
  })

  output$downloadCsv <- downloadHandler(
    filename = "cranlog.csv",
    content = function(file) {
      write.csv(pkgData(), file)
    },
    contentType = "text/csv"
  )
  
  output$rawtable <- renderPrint({
    orig <- options(width = 1000)
    print(tail(pkgData(), input$maxrows))
    options(orig)
  })
}


