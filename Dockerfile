FROM debian:jessie
MAINTAINER Alexandre Abadie <alexandre.abadie@inria.fr>

ENV SHELL /bin/bash

RUN apt-get update -yqq  && apt-get install -yqq \
  wget \
  bzip2 \
  git \
  libglib2.0-0 \
  && rm -rf /var/lib/apt/lists/*

# Localize en_US.UTF-8
RUN apt-get update -qq \
 && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
 && apt-get install -yqq locales \
 && update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PYTHONIOENCODING UTF-8

# Folder to install non-system tools and serve as workspace for the notebook
# user
RUN mkdir -p /work/bin

# Create a non-priviledge user that will run the services
ENV BASICUSER basicuser
ENV BASICUSER_UID 1000
RUN useradd -m -d /work -s /bin/bash -N -u $BASICUSER_UID $BASICUSER
RUN chown $BASICUSER /work
USER $BASICUSER
WORKDIR /work

# Install Python 3 from miniconda
RUN wget -O miniconda.sh \
  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  && bash miniconda.sh -b -p /work/miniconda \
  && rm miniconda.sh

ENV PATH="/work/bin:/work/miniconda/bin:$PATH"


# Install matplotlib and scikit-image without Qt
RUN conda update -y python conda && \
  conda install -y --no-deps \
  matplotlib \
  cycler \
  freetype \
  libpng \
  pyparsing \
  pytz \
  python-dateutil \
  scikit-image \
  networkx \
  pillow \
  six \
  && conda clean -tipsy

RUN conda install -y \
  pip \
  setuptools \
  notebook \
  ipywidgets \
  terminado \
  psutil \
  numpy \
  scipy \
  pandas \
  bokeh \
  scikit-learn \
  statsmodels \
  && conda clean -tipsy

# Install the master branch of distributed and dask
COPY requirements.txt .
RUN pip install -r requirements.txt && rm -rf ~/.cache/pip/

# Configure matplotlib to avoid using QT
COPY matplotlibrc /work/.config/matplotlib/matplotlibrc

# Trigger creation of the matplotlib font cache
ENV MATPLOTLIBRC /work/.config/matplotlib
RUN python -c "import matplotlib.pyplot"

# Switch back to root to make it possible to do interactive admin/debug as
# root tasks with docker exec
USER root

# Install Tini that necessary to properly run the notebook service in a docker
# container:
# http://jupyter-notebook.readthedocs.org/en/latest/public_server.html#docker-cmd
# Add Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.9.0/tini \
 && cp tini /usr/bin/tini && chmod +x /usr/bin/tini

EXPOSE 2222 8888
ENTRYPOINT ["/usr/bin/tini", "run"]

ENV JUPYTER_ID="basicuser:1000:100"
ENV JUPYTER_ENGINES_N=""
ENV JUPYTER_CONTROLLER="controller:9000"
ENV JUPYTER_NOTEBOOK_PORT="8888"
ENV JUPYTER_KEY_PUB="$HOME/.ssh/id_rsa.pub"
ENV JUPYTER_KEY_PRV="$HOME/.ssh/id_rsa"
CMD ["console"]

COPY run /usr/sbin/run
COPY commands /docker-commands
RUN chmod u+x /usr/sbin/run \
 && chmod +x /docker-commands/*
