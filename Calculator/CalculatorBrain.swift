//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Devorah Langsam on 5/3/16.
//  Copyright © 2016 Devorah. All rights reserved.
//

import Foundation


func factorial(operand: Double) -> Double {
    if (operand <= 1){return 1}
    else{ return operand * (factorial(operand - 1))}
}

class CalculatorBrain {
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    private var isPartialResult: Bool {
        get{
            return pending != nil
        }
    }
    private var afterEqual = false
    private var orderOfOperations = [String]()
    
    func setOperand(operand: Double){
        orderOfOperations.append(String(operand))
        internalProgram.append(operand)
        accumulator = operand
    }
    
    func setOperand(symbol: String){
        if(afterEqual){
            eraseCalculation()
        }
        variableValues[symbol] = variableValues[symbol] ?? 0.0
        accumulator = variableValues[symbol]!
        orderOfOperations.append(symbol)
        internalProgram.append(symbol)
     
    }
    
    var variableValues: Dictionary<String, Double> = [:]
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√": Operation.UnaryOperation(sqrt),
        "cos": Operation.UnaryOperation(cos),
        "sin": Operation.UnaryOperation(sin),
        "tan": Operation.UnaryOperation(tan),
        "1/x": Operation.UnaryOperation({1/$0}),
        "±": Operation.UnaryOperation({-1*$0}),
        "ln": Operation.UnaryOperation(log),
        "x!": Operation.UnaryOperation(factorial),
        "x²": Operation.UnaryOperation({$0 * $0}),
        "e^x": Operation.UnaryOperation({pow(M_E, $0)}),
        "xⁿ": Operation.BinaryOperation({pow($0, $1)}),
        "×": Operation.BinaryOperation({$0 * $1}),
        "÷": Operation.BinaryOperation({$0 / $1}),
        "+": Operation.BinaryOperation({$0 + $1}),
        "−": Operation.BinaryOperation({$0 - $1}),
        "=": Operation.Equals,
        "C": Operation.Clears
    ]
    private enum Operation{
        case Constant(Double)
        case UnaryOperation((Double) ->Double) //takes a bool that is true if the operation goes in the beginning
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clears
    }
    func checkIfAfterEqual(){
        if(afterEqual){
            eraseCalculation()
            afterEqual = false;
        }
        
    }
    func performOperations(symbol: String){
        internalProgram.append(symbol)
        if let operation  = operations[symbol]{
            switch operation{
                case .Constant(let value):
                    if(afterEqual){
                        eraseCalculation()
                    }
                    accumulator = value
                    if isPartialResult {orderOfOperations.append(symbol)}
                    else {orderOfOperations = [symbol]}
                    afterEqual = false;
                case .UnaryOperation(let function):
                    var insertIndex:Int = 0;
                    
                    if(isPartialResult){
                         let length = orderOfOperations.count
                         insertIndex = length-1
                    }
                    if(symbol == "x!"){
                      orderOfOperations.insert("(", atIndex: insertIndex)
                      orderOfOperations.append(")!")
                    }else if(symbol == "x²"){
                        orderOfOperations.insert("(", atIndex: insertIndex)
                        orderOfOperations.append(")²")

                
                    }else{
                      orderOfOperations.insert(symbol + "(", atIndex: insertIndex)
                      orderOfOperations.append(")")
                    }
                   
                    afterEqual = false
                    accumulator = function(accumulator)
                case .BinaryOperation(let function):
                    orderOfOperations.append(symbol)
                    executePendingBinaryOperation()
                    pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand:accumulator)
                    
                    afterEqual = false
                case .Equals:
                    executePendingBinaryOperation()
                    afterEqual = true
                case .Clears:
                    clear()
                
            }
        }
        
    }
 
    private func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
            
        }
    }

   
    private var pending: PendingBinaryOperationInfo?
    private struct PendingBinaryOperationInfo {
        var binaryFunction:(Double, Double)->Double
        var firstOperand: Double
    }
    private var description = ""
    private func createOrderOfOperationString() -> String{
        description = ""
        if orderOfOperations.isEmpty{ return description}
        for x in orderOfOperations{
            description += x
        }
        return description
        
    }
    var getDescription: String {
        get{
            
 
            print("get description: " + description)
            if orderOfOperations.isEmpty {return " "}
            else if isPartialResult { return description + "..."}
            else{ return description + "="}
        }
    }
    typealias PropertyList = AnyObject
    var program: PropertyList{
        get {
            //returns a copy of the array
            return internalProgram
        }
        set {
            print("Set program")
            eraseCalculation()
            if let arrayOfOps = newValue as? [AnyObject]
            {
                for op in arrayOfOps{
                    if let operand = op as? Double{
                        setOperand(operand)
                    }else if let variableName = op as? String{
                        if variableValues[variableName] != nil{
                            setOperand(variableName)
                        }else if let operation = op as? String{
                            performOperations(operation)
                        }
                    }
                }
            }
        }
    }
    private func eraseCalculation(){
        print("Erase Calculation")
        accumulator = 0.0
        
        orderOfOperations = []
        pending = nil

         internalProgram.removeAll()
       
    }
    func clear(){
        print("Clear")
        accumulator = 0
        pending = nil
        internalProgram.removeAll()
        variableValues.removeAll()
        orderOfOperations = []
        

        
    }
    func undo(){
        print("Undo")
        if !internalProgram.isEmpty{
            createOrderOfOperationString()
            print("pre undo: " + description)
            internalProgram.removeLast()
            internalProgram.removeLast()
            orderOfOperations.removeLast()
            createOrderOfOperationString()
            print("post undo: " + description)
            program = internalProgram
             accumulator = 0
            
        }else{
            clear();
        }
        afterEqual = false
    }
    var result: Double {
        get {
            createOrderOfOperationString()
            print("get result: " + description)
            print("accumulaltor: " + String(accumulator))
            return accumulator
        }
    }
    
}