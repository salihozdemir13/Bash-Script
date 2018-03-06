#! /bin/bash

# Utility Functions Begin
function sendMail
{
   numberOfFindedLines=$(grep -c '1' mail.txt) #here we go :) thats why this code just working on local server.
   if [ "$numberOfFindedLines" != 0 ]
   then
       mail yourmailaddress@blabla.com < mail.txt -s "network activity" #subject for your mail
   fi
}

function IPActivities #difference between first scan and second scan
{
   echo "Disconnected IPs" > mail.txt
   diff firstIPControl.txt secondIPControl.txt | grep '<' >> mail.txt
   echo "Connected IPs" >> mail.txt
   diff firstIPControl.txt secondIPControl.txt | grep '>' >> mail.txt
   sendMail
}

function IPGenerate #scanning
{
   nmap -sP 192.168.47.0/24 | awk '/Host/{printf $2;}/MAC Address:/{print "-MAC:"$3;}/{printf""}/' | sort > $1

   while read line  #Remove trusted IPs from scanned IP list
   do
         IPTemp="$line"
       ex -s +"g/$IPTemp/d" -cwq $1
   done < IPLib.txt
}

function firstRunCheckAndInit
{
       if [ ! -f firstIPControl.txt ]
       then #if file does not exist

           > firstIPControl.txt
           > secondIPControl.txt
       fi

}

function run
{
   IPGenerate secondIPControl.txt
   IPActivities
   cat secondIPControl.txt > firstIPControl.txt
}

# Utility Functions End

## Program Start Here

#Checking NMAP
nmap -sP 192.168.xxx.xxx ||{ echo "nmap is not found..."
   exit 1
}

firstRunCheckAndInit
run
