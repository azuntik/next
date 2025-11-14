#!/usr/bin/env python3
"""
iOS Shortcuts Generator for Intentional Friction

This script generates iOS shortcut files (.shortcut) that can be imported
into the iOS Shortcuts app. These shortcuts trigger friction moments for
various social media apps.

Usage:
    python3 generate_shortcuts.py

This will create .shortcut files in the output/ directory that you can:
1. AirDrop to your iOS device
2. Share via iCloud (requires iOS Shortcuts app)
3. Import directly by opening on iOS

Requirements:
    - Python 3.6+
    - No additional packages needed (uses stdlib)
"""

import plistlib
import uuid
from pathlib import Path
from typing import Dict, List

# App configurations
APPS = {
    'Instagram': {
        'name': 'Check Instagram',
        'color': 13421823,  # Pink/purple gradient
        'icon': {
            'StartColor': 13421823,
            'EndColor': 15895611,
            'GlyphNumber': 59511,
        }
    },
    'Facebook': {
        'name': 'Check Facebook',
        'color': 4282549119,  # Blue
        'icon': {
            'StartColor': 4282549119,
            'EndColor': 4282549119,
            'GlyphNumber': 59511,
        }
    },
    'Twitter': {
        'name': 'Check Twitter',
        'color': 255,  # Black
        'icon': {
            'StartColor': 255,
            'EndColor': 255,
            'GlyphNumber': 61594,
        }
    },
    'TikTok': {
        'name': 'Check TikTok',
        'color': 255,  # Black
        'icon': {
            'StartColor': 255,
            'EndColor': 4278190335,
            'GlyphNumber': 59511,
        }
    },
    'Reddit': {
        'name': 'Check Reddit',
        'color': 4294934528,  # Orange
        'icon': {
            'StartColor': 4294934528,
            'EndColor': 4294934528,
            'GlyphNumber': 59511,
        }
    },
    'YouTube': {
        'name': 'Check YouTube',
        'color': 4294901760,  # Red
        'icon': {
            'StartColor': 4294901760,
            'EndColor': 4294901760,
            'GlyphNumber': 61762,
        }
    },
    'Snapchat': {
        'name': 'Check Snapchat',
        'color': 4294967040,  # Yellow
        'icon': {
            'StartColor': 4294967040,
            'EndColor': 4294967040,
            'GlyphNumber': 59511,
        }
    },
    'LinkedIn': {
        'name': 'Check LinkedIn',
        'color': 4280193279,  # Blue
        'icon': {
            'StartColor': 4280193279,
            'EndColor': 4280193279,
            'GlyphNumber': 59689,
        }
    },
}

def generate_shortcut_data(app_name: str, shortcut_name: str, color: int, icon: Dict) -> Dict:
    """
    Generate the shortcut data structure for a given app.

    Args:
        app_name: The app name (e.g., 'Instagram')
        shortcut_name: Display name for the shortcut
        color: Integer color value
        icon: Icon configuration dictionary

    Returns:
        Dictionary representing the shortcut plist structure
    """

    # Generate UUIDs for the shortcut
    action_uuid = str(uuid.uuid4()).upper()
    shortcut_uuid = str(uuid.uuid4()).upper()

    # Construct the URL
    url = f"intentionalfriction://trigger?app={app_name}"

    # Build the shortcut structure
    shortcut = {
        'WFWorkflowActions': [
            {
                'WFWorkflowActionIdentifier': 'is.workflow.actions.openurl',
                'WFWorkflowActionParameters': {
                    'WFInput': {
                        'Value': {
                            'Type': 'ExtensionInput',
                            'OutputName': 'URL',
                            'OutputUUID': action_uuid,
                        },
                        'WFSerializationType': 'WFTextTokenAttachment'
                    },
                    'WFURLActionURL': url,
                },
            }
        ],
        'WFWorkflowClientVersion': '2605.0.5',
        'WFWorkflowClientRelease': '18.1',
        'WFWorkflowMinimumClientVersion': 900,
        'WFWorkflowMinimumClientRelease': '13.0',
        'WFWorkflowIcon': {
            'WFWorkflowIconStartColor': icon['StartColor'],
            'WFWorkflowIconGlyphNumber': icon['GlyphNumber'],
        },
        'WFWorkflowTypes': ['NCWidget', 'WatchKit'],
        'WFWorkflowInputContentItemClasses': [
            'WFAppStoreAppContentItem',
            'WFArticleContentItem',
            'WFContactContentItem',
            'WFDateContentItem',
            'WFEmailAddressContentItem',
            'WFGenericFileContentItem',
            'WFImageContentItem',
            'WFiTunesProductContentItem',
            'WFLocationContentItem',
            'WFDCMapsLinkContentItem',
            'WFAVAssetContentItem',
            'WFPDFContentItem',
            'WFPhoneNumberContentItem',
            'WFRichTextContentItem',
            'WFSafariWebPageContentItem',
            'WFStringContentItem',
            'WFURLContentItem',
        ],
    }

    return shortcut


