# Package setup ---------------------------------------------------------------

# Install required packages:
# install.packages("pak")
# pak::pak("surveydown-dev/surveydown") # Development version from GitHub

# Load packages
library(surveydown)

# Database setup --------------------------------------------------------------
#
# Details at: https://surveydown.org/docs/storing-data
#
# surveydown stores data on any PostgreSQL database. We recommend
# https://supabase.com/ for a free and easy to use service.
#
# Once you have your database ready, run the following function to store your
# database configuration parameters in a local .env file:
#
# sd_db_config()
#
# Once your parameters are stored, you are ready to connect to your database.
# This template runs in preview mode (set via `mode: preview` in survey.qmd),
# which saves responses locally instead of to a database. To collect real
# responses, run sd_db_config() to store your database credentials, then
# change `mode` to `database` in the survey.qmd YAML header.

db <- sd_db_connect()

# UI setup --------------------------------------------------------------------

ui <- sd_ui()

# Server setup ----------------------------------------------------------------

server <- function(input, output, session) {
  observe({
    pet_type <- sd_value("pet_type")

    # Only create the question if pet_type has a value
    req(pet_type)

    # Make the question label and options
    label <- glue::glue("Are you a {pet_type} owner?")
    options <- c('yes', 'no')
    names(options)[1] <- glue::glue("Yes, I am a {pet_type} owner")
    names(options)[2] <- glue::glue("No, I am not a {pet_type} owner")

    # Make the question
    sd_question(
      type = "mc",
      id = "pet_owner",
      label = label,
      option = options
    )
  })

  # Only show the pet_owner question if pet_type is answered
  sd_show_if(
    sd_is_answered("pet_type") ~ "pet_owner"
  )

  # Run surveydown server and define database
  sd_server(db = db)
}

# Launch the app
shiny::shinyApp(ui = ui, server = server)
