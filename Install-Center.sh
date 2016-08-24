#!/bin/bash


function printMsg()
{
	echo -e "\n= = = = = = = = = = = = = = = = = = = = =\n$1\n= = = = = = = = = = = = = = = = = = = = =\n"
}

# arg 1: key, arg 2: value, arg 3: file
function ensureKeyValue()
{
    if [[ -z $(egrep -i ";? *$1 = [0-9]*[M]?" $3) ]]; then
        # add key-value pair
        echo "$1 = $2" >> $3
    else
        # replace existing key-value pair
        toreplace=`egrep -i ";? *$1 = [0-9]*[M]?" $3`
        sed $3 -i -e "s|$toreplace|$1 = $2|g"
    fi     
}

# arg 1: key, arg 2: value, arg 3: file
# make sure that a key-value pair is set in file
# key=value
function ensureKeyValueShort()
{
    if [[ -z $(egrep -i "#? *$1\s?=\s?""?[+|-]?[0-9]*[a-z]*"""? $3) ]]; then
        # add key-value pair
        echo "$1=""$2""" >> $3
    else
        # replace existing key-value pair
        toreplace=`egrep -i "#? *$1\s?=\s?""?[+|-]?[0-9]*[a-z]*"""? $3`
        sed $3 -i -e "s|$toreplace|$1=""$2""|g"
    fi     
}

function checkNeededPackages()
{
    doexit=0
    type -P git &>/dev/null && echo "Found git command." || { echo "Did not find git. Try 'sudo apt-get install -y git' first."; doexit=1; }
    type -P dialog &>/dev/null && echo "Found dialog command." || { echo "Did not find dialog. Try 'sudo apt-get install -y dialog' first."; doexit=1; }
    if [[ doexit -eq 1 ]]; then
        exit 1
    fi
}


function main_setservername()
{
    cmd=(dialog --backtitle "sethwahle.com - Ncurse Installer Utility." --inputbox "Please enter the URL of your Owncloud server." 22 76 $__servername)
    choices=$("${cmd[@]}" 2>&1 >/dev/tty)    
    if [ "$choices" != "" ]; then
        __servername=$choices

        if [[ -f /etc/nginx/sites-available/default ]]; then
          sed /etc/nginx/sites-available/default -r -e "s|server_name .*|server_name $__servername;|g"
        fi

    else
        break
    fi  
}

function install-onlyoffice()
{

# (c) Copyright Ascensio System Limited 2010-2015
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# You can contact Ascensio System SIA by email at sales@onlyoffice.com

COMMUNITY_CONTAINER_NAME="onlyoffice-community-server";
DOCUMENT_CONTAINER_NAME="onlyoffice-document-server";
MAIL_CONTAINER_NAME="onlyoffice-mail-server";
CONTROLPANEL_CONTAINER_NAME="onlyoffice-control-panel";

COMMUNITY_IMAGE_NAME="onlyoffice4enterprise/communityserver-ee";
DOCUMENT_IMAGE_NAME="onlyoffice4enterprise/documentserver-ee";
MAIL_IMAGE_NAME="onlyoffice/mailserver";
CONTROLPANEL_IMAGE_NAME="onlyoffice4enterprise/controlpanel-ee";

COMMUNITY_VERSION="";
DOCUMENT_VERSION="";
MAIL_VERSION="";
CONTROLPANEL_VERSION="";

MAIL_SERVER_HOST="";
DOCUMENT_SERVER_HOST="";

LICENSE_FILE_PATH="";
MAIL_DOMAIN_NAME="$__servername";

DIST="";
REV="";
KERNEL="";

AFTER_REBOOT="false";
UPDATE="false";

EMAIL="";
PASSWORD="";
USERNAME="";

INSTALL_COMMUNITY_SERVER="true"
INSTALL_DOCUMENT_SERVER="true"
INSTALL_MAIL_SERVER="true"
INSTALL_CONTROLPANEL="true"

PULL_COMMUNITY_SERVER="false"
PULL_DOCUMENT_SERVER="false"
PULL_MAIL_SERVER="false"
PULL_CONTROLPANEL="false"

USE_AS_EXTERNAL_SERVER="false"

while [ "$1" != "" ]; do
	case $1 in

		-cc | --communitycontainer )
			if [ "$2" != "" ]; then
				COMMUNITY_CONTAINER_NAME=$2
				shift
			fi
		;;

		-dc | --documentcontainer )
			if [ "$2" != "" ]; then
				DOCUMENT_CONTAINER_NAME=$2
				shift
			fi
		;;

		-mc | --mailcontainer )
			if [ "$2" != "" ]; then
				MAIL_CONTAINER_NAME=$2
				shift
			fi
		;;

		-cpc | --controlpanelcontainer )
			if [ "$2" != "" ]; then
				CONTROLPANEL_CONTAINER_NAME=$2
				shift
			fi
		;;

		-ci | --communityimage )
			if [ "$2" != "" ]; then
				COMMUNITY_IMAGE_NAME=$2
				shift
			fi
		;;

		-di | --documentimage )
			if [ "$2" != "" ]; then
				DOCUMENT_IMAGE_NAME=$2
				shift
			fi
		;;

		-mi | --mailimage )
			if [ "$2" != "" ]; then
				MAIL_IMAGE_NAME=$2
				shift
			fi
		;;

		-cpi | --controlpanelimage )
			if [ "$2" != "" ]; then
				CONTROLPANEL_IMAGE_NAME=$2
				shift
			fi
		;;

		-dip | --documentserverip  )
			if [ "$2" != "" ]; then
				DOCUMENT_SERVER_HOST=$2
				shift
			fi
		;;
		
		-mip | --mailserverip  )
			if [ "$2" != "" ]; then
				MAIL_SERVER_HOST=$2
				shift
			fi
		;;
		
		-cv | --communityversion )
			if [ "$2" != "" ]; then
				COMMUNITY_VERSION=$2
				shift
			fi
		;;

		-dv | --documentversion )
			if [ "$2" != "" ]; then
				DOCUMENT_VERSION=$2
				shift
			fi
		;;

		-mv | --mailversion )
			if [ "$2" != "" ]; then
				MAIL_VERSION=$2
				shift
			fi
		;;

		-cpv | --controlpanelversion )
			if [ "$2" != "" ]; then
				CONTROLPANEL_VERSION=$2
				shift
			fi
		;;

		-lf | --licensefile )
			if [ "$2" != "" ]; then
				LICENSE_FILE_PATH=$2
				shift
			fi
		;;

		-md | --maildomain )
			if [ "$2" != "" ]; then
				MAIL_DOMAIN_NAME=$2
				shift
			fi
		;;

		-ar | --afterreboot )
			if [ "$2" != "" ]; then
				AFTER_REBOOT=$2
				shift
			fi
		;;

		-u | --update )
			if [ "$2" != "" ]; then
				UPDATE=$2
				shift
			fi
		;;

		-e | --email )
			if [ "$2" != "" ]; then
				EMAIL=$2
				shift
			fi
		;;

		-p | --password )
			if [ "$2" != "" ]; then
				PASSWORD=$2
				shift
			fi
		;;

		-un | --username )
			if [ "$2" != "" ]; then
				USERNAME=$2
				shift
			fi
		;;

		-ics | --installcommunityserver )
			if [ "$2" != "" ]; then
				INSTALL_COMMUNITY_SERVER=$2
				shift
			fi
		;;

		-ids | --installdocumentserver )
			if [ "$2" != "" ]; then
				INSTALL_DOCUMENT_SERVER=$2
				shift
			fi
		;;

		-ims | --installmailserver )
			if [ "$2" != "" ]; then
				INSTALL_MAIL_SERVER=$2
				shift
			fi
		;;

		-icp | --installcontrolpanel )
			if [ "$2" != "" ]; then
				INSTALL_CONTROLPANEL=$2
				shift
			fi
		;;

		-pcs | --pullcommunityserver )
			if [ "$2" != "" ]; then
				PULL_COMMUNITY_SERVER=$2
				shift
			fi
		;;

		-pds | --pulldocumentserver )
			if [ "$2" != "" ]; then
				PULL_DOCUMENT_SERVER=$2
				shift
			fi
		;;

		-pms | --pullmailserver )
			if [ "$2" != "" ]; then
				PULL_MAIL_SERVER=$2
				shift
			fi
		;;

		-pcp | --pullcontrolpanel )
			if [ "$2" != "" ]; then
				PULL_CONTROLPANEL=$2
				shift
			fi
		;;
		
		-es | --useasexternalserver )
			if [ "$2" != "" ]; then
				USE_AS_EXTERNAL_SERVER=$2
				shift
			fi
		;;
		
		-? | -h | --help )
			echo "  Usage $0 [PARAMETER] [[PARAMETER], ...]"
			echo "    Parameters:"
			echo "      -cc, --communitycontainer         community container name"
			echo "      -dc, --documentcontainer          document container name"
			echo "      -mc, --mailcontainer              mail container name"
			echo "      -cpc, --controlpanelcontainer     control panel container name"
			echo "      -ci, --communityimage             community image name"
			echo "      -di, --documentimage              document image name"
			echo "      -mi, --mailimage                  mail image name"
			echo "      -cpi, --controlpanelimage         control panel image name"
			echo "      -cv, --communityversion           community version"
			echo "      -dv, --documentversion            document version"
			echo "      -dip, --documentserverip          document server ip"
			echo "      -mv, --mailversion                mail version"
			echo "      -mip, --mailserverip              mail server ip"
			echo "      -cpv, --controlpanelversion       control panel version"
			echo "      -lf, --licensefile                license file path"
			echo "      -md, --maildomain                 mail domail name"
			echo "      -ar, --afterreboot                use to continue installation after reboot (true|false)"
			echo "      -u, --update                      use to update existing components (true|false)"
			echo "      -e, --email                       dockerhub email"
			echo "      -p, --password                    dockerhub password"
			echo "      -un, --username                   dockerhub username"
			echo "      -ics, --installcommunityserver    install community server (true|false)"
			echo "      -ids, --installdocumentserver     install document server (true|false)"
			echo "      -ims, --installmailserver         install mail server (true|false)"
			echo "      -icp, --installcontrolpanel       install control panel (true|false)"
			echo "      -pcs, --pullcommunityserver       pull community server (true|false)"
			echo "      -pds, --pulldocumentserver        pull document server (true|false)"
			echo "      -pms, --pullmailserver            pull mail server (true|false)"
			echo "      -pcp, --pullcontrolpanel          pull control panel (true|false)"
			echo "      -es, --useasexternalserver        use as external server (true|false)"
			echo "      -?, -h, --help                    this help"
			echo
			exit 0
		;;

		* )
			echo "Unknown parameter $1" 1>&2
			exit 0
		;;
	esac
	shift
