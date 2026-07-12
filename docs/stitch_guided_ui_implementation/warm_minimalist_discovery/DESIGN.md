---
name: Warm Minimalist Discovery
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0edec'
  surface-container-high: '#ebe7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1c1b1b'
  on-surface-variant: '#5e3f3c'
  inverse-surface: '#313030'
  inverse-on-surface: '#f3f0ef'
  outline: '#936e6b'
  outline-variant: '#e8bcb8'
  surface-tint: '#c0001b'
  primary: '#b7001a'
  on-primary: '#ffffff'
  primary-container: '#e60023'
  on-primary-container: '#fff7f6'
  inverse-primary: '#ffb3ad'
  secondary: '#5e5e5d'
  on-secondary: '#ffffff'
  secondary-container: '#e0dfde'
  on-secondary-container: '#626361'
  tertiary: '#595a5b'
  on-tertiary: '#ffffff'
  tertiary-container: '#717373'
  on-tertiary-container: '#f9f9f9'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad7'
  primary-fixed-dim: '#ffb3ad'
  on-primary-fixed: '#410004'
  on-primary-fixed-variant: '#930012'
  secondary-fixed: '#e3e2e0'
  secondary-fixed-dim: '#c7c6c5'
  on-secondary-fixed: '#1a1c1b'
  on-secondary-fixed-variant: '#464746'
  tertiary-fixed: '#e2e2e2'
  tertiary-fixed-dim: '#c6c6c7'
  on-tertiary-fixed: '#1a1c1c'
  on-tertiary-fixed-variant: '#454747'
  background: '#fcf9f8'
  on-background: '#1c1b1b'
  surface-variant: '#e5e2e1'
  surface-warm: '#FAF9F7'
  text-muted: '#5F5F5F'
  border-subtle: '#EEEEEE'
  overlay-scrim: rgba(0, 0, 0, 0.4)
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 30px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  margin-mobile: 16px
  margin-tablet: 24px
  gutter: 12px
  stack-sm: 4px
  stack-md: 12px
  stack-lg: 24px
  section-gap: 32px
---

## Brand & Style

The design system is centered on the concept of "Visual Storytelling for the Urban Explorer." It balances the warmth of a lifestyle magazine with the efficiency of a high-performance mobile utility. The brand personality is approachable, tasteful, and observant—acting as a quiet guide rather than a loud announcer.

The chosen style is **Minimalism with a Warm Humanist edge**. It draws inspiration from Pinterest’s content-first masonry layouts and the tactile clarity of modern lifestyle apps like Lemon8. By utilizing heavy whitespace, soft off-white backgrounds, and a single high-impact accent color, the UI recedes to let photography and user-generated content take center stage. The aesthetic is "realistic premium"—avoiding over-the-top digital effects in favor of professional, mobile-native patterns that feel immediately familiar and trustworthy.

## Colors

The palette is anchored by a **Pinterest-inspired warm red**, used strategically for primary actions, saved states, and brand touchpoints. This red is vibrant but grounded, designed to evoke passion and appetite without causing visual fatigue.

The background uses a **soft off-white (`#F9F8F6`)** rather than pure white to reduce eye strain and provide a more "analog" paper-like feel that complements food and interior photography. Text follows a strict hierarchy using a **deep charcoal (`#111111`)** for maximum legibility and a **muted gray (`#5F5F5F`)** for secondary metadata and descriptions. Success, warning, and error states should be handled with low-saturation versions of their respective hues to maintain the calm, minimalist atmosphere.

## Typography

This design system utilizes **Plus Jakarta Sans** as the primary typeface. Its soft, rounded terminals and modern geometric construction perfectly mirror the "friendly yet professional" brand voice. It performs exceptionally well on mobile screens, maintaining high legibility even in dense descriptions.

**Inter** is introduced for labels and small utility text. Its systematic, neutral nature provides a clear functional distinction from the more expressive Plus Jakarta Sans, making it ideal for category tags, timestamps, and button labels. 

