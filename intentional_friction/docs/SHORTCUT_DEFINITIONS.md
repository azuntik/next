# Pre-Made iOS Shortcuts for Intentional Friction

This document contains pre-made shortcut definitions for common social media apps. Users can import these with one tap instead of manually creating them.

## How to Create Shareable Links

1. Open the Shortcuts app on iOS
2. Create a new shortcut using the configuration below
3. Tap the share button (···) > Share Shortcut
4. Enable "Share as iCloud Link"
5. Copy the link
6. Add the link to the app's setup guide

## Shortcut Definitions

### Instagram - "Check Instagram"

**Actions:**
1. Open URL: `intentionalfriction://trigger?app=Instagram`

**Shortcut Name:** Check Instagram
**Icon:** Instagram logo (pink/purple gradient)
**Color:** Pink

**iCloud Link:** [To be generated]

---

### Facebook - "Check Facebook"

**Actions:**
1. Open URL: `intentionalfriction://trigger?app=Facebook`

**Shortcut Name:** Check Facebook
**Icon:** Facebook logo (blue)
**Color:** Blue

**iCloud Link:** [To be generated]

---

### Twitter/X - "Check Twitter"

**Actions:**
1. Open URL: `intentionalfriction://trigger?app=Twitter`

**Shortcut Name:** Check Twitter
**Icon:** Twitter/X logo
**Color:** Black

**iCloud Link:** [To be generated]

---

### TikTok - "Check TikTok"

**Actions:**
1. Open URL: `intentionalfriction://trigger?app=TikTok`

**Shortcut Name:** Check TikTok
**Icon:** TikTok logo
**Color:** Black

**iCloud Link:** [To be generated]

---

### Reddit - "Check Reddit"

**Actions:**
1. Open URL: `intentionalfriction://trigger?app=Reddit`

**Shortcut Name:** Check Reddit
**Icon:** Reddit logo
**Color:** Orange

**iCloud Link:** [To be generated]

---

### YouTube - "Check YouTube"

**Actions:**
1. Open URL: `intentionalfriction://trigger?app=YouTube`

**Shortcut Name:** Check YouTube
**Icon:** YouTube logo
**Color:** Red

**iCloud Link:** [To be generated]

---

### Snapchat - "Check Snapchat"

**Actions:**
1. Open URL: `intentionalfriction://trigger?app=Snapchat`

**Shortcut Name:** Check Snapchat
**Icon:** Snapchat logo
**Color:** Yellow

**iCloud Link:** [To be generated]

---

### LinkedIn - "Check LinkedIn"

**Actions:**
1. Open URL: `intentionalfriction://trigger?app=LinkedIn`

**Shortcut Name:** Check LinkedIn
**Icon:** LinkedIn logo
**Color:** Blue

**iCloud Link:** [To be generated]

---

## How Users Import Shortcuts

### Method 1: iCloud Link (Recommended)
1. Tap the iCloud link for desired app
2. Tap "Add Shortcut" in Shortcuts app
3. Done! Shortcut is ready to use

### Method 2: QR Code
1. Scan QR code with camera
2. Tap "Add Shortcut"
3. Done!

### Method 3: Manual Creation
Follow the detailed guide in the app.

## After Importing

Users still need to create the automation trigger (this cannot be shared):

1. Open Shortcuts app > Automation tab
2. Create Personal Automation
3. Choose "App" trigger
4. Select the target app (Instagram, Facebook, etc.)
5. Choose "Is Opened"
6. Add action: Run the imported shortcut
7. **CRITICAL:** Turn OFF "Ask Before Running"
8. Done!

This reduces the setup from 8 steps to 4 steps!

## Generating Links (For Maintainers)

To generate the iCloud links for inclusion in the app:

1. **On an iOS device with the app installed:**
   - Open Shortcuts app
   - Create each shortcut manually using URLs above
   - For each shortcut:
     - Tap (···) > Share Shortcut
     - Enable "Allow Sharing"
     - Copy iCloud Link
     - Add to SHORTCUT_LINKS.md

2. **Add links to app:**
   - Update `shortcuts_setup_screen.dart` with the links
   - Create "Quick Import" option
   - Keep manual option as fallback

3. **Maintain links:**
   - Links don't expire but may need updating if shortcut changes
   - Test periodically to ensure they work
   - Provide fallback to manual creation

## Future Enhancement: App Intents Gallery

With iOS 17+, we could potentially use App Intents to provide shortcuts directly through the app without iCloud links. This would allow:
- In-app shortcut configuration
- No manual Shortcuts app interaction
- Automatic setup with one tap

For now, iCloud links provide the best balance of simplicity and compatibility.
