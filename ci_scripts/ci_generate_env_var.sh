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
	echo "===== LocalEnv ====="
	base64 -i $LOCAL_ENV_FILE
	echo -e "===== LocalEnv =====\n"
fi

if [ -f $GOOGLE_OAUTH2_FILE_DEV ] 
then
	echo "===== GoogleOAuth2_DEV ====="
	base64 -i $GOOGLE_OAUTH2_FILE_DEV
	echo -e "===== GoogleOAuth2_DEV =====\n"
fi

if [ -f $GOOGLE_SERVICE_FILE_DEV ] 
then
	echo "===== GoogleService_DEV ====="
	base64 -i $GOOGLE_SERVICE_FILE_DEV
	echo -e "===== GoogleService_DEV =====\n"
fi

if [ -f $SERVICE_CONFIG_FILE_DEV ] 
then
	echo "===== ServiceConfig_DEV ====="
	base64 -i $SERVICE_CONFIG_FILE_DEV
	echo -e "===== ServiceConfig_DEV =====\n"
fi

if [ -f $GOOGLE_OAUTH2_FILE_PROD ] 
then
	echo "===== GoogleOAuth2_PROD ====="
	base64 -i $GOOGLE_OAUTH2_FILE_PROD
	echo -e "===== GoogleOAuth2_PROD =====\n"
fi

if [ -f $GOOGLE_SERVICE_FILE_PROD ] 
then
	echo "===== GoogleService_PROD ====="
	base64 -i $GOOGLE_SERVICE_FILE_PROD
	echo -e "===== GoogleService_PROD =====\n"
fi

if [ -f $SERVICE_CONFIG_FILE_PROD ] 
then
	echo "===== ServiceConfig_PROD ====="
	base64 -i $SERVICE_CONFIG_FILE_PROD
	echo -e "===== ServiceConfig_PROD =====\n"
fi


echo "Generate Env Var for Xcode Build is completed..."

exit 0
