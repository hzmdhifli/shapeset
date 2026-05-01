import json
import re

file_path = r'c:\Users\hzmdh\OneDrive\Desktop\ShapeSet\athlete_app\lib\services\localization_service.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Extract es map
es_match = re.search(r"'es': \{(.*?)\},", content, re.DOTALL)
es_map = {}
if es_match:
    es_block = es_match.group(1)
    for line in es_block.split('\n'):
        m = re.search(r"'(.*?)':\s*['\"](.*?)['\"],", line)
        if m:
            es_map[m.group(1)] = m.group(2)

with open(r'c:\Users\hzmdh\OneDrive\Desktop\ShapeSet\athlete_app\lib\services\extracted_translations.json', 'r', encoding='utf-8') as f:
    extracted = json.load(f)

missing = []
for item in extracted:
    if item['key'] not in es_map:
        missing.append(item)

print(f"Missing {len(missing)} keys in es.")
with open('missing_es_translations.json', 'w', encoding='utf-8') as f:
    json.dump(missing, f, ensure_ascii=False, indent=2)
