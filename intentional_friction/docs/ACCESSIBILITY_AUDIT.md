# Accessibility Audit Checklist

This document provides a comprehensive accessibility audit checklist for Intentional Friction.

## WCAG 2.1 Level AA Compliance

### Perceivable

#### Text Alternatives (1.1)
- [ ] All images have appropriate alt text
- [ ] Decorative images excluded from accessibility tree
- [ ] Icons have semantic labels
- [ ] Charts have text descriptions

#### Time-Based Media (1.2)
- [ ] No time-based media currently (N/A)
- [ ] If added: Provide captions and transcripts

#### Adaptable (1.3)
- [ ] Semantic structure preserved in code
- [ ] Reading order is logical
- [ ] Instructions don't rely solely on sensory characteristics
- [ ] Content adapts to different orientations
- [ ] Input purpose identified

#### Distinguishable (1.4)
- [ ] Color not sole means of conveying information
- [ ] Audio control (if applicable)
- [ ] Contrast ratio: 4.5:1 for normal text
- [ ] Contrast ratio: 3:1 for large text
- [ ] Text can be resized up to 200%
- [ ] Images of text avoided (except logos)
- [ ] Reflow works at 400% zoom
- [ ] No loss of content when zoomed
- [ ] Text spacing adjustable
- [ ] Content on hover/focus is dismissible
- [ ] Content on hover/focus is hoverable
- [ ] Content on hover/focus persists

### Operable

#### Keyboard Accessible (2.1)
- [ ] All functionality available via keyboard
- [ ] No keyboard traps
- [ ] Keyboard shortcuts documented
- [ ] Focus visible at all times
- [ ] Focus order is logical

#### Enough Time (2.2)
- [ ] Time limits can be extended
- [ ] Auto-updating content can be paused
- [ ] Countdown timer in friction screen has clear purpose
- [ ] No time limits that can't be disabled

#### Seizures and Physical Reactions (2.3)
- [ ] No content flashes more than 3 times per second
- [ ] Animation can be disabled via system settings
- [ ] Breathing animation respects reduced motion preference

#### Navigable (2.4)
- [ ] Skip navigation links (if long lists)
- [ ] Page titles descriptive
- [ ] Focus order makes sense
- [ ] Link purpose clear from context
- [ ] Multiple ways to navigate
- [ ] Headings and labels descriptive
- [ ] Focus visible
- [ ] Current location indicated

#### Input Modalities (2.5)
- [ ] Touch targets at least 44x44 points
- [ ] Pointer gestures have keyboard alternatives
- [ ] Accidental activation prevented
- [ ] Labels match accessible names
- [ ] Target size adequate

### Understandable

#### Readable (3.1)
- [ ] Language of page identified
- [ ] Language of parts identified (if mixed)
- [ ] Unusual words defined
- [ ] Abbreviations expanded on first use
- [ ] Reading level appropriate

#### Predictable (3.2)
- [ ] Focus doesn't trigger unexpected changes
- [ ] Input doesn't trigger unexpected changes
- [ ] Navigation consistent across screens
- [ ] Identification consistent
- [ ] Changes requested by user

#### Input Assistance (3.3)
- [ ] Error messages clear and helpful
- [ ] Labels or instructions provided
- [ ] Error suggestions provided
- [ ] Error prevention for critical actions
- [ ] Confirmation for data submission
- [ ] Context-sensitive help available

### Robust

#### Compatible (4.1)
- [ ] HTML/markup valid (Flutter handles this)
- [ ] Name, role, value available for all components
- [ ] Status messages announced to screen readers
- [ ] Works with assistive technologies

## Platform-Specific Testing

### iOS Accessibility

#### VoiceOver
- [ ] All elements have labels
- [ ] Labels are descriptive
- [ ] Custom actions work
- [ ] Hints are appropriate
- [ ] Traits are correct (button, header, etc.)
- [ ] Reading order is logical
- [ ] Grouped content is properly merged
- [ ] Dismissible elements announce correctly

#### Voice Control
- [ ] All interactive elements can be activated by voice
- [ ] Labels match voice commands
- [ ] Numbered controls work

#### Dynamic Type
- [ ] Text scales from -3 to +7
- [ ] Layout doesn't break at any size
- [ ] Buttons remain tappable
- [ ] Critical content visible

#### Reduce Motion
- [ ] Animations simplified or removed
- [ ] Breathing animation respects preference
- [ ] Transitions still functional
- [ ] No jarring effects

