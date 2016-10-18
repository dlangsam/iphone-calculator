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
    private var tempProgram = [AnyObject]()
    private var isPartialResult: Bool {
        get{
            return pending != nil
        }
    }
    private var afterEqual = false
    
    func setOperand(operand: Double){
        if(afterEqual){
            tempProgram = internalProgram
            internalProgram.removeAll()
        }
        internalProgram.append(operand)
        accumulator = operand
        afterEqual = false
    }
    
    func setOperand(symbol: String){
        variableValues[symbol] = variableValues[symbol] ?? 0.0
        accumulator = variableValues[symbol]!
        if(afterEqual){
            tempProgram = internalProgram
            internalProgram.removeAll()
        }
        internalProgram.append(symbol)
        afterEqual = false
    }
    
    var variableValues: Dictionary<String, Double> = [:]
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√": Operation.UnaryOperation(sqrt),
        "cos": Operation.UnaryOperation(cos),
        "sin": Operation.UnaryOperation(sin),
        "tan": Operation.UnaryOperation(tan),
        "x⁻¹": Operation.UnaryOperation({1/$0}),
        "±": Operation.UnaryOperation({-1*$0}),
        "ln": Operation.UnaryOperation(log),
        "x!": Operation.UnaryOperation(factorial),
        "x²": Operation.UnaryOperation({$0 * $0}),
        "eⁿ": Operation.UnaryOperation({pow(M_E, $0)}),
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
    func performOperations(symbol: String){
    
        internalProgram.append(symbol)

        if let operation  = operations[symbol]{
            switch operation{
                case .Constant(let value):
                    if(afterEqual){
                        tempProgram = internalProgram
                        internalProgram.removeAll()
                        internalProgram.append(symbol)
                    }
                    accumulator = value
                    afterEqual = true;
                case .UnaryOperation(let function):
                    afterEqual = true
                    accumulator = function(accumulator)
                case .BinaryOperation(let function):
                    executePendingBinaryOperation()
                    pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand:accumulator)
                    afterEqual = false
                case .Equals:
                    tempProgram = internalProgram
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
        description = " "
        if internalProgram.isEmpty{ return description}
        var orderOfOperations = [String]()
        var recentEqual = false;
        var numDigits = 0;

        for op in internalProgram{
            if (op as? Double) != nil{
                orderOfOperations.append(String(op))
                numDigits += 1
            }else if let variableName = op as? String{
                if variableValues[variableName] != nil{
                    orderOfOperations.append(variableName)
                    recentEqual = false;
                    numDigits = 1
                }else if var operation = op as? String{
                    if(operation == "="){
                        orderOfOperations.insert("(", atIndex: 0)
                        orderOfOperations.append(")")
                        recentEqual = true;
                    }else if(operation == "tan" || operation == "sin" || operation == "cos"
                        || operation == "ln" || operation == "√" ||
                        operation ==  "±" || operation ==  "eⁿ"){
                        if(operation ==  "eⁿ"){
                            operation = "e^"
                        }
                        if(recentEqual){
                            orderOfOperations.insert(operation, atIndex: 0)
                             orderOfOperations.append(")")
                        }else{
                            let length = orderOfOperations.count
                            orderOfOperations.insert(operation + "(", atIndex: length - numDigits)
                             orderOfOperations.append(")")
                        }
                        recentEqual = true;
                    }else{
                        if(operation == "x!"){
                            operation = "!"
                        }else if(operation == "x²"){
                            operation = "²"
                        }
                        else if(operation == "x⁻¹"){
                            operation = "⁻¹"
                        }
                        else if(operation == "xⁿ"){
                            operation = "^"
                        }
                        orderOfOperations.append(operation)
                        recentEqual = false;
                    }
                    numDigits = 0
                }
            }
        }
        
        for x in orderOfOperations{
            description += x
        }
//        var temp = ""
//        for y in internalProgram{
//            temp += String(y)
//        }
//        print("Current program")
//        print(temp)

        return description
        
    }
    var getDescription: String {
        get{
            if internalProgram.isEmpty{return description}
            else if isPartialResult { return description + "..."}
            else{ return description + "="}
            
        }
    }
    typealias PropertyList = AnyObject
    var program: PropertyList{
        get {
            return internalProgram
        }
        set {
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
    func eraseCalculation(){
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    func clear(){
       eraseCalculation()
       variableValues.removeAll()
    }
    func restore(){
        internalProgram = tempProgram;
    }
    func undo(){
            if !internalProgram.isEmpty{
            internalProgram.removeLast()
            if(!internalProgram.isEmpty){
                internalProgram.removeLast()

            }
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
            return accumulator
        }
    }
    
}