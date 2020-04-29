#!/bin/bash

set -ev

# choco install openssl.light python -y

# SSH_COMMAND="rm -R $DEPLOY_TARGET_DIR/dist && mv $DEPLOY_TARGET_DIR/staging/dist $DEPLOY_TARGET_DIR"

# openssl aes-256-cbc -K $encrypted_7df0bf92a043_key -iv $encrypted_7df0bf92a043_iv -in $TRAVIS_BUILD_DIR/.travis/ssh_key.enc -out $TRAVIS_BUILD_DIR/.travis/ssh_key -d

# echo scp -r -i $TRAVIS_BUILD_DIR/.travis/ssh_key -o StrictHostKeyChecking=no $TRAVIS_BUILD_DIR/dist travis@$DEPLOY_HOST_IP:$DEPLOY_TARGET_DIR/staging
#ssh -i $TRAVIS_BUILD_DIR/.travis/ssh_key -o StrictHostKeyChecking=no travis@$DEPLOY_HOST_IP $SSH_COMMAND

echo Deploy: $DEPLOY_TARGET_DIR
