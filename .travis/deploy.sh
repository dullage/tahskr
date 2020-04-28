#!/bin/bash

set -ev

SSH_COMMAND="rm -R $DEPLOY_DIR_DEV/dist && mv $DEPLOY_DIR_DEV/staging/dist $DEPLOY_DIR_DEV"

openssl aes-256-cbc -K $encrypted_7df0bf92a043_key -iv $encrypted_7df0bf92a043_iv -in $TRAVIS_BUILD_DIR/.travis/ssh_key.enc -out $TRAVIS_BUILD_DIR/.travis/ssh_key -d

scp -r -i $TRAVIS_BUILD_DIR/.travis/ssh_key -o StrictHostKeyChecking=no $TRAVIS_BUILD_DIR/dist travis@$DEPLOY_HOST_IP:$DEPLOY_DIR_DEV/staging
ssh -i $TRAVIS_BUILD_DIR/.travis/ssh_key -o StrictHostKeyChecking=no travis@$DEPLOY_HOST_IP $SSH_COMMAND
