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
    /// A keyboard input event.
    ///
    /// Represents a key press with optional modifiers, text content,
    /// and event kind (for Kitty keyboard protocol).
    public struct Key: Sendable, Equatable {
        /// The key code identifying which key was pressed.
        public var code: Code

        /// Active modifier keys (shift, alt, control, etc.).
        public var modifiers: Modifiers

        /// The text representation of the key, if applicable.
        ///
        /// Present for printable keys in the Kitty keyboard protocol.
        public var text: Swift.String?

        /// The key event kind (press, repeat, release).
        ///
        /// Only present when the Kitty keyboard protocol is active.
        public var kind: Kind?

        /// Creates a key event from a code with optional modifiers, text, and kind.
        public init(
            code: Code,
            modifiers: Modifiers = [],
            text: Swift.String? = nil,
            kind: Kind? = nil
        ) {
            self.code = code
            self.modifiers = modifiers
            self.text = text
            self.kind = kind
        }
    }
}
