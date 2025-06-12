#!/bin/sh
SCRIPT_DIR=$(dirname $(realpath "$0"))
JAR_PATH=$SCRIPT_DIR/../jars
FILE_PATH=$(find $JAR_PATH -type f -name Ninjabrain-Bot-*.jar)
java -jar "$FILE_PATH" &
