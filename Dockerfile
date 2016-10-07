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

# Geração de chave auto assinada para o JBOSS
ENV JBOSS_SSL_KEY "wiser2014"
ENV JBOSS_SSL_ADDRESS "localhost"
ENV JBOSS_SSL_ORGANIZATION "WiserUFBA"
ENV JBOSS_SSL_ORGANIZATION_UNITY "SmartUFBA"
ENV JBOSS_SSL_CITY "Salvador"
ENV JBOSS_SSL_STATE "Bahia"
ENV JBOSS_SSL_COUNTRY "BR"

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
    update-rc.d virtuoso-service defaults && \
    printf "RUN=yes\n" > /etc/default/virtuoso && \
    # Cria o usuario virtuoso e adiciona as permissões para a DB
    useradd virtuoso --home $VIRTUOSO_HOME && \
    chown -R virtuoso:virtuoso $VIRTUOSO_HOME && \

# Inicializa o serviço do virtuoso, mesmo que ele apresente erros
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
    apt-get install -y unzip bsdtar \
    # Instala o JBOSS
    mkdir /tmp/jboss_install && \
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

# Adiciona o Jboss a inicialização
RUN chmod 755 /etc/init.d/jboss-service && \
    chown root:root /etc/init.d/jboss-service && \
    update-rc.d jboss-service defaults

# Cria o usuario jboss e adiciona as permissões para a home do jboss
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

# Configuração do Jboss
RUN mkdir $JBOSS_HOME/standalone/configuration/ssl && \
    JBOSS_SSL_CONFIG="CN=$JBOSS_SSL_ADDRESS," && \
	JBOSS_SSL_CONFIG="$JBOSS_SSL_CONFIG OU=$JBOSS_SSL_ORGANIZATION_UNITY," && \
	JBOSS_SSL_CONFIG="$JBOSS_SSL_CONFIG O=$JBOSS_SSL_ORGANIZATION," && \
	JBOSS_SSL_CONFIG="$JBOSS_SSL_CONFIG L=$JBOSS_SSL_CITY," && \
	JBOSS_SSL_CONFIG="$JBOSS_SSL_CONFIG S=$JBOSS_SSL_STATE," && \
	JBOSS_SSL_CONFIG="$JBOSS_SSL_CONFIG C=$JBOSS_SSL_COUNTRY" && \
	export JBOSS_SSL_CONFIG && \
	cd $JBOSS_HOME/standalone/configuration/ssl && \
	keytool -genkey \
			-noprompt \
			-alias jbosskey \
			-dname "$JBOSS_SSL_CONFIG" \
			-keyalg RSA \
			-keystore server.keystore \
			-storepass changeit \
			-keypass "$JBOSS_SSL_KEY" && \
	keytool -export \
			-noprompt \
			-alias jbosskey \
			-keypass "$JBOSS_SSL_KEY" \
			-file server.crt \
			-storepass changeit \
			-keystore server.keystore && \
	keytool -import \
			-noprompt \
			-alias jbosscert \
			-keypass "$JBOSS_SSL_KEY" \
			-file server.crt \
			-storepass changeit \
            -keystore server.keystore && \
	keytool -import \
			-noprompt \
			-keystore "$JAVA_HOME/jre/lib/security/cacerts" \
			-file server.crt \
			-alias incommon \
			-storepass changeit && \
	xmlstarlet ed \
			-L \
			-N serverns="urn:jboss:domain:1.2" \
			-N subsystemns="urn:jboss:domain:web:1.1" \
			--subnode "/serverns:server/_:profile/subsystemns:subsystem" \
				--type elem \
				-n connector \
			--insert "//subsystemns:subsystem/connector[not(@name)]" \
				--type attr \
				-n name \
				-v "https" \
			--insert "//connector[@name='https']" \
				--type attr \
				-n protocol \
				-v "HTTP/1.1" \
			--insert "//connector[@name='https']" \
				--type attr \
				-n scheme \
				-v "https" \
			--insert "//connector[@name='https']" \
				--type attr \
				-n "socket-binding" \
				-v "https" \
			--insert "//connector[@name='https']" \
				--type attr \
				-n "secure" \
				-v "true" \
			--subnode "//connector[@name='https']" \
				--type elem \
				-n ssl \
			--insert "//connector[@name='https']/ssl" \
				--type attr \
				-n name \
				-v "https" \
			--insert "//ssl" \
				--type attr \
				-n "key-alias" \
				-v "jbosskey" \
			--insert "//ssl" \
				--type attr \
				-n "password" \
				-v "$JBOSS_SSL_KEY" \
			--insert "//ssl" \
				--type attr \
				-n "certificate-key-file" \
				-v "$JBOSS_HOME/standalone/configuration/ssl/server.keystore" \
			"$JBOSS_HOME/standalone/configuration/standalone.xml"

