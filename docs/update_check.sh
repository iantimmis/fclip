#!/bin/bash

# Optional: Check for updates (could be called periodically)
# Usage: source this in your shell profile or run manually

check_fclip_update() {
    local current_version
    local latest_version
    
    # Get current version
    if ! command -v fclip >/dev/null 2>&1; then
        return 0  # Not installed
    fi
    
    current_version=$(fclip --version 2>/dev/null | grep -o 'v[0-9.]*')
    if [ -z "$current_version" ]; then
        return 0
    fi
    
    # Get latest version from GitHub
    latest_version=$(curl -s https://api.github.com/repos/iantimmis/fclip/releases/latest | grep '"tag_name"' | cut -d'"' -f4 2>/dev/null)
    
    if [ -n "$latest_version" ] && [ "$current_version" != "$latest_version" ]; then
        echo "📦 fclip update available: $current_version → $latest_version"
        echo "Run: fclip --update"
    fi
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    check_fclip_update
fi