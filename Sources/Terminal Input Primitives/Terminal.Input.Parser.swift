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

extension Terminal.Input {
    /// VT terminal input parser.
    ///
    /// Parses raw byte sequences from a terminal into structured ``Terminal.Input.Event``
    /// values. Supports standard VT/xterm sequences, SGR mouse encoding, and the
    /// Kitty keyboard protocol.
    ///
    /// The parser is stateless—all state lives in the ``Input.Buffer`` cursor.
    /// Incomplete sequences restore the buffer position so the I/O layer can
    /// retry after receiving more data.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer = Input.Buffer<ContiguousArray<Byte>>([0x1B, 0x5B, 0x41])
    /// let event = try Terminal.Input.Parser.parse(&buffer)
    /// // event == .key(Key(code: .up))
    /// ```
    public struct Parser: Sendable {
        /// Creates a stateless parser.
        public init() {}
    }
}

// MARK: - Main Dispatch

extension Terminal.Input.Parser {

    /// Parses the next input event from the buffer.
    ///
    /// Dispatches on the first byte:
    /// - ESC (0x1B) → escape sequence (CSI, SS3, or Alt+key)
    /// - DEL (0x7F) → backspace
    /// - Control characters (0x00–0x1A) → control key mapping
    /// - Printable ASCII (0x20–0x7E) → character key
    /// - High bytes (0x80–0xFF) → UTF-8 multibyte sequence
    ///
    /// - Parameter input: The byte buffer to parse from.
    /// - Returns: The parsed input event.
    /// - Throws: ``Error/emptyInput`` if the buffer is empty,
    ///   ``Error/incompleteSequence`` if more bytes are needed (buffer restored),
    ///   ``Error/unrecognizedSequence`` or ``Error/invalidUTF8`` for bad data.
    public static func parse<Storage>(
        _ input: inout Input.Buffer<Storage>
    ) throws(Self.Error) -> Terminal.Input.Event
    where
        Storage: RandomAccessCollection & Sendable,
        Storage.Element == Byte,
        Storage.Index: Sendable & Hashable
    {
        guard let byte = input.first else {
            throw .emptyInput
        }

        // Type-up: lift to ASCII.Code at the dispatch boundary. A non-ASCII
        // first byte (≥ 0x80) is the UTF-8 multibyte path per RFC 3629 —
        // the throwing `ASCII.Code(_:)` surfaces that branch structurally
        // rather than relying on `unchecked:` + switch-default fall-through.
        let code: ASCII.Code
        do {
            code = try ASCII.Code(byte)
        } catch {
            // Non-ASCII first byte → UTF-8 multibyte continuation. Rewind on
            // `.incompleteSequence` so the I/O layer can wait for more bytes.
            let saved = input.checkpoint
            do {
                return try parseUTF8(&input)
            } catch let utf8Err {
                if utf8Err == .incompleteSequence {
                    input.seek(to: saved)
                }
                throw utf8Err
            }
        }

        switch code {
        case .esc:
            let saved = input.checkpoint
            do {
                return try parseEscapeSequence(&input)
            } catch {
                if error == .incompleteSequence {
                    input.seek(to: saved)
                }
                throw error
            }

        case .del:
            consumeUnchecked(&input)
            return .key(Terminal.Input.Key(code: .backspace))

        case .nul...ASCII.Code.us:
            return parseControlCharacter(&input)

        case .space...ASCII.Code.tilde:
            let b = consumeUnchecked(&input)
            return .key(Terminal.Input.Key(code: .character(Unicode.Scalar(b))))

        default:
            // All 128 ASCII codes (0x00–0x7F) are covered by the four cases
            // above. This branch is unreachable but Swift cannot prove
            // exhaustiveness over a struct-wrapping-UInt8. Treat as
            // unrecognized to keep the failure model consistent.
            throw .unrecognizedSequence
        }
    }
}

// MARK: - Escape Sequence Dispatch

extension Terminal.Input.Parser {

    /// Parses an escape sequence after the initial ESC byte.
    ///
    /// Dispatches on the byte following ESC:
    /// - `[` → CSI sequence
    /// - `O` → SS3 sequence (F1–F4)
    /// - Printable → Alt+character
    static func parseEscapeSequence<Storage>(
        _ input: inout Input.Buffer<Storage>
    ) throws(Self.Error) -> Terminal.Input.Event
    where
        Storage: RandomAccessCollection & Sendable,
        Storage.Element == Byte,
        Storage.Index: Sendable & Hashable
    {
        // Consume ESC
        consumeUnchecked(&input)

        guard let next = input.first else {
            throw .incompleteSequence
        }

        // Type-up: lift to ASCII.Code at the dispatch boundary. A non-ASCII
        // byte after ESC is an unrecognized escape sequence — the throwing
        // `ASCII.Code(_:)` surfaces that structurally rather than silently
        // lifting an invalid byte through a default fall-through.
        let code: ASCII.Code
        do {
            code = try ASCII.Code(next)
        } catch {
            throw .unrecognizedSequence
        }

        switch code {
        case .leftBracket:
            consumeUnchecked(&input)
            return try parseCSI(&input)

        case .O:
            consumeUnchecked(&input)
            return try parseSS3(&input)

        case .space...ASCII.Code.tilde:
            consumeUnchecked(&input)
            return .key(
                Terminal.Input.Key(
                    code: .character(Unicode.Scalar(next)),
                    modifiers: .alt
                )
            )

        default:
            throw .unrecognizedSequence
        }
    }
}

// MARK: - Byte Consumption Helpers

extension Terminal.Input.Parser {

    /// Consumes one byte, converting stream exhaustion to `.incompleteSequence`.
    @inline(always)
    static func consume<Storage>(
        _ input: inout Input.Buffer<Storage>
    ) throws(Self.Error) -> Byte
    where
        Storage: RandomAccessCollection & Sendable,
        Storage.Element == Byte,
        Storage.Index: Sendable & Hashable
    {
        do {
            return try input.advance()
        } catch {
            throw .incompleteSequence
        }
    }

    /// Consumes one byte without checking.
    ///
    /// The caller guarantees `!input.isEmpty`.
    @inline(always)
    @discardableResult
    static func consumeUnchecked<Storage>(
        _ input: inout Input.Buffer<Storage>
    ) -> Byte
    where
        Storage: RandomAccessCollection & Sendable,
        Storage.Element == Byte,
        Storage.Index: Sendable & Hashable
    {
        do {
            return try input.advance()
        } catch {
            preconditionFailure(
                "consumeUnchecked requires a non-empty buffer; the caller violated the !input.isEmpty precondition"
            )
        }
    }
}
