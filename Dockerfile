FROM rocker/r-ver:4.2.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    libgdal-dev \
    libproj-dev \
    libgeos-dev \
    libfontconfig1-dev \
    libudunits2-dev \
    && rm -rf /var/lib/apt/lists/*

# Set GitHub PAT as an environment variable
ARG GITHUB_PAT
ENV GITHUB_PAT=${GITHUB_PAT}

# Install remotes and plumber, authenticate GitHub API
RUN R -e 'Sys.setenv(GITHUB_PAT = Sys.getenv("GITHUB_PAT")); install.packages(c("remotes", "plumber"), repos = "https://cran.r-project.org")'

# Install nbastatR and force installation
RUN R -e 'Sys.setenv(GITHUB_PAT = Sys.getenv("GITHUB_PAT")); remotes::install_github("abresler/nbastatR", force = TRUE)'

# Set the working directory
WORKDIR /app

# Copy project files into the container
COPY . /app

# Install dependencies from DESCRIPTION
RUN R -e 'remotes::install_deps(dependencies=TRUE, repos = "https://cran.r-project.org")'

# Expose the port that Plumber will use
EXPOSE 8000

# Run the Plumber API
CMD R -e 'pr <- plumber::pr("plumber.R"); pr$run(host="0.0.0.0", port=8000)'



