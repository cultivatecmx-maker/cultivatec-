import os
import re

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # Find Text(some.icon, style: TextStyle(...))
    # Or Text(some.icon)
    def replacer(match):
        icon_expr = match.group(1)
        style_expr = match.group(2)
        
        if not style_expr:
            return f"Icon({icon_expr})"
            
        size = ""
        color = ""
        
        size_match = re.search(r'fontSize:\s*([\d\.]+)', style_expr)
        if size_match:
            size = f"size: {size_match.group(1)}"
            
        color_match = re.search(r'color:\s*([^,}]+)', style_expr)
        if color_match:
            color = f"color: {color_match.group(1)}"
            
        args = [a for a in [size, color] if a]
        if args:
            return f"Icon({icon_expr}, {', '.join(args)})"
        return f"Icon({icon_expr})"

    content = re.sub(r'Text\(([^,]+?\.icon)(?:\s*,\s*style:\s*(?:const\s+)?TextStyle\(([^)]*)\))?\s*\)', replacer, content)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed {filepath}")

def main():
    lib_dir = 'lib'
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                fix_file(os.path.join(root, file))

if __name__ == '__main__':
    main()
