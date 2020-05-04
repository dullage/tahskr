#!/bin/bash

set -ev

git config user.email "travis@travis-ci.com"
git config user.name "Travis CI"

version=$(cat package.json | jq -r ".version")

git tag -a "$version" -m "$version"

git remote add origin-authenticated https://${GITHUB_TOKEN}@github.com/$GIT_REPO_SLUG.git
git push origin-authenticated --tags
