
library(plumber)
library(airball)

# Example root endpoint
#* @get /
#* @serializer unboxedJSON
function() {
  list(message = "Welcome to the Airball API! Visit /__docs__/ for Swagger documentation.")
}


##########################

# nba_travel.R

#########################


#* @apiTitle NBA Travel API
#* @apiDescription This API returns NBA travel data based on specified seasons, teams, and other parameters, provided by the `airball` package.

#* Return NBA travel data
#* @param start_season:integer The starting season (default = 2018)
#* @param end_season:integer The ending season (default = 2020)
#* @param team:string An optional team name or comma-separated list of teams (e.g. "Los Angeles Lakers,Chicago Bulls"). Defaults to "Atlanta Hawks" if not specified.
#* @param return_home:integer Minimum rest days away from home before returning home (default = 20)
#* @param phase:string The phase(s) of the season, comma-separated (e.g. "RS,PO"). Defaults to "RS,PO".
#* @param flight_speed:integer The flight speed to assume in mph (default = 550)
#* @get /nba_travel
function(start_season = 2018,
         end_season = 2020,
         team = "",
         return_home = 20,
         phase = "RS,PO",
         flight_speed = 550) {

  # Convert parameters as needed
  start_season  <- as.integer(start_season)
  end_season    <- as.integer(end_season)
  return_home   <- as.integer(return_home)
  flight_speed  <- as.integer(flight_speed)

  # Split comma-separated parameters into vectors
  phase_vec <- trimws(unlist(strsplit(phase, ",")))

  # If team is NULL or empty string, default to "Atlanta Hawks"
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



##########################

#nba_travel_player

##########################



#* @apiTitle NBA Player Travel API
#* @apiDescription Returns NBA player travel and game data from the airball package

#* Return NBA player travel data
#* @param start_season:integer The starting season (default = 2018)
#* @param end_season:integer The ending season (default = 2020)
#* @param team:string An optional team name or comma-separated list of teams (e.g. "Los Angeles Lakers"). Defaults to "Atlanta Hawks".
#* @param player:string An optional player name or comma-separated list of players (e.g. "LeBron James"). Defaults to "Trae Young".
#* @param return_home:integer Minimum rest days away from home before returning home (default = 20)
#* @param phase:string The phase(s) of the season, comma-separated (e.g. "RS,PO"). Defaults to "RS,PO".
#* @param flight_speed:integer The flight speed to assume in mph (default = 450)
#* @get /nba_player_travel
function(start_season = 2018,
         end_season = 2020,
         team = "",
         player = "",
         return_home = 20,
         phase = "RS,PO",
         flight_speed = 550) {

  # Convert parameters to appropriate types
  start_season  <- as.integer(start_season)
  end_season    <- as.integer(end_season)
  return_home   <- as.integer(return_home)
  flight_speed  <- as.integer(flight_speed)

  # Split comma-separated parameters into vectors
  phase_vec <- unlist(strsplit(phase, ","))
  phase_vec <- trimws(phase_vec)

  # Default team to "Atlanta Hawks" if none provided
  if (is.null(team) || nchar(team) == 0) {
    team_vec <- "Atlanta Hawks"
  } else {
    team_vec <- trimws(unlist(strsplit(team, ",")))
  }

  # Default player to "Trae Young" if none provided
  if (is.null(player) || nchar(player) == 0) {
    player_vec <- "Trae Young"
  } else {
    player_vec <- trimws(unlist(strsplit(player, ",")))
  }

  # Call the nba_player_travel function from the airball package
  result <- nba_player_travel(
    start_season = start_season,
    end_season = end_season,
    team = team_vec,
    player = player_vec,
    return_home = return_home,
    phase = phase_vec,
    flight_speed = flight_speed
  )

  # Return the result as JSON
  return(result)
}



##########################

#nba_density

##########################



#* @apiTitle NBA Density API
#* @apiDescription Returns NBA density metrics (like B2B games) using data from nba_travel, processed by nba_density.

#* Return NBA density data
#* @param start_season:integer The starting season (default = 2018)
#* @param end_season:integer The ending season (default = 2020)
#* @param team:string An optional team name or comma-separated list of teams. Defaults to "Atlanta Hawks" if not specified.
#* @param return_home:integer Minimum rest days away from home before returning home (default = 20)
#* @param phase:string The phase(s) of the season, comma-separated (e.g. "RS,PO"). Defaults to "RS,PO".
#* @param flight_speed:integer The flight speed to assume in mph (default = 550)
#* @get /nba_density
function(start_season = 2018,
         end_season = 2020,
         team = "",
         return_home = 20,
         phase = "RS,PO",
         flight_speed = 550) {

  # Convert parameters to appropriate types
  start_season  <- as.integer(start_season)
  end_season    <- as.integer(end_season)
  return_home   <- as.integer(return_home)
  flight_speed  <- as.integer(flight_speed)

  # Split comma-separated phases
  phase_vec <- trimws(unlist(strsplit(phase, ",")))

  # Default to Atlanta Hawks if team not provided
  if (is.null(team) || nchar(team) == 0) {
    team_vec <- "Atlanta Hawks"
  } else {
    team_vec <- trimws(unlist(strsplit(team, ",")))
  }

  # Call nba_travel from airball
  travel_data <- nba_travel(
    start_season = start_season,
    end_season = end_season,
    team = team_vec,
    return_home = return_home,
    phase = phase_vec,
    flight_speed = flight_speed
  )

  # Pass the travel_data to nba_density
  result <- nba_density(travel_data)

  # Return the result as JSON
  return(result)
}



##########################

#nba_injuries

##########################


#* @apiTitle NBA Injuries API
#* @apiDescription Returns injury transactions data based on the given query parameters.
#* If both `team` and `player` are empty, defaults to "Hawks" for the Atlanta Hawks (since you use nicknames).
#* If only `player` is provided, returns all injuries for that player.
#* If only `team` is provided, returns all injuries for that team.
#* If both `player` and `team` are provided, returns injuries for that combination.

#* Return NBA injuries and related transactions
#* @param start_date:string Starting date for the search (YYYY-MM-DD), default = "2017-01-01"
#* @param end_date:string Ending date for the search (YYYY-MM-DD), default = "2018-01-01"
#* @param player:string Player name (optional)
#* @param team:string Team nickname (optional), for example "Celtics" for Boston Celtics. Default logic explained below.
#* @get /nba_injuries
function(start_date = "2017-01-01",
         end_date = "2018-01-01",
         player = "",
         team = "") {

  # Handle defaults:
  # If both player and team are empty, default to "Hawks" (for Atlanta Hawks)
  if ((is.null(player) || nchar(player) == 0) && (is.null(team) || nchar(team) == 0)) {
    team <- "Hawks"
    player <- ""  # No player specified, so all team injuries
  }

  # If user only supplies a player, we leave team empty and query all results for that player.
  # If user only supplies a team, we leave player empty and query all results for that team.
  # If user supplies both, we use them as provided.

  # Call the nba_injuries function
  result <- nba_injuries(
    start_date = start_date,
    end_date = end_date,
    player = player,
    team = team
  )

  # Check if result is NA (no results or an error)
  # Use identical() to safely check if result is the single NA value.
  if (identical(result, NA)) {
    # No results found. Craft a message depending on parameters.
    if (nchar(player) > 0 && nchar(team) > 0) {
      return(list(
        message = paste("No results found for player", player, "on team", team,
                        "within the specified date range. Consider adjusting your parameters.")
      ))
    } else if (nchar(player) > 0) {
      return(list(
        message = paste("No results found for player", player,
                        "within the specified date range. Consider adjusting your parameters.")
      ))
    } else if (nchar(team) > 0) {
      return(list(
        message = paste("No results found for team", team,
                        "within the specified date range. Consider adjusting your parameters.")
      ))
    } else {
      return(list(message = "No results found. Consider adjusting your parameters."))
    }
  }

  # If we reach this point, result should be a data frame with some rows.
  return(result)
}


###################

# nba travel plot

####################



#* @apiTitle NBA Travel Plot API
#* @apiDescription Returns a PNG plot of NBA flight paths using `nba_travel_plot`.

#* @serializer png
#* @param width:integer Width of the plot in pixels (default=1200)
#* @param height:integer Height of the plot in pixels (default=800)
#* @param start_season:integer Starting season (default=2018)
#* @param end_season:integer Ending season (default=2020)
#* @param team:string Full team name(s), comma-separated (e.g. "Boston Celtics, Chicago Bulls"). Defaults to "Atlanta Hawks".
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
#* @get /nba_travel_plot
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

  # Convert parameters that must be numeric
  start_season <- as.integer(start_season)
  end_season <- as.integer(end_season)
  return_home <- as.integer(return_home)
  flight_speed <- as.integer(flight_speed)
  ncolumns <- as.integer(ncolumns)
  width <- as.integer(width)
  height <- as.integer(height)

  # season may be NULL or empty
  if (!is.null(season) && nchar(season) > 0) {
    season <- as.integer(season)
  } else {
    season <- ""
  }

  # phase may be multiple values
  phase_vec <- trimws(unlist(strsplit(phase, ",")))

  # For team(s), split if multiple
  if (is.null(team) || nchar(team) == 0) {
    team <- "Atlanta Hawks"
  } else {
    team <- trimws(unlist(strsplit(team, ",")))
  }

  # Convert numeric parameters for plotting
  land_alpha <- as.numeric(land_alpha)
  city_size <- as.numeric(city_size)
  path_curvature <- as.numeric(path_curvature)
  path_size <- as.numeric(path_size)
  title_size <- as.numeric(title_size)
  caption_size <- as.numeric(caption_size)
  strip_text_size <- as.numeric(strip_text_size)

  # Get travel data
  travel_data <- nba_travel(
    start_season = start_season,
    end_season = end_season,
    team = team,
    return_home = return_home,
    phase = phase_vec,
    flight_speed = flight_speed
  )

  # Generate the plot
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

  # Print the plot to return it as PNG
  print(p)
}
