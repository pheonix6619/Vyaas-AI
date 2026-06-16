# Design System: Vyaas AI

## 1. Style Definition

- **Name:** Vyaas AI
- **Type:** Professional, Minimal, Distinctive
- **Keywords:** local-first AI workspace, secure chat, resume builder, dark theme, glassmorphism, productivity, indigo, Flutter
- **Era:** 2020s Productivity Tooling
- **Light/Dark:** ✗ No Light / ✓ Full Dark

## 2. Color Palette

- **Backgrounds:** Obsidian `#090B11`, Slate Card `#131824`, Near-black
- **Accent Primary:** Cobalt Blue `#2563EB` (Midnight Navy) / Mint Green `#10B981` (Nordic Forest)
- **Accent Secondary:** Coral Red `#F43F5E` (Midnight Navy) / Sage Green `#34D399` (Nordic Forest)
- **Semantic:** Success `#10B981`, Warning `#F59E0B`, Error `#EF4444`
- **Text:** Primary `#F3F4F6`, Secondary `#9CA3AF`
- **Border:** Translucent white `0x15FFFFFF`

## 3. Visual Effects

Glassmorphism cards (`GlassCard`), frosted backgrounds, subtle border strokes, indigo gradient accents, radial progress rings, animated typing indicator, fade + scale splash entrance, collapsible accordion sections, reorderable lists with drag handles.

## 4. AI Prompt Keywords

local-first AI workspace, secure chat, resume ATS optimizer, template hub, glassmorphism dark UI, indigo accent, token scheduler, Flutter Riverpod, drift database, productivity tooling.

## 5. Technical Tokens

```dart
// Spacing (8px base unit)
const double spacingXs = 4;
const double spacingSm = 8;
const double spacingMd = 16;
const double spacingLg = 24;
const double spacingXl = 32;

// Border radius
const double radiusSm = 8;
const double radiusMd = 12;
const double radiusLg = 16;
const double radiusFull = 24;

// Card
const double cardBorderRadius = 16;
const double cardBorderOpacity = 0.08;
const double cardBackgroundOpacity = 0.6;

// Font sizes
const double fontSizeXs = 10;
const double fontSizeSm = 11;
const double fontSizeMd = 13;
const double fontSizeLg = 18;
const double fontSizeXl = 32;
```

## 6. Design System Tokens

```dart
--obsidian: #090B11
--slate-card: #131824
--accent-indigo: #2563EB
--accent-purple: #F43F5E
--success: #10B981
--warning: #F59E0B
--error: #EF4444
--text-primary: #F3F4F6
--text-secondary: #9CA3AF
--radius-card: 16px
--radius-input: 12px
--radius-button: 8px
--font-display: 'Outfit'
--font-body: 'Inter'
--spacing-unit: 8px
```

## 7. Implementation Checklist

- ☐ Navigation shell (sidebar + bottom nav)
- ☐ Splash screen with animated logo
- ☐ Dashboard with token gauge, quick actions, recent items
- ☐ Chat screen with message list, markdown rendering, typing indicator
- ☐ AI control drawer (provider selector, daily quota, API keys)
- ☐ Resume Hub — 3 tabs (Builder Form, JD Optimizer, Preview & Export)
- ☐ Builder form with 8 editable sections + reorderable sequence
- ☐ AI resume import/parse from raw text
- ☐ JD optimizer with ATS score, keyword extraction, AI suggestions
- ☐ PDF export with font choice + section ordering
- ☐ Template Hub — 3 categories, 9 templates, AI generation + export to chat
- ☐ Scheduler dashboard — RPM/TPM gauges, task queue, FAB for new jobs
- ☐ Settings — API key management, theme/palette switching, font scale, backup/wipe
- ☐ Dark theme with 2 palette variants (Midnight Navy, Nordic Forest)
- ☐ GlassCard reusable component
- ☐ Responsive breakpoints (mobile <768, desktop >=768)

## 8. Visual Theme & Atmosphere

Vyaas AI — Professional dark workspace with glassmorphism surfaces. Indigo/coral accent on navy background (default) or mint/sage on near-black forest (alt). Typography-driven with Outfit for headings and Inter for body. Low-density layouts (5/10) with generous whitespace. Motion is restrained — entrance fades, scale pulses, and subtle hover shifts only. The aesthetic should read as a serious productivity tool, not a consumer app.

- Density: 5/10 — Balanced
- Variance: 6/10 — Distinctive per section
- Motion: 3/10 — Minimal, purposeful

## 9. Color Palette & Roles

- **Obsidian Background** (`#090B11`) — Primary screen background, scaffold
- **Slate Card** (`#131824`) — Card surfaces, drawer, input fills, nav rail
- **Accent Indigo** (`#2563EB`) — Primary interactive elements, active nav items, links, send button, progress fills
- **Accent Purple** (`#F43F5E`) — Secondary accent, AI generate buttons, highlight badges
- **Success Green** (`#10B981`) — Positive confirmations, local-first badge, valid state
- **Warning Amber** (`#F59E0B`) — API key alert card, missing-keyword emphasis
- **Error Red** (`#EF4444`) — Destructive actions, wipe button, error messages, high-priority badges
- **Text Primary** (`#F3F4F6`) — Headlines, nav labels, active content
- **Text Secondary** (`#9CA3AF`) — Body copy, hints, subtitles, metadata
- **Border Transparent** (`0x15FFFFFF`) — Card borders, dividers, input outlines

Nordic Forest overrides:
- Accent Indigo → `#10B981` (mint green)
- Accent Purple → `#34D399` (sage green)
- Obsidian → `#0B0F0C`
- Slate Card → `#161D18`

