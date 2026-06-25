# Terminal Input Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Decodes raw terminal byte streams into structured keyboard, mouse, resize, and paste events, covering VT/xterm escape sequences, SGR mouse encoding, and the Kitty keyboard protocol.

---

## Quick Start

`Terminal.Input.Parser` reads bytes from an `Input.Buffer` cursor and returns one `Terminal.Input.Event` at a time. The parser is stateless — all position lives in the buffer — so it drops straight into a read loop.

```swift
import Terminal_Input_Primitives

// Raw bytes from the terminal: ESC [ A — the Up arrow key.
var buffer = Input.Buffer<ContiguousArray<Byte>>([0x1B, 0x5B, 0x41])

do {
    let event = try Terminal.Input.Parser.parse(&buffer)
    switch event {
    case .key(let key):
        print(key.code)                 // up
    case .mouse(let mouse):
        print(mouse.column, mouse.row)  // 1-based SGR coordinates
    case .resize(let size):
        print(size)
    case .paste(let text):
        print(text)
    }
} catch {
    // `error` is a typed `Terminal.Input.Parser.Error`:
    // .emptyInput, .incompleteSequence, .unrecognizedSequence, .invalidUTF8
    print("parse failed: \(error)")
}
```

Partial reads are first-class. When the buffer ends mid-sequence the parser throws `Error.incompleteSequence` and rewinds the cursor to where the sequence began, so an I/O layer can wait for more bytes and retry the same buffer without losing data. Keyboard modifiers (`shift`, `alt`, `control`, `super`, `hyper`, `meta`, `capsLock`, `numLock`) arrive as a `Terminal.Input.Key.Modifiers` option set decoded from the CSI `1 + modifier_bits` encoding shared by xterm and Kitty.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-terminal-input-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Terminal Input Primitives", package: "swift-terminal-input-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Two library products. Depends only on the `Terminal`, `Input`, and `ASCII` primitives.

| Product | Target | Purpose |
|---------|--------|---------|
| `Terminal Input Primitives` | `Sources/Terminal Input Primitives/` | The `Terminal.Input` namespace: `Event`; `Key` with `Code`, `Kind`, and the `Modifiers` option set; `Mouse` with `Button` and `Kind`; and `Parser` with its typed `Error`. Decodes VT/xterm sequences, SGR mouse reports, and the Kitty keyboard protocol. |
| `Terminal Input Primitives Test Support` | `Tests/Support/` | Re-exports the main target for test consumers. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
