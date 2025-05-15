[![pub package](https://img.shields.io/pub/v/flutter_hypertext.svg)](https://pub.dartlang.org/packages/flutter_hypertext)
[![GitHub stars](https://img.shields.io/github/stars/fingerart/flutter_hypertext)](https://github.com/fingerart/flutter_hypertext/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fingerart/flutter_hypertext)](https://github.com/fingerart/flutter_hypertext/network)
[![GitHub license](https://img.shields.io/github/license/fingerart/flutter_hypertext)](https://github.com/fingerart/flutter_hypertext/blob/main/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/fingerart/flutter_hypertext)](https://github.com/fingerart/flutter_hypertext/issues)

Language: English | [中文](./README_zh.md)

<br/>

Hypertext is a highly extensible rich text widget that automatically parses styles.

## Preview

View [online demo](https://fingerart.github.io/flutter_hypertext)

| EN                                                                                          | ZH                                                                                          |
|---------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| ![](https://raw.githubusercontent.com/fingerart/flutter_hypertext/main/arts/preview_en.png) | ![](https://raw.githubusercontent.com/fingerart/flutter_hypertext/main/arts/preview_zh.png) |


## Features

1. Built-in support for common [HTML-like tags](#predefined-markup-tags), such as:

    * Links (with tap and long-press events)
    * Images
    * Text styles: *italic*, **bold**, ~~strikethrough~~, underline, text color, gradients, etc.
    * ...
2. Event handling support
3. Custom markup support
4. Customizable color name mapping to easily support multi-theme scenarios
5. Text style inheritance for `WidgetSpan`'s inner `child`

## Table of contents

<!-- TOC -->
  * [Preview](#preview)
  * [Features](#features)
  * [Table of contents](#table-of-contents)
  * [Getting Started](#getting-started)
    * [Supported Parameters](#supported-parameters)
    * [Custom Markups](#custom-markups)
  * [Use Cases](#use-cases)
  * [Predefined Markup Tags](#predefined-markup-tags)
    * [1) LinkMarkup](#1-linkmarkup)
    * [2) StyleMarkup](#2-stylemarkup)
      * [1. FontWeightMarkup](#1-fontweightmarkup)
      * [2. BoldMarkup](#2-boldmarkup)
      * [3. FontStyleMarkup](#3-fontstylemarkup)
      * [4. ItalicMarkup](#4-italicmarkup)
      * [5. TextDecorationMarkup](#5-textdecorationmarkup)
      * [6. DelMarkup](#6-delmarkup)
      * [7. UnderlineMarkup](#7-underlinemarkup)
      * [8. ColorMarkup](#8-colormarkup)
      * [9. SizeMarkup](#9-sizemarkup)
    * [4) GradientMarkup](#4-gradientmarkup)
    * [5) ImageMarkup](#5-imagemarkup)
    * [6) GapMarkup](#6-gapmarkup)
    * [7) PaddingMarkup](#7-paddingmarkup)
  * [Special Notes](#special-notes)
    * [Color Names](#color-names)
    * [Hex Colors](#hex-colors)
    * [Margin Values](#margin-values)
  * [Things to Keep in Mind](#things-to-keep-in-mind)
  * [TODO](#todo)
<!-- TOC -->

## Getting Started

```yaml
dependencies:
  flutter_hypertext: ^0.0.1+8
```

```dart
import 'package:flutter_hypertext/markup.dart';

Hypertext("Hello <color=red>Hypertext</color>")
```

### Supported Parameters

| Parameter              | Default           | Description                                      |
|------------------------|-------------------|--------------------------------------------------|
| `onMarkupEvent`        |                   | Receive events like `a`                          |
| `lowercaseAttrName`    | `true`            | Convert attribute names to lowercase             |
| `lowercaseElementName` | `true`            | Convert element names to lowercase               |
| `ignoreErrorMarkup`    | `false`           | Ignore erroneous tags                            |
| `colorMapper`          | `kBasicCSSColors` | Color name mapping (default is CSS basic colors) |
| `markups`              | `kDefaultMarkups` | Supported markup tags                            |

> Global default configuration can be set via `HypertextThemeExtension`

### Custom Markups

**Defining a Custom Markup:**

```dart
class CustomMarkup extends TagMarkup {
  const CustomMarkup() : super('your-tag');

  @override
  HypertextSpan onMarkup(List<HypertextSpan>? children, MarkupContext ctx) {
    return HypertextTextSpan(children: children, style: TextStyle());
    return HypertextWidgetSpan(child: child);
  }
}
```

**Setting Custom Markup:**

```dart
Hypertext(
    text,
    markups: [...kDefaultMarkups, CustomMarkup()],
)
```

Or

```dart
ThemeData(
  extensions: [HypertextThemeExtension(markups: [...kDefaultMarkups, CustomMarkup()])],
)
```

## Use Cases

1. Rich text in multiple languages
2. Rich text with multiple themes
3. Highlighting keywords (search, mentions, topics...)

## Predefined Markup Tags

### 1) LinkMarkup

Marks a range as a hyperlink, specifically for adding click events.

**Tag Name: `a`**

Parameters:

| Parameter    | Value                                 | Required | Description                                  |
|--------------|---------------------------------------|----------|----------------------------------------------|
| `href`       | URI string                            | ✅        | URI                                          |
| `tap`        | -                                     | ☑️       | Handle click (can also specify `long-press`) |
| `long-press` | -                                     | ☑️       | Handle long press (can also specify `tap`)   |
| `title`      | String                                | ☑️       | Tooltip content                              |
| `cursor`     | `basic` `click` `text` `defer`...     | ☑️       | See [SystemMouseCursors]                     |
| `alignment`  | `baseline` `middle` `top` `bottom`... | ☑️       | See [PlaceholderAlignment]                   |
| `baseline`   | `alphabetic` `ideographic`            | ☑️       | See [TextBaseline]                           |

Example:

```html
<a href="https://example.com">go</a>
<a href="app://op" custom-attr=foo title="User Foo" long-press tap>foo</a> <!-- Supports both tap and long-press -->
```

```dart
Hypertext(
    text,
    onMarkupEvent: (MarkupEvent event){
      // event.tag
      // event.data
    },
);
```

### 2) StyleMarkup

Sets text styles for a specified range, such as text color, background color, font size, font family, font weight, italic, text decorations (underline, overline, strikethrough)...

**Tag: `style`**

Parameters:

| Parameter     | Value                                                  | Required | Description                                                                                                             |
|---------------|--------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------------------------|
| `color`       | [Hex Color](#hex-colors) or [Color Name](#color-names) | ☑️       | Text color, default supports [CSS Basic Colors](https://www.w3.org/wiki/CSS/Properties/color/keywords)[kBasicCSSColors] |
| `background`  | [Hex Color](#hex-colors) or [Color Name](#color-names) | ☑️       | Text background color                                                                                                   |
| `size`        | double                                                 | ☑️       | Text size                                                                                                               |
| `font-family` | font family name                                       | ☑️       | Font family                                                                                                             |
| `weight`      | `100`~`900`、`bold`、`normal`                            | ☑️       | See [FontWeight]                                                                                                        |
| `font-style`  | `normal` `italic`                                      | ☑️       | Font style [FontStyle]                                                                                                  |
| `decor`       | `none` `underline` `overline` `lineThrough`            | ☑️       | Text decoration [TextDecoration]                                                                                        |
| `decor-style` | `double` `dashed` `dotted` `solid` `wavy`              | ☑️       | Decoration style [TextDecorationStyle]                                                                                  |
| `decor-color` | [Hex Color](#hex-colors) or [Color Name](#color-names) | ☑️       | Decoration color                                                                                                        |
| `thickness`   | double                                                 | ☑️       | Decoration line thickness                                                                                               |

Example:

```html
<style color=red background=white size=20 weight=900>hypertext</style>
<style decor=underline decor-color=#F00 thickness=2>hypertext</style>
```

**`StyleMarkup` is a superset of the following tags:**

#### 1. FontWeightMarkup

Tag: `weight`

| Parameter           | Value                       | Required | Description      |
|---------------------|-----------------------------|----------|------------------|
| `weight` (simplify) | `100`~`900`、`bold`、`normal` | ✅️       | See [FontWeight] |

Example:

```html
<weight=500>foo</weight>
<weight weight=100>bar</weight>
```

#### 2. BoldMarkup

Tags: `b` `bold` `strong`

| Parameter           | Value                       | Required | Description      |
|---------------------|-----------------------------|----------|------------------|
| `weight` (simplify) | `100`~`900`、`bold`、`normal` | ✅️       | See [FontWeight] |

```html
<b>Hypertext</b>
<bold=900>Hypertext</bold>
<strong weight=100>Hypertext</strong>
```

#### 3. FontStyleMarkup

Tag: `font-style`

| Parameter               | Value             | Required | Description      |
|-------------------------|-------------------|----------|------------------|
| `font-style` (simplify) | `normal` `italic` | ✅        | See [FontWeight] |

Example:

```html
<font-style=italic>foo</font-style>
<font-style font-style=normal>bar</font-style>
```

#### 4. ItalicMarkup

Tag: `i`

Example:

```html
<i>bar</i>
```

#### 5. TextDecorationMarkup

Tag: `text-decor`

| Parameter          | Value                                                  | Required | Description                            |
|--------------------|--------------------------------------------------------|----------|----------------------------------------|
| `decor` (simplify) | `none` `underline` `overline` `lineThrough`            | ✅        | Text decoration [TextDecoration]       |
| `style`            | `double` `dashed` `dotted` `solid` `wavy`              | ☑️       | Decoration style [TextDecorationStyle] |
| `color`            | [Hex Color](#hex-colors) or [Color Name](#color-names) | ☑️       | Decoration color                       |
| `thickness`        | double                                                 | ☑️       | Decoration line thickness              |

Example:

```html
<text-decor=underline style=dotted>foo</text-decor>
<text-decor decor=lineThrough color=red thickness=2>bar</text-decor>
```

#### 6. DelMarkup

Tag: `del`

| Parameter   | Value                                                  | Required | Description                            |
|-------------|--------------------------------------------------------|----------|----------------------------------------|
| `style`     | `double` `dashed` `dotted` `solid` `wavy`              | ☑️       | Decoration style [TextDecorationStyle] |
| `color`     | [Hex Color](#hex-colors) or [Color Name](#color-names) | ☑️       | Decoration color                       |
| `thickness` | double                                                 | ☑️       | Decoration line thickness              |

Example:

```html
<del color=red>bar</del>
```

#### 7. UnderlineMarkup

Tag: `u` `ins`

| Parameter   | Value                                                  | Required | Description                            |
|-------------|--------------------------------------------------------|----------|----------------------------------------|
| `style`     | `double` `dashed` `dotted` `solid` `wavy`              | ☑️       | Decoration style [TextDecorationStyle] |
| `color`     | [Hex Color](#hex-colors) or [Color Name](#color-names) | ☑️       | Decoration color                       |
| `thickness` | double                                                 | ☑️       | Decoration line thickness              |

Example:

```html
<u style=wavy>bar</u>
```

#### 8. ColorMarkup

Tag: `color`

Parameters:

| Parameter          | Value                                                  | Required | Description |
|--------------------|--------------------------------------------------------|----------|-------------|
| `color` (simplify) | [Hex Color](#hex-colors) or [Color Name](#color-names) | ✅        | Text color  |

Example:

```html
<color=red>bar</color>
<color color=#FF0>bar</color>
```

#### 9. SizeMarkup

Tag: `size`

Parameters:

| Parameter         | Value  | Required | Description |
|-------------------|--------|----------|-------------|
| `size` (simplify) | double | ✅        | Text size   |

Example:

```html
<size=red>bar</size>
<size color=#FF0>bar</size>
```

### 4) GradientMarkup

Sets a linear gradient for the specified range of text.

Tag: `gradient`

Parameters:

| Parameter   | Value                                                  | Required | Description                                                    |
|-------------|--------------------------------------------------------|----------|----------------------------------------------------------------|
| `colors`    | [Hex Color](#hex-colors) or [Color Name](#color-names) | ✅        | Gradient colors                                                |
| `stops`     | List<double>                                           | ☑️       | Values between 0.0 and 1.0 for gradient stops [LinearGradient] |
| `rotation`  | Angle (0~360)                                          | ☑️       | Rotation angle for gradient                                    |
| `tile-mode` | `clamp` (default) `repeated` `mirror` `decal`          | ☑️       | Tiling mode                                                    |
| `alignment` | `baseline` `middle` `top` `bottom`...                  | ☑️       | See [PlaceholderAlignment]                                     |
| `baseline`  | `alphabetic` `ideographic`                             | ☑️       | See [TextBaseline]                                             |

Example:

```html
<gradient colors="red, green" rotation=45>bar</gradient>
<gradient colors="#F00,#00F" rotation=45>bar</gradient>
```

### 5) ImageMarkup

Add image, support custom parsing `src` and creating image widgets through `imageBuilder`.

> [Note] The default implementation of network image is `NetworkImage`, which does not support disk
> caching. If necessary, please use `ImageMarkup.imagebuilder`.

Tag: `img` `image`

Parameters:

| Parameter   | Value                                                              | Required | Description                                            |
|-------------|--------------------------------------------------------------------|----------|--------------------------------------------------------|
| `src`       | URI string                                                         | ✅        | Image path (supports `http[s]://`, `asset://`, `path`) |
| `size`      | List\<double\>                                                     | ☑️       | Image width and height (1~2 values)                    |
| `width`     | double                                                             | ☑️       | Image width                                            |
| `height`    | double                                                             | ☑️       | Image height                                           |
| `fit`       | `fill` `contain` `cover` `fitWidth` `fitHeight` `none` `scaleDown` | ☑️       | BoxFit modes                                           |
| `align`     | `topLeft` `center` `bottomLeft`...                                 | ☑️       | Alignment options                                      |
| `alignment` | `baseline` `middle` `top` `bottom`...                              | ☑️       | See [PlaceholderAlignment]                             |
| `baseline`  | `alphabetic` `ideographic`                                         | ☑️       | See [TextBaseline]                                     |

Example:

```html
<img src="https://example.com/avatar.png" size=50 fit=cover/>
<img src="asset://images/icon.png" size="50,100"/>
<img src="path/to/icon.png" width="50" height="50"/> <!--File path-->
```

### 6) GapMarkup

Adds space gaps.

Tag: `gap`

Parameters:

| Parameter        | Value  | Required | Description |
|------------------|--------|----------|-------------|
| `gap` (simplify) | double | ✅        | Gap size    |

Example:

```html
<gap=10 />
<gap gap="50"/>
```

### 7) PaddingMarkup

Adds padding inside an element.

Tag: `padding`

Parameters:

| Parameter            | Value                                 | Required | Description                                  |
|----------------------|---------------------------------------|----------|----------------------------------------------|
| `padding` (simplify) | double                                | ✅        | [Padding value](#margin-values) (1~4 values) |
| `hor`                | List\<double\>                        | ☑️       | Horizontal padding (1~2 values)              |
| `ver`                | List\<double\>                        | ☑️       | Vertical padding (1~2 values)                |
| `alignment`          | `baseline` `middle` `top` `bottom`... | ☑️       | See [PlaceholderAlignment]                   |
| `baseline`           | `alphabetic` `ideographic`            | ☑️       | See [TextBaseline]                           |

Example:

```html
<padding="10, 20">foo</padding> <!-- Set top/bottom padding to 10, left/right padding to 20 -->
<padding padding="50"/> <!-- Set all padding to 50 -->
<padding hor="10, 20"/> <!-- Set left padding to 10, right padding to 20 -->
<padding ver="20"/> <!-- Set vertical padding to 20 -->
```

## Special Notes

### Color Names

By default, [CSS Basic Colors](https://www.w3.org/wiki/CSS/Properties/color/keywords)[kBasicCSSColors] are supported. You can customize color name mappings via `Hypertext.colorMapper` and `HypertextThemeExtension.colorMapper`.

### Hex Colors

Supports the following [formats](https://developer.mozilla.org/en-US/docs/Web/CSS/hex-color#syntax):

1. **RGB**, e.g., `#0F0`
2. **RGBA**, e.g., `#0F0F`
3. **RRGGBB**, e.g., `#00FF00`
4. **RRGGBBAA**, e.g., `#00FF00FF`

### Margin Values

Supports the following formats:

1. `10` → `left=10 top=10 right=10 bottom=10`
2. `10, 20` → `left=20 top=10 right=20 bottom=10`
3. `10, 20, 30` → `left=20 top=10 right=20 bottom=30`
4. `10, 20, 30, 40` → `left=10 top=20 right=30 bottom=40`

## Things to Keep in Mind

1. When customizing Markups, it is recommended to use `HypertextTextSpan` or `HypertextWidgetSpan` to help inherit styles from parent `WidgetSpan` for text within it.

## TODO

- ☑️ Improve selectability: Add built-in selectability options and pass selectability to `WidgetSpan`.
