#!/bin/bash
# ##########################################################
# ALPS(Android4.1 based) build environment profile setting
# ##########################################################
# Overwrite JAVA_HOME environment variable setting if already exists
JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export JAVA_HOME

# Overwrite ANDROID_JAVA_HOME environment variable setting if already exists
ANDROID_JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export ANDROID_JAVA_HOME

# Overwrite PATH environment setting for JDK & arm-eabi if already exists
PATH=/usr/lib/jvm/java-7-openjdk-amd64/bin:$PATH
export PATH