done



root_checking () {
	if [ ! $( id -u ) -eq 0 ]; then
		echo "To perform this action you must be logged in with root rights"
		exit 0;
	fi
}

command_exists () {
    type "$1" &> /dev/null;
}

file_exists () {
	if [ -z "$1" ]; then
		echo "file path is empty"
		exit 0;
	fi

	if [ -f "$1" ]; then
		return 0; #true
	else
		return 1; #false
	fi
}

install_sudo () {
	if command_exists apt-get; then
		apt-get install sudo 
	elif command_exists yum; then
		yum install sudo
	fi

	if ! command_exists sudo; then
		echo "command sudo not found"
		exit 0;
	fi
}

install_curl () {
	if command_exists apt-get; then
		sudo apt-get -y -q --force-yes install curl 
	elif command_exists yum; then
		sudo yum -y install curl
	fi

	if ! command_exists curl; then
		echo "command curl not found"
		exit 0;
	fi
}

to_lowercase () {
	echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

get_os_info () {
	OS=`to_lowercase \`uname\``

	if [ "${OS}" == "windowsnt" ]; then
		echo "Not supported OS";
		exit 0;
	elif [ "${OS}" == "darwin" ]; then
		echo "Not supported OS";
		exit 0;
	else
		OS=`uname`

		if [ "${OS}" = "SunOS" ] ; then
			echo "Not supported OS";
			exit 0;
		elif [ "${OS}" = "AIX" ] ; then
			echo "Not supported OS";
			exit 0;
		elif [ "${OS}" = "Linux" ] ; then
			MACH=`uname -m`

			if [ "${MACH}" != "x86_64" ]; then
				echo "Currently only supports 64bit OS's";
				exit 0;
			fi

			KERNEL=`uname -r`

			if [ -f /etc/redhat-release ] ; then
				DIST=`cat /etc/redhat-release |sed s/\ release.*//`
				REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/SuSE-release ] ; then
				REV=`cat /etc/os-release  | grep '^VERSION_ID' | awk -F=  '{ print $2 }'`
				DIST='SuSe'
			elif [ -f /etc/debian_version ] ; then
				REV=`cat /etc/debian_version`
				DIST='Debian'
				if [ -f /etc/lsb-release ] ; then
					DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
					REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
				elif [[ -f /etc/lsb_release ]]; then
					DIST=`lsb_release -a 2>&1 | grep 'Distributor ID:' | awk -F ":" '{print $2 }'`
					REV=`lsb_release -a 2>&1 | grep 'Release:' | awk -F ":" '{print $2 }'`
				fi
			fi
		fi
	fi
}

check_kernel () {
	if [[ -z ${KERNEL} ]]; then
		echo "Not supported OS";
		exit 0;
	fi
}

