//
//  RegisterViewController.swift
//  Shishka
//
//  Created by Daria Tsenter on 10/11/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var registerName: UITextField!
    @IBOutlet weak var registerLastName: UITextField!
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerConfirmEmail: UITextField!
    @IBOutlet weak var registerDOB: UITextField!
    @IBOutlet weak var connectInstagram: UIButton!
    @IBOutlet weak var connectYoutube: UIButton!
    
    private var datePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(RegisterViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        registerDOB.inputView = datePicker
        // Do any additional setup after loading the view.
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        registerDOB.text = dateFormatter.string(from: datePicker.date)
    }

}
