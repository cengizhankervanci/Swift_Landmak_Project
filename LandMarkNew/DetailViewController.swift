//
//  DetailViewController.swift
//  LandMarkNew
//
//  Created by Cengizhan Kervancı on 30.08.2022.
//

import UIKit
import CoreData

class DetailViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var artistTF: UITextField!
    @IBOutlet weak var yearTF: UITextField!
    
    var chosenPaintName = ""
    var chosenID : UUID?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if(chosenPaintName != "")
        {
            //Tekrar data çekiyoruz!
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PaintDB")
            
            let idString = chosenID?.uuidString

            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!) //id'si argümana eşit olanı bul demek! name = name gibi de kullanılır.
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if(results.count > 0)
                {
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String
                        {
                            nameTF.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String
                        {
                            artistTF.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int
                        {
                            yearTF.text = String(year)
                        }
                        
                        if let imgData = result.value(forKey: "image") as? Data
                        {
                            let image = UIImage(data: imgData)
                            userImage.image = image
                        }
                    }
                }
            }
            catch{
                print("Fetch Error 2!")
            }
        }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        userImage.isUserInteractionEnabled = true
        let gestureIMG = UITapGestureRecognizer(target: self, action: #selector(addIMG))
        userImage.addGestureRecognizer(gestureIMG)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveButton))
    }
    
    @objc func hideKeyboard()
    {
        view.endEditing(true)
    }
    
    @objc func saveButton()
    {
        if(nameTF.text != "" && artistTF.text != "" && yearTF.text != "")
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let newPainting = NSEntityDescription.insertNewObject(forEntityName: "PaintDB", into: context)
            
            newPainting.setValue(nameTF.text, forKey: "name")
            newPainting.setValue(artistTF.text, forKey: "artist")
            newPainting.setValue(Int(yearTF.text!), forKey: "year")
            newPainting.setValue(UUID(), forKey: "id")
            
            let data = userImage.image?.jpegData(compressionQuality: 0.5)
            newPainting.setValue(data, forKey: "image")
            
            do
            {
                try context.save()
            }
            catch
            {
                print("ERROR!")
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("updateData"), object: nil) //ACTİON ASLINDA... BU MESAJI ALAN HERKES BİR ŞEY YAPIYOR!
            self.navigationController?.popViewController(animated: true) //İşlem yapıldığında bir önceki page'e döner!
        }
        else{
            let alert = UIAlertController(title: "Opps!", message: "Some fields is empty", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okey", style: .default))
            self.present(alert, animated: true,completion: nil)
        }
        
    }
    
    @objc func addIMG()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        userImage.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true,completion: nil)
    }
}
