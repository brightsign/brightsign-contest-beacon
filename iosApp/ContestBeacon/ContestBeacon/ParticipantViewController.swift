//
//  ParticipantViewController.swift
//  ContestBeacon
//
//  Created by Jim Sugg on 2/21/17.
//  Copyright © 2017 BrightSign, LLC. All rights reserved.
//

import UIKit

class ParticipantViewController: UIViewController, UITextFieldDelegate {
    
    var participant = Participant()

    @IBOutlet weak var participantName: UITextField!
    @IBOutlet weak var participantCompany: UITextField!
    @IBOutlet weak var participantEmail: UITextField!
    @IBOutlet weak var participantPhone: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        participantName.text = participant.name
        participantCompany.text = participant.company
        participantEmail.text = participant.email
        participantPhone.text = participant.phoneNumber
        
        if participant.name == nil || participant.name!.isEmpty {
            participantName.becomeFirstResponder()
        }
        else if participant.company == nil || participant.company!.isEmpty {
            participantCompany.becomeFirstResponder()
        }
        else if participant.phoneNumber == nil || participant.phoneNumber!.isEmpty {
            participantPhone.becomeFirstResponder()
        }
        else if participant.email == nil || participant.email!.isEmpty {
            participantEmail.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        participant.name = participantName.text
        participant.company = participantCompany.text
        participant.email = participantEmail.text
        participant.phoneNumber = participantPhone.text
    }

}
