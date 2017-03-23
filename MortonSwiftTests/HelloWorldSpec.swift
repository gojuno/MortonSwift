//
//  MortonSwiftSpec.swift
//  MortonSwiftTests
//
//  Copyright © 2017 Juno Inc. All rights reserved.
//

import Foundation

import Quick
import Nimble

@testable import MortonSwift

final class HelloWorldSpec: QuickSpec {

    override func spec() {

        describe("HelloWorld") {

            var helloWorld: HelloWorld!

            beforeEach {
                helloWorld = HelloWorld()
            }

            afterEach {
                helloWorld = nil
            }

            it("should greet properly") {
                expect(helloWorld.greeting).to(equal("Hello"))
            }
        }
    }
}
