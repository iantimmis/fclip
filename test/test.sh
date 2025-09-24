#!/bin/bash
set -e

echo "🧪 Simple fclip test"

# Cleanup any previous state
rm -rf ~/.fclip test_*.txt test_dir

# Test 1: Basic copy/paste
echo "Test 1: Basic copy/paste"
echo "test content" > test_file.txt
fcopy test_file.txt
rm test_file.txt  # Remove so paste can work
fpaste
if [ -f "test_file.txt" ] && [ "$(cat test_file.txt)" = "test content" ]; then
    echo "✅ Copy/paste works"
else
    echo "❌ Copy/paste failed"
    exit 1
fi

# Test 2: Status
echo "Test 2: Status check"
fstatus | grep -q "test_file.txt" && echo "✅ Status works" || echo "❌ Status failed"

# Test 3: Clear
echo "Test 3: Clear clipboard"
fclear
fstatus | grep -q "empty" && echo "✅ Clear works" || echo "❌ Clear failed"

# Test 4: Cut/move
echo "Test 4: Cut operation" 
echo "cut test" > cut_file.txt
fcut cut_file.txt
mkdir new_dir
cd new_dir
fpaste
cd ..
if [ -f "new_dir/cut_file.txt" ] && [ ! -f "cut_file.txt" ]; then
    echo "✅ Cut/move works"
else
    echo "❌ Cut/move failed"
fi

# Test 5: Version
echo "Test 5: Version command"
fclip --version | grep -q "fclip v" && echo "✅ Version works" || echo "❌ Version failed"

echo "🎉 All tests completed!"

# Cleanup
rm -rf test_*.txt test_dir cut_file.txt new_dir ~/.fclip