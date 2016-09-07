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
    private var isPartialResult = true
    private var afterEqual = false
    private var orderOfOperations = [String]()
    
    func setOperand(operand: Double){
        orderOfOperations.append(String(operand))
        internalProgram.append(operand)
        accumulator = operand
    }
    
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
        //"x!": Operation.UnaryOperation(factorial),
        "x^2": Operation.UnaryOperation({$0 * $0}),
        "e^x": Operation.UnaryOperation({pow(M_E, $0)}),
        "x^y": Operation.BinaryOperation({pow($0, $1)}),
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
            clearCalc()
            afterEqual = false;
        }
        
    }
    func performOperations(symbol: String){
        internalProgram.append(symbol)
        if let operation  = operations[symbol]{
            switch operation{
                case .Constant(let value):
                    if(afterEqual){
                        clearCalc()
                    }
                    accumulator = value
                    if isPartialResult {orderOfOperations.append(symbol)}
                    else {orderOfOperations = [symbol]}
                    afterEqual = false;
                case .UnaryOperation(let function):
                
                    if(!isPartialResult){
                        orderOfOperations.insert(symbol + "(", atIndex: 0)
                        orderOfOperations.append(")")
                    }else{
                        let length = orderOfOperations.count
                        orderOfOperations.insert(symbol + "(", atIndex: length-1)
                        orderOfOperations.append(")")

                    }
                    afterEqual = false
                    accumulator = function(accumulator)
                case .BinaryOperation(let function):
                    orderOfOperations.append(symbol)
                    executePendingBinaryOperation()
                    pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand:accumulator)
                    isPartialResult = true
                    afterEqual = false
                case .Equals:
                    executePendingBinaryOperation()
                    isPartialResult = false
                    afterEqual = true
                case .Clears:
                    clearCalc()
                
            }
        }
        
    }
 
    private func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
            
        }
    }
    private func clearCalc(){
        accumulator = 0.0

        orderOfOperations = []
        pending = nil
        isPartialResult = true
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
            clear()
            if let arrayOfOps = newValue as? [AnyObject]
            {
                for op in arrayOfOps{
                    if let operand = op as? Double{
                        setOperand(operand)
                    }else if let operation = op as? String{
                        performOperations(operation)
                    }
                }
            }
        }
    }
    func clear(){
        accumulator = 0
        pending = nil
        internalProgram.removeAll()
    }
    var result: Double {
        get {
            createOrderOfOperationString()
            print(description)
            return accumulator
        }
    }
    
}