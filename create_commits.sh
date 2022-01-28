#!/bin/bash

# git rev-list
#   = get the SHA of the commit before latest tag (the tag that triggered this release)
#
# git describe
#   = get the commits since last tag
#
# git log
#   = display just the SHAs and stick them in an array

commits=($(git log --oneline --format=format:%H $(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))..HEAD))

arr="["

for commit in "${commits[@]}"; do
  arr+="{\"id\":\"$commit\"},"
done

# example output:
# ::set-output name=commits::[{"id":"afe0311974601664933a37391a9f78e8e2ee320b"},{"id":"2fc2c62f9a4851a7a54af9c6fe1946f8df0a77a7"},{"id":"151c6edfff93560bcaab28acc0757a01e1eb916f"},]

arr+="]"

# need to remove the last trailing comma as that's invalid json and is what
# we're ultimately producing this value to be used as.
#
# so we do that using sed...

echo "::set-output name=commits::$(echo $arr | sed 's/},]/}]/')"
