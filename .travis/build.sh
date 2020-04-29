#!/bin/bash

set -ev

npm ci

npm run build

npm run package-win
