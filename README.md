# Terminal Input Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Terminal-input parsing surface — `Terminal.Input.Key`, `Terminal.Input.Mouse`, `Terminal.Input.Event`, and the parser variants (`CSI`, `Kitty`, `UTF8`, `Mouse`, `Control`) built on top of `Terminal_Primitives_Core` + `Input_Primitives` + `ASCII_Primitives`.

Sibling extraction of swift-terminal-primitives. The bare `Terminal` enum + base operations live in `Terminal_Primitive` / `Terminal_Primitives_Core`; this package adds the input-parser surface that depends on `swift-input-primitives` (Input pipeline abstractions) and `swift-ascii-primitives` (ASCII control characters). Subject-first naming per the inventory v3.3 manual triage — Terminal is the subject domain, Input is the role.

---
