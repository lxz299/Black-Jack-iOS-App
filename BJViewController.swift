//
//  BJViewController.swift
//  BlackJack
//
//  Created by Jing Li on 2/17/17.
//  Copyright © 2017 CBC.case.edu. All rights reserved.
//

import UIKit

class BJViewController: UIViewController {

    @IBOutlet weak var settingOutlet: UINavigationItem!
    @IBOutlet var dealerCardViews: [UIImageView]!
    @IBOutlet var playerCardView: [UIImageView]!
    
    @IBOutlet weak var buttonHit: UIButton!
    @IBOutlet weak var buttonStand: UIButton!
    
    @IBOutlet weak var playerlabel: UILabel!
    @IBOutlet weak var dealerLabel: UILabel!
    @IBOutlet weak var remainingCardsLabel: UILabel!
    @IBOutlet weak var remainingCards: UILabel!
    
    var threshold: Int = 15
    var numOfDecks: Int = 1
    var message = "Please specify the number of decks and threshold in order to start the game!"
    
    @IBAction func userClickHit(_ sender: UIButton) {
        let card = gameModel.nextPlayerCard()
        card.isFaceUp = true
        renderCards()
        gameModel.updateGameStage()
        remainingCards.text = String(gameModel.cardRemaining)
        gameModel.findBlackJack()
    }
    
    @IBAction func userClickStand(_ sender: UIButton) {
        gameModel.gameStage = .dealerStage
        playDealerTurn()
        remainingCards.text = String(gameModel.cardRemaining)
    }
    
    func playDealerTurn(){
        buttonHit.isEnabled = false
        buttonStand.isEnabled = false
        
        showSecondDealerCard()
    }
    
    func showSecondDealerCard()  {
        if let card = gameModel.lastDealerCard(){
            card.isFaceUp = true
            renderCards()
            gameModel.updateGameStage()
            //....
            if(gameModel.gameStage != .gameOverStage){
                let aSelector : Selector = #selector(BJViewController.showNextDealerCard)
                perform(aSelector, with: nil, afterDelay: 1.5)
                
            }
        }
        remainingCards.text = String(gameModel.cardRemaining)
    }
    
    func showNextDealerCard(){
        let card = gameModel.nextDearlerCard()
        card.isFaceUp = true
        renderCards()
        gameModel.updateGameStage()
        if gameModel.gameStage != .gameOverStage{
            let aSelector : Selector = #selector(BJViewController.showNextDealerCard)
            perform(aSelector, with: nil, afterDelay: 1.5)
            
            //showNextDealerCard()
        }
    }
    
    
    private var gameModel: BJGameModel
    
    required init?(coder aDecoder: NSCoder) {
        gameModel = BJGameModel(numOfDecks: 1)
        super.init(coder: aDecoder)
        let aSelector : Selector = #selector(BJViewController.handleNotificationGameDidEnd(_:))
        
        NotificationCenter.default.addObserver(self, selector: aSelector, name: NSNotification.Name(rawValue: "BJNotificationGameDidEnd"), object: gameModel)
    }
    
