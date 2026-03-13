# Matugen 模板

这套模板会把 `matugen` 生成的配色写回 `modules/Theme/colors.js`，
这样 Quickshell 仍然只需要读取现有的 `Theme.colors.*` 接口。

## 用法

从仓库根目录执行：

```bash
matugen image /path/to/wallpaper -m dark -c modules/Theme/matugen/quickshell-colors.toml
```

或者直接用一个源色：

```bash
matugen color '#89b4fa' -m dark -c modules/Theme/matugen/quickshell-colors.toml
```

## 说明

- 模板文件：`modules/Theme/matugen/colors.template.js`
- 输出文件：`modules/Theme/colors.js`
- 圆角、尺寸、间距不走 matugen，仍然在 `modules/Theme/theme.js` 和相关样式文件里调。
- 现在整套 UI 的圆角统一跟 `Theme.uiRadius` 走；要整体更圆或更方，只改那一个值就行。
