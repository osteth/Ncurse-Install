#!/bin/bash

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

STR_PORTS=${1}
ARRAY_PORTS=(${STR_PORTS//,/ })

for PORT in "${ARRAY_PORTS[@]}"
do
	REGEXP=":$PORT$"
	CHECK_RESULT=$(sudo netstat -lnp | awk '{print $4}' | grep $REGEXP)

	if [[ $CHECK_RESULT != "" ]]; then
		echo "The following ports must be open: $PORT"
		echo "INSTALLATION-STOP-ERROR[3]"
		exit 0;
	fi
done

echo "INSTALLATION-STOP-SUCCESS"