check_ports () {
	STR_PORTS="80, 443, 5222, 25, 143, 587"
	ARRAY_PORTS=(${STR_PORTS//,/ })

	for PORT in "${ARRAY_PORTS[@]}"
	do
		REGEXP=":$PORT$"
		CHECK_RESULT=$(sudo netstat -lnp | awk '{print $4}' | grep $REGEXP)

		if [[ $CHECK_RESULT != "" ]]; then
			echo "The following ports must be open: $PORT"
			exit 0;
		fi
	done
}

install_docker () {

	EXIT_STATUS=-1;
	EXIT_NOT_SUPPORTED_OS_STATUS=10;

	REV_PARTS=(${REV//\./ });
	REV=${REV_PARTS[0]};

	if [ "${DIST}" == "Ubuntu" ]; then

		if [ "${REV}" -ge "14" ]; then
			sudo apt-get -y update
			sudo apt-get -y upgrade
			sudo apt-get -y -q --force-yes install curl
			sudo curl -sSL https://get.docker.com/ | sh
		elif [ "${REV}" -eq "13" ]; then
			sudo apt-get -y update
			sudo apt-get -y upgrade
			sudo apt-get -y install linux-image-extra-`uname -r`
			sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
			sudo sh -c "echo deb http://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
			sudo apt-get -y update
			sudo apt-get -y install lxc-docker
		elif [ "${REV}" -eq "12" ]; then
			# install the backported kernel
			sudo apt-get -y update
			sudo apt-get -y -q --force-yes install linux-image-generic-lts-trusty

			# reboot
			if [ "${AFTER_REBOOT}" != "true" ] ; then
				echo "Please reboot your computer and run installation once again with parameter '--afterreboot true'"
				exit 0;
			fi

			sudo apt-get -y -q --force-yes update
			sudo apt-get -y -q --force-yes install wget
			sudo wget -qO- https://get.docker.com/ | sh

		else
			EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
		fi

	elif [ "${DIST}" == "Debian" ]; then

		if [ "${REV}" -ge "8" ]; then
			sudo apt-get -y update
			sudo apt-get -y upgrade
			sudo apt-get -y -q --force-yes install curl
			sudo curl -sSL https://get.docker.com/ | sh
		elif [ "${REV}" -eq "7" ]; then
			echo "deb http://http.debian.net/debian wheezy-backports main" >>  /etc/apt/sources.list
			sudo apt-get -y update
			sudo apt-get -y upgrade
			sudo apt-get -y -q --force-yes install curl
			sudo apt-get -y -q --force-yes install -t wheezy-backports linux-image-amd64 

			# reboot
			if [ "${AFTER_REBOOT}" != "true" ] ; then
				echo "Please reboot your computer and run installation once again with parameter '--afterreboot true'"
				exit 0;
			fi

			curl -sSL https://get.docker.com/ | sh
		else
			EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
		fi

	elif [[ "${DIST}" == CentOS* ]] || [ "${DIST}" == "Red Hat Enterprise Linux Server" ]; then

		if [ "${REV}" -ge "7" ]; then

			if [ "${DIST}" == "Red Hat Enterprise Linux Server" ]; then
				sudo yum -y install yum-utils
				sudo yum-config-manager --enable rhui-REGION-rhel-server-extras
			fi

			sudo yum -y update
			sudo yum -y upgrade
			sudo yum -y install curl
			sudo curl -O -sSL https://get.docker.com/rpm/1.7.1/centos-7/RPMS/x86_64/docker-engine-1.7.1-1.el7.centos.x86_64.rpm
			sudo yum -y localinstall --nogpgcheck docker-engine-1.7.1-1.el7.centos.x86_64.rpm
			sudo rm docker-engine-1.7.1-1.el7.centos.x86_64.rpm
			sudo service docker start
			sudo systemctl start docker.service
			sudo systemctl enable docker.service

		elif [ "${REV}" -eq "6" ]; then

			sudo yum -y update
			sudo yum -y upgrade
			sudo yum -y install curl
			sudo curl -O -sSL https://get.docker.com/rpm/1.7.1/centos-6/RPMS/x86_64/docker-engine-1.7.1-1.el6.x86_64.rpm
			sudo yum -y localinstall --nogpgcheck docker-engine-1.7.1-1.el6.x86_64.rpm
			sudo rm docker-engine-1.7.1-1.el6.x86_64.rpm
			sudo service docker start
			sudo chkconfig docker on

		else
			EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
		fi

	elif [ "${DIST}" == "SuSe" ]; then

		if [ "${REV}" -ge "13" ]; then
			sudo zypper ar -f http://download.opensuse.org/repositories/Virtualization/openSUSE_13.1/ Virtualization
			sudo zypper --non-interactive in docker
			sudo systemctl start docker
			sudo systemctl enable docker
		elif [ "${REV}" -ge "12" ]; then
			sudo zypper ar -f http://download.opensuse.org/repositories/Virtualization/openSUSE_12.3/ Virtualization
			sudo zypper --non-interactive in docker
			sudo systemctl start docker
			sudo systemctl enable docker
		else
			EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
		fi

	elif [ "${DIST}" == "Fedora" ]; then

		if [ "${REV}" -ge "22" ]; then

			sudo yum -y update
			sudo yum -y upgrade
			sudo yum -y install curl
			sudo curl -O -sSL https://get.docker.com/rpm/1.7.1/fedora-22/RPMS/x86_64/docker-engine-1.7.1-1.fc22.x86_64.rpm
			sudo yum -y install --nogpgcheck docker-engine-1.7.1-1.fc22.x86_64.rpm
			sudo rm docker-engine-1.7.1-1.fc22.x86_64.rpm
			sudo service docker start
			sudo systemctl start docker.service
			sudo systemctl enable docker.service

		elif [ "${REV}" -ge "21" ]; then

			sudo yum -y update
			sudo yum -y upgrade
			sudo yum -y install curl
			sudo curl -O -sSL https://get.docker.com/rpm/1.7.1/fedora-21/RPMS/x86_64/docker-engine-1.7.1-1.fc21.x86_64.rpm
			sudo yum -y localinstall --nogpgcheck docker-engine-1.7.1-1.fc21.x86_64.rpm
			sudo rm docker-engine-1.7.1-1.fc21.x86_64.rpm
			sudo service docker start
			sudo systemctl start docker.service
			sudo systemctl enable docker.service

		elif [ "${REV}" -eq "20" ]; then

			sudo yum -y update
			sudo yum -y upgrade
			sudo yum -y install curl
			sudo curl -O -sSL https://get.docker.com/rpm/1.7.1/fedora-20/RPMS/x86_64/docker-engine-1.7.1-1.fc20.x86_64.rpm
			sudo yum -y localinstall --nogpgcheck docker-engine-1.7.1-1.fc20.x86_64.rpm
			sudo rm docker-engine-1.7.1-1.fc20.x86_64.rpm
			sudo service docker start
			sudo systemctl start docker.service
			sudo systemctl enable docker.service

		else
			EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
		fi

	else
		EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
	fi

	if [ ${EXIT_STATUS} -eq ${EXIT_NOT_SUPPORTED_OS_STATUS} ]; then
		echo "Not supported OS"
		exit 0;
	fi

	if ! command_exists docker ; then
		echo "error while installing docker"
		exit 0;
	fi
}

docker_login () {
	if [[ -n ${EMAIL} && -n ${PASSWORD} && -n ${USERNAME}  ]]; then
		sudo docker login -e ${EMAIL} -p ${PASSWORD} -u ${USERNAME}
	fi
}

make_directories () {
	sudo mkdir -p "/app/onlyoffice/setup";

	sudo mkdir -p "/app/onlyoffice/DocumentServer/data";
	sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/FileConverterService";
	sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/CoAuthoringService";
	sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/DocService";
	sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/SpellCheckerService";
	sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/LibreOfficeService";

	sudo mkdir -p "/app/onlyoffice/MailServer/data/certs";
	sudo mkdir -p "/app/onlyoffice/MailServer/logs";
	sudo mkdir -p "/app/onlyoffice/MailServer/mysql";

	sudo mkdir -p "/app/onlyoffice/CommunityServer/data";
	sudo mkdir -p "/app/onlyoffice/CommunityServer/logs";
	sudo mkdir -p "/app/onlyoffice/CommunityServer/mysql";

	sudo mkdir -p "/app/onlyoffice/ControlPanel/data";
	sudo mkdir -p "/app/onlyoffice/ControlPanel/logs";
	sudo mkdir -p "/app/onlyoffice/ControlPanel/mysql";

	sudo chmod 777 /app -R
}

copy_license () {
	if [[ -n "${LICENSE_FILE_PATH}" ]]; then

		if ! file_exists "${LICENSE_FILE_PATH}"; then
			echo "License file is not exist";
			exit 0;
		fi

		cp "${LICENSE_FILE_PATH}" "/app/onlyoffice/DocumentServer/data/license.lic";
		cp "${LICENSE_FILE_PATH}" "/app/onlyoffice/MailServer/data/license.lic";
		cp "${LICENSE_FILE_PATH}" "/app/onlyoffice/CommunityServer/data/license.lic";
		cp "${LICENSE_FILE_PATH}" "/app/onlyoffice/ControlPanel/data/license.lic";

	fi
}

get_available_version () {
	if [[ -z "$1" ]]; then
		echo "image name is empty";
		exit 0;
	fi

	if ! command_exists curl ; then
		install_curl;
	fi

	RUN_COMMAND="curl -s https://registry.hub.docker.com/v1/repositories/$1/tags";

	if [[ -n ${EMAIL} && -n ${PASSWORD} ]]; then
		RUN_COMMAND="$RUN_COMMAND --basic -u $EMAIL:$PASSWORD";
	fi

	listVersion=$(${RUN_COMMAND});

	if [[ $listVersion != "["* ]]; then
		echo "invalid version list";
		exit 0;
	fi

	splitListVersion=$(echo $listVersion | tr -d '[]{},:"')
	regex="[0-9]+\.[0-9]+\.[0-9]+"
	versionList=""

	for v in $splitListVersion
	do
		if [[ $v =~ $regex ]]; then
			versionList="$v,$versionList"
		fi
	done

	version=$(echo $versionList | tr ',' '\n' | sort -t. -k 1,1n -k 2,2n -k 3,3n | awk '/./{line=$0} END{print line}');

	echo "$version"
}

check_bindings () {
	if [[ -z "$1" ]]; then
		echo "container id is empty";
		exit 0;
	fi

	binds=$(sudo docker inspect --format='{{range $p,$conf:=.HostConfig.Binds}}{{$conf}};{{end}}' $1)
	volumes=$(sudo docker inspect --format='{{range $p,$conf:=.Config.Volumes}}{{$p}};{{end}}' $1)
	arrBinds=$(echo $binds | tr ";" "\n")
	arrVolumes=$(echo $volumes | tr ";" "\n")
	bindsCorrect=1

	for volume in $arrVolumes
	do
		bindExist=0
		for bind in $arrBinds
		do
		   bind=($(echo $bind | tr ":" " "))
		   if [ "${bind[1]}" == "${volume}" ]; then
			 bindExist=1
		   fi
		done
		if [ "$bindExist" = "0" ]; then
			bindsCorrect=0
			echo "${volume} not binded"
		fi
	done

	if [ "$bindsCorrect" = "0" ]; then
		exit 0;
	fi
}

install_document_server () {

	DOCUMENT_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${DOCUMENT_CONTAINER_NAME});
    DOCUMENT_SERVER_ADDITIONAL_PORTS="";

	if [[ -n ${DOCUMENT_SERVER_ID} ]]; then
		if [ "$UPDATE" == "true" ]; then
			check_bindings $DOCUMENT_SERVER_ID;
			sudo docker stop ${DOCUMENT_SERVER_ID};
			sudo docker rm ${DOCUMENT_SERVER_ID};
		else
			echo "ONLYOFFICE DOCUMENT SERVER is already installed."
			sudo docker start ${DOCUMENT_SERVER_ID};
		fi
	fi

	if [[ -z ${DOCUMENT_VERSION} ]]; then
		DOCUMENT_VERSION=$(get_available_version "$DOCUMENT_IMAGE_NAME");
	fi

	if [ "${USE_AS_EXTERNAL_SERVER}" == "true" ]; then
		DOCUMENT_SERVER_ADDITIONAL_PORTS="-p 80:80 -p 443:443";
	fi
	sudo docker run -i -t -d --restart=always --name ${DOCUMENT_CONTAINER_NAME} ${DOCUMENT_SERVER_ADDITIONAL_PORTS} \
	-v /app/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data \
	-v /app/onlyoffice/DocumentServer/logs:/var/log/onlyoffice \
	${DOCUMENT_IMAGE_NAME}:${DOCUMENT_VERSION}

	DOCUMENT_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${DOCUMENT_CONTAINER_NAME});

	if [[ -z ${DOCUMENT_SERVER_ID} ]]; then
		echo "ONLYOFFICE DOCUMENT SERVER not installed."
		exit 0;
	fi
}

install_mail_server () {
	MAIL_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${MAIL_CONTAINER_NAME});

	MAIL_SERVER_ADDITIONAL_PORTS="";
	
	if [[ -n ${MAIL_SERVER_ID} ]]; then
		if [ "$UPDATE" == "true" ]; then
			check_bindings $MAIL_SERVER_ID;
			sudo docker stop ${MAIL_SERVER_ID};
			sudo docker rm ${MAIL_SERVER_ID};
		else
			echo "ONLYOFFICE MAIL SERVER is already installed."
			sudo docker start ${MAIL_SERVER_ID};
		fi
	fi

	if [[ -z ${MAIL_VERSION} ]]; then
		MAIL_VERSION=$(get_available_version "$MAIL_IMAGE_NAME");
	fi
		
	if [ "${USE_AS_EXTERNAL_SERVER}" == "true" ]; then
		MAIL_SERVER_ADDITIONAL_PORTS="-p 3306:3306 -p 8081:8081";
	fi
	
	RUN_COMMAND="sudo docker run --privileged -i -t -d --restart=always --name ${MAIL_CONTAINER_NAME} ${MAIL_SERVER_ADDITIONAL_PORTS} -p 25:25 -p 143:143 -p 587:587";
	RUN_COMMAND="${RUN_COMMAND} -v /app/onlyoffice/MailServer/data:/var/vmail";
	RUN_COMMAND="${RUN_COMMAND} -v /app/onlyoffice/MailServer/data/certs:/etc/pki/tls/mailserver";
	RUN_COMMAND="${RUN_COMMAND} -v /app/onlyoffice/MailServer/logs:/var/log";
	RUN_COMMAND="${RUN_COMMAND} -v /app/onlyoffice/MailServer/mysql:/var/lib/mysql";
	
	if [ "$UPDATE" != "true" ]; then

		if  [[ -z ${MAIL_DOMAIN_NAME} ]]; then
			echo "Please, set domain name for mail server"
			exit 0;
		fi
		
		RUN_COMMAND="${RUN_COMMAND} -h ${MAIL_DOMAIN_NAME} ${MAIL_IMAGE_NAME}:${MAIL_VERSION}";
	else
		RUN_COMMAND="${RUN_COMMAND} ${MAIL_IMAGE_NAME}:${MAIL_VERSION}";
	fi

	${RUN_COMMAND};
	
	MAIL_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${MAIL_CONTAINER_NAME});

	if [[ -z ${MAIL_SERVER_ID} ]]; then
		echo "ONLYOFFICE MAIL SERVER not installed."
		exit 0;
	fi
}

