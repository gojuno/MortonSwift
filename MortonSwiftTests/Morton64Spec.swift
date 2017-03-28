import Foundation

import Quick
import Nimble

@testable import MortonSwift

final class Morton64Spec: QuickSpec {
    func DoTestInitialize(_ dimensions: UInt64, _ bits: UInt64) {
        it("can't initialize with dimensions \(dimensions) and bits \(bits)") {
            expect {
                try Morton64(dimensions: dimensions, bits: bits)
            }.to(throwError())
        }
    }

    func DoTestValueBoundaries(_ dimensions: UInt64, _ bits: UInt64, _ value: UInt64) {
        it("can't pack out of boundries value") {
            let m: Morton64 = try! Morton64(dimensions: dimensions, bits: bits)
            var values: [UInt64] = []
            var i: Int = 0
            while i < Int(dimensions) {
                values.append(value)
                i += 1
            }
            expect {
                try m.Pack(values)
            }.to(throwError())
        }
    }

    func DoTestSValueBoundaries(_ dimensions: UInt64, _ bits: UInt64, _ value: Int64) {
        it("can't pack out of boundries signed value") {
            let m: Morton64 = try! Morton64(dimensions: dimensions, bits: bits)
            var values: [Int64] = []
            var i: Int = 0
            while i < Int(dimensions) {
                values.append(value)
                i += 1
            }
            expect {
                try m.SPack(values)
            }.to(throwError())
        }
    }

    func DoTestPackUnpack(_ dimensions: UInt64, _ bits: UInt64, _ values: [UInt64]) {
        it("packed/unpacked \(values) with \(dimensions) dimensions and \(bits) bits") {
            let m: Morton64 = try! Morton64(dimensions: dimensions, bits: bits)
            let code: Int64 = try! m.Pack(values)
            let unpacked: [UInt64] = m.Unpack(code)
            expect(unpacked).to(equal(values))
        }
    }

    func DoTestSPackUnpack(_ dimensions: UInt64, _ bits: UInt64, _ values: [Int64]) {
        it("signed packed/unpacked \(values) with \(dimensions) dimensions and \(bits) bits") {
            let m: Morton64 = try! Morton64(dimensions: dimensions, bits: bits)
            let code: Int64 = try! m.SPack(values)
            let unpacked: [Int64] = m.SUnpack(code)
            expect(unpacked).to(equal(values))
        }
    }

