import os
import re

EMOJI_TO_ICON = {
    '👣': 'Icons.directions_walk',
    '⚡': 'Icons.bolt',
    '📚': 'Icons.menu_book',
    '🎓': 'Icons.school',
    '❓': 'Icons.help_outline',
    '💯': 'Icons.verified',
    '🔥': 'Icons.local_fire_department',
    '💻': 'Icons.laptop',
    '🤖': 'Icons.smart_toy',
    '🐛': 'Icons.bug_report',
    '👨‍💻': 'Icons.developer_mode',
    '🧩': 'Icons.extension',
    '🏆': 'Icons.emoji_events',
    '🐍': 'Icons.pest_control',
    '🔷': 'Icons.diamond',
    '🌱': 'Icons.grass',
    '🎖️': 'Icons.military_tech',
    '💡': 'Icons.lightbulb',
    '🏫': 'Icons.school',
    '🗺️': 'Icons.map',
    '💎': 'Icons.diamond',
}

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    def replacer(match):
        emoji = match.group(1)
        if emoji in EMOJI_TO_ICON:
            return f"icon: {EMOJI_TO_ICON[emoji]}"
        return f"icon: Icons.star"

    content = re.sub(r'icon:\s*[\'"]([^\'"]+)[\'"]', replacer, content)

    # Change final String icon; to final IconData icon; in Achievement class
    # Since we already changed emoji to icon in other places, we must be careful not to break anything.
    # We can just change final String icon; to final IconData icon; in module_models.dart
    
    content = content.replace("final String icon;", "final IconData icon;")

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed {filepath}")

def main():
    fix_file('lib/models/module_models.dart')

if __name__ == '__main__':
    main()
