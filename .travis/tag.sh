#!/bin/bash

# Note: This script cannot run as a before_deploy script otherwise it would run for every deployment

set -ev

git config user.email "travis@travis-ci.com"
git config user.name "Travis CI"

version=$(cat $TRAVIS_BUILD_DIR/package.json | jq -r ".version")
echo Extracted Version Number: $version

git tag
git fetch --tags

git tag -a "$version" -m "$version"
