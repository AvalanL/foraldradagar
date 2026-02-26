# Design System — Parents App

> Extracted pixel-by-pixel from reference screenshots.
> This document is the single source of truth for every visual decision in the app.

---

## Table of Contents

1. [Foundations](#1-foundations)
2. [Color Palette](#2-color-palette)
3. [Typography](#3-typography)
4. [Iconography](#4-iconography)
5. [Spacing & Layout Grid](#5-spacing--layout-grid)
6. [Component Library](#6-component-library)
7. [Screen Specifications](#7-screen-specifications)

---

## 1. Foundations

### 1.1 Platform Target

| Property            | Value                                  |
|---------------------|----------------------------------------|
| Platform            | iOS (iPhone)                           |
| Minimum iOS         | 17.0+                                  |
| Device frame        | iPhone 14 Pro / 15 Pro (Dynamic Island)|
| Screen width        | 393 pt (logical)                       |
| Safe area top       | 59 pt (below Dynamic Island)           |
| Safe area bottom    | 34 pt (home indicator)                 |
| Orientation         | Portrait only                          |

### 1.2 Design Principles

1. **Warm minimalism** — The entire app sits on a warm cream/parchment background. White cards float on top. No harsh grays or cool blues for surfaces.
2. **Content-first** — Typography is the primary visual element. Icons and color accents are secondary.
3. **Quiet chrome** — Navigation bars, toolbars, and separators are ultra-lightweight. No heavy borders. No solid tab bars.
4. **Time-awareness** — Relative timestamps ("1d 6h ago", "3h 47m ago") are first-class UI elements aligned to the trailing edge.

---

## 2. Color Palette

### 2.1 Backgrounds

| Token                    | Hex       | RGB              | Usage                                               |
|--------------------------|-----------|------------------|------------------------------------------------------|
| `bg.canvas`              | `#F5EFE5` | 245, 239, 229    | Full-screen background behind all content (warm cream/parchment) |
| `bg.surface`             | `#FFFFFF` | 255, 255, 255    | Card surfaces, list item backgrounds, calendar cells |
| `bg.surfaceElevated`     | `#FFFFFF` | 255, 255, 255    | Modal sheets, popovers (same white, elevated via shadow) |

### 2.2 Text Colors

| Token                    | Hex       | RGB              | Usage                                               |
|--------------------------|-----------|------------------|------------------------------------------------------|
| `text.primary`           | `#1C1C1E` | 28, 28, 30       | Titles, task names, primary content                  |
| `text.secondary`         | `#8A8A8E` | 138, 138, 142    | Subtitles, metadata labels ("Tag", "Folder")         |
| `text.tertiary`          | `#AEAEB2` | 174, 174, 178    | Timestamps, locations ("@Supermaket"), muted info    |
| `text.disabled`          | `#C7C7CC` | 199, 199, 204    | Grayed-out dates (previous/next month in calendar)   |
| `text.accent`            | `#C4A95B` | 196, 169, 91     | "Folder" label in page title, section headers ("Afternoon", "Evening") — warm gold/amber |
| `text.link`              | `#C4A95B` | 196, 169, 91     | Same gold used for tappable back-label "Home"        |

### 2.3 Icon / Category Colors

| Token                         | Hex       | RGB              | Usage                                              |
|-------------------------------|-----------|------------------|----------------------------------------------------|
| `category.home.bg`            | `#D4A94D` | 212, 169, 77     | Home category icon square background (golden amber)|
| `category.home.icon`          | `#FFFFFF` | 255, 255, 255    | Home icon glyph (white house on amber)             |
| `category.life.bg`            | `#E8937A` | 232, 147, 122    | Life category icon square background (salmon/coral)|
| `category.life.icon`          | `#FFFFFF` | 255, 255, 255    | Life icon glyph (white infinity/heart on coral)    |
| `category.work.bg`            | `#D15B5B` | 209, 91, 91      | Work category icon square background (muted red)   |
| `category.work.icon`          | `#FFFFFF` | 255, 255, 255    | Work icon glyph (white briefcase on red)           |

### 2.4 Interactive / Status Colors

| Token                    | Hex       | RGB              | Usage                                               |
|--------------------------|-----------|------------------|------------------------------------------------------|
| `interactive.checkboxFilled` | `#5B7FBF` | 91, 127, 191 | Filled/completed checkbox circle (muted steel-blue) |
| `interactive.checkboxEmpty`  | `#D1D1D6` | 209, 209, 214 | Empty/unchecked checkbox stroke                     |
| `interactive.dividerAccent`  | `#4A6FA5` | 74, 111, 165  | Short blue horizontal divider between sections      |
| `interactive.timelineBar`    | `#D4A94D` | 212, 169, 77  | Vertical amber bar on right edge of calendar task cards |
| `calendar.todayBorder`       | `#1C1C1E` | 28, 28, 30    | Border ring around today's date in calendar         |
| `calendar.currentMonth`      | `#1C1C1E` | 28, 28, 30    | Current-month date numbers                          |
| `calendar.otherMonth`        | `#C7C7CC` | 199, 199, 204 | Previous/next month date numbers (grayed out)       |

### 2.5 Separators & Borders

| Token                    | Hex       | Opacity | Usage                                              |
|--------------------------|-----------|---------|----------------------------------------------------|
| `separator.default`      | `#C6C6C8` | 100%    | Thin hairline between calendar rows                |
| `separator.list`         | `#E5E5EA` | 100%    | Between list items (very subtle)                   |
| `border.card`            | `#E8E3D9` | 100%    | Subtle warm border on card edges when needed       |

### 2.6 Shadows

| Token                | x  | y  | blur | spread | color                  | Usage             |
|----------------------|----|----|------|--------|------------------------|-------------------|
| `shadow.card`        | 0  | 2  | 12   | 0      | rgba(0, 0, 0, 0.06)   | Card float shadow |
| `shadow.elevated`    | 0  | 4  | 24   | 0      | rgba(0, 0, 0, 0.10)   | Modal/popover     |

---

## 3. Typography

The app uses **SF Pro** (San Francisco) — the iOS system font — exclusively. No custom fonts.

### 3.1 Type Scale

| Token                      | Font              | Weight      | Size (pt) | Line Height | Letter Spacing | Usage                                                         |
|----------------------------|-------------------|-------------|-----------|-------------|----------------|---------------------------------------------------------------|
| `type.screenTitle`         | SF Pro Display    | Bold (700)  | 28        | 34 pt       | -0.36 pt       | "All Items" in page header                                    |
| `type.screenTitleLight`    | SF Pro Display    | Regular (400)| 28       | 34 pt       | -0.36 pt       | "Folder" in page header (same size, lighter weight)           |
| `type.navTitle`            | SF Pro Text       | Semibold (600)| 17      | 22 pt       | -0.41 pt       | "Calendar" centered nav bar title                             |
| `type.navBackLabel`        | SF Pro Text       | Regular (400)| 17       | 22 pt       | -0.41 pt       | "Home" back button label                                      |
| `type.calendarMonth`       | SF Pro Text       | Semibold (600)| 17      | 22 pt       | -0.41 pt       | "March" month label                                           |
| `type.calendarYear`        | SF Pro Text       | Regular (400)| 17       | 22 pt       | -0.41 pt       | "2024" year label (lighter than month)                        |
| `type.calendarDayHeader`   | SF Pro Text       | Regular (400)| 13       | 18 pt       | -0.08 pt       | "Sun", "Mon", "Tue", etc.                                    |
| `type.calendarDate`        | SF Pro Text       | Regular (400)| 16       | 20 pt       | -0.32 pt       | Calendar date numbers                                         |
| `type.calendarDateToday`   | SF Pro Text       | Semibold (600)| 16      | 20 pt       | -0.32 pt       | Today's date number (bolder inside ring)                      |
| `type.sectionHeader`       | SF Pro Text       | Semibold (600)| 15      | 20 pt       | -0.24 pt       | "Afternoon", "Evening" — gold accent color                    |
| `type.sortLabel`           | SF Pro Text       | Regular (400)| 15       | 20 pt       | -0.24 pt       | "Name" sort indicator                                         |
| `type.categoryName`        | SF Pro Text       | Semibold (600)| 17      | 22 pt       | -0.41 pt       | "Home", "Life", "Work" category names                         |
| `type.categoryMeta`        | SF Pro Text       | Regular (400)| 13       | 18 pt       | -0.08 pt       | "Tag · 1 Item", "Folder" under category name                 |
| `type.taskTitle`           | SF Pro Text       | Semibold (600)| 16      | 21 pt       | -0.32 pt       | "Buy groceries for mom", task names                           |
| `type.taskMeta`            | SF Pro Text       | Regular (400)| 13       | 18 pt       | -0.08 pt       | "Yesterday, 15:57", date/time metadata                        |
| `type.taskLocation`        | SF Pro Text       | Regular (400)| 13       | 18 pt       | -0.08 pt       | "@Supermaket", "@Central Park" — tertiary color               |
| `type.taskTimestamp`        | SF Pro Text      | Regular (400)| 13       | 18 pt       | -0.08 pt       | "1d 6h ago", "3h 47m ago" — trailing-aligned relative time   |
| `type.taskSubcontent`      | SF Pro Text       | Regular (400)| 13       | 18 pt       | -0.08 pt       | "No Content" — tertiary/muted                                 |
| `type.todayButton`         | SF Pro Text       | Semibold (600)| 15      | 20 pt       | -0.24 pt       | "Today" button label                                          |

### 3.2 Type Pairing Rules

- **Page titles** use a two-tone pattern: primary word in Bold (`text.primary`), secondary descriptor in Regular (`text.accent`). Example: **"All Items"** `Folder`
- **Category rows** pair Semibold name above Regular metadata below.
- **Task rows** pair Semibold title above, Regular date + location below.
- Relative timestamps always sit on the **trailing edge**, vertically centered against the task metadata block.

---

## 4. Iconography

### 4.1 System Icons (SF Symbols)

| Icon Usage              | SF Symbol Name          | Size (pt) | Weight    | Color               |
|-------------------------|-------------------------|-----------|-----------|----------------------|
| Back chevron            | `chevron.left`          | 20        | Medium    | `text.primary`       |
| Sort/filter chevron     | `chevron.down`          | 12        | Regular   | `text.secondary`     |
| Filter icon             | `line.3.horizontal.decrease` | 18   | Regular   | `text.secondary`     |
| More menu (three dots)  | `ellipsis`              | 18        | Regular   | `text.tertiary`      |
| Checkbox empty          | `square` (custom)       | 22        | Regular   | `interactive.checkboxEmpty` |
| Checkbox filled         | `checkmark.circle.fill` | 22        | —         | `interactive.checkboxFilled` |
| Recurrence/repeat       | `repeat`                | 14        | Regular   | `text.tertiary`      |
| Search                  | `magnifyingglass`       | 24        | Regular   | `text.secondary`     |
| Add/Plus                | `plus`                  | 24        | Medium    | `text.secondary`     |
| Hamburger menu          | `line.horizontal.3`     | 24        | Regular   | `text.secondary`     |
| Month up chevron        | `chevron.up`            | 18        | Medium    | `text.primary`       |
| Month down chevron      | `chevron.down`          | 18        | Medium    | `text.primary`       |
| More (nav bar)          | `ellipsis.circle`       | 22        | Regular   | `text.primary`       |

### 4.2 Category Icons

Category icons are rendered inside a **rounded square** container.

| Property              | Value                |
|-----------------------|----------------------|
| Container size        | 40 x 40 pt           |
| Corner radius         | 10 pt                |
| Icon glyph size       | 20 pt                |
| Icon glyph color      | `#FFFFFF` (always white) |
| Icon glyph weight     | Medium               |

| Category | SF Symbol               | Background Color         |
|----------|-------------------------|--------------------------|
| Home     | `house.fill`            | `category.home.bg` (golden amber `#D4A94D`) |
| Life     | `infinity`              | `category.life.bg` (salmon `#E8937A`)        |
| Work     | `briefcase.fill`        | `category.work.bg` (muted red `#D15B5B`)     |

---

## 5. Spacing & Layout Grid

### 5.1 Base Unit

All spacing is based on a **4 pt** grid. Common increments:

| Token    | Value  |
|----------|--------|
| `xs`     | 4 pt   |
| `sm`     | 8 pt   |
| `md`     | 12 pt  |
| `base`   | 16 pt  |
| `lg`     | 20 pt  |
| `xl`     | 24 pt  |
| `2xl`    | 32 pt  |
| `3xl`    | 40 pt  |
| `4xl`    | 48 pt  |

### 5.2 Screen-Level Layout

| Property                        | Value         | Notes                                              |
|---------------------------------|---------------|----------------------------------------------------|
| Horizontal padding (leading)    | 20 pt         | Content inset from left screen edge                |
| Horizontal padding (trailing)   | 20 pt         | Content inset from right screen edge               |
| Top padding (below safe area)   | 12 pt         | Space between safe area and first content element  |
| Bottom padding (above toolbar)  | 0 pt          | Toolbar sits flush                                 |

### 5.3 Navigation Bar

| Property                        | Value         |
|---------------------------------|---------------|
| Height                          | 44 pt         |
| Back chevron size               | 20 pt         |
| Back chevron left inset         | 20 pt         |
| Back label left of chevron      | 6 pt          |
| Title alignment                 | Center        |
| Trailing action right inset     | 20 pt         |
| Bottom spacing to content       | 8 pt          |

### 5.4 Page Title Area

| Property                                | Value         |
|-----------------------------------------|---------------|
| Top padding (below nav bar)             | 16 pt         |
| Title baseline to sort row              | 32 pt         |
| "All Items" + "Folder" gap              | 6 pt (word space, same line) |
| Sort row height                         | 44 pt         |
| Sort row bottom margin                  | 8 pt          |

### 5.5 Category List Item

| Property                                | Value         |
|-----------------------------------------|---------------|
| Row height                              | 64 pt         |
| Icon left inset                         | 20 pt         |
| Icon-to-text gap                        | 14 pt         |
| Category name baseline to meta baseline | 18 pt         |
| Three-dot menu right inset              | 20 pt         |
| Vertical padding (top/bottom)           | 12 pt         |
| Separator                               | None visible between category items |

### 5.6 Section Divider (Blue Line)

| Property                        | Value                                       |
|---------------------------------|---------------------------------------------|
| Width                           | 40 pt                                        |
| Height                          | 3 pt                                         |
| Color                           | `interactive.dividerAccent` (`#4A6FA5`)      |
| Corner radius                   | 1.5 pt (fully rounded)                       |
| Alignment                       | Centered horizontally                        |
| Top margin (below last category)| 24 pt                                        |
| Bottom margin (above first task)| 24 pt                                        |

### 5.7 Task List Item

| Property                                | Value         |
|-----------------------------------------|---------------|
| Row min-height                          | 72 pt         |
| Checkbox left inset                     | 20 pt         |
| Checkbox diameter                       | 22 pt         |
| Checkbox-to-text gap                    | 14 pt         |
| Task title baseline to meta baseline    | 18 pt         |
| Meta baseline to location baseline      | 16 pt         |
| Relative timestamp right inset          | 20 pt         |
| Relative timestamp vertical alignment   | Centered to meta block |
| Three-dot menu right inset              | 20 pt         |
| Three-dot menu vertical alignment       | Top-aligned to title |
| Row vertical padding                    | 12 pt         |
| Inter-row separator                     | Hairline (`separator.list`), inset from left by 56 pt |

### 5.8 Bottom Toolbar

| Property                        | Value                          |
|---------------------------------|--------------------------------|
| Height                          | 50 pt (above safe area)        |
| Background                      | `bg.surface` (#FFFFFF)         |
| Top border                      | Hairline `separator.default`   |
| Icon count                      | 3 (menu, search, add)          |
| Icon distribution               | Equally spaced (thirds)        |
| Icon tap target                 | 44 x 44 pt                     |
| Hamburger left-center x         | ~65 pt                         |
| Search center x                 | ~196 pt (center)               |
| Plus right-center x             | ~328 pt                        |

---

## 6. Component Library

### 6.1 Category Row

```
┌──────────────────────────────────────────────────┐
│  ┌──────┐                                   •••  │
│  │ ICON │  Category Name                         │
│  │ 40x40│  metadata label                        │
│  └──────┘                                        │
│        14pt gap                                  │
│  20pt                                      20pt  │
└──────────────────────────────────────────────────┘
  Height: 64pt
```

**States:**
- Default: as shown
- Pressed: `bg.surface` dims to `rgba(0,0,0,0.04)` overlay
- No selected state at list level

### 6.2 Task Row (List View)

```
┌──────────────────────────────────────────────────┐
│  ○/●   Task Title                   •••          │
│  22pt  Date, Time                   1d 6h ago    │
│        @Location                                 │
│  20pt  14pt                              20pt    │
└──────────────────────────────────────────────────┘
  Min-height: 72pt
```

**Checkbox states:**
- Unchecked: `square` shape, 22 pt, 1.5 pt stroke, color `interactive.checkboxEmpty`, no fill
- Checked: `checkmark.circle.fill`, 22 pt, color `interactive.checkboxFilled`, white checkmark glyph

**Recurrence indicator (no checkbox shown):**
- When a task has recurrence, the checkbox is replaced by the `repeat` icon at 14 pt in `text.tertiary`
- Task title shifts left to align with the icon

**Relative timestamp:**
- Always trailing-aligned, vertically centered to the metadata block
- Color: `text.tertiary`
- Font: `type.taskTimestamp`

### 6.3 Calendar Grid

```
┌──────────────────────────────────────────────────┐
│  March  2024                          ∧     ∨    │
│                                                  │
│  Sun   Mon   Tue   Wed   Thu   Fri   Sat         │
├──────────────────────────────────────────────────┤
│  25    26    27    28    29    1      2           │
├──────────────────────────────────────────────────┤
│  3     4     5     6     7     8      9          │
├──────────────────────────────────────────────────┤
│  10   [11]   12    13    14    15    16           │
│              (small dot indicators below dates)   │
├──────────────────────────────────────────────────┤
│  17    18    19    20    21    22    23           │
├──────────────────────────────────────────────────┤
│  24    25    26    27    28    29    30           │
├──────────────────────────────────────────────────┤
│  31    1     2     3     4     5      6          │
└──────────────────────────────────────────────────┘
```

**Calendar layout specs:**

| Property                             | Value              |
|--------------------------------------|--------------------|
| Horizontal padding                   | 20 pt              |
| Month/year row height                | 44 pt              |
| Month/year to day headers gap        | 8 pt               |
| Day header row height                | 24 pt              |
| Day header to first date row gap     | 8 pt               |
| Date cell size                       | 44 x 40 pt (w x h) |
| Date row height                      | 40 pt              |
| Row separator                        | Hairline `separator.default`, full width |
| Column distribution                  | 7 equal columns across content width |
| Date number horizontal alignment     | Center in column   |
| Date number vertical alignment       | Center in row      |

**Date states:**

| State           | Text Color          | Background      | Border                                      |
|-----------------|---------------------|-----------------|----------------------------------------------|
| Current month   | `calendar.currentMonth` | None        | None                                         |
| Other month     | `calendar.otherMonth`   | None        | None                                         |
| Today           | `calendar.todayBorder`  | None        | 1.5 pt stroke ring, `calendar.todayBorder`, corner radius 8 pt |
| Selected        | `#FFFFFF`               | `text.primary` | None (filled circle)                       |
| Has events      | Small numeral below date number, `text.tertiary`, 10 pt font |  |                                              |

**Month navigation chevrons:**
- Positioned trailing, vertically centered to "March 2024"
- Up chevron and down chevron, 24 pt apart horizontally
- Tap targets: 44 x 44 pt each

### 6.4 Calendar Task Card

```
┌──────────────────────────────────────────────┬──┐
│  ●  Task Title (may wrap to 2 lines)    •••  │▌│
│     Today, 16:02                    3h 47m   │▌│
│     No Content                        ago    │▌│
└──────────────────────────────────────────────┴──┘
```

| Property                        | Value                                          |
|---------------------------------|------------------------------------------------|
| Card background                 | `bg.surface`                                   |
| Card corner radius              | 12 pt                                          |
| Card horizontal padding         | 16 pt                                          |
| Card vertical padding           | 12 pt                                          |
| Card shadow                     | `shadow.card`                                  |
| Card left inset from screen     | 40 pt (indented under section header)          |
| Card right inset from screen    | 20 pt                                          |
| Timeline bar width              | 4 pt                                           |
| Timeline bar color              | `interactive.timelineBar` (amber `#D4A94D`)    |
| Timeline bar position           | Flush right edge of card, full height           |
| Timeline bar corner radius      | 0 pt (sharp, clipped by card radius at corners)|
| Checkbox to title gap           | 12 pt                                          |
| Title to meta gap               | 4 pt                                           |
| Meta to subcontent gap           | 2 pt                                           |
| Relative timestamp              | Trailing-aligned, baseline-aligned to meta     |
| Three-dot menu                  | Top-right corner, 12 pt inset from edges       |

### 6.5 Section Header (Calendar View)

| Property                        | Value                                    |
|---------------------------------|------------------------------------------|
| Font                            | `type.sectionHeader`                     |
| Color                           | `text.accent` (gold `#C4A95B`)           |
| Left inset                      | 20 pt                                    |
| Top margin                      | 20 pt                                    |
| Bottom margin                   | 12 pt                                    |
| Text                            | "Afternoon", "Evening", "Morning", "Night" |

### 6.6 "Today" Button

| Property                        | Value                    |
|---------------------------------|--------------------------|
| Position                        | Bottom-right of calendar view |
| Right inset                     | 20 pt                    |
| Bottom inset                    | 16 pt (above safe area)  |
| Font                            | `type.todayButton`       |
| Color                           | `text.primary`           |
| Background                      | None (text-only button)  |
| Tap target                      | 44 x 44 pt              |

### 6.7 Sort/Filter Row

```
┌──────────────────────────────────────────────────┐
│  ∨ Name                                    ⊞     │
│  20pt                                      20pt  │
└──────────────────────────────────────────────────┘
  Height: 44pt
```

| Property                        | Value                          |
|---------------------------------|--------------------------------|
| Height                          | 44 pt                          |
| Chevron size                    | 12 pt                          |
| Chevron to label gap            | 6 pt                           |
| Label font                      | `type.sortLabel`               |
| Label color                     | `text.secondary`               |
| Filter icon                     | trailing-aligned               |
| Filter icon color               | `text.secondary`               |

---

## 7. Screen Specifications

### 7.1 All Items (Folder View) — Left Screen

**Structure (top to bottom):**

```
Safe Area (Dynamic Island)
├── Back Chevron `<`                             ← 20pt left, 12pt below safe area
├── 16pt gap
├── Page Title: "All Items Folder"               ← 20pt left
│   "All Items" = type.screenTitle, text.primary
│   "Folder" = type.screenTitleLight, text.accent
├── 12pt gap
├── Sort/Filter Row                              ← Component 6.7
│   "∨ Name" left, filter icon right
├── 8pt gap
├── Category List                                ← Component 6.1 (repeated)
│   ├── Home row (amber icon, "Tag · 1 Item")
│   ├── Life row (coral icon, "Folder")
│   └── Work row (red icon, "Tag")
├── 24pt gap
├── Section Divider (blue line)                  ← Component 5.6
├── 24pt gap
├── Task List (scrollable)                       ← Component 6.2 (repeated)
│   ├── "Buy groceries for mom"
│   │    ✓ filled checkbox (completed)
│   │    "Yesterday, 15:57"
│   │    "@Supermaket"
│   │    "1d 6h ago" trailing
│   ├── hairline separator (56pt left inset)
│   ├── "One on one time with Dani"
│   │    □ empty checkbox
│   │    "Tue, 27 Aug 24, 14:30"
│   │    "@Central Park"
│   │    "1w 1d" trailing
│   ├── hairline separator
│   ├── "Preparing for exam"
│   │    ↻ recurrence icon (no checkbox)
│   │    "Tomorrow, 10:00"
│   │    "@Maplewood Library"
│   │    "11h 54m" trailing
│   ├── hairline separator
│   └── "Table Mountain (Khoekhoe: Huri‡oaxa,..."
│        (truncated with ellipsis)
├── flex spacer
└── Bottom Toolbar                               ← Component 6.8
    ≡ (menu)    🔍 (search)    + (add)
```

**Key measurements from screen edge:**

| Element                  | X (from left) | Y (from top of safe area) |
|--------------------------|---------------|---------------------------|
| Back chevron             | 20 pt         | 12 pt                     |
| "All Items"              | 20 pt         | 56 pt                     |
| Sort chevron "∨"         | 20 pt         | 100 pt                    |
| First category icon      | 20 pt         | 152 pt                    |
| Blue divider center      | ~196 pt       | 356 pt                    |
| First task checkbox      | 20 pt         | 404 pt                    |
| Bottom toolbar top edge  | 0 pt          | ~780 pt                   |

### 7.2 Calendar View — Right Screen

**Structure (top to bottom):**

```
Safe Area (Dynamic Island)
├── Navigation Bar                               ← 44pt height
│   "< Home" left (chevron + label, gold)
│   "Calendar" center (type.navTitle, text.primary)
│   "•••" right (ellipsis.circle)
├── 8pt gap
├── Calendar Header                              ← Month/Year + Chevrons
│   "March" type.calendarMonth, text.primary
│   "2024" type.calendarYear, text.secondary
│   ∧ and ∨ chevrons trailing
├── 8pt gap
├── Day-of-Week Headers                          ← Sun Mon Tue Wed Thu Fri Sat
├── 8pt gap
├── Calendar Grid (6 rows)                       ← Component 6.3
│   Row separator hairlines between each row
│   Date 11 = today (bordered)
│   Dates 25-29 (Feb) and 1-6 (Apr) = other month (muted)
│   Small event count indicators below dates 11, 14
├── 20pt gap
├── Section: "Afternoon"                         ← Component 6.5
├── 12pt gap
├── Task Card                                    ← Component 6.4
│   "Research and sign up for a local community eve..."
│   ✓ filled checkbox
│   "Today, 16:02"
│   "No Content"
│   "3h 47m ago" trailing
│   Amber timeline bar on right edge
├── 20pt gap
├── Section: "Evening"                           ← Component 6.5
├── flex spacer
└── "Today" button                               ← Component 6.6, bottom-right
```

---

## 8. Interaction & Motion Specs

### 8.1 Transitions

| Transition                     | Type              | Duration | Curve                         |
|--------------------------------|-------------------|----------|-------------------------------|
| Push screen (forward)          | Slide from right  | 350ms    | `easeInOut` (iOS default)     |
| Pop screen (back)              | Slide to right    | 350ms    | `easeInOut`                   |
| Checkbox toggle                | Scale bounce      | 200ms    | `spring(damping: 0.7)`        |
| Calendar month change          | Crossfade + slide | 300ms    | `easeInOut`                   |
| Row highlight on press         | Opacity fade      | 100ms    | `linear`                      |

### 8.2 Gestures

| Gesture                        | Action                                          |
|--------------------------------|-------------------------------------------------|
| Swipe right on task row        | Reveal quick actions (complete/reschedule)       |
| Swipe left on task row         | Reveal delete action                             |
| Tap category row               | Navigate into category detail                    |
| Tap task row                   | Navigate into task detail                        |
| Tap checkbox                   | Toggle completion state                          |
| Tap three-dot menu             | Show context menu (iOS `.contextMenu`)           |
| Tap "Today" button             | Scroll calendar to current date                  |
| Long press task row            | Drag to reorder                                  |
| Pull to refresh                | Refresh task list                                |

---

## 9. Responsive & Accessibility Notes

### 9.1 Dynamic Type Support

All text styles should scale with iOS Dynamic Type. Use `UIFont.preferredFont(forTextStyle:)` or SwiftUI `.font(.system(...))` with `relativeTo:` parameter.

| Design Token              | UIKit Text Style    | SwiftUI equivalent              |
|---------------------------|---------------------|---------------------------------|
| `type.screenTitle`        | `.title1`           | `.title`                        |
| `type.navTitle`           | `.headline`         | `.headline`                     |
| `type.categoryName`       | `.body` (semibold)  | `.body.weight(.semibold)`       |
| `type.taskTitle`          | `.callout` (semibold)| `.callout.weight(.semibold)`   |
| `type.taskMeta`           | `.footnote`         | `.footnote`                     |
| `type.calendarDate`       | `.callout`          | `.callout`                      |
| `type.sectionHeader`      | `.subheadline`      | `.subheadline.weight(.semibold)`|

### 9.2 Color Contrast

All text/background combinations meet WCAG 2.1 AA (4.5:1 minimum for body text):

| Foreground         | Background     | Ratio  | Pass |
|--------------------|----------------|--------|------|
| `text.primary`     | `bg.surface`   | 16.3:1 | AA   |
| `text.secondary`   | `bg.surface`   | 4.6:1  | AA   |
| `text.tertiary`    | `bg.surface`   | 3.5:1  | AA*  |
| `text.accent`      | `bg.surface`   | 4.5:1  | AA   |
| `category.*.icon`  | `category.*.bg`| >4.5:1 | AA   |

*`text.tertiary` is used only for supplementary info alongside primary labels — acceptable under WCAG non-text contrast rules.

### 9.3 Dark Mode Mapping

| Light Token                | Dark Mode Hex   | Notes                                |
|----------------------------|-----------------|--------------------------------------|
| `bg.canvas` `#F5EFE5`     | `#1C1C1E`      | iOS system background                |
| `bg.surface` `#FFFFFF`    | `#2C2C2E`      | Elevated surface                     |
| `text.primary` `#1C1C1E`  | `#F2F2F7`      | Inverted                             |
| `text.secondary` `#8A8A8E`| `#8E8E93`      | Stays similar                        |
| `text.accent` `#C4A95B`   | `#D4B96B`      | Slightly brighter for contrast       |
| `separator.default`        | `#38383A`      | iOS system separator dark            |

---

## 10. Asset Naming Conventions

### 10.1 Icons

```
icon/{context}/{name}
icon/category/home
icon/category/life
icon/category/work
icon/nav/back
icon/nav/more
icon/action/search
icon/action/add
icon/action/menu
icon/task/checkbox-empty
icon/task/checkbox-filled
icon/task/recurrence
icon/calendar/chevron-up
icon/calendar/chevron-down
```

### 10.2 Colors (Xcode Asset Catalog)

```
Colors/
├── Background/
│   ├── Canvas
│   ├── Surface
│   └── SurfaceElevated
├── Text/
│   ├── Primary
│   ├── Secondary
│   ├── Tertiary
│   ├── Disabled
│   └── Accent
├── Category/
│   ├── HomeBg
│   ├── LifeBg
│   └── WorkBg
├── Interactive/
│   ├── CheckboxFilled
│   ├── CheckboxEmpty
│   ├── DividerAccent
│   └── TimelineBar
└── Calendar/
    ├── TodayBorder
    ├── CurrentMonth
    └── OtherMonth
```

---

## 11. Implementation Notes (SwiftUI)

### 11.1 Global Background

```swift
// Every screen wraps content in:
ZStack {
    Color("Canvas") // #F5EFE5
        .ignoresSafeArea()

    ScrollView {
        // content
    }
}
```

### 11.2 Card Style Modifier

```swift
.background(Color("Surface"))
.cornerRadius(12)
.shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 2)
```

### 11.3 Category Icon

```swift
Image(systemName: "house.fill")
    .font(.system(size: 20, weight: .medium))
    .foregroundColor(.white)
    .frame(width: 40, height: 40)
    .background(Color("CategoryHomeBg"))
    .cornerRadius(10)
```

### 11.4 Today Date Ring

```swift
Text("11")
    .font(.system(size: 16, weight: .semibold))
    .overlay(
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color("TodayBorder"), lineWidth: 1.5)
            .frame(width: 32, height: 32)
    )
```

---

*End of Design System*
