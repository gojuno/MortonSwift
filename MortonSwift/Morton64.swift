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
        for e in _lshifts.dropFirst(1) {
            _rshifts.append(e)
        }
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

        var vi: Int = 0
        while vi < values.count {
            if values[vi] >= (1 << bits) {
                throw Morton64Error.packBadValue(value: values[vi])
            }
            vi += 1
        }

        var code: UInt64 = 0
        var i: UInt64 = 0
        while i < dimensions {
            code |= Split(values[Int(i)]) << i
            i += 1
        }

        return UInt64ToInt64(code)
    }

    func SPack(_ values: [Int64]) throws -> Int64 {
        var uvalues: [UInt64] = []
        var i: Int = 0
          while i < values.count {
              uvalues.append(try ShiftSign(values[i]))
              i += 1
        }

        return try Pack(uvalues)
    }

    func Unpack(_ code: Int64) -> [UInt64] {
        var values: [UInt64] = []
        var i: UInt64 = 0
        while i < dimensions {
            values.append(Compact(Int64ToUInt64(code) >> i))
            i += 1
        }

        return values
    }

    func SUnpack(_ code: Int64) -> [Int64] {
        let uvalues: [UInt64] = Unpack(code)
        var values: [Int64] = []
        var i: Int = 0
        while i < Int(dimensions) {
            values.append(UnshiftSign(uvalues[i]))
            i += 1
        }

        return values
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
        var code: UInt64 = value
        var o: Int = 0
        while o < masks.count {
            code = (code | (code << lshifts[o])) & masks[o]
            o += 1
        }

        return code
    }

    private func Compact(_ code: UInt64) -> UInt64 {
        var value: UInt64 = code
        var o: Int = masks.count - 1
        while o >= 0 {
            value = (value | (value >> rshifts[o])) & masks[o]
            o -= 1
        }

        return value
    }

    private func Int64ToUInt64(_ value: Int64) -> UInt64 {
        return UInt64(bitPattern: value)
    }

    private func UInt64ToInt64(_ value: UInt64) -> Int64 {
        return Int64(bitPattern: value)
    }
}
