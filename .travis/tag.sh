#!/bin/bash

set -ev

if [[ $TRAVIS_BRANCH == "master" ]]
then
    # Extract the version from the package.json file
    version=$(cat $TRAVIS_BUILD_DIR/package.json | jq -r ".version")
    echo Extracted Version Number: $version

    # See if any tags already match the version
    existing_tag_count=$(git tag | grep $version | wc -l)

    if [[ $existing_tag_count == 0 ]]
    then
        git config user.email "travis@travis-ci.com"
        git config user.name "Travis CI"

        git tag -a "$version" -m "$version"
    else
        echo "Skipping tag script as already run..."
    fi
fi
