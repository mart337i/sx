#!/usr/bin/env bats

load 'setup.bash'

setup() {
    setup_test_env
}

teardown() {
    cleanup_test_env
}

@test "import_filezilla: imports servers from FileZilla XML" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla.xml"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    run "${BATS_TEST_DIRNAME}/../sx" --import "${xml}"
    
    [ "$status" -eq 0 ]
    [ -f "${SERVERS_FILE}" ]
    
    grep -q "Production Server" "${SERVERS_FILE}"
    grep -q "192.168.1.100" "${SERVERS_FILE}"
    grep -q "admin" "${SERVERS_FILE}"
}

@test "import_filezilla: handles missing XML file" {
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    run "${BATS_TEST_DIRNAME}/../sx" --import "/nonexistent/file.xml"
    
    [ "$status" -eq 1 ]
    [[ "$output" =~ "File not found" ]]
}

@test "import_filezilla: sets default port to 22 when missing" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla.xml"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    "${BATS_TEST_DIRNAME}/../sx" --import "${xml}" > /dev/null
    
    grep "Staging" "${SERVERS_FILE}" | grep -q "|22$"
}

@test "import_filezilla: sets default user to root when missing" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla.xml"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    "${BATS_TEST_DIRNAME}/../sx" --import "${xml}" > /dev/null
    
    grep "Staging" "${SERVERS_FILE}" | grep -q "|root|"
}

@test "import_filezilla: handles custom ports" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla.xml"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    "${BATS_TEST_DIRNAME}/../sx" --import "${xml}" > /dev/null
    
    grep "Dev Environment" "${SERVERS_FILE}" | grep -q "|2222$"
}

@test "import_filezilla: creates properly formatted server entries" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla.xml"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    "${BATS_TEST_DIRNAME}/../sx" --import "${xml}" > /dev/null
    
    line=$(grep "Production Server" "${SERVERS_FILE}")
    
    echo "$line" | grep -qE "^[^|]+\|[^|]+@[^|]+:[0-9]+\|[^|]+\|[^|]+\|[0-9]+$"
}

@test "import_filezilla: handles XML with folder sections" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla-folders.xml"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    run "${BATS_TEST_DIRNAME}/../sx" --import "${xml}"
    
    [ "$status" -eq 0 ]
    
    grep -q "Production Web 1" "${SERVERS_FILE}"
    grep -q "Production Database" "${SERVERS_FILE}"
    grep -q "Dev API Server" "${SERVERS_FILE}"
    grep -q "QA Test Server" "${SERVERS_FILE}"
}

@test "import_filezilla: imports nested folders correctly" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla-folders.xml"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    "${BATS_TEST_DIRNAME}/../sx" --import "${xml}" > /dev/null
    
    grep -q "Client A Production" "${SERVERS_FILE}"
    grep -q "Client B Server" "${SERVERS_FILE}"
}

@test "import_filezilla: counts all servers in folders" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla-folders.xml"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    "${BATS_TEST_DIRNAME}/../sx" --import "${xml}" > /dev/null
    
    count=$(wc -l < "${SERVERS_FILE}")
    [ "$count" -eq 6 ]
}

@test "import_ssh_config: imports servers from SSH config" {
    local config="${BATS_TEST_DIRNAME}/fixtures/sample-ssh-config"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    run "${BATS_TEST_DIRNAME}/../sx" --ssh-config "${config}"
    
    [ "$status" -eq 0 ]
    [ -f "${SERVERS_FILE}" ]
    
    grep -q "webserver" "${SERVERS_FILE}"
    grep -q "web.example.com" "${SERVERS_FILE}"
    grep -q "admin" "${SERVERS_FILE}"
}

@test "import_ssh_config: handles missing config file" {
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    run "${BATS_TEST_DIRNAME}/../sx" --ssh-config "/nonexistent/config"
    
    [ "$status" -eq 1 ]
    [[ "$output" =~ "File not found" ]]
}

@test "import_ssh_config: sets default user to root when missing" {
    local config="${BATS_TEST_DIRNAME}/fixtures/sample-ssh-config"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    "${BATS_TEST_DIRNAME}/../sx" --ssh-config "${config}" > /dev/null
    
    grep "backup" "${SERVERS_FILE}" | grep -q "|root|"
}

@test "import_ssh_config: sets default port to 22 when missing" {
    local config="${BATS_TEST_DIRNAME}/fixtures/sample-ssh-config"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    "${BATS_TEST_DIRNAME}/../sx" --ssh-config "${config}" > /dev/null
    
    grep "webserver" "${SERVERS_FILE}" | grep -q "|22$"
}

@test "import_ssh_config: handles custom ports" {
    local config="${BATS_TEST_DIRNAME}/fixtures/sample-ssh-config"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    "${BATS_TEST_DIRNAME}/../sx" --ssh-config "${config}" > /dev/null
    
    grep "jumphost" "${SERVERS_FILE}" | grep -q "|2222$"
}

@test "import_ssh_config: skips wildcard hosts" {
    local config="${BATS_TEST_DIRNAME}/fixtures/sample-ssh-config"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    "${BATS_TEST_DIRNAME}/../sx" --ssh-config "${config}" > /dev/null
    
    ! grep -q "^\*|" "${SERVERS_FILE}"
}

@test "import_ssh_config: creates properly formatted server entries" {
    local config="${BATS_TEST_DIRNAME}/fixtures/sample-ssh-config"
    
    export CONFIG_DIR="${TEST_DIR}/.config/sx"
    export SERVERS_FILE="${CONFIG_DIR}/servers"
    
    "${BATS_TEST_DIRNAME}/../sx" --ssh-config "${config}" > /dev/null
    
    line=$(grep "database" "${SERVERS_FILE}")
    
    echo "$line" | grep -qE "^[^|]+\|[^|]+@[^|]+:[0-9]+\|[^|]+\|[^|]+\|[0-9]+$"
}