#### Reduce Transparency
- [ ] Overlays remain usable
- [ ] Content still distinguishable

#### Increase Contrast
- [ ] UI remains clear
- [ ] Colors adjust appropriately

#### Differentiate Without Color
- [ ] Shapes/icons used alongside color
- [ ] Patterns used for differentiation

### Android Accessibility

#### TalkBack
- [ ] All elements have content descriptions
- [ ] Descriptions are meaningful
- [ ] Custom actions work
- [ ] Hints are helpful
- [ ] Reading order is logical
- [ ] Grouped content properly announced
- [ ] Touch exploration works

#### Switch Access
- [ ] All interactive elements reachable
- [ ] Scanning works correctly
- [ ] Actions can be performed

#### Font Size
- [ ] Text scales correctly
- [ ] Layout adapts
- [ ] No clipping occurs

#### Display Size
- [ ] UI scales appropriately
- [ ] Touch targets remain adequate
- [ ] Content remains accessible

#### Remove Animations
- [ ] Animations disabled correctly
- [ ] Functionality preserved

#### High Contrast Text
- [ ] Text remains readable
- [ ] Adjusts properly

## Screen-by-Screen Audit

### Onboarding Screen
- [ ] All pages have proper semantics
- [ ] Page indicator accessible
- [ ] "Next" button clearly labeled
- [ ] "Get Started" button clearly labeled
- [ ] Content order logical
- [ ] Skip option available and accessible

### Home Screen
- [ ] Statistics have semantic labels
- [ ] "Start/Stop Monitoring" buttons labeled
- [ ] "Pause & Reflect" button (iOS) labeled
- [ ] Status card information accessible
- [ ] Bottom navigation labeled
- [ ] Empty state has helpful message

### Friction Screen
- [ ] Prompt announced clearly
- [ ] Countdown status announced
- [ ] Button states (disabled/enabled) announced
- [ ] Emotion chips labeled
- [ ] Breathing animation described for screen readers
- [ ] Alternative text for visual cues
- [ ] Back button behavior clear

### Insights Screen
- [ ] Chart data available to screen readers
- [ ] Trend descriptions clear
- [ ] Insight cards have full information
- [ ] Empty state helpful
- [ ] Pull-to-refresh accessible

### Settings Screen
- [ ] All sections have headers
- [ ] Toggle states announced
- [ ] List items labeled
- [ ] Dialogs accessible
- [ ] Feedback options clear
- [ ] Navigation obvious

### Shortcuts Setup (iOS)
- [ ] Step navigation clear
- [ ] Instructions readable
- [ ] Code snippets have alternatives
- [ ] Progress indicator accessible
- [ ] Navigation buttons labeled

## Color & Contrast Audit

