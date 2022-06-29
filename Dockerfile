# pull base image
FROM ubuntu:latest

# maintainer details
MAINTAINER rajeshrajamani "rajesh.r6r@gmail.com"

# Initialize apt sources
RUN \
    echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | tee /etc/apt/apt.conf.d/no-cache && \
    apt-get update -q -y && \  
    apt-get dist-upgrade -y && \
    apt-get clean && \
    rm -rf /var/cache/apt/* 

# Install base ubuntu packages for H2O-3
RUN \
    DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential software-properties-common wget curl s3cmd git unzip chrpath \
    libffi-dev libxml2-dev libssl-dev libcurl4-openssl-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev libssl-dev libxft-dev libmysqlclient-dev \
    python3 python3-dev python3-pip python3-virtualenv \
    texlive texlive-fonts-extra texinfo texlive-bibtex-extra texlive-formats-extra 

# Install nodeJS
RUN \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get update -q -y && \
    apt-get install -y nodejs

# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

#WORKDIR
USER root

WORKDIR /app

# COPY Local requirements
ADD . /app

# Install python dependencies

RUN \
    pip3 install --trusted-host pypi.python.org -r requirements.txt

# Create users
RUN \
    useradd -m -c "H2o AI" h2oai -s /bin/bash


# Expose ports for services
EXPOSE 54321
EXPOSE 8080

CMD \
    ["/bin/bash"]
