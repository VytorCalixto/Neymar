#!/bin/bash

#TODO: Abrir quantidade arbitrária de clientes

server=$1
client1=$2
client2=$3
client3=$4  

if [ "$server" == "-h" ]; then
  echo "Uso: env PASS=\"<senha>\" ./artillery.sh <servidor> <cliente1> <cliente2> <cliente3>"
  exit 0
fi

./shooter.exp $USER $client1 "ruby Documentos/Programas/Redes2/neymar/main_client.rb $server" &
./shooter.exp $USER $client2 "ruby Documentos/Programas/Redes2/neymar/main_client.rb $server" &
./shooter.exp $USER $client3 "ruby Documentos/Programas/Redes2/neymar/main_client.rb $server" &