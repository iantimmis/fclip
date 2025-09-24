#!/bin/bash
set -e

# fclip test suite
# Tests all core functionality of fclip commands

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Use installed commands if available, fallback to local src/
if command -v fcopy >/dev/null 2>&1; then
    SRC_DIR=""  # Commands are in PATH
else
    SRC_DIR="$SCRIPT_DIR/../src/"  # Use local development version
fi

# Helper function to run fclip commands
run_cmd() {
    local cmd="$1"
    shift
    "${SRC_DIR}${cmd}" "$@"
}
TEST_DIR="/tmp/fclip_test_$$"
FAILURES=0
TESTS_RUN=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_RUN++))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILURES++))
    ((TESTS_RUN++))
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

cleanup() {
    rm -rf "$TEST_DIR"
    rm -rf "$HOME/.fclip"
}

setup() {
    cleanup
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Create test files
    echo "test file content" > test_file.txt
    mkdir test_dir
    echo "nested content" > test_dir/nested.txt
    
    info "Test environment set up in $TEST_DIR"
}

# Test if a command exists and is executable
test_command_exists() {
    local cmd="$1"
    if [ -n "$SRC_DIR" ]; then
        # Testing local development version
        if [ -x "$SRC_DIR$cmd" ]; then
            pass "Command $cmd exists and is executable"
        else
            fail "Command $cmd is missing or not executable"
        fi
    else
        # Testing installed version
        if command -v "$cmd" >/dev/null 2>&1; then
            pass "Command $cmd is installed and available"
        else
            fail "Command $cmd is not installed or not in PATH"
        fi
    fi
}

# Test basic fcopy functionality
test_fcopy() {
    info "Testing fcopy..."
    
    # Test copying a file
    if run_cmd fcopy test_file.txt >/dev/null 2>&1; then
        pass "fcopy can copy a file"
    else
        fail "fcopy failed to copy a file"
        return
    fi
    
    # Test copying a directory
    if run_cmd fcopy test_dir >/dev/null 2>&1; then
        pass "fcopy can copy a directory"
    else
        fail "fcopy failed to copy a directory"
    fi
    
    # Test copying non-existent file
    if run_cmd fcopy nonexistent.txt 2>/dev/null; then
        fail "fcopy should fail on non-existent file"
    else
        pass "fcopy correctly rejects non-existent file"
    fi
}

# Test fstatus functionality
test_fstatus() {
    info "Testing fstatus..."
    
    # Copy a file first
    run_cmd fcopy test_file.txt >/dev/null 2>&1
    
    # Test fstatus shows clipboard contents
    local status_output
    status_output=$(run_cmd fstatus 2>/dev/null)
    
    if echo "$status_output" | grep -q "test_file.txt"; then
        pass "fstatus shows copied file name"
    else
        fail "fstatus does not show copied file name"
    fi
    
    if echo "$status_output" | grep -q "Operation: copy"; then
        pass "fstatus shows operation type"
    else
        fail "fstatus does not show operation type"
    fi
    
    if echo "$status_output" | grep -q "Type: file"; then
        pass "fstatus shows file type"
    else
        fail "fstatus does not show file type"
    fi
}

# Test fpaste functionality
test_fpaste() {
    info "Testing fpaste..."
    
    # Copy a file and paste it elsewhere
    "$SRC_DIR/fcopy" test_file.txt >/dev/null 2>&1
    
    mkdir paste_test
    cd paste_test
    
    if "$SRC_DIR/fpaste" >/dev/null 2>&1; then
        pass "fpaste command executed successfully"
    else
        fail "fpaste command failed"
        cd ..
        return
    fi
    
    if [ -f "test_file.txt" ]; then
        pass "fpaste created the file"
    else
        fail "fpaste did not create the file"
    fi
    
    if [ "$(cat test_file.txt)" = "test file content" ]; then
        pass "fpaste preserved file content"
    else
        fail "fpaste did not preserve file content"
    fi
    
    cd ..
}

# Test fcut functionality
test_fcut() {
    info "Testing fcut..."
    
    # Create a file to cut
    echo "cut test content" > cut_test.txt
    
    # Cut the file
    if "$SRC_DIR/fcut" cut_test.txt >/dev/null 2>&1; then
        pass "fcut command executed successfully"
    else
        fail "fcut command failed"
        return
    fi
    
    # Check fstatus shows move operation
    local status_output
    status_output=$("$SRC_DIR/fstatus" 2>/dev/null)
    
    if echo "$status_output" | grep -q "Operation: move"; then
        pass "fcut sets operation type to move"
    else
        fail "fcut does not set operation type to move"
    fi
    
    # Paste in another location
    mkdir cut_test_dir
    cd cut_test_dir
    
    "$SRC_DIR/fpaste" >/dev/null 2>&1
    
    if [ -f "cut_test.txt" ]; then
        pass "fcut + fpaste created file in new location"
    else
        fail "fcut + fpaste did not create file in new location"
    fi
    
    cd ..
    
    # Original should be deleted
    if [ ! -f "cut_test.txt" ]; then
        pass "fcut + fpaste deleted original file"
    else
        fail "fcut + fpaste did not delete original file"
    fi
}

# Test fclear functionality
test_fclear() {
    info "Testing fclear..."
    
    # Copy something first
    "$SRC_DIR/fcopy" test_file.txt >/dev/null 2>&1
    
    # Clear clipboard
    if "$SRC_DIR/fclear" >/dev/null 2>&1; then
        pass "fclear command executed successfully"
    else
        fail "fclear command failed"
        return
    fi
    
    # Check clipboard is empty
    local status_output
    status_output=$("$SRC_DIR/fstatus" 2>/dev/null)
    
    if echo "$status_output" | grep -q "empty"; then
        pass "fclear emptied the clipboard"
    else
        fail "fclear did not empty the clipboard"
    fi
}

# Test fclip main command
test_fclip() {
    info "Testing fclip main command..."
    
    # Test version
    if "$SRC_DIR/fclip" --version | grep -q "fclip v"; then
        pass "fclip --version works"
    else
        fail "fclip --version does not work"
    fi
    
    # Test help
    if "$SRC_DIR/fclip" --help | grep -q "Commands:"; then
        pass "fclip --help works"
    else
        fail "fclip --help does not work"
    fi
}

# Run all tests
run_tests() {
    info "Starting fclip test suite..."
    echo ""
    
    setup
    
    # Test command existence
    test_command_exists "fcopy"
    test_command_exists "fpaste"
    test_command_exists "fcut"
    test_command_exists "fstatus"
    test_command_exists "fclear"
    test_command_exists "fclip"
    
    echo ""
    
    # Test functionality
    test_fcopy
    test_fstatus
    test_fpaste
    test_fcut
    test_fclear
    test_fclip
    
    echo ""
    
    # Summary
    if [ $FAILURES -eq 0 ]; then
        info "All $TESTS_RUN tests passed! ✅"
        cleanup
        exit 0
    else
        warn "$FAILURES out of $TESTS_RUN tests failed! ❌"
        cleanup
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "fclip test suite"
        echo "Usage: $0 [--help]"
        echo ""
        echo "Runs comprehensive tests for all fclip commands"
        exit 0
        ;;
    *)
        run_tests
        ;;
esac