The type scale is optimized for a content-heavy mobile experience:
- **Headlines** use tighter letter-spacing and heavier weights to create strong visual anchors.
- **Body text** utilizes a generous line-height (1.5x) to ensure reviews and descriptions feel breathable.
- **Mobile optimization:** Headline-xl and Headline-lg scale down by 15% on small devices (under 360px width) to prevent awkward word breaks.

## Layout & Spacing

The layout philosophy follows a **Fluid Content Grid** specifically optimized for one-handed mobile usage. The system relies on a 4-column grid for mobile and an 8-column grid for tablets.

**Key Layout Rules:**
- **Safe Zones:** A standard 16px lateral margin is maintained across all screens to ensure content doesn't bleed into device edges.
- **The "Thumb Zone":** Critical actions (Save, Add, Primary Navigation) are placed within the bottom 40% of the screen.
- **Pinterest-Style Feed:** The home feed utilizes a staggered two-column masonry layout where card heights are dictated by image aspect ratios (restricted to 4:5 or 1:1 for consistency).
- **Vertical Rhythm:** Spacing follows an 8px base unit. Small clusters (image + caption) use 4px or 8px; distinct sections (Map + List) use 24px or 32px.

## Elevation & Depth

To maintain the "Warm Minimalist" aesthetic, this design system avoids heavy drop shadows and instead uses **Tonal Layering** and **Soft Ambient Occlusion**.

- **Level 0 (Base):** The `surface-warm` off-white background.
- **Level 1 (Cards):** Pure white cards with a very soft, diffused shadow (Blur: 12px, Y: 4px, Opacity: 4% Black). This makes the cards appear to "float" slightly above the warm background without creating visual clutter.
- **Level 2 (Navigation/Modals):** Bottom sheets and navigation bars use the same white surface but with a subtle `border-subtle` top stroke (1px) and a slightly deeper shadow (Blur: 20px, Y: -2px, Opacity: 6% Black) to indicate they are "above" the main content.
- **Interactive States:** Buttons do not use elevation to indicate "press." Instead, they use a subtle scale-down effect (98%) and a slight darkening of the fill color.

## Shapes

The shape language is defined by **organic, approachable geometry**. 

- **Primary Cards:** Use the `rounded-lg` (16px) setting to create a friendly, modern container for photography.
- **Buttons and Inputs:** Use a consistent 12px radius, providing a tactile "squircle" feel that is comfortable for tap targets.
- **Chips & Tags:** Use a fully rounded "pill" shape to distinguish them from interactive buttons.
- **Images:** All thumbnails must inherit the border radius of their parent container. In detail views, the "Hero Image" uses a bottom-only radius of 24px to lead the eye down into the content.

## Components

### Buttons
- **Primary:** Warm Red background, white text, 12px radius. High emphasis.
- **Secondary:** Transparent background with a `border-subtle`, dark gray text. Used for "Cancel" or "View All."
- **Floating Action Button (FAB):** Circular, Warm Red, with a white icon. Positioned at the bottom right for "Add Hidden Spot."

### Cards
- **Feed Card:** Full-bleed image at the top, 12px padding for the text area below. The "Save" button (heart icon) is positioned as an overlay in the top right corner of the image with a subtle glass circle background.

### Input Fields
- **Search Bar:** Subtle off-white fill (slightly darker than the background), no border, 12px radius. Left-aligned search icon in `text-muted`.
- **Form Fields:** 1px `border-subtle` that turns `primary-red` on focus. Labels are always visible above the field in `label-md` style.

### Chips & Tags
- **Category Tags:** `surface-warm` background with `text-muted` color. Small, pill-shaped, used for "Coffee," "Quiet," "Late Night."

### Lists
- **Place List:** Horizontal scrolling "carousels" for categories on the Home Feed, and vertical lists with `border-subtle` separators for "Saved Places."

### Navigation
- **Bottom Bar:** 4-icon layout (Home, Map, Saved, Profile). Active state uses `primary-red` for the icon; inactive uses `text-muted`. No text labels to keep the UI clean.