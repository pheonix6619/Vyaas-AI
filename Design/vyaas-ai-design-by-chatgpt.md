# Vyaas AI — design.md

> Design specification for Flutter implementation. This document is the single source of truth for UI, UX, layout, theming, spacing, navigation, and component behavior.

---

# Product Identity

**Name:** Vyaas AI

**Tagline:**
Secure, Local-First AI Workspace

**Positioning:**
A professional productivity workspace combining AI chat, resume optimization, document generation, and intelligent task scheduling while keeping user data local.

**Design Goals**

* Professional
* Trustworthy
* Technical
* Fast
* Minimal
* Dark-first
* Productivity focused

Avoid looking like ChatGPT clones, crypto dashboards, gaming UIs, or generic AI tools.

---

# Theme System

## Primary Palette (Default)

```yaml
Background:
  Obsidian: #090B11

Surface:
  SlateCard: #131824

Primary:
  Indigo: #2563EB

Secondary:
  Coral: #F43F5E

Success:
  #10B981

Warning:
  #F59E0B

Error:
  #EF4444

TextPrimary:
  #F3F4F6

TextSecondary:
  #9CA3AF

Border:
  rgba(255,255,255,0.08)
```

---

## Alternate Palette

Nordic Forest

```yaml
Background:
  #0B0F0C

Surface:
  #161D18

Primary:
  #10B981

Secondary:
  #34D399
```

---

# Typography

## Font Families

### Headings

```yaml
Font:
  Outfit

Weights:
  600
  700
```

Used for:

* Branding
* Page titles
* Section titles
* ATS score

---

### Body

```yaml
Font:
  Inter

Weights:
  400
  500
  600
```

Used for:

* Inputs
* Messages
* Labels
* Metadata

---

## Scale

```yaml
Hero:
  32

H1:
  20

H2:
  16

H3:
  14

Body:
  13

Small:
  11

Caption:
  10
```

---

# Spacing System

8px grid only.

```yaml
XS: 4
SM: 8
MD: 16
LG: 24
XL: 32
```

Never use arbitrary spacing.

---

# Border Radius

```yaml
Button:
  8

Input:
  12

Card:
  16

BottomSheet:
  20

Full:
  24
```

---

# Navigation Shell

## Desktop

Width:

```yaml
250px
```

Structure:

```text
VYAAS AI

Dashboard
Chat
Resume Hub
Templates
Scheduler

Settings ▼
  Credentials
  Appearance
  Data

------------------

RPM
TPM
Provider Status
```

Behavior:

* Fixed sidebar
* No collapse mode
* Active item uses primary accent
* Content scrolls independently

---

## Mobile

Bottom Navigation

```text
Dashboard
Chat
Resume
Templates
More
```

Max:

```yaml
5 items
```

---

# Splash Screen

Purpose:

Immediately communicate trust and professionalism.

Layout:

```text
[Logo]

Vyaas AI

Secure, Local-First
AI Workspace
```

Animation:

```yaml
Logo:
  Scale Pulse

Text:
  Fade In

Duration:
  2500ms
```

Navigate automatically.

---

# Dashboard

## Layout

Desktop:

```text
Header

Quick Actions

Token Usage

Recent Chats

Recent Resumes
```

---

## Header

Left:

```text
Secure Workspace
```

Right:

```text
LOCAL-FIRST
```

Green success badge.

---

## API Warning Card

Show only if API missing.

```text
Configure your AI provider
to unlock chat and optimization.
```

CTA:

```text
Open Settings
```

Amber warning style.

---

## Quick Actions

2x2 grid

Cards:

```text
Start Chat

Optimize Resume

Create Template

Scheduler
```

Card height:

```yaml
120
```

---

## Token Usage Card

Contains:

```text
Daily Tokens

7200 / 10000
```

Progress bar

Scheduler Load

Estimated Cost

---

# Chat Screen

## Layout

```text
AppBar

Model Status

Messages

Input
```

---

## AppBar

Left:

```text
Chat
```

Center:

```text
Deep Think
```

Toggle switch.

Right:

Menu

```text
New Chat
Clear Chat
```

---

## Model Status Bar

Displays:

```text
Gemini 2.5 Pro

RPM
TPM
```

