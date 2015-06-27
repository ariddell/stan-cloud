FROM ipython/scipystack

MAINTAINER Stan Developers <stan-dev@googlegroups.com>

VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888

## Rudimentary test
#RUN python2 -c "import pystan"
#RUN python3 -c "import pystan"
#RUN echo "library(rstan)" | R --no-save
