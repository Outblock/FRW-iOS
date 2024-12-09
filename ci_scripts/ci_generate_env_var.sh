#!/bin/sh

echo "Generate Env Var for Xcode Build..."

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

pwd

if [ -f $LOCAL_ENV_FILE ] 
then
	echo "===== LOCAL_ENV ====="
	base64 -i $LOCAL_ENV_FILE
	echo -e "===== LOCAL_ENV =====\n"
fi

if [ -f $GOOGLE_OAUTH2_FILE_DEV ] 
then
	echo "===== GOOGLE_OAUTH2_DEV ====="
	base64 -i $GOOGLE_OAUTH2_FILE_DEV
	echo -e "===== GOOGLE_OAUTH2_DEV =====\n"
fi

if [ -f $GOOGLE_SERVICE_FILE_DEV ] 
then
	echo "===== GOOGLE_SERVICE_DEV ====="
	base64 -i $GOOGLE_SERVICE_FILE_DEV
	echo -e "===== GOOGLE_SERVICE_DEV =====\n"
fi

if [ -f $SERVICE_CONFIG_FILE_DEV ] 
then
	echo "===== SERVICE_CONFIG_DEV ====="
	base64 -i $SERVICE_CONFIG_FILE_DEV
	echo -e "===== SERVICE_CONFIG_DEV =====\n"
fi

if [ -f $GOOGLE_OAUTH2_FILE_PROD ] 
then
	echo "===== GOOGLE_OAUTH2_PROD ====="
	base64 -i $GOOGLE_OAUTH2_FILE_PROD
	echo -e "===== GOOGLE_OAUTH2_PROD =====\n"
fi

if [ -f $GOOGLE_SERVICE_FILE_PROD ] 
then
	echo "===== GOOGLE_SERVICE_PROD ====="
	base64 -i $GOOGLE_SERVICE_FILE_PROD
	echo -e "===== GOOGLE_SERVICE_PROD =====\n"
fi

if [ -f $SERVICE_CONFIG_FILE_PROD ] 
then
	echo "===== SERVICE_CONFIG_PROD ====="
	base64 -i $SERVICE_CONFIG_FILE_PROD
	echo -e "===== SERVICE_CONFIG_PROD =====\n"
fi


echo "Generate Env Var for Xcode Build is completed..."

exit 0
