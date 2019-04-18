//
//  CardBehavior.swift
//  PlayingCardTwo
//
//  Created by Kasra Daneshvar on 4/18/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {

    // ↓ This is step 2/3 of adding `dynamic animator`.
    lazy var collisionBehavior: UICollisionBehavior = { // Initialize with closure: example.
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
//        animator.addBehavior(behavior) // After making the class, someboy has to add `me` to an animator

        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 1.0 // Don't gain, don't lose.
        behavior.resistance = 0.1
//        animator.addBehavior(behavior)
        return behavior
    }()
    
    private func push (_ item: UIDynamicItem) {
        // Adding another `dynamic behavior`; a push.
        let pushBehavior = UIPushBehavior(items: [item], mode: .instantaneous) // Could also give it all the cards at once.
        pushBehavior.angle = CGFloat.pi / 7 // Better add some random number; `extension CGFloat`
        pushBehavior.magnitude = CGFloat(1.0)
        pushBehavior.action = { [unowned pushBehavior, weak self] in // Avoiding memory cycle: `pushBehavior.action` has a pointer to the closure which keeps `pushBehavior` in memory.
            // Still don't quite understand the `weak self` part.
//            pushBehavior.dynamicAnimator?.removeBehavior(pushBehavior) // Changed to removing a `child`.
            self?.removeChildBehavior(pushBehavior)
        }
        addChildBehavior(pushBehavior)
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
        // `Push` got removed as soon as it happend.
    }
    
    // Have to add the above as child in an `init()`
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
        
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }

}
