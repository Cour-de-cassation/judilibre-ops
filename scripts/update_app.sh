#!/bin/bash
#set version from package & git / could be git tag instead
if [ -z "${VERSION}" ];then\
        export VERSION=$(./scripts/version.sh)
fi

#get current branch
if [ -z "${GIT_BRANCH}" ];then
        export GIT_BRANCH=$(git branch | grep '*' | awk '{print $2}');
fi;

#default k8s namespace
if [ -z "${KUBE_NAMESPACE}" ]; then
        export KUBE_NAMESPACE=${APP_GROUP}-${KUBE_ZONE}-$(echo ${GIT_BRANCH} | tr '/' '-')
fi;

# logs
if [ -z "${KUBE_INSTALL_LOG}" ];then
        export KUBE_INSTALL_LOG=$(pwd)/k8s-$(date +%Y%m%d_%H%M).log;
fi

#perform update
if (kubectl set image --namespace=${KUBE_NAMESPACE} deployments/${APP_ID}-deployment ${APP_ID}=${DOCKER_USERNAME}/${APP_ID}:${VERSION} >> ${KUBE_INSTALL_LOG} 2>&1); then
        echo "🚀 update ${APP_ID} reference to ${VERSION}";
else
        echo -e "\e[31m❌  update ${APP_ID} reference to ${VERSION}\e[0m" && exit 1;
fi

#test or rollback
if ( ( ./scripts/wait_services_readiness.sh && ./scripts/test_minimal.sh ) > ${KUBE_INSTALL_LOG}.tmp 2>&1); then  
        cat ${KUBE_INSTALL_LOG}.tmp >> ${KUBE_INSTALL_LOG}
	rm ${KUBE_INSTALL_LOG}.tmp
	echo "✅  ${APP_ID}:${VERSION} upgrade";
else
        cat ${KUBE_INSTALL_LOG}.tmp >> ${KUBE_INSTALL_LOG}
	echo -e "\e[31m❌  ${APP_ID}:${VERSION} upgrade failed\e[0m";
        cat ${KUBE_INSTALL_LOG}.tmp | awk 'BEGIN{print "    Error in test_minimal:"}{print "    " $0}'
        rm ${KUBE_INSTALL_LOG}.tmp
        kubectl -n ${KUBE_NAMESPACE} logs deployments/${APP_ID}-deployment | awk 'BEGIN{print "    Logs of kube deployment:"}{print "    " $0}'
        if (kubectl -n ${KUBE_NAMESPACE} rollout undo deployments/${APP_ID}-deployment >> ${KUBE_INSTALL_LOG} 2>&1); then
                echo "✅  ${APP_ID} rollback successfull";
                exit 1;
        else
                echo -e "\e[31m❌  ${APP_ID} rollback failed\e[0m";
                exit 1;
        fi;
fi;
