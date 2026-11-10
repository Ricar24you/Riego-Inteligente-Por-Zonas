---
name: AgroTech Precision
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#3d4a42'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#6d7a72'
  outline-variant: '#bccac0'
  surface-tint: '#006c4a'
  primary: '#006948'
  on-primary: '#ffffff'
  primary-container: '#00855d'
  on-primary-container: '#f5fff7'
  inverse-primary: '#68dba9'
  secondary: '#006398'
  on-secondary: '#ffffff'
  secondary-container: '#5bb8fe'
  on-secondary-container: '#00476e'
  tertiary: '#6b38d4'
  on-tertiary: '#ffffff'
  tertiary-container: '#8455ef'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#85f8c4'
  primary-fixed-dim: '#68dba9'
  on-primary-fixed: '#002114'
  on-primary-fixed-variant: '#005137'
  secondary-fixed: '#cce5ff'
  secondary-fixed-dim: '#93ccff'
  on-secondary-fixed: '#001d31'
  on-secondary-fixed-variant: '#004b73'
  tertiary-fixed: '#e9ddff'
  tertiary-fixed-dim: '#d0bcff'
  on-tertiary-fixed: '#23005c'
  on-tertiary-fixed-variant: '#5516be'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 3rem
    fontWeight: '700'
    lineHeight: 3.5rem
    letterSpacing: -0.025em
  display-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 2rem
    fontWeight: '700'
    lineHeight: 2.5rem
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 1.75rem
    fontWeight: '600'
    lineHeight: 2.25rem
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 1.375rem
    fontWeight: '600'
    lineHeight: 1.875rem
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 1.25rem
    fontWeight: '600'
    lineHeight: 1.75rem
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 1.125rem
    fontWeight: '600'
    lineHeight: 1.5rem
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 1rem
    fontWeight: '400'
    lineHeight: 1.6rem
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 0.875rem
    fontWeight: '400'
    lineHeight: 1.45rem
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 0.75rem
    fontWeight: '400'
    lineHeight: 1.25rem
  telemetry-metric:
    fontFamily: JetBrains Mono
    fontSize: 1.875rem
    fontWeight: '600'
    lineHeight: 2.25rem
    letterSpacing: -0.03em
  telemetry-code:
    fontFamily: JetBrains Mono
    fontSize: 0.8125rem
    fontWeight: '500'
    lineHeight: 1.25rem
  telemetry-timestamp:
    fontFamily: JetBrains Mono
    fontSize: 0.6875rem
    fontWeight: '400'
    lineHeight: 1rem
    letterSpacing: 0.02em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 0.75rem
    fontWeight: '600'
    lineHeight: 1rem
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 0.6875rem
    fontWeight: '600'
    lineHeight: 0.875rem
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1.25rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system is engineered for industrial-grade agronomic telemetry and automated zone-based irrigation control backed by fault-tolerant Erlang/OTP architectures. It speaks to agricultural engineers, precision farm managers, and agronomy researchers who demand absolute operational clarity, zero cognitive friction, and instantaneous status comprehension under variable field lighting.

The visual direction combines crisp corporate modernism with high-density data telemetry:
- **Purity and Precision:** Clean, high-legibility surfaces where whitespace serves functional separation rather than mere decoration.
- **Systemic Trust:** Visual language inspired by industrial SCADA control units and mission-critical aviation dashboards, softened with modern SaaS elegance.
- **Physical-Digital Congruence:** Real-world fluid dynamics (water flow, soil saturation, valve pressure) mirrored through calibrated state indicators, active pulse micro-interactions, and tabular telemetry readouts.
- **Tone:** Methodical, robust, scientific, and responsive.

## Colors

The palette directly communicates the operational reality of automated irrigation: fertile crop growth, hydrodynamic movement, and fault-tolerant process states.

### Core Roles
- **Primary (Emerald Agricultural):** `#059669` (Core), `#10B981` (Vibrant / Active), `#047857` (Deep Interactive / Pressed). Drives system actions, operational confirmations, and healthy soil status.
- **Secondary (Hydro Aqua / Flow):** `#0284C7` (Core), `#0EA5E9` (Active Valve / Water Active), `#0369A1` (Submerged / Dark Flow). Represents active water release, m³/h telemetry, and hydraulic pressure monitors.
- **Tertiary (Maintenance / Inhibited):** `#8B5CF6` (Core), `#F3E8FF` (Surface Tint). Designated strictly for maintenance overrides, inhibited actuators, and manual physical bypass.
- **Neutral (Slate Architecture):** `#64748B` (Muted Data / Structural Inactive), `#0F172A` (High-contrast Telemetry Text), `#F8FAFC` (Canvas Foundation), `#F1F5F9` (Nested Panel Troughs), `#FFFFFF` (Surface Cards), `#E2E8F0` (Structural Dividers).

