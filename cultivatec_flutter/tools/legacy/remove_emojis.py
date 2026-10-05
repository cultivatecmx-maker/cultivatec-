import os
import re

EMOJI_TO_ICON = {
    '🚀': 'Icons.rocket_launch',
    '⚡': 'Icons.bolt',
    '🎮': 'Icons.videogame_asset',
    '🔧': 'Icons.build',
    '🏆': 'Icons.emoji_events',
    '🏭': 'Icons.factory',
    '📡': 'Icons.cell_tower',
    '🧠': 'Icons.psychology',
    '🌿': 'Icons.eco',
    '🐾': 'Icons.pets',
    '💪': 'Icons.fitness_center',
    '🐙': 'Icons.bug_report',
    '🛸': 'Icons.flight',
    '🏗️': 'Icons.construction',
    '🏜️': 'Icons.landscape',
    '🧭': 'Icons.explore',
    '👁️': 'Icons.visibility',
    '🛡️': 'Icons.security',
    '🌱': 'Icons.grass',
    '🚁': 'Icons.toys',
    '💧': 'Icons.water_drop',
    '🏙️': 'Icons.location_city',
    '🤖': 'Icons.smart_toy',
    '🌟': 'Icons.star',
    '👾': 'Icons.smart_toy',
    '⭐': 'Icons.star_border',
    '🎯': 'Icons.track_changes',
    '👑': 'Icons.workspace_premium',
    '🔥': 'Icons.local_fire_department',
    '🎓': 'Icons.school',
    '🔬': 'Icons.science',
    '🎨': 'Icons.palette',
    '🟢': 'Icons.circle',
    '🔵': 'Icons.circle',
    '🔴': 'Icons.circle',
    '🟡': 'Icons.circle',
    '🟠': 'Icons.circle',
    '🟣': 'Icons.circle',
    '🥇': 'Icons.looks_one',
    '🥈': 'Icons.looks_two',
    '🥉': 'Icons.looks_3',
    '✅': 'Icons.check_circle',
    '❌': 'Icons.cancel',
    '🎉': 'Icons.celebration',
    '👋': 'Icons.waving_hand',
    '⚙️': 'Icons.settings',
    '👤': 'Icons.person',
}

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # Replace `emoji: '🚀'` with `icon: Icons.rocket_launch`
    # We need to find `emoji: '...'` or `emoji: "..."`
    def replacer(match):
        field = match.group(1) # e.g. "emoji"
        emoji = match.group(2)
        if emoji in EMOJI_TO_ICON:
            return f"icon: {EMOJI_TO_ICON[emoji]}"
        # fallback
        return f"icon: Icons.star"

    content = re.sub(r'(emoji):\s*[\'"]([^\'"]+)[\'"]', replacer, content)

    # Also replace `final String emoji;` with `final IconData icon;`
    content = content.replace('final String emoji;', 'final IconData icon;')
    # Replace `this.emoji` with `this.icon`
    content = content.replace('this.emoji', 'this.icon')

    # Remove bgPattern completely or just clear its emojis
    content = re.sub(r'bgPattern:\s*[\'"][^\'"]*[\'"]', "bgPattern: ''", content)

    # In UI, Text(emoji) -> Icon(icon)
    # This is tricky, but let's look for Text('🚀') and replace with Icon(Icons.rocket_launch)
    for emoji, icon in EMOJI_TO_ICON.items():
        content = content.replace(f"Text('{emoji}'", f"Icon({icon}")
        content = content.replace(f'Text("{emoji}"', f"Icon({icon}")

    if content != original:
        # Check if we need to import material.dart if it's a data file
        if 'Icons.' in content and 'import \'package:flutter/material.dart\';' not in content:
            content = "import 'package:flutter/material.dart';\n" + content

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

def main():
    lib_dir = 'lib'
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))

if __name__ == '__main__':
    main()