    override func spec() {
        describe("initialization") {
            self.DoTestInitialize(0, 1)
            self.DoTestInitialize(1, 0)
            self.DoTestInitialize(1, 65)
        }

        describe("value boundries") {
            self.DoTestValueBoundaries(2, 1, 2)
            self.DoTestValueBoundaries(16, 4, 16)
        }

        describe("signed value boundries") {
            self.DoTestSValueBoundaries(2, 2, 2)
            self.DoTestSValueBoundaries(2, 2, -2)
            self.DoTestSValueBoundaries(16, 4, 8)
            self.DoTestSValueBoundaries(16, 4, -8)
        }

        describe("pack/unpack") {
            self.DoTestPackUnpack(2, 32, [1, 2])
            self.DoTestPackUnpack(2, 32, [2, 1])
            self.DoTestPackUnpack(2, 32, [(1 << 32) - 1, (1 << 32) - 1])
            self.DoTestPackUnpack(2, 1, [1, 1])

            self.DoTestPackUnpack(3, 21, [1, 2, 4])
            self.DoTestPackUnpack(3, 21, [4, 2, 1])
            let values0: [UInt64] = [(1 << 21) - 1, (1 << 21) - 1, (1 << 21) - 1]
            self.DoTestPackUnpack(3, 21, values0)
            self.DoTestPackUnpack(3, 1, [1, 1, 1])

            self.DoTestPackUnpack(4, 16, [1, 2, 4, 8])
            self.DoTestPackUnpack(4, 16, [8, 4, 2, 1])
            let values1: [UInt64] = [(1 << 16) - 1, (1 << 16) - 1, (1 << 16) - 1, (1 << 16) - 1]
            self.DoTestPackUnpack(4, 16, values1)
            self.DoTestPackUnpack(4, 1, [1, 1, 1, 1])

            self.DoTestPackUnpack(6, 10, [1, 2, 4, 8, 16, 32])
            self.DoTestPackUnpack(6, 10, [32, 16, 8, 4, 2, 1])
            self.DoTestPackUnpack(6, 10, [1023, 1023, 1023, 1023, 1023, 1023])

            var values: [UInt64] = []
            var i: Int = 0
            while i < 64 {
                values.append(1)
                i += 1
            }
            self.DoTestPackUnpack(64, 1, values)
        }

        describe("spack/sunpack") {
            self.DoTestSPackUnpack(2, 32, [1, 2])
            self.DoTestSPackUnpack(2, 32, [2, 1])
            self.DoTestSPackUnpack(2, 32, [(1 << 31) - 1, (1 << 31) - 1])
            self.DoTestSPackUnpack(2, 2, [1, 1])
            self.DoTestSPackUnpack(2, 32, [-1, -2])
            self.DoTestSPackUnpack(2, 32, [-2, -1])
            self.DoTestSPackUnpack(2, 32, [-((1 << 31) - 1), -((1 << 31) - 1)])
            self.DoTestSPackUnpack(2, 2, [-1, -1])

            self.DoTestSPackUnpack(3, 21, [1, 2, 4])
            self.DoTestSPackUnpack(3, 21, [4, 2, 1])
            let values0: [Int64] = [(1 << 20) - 1, (1 << 20) - 1, (1 << 20) - 1]
            self.DoTestSPackUnpack(3, 21, values0)
            self.DoTestSPackUnpack(3, 2, [1, 1, 1])
            self.DoTestSPackUnpack(3, 21, [-1, -2, -4])
            self.DoTestSPackUnpack(3, 21, [-4, -2, -1])
            let values1: [Int64] = [-((1 << 20) - 1), -((1 << 20) - 1), -((1 << 20) - 1)]
            self.DoTestSPackUnpack(3, 21, values1)
            self.DoTestSPackUnpack(3, 2, [-1, -1, -1])

            self.DoTestSPackUnpack(4, 16, [1, 2, 4, 8])
            self.DoTestSPackUnpack(4, 16, [8, 4, 2, 1])
            let values2: [Int64] = [(1 << 15) - 1, (1 << 15) - 1, (1 << 15) - 1, (1 << 15) - 1]
            self.DoTestSPackUnpack(4, 16, values2)
            self.DoTestSPackUnpack(4, 2, [1, 1, 1, 1])
            self.DoTestSPackUnpack(4, 16, [-1, -2, -4, -8])
            self.DoTestSPackUnpack(4, 16, [-8, -4, -2, -1])
            let values3: [Int64] = [-((1 << 15) - 1), -((1 << 15) - 1), -((1 << 15) - 1), -((1 << 15) - 1)]
            self.DoTestSPackUnpack(4, 16, values3)
            self.DoTestSPackUnpack(4, 2, [-1, -1, -1, -1])

            self.DoTestSPackUnpack(6, 10, [1, 2, 4, 8, 16, 32])
            self.DoTestSPackUnpack(6, 10, [32, 16, 8, 4, 2, 1])
            self.DoTestSPackUnpack(6, 10, [511, 511, 511, 511, 511, 511])
            self.DoTestSPackUnpack(6, 10, [-1, -2, -4, -8, -16, -32])
            self.DoTestSPackUnpack(6, 10, [-32, -16, -8, -4, -2, -1])
            self.DoTestSPackUnpack(6, 10, [-511, -511, -511, -511, -511, -511])

            var values: [Int64] = []
            var i: Int = 0
            while i < 32 {
                values.append(1 - 2 * (i % 2))
                i += 1
            }
            self.DoTestSPackUnpack(32, 2, values)
        }
    }
}