Compact gauges.

---

## Message Bubbles

### User

```yaml
Alignment:
  Right

Color:
  Primary Accent

Corner:
  Sharp BR
```

---

### Assistant

```yaml
Alignment:
  Left

Color:
  SlateCard

Corner:
  Sharp BL
```

Includes copy button.

---

## Input Bar

Contains:

```text
Prompt Field

Send Button
```

Deep Think:

```yaml
Border:
  Secondary Accent
```

---

## Chat Drawer

Sections:

### Quota

Radial usage chart

### Provider

Gemini

NVIDIA

### Credentials

Gemini Key

NVIDIA Key

Validate

Save

---

# Resume Hub

Uses:

```yaml
TabBar
```

Tabs:

```text
Builder
Optimizer
Preview
```

---

# Builder Tab

Accordion based.

Order:

1. Personal Details
2. Objective
3. Experience
4. Education
5. Skills
6. Projects
7. Certifications
8. Achievements

---

Each accordion:

```text
Expand

Edit

Save
```

---

## Import Resume

Expansion Tile

Input:

```text
Paste Resume
```

Action:

```text
Parse With AI
```

---

# JD Optimizer

Layout:

```text
Job Description

Analyze Button

ATS Score

Keywords

Suggestions
```

---

## ATS Score

Hero widget.

```yaml
Size:
  160x160
```

Range:

```yaml
0-100
```

---

## Missing Keywords

Chips

Example:

```text
Flutter
Riverpod
SQLite
```

---

## Suggestions

Glass card list.

---

# Preview Tab

Mimics A4.

Width:

```yaml
794px
```

Centered.

Toolbar:

```text
Font

Order

Export PDF
```

Optimization changes:

```yaml
Background:
  Warning Amber 20%
```

---

# Template Hub

## Layout

Desktop

```text
Navigation Rail

Template Grid

Editor
```

---

## Categories

Career

Communication

Study

---

## Career Templates

```text
Cover Letter

SOP

LOR

LinkedIn Summary
```

---

## Communication

```text
Professional Email

Follow-up Email

Leave Request
```

---

## Study

```text
Notes Summarizer

MCQ Generator

Flashcards

Viva Questions
```

---

# Scheduler

Layout

```text
RPM Gauge

TPM Gauge

Queue
```

---

## Gauges

Circular.

Size:

```yaml
140
```

---

## Queue Item

Contains:

```text
Title

Priority

Status

Progress
```

Priority colors:

```yaml
P1:
  Red

P2:
  Orange

P3:
  Blue

P4:
  Green
```

---

## FAB

Bottom right.

Label:

```text
New Job
```

---

# Settings

Sections:

## AI Credentials

Gemini

NVIDIA

Validate

Get API

---

## Active Provider

Dropdown

Recent Logs

---

## Appearance

Theme

```text
System
Dark
Light
```

Palette

```text
Midnight Navy
Nordic Forest
```

Font Scale

```yaml
0.8x → 1.5x
```

---

## Data Management

Export Backup

Import Backup

Wipe Local Storage

Requires confirmation dialog.

---

# GlassCard Specification

Background:

```yaml
#131824
Opacity: 60%
```

Border:

```yaml
1px rgba(255,255,255,0.08)
```

Radius:

```yaml
16px
```

Padding:

```yaml
16px
```

Used everywhere.

---

# Responsive Rules

## Mobile

```yaml
<768px
```

* Single column
* Bottom navigation
* Full-width cards

---

## Desktop

```yaml
>=768px
```

* Sidebar navigation
* Two-column dashboards
* Split layouts

---

# Flutter Architecture Mapping

```text
app_shell.dart
splash_screen.dart
dashboard_screen.dart
chat_screen.dart
resume_hub_screen.dart
template_hub_screen.dart
scheduler_screen.dart
settings_screen.dart
```

Reusable Widgets:

```text
GlassCard
VyaasButton
VyaasTextField
VyaasChip
VyaasGauge
VyaasBadge
TypingIndicator
ResumeAccordion
ProviderStatusCard
TokenUsageCard
```

This design spec is detailed enough for a Flutter developer to build the entire Vyaas AI application with consistent layouts, theming, spacing, and behavior.
