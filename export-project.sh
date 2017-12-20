#!/bin/bash

PROJECT_NAME=${1}
OUTPUT_FILE=${2}

if [ "${PROJECT_NAME}" == "" -o "${OUTPUT_FILE}" == "" ]; then
  echo "Usage: ${0} [project name] [output template file name]"
  exit 1
fi

echo "Selecting project ${PROJECT_NAME}"
oc project ${PROJECT_NAME}

echo "Exporting DeploymentConfigurations to ${OUTPUT_FILE}"
oc export Secret,PersistentVolumeClaim,ConfigMap,RoleBinding,DeploymentConfig,Service,Route > ${OUTPUT_FILE}

