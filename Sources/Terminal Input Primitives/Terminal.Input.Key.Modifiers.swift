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

extension Terminal.Input.Key {
    /// Keyboard modifier flags.
    ///
    /// Bit layout matches the CSI modifier encoding used by xterm and
    /// the Kitty keyboard protocol: `encoded_value = 1 + modifier_bits`.
    ///
    /// - Bit 0: Shift
    /// - Bit 1: Alt
    /// - Bit 2: Control
    /// - Bit 3: Super
    /// - Bit 4: Hyper
    /// - Bit 5: Meta
    /// - Bit 6: Caps Lock
    /// - Bit 7: Num Lock
    public struct Modifiers: OptionSet, Sendable, Equatable, Hashable {
        /// The raw bitset backing the modifier flags.
        public let rawValue: UInt8

        /// Creates a modifier set from its raw bitset.
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// The Shift modifier (bit 0).
        public static let shift = Self(rawValue: 1 << 0)

        /// The Alt (Option) modifier (bit 1).
        public static let alt = Self(rawValue: 1 << 1)

        /// The Control modifier (bit 2).
        public static let control = Self(rawValue: 1 << 2)

        /// The Super (Command / Windows) modifier (bit 3).
        public static let `super` = Self(rawValue: 1 << 3)

        /// The Hyper modifier (bit 4).
        public static let hyper = Self(rawValue: 1 << 4)

        /// The Meta modifier (bit 5).
        public static let meta = Self(rawValue: 1 << 5)

        /// The Caps Lock modifier (bit 6).
        public static let capsLock = Self(rawValue: 1 << 6)

        /// The Num Lock modifier (bit 7).
        public static let numLock = Self(rawValue: 1 << 7)
    }
}
