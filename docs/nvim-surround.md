# nvim-surround 中文使用指南

nvim-surround 用于快速**添加**、**删除**、**修改**成对的符号（括号、引号、标签等）。

## 三个核心操作

| 操作 | 快捷键 | 记忆方式 |
|------|--------|----------|
| **添加** | `ys` | **y**ou **s**urround |
| **删除** | `ds` | **d**elete **s**urround |
| **修改** | `cs` | **c**hange **s**urround |

---

## 1️⃣ 添加包围符号 `ys{motion}{char}`

**格式**：`ys` + 动作 + 要添加的符号

| 操作 | 按键 | 结果 |
|------|------|------|
| 给单词加双引号 | `ysiw"` | `hello` → `"hello"` |
| 给单词加圆括号 | `ysiw)` | `hello` → `(hello)` |
| 给单词加圆括号(带空格) | `ysiw(` | `hello` → `( hello )` |
| 给到行尾加引号 | `ys$"` | `hello world` → `"hello world"` |
| 给整行加括号 | `yss)` | `hello` → `(hello)` |

**小技巧**：
- 左括号 `(` `[` `{` 会添加空格
- 右括号 `)` `]` `}` 不添加空格

---

## 2️⃣ 删除包围符号 `ds{char}`

**格式**：`ds` + 要删除的符号

| 操作 | 按键 | 结果 |
|------|------|------|
| 删除双引号 | `ds"` | `"hello"` → `hello` |
| 删除圆括号 | `ds)` | `(hello)` → `hello` |
| 删除方括号 | `ds]` | `[hello]` → `hello` |
| 删除 HTML 标签 | `dst` | `<div>hello</div>` → `hello` |

---

## 3️⃣ 修改包围符号 `cs{old}{new}`

**格式**：`cs` + 旧符号 + 新符号

| 操作 | 按键 | 结果 |
|------|------|------|
| 双引号改单引号 | `cs"'` | `"hello"` → `'hello'` |
| 圆括号改方括号 | `cs)]` | `(hello)` → `[hello]` |
| 引号改 HTML 标签 | `cs"<div>` | `"hello"` → `<div>hello</div>` |
| HTML 标签改引号 | `cst"` | `<div>hello</div>` → `"hello"` |

---

## 4️⃣ 可视模式添加 `S{char}`

1. 先用 `v` 选中文本
2. 按 `S` + 符号

| 操作 | 按键 | 结果 |
|------|------|------|
| 选中后加引号 | `viw` → `S"` | `hello` → `"hello"` |
| 选中后加括号 | `viw` → `S)` | `hello` → `(hello)` |

---

## 常用符号速查

| 符号 | 说明 |
|------|------|
| `"` `'` `` ` `` | 引号 |
| `)` `]` `}` `>` | 括号（无空格） |
| `(` `[` `{` | 括号（有空格） |
| `t` | HTML/XML 标签 |
| `<div>` | 指定 HTML 标签 |
| `f` | 函数调用，如 `print(x)` |

---

## 实战示例

```lua
-- 原始代码
hello

-- ysiw"  → 给 hello 加双引号
"hello"

-- cs"'   → 双引号改单引号
'hello'

-- ds'    → 删除单引号
hello

-- ysiw)  → 加圆括号
(hello)

-- cs)]   → 圆括号改方括号
[hello]