install_controlpanel () {
	CONTROL_PANEL_ID=$(sudo docker inspect --format='{{.Id}}' ${CONTROLPANEL_CONTAINER_NAME});

	CONTROLPANEL_ADDITIONS_PARAMS="";
	
	if [[ -n ${CONTROL_PANEL_ID} ]]; then
		if [ "$UPDATE" == "true" ]; then
			check_bindings $CONTROL_PANEL_I#/bin/bashD;
			OLD_CONTROLPANEL_CONTAINER_NAME="${CONTROLPANEL_CONTAINER_NAME}_$RANDOM";
			sudo docker rename ${CONTROLPANEL_CONTAINER_NAME} ${OLD_CONTROLPANEL_CONTAINER_NAME};
		else
			echo "ONLYOFFICE CONTROL PANEL is already installed."
			sudo docker start ${CONTROL_PANEL_ID};
		fi
	fi

	if [[ -z ${CONTROLPANEL_VERSION} ]]; then
		CONTROLPANEL_VERSION=$(get_available_version "$CONTROLPANEL_IMAGE_NAME");
	fi

	if [[ -n ${MAIL_SERVER_HOST} ]]; then
		CONTROLPANEL_ADDITIONS_PARAMS="${CONTROLPANEL_ADDITIONS_PARAMS} -e MAIL_SERVER_EXTERNAL=true";
	fi

	if [[ -n ${DOCUMENT_SERVER_HOST} ]]; then
		CONTROLPANEL_ADDITIONS_PARAMS="${CONTROLPANEL_ADDITIONS_PARAMS} -e DOCUMENT_SERVER_EXTERNAL=true";	
	fi
	
	if [[ -n ${COMMUNITY_SERVER_HOST} ]]; then
		CONTROLPANEL_ADDITIONS_PARAMS="${CONTROLPANEL_ADDITIONS_PARAMS} -e COMMUNITY_SERVER_EXTERNAL=true";
	fi

	 sudo docker run -i -t -d --restart=always --name ${CONTROLPANEL_CONTAINER_NAME} ${CONTROLPANEL_ADDITIONS_PARAMS} \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /app/onlyoffice/CommunityServer/data:/app/onlyoffice/CommunityServer/data \
	-v /app/onlyoffice/DocumentServer/data:/app/onlyoffice/DocumentServer/data \
	-v /app/onlyoffice/MailServer/data:/app/onlyoffice/MailServer/data \
	-v /app/onlyoffice/ControlPanel/data:/var/www/onlyoffice-controlpanel/Data \
	-v /app/onlyoffice/ControlPanel/logs:/var/log/onlyoffice-controlpanel \
	-v /app/onlyoffice/ControlPanel/mysql:/var/lib/mysql \
	 ${CONTROLPANEL_IMAGE_NAME}:${CONTROLPANEL_VERSION}

	CONTROL_PANEL_ID=$(sudo docker inspect --format='{{.Id}}' ${CONTROLPANEL_CONTAINER_NAME});

	if [[ -z ${CONTROL_PANEL_ID} ]]; then
		echo "ONLYOFFICE CONTROL PANEL not installed."
		exit 0;
	fi

	if [[ -n ${OLD_CONTROLPANEL_CONTAINER_NAME} ]]; then
		docker rm -f ${OLD_CONTROLPANEL_CONTAINER_NAME}
	fi
}

