#!/bin/bash

# Expand variable if it starts with $ sign
function expandVariable() {
	if [[ "${1::1}" == "\$" ]]; then
		local varName=${1:1}
		echo "${!varName}"
	else
		echo "${1}"
	fi
}

# Use op read to get field values https://developer.1password.com/docs/cli/reference/commands/read
function readField {
	local opRef=$1

	result=$($OP_EXE read "${opRef}" --force --no-newline)
	[ -z "$result" ] && {
		echo "Unable to read secret reference \"${opRef}\" from 1Password" 1>&2
		exit 1
	}
	echo "${result}"
}

# Use op inject to replace secret placeholders in supplied file
function injectSecrets {
  local filePath=$1

  echo "~~~ :unlock: Injecting secrets into \"${filePath}\" from 1Password"
  $OP_EXE inject --in-file "${filePath}" --out-file "${filePath}"  --force
}

# Fetch API token from Secret Manager.
#
# Assumes token is stored as plaintext
function getToken {
	secretId=$1
	local result

	if ! result=$(aws secretsmanager get-secret-value \
		--secret-id "${secretId}" \
		--version-stage AWSCURRENT \
		--output text \
		--query 'SecretString' 2>&1); then
		echo "Unable to read secret value from Secrets Manager."
		echo "${result}"
	fi

	[ -z "${result}" ] && {
		echo "Unable to read secret value from Secrets Manager."
	}

	echo "${result}"
}
