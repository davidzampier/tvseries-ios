//
//  DispatchGroupMock.swift
//  TVSeries GuideTests
//
//  Created by David Zampier on 06/02/22.
//

import Foundation
@testable import TVSeries_Guide

final class DispatchGroupMock {
    
    private(set) var iterator = 0
    private(set) var didCallMethods: [Method] = []
    
    
    // MARK: - Method
    
    enum Method {
        case enter
        case leave
        case notify
    }
}


// MARK: - DispatchGroupProtocol

extension DispatchGroupMock: DispatchGroupProtocol {
    
    func enter() {
        self.iterator += 1
        self.didCallMethods.append(.enter)
    }

    func leave() {
        self.iterator -= 1
        self.didCallMethods.append(.leave)
    }

    func notify(queue: DispatchQueue,
                execute work: @escaping () -> Void) {
        self.didCallMethods.append(.notify)
        if self.iterator == 0 {
            work()
        }
    }
}
