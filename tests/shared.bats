#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

shared_lib="$PWD/lib/shared.sh"

@test "expandVariable expands variables correctly" {
	source $shared_lib
	export TEST_VAR=test_value
	run expandVariable "\$TEST_VAR"
	assert_success
	assert_output "test_value"
}

@test "expandVariable doesn't expand strings" {
	source $shared_lib
	export TEST_VAR=test_value
	run expandVariable "TEST_VAR"
	assert_success
	assert_output "TEST_VAR"
}
