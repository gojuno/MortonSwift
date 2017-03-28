import Foundation

enum Morton64Error: ErrorType {
    case initialization(dimensions: UInt64, bits: UInt64)
    case packDimensions(expected: UInt64, got: UInt64)
    case packBadValue(value: UInt64)
    case sPackBadValue(value: Int64)
}

class Morton64 {
    let dimensions: UInt64
    let bits: UInt64
    let masks: [UInt64]
    let lshifts: [UInt64]
    let rshifts: [UInt64]

    init(dimensions _dimensions: UInt64, bits _bits: UInt64) throws {
        if _dimensions == 0 || _bits == 0 || _dimensions * _bits > 64 {
            throw Morton64Error.initialization(dimensions: _dimensions, bits: _bits)
        }

        var mask: UInt64 = (1 << _bits) - 1

        var shift: UInt64 = _dimensions * (_bits - 1)
        shift |= shift >> 1
        shift |= shift >> 2
        shift |= shift >> 4
        shift |= shift >> 8
        shift |= shift >> 16
        shift |= shift >> 32
        shift -= shift >> 1

        var _masks: [UInt64] = [mask]
        var _lshifts: [UInt64] = [0]

        while shift > 0 {
            mask = 0
            var shifted: UInt64 = 0
            var bit: UInt64 = 0

            while bit < _bits {
                let distance: UInt64 = (_dimensions * bit) - bit
                shifted |= shift & distance
                mask |= (1 << bit) << (((shift - 1) ^ 0xffffffffffffffff) & distance)
                bit += 1
            }

            if shifted != 0 {
                _masks.append(mask)
                _lshifts.append(shift)
            }

            shift >>= 1
        }

        var _rshifts: [UInt64] = []
        _rshifts += _lshifts.dropFirst(1)
        _rshifts.append(0)

        dimensions = _dimensions
        bits = _bits
        masks = _masks
        lshifts = _lshifts
        rshifts = _rshifts
    }

    func Pack(_ values: [UInt64]) throws -> Int64 {
        if dimensions != UInt64(values.count) {
            throw Morton64Error.packDimensions(expected: dimensions, got: UInt64(values.count))
        }

        let wrongValues = values.filter {
            (value: UInt64) in value >= 1 << bits
        }

        if wrongValues.count > 0 {
            throw Morton64Error.packBadValue(value: wrongValues[0])
        }

        let code: UInt64 = values.enumerate().reduce(0) {
            (c: UInt64, iv: (i: Int, v: UInt64)) in c | (Split(iv.v) << UInt64(iv.i))
        }

        return UInt64ToInt64(code)
    }

    func SPack(_ values: [Int64]) throws -> Int64 {
        return try Pack(values.map(ShiftSign))
    }

    func Unpack(_ code: Int64) -> [UInt64] {
        return (0...(dimensions - 1)).map {
            (i: UInt64) in Compact(Int64ToUInt64(code) >> i)
        }
    }

    func SUnpack(_ code: Int64) -> [Int64] {
        return Unpack(code).map(UnshiftSign)
    }

    private func ShiftSign(_ value: Int64) throws -> UInt64 {
        if value >= UInt64ToInt64(1 << (bits - 1)) || value <= -UInt64ToInt64(1 << (bits - 1)) {
            throw Morton64Error.sPackBadValue(value: value)
        }

        var svalue: Int64 = value
        if svalue < 0 {
            svalue = -svalue
            svalue |= UInt64ToInt64(1 << (bits - 1))
        }

        return Int64ToUInt64(svalue)
    }

    private func UnshiftSign(_ value: UInt64) -> Int64 {
        let sign = value & (1 << (bits - 1))
        var svalue = UInt64ToInt64(value & ((1 << (bits - 1)) - 1))
        if sign != 0 {
            svalue = -svalue
        }

        return svalue
    }

    private func Split(_ value: UInt64) -> UInt64 {
        return zip(lshifts, masks).reduce(value) {
            (c: UInt64, lsm: (ls: UInt64, m: UInt64)) in (c | (c << lsm.ls)) & lsm.m
        }
    }

    private func Compact(_ code: UInt64) -> UInt64 {
        return zip(rshifts, masks).reverse().reduce(code) {
            (v: UInt64, rsm: (rs: UInt64, m: UInt64)) in (v | (v >> rsm.rs)) & rsm.m
        }
    }

    private func Int64ToUInt64(_ value: Int64) -> UInt64 {
        return UInt64(bitPattern: value)
    }

    private func UInt64ToInt64(_ value: UInt64) -> Int64 {
        return Int64(bitPattern: value)
    }
}
