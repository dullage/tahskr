#!/bin/bash

set -ev

target_branch=feature/travis-builds

git config user.email "travis@travis-ci.com"
git config user.name "Travis CI"

#git checkout $target_branch

python $TRAVIS_BUILD_DIR/.travis/bump_version.py package.json package-lock.json

version=$(cat package.json | jq -r ".version")

git add .
git commit -m "$VERSION_BUMP_MESSAGE_PREFIX $version"

git tag -a $version -m "$version"

git remote add origin-authenticated https://${GITHUB_TOKEN}@github.com/$GIT_REPO_SLUG.git
git push --set-upstream origin-authenticated --follow-tags $target_branch
