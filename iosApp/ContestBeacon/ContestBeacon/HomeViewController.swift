//
//  HomeViewController.swift
//  ContestBeacon
//
//  Created by Jim Sugg on 2/21/17.
//  Copyright © 2017 BrightSign, LLC. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController, BTBeaconManagerDelegate {
    
    var contestManager = ContestManager.sharedInstance

    @IBOutlet weak var currentMessage: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    fileprivate var messageFontSize : CGFloat = 0
    
    fileprivate var currentBeaconAppId : String?
    fileprivate var currentBeaconProximity : CLProximity = .unknown
    fileprivate var lastBeaconProximity : CLProximity = .unknown
    
    fileprivate var lastNotificationTime : Date = Date(timeIntervalSinceReferenceDate: 0)
    let minimumNotificationAlertInterval : TimeInterval = 60 * 15
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.beaconRegionMapUpdated(_:)), name: NSNotification.Name(rawValue: "updateBeaconRegionMap"), object: nil)
        UpdateMessage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BTBeaconManager.sharedInstance.delegate = self
        startMonitoringForBrightSign()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startMonitoringForBrightSign() {
        BTBeaconManager.sharedInstance.startBeaconMonitoring(BTBeaconManager.bsIdentifier)
    }
    
    func stopMonitoringForBrightSign() {
        BTBeaconManager.sharedInstance.stopBeaconMonitoring(BTBeaconManager.bsIdentifier)
        currentBeaconProximity = .unknown
    }
    
    func UpdateMessage() {
        if contestManager.participant.isValid {
            if currentBeaconProximity == .near {
                currentMessage.text = "Congratulations! You’ve been added to today’s prize drawing. The daily winner will be announced at 5pm in the BrightSign booth."
            } else {
                if currentBeaconProximity == .far {
                    if lastBeaconProximity == .near {
                        currentMessage.text = "Thanks for visiting BrightSign. Enjoy your time at the show!"
                    } else {
                        currentMessage.text = "Almost there! Come closer to the BrightBeacon™ demo in BrightSign booth for your chance to win today’s daily prize!"
                    }
                } else {
                    currentMessage.text = "Be sure to visit the BrightSign booth and find the BrightBeacon™ demo for a chance to win a great prize."
                }
            }
            actionButton.setTitle("Edit Contact Info", for: UIControlState())
        } else {
            if currentBeaconProximity == .unknown {
                currentMessage.text = "Please provide your contact information so we can enter you to win the daily prize from BrightSign at InfoComm 2016!"
            } else {
                currentMessage.text = "Hello! You are connected to BrightBeacon™. Please provide your contact information so we can enter you to win the daily prize!"
            }
            actionButton.setTitle("Enter Contact Info", for: UIControlState())
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EnterParticipantDetail" {
            if let participantView = sender as? ParticipantViewController {
                // Create a new participant object for the view
                // It is initialized with current stored values
                participantView.participant = Participant()
            }
        }
    }
    
    @IBAction func submitContactInfo(_ segue: UIStoryboardSegue) {
        if let participantView = segue.source as? ParticipantViewController {
            contestManager.updateParticipant(participantView.participant)
            UpdateMessage()
        }
    }
    
    @IBAction func cancelContactInfo(_ segue: UIStoryboardSegue) {
        
    }
    
    
    // MARK: - Beacon manager delegate
    
    // When we enter the region, we will display an alert
    func beaconManager(_ manager: BTBeaconManager, didEnterRegion beaconRegion: CLBeaconRegion)
    {
        var notification : UILocalNotification?
        
        if !manager.isRangingForRegion(beaconRegion) {
            manager.startRangingForRegion(beaconRegion)
            // Display notification here only if app is in background, and only if we haven't displayed it
            //  in a while (so as not to be too annoying)
            if UIApplication.shared.applicationState != .active
                && -(lastNotificationTime.timeIntervalSinceNow) > minimumNotificationAlertInterval
            {
                notification = UILocalNotification()
                notification?.userInfo = ["display":false]
                notification!.alertBody = "Launch BrightBeacon and enter to win a prize!"
            }
        }
        
        if let notification = notification {
            lastNotificationTime = Date()
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
    func beaconManager(_ manager: BTBeaconManager, didExitRegion beaconRegion: CLBeaconRegion)
    {
        BBTLog.write("Exiting region for %@", beaconRegion.identifier)
        
        if manager.isRangingForRegion(beaconRegion) {
            manager.stopRangingForRegion(beaconRegion)
        }
    }
    
    // This notification handler will be called on every beacon ranging callback (typically about 1/second)
    // Here we determine the current beacon we need to monitor.
    // We will set the current beacon to the closest beacon available for the region.
    // For this project, we assume that there is only one beacon in the region, but since the BeaconRegionMap
    //  object can handle multiple beacons in a region, we note that we are asking for the closest here
    // Once we get that, we determine the current and previous proximity values for the beacon. These are used
    //  to determine the message we display.
    func beaconRegionMapUpdated(_ notification: Notification)
    {
        if let userInfo = notification.userInfo as? [String:AnyObject],
            let regionMap = userInfo["map"] as? BTBeaconRegionMap,
            let closestBeaconData = regionMap.closestBeacon
        {
            currentBeaconAppId = closestBeaconData.appId
            currentBeaconProximity = closestBeaconData.filteredProximityFactor
            lastBeaconProximity = closestBeaconData.previousProximityFactor
            UpdateMessage()
            
            if currentBeaconProximity == .near {
                contestManager.updateProximity(true)
            }
        } else {
            currentBeaconAppId = nil
            currentBeaconProximity = .unknown
            lastBeaconProximity = .unknown
        }
    }

}

