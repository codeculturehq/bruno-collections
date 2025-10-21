# Sanitize .bru files - replace sensitive data with {{variables}}
sanitize:
	@echo "Sanitizing .bru files..."
	@bash sanitize_bru_env.sh $(folder)
	@echo "Done!"
