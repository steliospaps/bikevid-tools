#!/bin/bash

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

set -o errexit

OUTPUT=~/Videos/Videos_raw
STAGGING=~/Videos/Videos_raw/bikecam

declare -A CAMERA_NAME

CAMERA_NAME["UDISK"]="rear"
CAMERA_NAME["ESCAPE 4KW"]="front"

set -x
for camera in "${!CAMERA_NAME[@]}" 
do
	S=/media/$USER/$camera
	STAGGING_THIS="$STAGGING/${CAMERA_NAME[$camera]}"
	if [[ -d "$S" ]]
	then
		rsync -va "$S"/ "$STAGGING_THIS"/ && ${DIR:?}/merge.sh "$STAGGING_THIS"/video/ "$OUTPUT"/ "_${CAMERA_NAME[$camera]}"
	else
		echo "${CAMERA_NAME[$camera]}" camera not mounted
	fi
done
