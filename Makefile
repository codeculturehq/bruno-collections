# Sanitize .bru files - replace sensitive data with {{variables}}
sanitize:
	@echo "Sanitizing .bru files..."
	@bash sanitize_bru_env.sh $(folder)
	@echo "Done!"

# Run setup-hooks script
setup-hooks:
	@echo "Setting up Git hooks..."
	@bash setup-hooks.sh
	@echo "Git hooks set up!"