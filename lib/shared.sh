#!/bin/bash

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Expand variable if it starts with $ sign
function expandVariable() {
	if [[ "${1::1}" == "\$" ]]; then
		local varName=${1:1}
		echo ${!varName}
	else
		echo ${1}
	fi
}

function getField() {
	local opItem=$1
	local opField=$2

	result=$(op get item "$opItem" --fields "$opField" --session "$OP_SESSION_TOKEN")
	[ -z "$result" ] && {
		echo "Unable to get item \"$opItem\" field \"$opField\" from 1Password" 1>&2
		exit 1
	}
	echo "$result"
}

function generateSessionToken() {
	local opToken
	url=$OP_ACCOUNT_URL
	email=$OP_EMAIL
	secretKey=$OP_SECRET_KEY
	password=$OP_PASSWORD
	script="
      set timeout 30 
      log_user 0
      spawn op signin --raw ${url} ${email} ${secretKey}
      expect -exact \"Enter the password for ${email} at ${url}: \" 
      send -- "${password}\\r"
      expect {
        -re \"${password}\\r\\n(.+)\\r\\n\" { set result [ string trim \$expect_out(1,string) ] }
      }
      expect *
      puts \$result
    "
	opToken=$(expect -c "${script}")
	[ -z "$opToken" ] && {
		echo "Unable to generate valid 1Password token" 1>&2
		exit 1
	}

	export OP_SESSION_TOKEN=$opToken
}
