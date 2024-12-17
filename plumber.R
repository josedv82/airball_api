library(plumber)
library(airball)


# Increase connection buffer size to avoid vroom errors
  Sys.setenv("VROOM_CONNECTION_SIZE" = 131072 * 2)

# Top-level API metadata
#* @apiTitle Airball API
#* @apiDescription An API to interact with the 'airball' package and retrieve NBA schedule, travel metrics, player data, density metrics, injuries, and visualization plots.
#* @apiVersion 1.0.0
#* @apiLicense name="MIT"
#* @apiTag Travel: Endpoints related to NBA travel data
#* @apiTag Players: Endpoints related to player travel data
#* @apiTag Density: Endpoints related to scheduling density metrics
#* @apiTag Injuries: Endpoints related to NBA player injuries and transactions
#* @apiTag Plots: Endpoints that return visualization images
#* @apiServer https://airball-api.onrender.com

####################################
# Root Endpoint
####################################

#* @get /
#* @operationId rootGet
#* @summary Welcome endpoint
#* @description Provides a welcome message and directions to the docs.
#* @tag General
#* @serializer unboxedJSON
function() {
  list(message = "Welcome to the Airball API! Visit /__docs__/ for Swagger documentation.")
}

####################################
# nba_travel Endpoint
####################################

#* @get /nba_travel
#* @operationId nbaTravelGet
#* @summary Return NBA travel data
#* @description Returns travel metrics for NBA teams based on specified seasons, teams, and other parameters from the `airball` package.
#* @tag Travel
#* @param start_season:integer The starting season (default = 2018)
#* @param end_season:integer The ending season (default = 2020)
#* @param team:string An optional team name or comma-separated list of teams (e.g. "Los Angeles Lakers,Chicago Bulls"). Defaults to "Atlanta Hawks" if not specified.
#* @param return_home:integer Minimum rest days away from home before returning home (default = 20)
#* @param phase:string The phase(s) of the season, comma-separated (e.g. "RS,PO"). Defaults to "RS,PO".
#* @param flight_speed:integer The flight speed to assume in mph (default = 550)
function(start_season = 2018,
         end_season = 2020,
         team = "",
         return_home = 20,
         phase = "RS,PO",
         flight_speed = 550) {

  start_season  <- as.integer(start_season)
  end_season    <- as.integer(end_season)
  return_home   <- as.integer(return_home)
  flight_speed  <- as.integer(flight_speed)
  phase_vec <- trimws(unlist(strsplit(phase, ",")))

  if (is.null(team) || nchar(team) == 0) {
    team_vec <- "Atlanta Hawks"
  } else {
    team_vec <- trimws(unlist(strsplit(team, ",")))
  }

  result <- nba_travel(
    start_season = start_season,
    end_season = end_season,
    team = team_vec,
    return_home = return_home,
    phase = phase_vec,
    flight_speed = flight_speed
  )

  return(result)
}

####################################
# nba_player_travel Endpoint
####################################

#* @get /nba_player_travel
#* @operationId nbaPlayerTravelGet
#* @summary Return NBA player travel data
#* @description Returns NBA player travel and game data based on specified seasons, teams, players, and other parameters from the `airball` package.
#* @tag Players
#* @param start_season:integer The starting season (default = 2018)
#* @param end_season:integer The ending season (default = 2020)
#* @param team:string An optional team name or comma-separated list of teams (defaults to "Atlanta Hawks")
#* @param player:string An optional player name or comma-separated list of players (defaults to "Trae Young")
#* @param return_home:integer Minimum rest days away from home before returning home (default = 20)
#* @param phase:string The phase(s) of the season, comma-separated (e.g. "RS,PO"). Defaults to "RS,PO".
#* @param flight_speed:integer The flight speed to assume in mph (default = 450)
function(start_season = 2018,
         end_season = 2020,
         team = "",
         player = "",
         return_home = 20,
         phase = "RS,PO",
         flight_speed = 550) {

  start_season  <- as.integer(start_season)
  end_season    <- as.integer(end_season)
  return_home   <- as.integer(return_home)
  flight_speed  <- as.integer(flight_speed)

  phase_vec <- trimws(unlist(strsplit(phase, ",")))

  if (is.null(team) || nchar(team) == 0) {
    team_vec <- "Atlanta Hawks"
  } else {
    team_vec <- trimws(unlist(strsplit(team, ",")))
  }

  if (is.null(player) || nchar(player) == 0) {
    player_vec <- "Trae Young"
  } else {
    player_vec <- trimws(unlist(strsplit(player, ",")))
  }

  result <- nba_player_travel(
    start_season = start_season,
    end_season = end_season,
    team = team_vec,
    player = player_vec,
    return_home = return_home,
    phase = phase_vec,
    flight_speed = flight_speed
  )

  return(result)
}

