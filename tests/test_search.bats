#!/usr/bin/env bats

load 'setup.bash'

setup() {
    setup_test_env
    
    cat > "${SERVERS_FILE}" << 'EOF'
prod-web|admin@192.168.1.10:22|192.168.1.10|admin|22
prod-db|dbuser@192.168.1.20:3306|192.168.1.20|dbuser|3306
dev-web|developer@10.0.0.10:22|10.0.0.10|developer|22
staging-api|apiuser@staging.example.com:8080|staging.example.com|apiuser|8080
test-server|root@test.local:22|test.local|root|22
EOF
}

teardown() {
    cleanup_test_env
}

@test "search: filters servers by search term (case insensitive)" {
    run bash -c "cd ${BATS_TEST_DIRNAME}/.. && source sx && awk -F'|' -v q='prod' 'tolower(\$0) ~ tolower(q) {print \$1 \" (\" \$2 \")|\"\$3\"|\"\$4\"|\"\$5}' '${SERVERS_FILE}'"
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "prod-web" ]]
    [[ "$output" =~ "prod-db" ]]
    [[ ! "$output" =~ "dev-web" ]]
}

@test "search: handles uppercase search query" {
    run bash -c "cd ${BATS_TEST_DIRNAME}/.. && source sx && awk -F'|' -v q='PROD' 'tolower(\$0) ~ tolower(q) {print \$1 \" (\" \$2 \")|\"\$3\"|\"\$4\"|\"\$5}' '${SERVERS_FILE}'"
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "prod-web" ]]
    [[ "$output" =~ "prod-db" ]]
}

@test "search: filters by partial hostname match" {
    run bash -c "cd ${BATS_TEST_DIRNAME}/.. && source sx && awk -F'|' -v q='example.com' 'tolower(\$0) ~ tolower(q) {print \$1 \" (\" \$2 \")|\"\$3\"|\"\$4\"|\"\$5}' '${SERVERS_FILE}'"
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "staging-api" ]]
    [[ ! "$output" =~ "prod-web" ]]
}

@test "search: filters by username" {
    run bash -c "cd ${BATS_TEST_DIRNAME}/.. && source sx && awk -F'|' -v q='dbuser' 'tolower(\$0) ~ tolower(q) {print \$1 \" (\" \$2 \")|\"\$3\"|\"\$4\"|\"\$5}' '${SERVERS_FILE}'"
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "prod-db" ]]
    [[ ! "$output" =~ "prod-web" ]]
}

@test "search: returns empty when no match found" {
    run awk -F'|' -v q='nonexistent' 'tolower($0) ~ tolower(q) {print $1 " (" $2 ")|"$3"|"$4"|"$5}' "${SERVERS_FILE}"
    
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "search: lists all servers when no query provided" {
    run bash -c "cd ${BATS_TEST_DIRNAME}/.. && source sx && awk -F'|' '{print \$1 \" (\" \$2 \")|\"\$3\"|\"\$4\"|\"\$5}' '${SERVERS_FILE}'"
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "prod-web" ]]
    [[ "$output" =~ "prod-db" ]]
    [[ "$output" =~ "dev-web" ]]
    [[ "$output" =~ "staging-api" ]]
    [[ "$output" =~ "test-server" ]]
}

@test "search: handles special regex characters in search" {
    run bash -c "cd ${BATS_TEST_DIRNAME}/.. && source sx && awk -F'|' -v q='192.168.1' 'tolower(\$0) ~ tolower(q) {print \$1 \" (\" \$2 \")|\"\$3\"|\"\$4\"|\"\$5}' '${SERVERS_FILE}'"
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "prod-web" ]]
    [[ "$output" =~ "prod-db" ]]
}

@test "search: counts single match correctly" {
    result=$(bash -c "cd ${BATS_TEST_DIRNAME}/.. && source sx && awk -F'|' -v q='test-server' 'tolower(\$0) ~ tolower(q) {print \$1 \" (\" \$2 \")|\"\$3\"|\"\$4\"|\"\$5}' '${SERVERS_FILE}'")
    
    count=$(echo "$result" | wc -l)
    [ "$count" -eq 1 ]
}

@test "search: counts multiple matches correctly" {
    result=$(bash -c "cd ${BATS_TEST_DIRNAME}/.. && source sx && awk -F'|' -v q='prod' 'tolower(\$0) ~ tolower(q) {print \$1 \" (\" \$2 \")|\"\$3\"|\"\$4\"|\"\$5}' '${SERVERS_FILE}'")
    
    count=$(echo "$result" | wc -l)
    [ "$count" -eq 2 ]
}

@test "search: preserves pipe-delimited format in output" {
    run bash -c "cd ${BATS_TEST_DIRNAME}/.. && source sx && awk -F'|' -v q='prod-web' 'tolower(\$0) ~ tolower(q) {print \$1 \" (\" \$2 \")|\"\$3\"|\"\$4\"|\"\$5}' '${SERVERS_FILE}'"
    
    [ "$status" -eq 0 ]
    echo "$output" | grep -qE "^[^|]+\|[^|]+\|[^|]+\|[0-9]+$"
}

@test "search: includes display name and connection string" {
    run bash -c "cd ${BATS_TEST_DIRNAME}/.. && source sx && awk -F'|' -v q='prod-web' 'tolower(\$0) ~ tolower(q) {print \$1 \" (\" \$2 \")|\"\$3\"|\"\$4\"|\"\$5}' '${SERVERS_FILE}'"
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "prod-web (admin@192.168.1.10:22)" ]]
}
