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
        }
    }
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {// Almost always the first thing to do.
        case .ended: // Tap gesture: only care about the `.ended` state.
            // First, find out which view was tapped on. If the target was the view it would know that it was itself. Here, UITapGestureRecognizer knows what view was tapped on. All gestures do.
            if let chosenCardView = recognizer.view as? PlayingCardView {
                UIView.transition(with: chosenCardView,
                                  duration: 0.6,
                                  options: [.transitionFlipFromLeft],
                                  animations: { chosenCardView.isFaceUp = !chosenCardView.isFaceUp }
                )
            }
        default:
            break
        }
    }
}
