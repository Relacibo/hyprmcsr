#!/bin/sh
SCRIPT_PATH=$(dirname $(realpath "$0"))
JAR_PATH=$SCRIPT_PATH/../jars
FILE_NAME=$(find $JAR_PATH -type f -printf "%f\n" -name NinjaLink-*.jar)

cd $SCRIPT_PATH/..
java -jar "$JAR_PATH/$FILE_NAME" &