### Telemetry & Critical Actor States
- **Normal / Healthy (`gen_statem: idle`):** `#10B981` text/fill on `#ECFDF5` container.
- **Watering Active (`gen_statem: irrigating`):** `#0EA5E9` pulse on `#E0F2FE` container with an animated hydrodynamic stroke.
- **Warning / Pressure Drift:** `#F59E0B` on `#FFFBEB`.
- **Fault / Valve Stuck (`gen_server: crash` / alert):** `#EF4444` on `#FEF2F2`.
- **Offline / Node Disconnected:** `#64748B` on `#F1F5F9`.

## Typography

The type system separates analytical data from UI control hierarchy:

1. **Interface & Direction (`Plus Jakarta Sans`):** Selected for its humanist geometry, broad aperture, and high legibility at micro dimensions on outdoor tablets. Used across navigation, modal structures, sector titles, and control triggers.
2. **Actor Telemetry & Machine Logic (`JetBrains Mono`):** Dedicated to quantitative metrics (e.g., `42.8 m³/h`, `58.4 PSI`, `68% RH`), Erlang process identifiers (`<0.241.0>`), supervisor state atoms (`:in_recovery`, `:irrigating`), and synchronized ISO timestamps localized to `America/Tijuana`.
3. **Tabular Numerics:** All numeric telemetry must implement `font-variant-numeric: tabular-nums` to eliminate jitter during real-time 1-second interval WebSocket pushes.

## Layout & Spacing

The layout is structured around an ultra-responsive 12-column grid designed for dense dashboard panels, valve matrix maps, and side-by-side telemetry feeds:

- **Desktop (≥1280px):** 12-column fluid-hybrid layout capped at 1600px max width. 24px gutters and 32px outer canvas margins. Accommodates a fixed 280px telemetry sidebar with a 3-column sector card arrangement.
- **Tablet / Field Terminal (768px – 1279px):** 8-column layout with 20px gutters and 24px margins. Zone cards flow into a 2-column format; actor log panels collapse into an off-canvas slide-out sheet.
- **Mobile (≤767px):** Single-column stack with 16px horizontal margins. Compact vertical padding (`space-sm` to `space-md`) ensures critical telemetry (Soil Moisture % and Valve Actuation) remains visible above the fold.
- **Rhythm Principle:** Internal card padding is strictly uniform at `space-lg` (24px) for desktop and `space-md` (16px) for mobile devices. Grid items use `space-sm` (8px) for tightly related actuator controls and `space-md` for distinct sensor groupings.

## Elevation & Depth

To preserve an ultra-clean, modern SaaS atmosphere, elevation relies on subtle tonal layering complemented by soft ambient shadows rather than heavy skeuomorphism or harsh outlines:

- **Canvas Foundation (`Level 0`):** `#F8FAFC`. The neutral ground upon which all IoT modules rest.
- **Surface Containment (`Level 1`):** Pure white (`#FFFFFF`) modular cards framed with a crisp, low-contrast border: `1px solid #E2E8F0`. Offset with a diffuse, low-intensity ambient shadow: `0 1px 3px 0 rgba(15, 23, 42, 0.04), 0 1px 2px -1px rgba(15, 23, 42, 0.03)`.
- **Interactive Hover & Drag (`Level 2`):** Elevates on user pointer interaction with `0 10px 15px -3px rgba(15, 23, 42, 0.05), 0 4px 6px -4px rgba(15, 23, 42, 0.03)`.
- **System Overlays & Emergency Panels (`Level 3`):** Drawers, manual overrides, and OTP supervisor telemetry logs float with `0 20px 25px -5px rgba(15, 23, 42, 0.08), 0 8px 10px -6px rgba(15, 23, 42, 0.04)`.
- **Water Pulse Halo:** Dynamic, non-elevated animated rings for irrigating valves: `box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.25)` with a 2-second rhythmic ease cycle.

## Shapes

The design system implements a controlled `roundedness: 2` (base 8px / 0.5rem radius) across all standard component geometries. This softens the industrial aspect while preserving technical precision:

