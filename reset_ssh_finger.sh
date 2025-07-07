#!/bin/bash

NODO1=172.16.25.11
NODO2=172.16.25.12
NODO3=172.16.25.13
NODO4=172.16.25.21
NODO5=172.16.25.22
NODO6=172.16.25.23
NODO7=172.16.25.31
NODO8=172.16.25.32
for host in $NODO1 $NODO2 $NODO3 $NODO4 $NODO5 $NODO6 $NODO7 $NODO8; do
	ssh-keygen -f "$HOME/.ssh/known_hosts" -R $host
	ssh -o StrictHostKeyChecking=no $host 'echo Reset SSH NODO1 exitoso'
done