####################################
# nba_density Endpoint
####################################

#* @get /nba_density
#* @operationId nbaDensityGet
#* @summary Return NBA density data
#* @description Returns NBA density metrics (like B2B games) using `nba_travel` data processed by `nba_density`.
#* @tag Density
#* @param start_season:integer The starting season (default = 2018)
#* @param end_season:integer The ending season (default = 2020)
#* @param team:string An optional team name or comma-separated list of teams. Defaults to "Atlanta Hawks".
#* @param return_home:integer Minimum rest days away from home before returning home (default = 20)
#* @param phase:string The phase(s) of the season, comma-separated (e.g. "RS,PO"). Defaults to "RS,PO".
#* @param flight_speed:integer The flight speed to assume in mph (default = 550)
function(start_season = 2018,
         end_season = 2020,
         team = "",
         return_home = 20,
         phase = "RS,PO",
         flight_speed = 550) {

  start_season  <- as.integer(start_season)
  end_season    <- as.integer(end_season)
  return_home   <- as.integer(return_home)
  flight_speed  <- as.integer(flight_speed)
  phase_vec <- trimws(unlist(strsplit(phase, ",")))

  if (is.null(team) || nchar(team) == 0) {
    team_vec <- "Atlanta Hawks"
  } else {
    team_vec <- trimws(unlist(strsplit(team, ",")))
  }

  travel_data <- nba_travel(
    start_season = start_season,
    end_season = end_season,
    team = team_vec,
    return_home = return_home,
    phase = phase_vec,
    flight_speed = flight_speed
  )

  result <- nba_density(travel_data)
  return(result)
}

####################################
# nba_injuries Endpoint
####################################

#* @get /nba_injuries
#* @operationId nbaInjuriesGet
#* @summary Return NBA injuries and related transactions
#* @description If both `team` and `player` are empty, defaults to "Hawks". If only `player` is provided, returns all injuries for that player. If only `team` is provided, returns all injuries for that team. If both are provided, returns injuries for that combination.
#* @tag Injuries
#* @param start_date:string Starting date for the search (YYYY-MM-DD), default = "2017-01-01"
#* @param end_date:string Ending date for the search (YYYY-MM-DD), default = "2018-01-01"
#* @param player:string Player name (optional)
#* @param team:string Team nickname (optional), e.g. "Celtics" for Boston Celtics
function(start_date = "2017-01-01",
         end_date = "2018-01-01",
         player = "",
         team = "") {

  if ((is.null(player) || nchar(player) == 0) && (is.null(team) || nchar(team) == 0)) {
    team <- "Hawks"
    player <- ""
  }

  result <- nba_injuries(
    start_date = start_date,
    end_date = end_date,
    player = player,
    team = team
  )

  if (identical(result, NA)) {
    if (nchar(player) > 0 && nchar(team) > 0) {
      return(list(message = paste("No results found for player", player, "on team", team,
                                  "within the specified date range.")))
    } else if (nchar(player) > 0) {
      return(list(message = paste("No results found for player", player,
                                  "within the specified date range.")))
    } else if (nchar(team) > 0) {
      return(list(message = paste("No results found for team", team,
                                  "within the specified date range.")))
    } else {
      return(list(message = "No results found. Consider adjusting your parameters."))
    }
  }

  return(result)
}

####################################
# nba_travel_plot Endpoint
####################################

