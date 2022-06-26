//
//  AddToyViewController.swift
//  Toys
//
//  Created by Luiz Valdemar da Silva on 26/06/22.
//

import UIKit
import Firebase
import FirebaseFirestore

class AddToyViewController: UIViewController {
    
    let toyListCollection = "toys"
    // var toy: ToyItem!
    
    lazy var firestore: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        // settings.areTimestampInSnapshotsEnabled = true
        let firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()
    
    var firestoreListener: ListenerRegistration!
    
    @IBOutlet weak var tfToyName: UITextField!
    @IBOutlet weak var scStatus: UISegmentedControl!
    @IBOutlet weak var tfAddedByUser: UITextField!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func saveData(item: ToyItem?){
        
        var sc: String = ""
        switch scStatus.selectedSegmentIndex{
        case 0:
                sc = "Novo"
        case 1:
                sc = "Usado"
        default:
                sc = "Precisa de Reparo"
        
        }
        
        let data: [String: Any] = [
            "toyName" : tfToyName.text!,
            "status" : sc,
            "addedByUser" : tfAddedByUser.text!,
            "address" : tfAddress.text!,
            "phoneNumber" : tfPhoneNumber.text!
        ]
        
         self.firestore.collection(self.toyListCollection).addDocument(data: data)
        
    }
    
    func goBack(){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func addItemToy(_ sender: UIButton) {
        
       saveData(item: nil)
        goBack()
        
    }
    
 
}
