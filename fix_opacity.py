import os, re

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Regex: tangkap withOpacity(...) meski multi-line
            new_content = re.sub(
                r'\.withOpacity\s*\(\s*([^)]+)\s*\)',
                r'.withValues(alpha: \1)',
                content,
                flags=re.DOTALL
            )
            
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f'Fixed: {path}')

print('Done! Run "flutter analyze" to verify.')