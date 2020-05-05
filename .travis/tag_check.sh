#!/bin/bash

set -ev

if [[ $TRAVIS_BRANCH == "master" && $TRAVIS_EVENT_TYPE == "push" ]]
then
    # Extract the version from the package.json file
    version=$(cat $TRAVIS_BUILD_DIR/package.json | jq -r ".version")
    echo Extracted Version Number: $version

    # See if any tags already match the version
    existing_tag_count=$(git tag | grep $version | wc -l)

    if [[ $existing_tag_count > 0 ]]
    then
        echo "Tag already exists for this version!"
        exit 1
    fi
fi