# OpenIoT Installation Link
ENV OPENIOT_LINK https://github.com/OpenIotOrg/openiot.git

# Versão do OpenIoT
ENV OPENIOT_BRANCH develop
# ENV OPENIOT_BRANCH master

# Compilação dos modulos do OpenIoT
RUN mkdir /tmp/openiot && \
    cd /tmp/openiot && \
    git clone --branch $OPENIOT_BRANCH $OPENIOT_LINK && \
    cd /tmp/openiot/openiot && \
    mvn clean install && \
    JBOSS_DEPLOY="$JBOSS_HOME/standalone/deployments" && \
	JBOSS_CONFIGURATION="$JBOSS_HOME/standalone/configuration" && \
	cp ./utils/utils.commons/src/main/resources/security-config.ini "$JBOSS_CONFIGURATION" && \
	cp ./utils/utils.commons/src/main/resources/properties/openiot.properties "$JBOSS_CONFIGURATION" && \
	cp ./modules/lsm-light/lsm-light.server/target/lsm-light.server.war "$JBOSS_DEPLOY" && \
	cp ./modules/security/security-server/target/openiot-cas.war "$JBOSS_DEPLOY" && \
	cp ./modules/security/security-management/target/security.management.war "$JBOSS_DEPLOY" && \
	cp ./modules/scheduler/scheduler.core/target/scheduler.core.war "$JBOSS_DEPLOY" && \
	cp ./modules/sdum/sdum.core/target/sdum.core.war "$JBOSS_DEPLOY" && \
	cp ./ui/ui.requestDefinition/target/ui.requestDefinition.war "$JBOSS_DEPLOY" && \
	cp ./ui/ui.requestPresentation/target/ui.requestPresentation.war "$JBOSS_DEPLOY" && \
	cp ./ui/ui.schemaeditor/target/ui.schemaeditor.war "$JBOSS_DEPLOY" && \
	cp ./ui/ide/ide.core/target/ide.core.war "$JBOSS_DEPLOY" && \
    cd / && \
    mv /tmp/openiot/openiot $OPENIOT_HOME && \
    rm -r /tmp/openiot

# Passo Final
# ---------------------------------------------------------------------------
# Ultimas rotinas de compilação da imagem

# Script de inicialização da aplicação
ADD openiot.sh /openiot.sh

# Remove diversas aplicações inúteis
# TODO: REMOVE ALL UNANTHED APPLICATIONS

# Finaliza a instalação
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Ponto de entrada
CMD ["/bin/bash", "/openiot.sh"]

# References
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/
# https://github.com/jboss-dockerfiles/base-jdk/blob/jdk7/Dockerfile
# https://github.com/OpenIotOrg/openiot/wiki/Installation-Guide
# https://github.com/OpenIotOrg/openiot/wiki/InstallingVirtuosoOpensource7Ubuntu
# https://hub.docker.com/_/ubuntu/
# https://hub.docker.com/r/jboss/base/
# https://hub.docker.com/r/jboss/base/~/dockerfile/
# https://hub.docker.com/r/tenforce/virtuoso/~/dockerfile/
# https://hub.docker.com/r/andreptb/jboss-as/~/dockerfile/
# http://stackoverflow.com/questions/19335444/how-to-assign-a-port-mapping-to-an-existing-docker-container
# http://stackoverflow.com/questions/6880902/start-jboss-7-as-a-service-on-linux
# http://stackoverflow.com/questions/15630055/how-to-install-maven-3-on-ubuntu-15-10-15-04-14-10-14-04-lts-13-10-13-04-12-10-1
# https://www.ivankrizsan.se/2015/08/08/creating-a-docker-image-with-ubuntu-and-java/
# https://www.ctl.io/developers/blog/post/dockerfile-entrypoint-vs-cmd/
# http://www.mundodocker.com.br/docker-exec/
# https://www.digitalocean.com/community/tutorials/docker-explained-using-dockerfiles-to-automate-building-of-images
# http://stackoverflow.com/questions/13578134/how-to-automate-keystore-generation-using-the-java-keystore-tool-w-o-user-inter
# https://www.technomancy.org/xml/add-a-subnode-command-line-xmlstarlet/
