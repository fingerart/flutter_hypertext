[![pub package](https://img.shields.io/pub/v/flutter_hypertext.svg)](https://pub.dartlang.org/packages/flutter_hypertext)
[![GitHub stars](https://img.shields.io/github/stars/fingerart/flutter_hypertext)](https://github.com/fingerart/flutter_hypertext/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fingerart/flutter_hypertext)](https://github.com/fingerart/flutter_hypertext/network)
[![GitHub license](https://img.shields.io/github/license/fingerart/flutter_hypertext)](https://github.com/fingerart/flutter_hypertext/blob/main/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/fingerart/flutter_hypertext)](https://github.com/fingerart/flutter_hypertext/issues)

语言: [English](./README.md) | 中文简体

<br/>

Hypertext是一个可自动解析样式的高扩展性富文本组件。

## 预览

查看[在线演示](https://fingerart.github.io/flutter_hypertext)

| EN                                                                                          | ZH                                                                                          |
|---------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| ![](https://raw.githubusercontent.com/fingerart/flutter_hypertext/main/arts/preview_en.png) | ![](https://raw.githubusercontent.com/fingerart/flutter_hypertext/main/arts/preview_zh.png) |

## 特性

1. 内置常用的[类HTML标记](#预置标记列表)
    
    * 链接（点击、长按）
    * 图片
    * 文本样式（*斜体*、**粗体**、~~删除线~~、下划线、颜色、渐变）
    * ...
2. 支持事件处理
3. 自定义标记
4. 自定义颜色名称映射，轻松应对多主题场景
5. 文本样式遗传给`WidgetSpan`内部`child`

## 目录

<!-- TOC -->
  * [预览](#预览)
  * [特性](#特性)
  * [目录](#目录)
  * [开始使用](#开始使用)
    * [支持参数](#支持参数)
    * [自定义标记](#自定义标记)
  * [场景](#场景)
  * [预置标记列表](#预置标记列表)
    * [1）LinkMarkup](#1linkmarkup)
    * [2）StyleMarkup](#2stylemarkup)
      * [1. FontWeightMarkup](#1-fontweightmarkup)
      * [2. BoldMarkup](#2-boldmarkup)
      * [3. FontStyleMarkup](#3-fontstylemarkup)
      * [4. ItalicMarkup](#4-italicmarkup)
      * [5. TextDecorationMarkup](#5-textdecorationmarkup)
      * [6. DelMarkup](#6-delmarkup)
      * [7. UnderlineMarkup](#7-underlinemarkup)
      * [8. ColorMarkup](#8-colormarkup)
      * [9. SizeMarkup](#9-sizemarkup)
    * [4）GradientMarkup](#4gradientmarkup)
    * [5）ImageMarkup](#5imagemarkup)
    * [5）GapMarkup](#5gapmarkup)
    * [5）PaddingMarkup](#5paddingmarkup)
  * [特别说明](#特别说明)
    * [颜色名称](#颜色名称)
    * [十六进制颜色](#十六进制颜色)
    * [边距值](#边距值)
  * [需要注意的事项](#需要注意的事项)
  * [TODO](#todo)
<!-- TOC -->

## 开始使用

```yaml
dependencies:
  flutter_hypertext: ^0.0.1+6
```

```dart
import 'package:flutter_hypertext/markup.dart';

Hypertext("Hello <color=red>Hypertext</color>")
```

### 支持参数

| 参数                     | 默认                | 说明               |
|------------------------|-------------------|------------------|
| `onMarkupEvent`        |                   | 接收事件，比如`a`       |
| `lowercaseAttrName`    | `true`            | 属性名称转换为小写        |
| `lowercaseElementName` | `true`            | 元素名称转换为小写        |
| `ignoreErrorMarkup`    | `false`           | 屏蔽错误的标签          |
| `colorMapper`          | `kBasicCSSColors` | 颜色名称映射（默认CSS基础色） |
| `markups`              | `kDefaultMarkups` | 支持的标记集合          |

> 可通过`HypertextThemeExtension`设置全局默认配置

### 自定义标记

**定义标记：**
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

**设置标记：**

```dart
Hypertext(
    text,
    markups: [...kDefaultMarkups, CustomMarkup()],
)
```

或者

```dart
ThemeData(
  extensions: [HypertextThemeExtension(markups: [...kDefaultMarkups, CustomMarkup()])],
)
```

## 场景

1. 多语言下的富文本
2. 多主题下的富文本
3. 高亮关键字（搜索、提及、话题……）

## 预置标记列表

### 1）LinkMarkup

标记指定范围为超链接，专用于添加点击事件。

**标签名：`a`**

参数：

| 参数名          | 值                                     | 必选 | 说明                       |
|--------------|---------------------------------------|:---|:-------------------------|
| `href`       | string                                | ✅  | URI                      |
| `tap`        | -                                     | ☑️ | 处理单击（可同时指定`long-press`）  |
| `long-press` | -                                     | ☑️ | 处理长按（可同时指定`tap`）         |
| `title`      | string                                | ☑️ | 提示内容                     |
| `cursor`     | `basic` `click` `text` `defer`...     | ☑️ | 参见[SystemMouseCursors]   |
| `alignment`  | `baseline` `middle` `top` `bottom`... | ☑️ | 参见[PlaceholderAlignment] |
| `baseline`   | `alphabetic` `ideographic`            | ☑️ | 参见[TextBaseline]         |

示例：

```html
<a href="https://example.com">go</a>
<a href="app://op" custom-attr=foo title="User Foo" long-press tap>foo</a> <!--同时支持tap和long-press-->
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

### 2）StyleMarkup

为指定范围设置文本样式，如：文本颜色、背景色、文本大小、字体、文本粗细、斜体、文本装饰（下划线、上划线、波浪线）...

**标签：`style`**

参数：

| 参数名           | 值                                           | 必选 | 说明                                                                                           |
|---------------|---------------------------------------------|----|----------------------------------------------------------------------------------------------|
| `color`       | [十六进制颜色](#十六进制颜色) 或 [颜色名](#颜色名称)            | ☑️ | 文本颜色，颜色名默认支持[CSS基本色](https://www.w3.org/wiki/CSS/Properties/color/keywords)[kBasicCSSColors] |
| `background`  | [十六进制颜色](#十六进制颜色) 或 [颜色名](#颜色名称)            | ☑️ | 文本背景色                                                                                        |
| `size`        | double                                      | ☑️ | 文本大小                                                                                         |
| `font-family` | font family name                            | ☑️ | 文本字体                                                                                         |
| `weight`      | `100`~`900`                                 | ☑️ | 参见[FontWeight]                                                                               |
| `font-style`  | `nomal` `italic`                            | ☑️ | 文本斜体类型[FontStyle]                                                                            |
| `decor`       | `none` `underline` `overline` `lineThrough` | ☑️ | 装饰线条[TextDecoration]                                                                         |
| `decor-style` | `double` `dashed` `dotted` `solid` `wavy`   | ☑️ | 装饰线条类型[TextDecorationStyle]                                                                  |
| `decor-color` | [十六进制颜色](#十六进制颜色) 或 [颜色名](#颜色名称)            | ☑️ | 装饰线条颜色                                                                                       |
| `thickness`   | double                                      | ☑️ | 装饰线条厚度                                                                                       |

示例：

```html
<style color=red background=white size=20 weight=900>hypertext</style>
<style decor=underline decor-color=#F00 thickness=2>hypertext</style>
```

**`StyleMarkup`是以下标记的超集：**

#### 1. FontWeightMarkup

标签：`weight`

| 参数名            | 值           | 必选 | 说明             |
|----------------|:------------|----|----------------|
| `weight`(支持简化) | `100`~`900` | ✅️ | 参见[FontWeight] |

示例：

```html
<weight=500>foo</weight>
<weight weight=100>bar</weight>
```

#### 2. BoldMarkup

标签：`b` `bold` `strong`

| 参数名            | 值           | 必选 | 说明             |
|----------------|:------------|----|----------------|
| `weight`(支持简化) | `100`~`900` | ✅️ | 参见[FontWeight] |


```html
<b>Hypertext</b>
<bold=900>Hypertext</bold>
<strong weight=100>Hypertext</strong>
```

#### 3. FontStyleMarkup

标签：`font-style`

| 参数名                | 值                 | 必选 | 说明             |
|--------------------|:------------------|----|----------------|
| `font-style`(支持简化) | `normal` `italic` | ✅️ | 参见[FontWeight] |

示例：

```html
<font-style=italic>foo</font-style>
<font-style font-style=normal>bar</font-style>
```

#### 4. ItalicMarkup

标签：`i`

示例：

```html
<i>bar</i>
```

#### 5. TextDecorationMarkup

标签：`text-decor`

| 参数名           | 值                                           | 必选 | 说明                          |
|---------------|:--------------------------------------------|----|-----------------------------|
| `decor`(支持简化) | `none` `underline` `overline` `lineThrough` | ✅️ | 装饰线条[TextDecoration]        |
| `style`       | `double` `dashed` `dotted` `solid` `wavy`   | ☑️ | 装饰线条类型[TextDecorationStyle] |
| `color`       | [十六进制颜色](#十六进制颜色) 或 [颜色名](#颜色名称)            | ☑️ | 装饰线条颜色                      |
| `thickness`   | double                                      | ☑️ | 装饰线条厚度                      |

示例：

```html
<text-decor=underline style=dotted>foo</text-decor>
<text-decor decor=lineThrough color=red thickness=2>bar</text-decor>
```

#### 6. DelMarkup

标签：`del`

| 参数名           | 值                                           | 必选 | 说明                          |
|---------------|:--------------------------------------------|----|-----------------------------|
| `style`       | `double` `dashed` `dotted` `solid` `wavy`   | ☑️ | 装饰线条类型[TextDecorationStyle] |
| `color`       | [十六进制颜色](#十六进制颜色) 或 [颜色名](#颜色名称)            | ☑️ | 装饰线条颜色                      |
| `thickness`   | double                                      | ☑️ | 装饰线条厚度                      |

示例：

```html
<del color=red>bar</del>
```

#### 7. UnderlineMarkup

标签：`u` `ins`

| 参数名           | 值                                           | 必选 | 说明                          |
|---------------|:--------------------------------------------|----|-----------------------------|
| `style`       | `double` `dashed` `dotted` `solid` `wavy`   | ☑️ | 装饰线条类型[TextDecorationStyle] |
| `color`       | [十六进制颜色](#十六进制颜色) 或 [颜色名](#颜色名称)            | ☑️ | 装饰线条颜色                      |
| `thickness`   | double                                      | ☑️ | 装饰线条厚度                      |

示例：

```html
<u style=wavy>bar</u>
```

#### 8. ColorMarkup

标签：`color`

参数：

| 参数名           | 值                                | 必选 | 说明   |
|---------------|----------------------------------|----|------|
| `color`(支持简化) | [十六进制颜色](#十六进制颜色) 或 [颜色名](#颜色名称) | ✅️ | 文本颜色 |

示例：

```html
<color=red>bar</color>
<color color=#FF0>bar</color>
```

#### 9. SizeMarkup

标签：`size`

参数：

| 参数名          | 值      | 必选 | 说明   |
|--------------|--------|----|------|
| `size`(支持简化) | double | ✅️ | 文本颜色 |

示例：

```html
<size=red>bar</size>
<size color=#FF0>bar</size>
```

### 4）GradientMarkup

为指定范围文本设置线性渐变。

标签：`gradient`

参数：

| 参数名         | 值                                       | 必选 | 说明                                   |
|-------------|-----------------------------------------|----|--------------------------------------|
| `colors`    | [十六进制颜色](#十六进制颜色) 或 [颜色名](#颜色名称)        | ✅️ | 创建渐变的梯度颜色                            |
| `stops`     | List\<double\>                          | ☑️ | 从0.0到1.0的值列表表示沿渐变的分数[LinearGradient] |
| `rotation`  | 角度(0~360)                               | ☑️ | 对渐变进行旋转                              |
| `tile-mode` | `clamp`(默认) `repeated` `mirror` `decal` | ☑️ | 平铺模式                                 |
| `alignment` | `baseline` `middle` `top` `bottom`...   | ☑️ | 参见[PlaceholderAlignment]             |
| `baseline`  | `alphabetic` `ideographic`              | ☑️ | 参见[TextBaseline]                     |

示例：

```html
<gradient colors="red, green" rotation=45>bar</gradient>
<gradient colors="#F00,#00F" rotation=45>bar</gradient>
```

### 5）ImageMarkup

添加图片标记，支持通过`imageBuilder`以自定义解析`src`和创建图片Widget。

> 【注意】网络图片默认实现是`NetworkImage`，不支持磁盘缓存，如果需要请通过`ImageMarkup.imagebuilder`实现。

标签：`img` `image`

参数：

| 参数名         | 值                                                                  | 必选 | 说明                                      |
|-------------|--------------------------------------------------------------------|----|-----------------------------------------|
| `src`       | URI                                                                | ✅️ | 图片路径，默认支持`http[s]://`、`asset://`、`path` |
| `size`      | List\<double\>                                                     | ☑️ | 图片宽高，接受1~2个值，`size=20` `size="10,20"`   |
| `width`     | double                                                             | ☑️ | 图片宽                                     |
| `height`    | double                                                             | ☑️ | 图片高                                     |
| `fit`       | `fill` `contain` `cover` `fitWidth` `fitHeight` `none` `scaleDown` | ☑️ | 填充模式[BoxFit]                            |
| `align`     | `topLeft` `center` `bottomLeft`...                                 | ☑️ | 对齐方式[Alignment]                         |
| `alignment` | `baseline` `middle` `top` `bottom`...                              | ☑️ | 参见[PlaceholderAlignment]                |
| `baseline`  | `alphabetic` `ideographic`                                         | ☑️ | 参见[TextBaseline]                        |

示例：

```html
<img src="https://example.com/avatar.png" size=50 fit=cover/>
<img src="asset://images/icon.png" size="50,100"/>
<img src="path/to/icon.png" width="50" height="50"/> <!--文件路径-->
```

### 5）GapMarkup

添加空白间隙。

标签：`gap`

参数：

| 参数名         | 值      | 必选 | 说明   |
|-------------|--------|----|------|
| `gap`(支持简化) | double | ✅️ | 间隙大小 |

示例：

```html
<gap=10 />
<gap gap="50"/>
```

### 5）PaddingMarkup

添加空白内部边距。

标签：`padding`

参数：

| 参数名             | 值                                     | 必选 | 说明                       |
|-----------------|---------------------------------------|----|--------------------------|
| `padding`(支持简化) | double                                | ✅️ | [边距值](#边距值)，接受 1~4 个值    |
| `hor`           | List\<double\>                        | ☑️ | 水平边距，接受1~2个值             |
| `ver`           | List\<double\>                        | ☑️ | 垂直边距，接受1~2个值             |
| `alignment`     | `baseline` `middle` `top` `bottom`... | ☑️ | 参见[PlaceholderAlignment] |
| `baseline`      | `alphabetic` `ideographic`            | ☑️ | 参见[TextBaseline]         |

示例：

```html
<padding="10, 20" >foo</padding> <!--设置上下边距为10，左右边距为20-->
<padding padding="50"/> <!--设置上下左右边距都为50-->
<padding hor="10, 20"/> <!--设置左边距为10，右边距为20-->
<padding ver="20"/> <!--设置上下边距为20-->
```

## 特别说明

### 颜色名称

默认支持[CSS基本色](https://www.w3.org/wiki/CSS/Properties/color/keywords)[kBasicCSSColors]
，可通过`Hypertext.colorMapper`和`HypertextThemeExtension.colorMapper`设置颜色名映射表。

### 十六进制颜色

支持以下[形式](https://developer.mozilla.org/en-US/docs/Web/CSS/hex-color#syntax)：

1. **RGB**，如：`#0F0`
2. **RGBA**，如：`#0F0F`
3. **RRGGBB**，如：`#00FF00`
4. **RRGGBBAA**，如：`#00FF00FF`

### 边距值

支持以下形式：

1. `10` => `left=10 top=10 right=10 bottom=10`
2. `10, 20` => `left=20 top=10 right=20 bottom=10`
3. `10, 20, 30` => `left=20 top=10 right=20 bottom=30`
4. `10, 20, 30, 40` => `left=10 top=20 right=30 bottom=40`

## 需要注意的事项

1. 自定义Markup时，建议使用`HypertextTextSpan`、`HypertextWidgetSpan`，以帮助`WidgetSpan`内部的文本遗传父级的样式

## TODO

- ☑️ 完善可选择性：内置可选择性选项且传递可选择性到`WidgetSpan`中
