#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

environment_hook="$PWD/hooks/environment"

export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty


@test "Runs with no errors" {
  export OP_TOKEN="token"
  run "$environment_hook"

  assert_success
}