- **Base Components (Inputs, Buttons, Checkboxes, Selects):** `0.5rem` (8px) radius. Ensures clean corner alignment across inline form fields and toggle toolbars.
- **Containers & Modular IoT Cards:** `rounded-lg` (1rem / 16px) creates clean visual containment for complex sensor arrays.
- **Simulator Banners & Modal Shells:** `rounded-xl` (1.5rem / 24px) for architectural containment.
- **Pills, Actor State Chips, and Mode Toggles:** Fully rounded radii (`9999px`) provide instantaneous visual differentiation between interactive telemetry badges and rectangular structural containers.

## Components

### 1. Erlang Process State Badges (OTP Pills)
- Fully pill-shaped (`9999px`).
- Monospace font (`JetBrains Mono`, `0.6875rem`, weight 600) preceded by a 6px status dot.
- **Active / Idle:** Background `#ECFDF5`, border `1px solid #A7F3D0`, dot & text `#059669`.
- **Watering / Busy:** Background `#E0F2FE`, border `1px solid #BAE6FD`, text `#0284C7`. The 6px dot displays an animated CSS ring ping.
- **Inhibited / Manual Bypass:** Background `#F3E8FF`, border `1px solid #DDD6FE`, text `#7C3AED`.
- **Error / Stuck Valve:** Background `#FEF2F2`, border `1px solid #FECACA`, text `#DC2626`. Displays the OTP error reason (`{:error, :valve_stuck}`) on hover tooltip.

### 2. Modular IoT Zone Cards
- Background `#FFFFFF`, border `1px solid #E2E8F0`, corner radius `1rem`.
- **Header:** Displays zone label (e.g., `ZONA 04 - NOGALES SUR`), Erlang actor PID badge (`<0.182.0>`), and the Auto/Manual segment toggle.
- **Telemetry Readout Matrix:** A 2-column or 3-column split showing Soil Moisture (%) with an integrated mini progress bar, Hydro Flow (`m³/h`), and Hydraulic Pressure (`PSI`).
- **Footer:** Last telemetry sync timestamp formatted in Tijuana local time (`YYYY-MM-DD HH:mm:ss PST/PDT`) alongside the immediate manual irrigation trigger.

### 3. Soil Moisture Slider
- Track height: 6px, rounded to `9999px`. Base track `#E2E8F0`.
- Active fill: Dynamic gradient transitioning from `#0EA5E9` (high hydration) to `#10B981` (optimal) to `#F59E0B` (dry limit).
- Thumb: 20px circle, `#FFFFFF` with a 2px `#059669` ring border, elevated with `Level 1` shadow. 
- Integrated numeric tooltip showing the real-time threshold setpoint value.

### 4. Metric Gauge & Readout Indicators
- Hydro Flow: `#0284C7` label with large numeric readout (`JetBrains Mono`) followed by a light text unit label (`m³/h`).
- Valve Pressure: Clean horizontal gauge indicator with warning zones marked at >75 PSI (Amber) and >90 PSI (Red).

### 5. Control Switches (Auto / Manual Mode)
- Segmented dual-pill switch style.
- Background `#F1F5F9`, internal active tab `#FFFFFF` with `0 1px 3px rgba(0,0,0,0.1)`.
- Active text displays bold emerald for `AUTO` (driven by the OTP scheduler) and tertiary violet for `MANUAL` (user controlled).

### 6. Academic Simulator Banner (Erlang/Cowboy)
- Spans full width of the main canvas.
- Background: Linear gradient from `#0F172A` to `#1E293B` with a subtle 1px border `#334155`.
- Text: White high-contrast header paired with `#94A3B8` subtext explaining the simulated telemetry environment.
- Highlights: Tagged with a high-contrast badge reading `Erlang/OTP 26` in `#A7F3D0` / `#065F46` and `Cowboy WS: Connected` with a pulsing emerald sync light. Contains an interactive slider to accelerate virtual cycle times (1x, 5x, 20x).

### 7. Form Fields & Action Triggers
- **Primary Button:** `#059669` background, `#FFFFFF` text, `0.5rem` radius, hover state `#047857`. Focus ring: `3px solid #A7F3D0`.
- **Secondary Action Button:** `#FFFFFF` background, border `1px solid #E2E8F0`, text `#0F172A`, hover `#F8FAFC`.
- **Emergency Stop Button:** `#EF4444` solid background, text `#FFFFFF`, with immediate system-wide actuator halt icon.