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
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle
ENV MAVEN_HOME /usr/share/maven3
ENV VIRTUOSO_HOME /usr/local/virtuoso-opensource
ENV JBOSS_HOME /opt/jboss
ENV OPENIOT_HOME /opt/openiot

# Usuario Administrador Virtuoso
ENV VIRTUOSO_DBA_PASS wiser2014

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
RUN echo "oracle-java7-installer shared/accepted-oracle-license-v1-1 " \
         "select true" | /usr/bin/debconf-set-selections

# Agora instalamos o Java 7 e o Maven 3
RUN apt-get install -y oracle-java7-installer && \
    apt-get install -y oracle-java7-set-default && \
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

# Adiciona o virtuoso
ENV PATH $VIRTUOSO_HOME/bin/:$PATH

# Adiciona script de inicialização
ADD virtuoso-service /etc/init.d/virtuoso-service

# Adiciona o script de inicialização do virtuoso
RUN chmod 755 /etc/init.d/virtuoso-service && \
    chown root:root /etc/init.d/virtuoso-service && \
    update-rc.d virtuoso-service defaults

# Adiciona a permissão de inicialização
RUN printf "RUN=yes\n" > /etc/default/virtuoso

# Cria o usuario virtuoso e adiciona as permissões para a DB
RUN useradd virtuoso --home $VIRTUOSO_HOME && \
    chown -R virtuoso:virtuoso $VIRTUOSO_HOME

# Inicializa o serviço do virtuoso e espera
RUN until service virtuoso-service start; do
        echo "Failed to start... Trying again."
    done

# Adiciona a rotina padrão de execução
ADD virtuoso_config.sh /tmp/virtuoso_config.sh

# Executa a configuração do virtuoso e remove o arquivo de configuração
RUN bash /tmp/virtuoso_config.sh && \
    rm /tmp/virtuoso_config.sh

# Expõe as portas do Virtuoso
EXPOSE 8890
EXPOSE 1111

# 5 Passo - Instalação do JBOSS
# ---------------------------------------------------------------------------
# Instalação do JBOSS

# Link de Download JBOSS
ENV JBOSS_DOWNLOAD_LINK "http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.zip"

# Instala os pré-requisitos
RUN apt-get install -y xmlstarlet && \
    apt-get install -y libsaxon-java libsaxonb-java libsaxonhe-java && \
    apt-get install -y libaugeas0 && \
    apt-get install -y unzip bsdtar

# Criar a pasta para o JBOSS
RUN mkdir /tmp/jboss_install && \
    cd /tmp/jboss_install && \
    wget -O jboss-install.zip $JBOSS_DOWNLOAD_LINK && \
    unzip jboss-install.zip && \
    mv jboss-as-7.1.1.Final $JBOSS_HOME && \
    rm -r /tmp/jboss_install && \
    mkdir /etc/jboss-as && \
    mkdir /var/log/jboss-as/

# Adiciona o script de inicialização do JBOSS e a configuração
ADD jboss-service /etc/init.d/jboss-service
ADD jboss-as.conf /etc/jboss-as/jboss-as.conf

# Cria os arquivos de configuração para o JBOSS
RUN chmod 755 /etc/init.d/jboss-service && \
    chown root:root /etc/init.d/jboss-service && \
    update-rc.d jboss-service defaults

# Cria o usuario virtuoso e adiciona as permissões para a DB
RUN useradd jboss --home $JBOSS_HOME && \
    chown -R jboss:jboss $JBOSS_HOME

# Executa o serviço do jboss
RUN service jboss-service start

# Expõe a porta do JBOSS
EXPOSE 8080
EXPOSE 8443

# 6 Passo - Instalação do OpenIot
# ---------------------------------------------------------------------------
# Instalação completa do OpenIoT e seus modulos

# Cria a pasta para a aplicação
RUN mkdir $OPENIOT_HOME

# Passo Final
# ---------------------------------------------------------------------------
# Ultimas rotinas de compilação da imagem

# Script de inicialização da aplicação
ADD openiot.sh /openiot.sh

# Ponto de entrada
CMD ["/openiot.sh"]

# References
# https://www.digitalocean.com/community/tutorials/docker-explained-using-dockerfiles-to-automate-building-of-images
# https://github.com/OpenIotOrg/openiot/wiki/Installation-Guide
# https://hub.docker.com/_/ubuntu/
# https://github.com/jboss-dockerfiles/base-jdk/blob/jdk7/Dockerfile
# https://hub.docker.com/r/jboss/base/
# https://hub.docker.com/r/jboss/base/~/dockerfile/
# https://hub.docker.com/r/tenforce/virtuoso/~/dockerfile/

