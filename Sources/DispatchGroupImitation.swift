//
//  DispatchGroupImitation.swift
//  SwiftPushServer
//
//  Created by Alex Shubin on 24.03.17.
//
//

import PerfectThread

class DispatchGroupImitation {
    
    private let lock = Threading.Lock()
    
    private var count: UInt = 0
    private var notify: ()->Void
    
    init(notify: @escaping ()->Void) {
        self.notify = notify
    }
    
    func enter() {
        lock.doWithLock {
            count += 1
        }
    }
    
    func leave() {
        lock.doWithLock {
            if count > 0 {
                count -= 1
                if count == 0 {
                    notify()
                }
            }
        }
    }
    
}
