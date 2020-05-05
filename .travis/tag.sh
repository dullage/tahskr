#!/bin/bash

# - The build must only be tagged once therefore this script cannot run in the before_deploy phase.
# - The build must fail (and not deploy) if the tag already exists (indicating the version hasn't been bumped) therefore this script cannot run in the after_success phase.
# - No deployments should happen if the tag already exists therefor this script cannot run as a deploy phase.

set -ev

if [[ $TRAVIS_BRANCH == "master" && $TRAVIS_EVENT_TYPE == "push" ]]
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

        git remote add origin-authenticated https://${GITHUB_TOKEN}@github.com/$GIT_REPO_SLUG.git

        git tag -a "$version" -m "$version"
        git push origin-authenticated --tags
    else
        echo "Tag already exists for this version!"
        exit 1
    fi
fi
