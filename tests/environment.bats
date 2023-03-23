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

@test "Fails when OP token is missing" {
	unset OP_CONNECT_TOKEN

	run "$environment_hook"

	assert_failure
	assert_output --partial "Missing OP_CONNECT_TOKEN"
}

@test "Parses out variable names for 1 secret" {
	export ${prefix}_ENV_SECRET_A="op://vault/item/field"

	export -f op

	run "$environment_hook"

	assert_success
	assert_output --partial "Reading secret at reference \"op://vault/item/field\" from 1Password into environment variable $exportName"
}

@test "Parses out variable names for multiple secrets" {
	export ${prefix}_ENV_SECRET_A="op://vault/a/field"
	export ${prefix}_ENV_SECRET_B="op://vault/b/field"

	export -f op

	run "$environment_hook"

	assert_success
	assert_output --partial "Reading secret at reference \"op://vault/a/field\" from 1Password into environment variable SECRET_A"
	assert_output --partial "Reading secret at reference \"op://vault/b/field\" from 1Password into environment variable SECRET_B"
}

@test "Expands out environment variable in field name" {
	export ${prefix}_ENV_SECRET_A="\$ENV_FIELD_NAME"
	export ENV_FIELD_NAME=op://vault/item/field

	export -f op

	run "$environment_hook"

	assert_success
	assert_output --partial "Reading secret at reference \"op://vault/item/field\" from 1Password into environment variable SECRET_A"
}