def generate_shortcut_file(app_name: str, config: Dict, output_dir: Path):
    """
    Generate a .shortcut file for the given app.

    Args:
        app_name: The app name (e.g., 'Instagram')
        config: App configuration dictionary
        output_dir: Directory to save the shortcut file
    """

    shortcut_data = generate_shortcut_data(
        app_name=app_name,
        shortcut_name=config['name'],
        color=config['color'],
        icon=config['icon']
    )

    # Create filename
    filename = f"{config['name'].replace(' ', '_')}.shortcut"
    filepath = output_dir / filename

    # Write the plist file
    with open(filepath, 'wb') as f:
        plistlib.dump(shortcut_data, f, fmt=plistlib.FMT_BINARY)

    print(f"✅ Generated: {filename}")
    return filepath


def generate_readme(output_dir: Path, generated_files: List[Path]):
    """Generate a README with instructions for using the shortcuts."""

    readme_content = """# Intentional Friction - iOS Shortcuts

This directory contains pre-generated iOS shortcuts for the Intentional Friction app.

## What Are These Files?

Each `.shortcut` file is a ready-to-use iOS shortcut that will trigger a friction
moment before you open a specific social media app.

## How to Import

### Method 1: AirDrop (Easiest)
1. AirDrop any `.shortcut` file to your iPhone/iPad
2. Tap the file when it arrives
3. iOS will open the Shortcuts app
4. Tap "Add Shortcut"
5. Done! The shortcut is now in your Shortcuts app

### Method 2: iCloud Drive
1. Upload `.shortcut` files to iCloud Drive
2. Open Files app on iOS
3. Navigate to the shortcut file
4. Tap to open
5. Tap "Add Shortcut"

### Method 3: Email/Messages
1. Email or message yourself the `.shortcut` file
2. Open on iOS device
3. Tap the attachment
4. Tap "Add Shortcut"

## After Importing

Once you've imported a shortcut, you need to create an automation:

1. Open **Shortcuts app**
2. Go to **Automation** tab
3. Tap **+** (top right)
4. Select **Create Personal Automation**
5. Choose **App**
6. Select the social media app (e.g., Instagram)
7. Choose **Is Opened**
8. Tap **Next**
9. Tap **Add Action**
10. Search for your imported shortcut (e.g., "Check Instagram")
11. Select it
12. **CRITICAL**: Turn OFF "Ask Before Running"
13. Tap **Done**

Now friction will appear automatically when you open that app!

## Available Shortcuts

"""

    for filepath in sorted(generated_files):
        app_name = filepath.stem.replace('_', ' ')
        readme_content += f"- **{app_name}**: `{filepath.name}`\n"

    readme_content += """
## Siri Voice Commands

After importing, you can also trigger friction by saying:
- "Hey Siri, Check Instagram"
- "Hey Siri, Check Facebook"
- etc.

## Troubleshooting

**Shortcut won't import**
- Make sure you're opening the file on an iOS device (not Mac)
- Ensure iOS 13 or later
- Try a different transfer method

**Automation not working**
- Double-check "Ask Before Running" is OFF
- Make sure the app name matches exactly
- Try deleting and recreating the automation

**Friction doesn't appear**
- Make sure Intentional Friction app is installed
- Open the app at least once before using shortcuts
- Check that the URL scheme is registered

## Creating iCloud Share Links

If you want to share these shortcuts via links:

1. Import a shortcut to your iOS device
2. Open Shortcuts app
3. Long-press the shortcut
4. Tap "Share"
5. Enable "Share as iCloud Link"
6. Copy the link
7. Update the app's `shortcuts_setup_screen.dart` with the link

## Need Help?

See the main app documentation or visit Settings > iOS Shortcuts Setup
in the Intentional Friction app for a step-by-step guide.

---

**Generated by**: iOS Shortcuts Generator for Intentional Friction
**Date**: Auto-generated
"""

    readme_path = output_dir / 'README.md'
    with open(readme_path, 'w') as f:
        f.write(readme_content)

    print(f"\n📄 Generated: README.md")


def main():
    """Main function to generate all shortcuts."""

    print("🚀 Intentional Friction - iOS Shortcuts Generator\n")
    print("=" * 60)

    # Create output directory
    output_dir = Path('output/ios_shortcuts')
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"📁 Output directory: {output_dir}\n")

    # Generate shortcuts for all apps
    generated_files = []
    for app_name, config in APPS.items():
        filepath = generate_shortcut_file(app_name, config, output_dir)
        generated_files.append(filepath)

    # Generate README
    generate_readme(output_dir, generated_files)

    print("\n" + "=" * 60)
    print(f"✨ Success! Generated {len(generated_files)} shortcuts")
    print(f"\n📦 Files are in: {output_dir}")
    print("\n📖 Next Steps:")
    print("   1. Transfer .shortcut files to your iOS device")
    print("   2. Open each file to import into Shortcuts app")
    print("   3. Create automations for each app (see README.md)")
    print("   4. (Optional) Share via iCloud to get shareable links")
    print("\n" + "=" * 60)


if __name__ == '__main__':
    main()
