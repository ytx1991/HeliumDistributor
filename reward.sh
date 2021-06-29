#!/bin/bash
#Check if there is anyone unpaid
unpaid=$(ls -l | grep unpaid | wc -l)
if [[ $unpaid -gt 0 ]]
then
        echo "Found $unpaid unpaid, skipping the current payment ..."
        exit
fi
# Your total shares
totalShare=100
# Your wallet password
export HELIUM_WALLET_PASSWORD=
#export HELIUM_API_URL=https://testnet-api.helium.wtf/v1
# Payee address
address=(1aVMj6QWrRAuF4DwKqpzP7ShXMoKGWnEiqvf1wZwjjZijeiUD8g)
# Payee name
name=("test1")
# Payee shares
share=(10)
# Reserved HNT for operation purpose
reserveAmount=50
total=${#name[*]}
signature=$(openssl rand -base64 8)
mkdir $signature
#Truncated balance in the wallet
balance=$(./helium-wallet -f wallet.key.1 balance | grep -P '[\d]+\.[\d]+' -o | head -n 1 | grep -o '^[0-9]*')
echo "$(date -u)        Current balance $balance" >> $signature/log
rewards=$((balance - reserveAmount))
echo "$(date -u)        Reserved: $reserveAmount HNT, distribute: $rewards HNT, sig: $signature" >> $signature/log
for (( i=0; i<=$(( $total -1 )); i++ ))
do
        pay=$((rewards / totalShare * ${share[$i]}))
        echo "$(date -u)        Paying ${name[$i]}, addr: ${address[$i]}, amount: $pay, signature: $signature ..." >> $signature/log
        ./helium-wallet -f wallet.key.1 -f wallet.key.2 -f wallet.key.3 pay one ${address[$i]} $pay --memo $signature --commit >> $signature/log || echo $pay > $signature/${name[$i]}-$signature.unpaid
done
