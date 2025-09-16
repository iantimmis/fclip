#!/bin/bash

# Installation script for fclip commands
echo "Installing fclip commands..."

# Create a local bin directory if it doesn't exist
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# Copy the commands
cp src/fcopy "$BIN_DIR/"
cp src/fpaste "$BIN_DIR/"
cp src/fmove "$BIN_DIR/"
cp src/fstatus "$BIN_DIR/"
cp src/fclear "$BIN_DIR/"

# Make them executable
chmod +x "$BIN_DIR/fcopy"
chmod +x "$BIN_DIR/fpaste"
chmod +x "$BIN_DIR/fmove"
chmod +x "$BIN_DIR/fstatus"
chmod +x "$BIN_DIR/fclear"

echo "Commands installed to $BIN_DIR"
echo ""
echo "Add the following line to your ~/.bashrc or ~/.zshrc if not already present:"
echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "Then restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
echo ""
echo "Usage:"
echo "  fcopy <file_or_directory>  - Copy to clipboard"
echo "  fpaste                     - Paste from clipboard"
echo "  fmove <file_or_directory>  - Move via clipboard (deletes original on paste)"
echo "  fstatus                    - Show clipboard contents"
echo "  fclear                     - Clear clipboard"