install_community_server () {
	COMMUNITY_PORT=80
	COMMUNITY_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${COMMUNITY_CONTAINER_NAME});
	DOCUMENT_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${DOCUMENT_CONTAINER_NAME});
	MAIL_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${MAIL_CONTAINER_NAME});
	CONTROL_PANEL_ID=$(sudo docker inspect --format='{{.Id}}' ${CONTROLPANEL_CONTAINER_NAME});

	if [[ -n ${COMMUNITY_SERVER_ID} ]]; then
		if [ "$UPDATE" == "true" ]; then
			check_bindings $COMMUNITY_SERVER_ID;
			COMMUNITY_PORT=$(sudo docker port $COMMUNITY_SERVER_ID 80 | sed 's/.*://')
			sudo docker stop ${COMMUNITY_SERVER_ID};
			sudo docker rm ${COMMUNITY_SERVER_ID};
		else
			echo "ONLYOFFICE COMMUNITY SERVER is already installed."
			sudo docker start ${COMMUNITY_SERVER_ID};
		fi
	fi

	RUN_COMMAND="sudo docker run --name $COMMUNITY_CONTAINER_NAME -i -t -d --restart=always -p $COMMUNITY_PORT:80 -p 443:443 -p 5222:5222";

	if [[ -n ${MAIL_SERVER_HOST} ]]; then
		RUN_COMMAND="$RUN_COMMAND  -e MAIL_SERVER_DB_HOST='${MAIL_SERVER_HOST}'";
	fi

	if [[ -n ${DOCUMENT_SERVER_HOST} ]]; then
		RUN_COMMAND="$RUN_COMMAND  -e DOCUMENT_SERVER_HOST='${DOCUMENT_SERVER_HOST}'";
	fi
	
	if [[ -n ${DOCUMENT_SERVER_ID} ]]; then
		RUN_COMMAND="$RUN_COMMAND  --link $DOCUMENT_CONTAINER_NAME:document_server";
	fi

	if [[ -n ${MAIL_SERVER_ID} ]]; then
		RUN_COMMAND="$RUN_COMMAND  --link $MAIL_CONTAINER_NAME:mail_server";
	fi

	if [[ -n ${CONTROL_PANEL_ID} ]]; then
		RUN_COMMAND="$RUN_COMMAND  --link $CONTROLPANEL_CONTAINER_NAME:control_panel";
	fi

	if [[ -z ${COMMUNITY_VERSION} ]]; then
		COMMUNITY_VERSION=$(get_available_version "$COMMUNITY_IMAGE_NAME");
	fi

	RUN_COMMAND="$RUN_COMMAND -v /app/onlyoffice/CommunityServer/data:/var/www/onlyoffice/Data -v /app/onlyoffice/CommunityServer/mysql:/var/lib/mysql -v /app/onlyoffice/CommunityServer/logs:/var/log/onlyoffice $COMMUNITY_IMAGE_NAME:$COMMUNITY_VERSION";

	${RUN_COMMAND};

	COMMUNITY_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${COMMUNITY_CONTAINER_NAME});

	if [[ -z ${COMMUNITY_SERVER_ID} ]]; then
		echo "ONLYOFFICE COMMUNITY SERVER not installed."
		exit 0;
	fi
}

