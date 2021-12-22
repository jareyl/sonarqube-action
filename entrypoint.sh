#!/bin/bash

set -e

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
	EVENT_ACTION=$(jq -r ".action" "${GITHUB_EVENT_PATH}")
	if [[ "${EVENT_ACTION}" != "opened" && "${EVENT_ACTION}" != "edited" && "${EVENT_ACTION}" != "reopened" && "${EVENT_ACTION}" != "synchronize"  ]]; then
		echo "No need to run analysis. It is already triggered by the push event."
		exit
	fi
fi

REPOSITORY_NAME=$(basename "${GITHUB_REPOSITORY}")

[[ ! -z ${INPUT_PASSWORD} ]] && SONAR_PASSWORD="${INPUT_PASSWORD}" || SONAR_PASSWORD=""

# Re-setting the JAVA_HOME PATH and other needed environment variables because they could be pre-set in previous
# github steps of the job, and entering the container with invalid values for this execution (it happened for JAVA_HOME).
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk"
export HOME="/tmp"
export  XDG_CONFIG_HOME="/tmp"
export SONAR_SCANNER_HOME="/opt/sonar-scanner"
export SONAR_USER_HOME="/opt/sonar-scanner/.sonar"
export PATH="/opt/java/openjdk/bin:/opt/sonar-scanner/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [[ ! -f "${GITHUB_WORKSPACE}/sonar-project.properties" ]]; then
  [[ -z ${INPUT_PROJECTKEY} ]] && SONAR_PROJECTKEY="${REPOSITORY_NAME}" || SONAR_PROJECTKEY="${INPUT_PROJECTKEY}"
  [[ -z ${INPUT_PROJECTNAME} ]] && SONAR_PROJECTNAME="${REPOSITORY_NAME}" || SONAR_PROJECTNAME="${INPUT_PROJECTNAME}"
  [[ -z ${INPUT_PROJECTVERSION} ]] && SONAR_PROJECTVERSION="" || SONAR_PROJECTVERSION="${INPUT_PROJECTVERSION}"
  sonar-scanner \
    -Dsonar.host.url=${INPUT_HOST} \
    -Dsonar.projectKey=${SONAR_PROJECTKEY} \
    -Dsonar.projectName=${SONAR_PROJECTNAME} \
    -Dsonar.projectVersion=${SONAR_PROJECTVERSION} \
    -Dsonar.projectBaseDir=${INPUT_PROJECTBASEDIR} \
    -Dsonar.login=${INPUT_LOGIN} \
    -Dsonar.password=${SONAR_PASSWORD} \
    -Dsonar.sources=. \
    -Dsonar.sourceEncoding=UTF-8
else
  sonar-scanner \
    -Dsonar.host.url=${INPUT_HOST} \
    -Dsonar.projectBaseDir=${INPUT_PROJECTBASEDIR} \
    -Dsonar.login=${INPUT_LOGIN} \
    -Dsonar.password=${SONAR_PASSWORD}
fi
