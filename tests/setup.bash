#!/bin/bash

setup_test_env() {
    export TEST_DIR="${BATS_TEST_TMPDIR}/sx_test"
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    export HOME="${TEST_DIR}"
    
    mkdir -p "${CONFIG_DIR}"
    touch "${SERVERS_FILE}"
}

cleanup_test_env() {
    [[ -d "${TEST_DIR}" ]] && rm -rf "${TEST_DIR}"
}

load_sx_functions() {
    source "${BATS_TEST_DIRNAME}/../sx"
}
