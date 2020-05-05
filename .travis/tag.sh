#!/bin/bash

set -ev

if [[ $TRAVIS_BRANCH == "master" ]]
then
    version=$(cat $TRAVIS_BUILD_DIR/package.json | jq -r ".version")
    echo Extracted Version Number: $version

    git fetch --tags

    # Check if tag already exists with version number 
    if git rev-parse "$version" >/dev/null 2>&1
    then
        echo "Tag already exists for this version!"
        exit 1
    else
        git config user.email "travis@travis-ci.com"
        git config user.name "Travis CI"

        git tag -a "$version" -m "$version"
    fi
fi
