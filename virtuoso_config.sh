#!/bin/bash

# Rotina Virtuoso OpenIoT
# <odifica a senha do usuaro dba para a variavel de ambiente
# Adiciona a role SPARQL_UPDATE para o usuario SPARQL
# Cria os gráficos necessários 
cat > /tmp/virtuoso_dba <<EOF
SET PASSWORD dba $VIRTUOSO_DBA_PASS;
USER_GRANT_ROLE('SPARQL', 'SPARQL_UPDATE', 0);
SPARQL
    CREATE GRAPH <http://lsm.deri.ie/OpenIoT/sensormeta#>
    CREATE GRAPH <http://lsm.deri.ie/OpenIoT/sensordata#>
    CREATE GRAPH <http://lsm.deri.ie/OpenIoT/functionaldata#>;
EOF

# Executa a query
isql -U dba -P dba < /tmp/virtuoso_dba