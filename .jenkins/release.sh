#!/bin/bash

set -e

asset_one=tahskr-web.zip
asset_two=tahskr-win.zip
 
tag=$(cat $WORKSPACE/package.json | jq -r ".version")

printf "Creating Release...\n"
response=$(\
  curl -fsS \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"tag_name\": \"$tag\", \"target_commitish\": \"master\", \"name\": \"$tag\"}" \
    https://api.github.com/repos/$GIT_REPO_SLUG/releases \
)

upload_url=$(echo $response | jq -r ".upload_url")
upload_url="${upload_url%\{*}"

printf "Uploading Assets...\n"
curl -fsS -o /dev/null \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: $(file -b --mime-type $WORKSPACE/$asset_one)" \
  --data-binary @$WORKSPACE/$asset_one \
  $upload_url?name=$asset_one

curl -fsS -o /dev/null \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: $(file -b --mime-type $WORKSPACE/$asset_two)" \
  --data-binary @$WORKSPACE/$asset_two \
  $upload_url?name=$asset_two
