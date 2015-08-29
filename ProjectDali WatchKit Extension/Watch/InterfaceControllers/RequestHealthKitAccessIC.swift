//
//  RequestHealthKitAccessIC.swift
//  ProjectDali
//
//  Created by William Robinson on 11/07/2015.
//  Copyright © 2015 William Robinson. All rights reserved.
//

import WatchKit
import Foundation


class RequestHealthKitAccessIC: WKInterfaceController {

    @IBOutlet var healthKitGroup: WKInterfaceGroup!
    @IBOutlet var infoButton: WKInterfaceButton!
    @IBOutlet var healthKitTitleLabel: WKInterfaceLabel!
    @IBOutlet var healthKitLabel: WKInterfaceLabel!
    @IBOutlet var refreshHealthKitStatusButton: WKInterfaceButton!
    
    let healthKitManager = HealthKitManager()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        self.setupView()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func setupView() {
        
        let healthKitAuthorization = healthKitManager.checkAuthorizationOfHealthKitAccess()
        
        if healthKitAuthorization {
            

            return
            
        } else {
            
            self.healthKitTitleLabel.setText("😞")
        
            self.healthKitLabel.setText("ProjectDali needs permission to track your heart rate.\n\n Please visit the Health app on your iPhone.")
            healthKitManager.requestHealthKitAccess()
        }
    }

    // MARK: - IBActions
    
    @IBAction func refreshHealthKitStatusButtonPressed() {
        
        self.healthKitTitleLabel.setText("😐")
        
        let healthKitAuthorization = healthKitManager.checkAuthorizationOfHealthKitAccess()
        
        if healthKitAuthorization {
            
            self.healthKitTitleLabel.setText("😀")
            
            self.dismissController()
            self.popController()

        } else {
            
            self.healthKitTitleLabel.setText("😞")

        }
    }

}
