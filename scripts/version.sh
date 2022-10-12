#!/bin/sh

./scripts/check_install.sh > /dev/null

if [ -z ${GIT_BRANCH} ];then
    GIT_BRANCH=$(git branch --show-current)
fi

if [ -f "package.json" ]; then
    echo "package"
    SEMVER=$(cat package.json | jq -r '.version');
else
    if [ -f "setup.py" ]; then
      echo "setup.py"
        TMP=$(grep -r __version__ */__init__.py | sed 's/.*=//;s/"//g;s/\s//g') > /dev/null 2>&1
        if [ ! -z "${TMP}" ]; then
            SEMVER=${TMP}
        else
	  TMP=$(cat setup.py | grep version | sed 's/.*version="\(.*\)\".*/\1/' | grep -v version) > /dev/null 2>&1;
          if [ ! -z "${TMP}" ];then
            SEMVER=${TMP}
	    exit 1
          fi
        fi
    fi
fi;
if [ -z "${SEMVER}" ]; then
    echo "semver"
    SEMVER=$(git tag | tail -1)
fi

if [ -f .docker-parent ]; then
    echo "docker"
    PARENT_VERSION_FILE=.docker-parent-image-file
    docker manifest inspect $(cat .docker-parent):${GIT_BRANCH} > .docker-parent-image
    echo .docker-parent-image > .docker-parent-image-file
fi

echo ${SEMVER}-$(export LC_COLLATE=C;export LC_ALL=C;cat tagfiles.version ${PARENT_VERSION_FILE} | xargs -I '{}' find {} -type f | xargs -I {} sh -c "(git show {} > /dev/null 2>&1) && echo {}" | sort | xargs cat | sha256sum - | sed 's/\(......\).*/\1/')
