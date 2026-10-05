import os
import re

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # 1. Replace `.emoji` with `.icon` where appropriate:
    # e.g., world.emoji -> world.icon, levelInfo.emoji -> levelInfo.icon, universe.emoji -> universe.icon
    content = re.sub(r'\.emoji\b', '.icon', content)

    # 2. Fix Icon(..., style: TextStyle(fontSize: X, color: Y))
    # It might be multiline. It's safer to use a regex to extract fontSize and color from TextStyle
    # Icon(..., style: const TextStyle(fontSize: 48)) -> Icon(..., size: 48)
    # This regex is a bit complex. Let's do a simple substitution for common cases.
    
    def replacer(match):
        icon_expr = match.group(1) # anything before style
        style_expr = match.group(2) # inside style: TextStyle(...)
        
        size = ""
        color = ""
        
        # find fontSize
        size_match = re.search(r'fontSize:\s*([\d\.]+)', style_expr)
        if size_match:
            size = f"size: {size_match.group(1)}"
            
        color_match = re.search(r'color:\s*([^,}]+)', style_expr)
        if color_match:
            color = f"color: {color_match.group(1)}"
            
        args = [a for a in [size, color] if a]
        if args:
            return f"Icon({icon_expr}, {', '.join(args)}"
        return f"Icon({icon_expr}"

    content = re.sub(r'Icon\(([^,]+),\s*style:\s*(?:const\s+)?TextStyle\(([^)]*)\)', replacer, content)

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
