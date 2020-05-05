#!/bin/bash

set -ev

if [[ $TRAVIS_BRANCH == "master" ]]
then
    # Extract the version from the package.json file
    version=$(cat $TRAVIS_BUILD_DIR/package.json | jq -r ".version")
    echo Extracted Version Number: $version

    git config user.email "travis@travis-ci.com"
    git config user.name "Travis CI"

    git tag -a "$version" -m "$version"
fi
