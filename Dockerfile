FROM rocker/r-ver:4.2.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgeos-dev \
    libudunits2-dev \
    libgdal-dev \
    libproj-dev \
    libfontconfig1-dev \
    && rm -rf /var/lib/apt/lists/*

# Install remotes to install from GitHub
RUN R -e 'install.packages("remotes")'

# Set the working directory
WORKDIR /app

# Copy all files from your project into the image
COPY . /app

# Install dependencies from DESCRIPTION
RUN R -e 'remotes::install_deps(dependencies=TRUE)'

# Expose the port that plumber will run on
EXPOSE 8000

# Run the plumber API
CMD R -e 'pr <- plumber::pr("plumber.R"); pr$run(host="0.0.0.0", port=8000)'
