# Design System Spec (Phase 0)

> **Source of Truth** for all UI/UX decisions.
> Last updated: 2026-01-30

## 1. Colors & Surfaces

### Surfaces (Theme-Dependent)
| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `surface0` | `#FAFAFA` + Aurora | `#121212` + Aurora | Main app background (scaffold) |
| `surface1` | `#FFFFFF` | `#1E1E1E` | Standard cards, lists, bottom sheets |
| `surface2` | `#F5F5F5` | `#252525` | Elevated items, active states, pressed cards |

### Semantic Palette
| Role | Color | Hex (Reference) | Usage |
|------|-------|-----------------|-------|
| **Primary** | Green Growth | `#58CC02` | Main actions, correct answers, active tabs |
| **Primary Soft** | Light Green | `#D7FFB8` | Subordinate actions, backgrounds |
| **Secondary** | Amber Achieve | `#FFC800` | Stars, streaks, warnings, premium features |
| **Danger** | Red Error | `#FF4B4B` | Errors, deletion, wrong answers |
| **Info** | Blue Sky | `#2B70C9` | Information, links, neutral accents |
| **Text Primary** | Ink | `#4B4B4B` (Light) / `#E5E5E5` (Dark) | Headings, main body text |
| **Text Secondary** | Stone | `#777777` (Light) / `#A3A3A3` (Dark) | Captions, subtitles, disabled text |
| **Border Soft** | Outline | `#E5E5E5` (Light) / `#333333` (Dark) | Dividers, card borders (unselected) |
| **Shadow** | Shadow | `rgba(0,0,0,0.1)` | Card elevation shadows |

## 2. Typography

Font Family: **Nunito** (Round, friendly, readable) or **Roboto** (fallback).

| Token | Size | Weight | Height | Usage |
|-------|------|--------|--------|-------|
| `titleLarge` | 24 | 700 (Bold) | 1.25 | Screen titles, hero text |
| `titleMedium` | 20 | 700 (Bold) | 1.3 | Card titles, major section headers |
| `bodyLarge` | 18 | 600 (Semi) | 1.4 | Important body text, buttons |
| `bodyMedium` | 16 | 500 (Med) | 1.5 | Standard reading text |
| `bodySmall` | 14 | 500 (Med) | 1.5 | Secondary information |
| `labelLarge` | 14 | 700 (Bold) | 1.2 | UI controls, chips, small buttons |
| `caption` | 12 | 500 (Med) | 1.4 | Metadata, timestamps, tiny labels |

## 3. Radius & Shape

| Token | Value | Usage |
|-------|-------|-------|
| `none` | 0 | Full-screen generated content |
| `sm` | 8 | Small inner elements, checkboxes |
| `md` | 12 | Standard controls, text fields, small cards |
| `lg` | 16 | **Default Card**, Dialogs, Bottom Sheets |
| `xl` | 24 | Large containers, hero sections |
| `full` | 999 | Chips, Pills, FABs |

## 4. Spacing System

Base unit: **4px**

| Token | Pixels | Usage |
|-------|--------|-------|
| `xxs` | 4 | Tight grouping (icon + text) |
| `xs` | 8 | Standard padding, small gaps |
| `s` | 12 | Control grouping |
| `m` | 16 | **Default Padding**, Card internals |
| `l` | 20 | Section separation |
| `xl` | 24 | Major layout gaps |
| `2xl` | 32 | Screen margins, large whitespace |
| `3xl` | 40 | Hero spacing, bottom scrolling area |

## 5. Elevation & Depth

Premium feel comes from **subtle** depth, not heavy drop shadows.

- **Level 0 (Flat)**: Backgrounds, inputs (filled).
- **Level 1 (Card)**: `0px 4px 0px 0px` (Solid bottom lip) OR `0px 2px 8px rgba(0,0,0,0.06)` (Soft).
    - *Decision*: Go with **Soft Shadow** for modern feel, **Solid Lip** for buttons/gamification.
- **Level 2 (Float)**: `0px 8px 24px rgba(0,0,0,0.12)`. Dialogs, bottom sheets.

## 6. Motion & Interaction

| Interaction | Duration | Curve | Scale Effect |
|-------------|----------|-------|--------------|
| **Tap/Press** | 100ms | `easeInOut` | 0.96 scale |
| **Hover** | 200ms | `easeOut` | 1.02 scale (Desktop/Web) |
| **Page Transition** | 300ms | `fastOutSlowIn` | Slide + Fade |
| **Card Expand** | 400ms | `fastOutSlowIn` | Size + Fade |
| **Success Pop** | 600ms | `elasticOut` | Scale up heavily then settle |

### Interaction Rules
- **Buttons**: Must implement `ScaleButton` wrapper (0.96 on press).
- **Lists**: Staggered entrance animations (30ms delay per item).
- **Feedback**: Haptic feedback on all primary actions (Light Impact).
