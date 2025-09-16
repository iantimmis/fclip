<div align="center">
  <img src="img/logo.png" width="500">
  <p>A simple file clipboard system for the terminal that allows you to copy, paste, and move files and directories between different terminal sessions.</p>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)](https://github.com/iantimmis/fclip)
[![GitHub release](https://img.shields.io/github/v/release/iantimmis/fclip)](https://github.com/iantimmis/fclip/releases)
[![Downloads](https://img.shields.io/github/downloads/iantimmis/fclip/total)](https://github.com/iantimmis/fclip/releases)

</div>

## Commands

- `fclip --version` - Show version information
- `fclip --help` - Show help and usage examples
- `fcopy <file_or_directory>` - Copy a file or directory to the clipboard
- `fpaste` - Paste the copied file or directory to the current directory
- `fcut <file_or_directory>` - Move a file or directory (copy to clipboard and delete original on paste)
- `fstatus` - Show current clipboard contents
- `fclear` - Clear the clipboard

## Installation

```bash
curl -LsSf https://iantimmis.github.io/fclip/install.sh | sh
```

Or download manually from [releases](https://github.com/iantimmis/fclip/releases).

## Usage Examples

```bash
# Get help and version info
fclip --help
fclip --version

# Copy a file
fcopy example.txt

# In another terminal window/session
fpaste  # Creates example.txt in current directory

# Copy a directory
fcopy my_folder

# Paste the directory
fpaste  # Creates my_folder in current directory

# Move a file (deletes original when pasted)
fcut old_file.txt
fpaste  # Creates old_file.txt here and deletes it from original location

# Check clipboard status
fstatus

# Clear clipboard
fclear
```

## How it works

The system uses a hidden directory `~/.fclip/` to store:
- Copied files/directories in `data/`
- Metadata about the clipboard contents in `info`
- Source path for move operations in `move_source`

Files are actually copied to the clipboard directory, so they persist between terminal sessions and survive system restarts.