pull_document_server () {

	if [[ -z ${DOCUMENT_VERSION} ]]; then
		DOCUMENT_VERSION=$(get_available_version "$DOCUMENT_IMAGE_NAME");
	fi

	sudo docker pull ${DOCUMENT_IMAGE_NAME}:${DOCUMENT_VERSION}
}

pull_mail_server () {

	if [[ -z ${MAIL_VERSION} ]]; then
		MAIL_VERSION=$(get_available_version "$MAIL_IMAGE_NAME");
	fi

	sudo docker pull ${MAIL_IMAGE_NAME}:${MAIL_VERSION}
}

pull_controlpanel () {

	if [[ -z ${CONTROLPANEL_VERSION} ]]; then
		CONTROLPANEL_VERSION=$(get_available_version "$CONTROLPANEL_IMAGE_NAME");
	fi

	sudo docker pull ${CONTROLPANEL_IMAGE_NAME}:${CONTROLPANEL_VERSION}
}

pull_community_server () {

	if [[ -z ${COMMUNITY_VERSION} ]]; then
		COMMUNITY_VERSION=$(get_available_version "$COMMUNITY_IMAGE_NAME");
	fi

	sudo docker pull ${COMMUNITY_IMAGE_NAME}:${COMMUNITY_VERSION}
}

start_installation () {
	root_checking

	if ! command_exists sudo ; then
		install_sudo;
	fi

	get_os_info

	check_kernel

	if [ "$UPDATE" != "true" ]; then
		check_ports
	fi

	if ! command_exists docker ; then
		install_docker;
	fi

	docker_login

	make_directories

	copy_license

	if [ "$INSTALL_DOCUMENT_SERVER" == "true" ]; then
		install_document_server
	elif [ "$PULL_DOCUMENT_SERVER" == "true" ]; then
		pull_document_server
	fi

	if [ "$INSTALL_MAIL_SERVER" == "true" ]; then
		install_mail_server
	elif [ "$PULL_MAIL_SERVER" == "true" ]; then
		pull_mail_server
	fi

	if [ "$INSTALL_CONTROLPANEL" == "true" ]; then
		install_controlpanel
	elif [ "$PULL_CONTROLPANEL" == "true" ]; then
		pull_controlpanel
	fi

	if [ "$INSTALL_COMMUNITY_SERVER" == "true" ]; then
		install_community_server
	elif [ "$PULL_COMMUNITY_SERVER" == "true" ]; then
		pull_community_server
	fi

	echo "Installation complete"
	exit 0;
}



start_installation

}

function install-jitsi()
{
clear
apt-get install git nginx npm nodejs-legacy make -y
cd /var/www/html
git clone https://github.com/jitsi/jitsi-meet.git
mv jitsi-meet/ meet
cd meet
npm install
make

echo "finish the jitsi script you slacker!!!"

}

function install-gitlab()
{
clear
sudo apt-get install curl openssh-server ca-certificates postfix -y
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt-get install gitlab-ce
sudo gitlab-ctl reconfigure
}

function install-openvpn()
{
#!/bin/bash
# OpenVPN road warrior installer for Debian, Ubuntu and CentOS

# This script will work on Debian, Ubuntu, CentOS and probably other distros
# of the same families, although no support is offered for them. It isn't
# bulletproof but it will probably work if you simply want to setup a VPN on
# your Debian/Ubuntu/CentOS box. It has been designed to be as unobtrusive and
# universal as possible.


# Detect Debian users running the script with "sh" instead of bash
if readlink /proc/$$/exe | grep -qs "dash"; then
	echo "This script needs to be run with bash, not sh"
	exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 2
fi

if [[ ! -e /dev/net/tun ]]; then
	echo "TUN is not available"
	exit 3
fi

if grep -qs "CentOS release 5" "/etc/redhat-release"; then
	echo "CentOS 5 is too old and not supported"
	exit 4
fi
if [[ -e /etc/debian_version ]]; then
	OS=debian
	GROUPNAME=nogroup
	RCLOCAL='/etc/rc.local'
elif [[ -e /etc/centos-release || -e /etc/redhat-release ]]; then
	OS=centos
	GROUPNAME=nobody
	RCLOCAL='/etc/rc.d/rc.local'
	# Needed for CentOS 7
	chmod +x /etc/rc.d/rc.local
else
	echo "Looks like you aren't running this installer on a Debian, Ubuntu or CentOS system"
	exit 5
fi

newclient () {
	# Generates the custom client.ovpn
	cp /etc/openvpn/client-common.txt ~/$1.ovpn
	echo "<ca>" >> ~/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/ca.crt >> ~/$1.ovpn
	echo "</ca>" >> ~/$1.ovpn
	echo "<cert>" >> ~/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/issued/$1.crt >> ~/$1.ovpn
	echo "</cert>" >> ~/$1.ovpn
	echo "<key>" >> ~/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/private/$1.key >> ~/$1.ovpn
	echo "</key>" >> ~/$1.ovpn
	echo "<tls-auth>" >> ~/$1.ovpn
	cat /etc/openvpn/ta.key >> ~/$1.ovpn
	echo "</tls-auth>" >> ~/$1.ovpn
}

# Try to get our IP from the system and fallback to the Internet.
# I do this to make the script compatible with NATed servers (lowendspirit.com)
# and to avoid getting an IPv6.
IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
		IP=$(wget -qO- ipv4.icanhazip.com)
fi

if [[ -e /etc/openvpn/server.conf ]]; then
	while :
	do
	clear
		echo "Looks like OpenVPN is already installed"
		echo ""
		echo "What do you want to do?"
		echo "   1) Add a cert for a new user"
		echo "   2) Revoke existing user cert"
		echo "   3) Remove OpenVPN"
		echo "   4) Exit"
		read -p "Select an option [1-4]: " option
		case $option in
			1) 
			echo ""
			echo "Tell me a name for the client cert"
			echo "Please, use one word only, no special characters"
			read -p "Client name: " -e -i client CLIENT
			cd /etc/openvpn/easy-rsa/
			./easyrsa build-client-full $CLIENT nopass
			# Generates the custom client.ovpn
			newclient "$CLIENT"
			echo ""
			echo "Client $CLIENT added, certs available at ~/$CLIENT.ovpn"
			exit
			;;
			2)
			# This option could be documented a bit better and maybe even be simplimplified
			# ...but what can I say, I want some sleep too
			NUMBEROFCLIENTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c "^V")
			if [[ "$NUMBEROFCLIENTS" = '0' ]]; then
				echo ""
				echo "You have no existing clients!"
				exit 6
			fi
			echo ""
			echo "Select the existing client certificate you want to revoke"
			tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | nl -s ') '
			if [[ "$NUMBEROFCLIENTS" = '1' ]]; then
				read -p "Select one client [1]: " CLIENTNUMBER
			else
				read -p "Select one client [1-$NUMBEROFCLIENTS]: " CLIENTNUMBER
			fi
			CLIENT=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | sed -n "$CLIENTNUMBER"p)
			cd /etc/openvpn/easy-rsa/
			./easyrsa --batch revoke $CLIENT
			./easyrsa gen-crl
			rm -rf pki/reqs/$CLIENT.req
			rm -rf pki/private/$CLIENT.key
			rm -rf pki/issued/$CLIENT.crt
			rm -rf /etc/openvpn/crl.pem
			cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem
			# CRL is read with each client connection, when OpenVPN is dropped to nobody
			chown nobody:$GROUPNAME /etc/openvpn/crl.pem
			echo ""
			echo "Certificate for client $CLIENT revoked"
			exit
			;;
			3) 
			echo ""
			read -p "Do you really want to remove OpenVPN? [y/n]: " -e -i n REMOVE
			if [[ "$REMOVE" = 'y' ]]; then
				PORT=$(grep '^port ' /etc/openvpn/server.conf | cut -d " " -f 2)
				if pgrep firewalld; then
					# Using both permanent and not permanent rules to avoid a firewalld reload.
					firewall-cmd --zone=public --remove-port=$PORT/udp
					firewall-cmd --zone=trusted --remove-source=10.8.0.0/24
					firewall-cmd --permanent --zone=public --remove-port=$PORT/udp
					firewall-cmd --permanent --zone=trusted --remove-source=10.8.0.0/24
				fi
				if iptables -L | grep -qE 'REJECT|DROP'; then
					sed -i "/iptables -I INPUT -p udp --dport $PORT -j ACCEPT/d" $RCLOCAL
					sed -i "/iptables -I FORWARD -s 10.8.0.0\/24 -j ACCEPT/d" $RCLOCAL
					sed -i "/iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT/d" $RCLOCAL
				fi
				sed -i '/iptables -t nat -A POSTROUTING -s 10.8.0.0\/24 -j SNAT --to /d' $RCLOCAL
				if hash sestatus 2>/dev/null; then
					if sestatus | grep "Current mode" | grep -qs "enforcing"; then
						if [[ "$PORT" != '1194' ]]; then
							semanage port -d -t openvpn_port_t -p udp $PORT
						fi
					fi
				fi
				if [[ "$OS" = 'debian' ]]; then
					apt-get remove --purge -y openvpn openvpn-blacklist
				else
					yum remove openvpn -y
				fi
				rm -rf /etc/openvpn
				rm -rf /usr/share/doc/openvpn*
				echo ""
				echo "OpenVPN removed!"
			else
				echo ""
				echo "Removal aborted!"
			fi
			exit
			;;
			4) exit;;
		esac
	done
