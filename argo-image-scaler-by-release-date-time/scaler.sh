#!/usr/bin/env bash
set -x
if [ $# -lt 4 ]; then 
    echo "Usage: ./$(basename $0) SCALE_DOWN_POD_COUNT SCALE_UP_POD_COUNT SCALE_UP_TIME SCALE_DOWN_TIME"
    exit 123
fi
SCALE_DOWN_POD_COUNT=$SCALE_DOWN_POD_COUNT
SCALE_UP_POD_COUNT=$SCALE_UP_POD_COUNT
SCALE_UP_TIME=$SCALE_UP_TIME
SCALE_DOWN_TIME=$SCALE_DOWN_TIME
NS_NAME='argocd'
DEPLOY_NAME='argocd-image-updater'
DAY_IN_STRING=$(TZ=America/New_York date +%a)
CURRENT_EST_TIME=$(TZ=America/New_York date +"%H:%M %Z")
PARSED_TIME=$(echo ${CURRENT_EST_TIME} | awk '{ print $1 }' | cut -f1 -d':')
which kubectl > /dev/null

if [ `echo $?` != 0 ]; then 
    curl -s -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s \
        https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl 
    chmod +x ./kubectl && mv ./kubectl /usr/bin/
fi

if [ $DAY_IN_STRING = Sat -o $DAY_IN_STRING = Sun ]; then
    echo "Deploy name: ${DEPLOY_NAME} || Scale down Pod count: ${SCALE_DOWN_POD_COUNT} || Namespace: ${NS_NAME}"
    kubectl scale deployment ${DEPLOY_NAME} --replicas=${SCALE_DOWN_POD_COUNT} -n ${NS_NAME}
else 
    if [ $PARSED_TIME -ge $SCALE_UP_TIME -a $PARSED_TIME -le $SCALE_DOWN_TIME ]; then
        echo "Deploy name: ${DEPLOY_NAME} || Scale up Pod count: ${SCALE_UP_POD_COUNT} || Namespace: ${NS_NAME}"
        kubectl scale deployment ${DEPLOY_NAME} --replicas=${SCALE_UP_POD_COUNT} -n ${NS_NAME}
    else
        echo "Deploy name: ${DEPLOY_NAME} || Scale down Pod count: ${SCALE_DOWN_POD_COUNT} || Namespace: ${NS_NAME}"
        kubectl scale deployment ${DEPLOY_NAME} --replicas=${SCALE_DOWN_POD_COUNT} -n ${NS_NAME}
    fi
fi
set +x