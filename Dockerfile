FROM rocker/r-ver:4.3.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgdal-dev \
    libproj-dev \
    libgeos-dev \
    libfontconfig1-dev \
    libudunits2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install remotes for handling GitHub dependencies
RUN R -e 'install.packages("remotes")'

# Set the working directory
WORKDIR /app

# Copy all project files into the container
COPY . /app

# Install dependencies from DESCRIPTION
RUN R -e 'remotes::install_deps(dependencies=TRUE, repos = c(CRAN = "https://cran.r-project.org"))'

# Expose the port that Plumber will use
EXPOSE 8000

# Run the Plumber API
CMD R -e 'pr <- plumber::pr("plumber.R"); pr$run(host="0.0.0.0", port=8000)'

