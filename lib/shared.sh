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

# retry <number-of-retries> <jitter-factor> <command>
function retry {
	local maxAttempts=$1
	shift
	local jitterFactor=$1
	shift
	local attempt=1

	while true; do
		"$@" && break || {
			if [[ $attempt -lt $maxAttempts ]]; then
				backOff=$(echo "1*1.5^$attempt" | bc)
				maxJitter=$(echo "$jitterFactor * $backOff" | bc)
				minJitter=$(echo "$maxJitter * -1" | bc)
				jitter=$(echo "scale=2; ($RANDOM / 32768) * ($maxJitter - $minJitter) + $minJitter" | bc)
				delay=$(echo "$backOff + $jitter" | bc)
				echo "Attempt $attempt/$maxAttempts failed. Retrying in ${delay}s"
				((attempt++))
				sleep "$delay"
			else
				echo 1>&2 "The command has failed after $maxAttempts attempts."
				exit 1
			fi
		}
	done
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
