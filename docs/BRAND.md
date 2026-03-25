# Notch — Brand Guidelines

## App Overview
Notch is a macOS menu bar utility that lives in your MacBook's notch or menu bar area — displaying widgets like date, time, battery, and weather in a clean, glanceable strip.

---

## Icon Concept

**Visual:** A small notch shape (the MacBook display cutout) containing 3-4 mini status dots — like the "Dynamic Island" concept.
- A rounded square icon
- A subtle pill/notch shape in brand teal
- Four mini indicators inside (representing time, battery, weather, date widgets)
- Minimal, geometric, utility-first
- Sizes: 16, 32, 64, 128, 256, 512, 1024

**Alternative concept:** A simple rounded square with a white/black pill shape centered — like the notch itself.

---

## Color Palette

| Role | Hex | Usage |
|------|-----|-------|
| Primary Teal | `#14B8A6` | Active widget, bar background |
| Deep Teal | `#0F766E` | Pressed states |
| Background | System (NSColor.windowBackgroundColor) | Respects dark/light mode |
| Widget Surface | `#1E293B` (dark) / `#F1F5F9` (light) | Individual widget chip |
| Text Primary | `#F8FAFC` (dark) / `#0F172A` (light) | Widget values (time, temp) |
| Text Secondary | `#94A3B8` (dark) / `#64748B` (light) | Labels |
| Battery Green | `#22C55E` | Battery > 50% |
| Battery Yellow | `#EAB308` | Battery 20–50% |
| Battery Red | `#EF4444` | Battery < 20% |
| Weather Sun | `#FBBF24` | Sunny weather icon |
| Weather Cloud | `#94A3B8` | Cloudy weather icon |
| Weather Rain | `#3B82F6` | Rainy weather icon |

---

## Typography

- **Time (hero):** SF Pro Display, Bold — 13px (fits in notch)
- **Date:** SF Pro Text, Medium — 11px
- **Weather Temp:** SF Pro Rounded, Medium — 12px
- **Battery %:** SF Pro Rounded, Regular — 11px
- **Labels:** SF Pro Text, Regular — 9px

**Font Stack:**
```
font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "SF Pro Rounded", sans-serif;
```

---

## Visual Motif

**Theme:** "Glass & Light" — the widget bar should feel like it's made of glass — semi-transparent, with subtle blur, sitting elegantly in the notch space. The aesthetic mirrors Apple's notch Dynamic Island: rounded, floating, alive.

- **Widget bar:** Floating pill-shaped bar that sits in the notch/display area. Background: blur + semi-transparent dark surface
- **Widget chips:** Individual rounded rectangles inside the bar, separated by subtle dividers
- **Available widgets:** Time, Date, Battery (icon + %), Weather (icon + temp), Keyboard layout
- **Compact mode:** Only shows time; other widgets appear on hover or click
- **Expanded mode:** A small popover panel listing all widgets and their settings
- **Transparency:** Uses `NSVisualEffectView` for the blur/glow aesthetic
- **Menu bar mode:** Falls back to a slim bar at the top of the screen if no notch is present

**Spatial rhythm:** Widget chips are 8px apart. Each chip padding: 6px horizontal, 4px vertical. Total bar height: 20px (notch mode) or 24px (menu bar mode).

---

## macOS-Specific Behavior

- **Window:** Borderless, transparent `NSWindow` positioned at top-center (notch area). Always on top. Non-activating.
- **Menu Bar:** No Dock icon. Menu bar app (`NSStatusItem`).
- **Display detection:** Auto-detects if MacBook has a notch and positions accordingly
- **Dark/Light mode:** Automatically matches system appearance
- **Widgets:** Each widget is independently togglable in preferences
- **Keyboard shortcuts:** `⌘⇧N` toggle notch bar visibility

---

## Sizes & Behavior

| Element | Notch Mode | Menu Bar Mode |
|---------|-----------|---------------|
| Bar height | 20px | 24px |
| Bar width | Fills notch | Full screen width |
| Widget chip | 6px h-pad, 4px v-pad | Same |
| Time font | 13px | 14px |
| Popover | 300×280px | 300×280px |

Popover appears on click/hover of the notch bar. Contains widget toggles and settings.
