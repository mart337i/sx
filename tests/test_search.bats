#!/usr/bin/env bats

load 'setup.bash'

setup() {
    setup_test_env

    cat > "${SX_SSH_CONFIG}" << 'EOF'
# sx-name: prod-web
Host prod-web
    HostName 192.168.1.10
    User admin
    Port 22

# sx-name: prod-db
Host prod-db
    HostName 192.168.1.20
    User dbuser
    Port 3306

# sx-name: dev-web
Host dev-web
    HostName 10.0.0.10
    User developer
    Port 22

# sx-name: staging-api
Host staging-api
    HostName staging.example.com
    User apiuser
    Port 8080

# sx-name: test-server
Host test-server
    HostName test.local
    User root
    Port 22
EOF
}

teardown() {
    cleanup_test_env
}

@test "search: filters servers by search term (case insensitive)" {
    run bash -c "source '${BATS_TEST_DIRNAME}/../sx' && ssh_config_entries | awk -F'|' -v q='prod' 'index(tolower(\$0), tolower(q)) {print}'"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "prod-web" ]]
    [[ "$output" =~ "prod-db" ]]
    [[ ! "$output" =~ "dev-web" ]]
}

@test "search: handles uppercase search query" {
    run bash -c "source '${BATS_TEST_DIRNAME}/../sx' && ssh_config_entries | awk -F'|' -v q='PROD' 'index(tolower(\$0), tolower(q)) {print}'"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "prod-web" ]]
    [[ "$output" =~ "prod-db" ]]
}

@test "search: filters by partial hostname match" {
    run bash -c "source '${BATS_TEST_DIRNAME}/../sx' && ssh_config_entries | awk -F'|' -v q='example.com' 'index(tolower(\$0), tolower(q)) {print}'"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "staging-api" ]]
    [[ ! "$output" =~ "prod-web" ]]
}

@test "search: filters by username" {
    run bash -c "source '${BATS_TEST_DIRNAME}/../sx' && ssh_config_entries | awk -F'|' -v q='dbuser' 'index(tolower(\$0), tolower(q)) {print}'"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "prod-db" ]]
    [[ ! "$output" =~ "prod-web" ]]
}

@test "search: returns empty when no match found" {
    run bash -c "source '${BATS_TEST_DIRNAME}/../sx' && ssh_config_entries | awk -F'|' -v q='nonexistent' 'index(tolower(\$0), tolower(q)) {print}'"

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "search: lists all servers when no query provided" {
    run bash -c "source '${BATS_TEST_DIRNAME}/../sx' && ssh_config_entries"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "prod-web" ]]
    [[ "$output" =~ "prod-db" ]]
    [[ "$output" =~ "dev-web" ]]
    [[ "$output" =~ "staging-api" ]]
    [[ "$output" =~ "test-server" ]]
}

@test "search: handles special regex characters in search" {
    run bash -c "source '${BATS_TEST_DIRNAME}/../sx' && ssh_config_entries | awk -F'|' -v q='192.168.1' 'index(tolower(\$0), tolower(q)) {print}'"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "prod-web" ]]
    [[ "$output" =~ "prod-db" ]]
}

@test "search: counts single match correctly" {
    result=$(bash -c "source '${BATS_TEST_DIRNAME}/../sx' && ssh_config_entries | awk -F'|' -v q='test-server' 'index(tolower(\$0), tolower(q)) {print}'")

    count=$(printf '%s\n' "$result" | wc -l)
    [ "$count" -eq 1 ]
}

@test "search: counts multiple matches correctly" {
    result=$(bash -c "source '${BATS_TEST_DIRNAME}/../sx' && ssh_config_entries | awk -F'|' -v q='prod' 'index(tolower(\$0), tolower(q)) {print}'")

    count=$(printf '%s\n' "$result" | wc -l)
    [ "$count" -eq 2 ]
}

@test "search: preserves parser output format" {
    run bash -c "source '${BATS_TEST_DIRNAME}/../sx' && ssh_config_entries | awk -F'|' -v q='prod-web' 'index(tolower(\$0), tolower(q)) {print}'"

    [ "$status" -eq 0 ]
    echo "$output" | grep -qE "^[^|]+\|[^|]+\|[^|]+\|[^|]+\|[0-9]+$"
}

@test "search: includes display name and connection string" {
    run bash -c "source '${BATS_TEST_DIRNAME}/../sx' && ssh_config_entries | awk -F'|' -v q='prod-web' 'index(tolower(\$0), tolower(q)) {print}' | format_entries_for_selection"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "prod-web - prod-web (admin@192.168.1.10:22)" ]]
}
