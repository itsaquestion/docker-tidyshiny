# Base image, see https://hub.docker.com/r/rocker/rstudio
FROM rocker/tidyverse:3.5.3

# Shiny
RUN export ADD=shiny && bash /etc/cont-init.d/add

# DataBase
RUN install2.r --error --deps TRUE -r 'http://cran.r-project.org' \
   DBI \
   RPostgres \
   && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Chinese fonts
RUN apt-get -qqy update \
  && apt-get -qqy --no-install-recommends install \
    fonts-noto-cjk \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get -qyy clean

RUN install2.r --error --deps TRUE  -r 'http://cran.r-project.org' \
   devtools \
   shinycssloaders \
   pool \
   egg \
   shinythemes \
   properties \
   lattice \
   xts \
   && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# for ggalt
RUN install2.r --error --deps TRUE  -r 'http://cran.r-project.org' \
   KernSmooth \
   MASS \
   && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN R -e 'devtools::install_github("hrbrmstr/ggalt", ref = "noproj")'

RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Improve first page load time by not shutting down the R session when idle

RUN sed -i '/location \/ {/a app_idle_timeout 0;' /etc/shiny-server/shiny-server.conf

# Increase app load timeout
RUN sed -i '/location \/ {/a app_init_timeout 60;' /etc/shiny-server/shiny-server.conf