#* @get /nba_travel_plot
#* @operationId nbaTravelPlotGet
#* @summary Return a PNG plot of NBA flight paths
#* @description Returns a PNG plot of NBA flight paths using `nba_travel_plot`.
#* @tag Plots
#* @serializer png
#* @param width:integer Width of the plot in pixels (default=1200)
#* @param height:integer Height of the plot in pixels (default=800)
#* @param start_season:integer Starting season (default=2018)
#* @param end_season:integer Ending season (default=2020)
#* @param team:string Full team name(s), comma-separated (defaults to "Atlanta Hawks")
#* @param season:integer Year portion of season (e.g., 2020 for '2020-21')
#* @param return_home:integer (default=20)
#* @param phase:string Comma-separated phases (default="RS,PO")
#* @param flight_speed:integer (default=550)
#* @param land_color:string (default="#17202a")
#* @param land_alpha:double (default=0.6)
#* @param city_color:string (default="cyan4")
#* @param city_size:double (default=0.8)
#* @param path_curvature:double (default=0.05)
#* @param path_color:string (default="#e8175d")
#* @param path_size:double (default=0.5)
#* @param title:string (default="NBA Flight Paths")
#* @param title_color:string (default="white")
#* @param title_size:double (default=20)
#* @param caption:string (default="")
#* @param caption_color:string (default="gray")
#* @param caption_size:double (default=8)
#* @param caption_face:string (default="italic")
#* @param major_grid_color:string (default="transparent")
#* @param minor_grid_color:string (default="transparent")
#* @param strip_text_size:double (default=8)
#* @param strip_text_color:string (default="white")
#* @param strip_fill:string (default="transparent")
#* @param plot_background_fill:string (default="#343e48")
#* @param panel_background_fill:string (default="transparent")
#* @param ncolumns:integer (default=6)
function(start_season = "2018",
         end_season = "2020",
         team = "",
         season = "",
         return_home = "20",
         phase = "RS,PO",
         flight_speed = "550",
         land_color = "#17202a",
         land_alpha = "0.6",
         city_color = "cyan4",
         city_size = "0.8",
         path_curvature = "0.05",
         path_color = "#e8175d",
         path_size = "0.5",
         title = "NBA Flight Paths",
         title_color = "white",
         title_size = "20",
         caption = "",
         caption_color = "gray",
         caption_size = "8",
         caption_face = "italic",
         major_grid_color = "transparent",
         minor_grid_color = "transparent",
         strip_text_size = "8",
         strip_text_color = "white",
         strip_fill = "transparent",
         plot_background_fill = "#343e48",
         panel_background_fill = "transparent",
         ncolumns = "6",
         width = 1200,
         height = 800) {

  start_season <- as.integer(start_season)
  end_season <- as.integer(end_season)
  return_home <- as.integer(return_home)
  flight_speed <- as.integer(flight_speed)
  ncolumns <- as.integer(ncolumns)
  width <- as.integer(width)
  height <- as.integer(height)

  if (!is.null(season) && nchar(season) > 0) {
    season <- as.integer(season)
  } else {
    season <- ""
  }

  phase_vec <- trimws(unlist(strsplit(phase, ",")))

  if (is.null(team) || nchar(team) == 0) {
    team <- "Atlanta Hawks"
  } else {
    team <- trimws(unlist(strsplit(team, ",")))
  }

  land_alpha <- as.numeric(land_alpha)
  city_size <- as.numeric(city_size)
  path_curvature <- as.numeric(path_curvature)
  path_size <- as.numeric(path_size)
  title_size <- as.numeric(title_size)
  caption_size <- as.numeric(caption_size)
  strip_text_size <- as.numeric(strip_text_size)

  travel_data <- nba_travel(
    start_season = start_season,
    end_season = end_season,
    team = team,
    return_home = return_home,
    phase = phase_vec,
    flight_speed = flight_speed
  )

  p <- nba_travel_plot(
    data = travel_data,
    season = season,
    team = team,
    land_color = land_color,
    land_alpha = land_alpha,
    city_color = city_color,
    city_size = city_size,
    path_curvature = path_curvature,
    path_color = path_color,
    path_size = path_size,
    title = title,
    title_color = title_color,
    title_size = title_size,
    caption = caption,
    caption_color = caption_color,
    caption_size = caption_size,
    caption_face = caption_face,
    major_grid_color = major_grid_color,
    minor_grid_color = minor_grid_color,
    strip_text_size = strip_text_size,
    strip_text_color = strip_text_color,
    strip_fill = strip_fill,
    plot_background_fill = plot_background_fill,
    panel_background_fill = panel_background_fill,
    ncolumns = ncolumns
  )

  print(p)
}

