#!/bin/bash

sudo echo -n

./scripts/check_install.sh

if [ -z "${KUBE_INSTALL_LOG}" ];then
    export KUBE_INSTALL_LOG=$(pwd)/k8s-$(date +%Y%m%d_%H%M).log;
fi;

if [ -z "${KUBECTL}" ];then
    export KUBECTL=$(which kubectl);
fi

#default k8s namespace
if [ -z "${KUBE_NAMESPACE}" ]; then
        export KUBE_NAMESPACE=${APP_GROUP}-${KUBE_ZONE}-$(echo ${GIT_BRANCH} | tr '/' '-')
fi;

for (( i=0 ; ((i-${ELASTIC_NODES})) ; i=(($i+1)) ));
        do ${KUBECTL} -n ${KUBE_NAMESPACE} delete pod/${APP_GROUP}-es-default-${i};
        ./scripts/wait_services_readiness.sh;
done;
echo