-- yss<div>  → 整行加 div 标签
<div>[hello]</div>
```

---

## 常用动作 (motion) 速查

Motion（动作）是 Vim 中描述**文本范围**的方式。在 `ys{motion}{char}` 中，motion 告诉 Neovim "要给哪些文本添加包围符号"。

### 基础 Motion

| 动作 | 说明 | 示例 |
|------|------|------|
| `iw` | 当前单词 (inner word) | `hello world` 光标在 hello → 选中 `hello` |
| `aw` | 当前单词含空格 (a word) | `hello world` → 选中 `hello ` |
| `iW` | 当前 WORD（空格分隔） | `hello-world foo` → 选中 `hello-world` |
| `aW` | 当前 WORD 含空格 | `hello-world foo` → 选中 `hello-world ` |
| `w` | 到下一个单词开头 | 从光标位置到下个词 |
| `e` | 到当前单词结尾 | 从光标位置到词尾 |
| `b` | 到单词开头（向后） | 从光标位置到词首 |
| `$` | 到行尾 | 从光标到行末 |
| `0` | 到行首 | 从光标到行首 |
| `s` | 整行 (用于 `yss`) | 特殊用法 |

### 文本对象 Motion

| 动作 | 说明 | 示例 |
|------|------|------|
| `i"` | 双引号内内容 | `"hello"` → 选中 `hello` |
| `a"` | 双引号内容含引号 | `"hello"` → 选中 `"hello"` |
| `i'` | 单引号内内容 | `'hello'` → 选中 `hello` |
| `a'` | 单引号内容含引号 | `'hello'` → 选中 `'hello'` |
| `` i` `` | 反引号内内容 | `` `hello` `` → 选中 `hello` |
| `i)` / `ib` | 圆括号内内容 | `(hello)` → 选中 `hello` |
| `a)` / `ab` | 圆括号内容含括号 | `(hello)` → 选中 `(hello)` |
| `i]` | 方括号内内容 | `[hello]` → 选中 `hello` |
| `a]` | 方括号内容含括号 | `[hello]` → 选中 `[hello]` |
| `i}` / `iB` | 花括号内内容 | `{hello}` → 选中 `hello` |
| `a}` / `aB` | 花括号内容含括号 | `{hello}` → 选中 `{hello}` |
| `i>` | 尖括号内内容 | `<hello>` → 选中 `hello` |
| `a>` | 尖括号内容含括号 | `<hello>` → 选中 `<hello>` |
| `it` | HTML 标签内内容 | `<div>hello</div>` → 选中 `hello` |
| `at` | HTML 标签内容含标签 | `<div>hello</div>` → 选中整个 |

### 段落与句子 Motion

| 动作 | 说明 |
|------|------|
| `ip` | 当前段落 (inner paragraph) |
| `ap` | 当前段落含空行 (a paragraph) |
| `is` | 当前句子 (inner sentence) |
| `as` | 当前句子含空格 (a sentence) |

### 查找 Motion

| 动作 | 说明 | 示例 |
|------|------|------|
| `f{char}` | 到下一个指定字符（包含该字符） | `fx` 到下一个 x |
| `t{char}` | 到下一个指定字符之前 | `tx` 到 x 之前 |
| `F{char}` | 到上一个指定字符（向后查找） | `Fx` 到上一个 x |
| `T{char}` | 到上一个指定字符之后 | `Tx` 到上一个 x 之后 |

---

## `i` vs `a` 的区别

- **`i`** = **inner**（内部），不包含边界符号/空格
- **`a`** = **a/around**（周围），包含边界符号/空格

```lua
-- 光标在 hello 中间
"hello world"

yi"  -- 复制: hello world （不含引号）
ya"  -- 复制: "hello world" （含引号）

-- 光标在 hello 上
hello world

yiw  -- 复制: hello （不含空格）
yaw  -- 复制: hello  （含后面空格）
```

---

## Motion 实战示例

```lua
-- 光标在 hello 上
local msg = hello world

ysiw"   -- 结果: local msg = "hello" world    (iw = 只选 hello)
ysiW"   -- 结果: local msg = "hello" world    (iW = 空格分隔的 WORD)
ys$"    -- 结果: local msg = "hello world"    ($ = 到行尾)
ysw"    -- 结果: local msg = "hello "world    (w = 到下个词，含空格)
yse"    -- 结果: local msg = "hello" world    (e = 到词尾)

-- 光标在引号内
local s = "hello world"

ysi""   -- 无意义，已经有引号了
cs"'    -- 结果: local s = 'hello world'      (修改引号类型)
ds"     -- 结果: local s = hello world        (删除引号)

-- 嵌套结构
local t = { name = "test" }

-- 光标在 name 上
ysiw"   -- 结果: { "name" = "test" }
-- 光标在 { 后
ysi}"   -- 结果: { "name = \"test\"" }        (给花括号内内容加引号)
```
