//
//  ViewController.swift
//  ListApp
//
//  Created by ORKUN GÜNERİ on 9.11.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController  {
    
    var data = [NSManagedObject]()
    
    var alertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
    }
    
  
    @IBOutlet weak var tableView : UITableView!
    @IBAction func didRemoveBarButtonItemTapped(_ sender : UIBarButtonItem){
        presentAlert(title: "Uyarı!",
                     message: "Tüm Liste Silinecek",
                     prefferedStyle: .alert,
                     cancelButtonTitle: "Vazgeç",
                     defaultButtonTitle: "Sil",
                     defaultButtonHandler: { _ in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            for object in self.data { managedObjectContext!.delete(object) }
            try? managedObjectContext?.save()
            self.fetch()

        },
                     isTextFieldAvailable: false)
       
    }
    @IBAction func didAddButtonItemTapped(_ sender : UIBarButtonItem){
        presentAddAlert()
    }
    func presentAddAlert(){
      
        
        presentAlert(title: "Yeni Eleman Ekle",
                     message: nil,
                     cancelButtonTitle: "Vazgeç",
                     defaultButtonTitle: "Ekle", defaultButtonHandler: { _ in
            let text = self.alertController.textFields?.first?.text
            if text != "" {
                
                //self.data.append((text)!)
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!)
                let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                listItem.setValue(text, forKey: "title")
                try? managedObjectContext?.save()
                self.fetch()
            }
            else {
                self.presentWarningAlert()
            }
        }, isTextFieldAvailable: true
        )
        
    }
    
    func presentWarningAlert(){
        presentAlert(title: "Uyarı!",
                     message: "Liste Elemanı Boş Bırakılamaz",
                     cancelButtonTitle: "Kapat")
    }
    
    func presentAlert(title : String?,
                      message : String?,
                      prefferedStyle : UIAlertController.Style = .alert,
                      cancelButtonTitle : String? ,
                      defaultButtonTitle : String? = nil ,
                      defaultButtonHandler : ((UIAlertAction) -> Void)? = nil,
                      isTextFieldAvailable : Bool = false){
        
        alertController = UIAlertController(title: title , message: message, preferredStyle: prefferedStyle)
        let cancelButton = UIAlertAction(title: cancelButtonTitle , style: .cancel)
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle , style: .default , handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        if isTextFieldAvailable{
            alertController.addTextField()
        }
        present(alertController, animated: true)
        alertController.addAction(cancelButton)

    }
    
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        data = try! managedObjectContext!.fetch(fetchRequest)
        tableView.reloadData()
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal,
                                              title: "Sil") { _, _, _ in
            //self.data.remove(at: indexPath.row)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            managedObjectContext?.delete(self.data[indexPath.row])
            try? managedObjectContext?.save()
            self.fetch()
            
        }
        let editAction = UIContextualAction(style: .normal, title: "Düzenle") { _, _, _ in
            
            self.presentAlert(title: "Elemanını Düzenle",
                              message: nil,
                              cancelButtonTitle: "Vazgeç",
                              defaultButtonTitle: "Düzenle", defaultButtonHandler: { _ in
                let text = self.alertController.textFields?.first?.text
                if text != "" {
                    
                   // self.data[indexPath.row] = text!
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    if managedObjectContext!.hasChanges{
                        try? managedObjectContext?.save()
                    }
                    self.tableView.reloadData()
                }
                else {
                    self.presentWarningAlert()
                }
                
            }, isTextFieldAvailable: true
            )
            self.tableView.reloadData()

        }
        deleteAction.backgroundColor = .systemRed
        editAction.backgroundColor = .systemBlue
        let config = UISwipeActionsConfiguration(actions: [deleteAction , editAction])
        
        return config
    }
}
