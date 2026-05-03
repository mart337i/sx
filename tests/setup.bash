#!/bin/bash

setup_test_env() {
    export TEST_DIR="${BATS_TEST_TMPDIR}/sx_test"
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    export HOME="${TEST_DIR}"
    export SSH_DIR="${TEST_DIR}/.ssh"
    export SSH_CONFIG="${SSH_DIR}/config"
    export SX_SSH_CONFIG="${SSH_DIR}/config.d/sx.conf"
    
    mkdir -p "${CONFIG_DIR}" "${SSH_DIR}/config.d"
    touch "${SERVERS_FILE}"
    touch "${SSH_CONFIG}" "${SX_SSH_CONFIG}"
}

cleanup_test_env() {
    [[ -d "${TEST_DIR}" ]] && rm -rf "${TEST_DIR}"
}

load_sx_functions() {
    source "${BATS_TEST_DIRNAME}/../sx"
}
