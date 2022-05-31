#https://www.r-bloggers.com/2019/07/excel-report-generation-with-shiny/

library("ERICDataProc")
EA_SLA_config <- setup_EA_SLA_config_values()

options(shiny.maxRequestSize=400*1024^2)

  # minimal Shiny UI
ui <- fluidPage(
  titlePanel("EA SLA processing"),
  tags$br(),

  fileInput("csvfile", "Choose CSV File",
            accept = c(
              "text/csv",
              "text/comma-separated-values,text/plain",
              ".csv")
  ),


  textInput(inputId = "outputfile",label = "Output filename",value = ""),
  textOutput(outputId = "msg"),



  downloadButton(
    outputId = "okBtn",
    label = "Process EA data")


)

# minimal Shiny server
server <- function(input, output) {


  output$okBtn <- downloadHandler(
    filename = function() {
      ifelse(stringr::str_ends(input$outputfile,'xlsx'),input$outputfile,paste0(input$outputfile,'.xlsx'))

    },
    content = function(file) {


      # inFile <- input$csvfile
      #
      # if (is.null(inFile))
      #   return(NULL)
      #
      # ea_data <- read.csv(inFile$datapath,header = TRUE)


      started <- Sys.time()

      #Create output workbook
      XL_wb <- openxlsx::createWorkbook()

      inFile <- input$csvfile

      if (is.null(inFile))
        return(NULL)

      OutputCols <- EA_SLA_config["EAOutputCols"]
      newColNames <- EA_SLA_config["TempColNames"]
      locationCol <- EA_SLA_config["locationCol"]
      abundanceCol <- EA_SLA_config["abundanceCol"]
      commentCol <- EA_SLA_config["commentCol"]
      recorderCol <- EA_SLA_config["recorderCol"]
      lastCol <- EA_SLA_config["lastCol"]

      ea_data <- read.csv(inFile$datapath,header = TRUE)


        #Format the date - two fields
        ea_data$Survey_sta <- formatDates(ea_data$Survey_sta)
        ea_data$Survey_end <- formatDates(ea_data$Survey_end)

        #Filter out the records we don't want
        #ea_data <- filter_by_survey(ea_data)

        #Remove GCN licence zero counts
        #ea_data <- filter_GCN(ea_data)

        #Fish
        #ea_data <- do_data_fixes(ea_data)

        #Set protected flag
        # #Not sure prot species is correct - = not "in"

        #ea_data <- set_protected_flag(ea_data)


        # #Sort out designations
        #ea_data <- fix_designations(ea_data,TRUE)

        # Easting & northing calculations
        #ea_data <- E_and_N_calcs(ea_data)


        #Get the columns we're going to output
        #AED this needs checking
        browser()
        outputdata <- format_and_check_EA_SLA_data(ea_data,OutputCols,newColNames)

        sheet_name = 'SLA data'
        XL_wb <- openxlsx::createWorkbook()


        XL_wb <- format_EA_SLA_Excel_output(XL_wb,sheet_name,outputdata,EA_SLA_config)


        openxlsx::saveWorkbook(XL_wb,file,overwrite = TRUE)
    }
  )


}

shinyApp(ui, server)
