#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

post_checkout_hook="$PWD/hooks/post-checkout"

# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

export OP_SESSION_TOKEN="token"
export OP_CONNECT_HOST="http://connecthost"
export OP_CONNECT_TOKEN="connecttoken"
prefix="BUILDKITE_PLUGIN_1PASSWORD_SECRETS_FILE"

function op() {
	echo ${SECRET_VALUE:-secret}
}

function getToken {
	echo ${TOKEN_VALUE:-token}
}

@test "Runs with no errors" {
	run "$post_checkout_hook"

	assert_success
}

@test "Handles a file without  specified output" {
	export ${prefix}_CLEAR_TOKEN="false"
	export ${prefix}_0_PATH="inputTemplateFile"
	export -f op
	export -f getToken

	run "$post_checkout_hook"

	assert_success
	assert_output --partial "Injecting secrets into \"inputTemplateFile\" from 1Password"
}

@test "Handles a file with specified output" {
	export ${prefix}_CLEAR_TOKEN="false"
	export ${prefix}_0_PATH="inputTemplateFile"
	export ${prefix}_0_OUT="someDir/outputFile"
	export -f op
	export -f getToken

	run "$post_checkout_hook"

	assert_success
	assert_output --partial "Injecting secrets into \"someDir/outputFile\" from 1Password"
}