## 10. Typography Rules

- **Display / Headings:** Outfit — Weight 600/700, tight tracking (-0.5px), used for headlines, nav branding, page titles
- **Body:** Inter — Weight 400, 13px base, 1.4 line-height, used for all content text
- **UI Labels / Captions:** Inter — Weight 500/600, 10-12px, slight letter-spacing (0.5px), used for buttons, badges, metadata
- **Monospace:** System monospace — Used for code blocks, technical values

Scale:
- Hero (Splash): 32px
- H1: 20px (AppBar title)
- H2: 16px (section titles)
- H3: 14px (card titles, accordion headers)
- Body: 13px
- Small: 11px
- Caption: 10px

## 11. Component Stylings

- **Primary Button:** Rounded (8-12px). Accent fill. Hover: opacity shift + subtle lift. Text weight 600. Icon + label layout.
- **Secondary / Ghost Button:** Slate card background. No border. Text in accent color. Used for "Save", "Cancel".
- **GlassCard:** Rounded (16px) corners. Slate card background at 60% opacity. 1px translucent border. Frosted appearance. Optional padding (default 16px).
- **Inputs:** Label above or hint inside. Filled background (white 2% opacity). Rounded (12px). Focus border: accent 1.5px. Hint text in secondary color. No floating labels.
- **Navigation (Desktop Sidebar):** 250px wide. Obsidian background. Active item: accent 12% opacity fill + accent border. Icons + labels. 13px font. 10px border radius.
- **Navigation (Mobile Bottom):** Fixed bottom. Slate card background. 5 items max. Active: accent color. Font 10px. Type: fixed.
- **Tabs (Resume Hub):** AppBar bottom with icons + labels. Indicator: accent underline.
- **Chips:** Used for keywords, skills, ATS tags. Rounded (12px). Wrapped layout.
- **Empty States:** Centered text in secondary color. Descriptive message. No icon needed.
- **Skeletons:** Circular progress indicator (standard Flutter). Used during AI loading states.
- **Dialog (Alerts):** Obsidian background. Title + content + actions (Cancel / Confirm). Used for API key warnings, wipe confirmation.
- **Bottom Sheet:** Modal with rounded top (20px radius). Slate card background. Full-width inputs. Used for "New Job" form.
- **Drawer (Chat):** Full-height. Branding header + scrollable content (quota, provider, API keys). 20px horizontal padding.

## 12. Layout Principles

- **Navigation:** 250px sidebar (desktop) / BottomNavigationBar (mobile). Breakpoint: 768px.
- **Content padding:** 24px (desktop) / 16px (mobile).
- **Card spacing:** 16px grid gap.
- **Section vertical gaps:** 32px between major sections.
- **Dashboard layout:** Adaptive grid — 2 columns (wide), 1 column (narrow). Responsive `LayoutBuilder`.
- **Chat layout:** Full-width message list. Input bar fixed at bottom. Sub-header above list.
- **Resume Hub:** TabBar with 3 views. Builder form uses scrollable accordion sections. Optimizer is single-column. Preview mimics A4 page.
- **Template Hub:** NavigationRail (3 categories) + grid of template cards (2 columns) + form view on selection.
- **Scheduler:** Two gauges side-by-side + task list below. FAB for new job.
- **Settings:** Single scrollable list of grouped sections. Cards for each group.
- **z-index contract:** base (0) / app-bar (4) / drawer (5) / bottom-nav (6) / snackbar (8) / dialog (10) / bottom-sheet (12).

## 13. Motion & Interaction

- **Physics:** Ease-in-out curves, 200-300ms duration. Smooth and predictable.
- **Entry animations:** Splash: scale (easeOutBack) + fade (easeIn) over 1.5s for logo, 1.2s for text.
- **Chat session switch:** Content fades out (200ms), data loads, fades back in.
- **Typing indicator:** 3 dots bouncing on sine wave over 1.4s loop. 1400ms repeat.
- **Radial progress:** Custom painter with sweep gradient. No animation — static render on update.
- **Sidebar hover:** Subtle background fill. No lift.
- **Accordion expand:** Standard Flutter ExpansionTile animation.
- **Page transitions:** None (indexed screens swap instantly).
- **Performance:** Avoid animated `Container` — prefer `Transform` and `Opacity`. No layout-triggering properties.

## 14. Anti-Patterns (Banned)

- No emojis in UI — use Material Icons (`Icons.*`) from Flutter
- No pure black (`#000000`) — use `#090B11` obsidian
- No light theme as default — dark theme is identity
- No generic AI copywriting: "Elevate", "Seamless", "Unleash", "Next-Gen", "Revolutionize"
- No floating labels on inputs — label above or hint only
- No horizontal scroll on mobile — collapse layouts at breakpoint
- No 3-column equal feature grids — use adaptive 1/2 column
- No inline `CircularProgressIndicator` size variants — use standard 16x16 or 24x24
- No hardcoded font sizes — use theme's `TextTheme` consistently

## 15. Context

Vyaas AI is a local-first AI workspace for job seekers and professionals. Core features: secure AI chat (Gemini/NVIDIA), ATS resume optimization with JD targeting, template generation (cover letters, SOPs, emails, study materials), and a token-based scheduler for background AI jobs. All data stored locally via Drift/SQLite.

## 16. Use Case

Desktop and mobile Flutter application. Primary audience: job seekers, students, and professionals who need AI-assisted resume tailoring, document drafting, and secure communication without data leaving their device.
