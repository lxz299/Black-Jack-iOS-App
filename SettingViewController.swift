//
//  SettingViewController.swift
//  BlackJack
//
//  Created by Liuming Zhao on 3/21/17.
//  Copyright © 2017 CBC.case.edu. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var editAndDoneButton: UIBarButtonItem!
    
    
    @IBOutlet weak var numberOfDecks: UITextField!
    @IBOutlet weak var threshold: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.editAndDoneButton.title = "edit"
        self.numberOfDecks.isHidden = true
        self.threshold.isHidden = true
        if let pvc = getPreviousController() as! BJViewController? {
            self.numberOfDecks.text = String(pvc.numOfDecks)
            self.threshold.text = String(pvc.threshold)
        }
    }

    

    @IBAction func editAndDone(_ sender: UIBarButtonItem) {
        if self.editAndDoneButton.title == "edit" {
            self.editAndDoneButton.title = "done"
            self.numberOfDecks.isHidden = false
            self.threshold.isHidden = false
        }
        else if self.editAndDoneButton.title == "done" {
            if let nod = Int(numberOfDecks.text!), let thres = Int(threshold.text!) {
            if let pvc = getPreviousController() as! BJViewController? {
                pvc.numOfDecks = nod
                pvc.threshold = thres
                pvc.restartNewGame()
            }
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            }
        }
    }
    
    func getPreviousController() -> UIViewController? {
        let numberOfViewControllers = self.navigationController?.viewControllers.count
        if numberOfViewControllers! < 2 {
            return nil
        }
        else {
        return self.navigationController?.viewControllers[numberOfViewControllers! - 2]
        }
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
