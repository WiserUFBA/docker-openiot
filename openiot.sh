#!/bin/bash

# Configura os variaveis de cada ambiente
JAVA_HOME=/usr/lib/jvm/java-7-oracle
MAVEN_HOME=/usr/share/maven3
VIRTUOSO_HOME=/usr/local/virtuoso-opensource
JBOSS_HOME=/opt/jboss
OPENIOT_HOME=/opt/openiot

# Permite o uso dessas variaveis dentro das aplicações chamadas
export JAVA_HOME
export MAVEN_HOME
export VIRTUOSO_HOME
export JBOSS_HOME
export OPENIOT_HOME

# Adiciona o virtuoso ao path
PATH=$VIRTUOSO_HOME/bin/:$PATH


