#!/bin/bash

server=$1
nclients=$2
machinesfile="machines"
machinesmax=$(cat "$machinesfile" | wc -l)

if [ "$server" == "-h" ]; then
  echo "Uso: ./artillery.sh <servidor> <número de clientes> <usuário (opcional)>"
  exit -1
fi

if [ "$nclients" -ge "$machinesmax" ]; then
  echo "Número máximo de máquinas conhecidas é $machinesmax"
  exit -1
fi

if [ "$#" -eq 3 ]; then
  user=$3
else
  user=$USER
fi

read -sp "Entre com a senha de $user: " pass
echo ""
export PASS=$pass

counter=0
echo -e "Criando clientes..."
while IFS='' read -r line || [[ -n "$line" ]] && [ "$counter" -lt "$nclients" ]; do
  if [ "$line" != "$server" ]; then
      ./shooter.exp $user $line "ruby $(pwd)/main_client.rb $server" &
    echo -e "Cliente criado em: $line"
    # Debug:
    # ./shooter.exp -d $USER $line "ruby Documentos/Programas/Redes2/neymar/main_client.rb $server > log_neymar 2>&1" &
    ((counter++))
  fi
done < "machines"
echo "Mensagens enviadas"
