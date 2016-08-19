
## ONLYOFFICE One Click Installation Overview

An ONLYOFFICE One Click Installation is used to automate the deployment process of ONLYOFFICE Community Edition using the Docker container technology.
ONLYOFFICE Community Edition is an open source software that comprises Document Server, Community Server and Mail Server,
all to resolve the collaboration issues for both small and medium-sized teams.


## How it works?

ONLYOFFICE One Click Installation service connects to a remote Linux machine via SSH (https://www.nuget.org/packages/SSH.NET/ or http://sshnet.codeplex.com/) using the following provided user data: username with admin access rights, password or SSH key and the server IP address or full domain name, uploads the scripts from the 'Executables' folder and runs them:

The scripts are performing the following:

1. bash check-previous-version.sh  
checking the already existing data 

2. bash make-dir.sh 
creating the working directory /app/onlyoffice

3. bash get-os-info.sh  
getting the information about the currently used OS

4. bash check-ports.sh "80,443,5222,25,143,587"  
checking ports of the current computer

5. bash run-docker.sh "Ubuntu" "14.04" "3.13.0-36-generic" "x86_64"  
installing and running Docker

6. bash make-network.sh  
creating docker network

7. bash run-document-server.sh  
installing Document Server

8. bash run-mail-server.sh -d "domainName"  
installing Mail Server using the specified domain name

8. bash run-community-server.sh  
installing Community Server


Before running each script two commands need to be executed: 

chmod +x scriptPath  
sed -i 's/\r$//' scriptPath

where scriptPath is the path to the script (e.g. /app/onlyoffice/setup/tools/check-ports.sh)

This is used to correct the document formatting (\n\r issues in different operating systems)


## Project Information

Official website: [http://one-click-install.onlyoffice.com](http://one-click-install.onlyoffice.com "http://one-click-install.onlyoffice.com")

Code repository: [https://github.com/ONLYOFFICE/OneClickInstall](https://github.com/ONLYOFFICE/OneClickInstall "https://github.com/ONLYOFFICE/OneClickInstall")

License: [Apache v.2.0](http://www.apache.org/licenses/LICENSE-2.0 "Apache v.2.0")

ONLYOFFICE SaaS version: [http://www.onlyoffice.com](http://www.onlyoffice.com "http://www.onlyoffice.com")

ONLYOFFICE Open Source version: [http://www.onlyoffice.org](http://onlyoffice.org "http://www.onlyoffice.org")


## User Feedback and Support

If you have any problems with or questions about ONLYOFFICE One Click Installation, please visit our official forum to find answers to your questions: [dev.onlyoffice.org][1].

  [1]: http://dev.onlyoffice.org

  
  ##openvpn-install
OpenVPN [road warrior](http://en.wikipedia.org/wiki/Road_warrior_%28computing%29) installer for Debian, Ubuntu and CentOS.

This script will let you setup your own VPN server in no more than a minute, even if you haven't used OpenVPN before. It has been designed to be as unobtrusive and universal as possible.

###Installation
Run the script and follow the assistant:

`wget https://git.io/vpn -O openvpn-install.sh && bash openvpn-install.sh`

Once it ends, you can run it again to add more users, remove some of them or even completely uninstall OpenVPN.

###I want to run my own VPN but don't have a server for that
You can get a little VPS for just $2.99/month at [Bandwagon Host](https://bandwagonhost.com/aff.php?aff=575&pid=12).

###Donations

If you want to show your appreciation, you can donate via [PayPal](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=VBAYDL34Z7J6L) or [Bitcoin](https://www.coinbase.com/Nyr). Thanks!