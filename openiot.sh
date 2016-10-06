#!/bin/bash

# Script de Inicialização OpenIoT
# Developed By Jeferson Lima <jefersonlimaa@dcc.ufba.br> @jefersonla

# Inicializa o Virtuoso e espera alguns segundos por isso
service virtuoso-service start && sleep 20

# Inicializa a instância do Jboss
service jboss-service start

