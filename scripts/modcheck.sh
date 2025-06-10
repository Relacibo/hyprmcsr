#!/bin/sh
SCRIPT_PATH=$(dirname $(realpath "$0"))
JAR_PATH=$SCRIPT_PATH/../jars
FILE_PATH=$(find $JAR_PATH -type f -name modcheck-*.jar)
java -jar "$FILE_PATH" &
