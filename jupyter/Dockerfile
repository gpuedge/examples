FROM ubuntu:22.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y vim git curl wget locate locales apt-transport-https apt-utils \
    && apt-get clean && apt-get autoremove --yes

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN echo "en_US UTF-8" >> /etc/locale.gen && locale-gen

WORKDIR "/root"

#install jupyter
RUN apt-get update \
    && apt-get install -y python3 python3-pip \
    && apt-get clean && apt-get autoremove --yes \
    && pip3 install numpy scipy sklearn tensorflow torch pandas matplotlib jax \
    && pip3 install jupyterlab

ENTRYPOINT ["/usr/local/bin/jupyter-lab", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''", "--ip", "localhost", "--port", "8080", "--notebook-dir=/persist"]