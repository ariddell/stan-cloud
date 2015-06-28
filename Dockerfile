FROM ipython/scipystack

MAINTAINER Stan Developers <stan-dev@googlegroups.com>

VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888

## Install PyStan
RUN pip2 install pystan
RUN pip3 install pystan

## Install RStan dependencies
RUN apt-get install -qy python-software-properties software-properties-common && add-apt-repository -y ppa:marutter/rrutter && apt-get update && apt-get -qy install r-base r-base-dev
RUN apt-get install -qy libxml2-dev
RUN apt-get install -qy r-recommended r-cran-rcpp r-cran-rcppeigen r-cran-inline r-cran-rcurl r-cran-memoise r-cran-evaluate r-cran-digest
RUN echo 'options(repos = "http://lib.stat.cmu.edu/R/CRAN/"); install.packages("Rcpp")' | R --no-save
RUN echo 'options(repos = "http://lib.stat.cmu.edu/R/CRAN/"); install.packages("BH")' | R --no-save
RUN echo 'options(repos = "http://lib.stat.cmu.edu/R/CRAN/"); install.packages("xml2")' | R --no-save
RUN echo 'options(repos = "http://lib.stat.cmu.edu/R/CRAN/"); install.packages("rversions")' | R --no-save
RUN echo 'options(repos = "http://lib.stat.cmu.edu/R/CRAN/"); install.packages("devtools")' | R --no-save
RUN echo 'options(repos = "http://lib.stat.cmu.edu/R/CRAN/");' \
         'source("http://mc-stan.org/rstan/install.R", echo = TRUE, max.deparse.length = 2000);' \
         'install_rstan()' | R --no-save

## Install bash kernel
RUN pip3 install bash_kernel

## Rudimentary test
RUN python2 -c "import pystan"
RUN python3 -c "import pystan"
RUN echo "library(rstan)" | R --no-save
