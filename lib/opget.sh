#!/bin/bash

set -eo pipefail

if ! command -v op &>/dev/null; then
	echo "op not found. Nothing to do"
	exit 0
fi

if [ -z "$OP_SESSION" ]; then
	echo "OP_SESSION must be set. Try running 'export OP_SESSION=\$(./scripts/op-session)'"
	exit 1
fi

opItem=$1
opFields=$2

if [ "$#" -ne 2 ]; then
	echo "Missing/invalid arguments"
	echo
	echo "op-get-field.sh itemId itemField"
	exit 1
fi

result=$(op get item "$opItem" --fields "$opFields" --session "$OP_SESSION")

if [ -z "$result" ]; then
	echo "Field(s) \"${opFields}\" in item \"${opItem}\" not found. Please check item and field"
	exit 1
fi

echo "$result"
