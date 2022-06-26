//
//  ToyTableViewController.swift
//  Toys
//
//  Created by Luiz Valdemar da Silva on 25/06/22.
//

import UIKit
import Firebase
import FirebaseFirestore

class ToyTableViewController: UITableViewController {
    
    let toyListCollection = "toys"
    var toyList: [ToyItem] = []
    
    lazy var firestore: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        // settings.areTimestampInSnapshotsEnabled = true
        let firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()
    
    var firestoreListener: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    func loadItems(){
        firestoreListener = firestore.collection(toyListCollection).order(by: "toyName").addSnapshotListener(includeMetadataChanges: true, listener: {
            (snapshot, error) in
            if error != nil {
                print("Firestore error: ", error!)
            } else {
                guard let snapshot = snapshot else {return}
                print("Total de mudanças:", snapshot.documentChanges.count)
                
                if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                    self.showItems(snapshot: snapshot)
                }
            }
        })
    } // Fim do metodo loadItems
    
    func showItems(snapshot: QuerySnapshot){
        toyList.removeAll()
        
        for document in snapshot.documents {
            let data = document.data()
            let toyName = data["toyName"] as! String
            let status = data["status"] as! String
            let addedByUser = data["addedByUser"] as! String
            let address = data["address"] as! String
            let phoneNumber = data["phoneNumber"] as! String
            let toyItem = ToyItem(toyName: toyName, status: status, addedByUser: addedByUser, address: address, phoneNumber: phoneNumber, id: document.documentID)
            toyList.append(toyItem)
        }
        tableView.reloadData()
    }
    
    // Metodo show alert
    func showAlert(item: ToyItem?){
        let alert = UIAlertController(title: "Alterar dados", message: "Informe os novos dados", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nome do Brinquedo"
            textField.text = item?.toyName
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Estado do brinquedo"
            textField.text = item?.status
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nome do Usuário"
            textField.text = item?.addedByUser
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Endereço"
            textField.text = item?.address
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Telefone para contato"
            textField.text = item?.phoneNumber
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) {(_) in
            guard let toyName = alert.textFields?.first?.text,
                  let status = alert.textFields?[1].text,
                  let addedByUser = alert.textFields?[2].text,
                  let address = alert.textFields?[3].text,
                  let phoneNumber = alert.textFields?.last?.text else {return}
            
            let data: [String: Any] = [
                "toyName" : toyName,
                "status" : status,
                "addedByUser" : addedByUser,
                "address" : address,
                "phoneNumber" : phoneNumber
            ]
            
            if let item = item {
                self.firestore.collection(self.toyListCollection).document(item.id).updateData(data)
            } else{
                self.firestore.collection(self.toyListCollection).addDocument(data: data)
            }
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Desativando acao do botao para nova chamada.
    /*
    @IBAction func addItem(_ sender: Any) {
        showAlert(item: nil)
    }
    */
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return toyList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let toyItem = toyList[indexPath.row]
        cell.textLabel?.text = toyItem.toyName
        cell.detailTextLabel?.text = toyItem.status

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toyItem = toyList[indexPath.row]
        showAlert(item: toyItem)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let toyItem = toyList[indexPath.row]
            firestore.collection(toyListCollection).document(toyItem.id).delete()
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
