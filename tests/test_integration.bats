#!/usr/bin/env bats

load 'setup.bash'

setup() {
    setup_test_env
}

teardown() {
    cleanup_test_env
}

write_fake_command() {
    local name="$1" body="$2"

    mkdir -p "${TEST_DIR}/bin"
    printf '%s\n' '#!/bin/sh' "${body}" > "${TEST_DIR}/bin/${name}"
    chmod +x "${TEST_DIR}/bin/${name}"
}

@test "integration: missing fzf does not clear readline state" {
    write_fake_command sx 'exit 0'
    write_fake_command ssh 'exit 0'

    run env PATH="${TEST_DIR}/bin" HOME="${TEST_DIR}" /bin/bash -c '
        source "$1"
        READLINE_LINE="do-not-delete"
        READLINE_POINT=12
        __sx_invoke >/dev/null 2>&1 || status=$?
        printf "line=%s\npoint=%s\nstatus=%s\n" "${READLINE_LINE}" "${READLINE_POINT}" "${status:-0}"
    ' bash "${BATS_TEST_DIRNAME}/../sx-integration.sh"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "line=do-not-delete" ]]
    [[ "$output" =~ "point=12" ]]
    [[ "$output" =~ "status=1" ]]
}

@test "integration: failed sx invocation restores readline state" {
    write_fake_command sx 'exit 1'
    write_fake_command fzf 'exit 0'
    write_fake_command ssh 'exit 0'

    run env PATH="${TEST_DIR}/bin" HOME="${TEST_DIR}" /bin/bash -c '
        source "$1"
        READLINE_LINE="restore-me"
        READLINE_POINT=9
        __sx_invoke >/dev/null 2>&1 || status=$?
        printf "line=%s\npoint=%s\nstatus=%s\n" "${READLINE_LINE}" "${READLINE_POINT}" "${status:-0}"
    ' bash "${BATS_TEST_DIRNAME}/../sx-integration.sh"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "line=restore-me" ]]
    [[ "$output" =~ "point=9" ]]
    [[ "$output" =~ "status=1" ]]
}
