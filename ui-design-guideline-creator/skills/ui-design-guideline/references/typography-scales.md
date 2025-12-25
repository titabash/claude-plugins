# Typography Scales Best Practices

## Font Family

### Default Font (Recommended)

#### Japanese Projects (Default)
Use Noto Sans JP as the default font for Japanese projects:

```css
font-family: "Noto Sans JP", -apple-system, BlinkMacSystemFont, "Segoe UI",
             Roboto, "Helvetica Neue", Arial, sans-serif;
```

Google Fonts import:
```html
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;700&display=swap" rel="stylesheet">
```

#### English/International Projects
```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
             "Helvetica Neue", Arial, "Noto Sans", sans-serif,
             "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol",
             "Noto Color Emoji";
```

#### System Font Stack (Fallback)
```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
             "Helvetica Neue", Arial, "Hiragino Kaku Gothic ProN",
             "Hiragino Sans", Meiryo, sans-serif;
```

#### Serif
```css
font-family: Georgia, Cambria, "Times New Roman", Times, serif;
```

#### Monospace
```css
font-family: Menlo, Monaco, Consolas, "Liberation Mono",
             "Courier New", monospace;
```

## Font Size Scale

### Modular Scale (1.25 ratio)
Mathematically harmonious scale:

```
xs:   0.64rem  (10.24px @ 16px base)
sm:   0.8rem   (12.8px)
base: 1rem     (16px) ← Base size
lg:   1.25rem  (20px)
xl:   1.563rem (25px)
2xl:  1.953rem (31.25px)
3xl:  2.441rem (39px)
4xl:  3.052rem (48.8px)
5xl:  3.815rem (61px)
6xl:  4.768rem (76px)
```

### Heading Sizes
```
H1: 2.441rem (3xl) - Most important heading
H2: 1.953rem (2xl) - Section heading
H3: 1.563rem (xl)  - Subsection heading
H4: 1.25rem  (lg)  - Small heading
H5: 1rem     (base)- Emphasized text
H6: 0.8rem   (sm)  - Smallest heading
```

### Body Text
```
body-lg:   1.125rem (18px) - Readability focused
body-base: 1rem     (16px) - Standard
body-sm:   0.875rem (14px) - Compact
caption:   0.75rem  (12px) - Captions, labels
```

## Line Height

### Basic Principles
- **Headings**: 1.2-1.4 (tight layout)
- **Body**: 1.5-1.75 (readability focused)
- **Captions**: 1.4-1.5 (balanced)

### Specific Values
```css
leading-tight:  1.25  /* For headings */
leading-snug:   1.375
leading-normal: 1.5   /* Body default */
leading-relaxed: 1.625
leading-loose:  2     /* Spacious layout */
```

## Font Weight

### Recommended Weights
```
thin:       100
extralight: 200
light:      300
normal:     400  ← Body default
medium:     500
semibold:   600  ← Headings, emphasis
bold:       700
extrabold:  800
black:      900
```

### Usage Guidelines
- **Body**: 400 (normal)
- **Emphasis**: 500-600 (medium-semibold)
- **Headings**: 600-700 (semibold-bold)
- **Strong emphasis**: 800-900 (extrabold-black)

## Letter Spacing

### Tracking
```css
tracking-tighter: -0.05em  /* For large headings */
tracking-tight:   -0.025em
tracking-normal:  0        /* Default */
tracking-wide:    0.025em  /* For small text */
tracking-wider:   0.05em
tracking-widest:  0.1em    /* For uppercase */
```

### Usage Examples
- Large headings (H1-H2): `tracking-tight`
- Normal text: `tracking-normal`
- Small text, labels: `tracking-wide`
- Uppercase text: `tracking-wider` to `tracking-widest`

## Responsive Typography

### Fluid Typography
Smoothly scales with screen size:

```css
/* H1 example */
font-size: clamp(2rem, 5vw, 3.815rem);

/* Body example */
font-size: clamp(1rem, 2.5vw, 1.125rem);
```

### By Breakpoint
```css
/* Mobile */
h1 { font-size: 1.953rem; }

/* Tablet (768px+) */
@media (min-width: 768px) {
  h1 { font-size: 2.441rem; }
}

/* Desktop (1024px+) */
@media (min-width: 1024px) {
  h1 { font-size: 3.052rem; }
}
```

## Text Colors

### Hierarchical Color Intensity
```
text-primary:   gray-900 (most important, headings)
text-secondary: gray-700 (body)
text-tertiary:  gray-500 (supplementary info)
text-disabled:  gray-400 (disabled state)
```

## Accessibility

### Minimum Sizes
- **Body**: 16px or larger recommended
- **Captions**: Avoid below 12px
- **Text in touch targets**: 14px or larger

### Contrast
- See color-systems.md

## Reference Design Systems
- **Material Design**: Comprehensive typography system
- **Tailwind CSS**: Practical scales and utilities
- **IBM Carbon**: Good example for enterprise typography
- **Apple Human Interface Guidelines**: Mobile typography
