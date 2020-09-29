#
# Dockerfile
# for Deeplearning use cases
#
# based on Ubunut 20.04, Tensorflow, Python3 and Jupiter notebook
# container will start with an empty jupiter notebook
# 
# Version 1.0, created: 29.09.2020
#

# We start with an Ubuntu OS
FROM ubuntu:20.04
MAINTAINER johannes.diemer@dc40.de

ENV LANG C.UTF-8
# We need Python ...
RUN echo "installing python3 ..."
RUN apt update && apt install -y python3 python3-dev python3-pip python3-venv
RUN python3 --version
# Requires the latest pip version
RUN echo "installing pip ..."
RUN pip3 install --upgrade pip
RUN pip --version

# Some TF tools expect a "python" binary
RUN ln -s $(which python3) /usr/local/bin/python

# some examples require git to fetch dependencies
RUN apt-get install -y --no-install-recommends git

# Installs the latest version by default.
ARG TF_PACKAGE=tensorflow
ARG TF_PACKAGE_VERSION=
RUN python3 -m pip install --no-cache-dir ${TF_PACKAGE}${TF_PACKAGE_VERSION:+==${TF_PACKAGE_VERSION}}

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc

# Insatll jupiter notebook and matplotlib for numpy
RUN  python3 -m pip install --use-feature=2020-resolver --no-cache-dir jupyter matplotlib
RUN python3 -m pip install --no-cache-dir jupyter_http_over_ws ipykernel==5.1.1 nbformat==5.0.7
RUN jupyter serverextension enable --py jupyter_http_over_ws

#  create working directory for jupiter notebook as exterenal volume 
# to ensure data are saved even if container no longer exists 
RUN mkdir -p /tf/tsf_empty  && chmod -R a+rwx /tf/
VOLUME "/tf/tsf_empty"
WORKDIR "/tf/tsf_empty"

# 
# port for jupiter notebook server
EXPOSE 8888
RUN python3 -m ipykernel.kernelspec

# Start Jupiter 
CMD ["/bin/bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=/tf/tsf_empty --ip 0.0.0.0 --no-browser --allow-root"]
