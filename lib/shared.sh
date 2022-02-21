#!/bin/bash

CWD="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

function getField() {
  local opItem=$1
  local opField=$2

  result=$(op get item "$opItem" --fields "$opFields" --session "$OP_SESSION")
  echo "$result"
}

function generateSessionToken() {
  local opToken
  opToken=$("$CWD"/../lib/opsession)

  export OP_TOKEN=$opToken
}

