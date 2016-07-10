//
//  ViewController.swift
//  Calculator
//
//  Created by Devorah Langsam on 5/2/16.
//  Copyright © 2016 Devorah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var procedure: UILabel!
    
    @IBOutlet weak var display: UILabel!
    
    private var userInMiddleOfTyping = false
 
    
   
     private var brain = CalculatorBrain()
    @IBAction private func touchDigit(sender: UIButton) {
        
        brain.checkIfAfterEqual()
        let digit = sender.currentTitle!
        if(userInMiddleOfTyping){
            let textCurrentlyInDisplay = display.text!
            if textCurrentlyInDisplay.containsString(".") && digit == "." {return}
            display.text = textCurrentlyInDisplay + digit
        }else{
             display.text = digit
        }
        userInMiddleOfTyping = true
       
        
    }
    private var displayValue: Double {
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
        }
    }
    
   
    @IBAction private func performOperation(sender: UIButton) {
        

        if userInMiddleOfTyping{
            brain.setOperand(displayValue)
        }

        userInMiddleOfTyping = false
        if let mathSymbol = sender.currentTitle{
            brain.performOperations(mathSymbol)
        }
         displayValue = brain.result
        procedure.text = brain.getDescription 
    }
    
}

