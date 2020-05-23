#!/bin/bash

# Note: This check has to happen during the build phase as it can only be checked once (no before_deploy) and the build should fail if there's a problem (no after_success). The tag is not created by this script but instead by tag.sh in the before_deploy stage as that seemed to be required for the GitHub Releases integration.

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