    func handleNotificationGameDidEnd(_ notification: Notification){
        if let userInfo  = notification.userInfo {
            if let dealerWin = userInfo["didDealerWin"]{
                let message = (dealerWin as! Bool) ? "Dealer Won!" : "You Won!"
                let alert = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
                let alertRestart = UIAlertAction(title: "Play again!", style: .default, handler: ({ (_:UIAlertAction) -> Void in self.restartNewGame()}))
                let alertContinue = UIAlertAction(title: "Play again!", style: .default, handler: ({ (_:UIAlertAction) -> Void in self.restartGame()}))
                if self.gameModel.cardRemaining < threshold{
                    alert.addAction(alertRestart)
                }
                else {
                    alert.addAction(alertContinue)
                }
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func handleNotificationGameStart(){
        let alert = UIAlertController(title: "New Game", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Start a New Game!", style: .default, handler: ({ (_:UIAlertAction) -> Void in
            let n = alert.textFields![0].text!
            let t = alert.textFields![1].text!
            if n != "" && t != "" {
                self.message = ""
                self.numOfDecks = Int(n)!
                self.threshold = Int(t)!
                self.restartNewGame()}
            else {
                self.message = "Both of the textfields should not be empty!"
                self.handleNotificationGameStart()
            }}))
        alert.addAction(alertAction)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter the number of decks"
        }
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter the threshold"
        }
        present(alert, animated: true, completion: nil)
    }
    
    func restartGame(){
        gameModel.resetGame()
        var card = gameModel.nextDearlerCard()
        card.isFaceUp = true
        card = gameModel.nextDearlerCard()
        
        card = gameModel.nextPlayerCard()
        card.isFaceUp = true
        card = gameModel.nextPlayerCard()
        card.isFaceUp = true
        
        buttonHit.isEnabled = true
        buttonStand.isEnabled = true
        remainingCards.text = String(gameModel.cardRemaining)
        renderCards()
        gameModel.findBlackJack()
        
    }
    
    func restartNewGame(){
        buttonHit.isHidden = false
        buttonStand.isHidden = false
        remainingCards.isHidden = false
        remainingCardsLabel.isHidden = false
        dealerLabel.isHidden = false
        playerlabel.isHidden = false
        gameModel.startGame(numOfDecks: numOfDecks)
        var card = gameModel.nextDearlerCard()
        card.isFaceUp = true
        card = gameModel.nextDearlerCard()
        
        card = gameModel.nextPlayerCard()
        card.isFaceUp = true
        card = gameModel.nextPlayerCard()
        card.isFaceUp = true
        
        buttonHit.isEnabled = true
        buttonStand.isEnabled = true
        remainingCards.text = String(gameModel.cardRemaining)
        renderCards()
        gameModel.findBlackJack()
    }
    
    func renderCards(){
        var isPresent : Bool
        for i in 0..<gameModel.maxPlayerCards{
            if let dealerCard = gameModel.dealerCardAtIndex(i){
                if dealerCardViews[i].isHidden == true{
                    isPresent = true
                }
                else {
                    isPresent = false
                }
                dealerCardViews[i].isHidden = false
                if(dealerCard.isFaceUp){
                    if (self.dealerCardViews[i].image == UIImage(named:"card-back.png") || isPresent){
                        UIView.transition(with: dealerCardViews[i],
                                          duration: 1,
                                          options: UIViewAnimationOptions.transitionFlipFromLeft,
                                          animations: {self.dealerCardViews[i].image = dealerCard.getCardImage() },
                                          completion: nil)
                    }
                    else{
                       self.dealerCardViews[i].image = dealerCard.getCardImage()
                    }
                }else{
                    dealerCardViews[i].image = UIImage(named: "card-back.png")
                }
            }else{
                dealerCardViews[i].isHidden = true
            }
            
            if let playerCard = gameModel.playerCardAtIndex(i){
                if playerCardView[i].isHidden == true{
                    isPresent = true
                }
                else {
                    isPresent = false
                }
                playerCardView[i].isHidden = false
                if(playerCard.isFaceUp){
                    if (self.playerCardView[i].image == UIImage(named:"card-back.png") || isPresent){
                        UIView.transition(with: playerCardView[i],
                                      duration: 1,
                                      options:UIViewAnimationOptions.transitionFlipFromLeft,
                                      animations: {self.playerCardView[i].image = playerCard.getCardImage() },
                                      completion: nil)
                    }
                    else{
                        playerCardView[i].image = playerCard.getCardImage()
                    }
                }else{
                    playerCardView[i].image = UIImage(named: "card-back.png")
                }
            }else{
                playerCardView[i].isHidden = true
            }
            remainingCards.text = String(gameModel.cardRemaining)
        }
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restartNewGame()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
