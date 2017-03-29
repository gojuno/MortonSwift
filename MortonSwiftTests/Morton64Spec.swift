import Foundation

import Quick
import Nimble

import MortonSwift

final class Morton64Spec: QuickSpec {

    override func spec() {

        func doTestInitialize(dimensions: UInt64, _ bits: UInt64) {
            it("can't initialize with dimensions \(dimensions) and bits \(bits)") {
                expect {
                    try Morton64(dimensions: dimensions, bits: bits)
                    }.to(throwError())
            }
        }

        func doTestValueBoundaries(dimensions: UInt64, _ bits: UInt64, _ value: UInt64) {
            it("can't pack out of boundaries value") {
                let m: Morton64 = try! Morton64(dimensions: dimensions, bits: bits)
                let values = [UInt64](count: Int(dimensions), repeatedValue: value)
                expect {
                    try m.pack(values)
                    }.to(throwError())
            }
        }

        func doTestSValueBoundaries(dimensions: UInt64, _ bits: UInt64, _ value: Int64) {
            it("can't pack out of boundaries signed value") {
                let m: Morton64 = try! Morton64(dimensions: dimensions, bits: bits)
                let values = [Int64](count: Int(dimensions), repeatedValue: value)
                expect {
                    try m.sPack(values)
                    }.to(throwError())
            }
        }

        func doTestPackUnpack(dimensions: UInt64, _ bits: UInt64, _ values: [UInt64]) {
            it("packed/unpacked \(values) with \(dimensions) dimensions and \(bits) bits") {
                let m: Morton64 = try! Morton64(dimensions: dimensions, bits: bits)
                let code: Int64 = try! m.pack(values)
                let unpacked: [UInt64] = m.unpack(code)
                expect(unpacked).to(equal(values))
            }
        }

        func doTestSPackUnpack(dimensions: UInt64, _ bits: UInt64, _ values: [Int64]) {
            it("signed packed/unpacked \(values) with \(dimensions) dimensions and \(bits) bits") {
                let m: Morton64 = try! Morton64(dimensions: dimensions, bits: bits)
                let code: Int64 = try! m.sPack(values)
                let unpacked: [Int64] = m.sUnpack(code)
                expect(unpacked).to(equal(values))
            }
        }

        describe("initialization") {
            doTestInitialize(0, 1)
            doTestInitialize(1, 0)
            doTestInitialize(1, 65)
        }

        describe("value boundaries") {
            doTestValueBoundaries(2, 1, 2)
            doTestValueBoundaries(16, 4, 16)
        }

        describe("signed value boundaries") {
            doTestSValueBoundaries(2, 2, 2)
            doTestSValueBoundaries(2, 2, -2)
            doTestSValueBoundaries(16, 4, 8)
            doTestSValueBoundaries(16, 4, -8)
        }

        describe("pack/unpack") {
            doTestPackUnpack(2, 32, [1, 2])
            doTestPackUnpack(2, 32, [2, 1])
            doTestPackUnpack(2, 32, [(1 << 32) - 1, (1 << 32) - 1])
            doTestPackUnpack(2, 1, [1, 1])

            doTestPackUnpack(3, 21, [1, 2, 4])
            doTestPackUnpack(3, 21, [4, 2, 1])
            let values0: [UInt64] = [(1 << 21) - 1, (1 << 21) - 1, (1 << 21) - 1]
            doTestPackUnpack(3, 21, values0)
            doTestPackUnpack(3, 1, [1, 1, 1])

            doTestPackUnpack(4, 16, [1, 2, 4, 8])
            doTestPackUnpack(4, 16, [8, 4, 2, 1])
            let values1: [UInt64] = [(1 << 16) - 1, (1 << 16) - 1, (1 << 16) - 1, (1 << 16) - 1]
            doTestPackUnpack(4, 16, values1)
            doTestPackUnpack(4, 1, [1, 1, 1, 1])

            doTestPackUnpack(6, 10, [1, 2, 4, 8, 16, 32])
            doTestPackUnpack(6, 10, [32, 16, 8, 4, 2, 1])
            doTestPackUnpack(6, 10, [1023, 1023, 1023, 1023, 1023, 1023])

            let values: [UInt64] = [UInt64](count: 64, repeatedValue: 1)
            doTestPackUnpack(64, 1, values)
        }

        describe("spack/sunpack") {
            doTestSPackUnpack(2, 32, [1, 2])
            doTestSPackUnpack(2, 32, [2, 1])
            doTestSPackUnpack(2, 32, [(1 << 31) - 1, (1 << 31) - 1])
            doTestSPackUnpack(2, 2, [1, 1])
            doTestSPackUnpack(2, 32, [-1, -2])
            doTestSPackUnpack(2, 32, [-2, -1])
            doTestSPackUnpack(2, 32, [-((1 << 31) - 1), -((1 << 31) - 1)])
            doTestSPackUnpack(2, 2, [-1, -1])

            doTestSPackUnpack(3, 21, [1, 2, 4])
            doTestSPackUnpack(3, 21, [4, 2, 1])
            let values0: [Int64] = [(1 << 20) - 1, (1 << 20) - 1, (1 << 20) - 1]
            doTestSPackUnpack(3, 21, values0)
            doTestSPackUnpack(3, 2, [1, 1, 1])
            doTestSPackUnpack(3, 21, [-1, -2, -4])
            doTestSPackUnpack(3, 21, [-4, -2, -1])
            let values1: [Int64] = [-((1 << 20) - 1), -((1 << 20) - 1), -((1 << 20) - 1)]
            doTestSPackUnpack(3, 21, values1)
            doTestSPackUnpack(3, 2, [-1, -1, -1])

            doTestSPackUnpack(4, 16, [1, 2, 4, 8])
            doTestSPackUnpack(4, 16, [8, 4, 2, 1])
            let values2: [Int64] = [(1 << 15) - 1, (1 << 15) - 1, (1 << 15) - 1, (1 << 15) - 1]
            doTestSPackUnpack(4, 16, values2)
            doTestSPackUnpack(4, 2, [1, 1, 1, 1])
            doTestSPackUnpack(4, 16, [-1, -2, -4, -8])
            doTestSPackUnpack(4, 16, [-8, -4, -2, -1])
            let values3: [Int64] = [-((1 << 15) - 1), -((1 << 15) - 1), -((1 << 15) - 1), -((1 << 15) - 1)]
            doTestSPackUnpack(4, 16, values3)
            doTestSPackUnpack(4, 2, [-1, -1, -1, -1])

            doTestSPackUnpack(6, 10, [1, 2, 4, 8, 16, 32])
            doTestSPackUnpack(6, 10, [32, 16, 8, 4, 2, 1])
            doTestSPackUnpack(6, 10, [511, 511, 511, 511, 511, 511])
            doTestSPackUnpack(6, 10, [-1, -2, -4, -8, -16, -32])
            doTestSPackUnpack(6, 10, [-32, -16, -8, -4, -2, -1])
            doTestSPackUnpack(6, 10, [-511, -511, -511, -511, -511, -511])

            let range: Range<Int64> = 0..<32
            let values = range.map { 1 - 2 * ($0 % 2) }
            doTestSPackUnpack(32, 2, values)
        }
    }
}
