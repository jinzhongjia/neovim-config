# DAP Adapters Installation

This directory documents how to install debug adapters for each language.

## Go — Delve

```bash
go install github.com/go-delve/delve/cmd/dlv@latest
```

## Rust/C — codelldb

Download from: https://github.com/vadimcn/codelldb/releases

Or via Mason in Neovim:
```
:MasonInstall codelldb
```

Alternative: use `lldb-dap` (ships with LLVM 18+):
```bash
# Ubuntu/Debian
sudo apt install lldb

# macOS
brew install llvm
```

## Python — debugpy

```bash
pip install debugpy
# or
uv tool install debugpy
```

## TypeScript/JavaScript — js-debug-adapter

```bash
npm install -g @anthropic-ai/js-debug-adapter
# or use the vscode-js-debug approach:
npm install -g js-debug-adapter
```

Alternative via Mason:
```
:MasonInstall js-debug-adapter
```
