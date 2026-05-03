#!/usr/bin/env bats

load 'setup.bash'

setup() {
    setup_test_env
}

teardown() {
    cleanup_test_env
}

@test "import_filezilla: imports servers as SSH config blocks" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla.xml"

    run "${BATS_TEST_DIRNAME}/../sx" --import "${xml}"

    [ "$status" -eq 0 ]
    [ -f "${SX_SSH_CONFIG}" ]

    grep -q "# sx-name: Production Server" "${SX_SSH_CONFIG}"
    grep -q "Host production-server" "${SX_SSH_CONFIG}"
    grep -q "HostName 192.168.1.100" "${SX_SSH_CONFIG}"
    grep -q "User admin" "${SX_SSH_CONFIG}"
}

@test "import_filezilla: ensures managed include in SSH config" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla.xml"

    run "${BATS_TEST_DIRNAME}/../sx" --import "${xml}"

    [ "$status" -eq 0 ]
    grep -Fxq "Include ~/.ssh/config.d/sx.conf" "${SSH_CONFIG}"
}

@test "import_filezilla: handles missing XML file" {
    run "${BATS_TEST_DIRNAME}/../sx" --import "/nonexistent/file.xml"

    [ "$status" -eq 1 ]
    [[ "$output" =~ "File not found" ]]
}

@test "import_filezilla: sets default port to 22 when missing" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla.xml"

    "${BATS_TEST_DIRNAME}/../sx" --import "${xml}" > /dev/null

    grep -A4 "Host staging" "${SX_SSH_CONFIG}" | grep -q "Port 22"
}

@test "import_filezilla: sets default user to root when missing" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla.xml"

    "${BATS_TEST_DIRNAME}/../sx" --import "${xml}" > /dev/null

    grep -A4 "Host staging" "${SX_SSH_CONFIG}" | grep -q "User root"
}

@test "import_filezilla: handles custom ports" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla.xml"

    "${BATS_TEST_DIRNAME}/../sx" --import "${xml}" > /dev/null

    grep -A4 "Host dev-environment" "${SX_SSH_CONFIG}" | grep -q "Port 2222"
}

@test "import_filezilla: creates valid SSH config entries" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla.xml"

    "${BATS_TEST_DIRNAME}/../sx" --import "${xml}" > /dev/null

    grep -A4 "Host production-server" "${SX_SSH_CONFIG}" | grep -q "HostName 192.168.1.100"
    grep -A4 "Host production-server" "${SX_SSH_CONFIG}" | grep -q "User admin"
    grep -A4 "Host production-server" "${SX_SSH_CONFIG}" | grep -q "Port 22"
}

@test "import_filezilla: handles XML with folder sections" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla-folders.xml"

    run "${BATS_TEST_DIRNAME}/../sx" --import "${xml}"

    [ "$status" -eq 0 ]

    grep -q "# sx-name: Production Web 1" "${SX_SSH_CONFIG}"
    grep -q "# sx-name: Production Database" "${SX_SSH_CONFIG}"
    grep -q "# sx-name: Dev API Server" "${SX_SSH_CONFIG}"
    grep -q "# sx-name: QA Test Server" "${SX_SSH_CONFIG}"
}

@test "import_filezilla: imports nested folders correctly" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla-folders.xml"

    "${BATS_TEST_DIRNAME}/../sx" --import "${xml}" > /dev/null

    grep -q "# sx-name: Client A Production" "${SX_SSH_CONFIG}"
    grep -q "# sx-name: Client B Server" "${SX_SSH_CONFIG}"
}

@test "import_filezilla: counts all servers in folders" {
    local xml="${BATS_TEST_DIRNAME}/fixtures/sample-filezilla-folders.xml"

    "${BATS_TEST_DIRNAME}/../sx" --import "${xml}" > /dev/null

    count=$(grep -c "^Host " "${SX_SSH_CONFIG}")

    [ "$count" -eq 6 ]
}

@test "import_ssh_config: imports servers from SSH config" {
    local config="${BATS_TEST_DIRNAME}/fixtures/sample-ssh-config"

    run "${BATS_TEST_DIRNAME}/../sx" --ssh-config "${config}"

    [ "$status" -eq 0 ]
    [ -f "${SX_SSH_CONFIG}" ]

    grep -q "Host webserver" "${SX_SSH_CONFIG}"
    grep -q "HostName web.example.com" "${SX_SSH_CONFIG}"
    grep -q "User admin" "${SX_SSH_CONFIG}"
}

@test "import_ssh_config: handles missing config file" {
    run "${BATS_TEST_DIRNAME}/../sx" --ssh-config "/nonexistent/config"

    [ "$status" -eq 1 ]
    [[ "$output" =~ "File not found" ]]
}

@test "import_ssh_config: sets default user to root when missing" {
    local config="${BATS_TEST_DIRNAME}/fixtures/sample-ssh-config"

    "${BATS_TEST_DIRNAME}/../sx" --ssh-config "${config}" > /dev/null
    grep -A4 "Host backup" "${SX_SSH_CONFIG}" | grep -q "User root"
}

@test "import_ssh_config: sets default port to 22 when missing" {
    local config="${BATS_TEST_DIRNAME}/fixtures/sample-ssh-config"

    "${BATS_TEST_DIRNAME}/../sx" --ssh-config "${config}" > /dev/null
    grep -A4 "Host webserver" "${SX_SSH_CONFIG}" | grep -q "Port 22"
}

@test "import_ssh_config: handles custom ports" {
    local config="${BATS_TEST_DIRNAME}/fixtures/sample-ssh-config"

    "${BATS_TEST_DIRNAME}/../sx" --ssh-config "${config}" > /dev/null
    grep -A4 "Host jumphost" "${SX_SSH_CONFIG}" | grep -q "Port 2222"
}

@test "import_ssh_config: skips wildcard hosts" {
    local config="${BATS_TEST_DIRNAME}/fixtures/sample-ssh-config"

    "${BATS_TEST_DIRNAME}/../sx" --ssh-config "${config}" > /dev/null
    ! grep -q "Host \*" "${SX_SSH_CONFIG}"
}

@test "import_ssh_config: creates valid SSH config entries" {
    local config="${BATS_TEST_DIRNAME}/fixtures/sample-ssh-config"

    "${BATS_TEST_DIRNAME}/../sx" --ssh-config "${config}" > /dev/null
    grep -A4 "Host database" "${SX_SSH_CONFIG}" | grep -q "HostName db.internal.net"
    grep -A4 "Host database" "${SX_SSH_CONFIG}" | grep -q "User dbadmin"
    grep -A4 "Host database" "${SX_SSH_CONFIG}" | grep -q "Port 5432"
}

@test "migrate: converts legacy servers file to SSH config" {
    cat > "${SERVERS_FILE}" << 'EOF'
prod-web|admin@192.168.1.10:22|192.168.1.10|admin|22
dev-db|root@localhost:3306|localhost|root|3306
EOF

    run "${BATS_TEST_DIRNAME}/../sx" --migrate

    [ "$status" -eq 0 ]
    grep -q "Host prod-web" "${SX_SSH_CONFIG}"
    grep -q "HostName 192.168.1.10" "${SX_SSH_CONFIG}"
    grep -q "Host dev-db" "${SX_SSH_CONFIG}"
    grep -q "dev-db|root@localhost:3306|localhost|root|3306" "${SERVERS_FILE}"
}

@test "migrate: handles missing legacy file" {
    rm "${SERVERS_FILE}"

    run "${BATS_TEST_DIRNAME}/../sx" --migrate


    [ "$status" -eq 1 ]
    [[ "$output" =~ "File not found" ]]
}
