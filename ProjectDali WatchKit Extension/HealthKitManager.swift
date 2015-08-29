//
//  HealthKitManager.swift
//  ProjectDali
//
//  Created by William Robinson on 07/07/2015.
//  Copyright © 2015 William Robinson. All rights reserved.
//

import WatchKit
import HealthKit

protocol HealthKitManagerDelegate: class {
    func healthKitManager(controller: HealthKitManager, receivedNewHeartRateValue heartRateValue: Double)
    func healthKitManager(controller: HealthKitManager, workoutDidStartAtDate workoutStartDate: NSDate)
    func healthKitManagerWorkoutFailedToStart(controller: HealthKitManager)
    func healthKitManagerWorkoutStopped(controller: HealthKitManager)

}

class HealthKitManager: NSObject, HKWorkoutSessionDelegate {

    let healthStore: HKHealthStore = HKHealthStore()
    
    let heartRateType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
    let heartRateUnit = HKUnit(fromString: "count/min")

    var queries: [HKQuery] = []
    var heartRateSessionSamples: [HKQuantitySample] = []
    
    weak var delegate: HealthKitManagerDelegate?

    
    
    
//    var heartRateSessionValues: [Double] = []
    
    
    
    var anchor = 0
    
    
    
    
    var workoutSession: HKWorkoutSession

    var workoutStartDate: NSDate?
    var workoutEndDate: NSDate?
    var oneHourAfterWorkoutStartDate: NSDate?
    
    
    override init() {
        workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.PreparationAndRecovery, locationType: HKWorkoutSessionLocationType.Indoor)
        super.init()
        workoutSession.delegate = self
    }
    
    
    
    

    // MARK: - HealthKit Helpers
    
    func checkForHealthKitCapabilities() -> Bool {
        
        print("Is HealthKit available: \(HKHealthStore.isHealthDataAvailable())")
        
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func requestHealthKitAccess() {
        
        let typesToShare = Set([
            self.heartRateType,
            ])
        
        let typesToRead = Set([
            self.heartRateType,
            ])
        
        self.healthStore.requestAuthorizationToShareTypes(typesToShare, readTypes: typesToRead) {
            success, error in
            print("We got here")

            if error != nil {
                print("RequestHealthKit \(error)")
            } else {
                print("We got access")
            }
            
        }
    }
    
    func checkAuthorizationOfHealthKitAccess() -> Bool {
        
        let authorizationStatus = self.healthStore.authorizationStatusForType(heartRateType)
        var authorization = false
        if authorizationStatus == HKAuthorizationStatus.SharingDenied {
            
            print("HealthKit sharing Denied")
            return authorization
            
        } else if authorizationStatus == HKAuthorizationStatus.NotDetermined {
            
            print("HealthKit sharing Not Determined")
            return authorization

        } else {
            
            authorization = true
            return authorization
        }
    }
    
    func createStreamingHeartRateQuery(workoutStartDate: NSDate) -> HKQuery {
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(workoutStartDate, endDate: nil, options: .None)
        var anchorValue = Int(HKAnchoredObjectQueryNoAnchor)
        if anchor != 0 {
            anchorValue = self.anchor
        }
        
        let heartRateQuery = HKAnchoredObjectQuery(type:self.heartRateType, predicate: predicate, anchor: anchorValue, limit: 0) {
            (query, samples, deletedObjects, anchor, error) -> Void in
            
            if error != nil {
                print("heartRateQuery \(error)")
            }
            
            self.anchor = anchorValue
        }
        
        // Create update block
        heartRateQuery.updateHandler = {(query, samples, deletedObjects, anchor, error) -> Void in
            
            if error != nil {
                print("updateHandler \(error)")
            }
            
            self.anchor = anchor
            self.addHeartRateSamples(samples)
        }
        
        return heartRateQuery
    }
    
    func addHeartRateSamples(samples: [HKSample]?) {
        
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        dispatch_async(dispatch_get_main_queue()) {
            
            print("heart rate samples = \(heartRateSamples)\n")
            
            let sample = heartRateSamples.first
            
            if sample != nil {
                
                let heartRateValue = sample!.quantity.doubleValueForUnit(self.heartRateUnit)
                print("Heart rate: \(heartRateValue)")

                self.heartRateSessionSamples.append(sample!)
                self.delegate?.healthKitManager(self, receivedNewHeartRateValue: heartRateValue)
                
            } else {
                
                print("No heart data.")
            }
        }
    }
    
    // MARK: - WorkoutSessionDelegates
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        
        print("To State \(toState.rawValue), from state \(fromState.rawValue), on date \(date)\n")
        
        switch toState {
        case .Running:
            // Workout has changed to running
            self.workoutDidStart(date)
            
        case .Ended:
            // Workout has changed to stopped
            self.workoutDidStop(date)
            
        default:
            print("workoutSessionDidChangeToState \(toState)\n")
        }
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        
        print("workoutSessionDidFailWithError \(error)\n")
    }
    
    func workoutDidStart(date: NSDate) {
        
        // Workout started, make a query to get HeartRate data
        self.workoutStartDate = date
        self.delegate?.healthKitManager(self, workoutDidStartAtDate: self.workoutStartDate!)
        
        let query = self.createStreamingHeartRateQuery(date)
        queries.append(query)
        self.healthStore.executeQuery(query)
        
        
    }
    
    func workoutDidStop(date: NSDate) {
        
        // Workout stopped, stop all queries for HeartRate data
        
        self.workoutEndDate = date
        
        self.healthStore.stopQuery(queries.first!)
        queries.removeAll()
        
        self.createNewWorkoutSession()
        
        self.delegate?.healthKitManagerWorkoutStopped(self)
    }
    
    func saveWorkout() {
        
        // Can't really save a workout because it needs energy, distance etc, so use this to save heartRate samples
        
        if self.heartRateSessionSamples.count == 0 {
            
            for var i = 0; i < 10; i++ {
                
                let heartRateType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
                let heartRateQuantity = HKQuantity(unit: heartRateUnit, doubleValue: Double(arc4random_uniform(100)))
                
                
                //let heartRateQuantity = HKQuantity(unit: heartRateUnit (), doubleValue: Double(arc4random_uniform(100)))
                let heartRateSample = HKQuantitySample(type: heartRateType!, quantity: heartRateQuantity, startDate: self.workoutStartDate!, endDate: NSDate())
                self.heartRateSessionSamples.append(heartRateSample)
            }
        }
        
        self.healthStore.saveObjects(self.heartRateSessionSamples, withCompletion: {
            (success, error) -> Void in
            
            if (success) {
                print("Success")
            } else {
                print("Error saving HeartRates \(error)")
            }
        })
    }
    
    func createNewWorkoutSession() {
        
        // workoutSessions cannot be reused, so create a new one
        self.workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.Other, locationType: HKWorkoutSessionLocationType.Indoor)
        self.workoutSession.delegate = self
    }
    
    func startWorkout() {
        
        self.healthStore.startWorkoutSession(self.workoutSession) {
            success, error in
            
            if error != nil {
                print("startWorkoutSession \(error)")
            }
        }
    } 
    
    func stopWorkout() {
        
        self.healthStore.endWorkoutSession(self.workoutSession) {
            success, error in
            
            if error != nil {
                print("stopWorkoutSession \(error)")
            }
        }
    }
}
