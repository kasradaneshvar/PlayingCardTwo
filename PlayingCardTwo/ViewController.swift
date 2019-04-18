//
//  ViewController.swift
//  PlayingCardTwo
//
//  Created by Kasra Daneshvar on 4/15/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var deck = PlayingCardDeck()
    
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    // ↓ This is step 1/3 of adding `dynamic animator`.
    lazy var animator = UIDynamicAnimator(referenceView: view) // For `referenceView`, check the docs (?). If the app had subview, maybe `view` was not a good choice.
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var cards = [PlayingCard]()
        
        for _ in 1...((cardViews.count + 1) / 2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            
            // ↓ This is step 3/3 of adding `dynamic animator`: adding items. This is done where the items were created.
//            collisionBehavior.addItem(cardView)
//            itemBehavior.addItem(cardView)
            
            cardBehavior.addItem(cardView)            
        }
    }
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0.alpha == 1} // The latter two conditions are there to make sure animated cards are not counted as `faceUp`.
        // The fact that `$0` act like a loop might be interesting.
    }
    
    private var faceUpCardsViewsMatch: Bool {
        return faceUpCardViews.count == 2 &&
        faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
        faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    private var lastChosenCardView: PlayingCardView?
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {// Almost always the first thing to do.
        case .ended: // Tap gesture: only care about the `.ended` state.
            // First, find out which view was tapped on. If the target was the view it would know that it was itself. Here, UITapGestureRecognizer knows what view was tapped on. All gestures do.
            if let chosenCardView = recognizer.view as? PlayingCardView , faceUpCardViews.count < 2 { // The second `if` is to make sure more than two cards can't be chosen.
                lastChosenCardView  = chosenCardView
                cardBehavior.removeItem(chosenCardView) // Stop animations on the chosen card.
                
                UIView.transition(
                    with: chosenCardView,
                    duration: 0.6,
                    options: [.transitionFlipFromLeft],
                    animations: { chosenCardView.isFaceUp = !chosenCardView.isFaceUp },
                    completion: { finished in // A closure? What is `finished in`?
                        let cardsToAnimate = self.faceUpCardViews // Because of the way `faceUpCardViews` were chosen; or else the code will dynamically change them.
                        
                        if self.faceUpCardsViewsMatch {
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.6,
                                delay: 0,
                                options: [],
                                animations: {
                                    cardsToAnimate.forEach {
                                        $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                    }
                                },
                                completion: { position in // Need to check the documentation for `position`.
                                    UIViewPropertyAnimator.runningPropertyAnimator(
                                        withDuration: 0.75,
                                        delay: 0,
                                        options: [],
                                        animations: {
                                            cardsToAnimate.forEach {
                                                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                $0.alpha = 0
                                            }
                                        },
                                        completion: { position in // Also, note that `$0` won't work without `position in`, as above.
                                            cardsToAnimate.forEach {
                                                $0.isHidden = true
                                                $0.alpha = 1
                                                $0.transform = .identity
                                            }
                                        }
                                    )
                                }
                            )
                            
                        } else if cardsToAnimate.count == 2 {
                            if chosenCardView == self.lastChosenCardView { // If the `flip transitions` is too long second card will start flipping too early.
                                cardsToAnimate.forEach { cardView in // Not able to infer here. Not sure why.
                                    UIView.transition(
                                        with: cardView,
                                        duration: 0.6,
                                        options: [.transitionFlipFromRight],
                                        animations: { cardView.isFaceUp = false },
                                        completion: { finished in
                                            self.cardBehavior.addItem(cardView)
                                        }
                                    )
                                }
                            }
                        } else {
                            if !chosenCardView.isFaceUp {
                                self.cardBehavior.addItem(chosenCardView)
                            }
                        }
                    }
                )
            }
        default:
            break
        }
    }
}
