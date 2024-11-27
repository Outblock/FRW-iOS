#!/bin/sh

echo "Stage: PRE-Xcode Build running.... "

# for future reference
# https://developer.apple.com/documentation/xcode/environment-variable-reference

cd ../FRW/App/Env/ 

LOCAL_ENV_FILE=./LocalEnv

GOOGLE_OAUTH2_FILE_DEV=./Dev/GoogleOAuth2.plist
GOOGLE_SERVICE_FILE_DEV=./Dev/GoogleService-Info.plist
SERVICE_CONFIG_FILE_DEV=./Dev/ServiceConfig.plist

GOOGLE_OAUTH2_FILE_PROD=./Prod/GoogleOAuth2.plist
GOOGLE_SERVICE_FILE_PROD=./Prod/GoogleService-Info.plist
SERVICE_CONFIG_FILE_PROD=./Prod/ServiceConfig.plist


if [ ! -f $LOCAL_ENV_FILE ] 
then
	echo "Generating LocalEnv..."
	base64 -D -o $LOCAL_ENV_FILE <<< $LOCAL_ENV
fi

if [ ! -f $GOOGLE_OAUTH2_FILE_DEV ] 
then
	echo "DEV: Generating GoogleOAuth2..."
	base64 -D -o $GOOGLE_OAUTH2_FILE_DEV <<< $GOOGLE_OAUTH2_DEV
fi

if [ ! -f $GOOGLE_SERVICE_FILE_DEV ] 
then
	echo "DEV: Generating GoogleService-Info..."
	base64 -D -o $GOOGLE_SERVICE_FILE_DEV <<< $GOOGLE_SERVICE_DEV
fi

if [ ! -f $SERVICE_CONFIG_FILE_DEV ] 
then
	echo "DEV: Generating ServiceConfig..."
	base64 -D -o $SERVICE_CONFIG_FILE_DEV <<< $SERVICE_CONFIG_DEV
fi

if [ ! -f $GOOGLE_OAUTH2_FILE_PROD ] 
then
	echo "PROD: Generating GoogleOAuth2..."
	base64 -D -o $GOOGLE_OAUTH2_FILE_PROD <<< $GOOGLE_OAUTH2_PROD
fi

if [ ! -f $GOOGLE_SERVICE_FILE_PROD ] 
then
	echo "PROD: Generating GoogleService-Info..."
	base64 -D -o $GOOGLE_SERVICE_FILE_PROD <<< $GOOGLE_SERVICE_PROD
fi

if [ ! -f $SERVICE_CONFIG_FILE_PROD ] 
then
	echo "PROD: Generating ServiceConfig..."
	base64 -D -o $SERVICE_CONFIG_FILE_PROD <<< $SERVICE_CONFIG_PROD
fi


echo "Stage: PRE-Xcode Build is completed..."

exit 0
