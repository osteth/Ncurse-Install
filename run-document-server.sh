#/bin/bash

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

UPDATE=0
DOCUMENT_IMAGE_NAME='onlyoffice/documentserver';
DOCUMENT_CONTAINER_NAME='onlyoffice-document-server';

while [ "$1" != "" ]; do
	case $1 in

		-u | --update )
			UPDATE=1
		;;

		-i | --image )
			if [ "$2" != "" ]; then
				DOCUMENT_IMAGE_NAME=$2
				shift
			fi
		;;

		-v | --version )
			if [ "$2" != "" ]; then
				VERSION=$2
				shift
			fi
		;;

		-c | --container )
			if [ "$2" != "" ]; then
				DOCUMENT_CONTAINER_NAME=$2
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

		-? | -h | --help )
			echo "  Usage $0 [PARAMETER] [[PARAMETER], ...]"
			echo "    Parameters:"
			echo "      -u, --update          update"
			echo "      -i, --image          image name"
			echo "      -v, --version          image version"
			echo "      -c, --container          container name"
			echo "      -p, --password          dockerhub password"
			echo "      -un, --username          dockerhub username"
			echo "      -?, -h, --help        this help"
			echo
			exit 0
		;;

		* )
			echo "Unknown parameter $1" 1>&2
			exit 1
		;;
	esac
	shift
done



DOCUMENT_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${DOCUMENT_CONTAINER_NAME});

if [[ -n ${DOCUMENT_SERVER_ID} ]]; then
	if [ "$UPDATE" == "1" ]; then
	    sudo bash /app/onlyoffice/setup/tools/check-bindings.sh ${DOCUMENT_SERVER_ID} "/etc/onlyoffice,/var/lib/onlyoffice"
		sudo bash /app/onlyoffice/setup/tools/remove-container.sh ${DOCUMENT_CONTAINER_NAME}
	else
		echo "ONLYOFFICE DOCUMENT SERVER is already installed."
		sudo docker start ${DOCUMENT_SERVER_ID};
		echo "INSTALLATION-STOP-SUCCESS"
		exit 0;
	fi
fi

if [[ -n ${USERNAME} && -n ${PASSWORD}  ]]; then
	sudo bash /app/onlyoffice/setup/tools/login-docker.sh ${USERNAME} ${PASSWORD}
fi

if [[ -z ${VERSION} ]]; then
	GET_VERSION_COMMAND="sudo bash /app/onlyoffice/setup/tools/get-available-version.sh -i $DOCUMENT_IMAGE_NAME";

	if [[ -n ${PASSWORD} && -n ${USERNAME} ]]; then
	    GET_VERSION_COMMAND="$GET_VERSION_COMMAND -un $USERNAME -p $PASSWORD";
	fi

	VERSION=$(${GET_VERSION_COMMAND});
fi

sudo bash /app/onlyoffice/setup/tools/pull-image.sh ${DOCUMENT_IMAGE_NAME} ${VERSION}

sudo docker run --net onlyoffice -i -t -d --restart=always --name ${DOCUMENT_CONTAINER_NAME} \
-v /app/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data \
-v /app/onlyoffice/DocumentServer/logs:/var/log/onlyoffice \
${DOCUMENT_IMAGE_NAME}:${VERSION}

DOCUMENT_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${DOCUMENT_CONTAINER_NAME});

if [[ -z ${DOCUMENT_SERVER_ID} ]]; then
	echo "ONLYOFFICE DOCUMENT SERVER not installed."
	echo "INSTALLATION-STOP-ERROR"
	exit 0;
fi

echo "ONLYOFFICE DOCUMENT SERVER successfully installed."
echo "INSTALLATION-STOP-SUCCESS"