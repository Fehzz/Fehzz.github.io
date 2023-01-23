#!/bin/bash
#Lines 4-10 contain variables used to style the script. 
#They can be edited and subsituted into the code accordingly, or removed altogether. 
bold=$(tput bold)
underline=$(tput smul)
error=$(tput setaf 160)
green=$(tput setaf 2)
folder=$(tput setaf 125)
target=$(tput setaf 214)
reset=$(tput sgr0)

#Step 1: Check for installed applications. 

	echo 'Checking for installed applications... '

	find_nipe=$(find ~ -type f -name nipe.pl | wc -l) 
#find_nipe is the variable that stores the command used to search for nipe.pl, in order to verify that nipe is installed.
#Nipe will be used to anonymize browsing.  

if [ $find_nipe != 1 ] #If nipe.pl is not found, the output of the command stored in $find_nipe = 0, hence it will be installed. 
then 
	echo "Installing Nipe..." 
   
	git clone https://github.com/htrgouvea/nipe && cd nipe #Three commands on line 24-26 are needed to install nipe completely.
	sudo cpan install Try::Tiny Config::Simple JSON #This command must be installed as root, so sudo is required.
	sudo perl nipe.pl install #This command must be installed as root, so sudo is required.
	
	echo 'Nipe has been installed successfully.' 
else      
	echo 'Nipe is installed.' #If Nipe already exists, it will not be re-installed. The user is notified. 
fi   

	find_aptitude=$(dpkg-query -W aptitude | grep aptitude | wc -l)

if [ $find_aptitude != 1 ]
then 
	echo 'Installing aptitude...'
	sudo apt install aptitude -y
	echo 'aptitude has been installed successfully.'
else
	echo 'aptitude is installed.'
fi
	find_geoip=$(aptitude -F' * %p -> %d ' --no-gui --disable-columns \
	search '?and(~i,!?section(libs), !?section(kernel), !?section(devel))' | grep geoip-bin | wc -l) 

#backslash is used at the end of line 32 to split the command for viewing convenience.
#Aptitude is used to search for geoip-bin. 
	
#find_geoip is the variable that stores the command used to search for geoip-bin. 
#It will allow us to use geoiplookup later in the script in order to match our IP Address to the corresponding country. 
#The corresponding country will be displayed to the user later in the script. 

if [ $find_geoip != 1 ] #If geoip-bin is not installed...    
then
	echo 'Installing geoip-bin...'
	sudo apt-get install -y geoip-bin
	echo 'geoip-bin has been installed successfully.'
else
	echo 'geoip-bin is installed.' #If geoip-bin already exists, it will not be re-installed. The user is notified.

fi 

	find_sshpass=$(aptitude -F' * %p -> %d ' --no-gui --disable-columns \
	search '?and(~i,!?section(libs), !?section(kernel), !?section(devel))' | grep sshpass | wc -l)
#A backslash is used at the end of line 51 to split the command for viewing convenience.
#Line 51: aptitude is used again to search for installed applications. 
if [ $find_sshpass != 1 ] #If sshpass is not installed...
then
	echo 'Installing sshpass'
	sudo apt-get install sshpass
	echo 'sshpass has been installed successfully.'   
else
	echo 'sshpass is installed.' #If sshpass already exists, it will not be re-installed. The user is notified.
fi 

#Step 2: Let's check if our network connection is anonymous. The script will be suspended if we are not. 

	echo 'Checking if we are anonymous on the internet...' 
  
myIP=$(curl -s ifconfig.me)
mycountry=$(geoiplookup $myIP | awk '{print $5}') 

if [ mycountry = Singapore ]  
then 
	echo "You are ${bold}anonymous${reset}. Your spoofed country is: ${green}$mycountry${reset}" 
else
	echo "${error}WARNING${reset}: You are not anonymous, your identity is exposed, the script will be suspended immediately."
	exit 1 #The previous line warns you in case you're not anonymous. In which case, the exit command will suspend the script. 
fi 

#Step 2b) Specify a domain/IP to scan. 

echo 'Specify a domain or IP address that you want to scan.' 
read yourtarget #You are required to specify the domain you want to scan, your result is saved as a variable: yourtarget. 
echo "You have specified ${target}$yourtarget${reset} as your target." 
echo 'Connecting to remote server via SSH..' 
          
export SSHPASS='tc' #export command is used here to prepare for entry to remote server via sshpass, refer to command in line 100.  
     
uptime_result=$(sshpass -e  ssh tc@192.168.242.129 "uptime")
echo "Uptime: $uptime_result."
sshpass -e  ssh tc@192.168.242.129 "nmap -o output --top-ports 1 $yourtarget -Pn" > /home/kali/nipe/nmap_results 
sshpass -e  ssh tc@192.168.242.129 "whois  $yourtarget" > /home/kali/nipe/whois_results #Line 102-103 results saved LOCALLY. 
echo "Your nmap data has been saved at ${folder}/home/kali/nipe/nmap_results${reset}" 
echo "Your whois data has been saved at ${folder}/home/kali/nipe/whois_results${reset}" 
       


