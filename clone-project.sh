#!/bin/bash

set -e

FROM_PROJECT_NAME=${1}
FROM_PROJECT_FILE=${TMPDIR}/${FROM_PROJECT_NAME}.yml
TO_PROJECT_NAME=${2}
TO_PROJECT_FILE=${TMPDIR}/${TO_PROJECT_NAME}.yml
TMP_FILE=${TMPDIR}/_tempfile.yml

ROUTES_SUFIX=${3}
RENAME_IMAGE_REPO=${4}

if [ "${FROM_PROJECT_NAME}" == "" -o "${TO_PROJECT_NAME}" == "" ]; then
  echo "Usage: ${0} [from project name] [new project name] [route hostname sufix] [rename images repository reference?]"
  echo "    Example: ${0} super_project another_super_project .another.superproject.com false"
  exit 1
fi

if [ "${ROUTES_SUFIX}" == "" ]; then
  ROUTES_SUFIX=".example.com"
fi

./export-project.sh ${FROM_PROJECT_NAME} ${FROM_PROJECT_FILE}

echo "Preparing exported file..."
cp ${FROM_PROJECT_FILE} ${TO_PROJECT_FILE}

echo "Renaming service references..."
sed -e s/${FROM_PROJECT_NAME}\.svc/${TO_PROJECT_NAME}\.svc/g ${TO_PROJECT_FILE} > ${TMP_FILE}
cp ${TMP_FILE} ${TO_PROJECT_FILE}

if [ "${RENAME_IMAGE_REPO}" == "true" ]; then
  echo "Renaming image repository reference..."
  sed -e s/${FROM_PROJECT_NAME}/${TO_PROJECT_NAME}/g ${TO_PROJECT_FILE} > ${TMP_FILE}
  cp ${TMP_FILE} ${TO_PROJECT_FILE}
fi 

echo "Renaming routes hostname to sufix ${ROUTES_SUFIX}..."
IFS=$'\n'
hostnames=($(more ${TO_PROJECT_FILE} | grep -e "^    host" | cut -f6 -d ' '))
route_names=($(more ${TO_PROJECT_FILE} | grep -e "^    host" -B 2 | grep name: | cut -f6 -d ' '))
for i in ${!hostnames[@]}; do
  hn=${hostnames[$i]}
  rn=${route_names[$i]}
  new_hostname="${rn}${ROUTES_SUFIX}"
  sed -e s/$hn/$new_hostname/g ${TO_PROJECT_FILE} > ${TMP_FILE}
  echo "ROUTE ${rn} --> ${new_hostname}"
  cp ${TMP_FILE} ${TO_PROJECT_FILE}
done

echo "Removing PV references for PVCs (forcing volume recreation)..."
grep -v volumeName ${TO_PROJECT_FILE} > ${TMP_FILE}
cp ${TMP_FILE} ${TO_PROJECT_FILE}
grep -v pv.kubernetes.io/bind-completed ${TO_PROJECT_FILE} > ${TMP_FILE}
cp ${TMP_FILE} ${TO_PROJECT_FILE}
grep -v pv.kubernetes.io/bound-by-controller ${TO_PROJECT_FILE} > ${TMP_FILE}
cp ${TMP_FILE} ${TO_PROJECT_FILE}

echo "Creating new project with name ${TO_PROJECT_NAME}"
oc new-project ${TO_PROJECT_NAME}

echo "Create objects on the new project"
oc create -f ${TO_PROJECT_FILE}

echo "Authorize newly cloned project to pull images from another"
if [ "$RENAME_IMAGE_REPO" != "true" ]; then
   oc policy add-role-to-user \
       system:image-puller system:serviceaccount:$FROM_PROJECT_NAME:default -n TO_PROJECT_NAME 
fi

