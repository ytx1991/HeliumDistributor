#!/bin/bash
# Your total shares
totalShare=100
# Your wallet password
export HELIUM_WALLET_PASSWORD=
# Payee address
address=(1aVMj6QWrRAuF4DwKqpzP7ShXMoKGWnEiqvf1wZwjjZijeiUD8g)
# Payee name
name=("test1")
# Payee shares
share=(10)
# Reserved HNT for operation purpose
reserveAmount=50
total=${#name[*]}
#Truncated balance in the wallet
balance=$(./helium-wallet -f wallet.key.1 balance | grep -P '[\d]+\.[\d]+' -o | head -n 1 | grep -o '^[0-9]*')
echo "$(date -u)        Current balance $balance"
rewards=$((balance - reserveAmount))
signature=$(openssl rand -base64 8)
echo "$(date -u)        Reserved: $reserveAmount HNT, distribute: $rewards HNT, sig: $signature"
for (( i=0; i<=$(( $total -1 )); i++ ))
do
        pay=$((rewards / totalShare * ${share[$i]}))
        echo "$(date -u)        Paying ${name[$i]}, addr: ${address[$i]}, amount: $pay, signature: $signature ..."
        ./helium-wallet -f wallet.key.1 -f wallet.key.2 -f wallet.key.3 pay one ${address[$i]} $pay --memo $signature --commit || echo $pay > ${name[$i]}-$signature.unpaid
        echo "$(date -u)        Paid ${name[$i]}"
done