else
	clear
	echo 'Welcome to this quick OpenVPN "road warrior" installer'
	echo ""
	# OpenVPN setup and first user creation
	echo "I need to ask you a few questions before starting the setup"
	echo "You can leave the default options and just press enter if you are ok with them"
	echo ""
	echo "First I need to know the IPv4 address of the network interface you want OpenVPN"
	echo "listening to."
	read -p "IP address: " -e -i $IP IP
	echo ""
	echo "What port do you want for OpenVPN?"
	read -p "Port: " -e -i 1194 PORT
	echo ""
	echo "What DNS do you want to use with the VPN?"
	echo "   1) Current system resolvers"
	echo "   2) Google"
	echo "   3) OpenDNS"
	echo "   4) NTT"
	echo "   5) Hurricane Electric"
	echo "   6) Verisign"
	read -p "DNS [1-6]: " -e -i 1 DNS
	echo ""
	echo "Finally, tell me your name for the client cert"
	echo "Please, use one word only, no special characters"
	read -p "Client name: " -e -i client CLIENT
	echo ""
	echo "Okay, that was all I needed. We are ready to setup your OpenVPN server now"
	read -n1 -r -p "Press any key to continue..."
		if [[ "$OS" = 'debian' ]]; then
		apt-get update
		apt-get install openvpn iptables openssl ca-certificates -y
	else
		# Else, the distro is CentOS
		yum install epel-release -y
		yum install openvpn iptables openssl wget ca-certificates -y
	fi
	# An old version of easy-rsa was available by default in some openvpn packages
	if [[ -d /etc/openvpn/easy-rsa/ ]]; then
		rm -rf /etc/openvpn/easy-rsa/
	fi
	# Get easy-rsa
	wget -O ~/EasyRSA-3.0.1.tgz https://github.com/OpenVPN/easy-rsa/releases/download/3.0.1/EasyRSA-3.0.1.tgz
	tar xzf ~/EasyRSA-3.0.1.tgz -C ~/
	mv ~/EasyRSA-3.0.1/ /etc/openvpn/
	mv /etc/openvpn/EasyRSA-3.0.1/ /etc/openvpn/easy-rsa/
	chown -R root:root /etc/openvpn/easy-rsa/
	rm -rf ~/EasyRSA-3.0.1.tgz
	cd /etc/openvpn/easy-rsa/
	# Create the PKI, set up the CA, the DH params and the server + client certificates
	./easyrsa init-pki
	./easyrsa --batch build-ca nopass
	./easyrsa gen-dh
	./easyrsa build-server-full server nopass
	./easyrsa build-client-full $CLIENT nopass
	./easyrsa gen-crl
	# Move the stuff we need
	cp pki/ca.crt pki/private/ca.key pki/dh.pem pki/issued/server.crt pki/private/server.key /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn
	# CRL is read with each client connection, when OpenVPN is dropped to nobody
	chown nobody:$GROUPNAME /etc/openvpn/crl.pem
	# Generate key for tls-auth
	openvpn --genkey --secret /etc/openvpn/ta.key
	# Generate server.conf
	echo "port $PORT
proto udp
dev tun
sndbuf 0
rcvbuf 0
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt" > /etc/openvpn/server.conf
	echo 'push "redirect-gateway def1 bypass-dhcp"' >> /etc/openvpn/server.conf
	# DNS
	case $DNS in
		1) 
		# Obtain the resolvers from resolv.conf and use them for OpenVPN
		grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
			echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server.conf
		done
		;;
		2) 
		echo 'push "dhcp-option DNS 8.8.8.8"' >> /etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 8.8.4.4"' >> /etc/openvpn/server.conf
		;;
		3)
		echo 'push "dhcp-option DNS 208.67.222.222"' >> /etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 208.67.220.220"' >> /etc/openvpn/server.conf
		;;
		4) 
		echo 'push "dhcp-option DNS 129.250.35.250"' >> /etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 129.250.35.251"' >> /etc/openvpn/server.conf
		;;
		5) 
		echo 'push "dhcp-option DNS 74.82.42.42"' >> /etc/openvpn/server.conf
		;;
		6) 
		echo 'push "dhcp-option DNS 64.6.64.6"' >> /etc/openvpn/server.conf
		echo 'push "dhcp-option DNS 64.6.65.6"' >> /etc/openvpn/server.conf
		;;
	esac
	echo "keepalive 10 120
