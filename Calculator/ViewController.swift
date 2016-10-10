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
    
    private func updateUI() {
        displayValue = brain.result
        procedure.text = brain.getDescription
    }
 
    
   
     private var brain = CalculatorBrain()
    @IBAction private func touchDigit(sender: UIButton) {
        
        brain.checkIfAfterEqual()
        let digit = sender.currentTitle!
        if(userInMiddleOfTyping){
            let textCurrentlyInDisplay = display.text!
            if textCurrentlyInDisplay.containsString(".") && digit == "." {return}
            display.text = textCurrentlyInDisplay + digit
        }else{
            if digit == "."{
                display.text = "0."
            }else{
                display.text = digit
            }
        }
        userInMiddleOfTyping = true
       
        
    }
    private var displayValue: Double? {
        get{
            return Double(display.text!)!
        }
        set{
            display.text = newValue != nil ? String(newValue!) : " "
        }
    }
    //code not needed for assignment
    var savedProgram: CalculatorBrain.PropertyList?
    @IBAction func save() {
        savedProgram = brain.program
    }
    @IBAction func restore() {
        if savedProgram != nil{
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    @IBAction private func performOperation(sender: UIButton) {
        

        if userInMiddleOfTyping{
            brain.setOperand(displayValue!)
        }

        userInMiddleOfTyping = false
        if let mathSymbol = sender.currentTitle{
            brain.performOperations(mathSymbol)
        }
         displayValue = brain.result
        procedure.text = brain.getDescription 
    }
    @IBAction func setVariable() {
        brain.variableValues["M"] = displayValue
        if userInMiddleOfTyping {
            userInMiddleOfTyping = false
        }else{
            //brain.undo()
        }
        brain.program = brain.program

        updateUI()
        
    }
    @IBAction func getVariable() {
    
        brain.setOperand("M")
        userInMiddleOfTyping = false
        updateUI()
    }
    
    @IBAction func backspace(sender: UIButton) {
        
        guard userInMiddleOfTyping == true else {
            brain.undo()
            updateUI()
            return
        }
        
        guard var number = display.text else {
            return
        }
        
        number.removeAtIndex(number.endIndex.predecessor())
        if number.isEmpty {
            number = "0"
            userInMiddleOfTyping = false
        }
        display.text = number
        
    }
    
    
}

