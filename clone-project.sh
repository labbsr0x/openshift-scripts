#!/bin/bash

set -e

FROM_PROJECT_NAME=${1}
FROM_PROJECT_FILE=${TMPDIR}/${FROM_PROJECT_NAME}.yml
TO_PROJECT_NAME=${2}
TO_PROJECT_FILE=${TMPDIR}/${TO_PROJECT_NAME}.yml
TMP_FILE=${TMPDIR}/_tempfile.yml

RENAME_IMAGE_REPO=${3}

if [ "${FROM_PROJECT_NAME}" == "" -o "${TO_PROJECT_NAME}" == "" ]; then
  echo "Usage: ${0} [from project name] [new project name] [rename repository reference?]"
  exit 1
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

