//
//  StandardDeviationCalculator.swift
//  ProjectDali
//
//  Created by William Robinson on 04/07/2015.
//  Copyright © 2015 William Robinson. All rights reserved.
//

import WatchKit

class StandardDeviationCalculator: NSObject {

    var sumOfValues = 0.0
    var meanOfValues = 0.0
    var varianceOfValues = 0.0
    var standardDeviation = 0.0
    
    var valuesArray: [(value: Double, varianceFromMeanValue: Double)] = []

    func findTopBoundaryFromValues(values: [Double]) -> Double {
        
        sumOfValues = 0.0
        meanOfValues = 0.0
        varianceOfValues = 0.0
        standardDeviation = 0.0
        valuesArray.removeAll()
        // Create the sum, which we use for the average
        
        for value in values {
            
            sumOfValues += value
        }
        
        // Create the average
        
        meanOfValues = sumOfValues / Double(values.count)
        
        // Create an array containing all of the variances from the mean
        
        for value in values {
            
            let varianceFromMeanValue = value - self.meanOfValues
            valuesArray.append(value: value, varianceFromMeanValue: varianceFromMeanValue)
        }
        
        // Find the total variance
        
        for value in valuesArray {
            
            let squaredVariance = value.value * value.varianceFromMeanValue
            self.varianceOfValues += squaredVariance
        }
        
        // Average the variance
        
        self.varianceOfValues = self.varianceOfValues / Double(valuesArray.count)

        // Find the standard deviation by finding the square root of the variance
        
        self.standardDeviation = sqrt(self.varianceOfValues)

        // Create top boundary
        let topBoundary = self.meanOfValues + self.standardDeviation
        
        return topBoundary
    }
}
