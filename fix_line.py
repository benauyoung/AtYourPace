import sys

# Read the file
with open(r'c:\Users\Benjamin\Desktop\Projects\AYP\lib\presentation\screens\modules\marketplace\widgets\marketplace_map_view.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Fix line 149 (index 148) - comment out the closing brace
if len(lines) > 148:
    lines[148] = '      // }\r\n'

# Write back
with open(r'c:\Users\Benjamin\Desktop\Projects\AYP\lib\presentation\screens\modules\marketplace\widgets\marketplace_map_view.dart', 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("Fixed line 149")
