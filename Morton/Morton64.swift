import Foundation

public enum Morton64Error: Error {
    case initialization(dimensions: UInt64, bits: UInt64)
    case packDimensions(expected: UInt64, got: UInt64)
    case packBadValue(value: UInt64)
    case sPackBadValue(value: Int64)
}

public final class Morton64 {
    let dimensions: UInt64
    let bits: UInt64
    let masks: [UInt64]
    let lshifts: [UInt64]
    let rshifts: [UInt64]

    public init(dimensions: UInt64, bits: UInt64) throws {
        guard dimensions != 0 && bits != 0 && dimensions * bits <= 64 else {
            throw Morton64Error.initialization(dimensions: dimensions, bits: bits)
        }

        var mask: UInt64 = (1 << bits) - 1

        var shift: UInt64 = dimensions * (bits - 1)
        shift |= shift >> 1
        shift |= shift >> 2
        shift |= shift >> 4
        shift |= shift >> 8
        shift |= shift >> 16
        shift |= shift >> 32
        shift -= shift >> 1

        var masks: [UInt64] = [mask]
        var lshifts: [UInt64] = [0]

        while shift > 0 {
            mask = 0
            var shifted: UInt64 = 0
            var bit: UInt64 = 0

            while bit < bits {
                let distance: UInt64 = (dimensions * bit) - bit
                shifted |= shift & distance
                mask |= (1 << bit) << (((shift - 1) ^ 0xffffffffffffffff) & distance)
                bit += 1
            }

            if shifted != 0 {
                masks.append(mask)
                lshifts.append(shift)
            }

            shift >>= 1
        }

        var rshifts: [UInt64] = []
        rshifts += lshifts.dropFirst(1)
        rshifts.append(0)

        self.dimensions = dimensions
        self.bits = bits
        self.masks = masks
        self.lshifts = lshifts
        self.rshifts = rshifts
    }

    public func pack(_ values: [UInt64]) throws -> Int64 {
        guard dimensions == UInt64(values.count) else {
            throw Morton64Error.packDimensions(expected: dimensions, got: UInt64(values.count))
        }

        let wrongValues = values.filter {
            (value: UInt64) in value >= 1 << bits
        }

        guard wrongValues.count == 0 else {
            throw Morton64Error.packBadValue(value: wrongValues[0])
        }

        let code: UInt64 = values.enumerated().reduce(0) {
            (c: UInt64, iv: (i: Int, v: UInt64)) in c | (split(iv.v) << UInt64(iv.i))
        }

        return code.toInt64
    }

    public func pack(_ head: UInt64, _ tail: UInt64...) throws -> Int64 {
        return try pack([head] + tail)
    }

    public func sPack(_ values: [Int64]) throws -> Int64 {
        return try pack(values.map(shiftSign))
    }

    public func sPack(_ head: Int64, _ tail: Int64...) throws -> Int64 {
        return try sPack([head] + tail)
    }

    public func unpack(_ code: Int64) -> [UInt64] {
        return (0..<dimensions).map {
            (i: UInt64) in compact(code.toUInt64 >> i)
        }
    }

    public func sUnpack(_ code: Int64) -> [Int64] {
        return unpack(code).map(unshiftSign)
    }
}

private extension Morton64 {
    func shiftSign(_ value: Int64) throws -> UInt64 {
        let edgeValue = (1 << (bits - 1)).toInt64
        guard value < edgeValue && value > -edgeValue else {
            throw Morton64Error.sPackBadValue(value: value)
        }

        var svalue: Int64 = value
        if svalue < 0 {
            svalue = -svalue
            svalue |= edgeValue
        }

        return svalue.toUInt64
    }

    func unshiftSign(_ value: UInt64) -> Int64 {
        let sign = value & (1 << (bits - 1))
        var svalue = (value & ((1 << (bits - 1)) - 1)).toInt64
        if sign != 0 {
            svalue = -svalue
        }

        return svalue
    }

    func split(_ value: UInt64) -> UInt64 {
        return zip(lshifts, masks).reduce(value) {
            (c: UInt64, lsm: (ls: UInt64, m: UInt64)) in (c | (c << lsm.ls)) & lsm.m
        }
    }

    func compact(_ code: UInt64) -> UInt64 {
        return zip(rshifts, masks).reversed().reduce(code) {
            (v: UInt64, rsm: (rs: UInt64, m: UInt64)) in (v | (v >> rsm.rs)) & rsm.m
        }
    }
}

private extension Int64 {
    var toUInt64: UInt64 {
        return UInt64(bitPattern: self)
    }
}

private extension UInt64 {
    var toInt64: Int64 {
        return Int64(bitPattern: self)
    }
}
