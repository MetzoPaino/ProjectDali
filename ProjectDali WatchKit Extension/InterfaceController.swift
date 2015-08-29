//
//  InterfaceController.swift
//  ProjectDali WatchKit Extension
//
//  Created by William Robinson on 27/06/2015.
//  Copyright © 2015 William Robinson. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate, HealthKitManagerDelegate {

    // Outlets
    
    // Start
    @IBOutlet var startGroup: WKInterfaceGroup!
    @IBOutlet var startButton: WKInterfaceButton!
    
    // Workout
    @IBOutlet var workoutGroup: WKInterfaceGroup!
    @IBOutlet var stopButton: WKInterfaceButton!
    @IBOutlet var microphoneButton: WKInterfaceButton!
    @IBOutlet var forceTouchInfoButton: WKInterfaceLabel!
    @IBOutlet var printLabel: WKInterfaceLabel!
    @IBOutlet var monitorLabel: WKInterfaceLabel!
    
    let healthKitManager = HealthKitManager()
    var workoutStartLoggingDate: NSDate?
    var heartRateValues: [Double] = []
    var timesTriggered = 0
    var topBoundary = 100.0

    var workoutIsOn = false
    var interfaceIsLocked = false
    var inWakeupState = false
    
    var buttonColorBeforeLock = UIColor()
    
    let standardDeviationCalculator = StandardDeviationCalculator()
    var timer: NSTimer?
    var timerCreationDate: NSDate?
    var timerCutOffDate: NSDate?
    
    var session : WCSession!

    
    
    override init() {
        super.init()
        healthKitManager.delegate = self
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
       
        self.setupView()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        if healthKitManager.checkForHealthKitCapabilities() {
            print("HealthKit is available")
            self.printLabel.setText("HealthKit is available")
            self.printLabel.setTextColor(UIColor.greenColor())
            
            // If device has HealthKit capabilities request access
            healthKitManager.requestHealthKitAccess()
            
        } else {
            print("HealthKit not available")
            self.printLabel.setText("HealthKit not available")
            self.printLabel.setTextColor(UIColor.redColor())
            
            return
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    

        
        if workoutIsOn {
            
            // If in a workout and viewing screen, update as it will hold values of last viewed
            self.refreshView()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func setupView() {
        
        self.startGroup.setRelativeHeight(1, withAdjustment: 0)
        self.workoutGroup.setRelativeHeight(0, withAdjustment: 0)
        
        // Setup button
        self.startButton.setTitle("Start workout")
        self.startButton.setBackgroundColor(UIColor.greenColor())
        
        // Setup printLabel
        self.printLabel.setText("")
        
        // Setup monitorLabel
        self.monitorLabel.setText("")
    }
    
    func setupViewForStartWorkout() {
        self.clearAllMenuItems()
        self.startGroup.setRelativeHeight(1, withAdjustment: 0)
        self.workoutGroup.setRelativeHeight(0, withAdjustment: 0)
        
    }
    
    func setupViewForWorkout() {
        
        self.addMenuItemWithItemIcon(WKMenuItemIcon.Add, title: "Lock", action: "toggleInterfaceLock")
        self.startGroup.setRelativeHeight(0, withAdjustment: 0)
        self.workoutGroup.setRelativeHeight(1, withAdjustment: 0)

    }
    
    func refreshView() {
        
        let value = self.heartRateValues.last
        self.monitorLabel.setText("Heart rate: \(value) Values: \(self.heartRateValues.count)\n Boundary: \(self.topBoundary)")

    }
    

    
    // MARK: - IBActions
    
    @IBAction func startWorkoutPressed() {
        
        if interfaceIsLocked {
            
            return
        }
        

        let healthKitAuthorization = healthKitManager.checkAuthorizationOfHealthKitAccess()
        
        if healthKitAuthorization {
            
            // Toggle workout bool
            self.workoutIsOn = true
            WKInterfaceDevice.currentDevice().playHaptic(.Start)
            
            if workoutIsOn {
                
                // Start workoutSession
                healthKitManager.startWorkout()
                self.setupViewForWorkout()
                
            } else {
                
                // Shouldn't have been able to end up in this situation
                print("Error: Start button tried to stop workout")
            }
            
        } else {
            
            // We don't have access to HealthKit so move to view asking for it
            self.pushControllerWithName("RequestHealthKitAccessIC", context: nil)
            return
        }
        
    }
    
    @IBAction func stopWorkoutPressed() {
        
        if interfaceIsLocked {
            
            return
        }
        
        // Stop workoutSession
        healthKitManager.stopWorkout()
        
    }
    @IBAction func userPressedMicrophone() {
        
//        let directory = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.extensiontexttaker")
//        let timeAtRecording = NSDate.timeIntervalSinceReferenceDate()
//        let recordingName = "AudioRecording-\(timeAtRecording).mpf"
//        
//        let url = directory?.URLByAppendingPathComponent(recordingName)
        
        if interfaceIsLocked {
            
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        let container = fileManager.containerURLForSecurityApplicationGroupIdentifier("group.extensiontexttaker")!
        let timeAtRecording = NSDate.timeIntervalSinceReferenceDate()
        let recordingName = "AudioRecording-\(timeAtRecording)"
        let fileName = recordingName.stringByAppendingPathExtension("mp4")
        let url = container.URLByAppendingPathComponent(fileName!)
        
        self.presentAudioRecordingControllerWithOutputURL(url, preset: WKAudioRecordingPreset.NarrowBandSpeech, maximumDuration: 60.0, actionTitle: "Save") {
                didSave, error in
            
            
            if error != nil {
                print("Audio recording: \(error)")

            } else {
                
                // Transfer the file to iPhone
                let metadata = ["App": "Dali"]
                
//                let fileTransfer = WCSession.defaultSession().transferFile(url, metadata: metadata)

                self.session.transferFile(url, metadata: metadata)
//                do {
//                    try self.session.transferFile(url, metadata: metadata)
//
//
//                } catch {
//                    
//                    print("error "\(error))
//                }
                
                // There is a method to look at what is outstanding
            }
            
        }
    }
    
    @IBAction func toggleInterfaceLock() {
        
        
        interfaceIsLocked = !interfaceIsLocked
        
        if interfaceIsLocked {
            
            // Setup button

            if workoutIsOn {
                buttonColorBeforeLock = UIColor.redColor()
            } else {
                buttonColorBeforeLock = UIColor.greenColor()
            }
            
            self.startButton.setBackgroundColor(UIColor.grayColor())
            
        } else {
            
            // Setup button
            self.startButton.setBackgroundColor(buttonColorBeforeLock)
        }
    }
    
    // MARK: Haptics
    
    func playHaptics() {
        
        //Do not use this method while gathering heart rate data using Health Kit. When you engage the haptic engine, WatchKit stops gathering heart rate data until after the haptic engine finishes.
        print("PlayHaptics")
        WKInterfaceDevice.currentDevice().playHaptic(.Notification)
        WKInterfaceDevice.currentDevice().playHaptic(.Start)
        timesTriggered++
    }
    
    // MARK: Timer
    
    func updateHapticTimer() {
        
        if let timerCutOffDate = self.timerCutOffDate {

            let currentDate = NSDate()
            
            let dateComparison = currentDate.compare(timerCutOffDate)
            
            if dateComparison == NSComparisonResult.OrderedDescending {
                
                // current date is past the timerCutOffDate
                timer?.invalidate()
                inWakeupState = false
                self.monitorLabel.setTextColor(UIColor.redColor())

            } else {
                
                self.playHaptics()
                self.monitorLabel.setTextColor(UIColor.blueColor())
            }
        }
    }
    
    // MARK: HealthKitManager Delegates
    
    func healthKitManager(controller: HealthKitManager, receivedNewHeartRateValue heartRateValue: Double) {
        
        self.heartRateValues.append(heartRateValue)
        self.topBoundary = self.standardDeviationCalculator.findTopBoundaryFromValues(self.heartRateValues)
        let truncatedBoundaryString = (String(format: "%.2f", self.topBoundary))
        
        self.monitorLabel .setText("Heart rate: \(heartRateValue)bpm\nValues: \(heartRateValues.count)\nTop boundary: \(truncatedBoundaryString)\nTimes triggered: \(timesTriggered)")
        
        if inWakeupState {
            return
        }
        
        if let workoutStartLoggingDate = self.workoutStartLoggingDate {
            
            let currentDate = NSDate()
            
            let dateComparison = currentDate.compare(workoutStartLoggingDate)
            
            if dateComparison == NSComparisonResult.OrderedDescending {
                
                // current date is past the workoutStartLoggingDate
                
                if heartRateValue > topBoundary {
                    
                    inWakeupState = true
                    
                    // Set timer off for 1 minute
                    
                    self.timerCreationDate = NSDate()
                    let calendar = NSCalendar.autoupdatingCurrentCalendar()
                    self.timerCutOffDate = calendar.dateByAddingUnit(NSCalendarUnit.Minute, value: 1, toDate: self.timerCreationDate!, options: [])

                    self.timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("updateHapticTimer"), userInfo: nil, repeats: true)

                }

//                NSProcessInfo.processInfo().performActivityWithOptions(<#T##options: NSActivityOptions##NSActivityOptions#>, reason: <#T##String#>, usingBlock: <#T##() -> Void#>)
            }
        }
    }
    
    func healthKitManager(controller: HealthKitManager, workoutDidStartAtDate workoutStartDate: NSDate) {
        
        let calendar = NSCalendar.autoupdatingCurrentCalendar()
//        self.oneHourAfterWorkoutStartDate = calendar.dateByAddingUnit(NSCalendarUnit.Hour, value: 1, toDate: workoutStartDate, options: [])
        self.workoutStartLoggingDate = calendar.dateByAddingUnit(NSCalendarUnit.Minute, value: 1, toDate: workoutStartDate, options: [])

    }
    
    func healthKitManagerWorkoutFailedToStart(controller: HealthKitManager) {
        
        print("Unhandled error, workout failed to start")
    }
    
    func healthKitManagerWorkoutStopped(controller: HealthKitManager) {
        
        self.workoutIsOn = false

        let saveAction = WKAlertAction(title: "Save", style: WKAlertActionStyle.Default, handler: { () -> Void in
            
            self.healthKitManager.saveWorkout()
        })
        
        let dontSaveAction = WKAlertAction(title: "Don't save", style: WKAlertActionStyle.Destructive, handler: { () -> Void in
            
        })
        
        self.presentAlertControllerWithTitle("Alert", message: "Do you want to save your heart rate data to your Health app?", preferredStyle: WKAlertControllerStyle.Alert, actions: [dontSaveAction, saveAction])
        self.setupViewForStartWorkout()

    }
}
