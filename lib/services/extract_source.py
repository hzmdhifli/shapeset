import re
import json
import os

def extract_l10n():
    filename = 'localization_service.dart'
    if not os.path.exists(filename):
        print(f"{filename} not found in current directory")
        return

    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract Arabic block to get keys
    ar_match = re.search(r"'ar': \{(.*?)\},", content, re.DOTALL)
    if not ar_match:
        print("Arabic block not found")
        return
    
    ar_content = ar_match.group(1)
    keys = re.findall(r"'([^']+)':", ar_content)
    
    # Extract English block to get source strings
    en_match = re.search(r"'en': \{(.*?)\},", content, re.DOTALL)
    if not en_match:
        print("English block not found")
        return
    
    en_content = en_match.group(1)
    en_map = {}
    # Use a more robust regex for key-value pairs
    pairs = re.findall(r"'([^']+)':\s*(?:'([^']*)'|\"([^\"]*)\")", en_content)
    for k, v1, v2 in pairs:
        en_map[k] = v1 or v2

    # Map keys to English values
    result = {}
    for key in keys:
        result[key] = en_map.get(key, f"MISSING_{key}")
    
    with open('source_translations.json', 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    print(f"Extracted {len(keys)} keys.")

if __name__ == "__main__":
    extract_l10n()
