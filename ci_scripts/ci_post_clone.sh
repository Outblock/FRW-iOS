#!/bin/sh

echo "Stage: PRE-Xcode Build running.... "

# for future reference
# https://developer.apple.com/documentation/xcode/environment-variable-reference

cd ../FRW/App/Env/ 

FILE=LocalEnv

if [ ! -f $FILE ]
then
	cp _LocalEnv LocalEnv
	sed -i bak -e "s|\$WalletConnectProjectID|$WalletConnectProjectID|g" LocalEnv
	sed -i bak -e "s|\$BackupAESKey|$BackupAESKey|g" LocalEnv
	sed -i bak -e "s|\$AESIV|$AESIV|g" LocalEnv
	sed -i bak -e "s|\$TranslizedProjectID|$TranslizedProjectID|g" LocalEnv
	sed -i bak -e "s|\$TranslizedOTAToken|$TranslizedOTAToken|g" LocalEnv
fi

echo "Stage: PRE-Xcode Build is completed..."

exit 0
