# Design System: Vyaas AI

> Single source of truth for Flutter UI/UX.
> **Subject:** Local-first AI workspace
> **Materials:** Flutter, Riverpod, Drift, Platform SDKs
> **Artifacts:** Glassmorphism cards, animated typing indicators, radial token gauges
> **Audience:** Job seekers, students, professionals
> **Single job:** Secure AI-assisted resume tailoring, document drafting, and chat without cloud dependency

---

## 1. Product Identity

**Name:** Vyaas AI

**Tagline:** Secure, Local-First AI Workspace

**Personality:**
- *Professional* (not playful, cryptic, or consumer)
- *Trustworthy* (transparent about local-first;
- *Technical* (engineers & power users)
- *Minimal* (dark, high-contrast, low clutter)
- *Precise* (metrics, gauges, labels)

---

## 2. Design Plan

### Color
```yaml
# Named hex values
Background:
  Obsidian: #090B11
Surface:
  SlateCard: #131824
Accent:
  Indigo: #2563EB
  Magenta: #F43F5E
Semantic:
  Success: #10B981
  Warning: #F59E0B
  Error: #EF4444
Text:
  Primary: #F3F4F6
  Secondary: #9CA3AF
Border:
  Transparent: rgba(255,255,255,0.08)
```

### Type
```yaml
Display:
  Outfit: 600/700 (headings, branding, ATS score)
Body:
  Inter: 400/500/600 (labels, inputs, metadata)

Scale:
  H1: 20
  H2: 16
  H3: 14
  Body: 13
  Small: 11
  Caption: 10
```

### Layout
ASCII wireframes for template layouts:

**Dashboard**
```
+-------------------------------------+
| Secure Workspace       LOCAL-FIRST |
+-------------------------------------+
| [ Start Chat ]   [ Optimize Resume ]|
| [ Book Template ]   [ Scheduler ]   |
+-------------------------------------+
| Token Usage                         |
+-----+-------------------------------+
| Chat | [Title] [Date]                |
+-----+-------------------------------+
| Resu | [Name] [Title]                |
+-----+-------------------------------+
```

**Chat Screen**
```
+-------------------------------+
| Chat        [Deep Think] ☐   |
+-------------------------------+
| Gemini 2.5 Pro        4/15 RPM|
| { … } { … }                   |
+-------------------------------+
| [User message]              |
|          [AI response]        |
+-------------------------------+
| [Prompt field]     [Send ▶] |
```

**Resume Hub – Optimizer Tab**
```
+-------------------------------+
| Job Description               |
| [Paste JD…]                   |
|                               |
| [ Analyze & Optimize ]        |
+-------------------------------+
| 🕒 ATS Score                  |
| 85                            |
+-------+-----------------------+
| Dart  | Flutter                |
| River | ReadableStream         |
+-------+-----------------------+
| [ Suggestions… ]              |
```

### Signature Element
**Large ATS Score Radial Gauge**: Indigo gradient sweep with magenta overflow marker for scores >85. This gauge is both informative and distinctive — visually memorable while supporting the product narrative (optimizing job applications).

---

## 3. Token System

**Spacing** (MD = 16px)
```dart
const double spacingXS = 4;
const double spacingSM = spacingXS * 2; // 8
const double spacingMD = spacingXS * 4; // 16
const double spacingLG = spacingXS * 6; // 24
const double spacingXL = spacingXS * 8; // 32
```

**Border Radius**
```dart
const double radiusSM = 8;
const double radiusMD = 12;
const double radiusLG = 16;
const double radiusFull = 24;
```

`radiusLG` (16px) used for all GlassCards.

---

## 4. Navigation Shell

### Desktop
Width: `250`

```text
VYAAS AI

▼ Dashboard
• Chat
▷ Resume Hub
▷ Templates
▷ Scheduler

──────────────
<🔒> Gemini NIM
└ 4/15 RPM
```

- Fixed sidebar, 250px
- Active nav item: **indigo background 12% opacity** + hairline indigo border (1px)
- Provider card flips to magenta when near rate limits

### Mobile
```text
Dashboard
Chat
Resume
Templates
⚙️
```

Max 5 items. BottomNavigationBar (Flutter widget).

---

## 5. Components

### GlassCard
```yaml
Background:
  SlateCard #131824 @ 60% opacity
Border:
  1px Transparent white @ 8% opacity
Radius:
  16
Elevation:
  None
```

- Reused for **cards**, **dialogs**, **drawers**, **inputs**

### Button
```yaml
Primary:
  Radius: 8
  Background: Indigo
  Foreground: TextPrimary
  Hover: 8% darken
  Active: -1px translate

Secondary:
  Background: SlateCard
  Foreground: Indigo
  Border: None
```

### Input
```yaml
Background:
  SlateCard 100% opacity with 2% white alpha
Radius:
  12
Hint:
  TextSecondary
Label:
  Always above, never floating
Border:
  1px Transparent
Focus:
  1.5px Indigo offset
```

---

## 6. Layout Rules

- **Breakpoint**: 768 (mobile <768, desktop ≥768)
- **Spacing rhythm**: base MD (16px), all gaps multiples thereof
- **Dashboard grid**: adaptive 1 or 2 columns based on `LayoutBuilder`
- **Template Hub**: left rail (categories) + template grid (2 cols) + form view
- **z-index**:
  ```dart
  const ZIndex= {stickyNav: 400, drawer: 500, sheet: 600, dialog: 700, snackbar: 800}
  ```

---

## 7. Screens

### Splash
Logo: scale from 0.9 to 1.05 (easeOutBack), 1.5s
Title: fade-in after 600ms delay, navigate after 2.5s

### Dashboard
- **API Key Alert** (amber): only shown if missing provider
- **Token Gauge**: linear progress + fill text + scheduler load
- **Quick Actions**: 2x2 card grid, each 120px tall
- **Recent**: lists scroll horizontally or vertically depending on breakpoint

### Chat
- **AppBar**: title left, Deep Think toggle center, menu right
- **Model Status**: live RPM/TPM gauge indicators
- **Message Bubbles**: sharp BL (AI) / BR (user) corners
- **Typing Indicator**: animated 3-circle sine wave, 1.4s repeat

### Resume Hub
**3 tabs**: Builder, Optimizer, Preview

- **Builder**: reorderable accordion sections similar to GitHub profile editing
- **Optimizer**: Job Description field → Analyze button → **signature ATS radial gauge** + keyword chips + suggestions
- **Preview**: A4-centric width, font selection, PDF export button, highlights for AI-optimized fields

### Template Hub
NavigationRail (Career/Comm/Study) → template cards → generate form
Templates: Cover Letter, SOP, LOR, LinkedIn, Email, Notes, MCQ, Flash

### Scheduler
- RPM/TPM circular gauges (size 140)
- Queue list with priority badges
- FAB for new job

### Settings
Tabs: AI Credentials / Appearance / Data
- **AI Tab**: Gemini & NVIDIA API fields
- **Appearance**: theme (dark/syst), palette (indigo/magenta), font scale (0.8x→1.5x)
- **Data**: export/import/wipe

---

## 8. Flutter Architecture Mapping

```text
app_shell.dart         → Shell
splash_screen.dart     → Entrance animation
chat_screen.dart       → Chat
resume_hub_screen.dart → Resume Builder/Optimizer/Preview
template_hub_screen.dart → Templates
dashboard_screen.dart → Home
scheduler_screen.dart  → Scheduler
settings_screen.dart   → Settings

Reusable widgets:
- GlassCard
- AtsRadialGauge
- ProviderStatusCard
- TokenUsageCard
- ReorderableAccordion
```

---

## 9. Motion & Interaction

- **Splash animation**: scale + fade orchestration
- **Typing indicator**: 3-circle bounce with sine timing
- **Radial progress**: custom painter sweep with gradient
- **Page transitions**: none (immediate stateful slide)
- **Only animate**: `Transform` & `Opacity` (avoid layout-triggering)

---

## 10. Anti-Patterns (Banned)

- ❌ Emoji in UI (use Material Icons)
- ❌ Pure black `#000000` (use `#090B11` Obsidian)
- ❌ Floating labels on inputs (label above)
- ❌ Horizontal scroll on mobile <768px
- ❌ 3-column equal-width grids (use asymmetric flow)
- ❌ Generic AI copy: “Elevate”, “Seamless”, “Unleash”
- ❌ Light theme (dark theme is primary identity)
- ❌ Inconsistent button heights (constrain to 36px min)

---

## 11. Content Principles

- **Write intent, not decoration**: “Save changes” not “Submit”
- **Dialogs**: explain outcomes: “Import database? Existing work will merge.”
- **Empty states**: action-first: “Start your first chat →”
- **Help text**: avoid filler: **not** “This field lets users input prompt data”, **but** “Ask the AI anything”

---

## 12. Design Risk

**Risk:** Magenta (`#F43F5E`) used intentionally in two roles: visual accent and destructive action (wipe button, missing keywords).

Justification:
- Most dark apps use green/red fixed roles, causing accessibility contrast issues (poor contrast on slate).
- Magenta sits between warm and cool, increasing depth perception next to indigo.
- Semantic role is still clear via location and iconography:
  - **Accent**: card headers, send buttons, active navigation
  - **Destructive**: delete buttons, wipe confirmation, missing keywords (shown as error state)

---

This spec empowers a Flutter developer to **build Vyaas AI with consistency, speed, and distinctiveness**.