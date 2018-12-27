#!/bin/bash
#program alters mask for the en0 interface
#note that the MAC address is a permenant hardware address
#this progrma only alters the mask of the address for the interface
#use first argument as equivilent to an option
#variable is cmd with -help as the default
cmd=${1:--help}
#if -help option is given, print help information
if [ "$cmd" = "-help" ]; then
  echo "MAC Address Setup Tool HELP:"
  echo "-help         Prints this help message"
  echo "-rand         Sets MAC address to a random value"
  echo "-set          Sets MAC address to specified value"
  echo "-getnew       Prints random MAC address"
  echo "-print        Prints current MAC address"
#if -rand option is given, set address to random value
elif [ "$cmd" = "-rand" ]; then
  #repeat process
  while true; do
    #create random value in the MAC address 0x format
    rand=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g;s/.$//')
    #attempt to set address mask using random value
    sudo ifconfig en0 ether $rand
    #read current address
    real=$(ifconfig en0 | awk '/ether/{print $2}')
    #compare generated value and actual value
    #successful set
	  if [ "$rand" = "$real" ]; then
      #reset internet
      sudo ifconfig en0 down
      sudo ifconfig en0 up
      #print success message
      echo "MAC Address Successfully Set"
      echo "New MAC Address: $real"
      #stop repeating after successful set
      break
    #failed set
    else
      #print fail message
      echo "Attempt to Set Address Failed"
      echo "Retrying Process ..."
      #will repeat process within while loop
	  fi
  done
#if -set option is given, set mask to that value
elif [ "$cmd" = "-set" ]; then
  #prompt user to give desired address
  read -p "Enter MAC Address: " new
  #attempt to set mask
  sudo ifconfig en0 ether $new
  #find actual value
  real=$(ifconfig en0 | awk '/ether/{print $2}')
  #test for successful set
  if [ "$new" = "$real" ]; then
    #reset interface
  	sudo ifconfig en0 down
  	sudo ifconfig en0 up
    #print success message
  	echo "MAC Address Successfully Set"
  	echo "New MAC Address: $real"
  #failed set
  else
    #print fail message
    #most likly the given address is an invalid MAC address
	  echo "Attempt to Set Address Failed"
	  echo "Retry using Different Address"
  fi
#if -getnew option given, print random value formatted as MAC address
elif [ "$cmd" = "-getnew" ]; then
  #print value generated in correct format
  echo $(openssl rand -hex 6 | sed 's/\(..\)/\1:/g;s/.$//')
#if -print option given, print current mask address
elif [ "$cmd" = "-print" ]; then
  #find and print current address
  echo $(ifconfig en0 | awk '/ether/{print $2}')
#invalid option given
else
  #give error message
  echo "Invaild Option Entered"
fi
