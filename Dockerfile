# OpenIoT Dockerfile by WiserUFBA Research Group
# ---------------------------------------------------------------------------
# Created by Jeferson Lima
# At Universidade Federal da Bahia
# Project SmartUFBA
# Version 1.0.0
# Description:
#       Esse é o Dockerfile de instalação de um container OpenIoT
#   totalmente configurado. O objetivo deste container é o de
#   se tornar o modelo padrão de deploy da aplicação OpenIoT
# ---------------------------------------------------------------------------
MAINTAINER Jeferson Lima <jefersonlimaa@dcc.ufba.br>

# 1 Passo - Preparação do ambiente
# ---------------------------------------------------------------------------
# Para nossa primeira execução iremos utilizar a versão 14.04 do ubuntu
FROM ubuntu:14.04

# Como em 'https://github.com/OpenIotOrg/openiot/wiki/Installation-Guide'
# precisamos configurar algumas variavéis de ambiente para a correta
# execução do OpenIoT

# Home das Aplicações necessárias
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV MAVEN_HOME /usr/share/maven3
ENV VIRTUOSO_HOME /usr/local/virtuoso-opensource
ENV JBOSS_HOME /opt/jboss
ENV OPENIOT_HOME /opt/openiot

# Especificado a home dessas aplicações iremos começar a instalação das mesmas

# 2 Passo - Instalação dos pré requisitos comuns
# ---------------------------------------------------------------------------
# Instalar os prerequisitos globais como alguns ppa e o básico para instalação
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y  software-properties-common && \
    apt-add-repository -y ppa:webupd8team/java && \
    apt-add-repository -y ppa:andrei-pozolotin/maven3 && \
    apt-get update

# 3 Passo - Instalação do Java 8 e Maven
# ---------------------------------------------------------------------------
# Instalação do Java 8

# Para a Instalação do JAVA 8 é necessário primeiro aceitar a licença do java
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 " \
         "select true" | /usr/bin/debconf-set-selections

# Agora instalamos o Java 8 e o Maven 3
RUN apt-get install -y oracle-java8-installer && \
    apt-get install -y oracle-java8-set-default && \
    apt-get install -y maven3

# 4 Passo - Instalação do Virtuoso
# ---------------------------------------------------------------------------
# Instalação Básica do Virtuoso

# Pré requisitos do virtuoso
RUN apt-get install -y build-essential debhelper autotools-dev && \
    apt-get install -y autoconf automake unzip wget net-tools && \
    apt-get install -y git libtool flex bison gperf gawk m4 && \
    apt-get install -y libssl-dev libreadline-dev libreadline-dev && \
    apt-get install -y openssl python-pip && \
    pip install crudini

# Virtuoso Release Link Virtuoso 7.2.4.2 (25/04/2016)
ENV VIRTUOSO_RELEASE_LINK "https://github.com/openlink/virtuoso-opensource/releases/download/v7.2.4.2/virtuoso-opensource-7.2.4.2.tar.gz"

# Configuração compilação e instalação do Virtuoso
RUN cd /tmp && \
    mkdir virtuoso_install && \
    cd virtuoso_install && \
    wget -O virtuoso_release.tar.gz $VIRTUOSO_RELEASE_LINK && \
    tar -zxvf virtuoso_release.tar.gz && \
    cd virtuoso_opensource && \
    ./autogen.sh && \
    CFLAGS="-O2 -m64" && \
    export CFLAGS && \
    ./configure && \
    make && \
    make install && \
    rm -r /tmp/virtuoso_install

# Criar as pastas para cada aplicação
RUN mkdir /opt/jboss && \
    mkdir /opt/openiot && \


# References
# https://www.digitalocean.com/community/tutorials/docker-explained-using-dockerfiles-to-automate-building-of-images
# https://github.com/OpenIotOrg/openiot/wiki/Installation-Guide
# https://hub.docker.com/_/ubuntu/
# https://github.com/jboss-dockerfiles/base-jdk/blob/jdk7/Dockerfile
# https://hub.docker.com/r/jboss/base/
# https://hub.docker.com/r/jboss/base/~/dockerfile/
# https://hub.docker.com/r/tenforce/virtuoso/~/dockerfile/