### Primary Colors
- [ ] Primary color (#6B4FA0) on white: Passes
- [ ] White on primary color: Passes
- [ ] Text colors on backgrounds: All pass

### Interactive Elements
- [ ] Button text: Passes
- [ ] Link text: Passes
- [ ] Icons: Passes
- [ ] Disabled states: Clear but distinguishable

### Charts & Visualizations
- [ ] Chart colors have good contrast
- [ ] Patterns/textures used in addition to color
- [ ] Legend readable

### Status Indicators
- [ ] Success: Not color-only
- [ ] Error: Not color-only
- [ ] Warning: Not color-only
- [ ] Info: Not color-only

## Touch Target Audit

### Minimum Sizes
- [ ] All buttons ≥ 44x44 points
- [ ] List items ≥ 44 points tall
- [ ] Icons ≥ 24x24 points (with padding)
- [ ] Switches/toggles ≥ 44 points
- [ ] Chips ≥ 32 points

### Spacing
- [ ] Adequate space between targets
- [ ] No accidental activations
- [ ] Thumb-friendly placement

## Motion & Animation Audit

### Reduce Motion Support
- [ ] System preference detected
- [ ] Animations disabled appropriately
- [ ] Transitions simplified
- [ ] Essential motion preserved
- [ ] No loss of functionality

### Animation Purposes
- [ ] Breathing animation: Optional, can be static
- [ ] Page transitions: Can be instant
- [ ] Loading indicators: Can be simplified
- [ ] Charts: Can skip animation

## Content Audit

### Language
- [ ] Plain language used
- [ ] Jargon explained
- [ ] Instructions clear
- [ ] Error messages helpful

### Structure
- [ ] Logical heading hierarchy
- [ ] Lists properly formatted
- [ ] Related content grouped
- [ ] Navigation consistent

### Readability
- [ ] Sentences concise
- [ ] Paragraphs short
- [ ] Line length appropriate
- [ ] Font size adequate

## Testing with Real Users

### Recommended Test Groups
- [ ] Blind users (screen reader)
- [ ] Low vision users (magnification)
- [ ] Motor impairment users (switch/voice)
- [ ] Cognitive disability users
- [ ] Deaf users (if audio added)
- [ ] Elderly users
- [ ] Users with multiple disabilities

### Test Scenarios
1. **Complete onboarding** (all users)
2. **Trigger and respond to friction** (all users)
3. **Review insights** (all users)
4. **Export data** (all users)
5. **Adjust settings** (all users)
6. **Set up iOS Shortcuts** (iOS only)

### Feedback to Collect
- [ ] Ease of navigation
- [ ] Clarity of information
- [ ] Barriers encountered
- [ ] Suggestions for improvement
- [ ] Overall satisfaction

## Tools for Accessibility Testing

### Automated Tools
- **Flutter DevTools**: Accessibility inspector
- **Xcode Accessibility Inspector**: iOS testing
- **Android Accessibility Scanner**: Android testing
- **aXe DevTools**: Web-based audit (if applicable)

### Manual Testing
- **VoiceOver** (iOS): Settings > Accessibility
- **TalkBack** (Android): Settings > Accessibility
- **Color Contrast Analyzer**: Desktop tool
- **Voice Control** (iOS): Hands-free testing
- **Switch Access** (Android): Alternative input

### Testing Commands

```bash
# Enable accessibility in Flutter DevTools
flutter run --dart-define=SHOW_ACCESSIBILITY_DEBUG=true

# Generate accessibility report (if tool available)
flutter analyze --accessibility

# Run with screen reader simulation
flutter test --platform=chrome --dart-define=A11Y_TEST=true
```

## Remediation Priority

### Priority 1 (Critical - Fix Immediately)
- Screen reader can't access core functionality
- Contrast fails by large margin
- Keyboard traps
- Time-outs without warning
- Seizure-inducing content

### Priority 2 (High - Fix Soon)
- Missing labels on important elements
- Poor contrast on secondary elements
- Confusing navigation
- Inadequate touch targets
- Missing error messages

### Priority 3 (Medium - Plan to Fix)
- Suboptimal labels
- Minor contrast issues
- Inconsistent behavior
- Missing hints
- Could be more efficient

### Priority 4 (Low - Nice to Have)
- Enhanced descriptions
- Additional keyboard shortcuts
- Optimization improvements
- Polish and refinement

## Compliance Documentation

### Required Documentation
- [ ] VPAT (Voluntary Product Accessibility Template)
- [ ] Accessibility statement
- [ ] Known issues list
- [ ] Roadmap for improvements
- [ ] Contact for accessibility feedback

### Accessibility Statement Template

```markdown
# Accessibility Statement for Intentional Friction

We are committed to ensuring digital accessibility for people with disabilities.
We are continually improving the user experience for everyone and applying the
relevant accessibility standards.

## Conformance Status
Intentional Friction aims to conform with WCAG 2.1 Level AA.

## Measures to Support Accessibility
- Include accessibility in our internal policies
- Integrate accessibility into our development process
- Test with assistive technologies
- Collect feedback from users with disabilities

## Known Limitations
[List any known issues]

## Feedback
We welcome your feedback on the accessibility of Intentional Friction.
Please contact us at: accessibility@intentionalfriction.app

## Assessment Date
Last assessed: [Date]

## Technical Specifications
- Flutter framework
- iOS 13+ / Android 5.0+
- Works with screen readers, switch access, voice control
```

## Continuous Accessibility

### Every Release
- [ ] Run automated accessibility checks
- [ ] Manual screen reader test
- [ ] Contrast audit of new colors
- [ ] Touch target verification
- [ ] Dynamic type test
- [ ] Reduce motion test

### Quarterly
- [ ] Full WCAG audit
- [ ] User testing with people with disabilities
- [ ] Tool updates
- [ ] Training refresh
- [ ] Documentation update

### Annually
- [ ] External accessibility audit
- [ ] VPAT update
- [ ] Compliance review
- [ ] Best practices review
- [ ] Assistive technology testing with latest versions

---

**Remember**: Accessibility is not a feature, it's a fundamental requirement.
Build it in from the start, not bolt it on at the end.

**Goal**: Make Intentional Friction usable by everyone, regardless of ability.
