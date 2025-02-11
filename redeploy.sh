#!/usr/bin/env bash

source ./bash-header.sh
set -x
source "$DEMO_HOME/myenv.sh"

cd "$DEMO_HOME"

while getopts "o" opt; do
    case "$opt" in
    o)  offline="-o"
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "Offline=$offline, Leftovers: $@"


curl  -X DELETE "$FUSION_API/webapps/$FUSION_APPLICATION_NAME"


mvn $offline clean package

cd "$DEMO_HOME/setup"

echo "deploying war"
curl -H "content-type:application/json" -X POST -d "{\"id\": \"$FUSION_APPLICATION_NAME\",\"name\": \"$FUSION_APPLICATION_NAME\", \"contextPath\": \"/$FUSION_UI_NAME\"}" "$FUSION_API/webapps"
curl -H 'Content-type: application/zip' -X PUT "$FUSION_API/webapps/$FUSION_APPLICATION_NAME/war" --data-binary "@../app/dist/$FUSION_UI_ARTIFACT_ID.war"


cd "$FUSION_HOME/"
bin/webapps restart
