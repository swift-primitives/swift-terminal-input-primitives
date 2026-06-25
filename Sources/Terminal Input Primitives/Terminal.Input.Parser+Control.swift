// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-terminal-primitives open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-terminal-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// MARK: - Control Character Parsing

extension Terminal.Input.Parser {

    /// Maps a control character byte to a key event.
    ///
    /// Standalone keys (Tab, Enter, Backspace) produce unmodified key events.
    /// Other control characters produce Ctrl+letter events:
    /// - 0x01–0x1A → Ctrl+a through Ctrl+z
    /// - 0x1C–0x1F → Ctrl+\ through Ctrl+_
    static func parseControlCharacter<Storage>(
        _ input: inout Input.Buffer<Storage>
    ) -> Terminal.Input.Event
    where
        Storage: RandomAccessCollection & Sendable,
        Storage.Element == Byte,
        Storage.Index: Sendable & Hashable
    {
        let byte = consumeUnchecked(&input)

        // Type-up: lift to ASCII.Code at the dispatch boundary. `unchecked:`
        // is safe here because the caller (`parse()` switch case
        // `.nul...ASCII.Code.us`) guarantees `byte ∈ 0x00...0x1F`, a strict
        // subset of the ASCII range per ISO 646.
        let code = ASCII.Code(unchecked: byte)
        switch code {
        case .cr:
            return .key(Terminal.Input.Key(code: .enter))

        case .tab:
            return .key(Terminal.Input.Key(code: .tab))

        case .bs:
            return .key(Terminal.Input.Key(code: .backspace))

        case .nul:
            return .key(
                Terminal.Input.Key(
                    code: .character(Unicode.Scalar(ASCII.Code.space)),
                    modifiers: .control
                )
            )

        default:
            // Arithmetic-domain bridge: control byte → printable Ctrl-letter via offset.
            // Byte has no arithmetic by design ([API-BYTE-002]); bridge via .underlying.
            guard code <= .sub else {
                // 0x1C–0x1F → Ctrl+\ through Ctrl+_
                return .key(
                    Terminal.Input.Key(
                        code: .character(Unicode.Scalar(byte.underlying &+ 0x40)),
                        modifiers: .control
                    )
                )
            }
            // 0x01–0x1A → Ctrl+a through Ctrl+z (lowercase)
            return .key(
                Terminal.Input.Key(
                    code: .character(Unicode.Scalar(byte.underlying &+ 0x60)),
                    modifiers: .control
                )
            )
        }
    }
}
