#!/bin/bash

# Script de Inicialização OpenIoT
# Developed By Jeferson Lima <jefersonlimaa@dcc.ufba.br> @jefersonla

# Inicializa o Virtuoso
until service virtuoso-service start; do
	echo "Failed to start... Trying again."
done

# Devido algum bug a senha está sendo resetada
# esse snippet irá modificar a senha caso isso esteja acontencedo ainda
printf "SET PASSWORD dba %s;\n" "$VIRTUOSO_DBA_PASS" > /tmp/virtuoso_dba
while isql -U dba -P dba < /tmp/virtuoso_dba
do
    echo "Failed to change password... Trying again..."
done


# Espera alguns segundos pela inicialização do virtuoso
sleep 10

# Inicializa a instância do Jboss
service jboss-service start

# Imprime o log para manter a instância ativa
tail -F "$JBOSS_HOME/standalone/log/server.log"
