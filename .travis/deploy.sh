#!/bin/bash

set -ev

SSH_COMMAND="rm -R $DEPLOY_DIR_DEV/dist && mv $DEPLOY_DIR_DEV/staging/dist $DEPLOY_DIR_DEV"

scp -r -i $TRAVIS_BUILD_DIR/.travis/ssh_key -o StrictHostKeyChecking=no $TRAVIS_BUILD_DIR/dist travis@$DEPLOY_HOST_IP:$DEPLOY_DIR_DEV/staging
ssh -i $TRAVIS_BUILD_DIR/.travis/ssh_key -o StrictHostKeyChecking=no travis@$DEPLOY_HOST_IP $SSH_COMMAND