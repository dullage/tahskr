#!/bin/bash

set -ev

# if [[ $TRAVIS_BRANCH == "develop" ]]
# then
#     deploy_env=dev
# elif [[ $TRAVIS_TAG != "" ]]
# then
#     deploy_env=prod
# else
#     exit 1
# fi

deploy_env=dev

choco install openssl.light -y

openssl aes-256-cbc -K $encrypted_7df0bf92a043_key -iv $encrypted_7df0bf92a043_iv -in $TRAVIS_BUILD_DIR/.travis/ssh_key.enc -out $TRAVIS_BUILD_DIR/.travis/ssh_key -d

# rsync -r --delete -e "ssh -i $TRAVIS_BUILD_DIR/.travis/ssh_key -o StrictHostKeyChecking=no" $TRAVIS_BUILD_DIR/dist travis@$DEPLOY_HOST_IP:$DEPLOY_TARGET_DIR/$deploy_env
rsync -r --delete -e "ssh -i $TRAVIS_BUILD_DIR/.travis/ssh_key -o StrictHostKeyChecking=no" ./src travis@$DEPLOY_HOST_IP:$DEPLOY_TARGET_DIR/dev
