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

# Precisamos de alguns outros containers ... mas vou pensar nisso depois

# Como em 'https://github.com/OpenIotOrg/openiot/wiki/Installation-Guide'
# precisamos configurar algumas variavéis de ambiente para a correta
# execução do OpenIoT

# Home das Aplicações necessárias
ENV JAVA_HOME /opt/java
ENV MAVEN_HOME /opt/maven
ENV JBOSS_HOME /opt/jboss
ENV OPENIOT_HOME /opt/openiot
ENV VIRTUOSO_HOME /opt/virtuoso

# Continue this later...
# https://www.digitalocean.com/community/tutorials/docker-explained-using-dockerfiles-to-automate-building-of-images
# https://github.com/OpenIotOrg/openiot/wiki/Installation-Guide
# https://hub.docker.com/_/ubuntu/
# https://github.com/jboss-dockerfiles/base-jdk/blob/jdk7/Dockerfile
# https://hub.docker.com/r/jboss/base/
# https://hub.docker.com/r/jboss/base/~/dockerfile/
# https://hub.docker.com/r/tenforce/virtuoso/~/dockerfile/
