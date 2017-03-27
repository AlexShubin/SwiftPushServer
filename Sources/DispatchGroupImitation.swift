//
//  DispatchGroupImitation.swift
//  SwiftPushServer
//
//  Created by Alex Shubin on 24.03.17.
//
//

class DispatchGroupImitation {
    
    private var count: UInt = 0
    private var notify: ()->Void
    
    init(notify: @escaping ()->Void) {
        self.notify = notify
    }
    
    func enter() {
        count += 1
    }
    
    func leave() {
        if count == 0 {
            count = 0
        } else {
            count -= 1
            if count == 0 {
                notify()
            }
        }
    }
    
}
