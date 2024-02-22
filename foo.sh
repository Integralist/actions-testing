#!/bin/bash

msg=abc

echo something here

# the following doesn't actually stop the workflow
# https://docs.github.com/en/actions/learn-github-actions/workflow-commands-for-github-actions#setting-an-error-message
echo "::error title=some title::Some error occurred"

echo ::set-output name=nvmrc-version::$(cat .nvmrc)
echo ::set-output name=something_else::msg: $msg
#
# UPDATED syntax:
# echo "nvmrc-version=$(cat .nvmrc)" >> $GITHUB_OUTPUT
# echo "something_else='msg: $msg'" >> $GITHUB_OUTPUT

returnSuccessfulExitCode() {
  return 0 # a no zero exit code would cause the following `&& echo ...` to not run
           # but also would stop any other steps from running
}

returnSuccessfulExitCode && echo ::set-output name=was_success::true

FOO=abc
BAR=xyz
JSON_STRING=$(jq -n --arg foo "$FOO" --arg bar "$BAR" '{"FOO": [$foo], "BAR": [$bar]}')
echo "$JSON_STRING"
echo ::set-output name=matrix::"$JSON_STRING"
# NOTE: It's important the key's value is a list in order for GitHub Actions to
# be able to generate a valid strategy matrix from the JSON data.

# don't forget to wrap JSON in single quotes otherwise the job will try to run
# echo {BEEP: 123, BOOP: testing} which then doesn't get parsed as JSON via jq correctly.
echo ::set-output name=custom_json::'{"BEEP": 123, "BOOP": "testing"}'

# UPDATED syntax:
# echo "matrix=$JSON_STRING" >> $GITHUB_OUTPUT
# echo "custom_json='{"BEEP": 123, "BOOP": "testing"}'" >> $GITHUB_OUTPUT
#
# ...10
