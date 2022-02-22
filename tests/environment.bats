#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

environment_hook="$PWD/hooks/environment"

# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

export OP_SESSION_TOKEN="token"
prefix="BUILDKITE_PLUGIN_1PASSWORD_SECRETS"

function op() {
  echo ${SECRET_VALUE:-secret}
}

@test "Runs with no errors" {
  run "$environment_hook"

  assert_success
}

@test "Parses out variable names for 1 secret" {
  export ${prefix}_ENV_SECRET_A_SECRET_UUID="secretAUuid"
  export ${prefix}_ENV_SECRET_A_FIELD="secretAField"

  export -f op

  run "$environment_hook"

  assert_success
  assert_output --partial "Reading item \"secretAUuid\" field \"secretAField\" from 1Password into environment variable SECRET_A"
}

@test "Parses out variable names for multiple secrets" {
  export ${prefix}_ENV_SECRET_A_SECRET_UUID="secretAUuid"
  export ${prefix}_ENV_SECRET_A_FIELD="secretAField"
  export ${prefix}_ENV_SECRET_B_SECRET_UUID="secretBUuid"
  export ${prefix}_ENV_SECRET_B_FIELD="secretBField"
  export -f op

  run "$environment_hook"

  assert_success
  assert_output --partial "Reading item \"secretAUuid\" field \"secretAField\" from 1Password into environment variable SECRET_A"
  assert_output --partial "Reading item \"secretBUuid\" field \"secretBField\" from 1Password into environment variable SECRET_B"
}
