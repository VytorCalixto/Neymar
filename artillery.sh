#!/bin/bash

server=$1
nclients=$2
machinesfile="machines"
machinesmax=$(cat "$machinesfile" | wc -l)

if [ "$server" == "-h" ]; then
  echo "Uso: ./artillery.sh <servidor> <número de clientes>"
  exit 0
fi

if [ "$nclients" -ge "$machinesmax" ]; then
  echo "Número máximo de máquinas conhecidas é $machinesmax"
  exit 0
fi

read -sp "Entre com a senha de $USER: " pass
echo -e "\n"
export PASS=$pass

counter=0
while IFS='' read -r line || [[ -n "$line" ]] && [ "$counter" -lt "$nclients" ]; do
  if [ "$line" != "$server" ]; then
    ./shooter.exp $USER $line "ruby Documentos/Programas/Redes2/neymar/main_client.rb $server" &
    ((counter++))
  fi
done < "machines"