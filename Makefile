PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SRCDIR = src

SCRIPTS = fcopy fpaste fmove fstatus fclear

.PHONY: install uninstall clean test

install:
	@echo "Installing fclip to $(BINDIR)..."
	@mkdir -p $(BINDIR)
	@for script in $(SCRIPTS); do \
		cp $(SRCDIR)/$$script $(BINDIR)/$$script; \
		chmod +x $(BINDIR)/$$script; \
		echo "  Installed $$script"; \
	done
	@echo "Installation complete!"
	@echo ""
	@echo "Usage:"
	@echo "  fcopy <file_or_directory>  - Copy to clipboard"
	@echo "  fpaste                     - Paste from clipboard"
	@echo "  fmove <file_or_directory>  - Move via clipboard"
	@echo "  fstatus                    - Show clipboard contents"
	@echo "  fclear                     - Clear clipboard"

uninstall:
	@echo "Removing fclip from $(BINDIR)..."
	@for script in $(SCRIPTS); do \
		rm -f $(BINDIR)/$$script; \
		echo "  Removed $$script"; \
	done
	@echo "Uninstall complete!"

clean:
	@echo "Clearing fclip clipboard..."
	@rm -rf ~/.fclip
	@echo "Clipboard cleared!"

test:
	@echo "Running basic tests..."
	@./test.sh