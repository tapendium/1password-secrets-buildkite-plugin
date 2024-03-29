#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

environment_hook="$PWD/hooks/environment"

# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

export OP_SESSION_TOKEN="token"
export OP_CONNECT_HOST="http://connecthost"
export OP_CONNECT_TOKEN="connecttoken"
prefix="BUILDKITE_PLUGIN_1PASSWORD_SECRETS"

function op() {
	echo ${SECRET_VALUE:-secret}
}

function getToken {
	echo ${TOKEN_VALUE:-token}
}

@test "Runs with no errors" {
	run "$environment_hook"

	assert_success
}

@test "Fails when OP host details are missing" {
	unset OP_CONNECT_HOST

	run "$environment_hook"

	assert_failure
	assert_output --partial "Missing OP_CONNECT_HOST"
}

@test "Runs when connect_host is provided" {
	unset OP_CONNECT_HOST
	export ${prefix}_CONNECT_HOST="localhost:8080"

	run "$environment_hook"

	assert_success
}

@test "Fails when both OP token and token reference are missing" {
	unset OP_CONNECT_TOKEN
	unset ${prefix}_CONNECT_TOKEN

	run "$environment_hook"

	assert_failure
	assert_output --partial "OP_CONNECT_TOKEN environment variable or connect_token field must be specified"
}

@test "Runs when connect_token is provided" {
	unset OP_CONNECT_TOKEN
	export ${prefix}_ENV_SECRET_A="op://vault/item/field"
	export ${prefix}_CONNECT_TOKEN=dummyarn
	export -f op
	export -f getToken

	run "$environment_hook"

	assert_success
	assert_output --partial "Reading secret \"op://vault/item/field\" from 1Password into environment variable $exportName"
}

@test "Parses out variable names for 1 secret" {
	export ${prefix}_ENV_SECRET_A="op://vault/item/field"

	export -f op

	run "$environment_hook"

	assert_success
	assert_output --partial "Reading secret \"op://vault/item/field\" from 1Password into environment variable $exportName"
}

@test "Reads secret references with spaces" {
	export ${prefix}_ENV_SECRET_A="op://vault name/item name/field name"

	export -f op

	run "$environment_hook"

	assert_success
	assert_output --partial "Reading secret \"op://vault name/item name/field name\" from 1Password into environment variable $exportName"

}

@test "Parses out variable names for multiple secrets" {
	export ${prefix}_ENV_SECRET_A="op://vault/a/field"
	export ${prefix}_ENV_SECRET_B="op://vault/b/field"

	export -f op

	run "$environment_hook"

	assert_success
	assert_output --partial "Reading secret \"op://vault/a/field\" from 1Password into environment variable SECRET_A"
	assert_output --partial "Reading secret \"op://vault/b/field\" from 1Password into environment variable SECRET_B"
}

@test "Expands out environment variable in field name" {
	export ${prefix}_ENV_SECRET_A="\$ENV_FIELD_NAME"
	export ENV_FIELD_NAME=op://vault/item/field

	export -f op

	run "$environment_hook"

	assert_success
	assert_output --partial "Reading secret \"op://vault/item/field\" from 1Password into environment variable SECRET_A"
}

@test "Clears OP_CONNECT_TOKEN on completion" {
	run "$environment_hook"

	assert_success
	assert_output --partial "Removing OP_CONNECT_TOKEN from environment"
}

@test "Does not clear OP_CONNECT_TOKEN when clear_token is set to false" {
	export ${prefix}_CLEAR_TOKEN="false"

	run "$environment_hook"

	assert_success
	refute_output --partial "Removing OP_CONNECT_TOKEN from environment"
}

@test "Does not clear OP_CONNECT_TOKEN if file injection specified" {
	export ${prefix}_CLEAR_TOKEN="true"
	export ${prefix}_FILE_0_PATH="configfile"

	run "$environment_hook"

	assert_success
	refute_output --partial "Removing OP_CONNECT_TOKEN from environment"
}
