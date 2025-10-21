#!/usr/bin/env bash
set -e

# Simple Bruno sanitizer - replaces sensitive data with {{variable_name}}

FOLDER="${1:-.}"
ROOT_DIR="$(pwd)"

# Define sensitive keywords that should always be sanitized
SENSITIVE_KEYWORDS="token|secret|password|passwd|pwd|key|apikey|api_key|username"

# Determine target path
if [ "$FOLDER" = "." ]; then
    TARGET_PATH="$ROOT_DIR"
else
    TARGET_PATH="$ROOT_DIR/$FOLDER"
fi

# Check if folder exists
if [ ! -d "$TARGET_PATH" ]; then
    echo "Folder not found: $TARGET_PATH"
    exit 1
fi

# Find environments folder
ENV_DIR="$TARGET_PATH/environments"
if [ ! -d "$ENV_DIR" ]; then
    ENV_DIR="$ROOT_DIR/environments"
    if [ ! -d "$ENV_DIR" ]; then
        echo "⚠️ No environments folder found"
        # Don't exit - we can still sanitize sensitive fields
    fi
fi

if [ -d "$ENV_DIR" ]; then
    echo "Using environments: $ENV_DIR"
fi

# Create temp file for variables
TMP_FILE="/tmp/bruno_vars.tmp"
> "$TMP_FILE"

# Extract variables from all .bru files in environments (if exists)
if [ -d "$ENV_DIR" ]; then
    for envfile in "$ENV_DIR"/*.bru; do
        [ -f "$envfile" ] || continue
        
        # Extract vars block and parse key:value pairs
        awk '/^vars[[:space:]]*{/,/^}/' "$envfile" | 
        grep ":" | 
        grep -v "^vars\|^}" |
        while IFS=':' read -r key value; do
            # Clean key and value
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs | sed "s/^['\"]//;s/['\"]$//")
            
            # Skip empty values
            [ -z "$value" ] && continue
            
            # Save to temp file
            echo "${key}|${value}" >> "$TMP_FILE"
        done
    done
    
    if [ -s "$TMP_FILE" ]; then
        echo "Found $(wc -l < "$TMP_FILE") environment variables"
    fi
fi

# Sort by value length (longest first to avoid partial replacements)
sort -t'|' -k2 -r "$TMP_FILE" -o "$TMP_FILE"

# Process all .bru files (excluding environments folder)
echo "Processing .bru files..."
files_processed=0
files_modified=0

find "$TARGET_PATH" -name "*.bru" -type f ! -path "*/environments/*" | while read -r file; do
    modified=false
    ((files_processed++))
    
    # Create backup
    cp "$file" "${file}.tmp"
    
    # First, replace known environment variables
    if [ -s "$TMP_FILE" ]; then
        while IFS='|' read -r key value; do
            # Skip if value not in file
            grep -qF "$value" "$file" 2>/dev/null || continue
            
            # Escape special characters for sed (but not forward slashes since we'll use | delimiter)
            escaped_value=$(printf '%s\n' "$value" | sed 's/[[\.*^$()+?{|]/\\&/g')
            
            # Replace value with {{key}} - using | as delimiter to handle URLs
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s|${escaped_value}|{{${key}}}|g" "$file"
            else
                sed -i "s|${escaped_value}|{{${key}}}|g" "$file"
            fi
            
            modified=true
        done < "$TMP_FILE"
    fi
    
    # Now handle ALL sensitive fields automatically
    # Process the file line by line looking for sensitive keys
    while IFS= read -r line; do
        # Check if line contains a key:value pattern with sensitive keyword
        if echo "$line" | grep -qE "($SENSITIVE_KEYWORDS)[^:]*:[[:space:]]*[^{]" && \
           ! echo "$line" | grep -q "{{"; then
            
            # Extract the key and check if it's sensitive
            if echo "$line" | grep -qE "^[[:space:]]*(.*($SENSITIVE_KEYWORDS).*)[[:space:]]*:"; then
                # Get the key name
                key=$(echo "$line" | sed -E 's/^[[:space:]]*([^:]+):.*/\1/' | xargs)
                
                # Check if the value is not already a variable reference
                if ! echo "$line" | grep -qE ":[[:space:]]*{{.*}}"; then
                    # Replace the value with {{key}} - using | as delimiter
                    if [[ "$OSTYPE" == "darwin"* ]]; then
                        sed -i '' "s|\(${key}[[:space:]]*:[[:space:]]*\)[^}]*|\1{{${key}}}|" "$file"
                    else
                        sed -i "s|\(${key}[[:space:]]*:[[:space:]]*\)[^}]*|\1{{${key}}}|" "$file"
                    fi
                    modified=true
                    echo "  Sanitized sensitive field: $key"
                fi
            fi
        fi
    done < "$file"
    
    # Special handling for auth:bearer blocks
    if grep -q "auth:bearer" "$file"; then
        # Check if we have a token line that's not already templated
        if grep -A5 "auth:bearer" "$file" | grep -q "token:" && \
           ! grep -A5 "auth:bearer" "$file" | grep -q "token:[[:space:]]*{{"; then
            
            # Replace token value in auth:bearer block - using | as delimiter
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' '/auth:bearer/,/^}/s|\(token:[[:space:]]*\)[^}]*|\1{{token}}|' "$file"
            else
                sed -i '/auth:bearer/,/^}/s|\(token:[[:space:]]*\)[^}]*|\1{{token}}|' "$file"
            fi
            modified=true
            echo "Sanitized auth:bearer token"
        fi
    fi
    
    # Special handling for headers with Authorization
    if grep -q "Authorization:" "$file"; then
        if ! grep -q "Authorization:[[:space:]]*.*{{" "$file"; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # Replace Bearer tokens
                sed -i '' "s|\(Authorization:[[:space:]]*Bearer[[:space:]]\+\)[^}]*|\1{{access_token}}|" "$file"
                # Replace Basic auth
                sed -i '' "s|\(Authorization:[[:space:]]*Basic[[:space:]]\+\)[^}]*|\1{{basic_auth}}|" "$file"
                # Replace API keys
                sed -i '' "s|\(Authorization:[[:space:]]*\)[^{B][^}]*|\1{{api_key}}|" "$file"
            else
                sed -i "s|\(Authorization:[[:space:]]*Bearer[[:space:]]\+\)[^}]*|\1{{access_token}}|" "$file"
                sed -i "s|\(Authorization:[[:space:]]*Basic[[:space:]]\+\)[^}]*|\1{{basic_auth}}|" "$file"
                sed -i "s|\(Authorization:[[:space:]]*\)[^{B][^}]*|\1{{api_key}}|" "$file"
            fi
            modified=true
            echo "Sanitized Authorization header"
        fi
    fi
    
    if [ "$modified" = true ]; then
        echo "✓ $(basename "$file")"
        ((files_modified++))
    fi
    
    # Remove temp file
    rm -f "${file}.tmp"
done

# Cleanup
rm -f "$TMP_FILE"

echo ""
echo "  Files processed: $files_processed"
echo "  Files modified: $files_modified"
echo ""
echo "Sanitization complete!"

# Provide hint about adding to environment
if [ "$files_modified" -gt 0 ]; then
    echo ""
    echo "Remember to add sanitized values to your environment files before using the collection!"
fi