cipher AES-128-CBC
comp-lzo
user nobody
group $GROUPNAME
persist-key
persist-tun
status openvpn-status.log
verb 3
crl-verify crl.pem" >> /etc/openvpn/server.conf
	# Enable net.ipv4.ip_forward for the system
	if [[ "$OS" = 'debian' ]]; then
		sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
	else
		# CentOS 5 and 6
		sed -i 's|net.ipv4.ip_forward = 0|net.ipv4.ip_forward = 1|' /etc/sysctl.conf
		# CentOS 7
		if ! grep -q "net.ipv4.ip_forward=1" "/etc/sysctl.conf"; then
			echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
		fi
	fi
	# Avoid an unneeded reboot
	echo 1 > /proc/sys/net/ipv4/ip_forward
	# Set NAT for the VPN subnet
	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP
	sed -i "1 a\iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP" $RCLOCAL
	if pgrep firewalld; then
		# We don't use --add-service=openvpn because that would only work with
		# the default port. Using both permanent and not permanent rules to
		# avoid a firewalld reload.
		firewall-cmd --zone=public --add-port=$PORT/udp
		firewall-cmd --zone=trusted --add-source=10.8.0.0/24
		firewall-cmd --permanent --zone=public --add-port=$PORT/udp
		firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
	fi
	if iptables -L | grep -qE 'REJECT|DROP'; then
		# If iptables has at least one REJECT rule, we asume this is needed.
		# Not the best approach but I can't think of other and this shouldn't
		# cause problems.
		iptables -I INPUT -p udp --dport $PORT -j ACCEPT
		iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
		iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
		sed -i "1 a\iptables -I INPUT -p udp --dport $PORT -j ACCEPT" $RCLOCAL
		sed -i "1 a\iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT" $RCLOCAL
		sed -i "1 a\iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" $RCLOCAL
	fi
	# If SELinux is enabled and a custom port was selected, we need this
	if hash sestatus 2>/dev/null; then
		if sestatus | grep "Current mode" | grep -qs "enforcing"; then
			if [[ "$PORT" != '1194' ]]; then
				# semanage isn't available in CentOS 6 by default
				if ! hash semanage 2>/dev/null; then
					yum install policycoreutils-python -y
				fi
				semanage port -a -t openvpn_port_t -p udp $PORT
			fi
		fi
	fi
	# And finally, restart OpenVPN
	if [[ "$OS" = 'debian' ]]; then
		# Little hack to check for systemd
		if pgrep systemd-journal; then
			systemctl restart openvpn@server.service
		else
			/etc/init.d/openvpn restart
		fi
	else
		if pgrep systemd-journal; then
			systemctl restart openvpn@server.service
			systemctl enable openvpn@server.service
		else
			service openvpn restart
			chkconfig openvpn on
		fi
	fi
	# Try to detect a NATed connection and ask about it to potential LowEndSpirit users
	EXTERNALIP=$(wget -qO- ipv4.icanhazip.com)
	if [[ "$IP" != "$EXTERNALIP" ]]; then
		echo ""
		echo "Looks like your server is behind a NAT!"
		echo ""
		echo "If your server is NATed (e.g. LowEndSpirit), I need to know the external IP"
		echo "If that's not the case, just ignore this and leave the next field blank"
		read -p "External IP: " -e USEREXTERNALIP
		if [[ "$USEREXTERNALIP" != "" ]]; then
			IP=$USEREXTERNALIP
		fi
	fi
	# client-common.txt is created so we have a template to add further users later
	echo "client
dev tun
proto udp
sndbuf 0
rcvbuf 0
remote $IP $PORT
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-128-CBC
comp-lzo
setenv opt block-outside-dns
key-direction 1
verb 3" > /etc/openvpn/client-common.txt
	# Generates the custom client.ovpn
	newclient "$CLIENT"
	echo ""
	echo "Finished!"
	echo ""
	echo "Your client config is available at ~/$CLIENT.ovpn"
	echo "If you want to add more clients, you simply need to run this script another time!"
fi

clear
dialog --backtitle "sethwahle.com - Ncurse Installer Utility." --msgbox "Finished installing OpenVPN." 20 60
}

function install-letsencrypt()
{

sudo apt-get update
sudo apt-get install git 
sudo git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
cd /opt/letsencrypt
./letsencrypt-auto --apache -d example.com

#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "30 2 * * 1 /opt/letsencrypt/letsencrypt-auto renew >> /var/log/le-renew.log" >> mycron
#install new cron file
crontab mycron
rm mycron

dialog --backtitle "sethwahle.com - Ncurse Installer Utility." --msgbox "Finished installing Lets Ecnrypt." 20 60


}

function main_update()
{
	#will eventually pull down and run a git repo to make updates to the server.
    dialog --backtitle "sethwahle.com - Ncurse Installer Utility." --msgbox "Finished upgrading server instance." 20 60    
}

function main_updatescript()
{
  scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  pushd $scriptdir
  if [[ ! -d .git ]]; then
    dialog --backtitle "sethwahle.com - Ncurse Installer Utility." --msgbox "Cannot find direcotry '.git'. Please clone the OwncloudPie script via 'git clone git://github.com/petrockblog/OwncloudPie.git'" 20 60    
    popd
    return
  fi
  git pull
  popd
  dialog --backtitle "sethwahle.com - Ncurse Installer Utility." --msgbox "Fetched the latest version of the OwncloudPie script. You need to restart the script." 20 60    
}


# here starts the main script

checkNeededPackages

if [[ -f /etc/nginx/sites-available/default ]]; then
  __servername=$(egrep -m 1 "server_name " /etc/nginx/sites-available/default | sed "s| ||g")
  __servername=${__servername:11:0-1}
else
  __servername="url.ofmyserver.com"
fi

if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo ./OwncloudPie_setup'\n"
  exit 1
fi

while true; do
    cmd=(dialog --backtitle "sethwahle.com - Ncurse Installer Utility." --menu "You MUST set the server URL (e.g., 192.168.0.10 or myaddress.dyndns.org) before starting one of the installation routines. Choose task:" 22 76 16)
    options=(1 "Set server URL ($__servername)"
             2 "Install OnlyOffice"
             3 "Install Jitsi"
			 4 "Install Git-Lab"
             5 "Install Open-VPN"
             6 "Install Lets Encrypt"
             7 "Perform Server Updates"
             8 "Update OwncloudPie script")
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)    
    if [ "$choice" != "" ]; then
        case $choice in
            1) main_setservername ;;
            2) install-onlyoffice ;;
            3) install-jitsi ;;
			4) install-gitlab ;;
            5) install-openvpn ;;
            6) install-letsencrypt ;;
            7) main_update ;;
            8) main_updatescript ;;
        esac
    else
        break
    fi
done
clear