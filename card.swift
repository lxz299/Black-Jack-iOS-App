//
//  card.swift
//  BlackJack
//
//  Created by Jing Li on 2/17/17.
//  Copyright © 2017 CBC.case.edu. All rights reserved.
//

import Foundation
import UIKit

enum Suit : Int {
    case club=0, spade, diamond, heart
    func simpleDescription()->String{
        switch self {
        case .club:
            return "club"
        case .spade:
            return "spade"
        case .diamond:
            return "diamond"
        case .heart:
            return "heart"
        }
    }
}

class Card{
    var suit: Suit = .club
    var digit = 1
    var isFaceUp = false
    
    init(suit: Suit, digit: Int){
        self.suit = suit
        self.digit = digit
    }
    
    static func generateAPackOfCards(numOfDecks : Int) -> [Card]{
        var deckOfCards = [Card]()
        for k in 1...numOfDecks{
            for i in 0..<4{
                for j in 1...13{
                    let card = Card(suit: Suit(rawValue: i)!, digit: j)
                    deckOfCards.append(card)
                }
            }
        }
        return deckOfCards
    }
    func isAce() -> Bool {
        return digit == 1 ? true : false
    }
    
    func isAFaceOrTen() -> Bool {
        return digit > 9 ? true : false
    }
    
    func getCardImage()-> UIImage?{
        return UIImage(named: "\(suit.simpleDescription())-\(digit).png")
        
    }
}

enum BJGameStage : Int
{
    case playerStage = 0
    case dealerStage, gameOverStage
    
}

extension Array{
    mutating func shuffle() {
        for i in (1...(self.count-1)).reversed(){
            let tmpInt = i+1
            let j = Int(arc4random_uniform(UInt32(tmpInt)))
            let tmp = self[i]
            self[i] = self[j]
            self[j] = tmp
        }
    }
}

class BJGameModel{
    private var cards = [Card]()
    private var playerCards = [Card]()
    private var dealerCards = [Card]()
    
    var gameStage : BJGameStage = .playerStage
    
    let maxPlayerCards = 5
    
    var didDealerWin = false
    
    var cardRemaining : Int = 52
    
    init(numOfDecks: Int){
        startGame(numOfDecks: numOfDecks)
    }
    
    func resetGame(){
        self.cards.shuffle()
        
        self.playerCards = [Card]()
        self.dealerCards = [Card]()
        gameStage = .playerStage
    }
    
    func startGame(numOfDecks : Int){
        self.cards = Card.generateAPackOfCards(numOfDecks: numOfDecks)
        //shuffle
        self.cards.shuffle()
        
        self.playerCards = [Card]()
        self.dealerCards = [Card]()
        self.cardRemaining = numOfDecks*52
        gameStage = .playerStage
    }
    func nextCard() -> Card{
        cardRemaining = cardRemaining - 1
        return cards.removeFirst()
    }
    func nextDearlerCard() -> Card {
        let card = nextCard()
        dealerCards.append(card)
        return card
    }
    func nextPlayerCard() -> Card {
        let card = nextCard()
        playerCards.append(card)
        return card
    }
    
    func dealerCardAtIndex(_ i: Int) -> Card?{
        if i < dealerCards.count{
            return dealerCards[i]
        }else{
            return nil
        }
    }
    
    func playerCardAtIndex(_ i: Int) -> Card?{
        if i < playerCards.count{
            return playerCards[i]
        }else{
            return nil
        }
    }
    
    func areCardsBust(_ curCards : [Card]) -> Bool {
        var lowestScore = 0
        for card in curCards {
            if card.isAce(){
                lowestScore += 1
            }else if card.isAFaceOrTen(){
                lowestScore += 10
            }else{
                lowestScore += card.digit
            }
        }
        if lowestScore > 21 {
            return true
        }else{
            return false
        }
    }
    
    func findBlackJack(){
        var score = 0
        for card in playerCards {
            if card.isAce(){
                score  += 11
            }
            else if card.isAFaceOrTen(){
                score += 10
            }
            else {
                score += card.digit
            }
        }
        
        if score == 21{
            gameStage = .gameOverStage
            didDealerWin = false
            notifyGameDidEnd()
        }
    }
    
    private func calculateBestScore(_ cards: [Card]) -> Int{
        var highestScore = 0
        
        if areCardsBust(cards) {
            return 0
        }
        
        for card in cards{
            if(card.isAce()){
                highestScore += 11
            }else if (card.isAFaceOrTen()){
                highestScore += 10
            }else{
                highestScore += card.digit
            }
        }
        
        while(highestScore > 21){
            highestScore -= 10
        }
        
        return highestScore
    }
    
    private func calculateWinner(){
        let dealerScore = calculateBestScore(dealerCards)
        let playerScore = calculateBestScore(playerCards)
        didDealerWin = dealerScore >= playerScore
    }
    
    func updateGameStage() {
        if gameStage == .playerStage{
            if areCardsBust(playerCards){
                gameStage = .gameOverStage
                // what we need to do after game over?
                didDealerWin = true
                notifyGameDidEnd()
            }else if playerCards.count == maxPlayerCards {
                gameStage = .dealerStage
            }
            
        }else if gameStage == .dealerStage{
            if areCardsBust(dealerCards){
                gameStage = .gameOverStage
                // what we need to do after game over?
                didDealerWin = false
                notifyGameDidEnd()
            }else if dealerCards.count == maxPlayerCards {
                gameStage = .gameOverStage
                calculateWinner()
                
                notifyGameDidEnd()
            }else { //calculate the score and then determine what to do
                let dealerScore = calculateBestScore(dealerCards)
                if dealerScore < 17 {
                    //still dealer's turn, do nothing
                }else{
                    let playerScore = calculateBestScore(playerCards)
                    if playerScore > dealerScore {
                        //... dealer still need more cards, do nothing
                    }else{
                        didDealerWin = true
                        gameStage = .gameOverStage
                        notifyGameDidEnd()
                    }
                }
            }
            
        }else{ // gameover
            calculateWinner()
            notifyGameDidEnd()
        }
        
    }
    
    func lastDealerCard()-> Card?{
        return dealerCards.last
    }
    
    func lastPlayerCard()-> Card?{
        return playerCards.last
    }

    func notifyGameDidEnd(){
        let notificationCenter = NotificationCenter.default
     
        notificationCenter.post(name: Notification.Name(rawValue:"BJNotificationGameDidEnd"), object: self, userInfo: ["didDealerWin" : didDealerWin])
    }
}


