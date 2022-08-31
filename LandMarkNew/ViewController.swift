//
//  ViewController.swift
//  LandMarkNew
//
//  Created by Cengizhan Kervancı on 30.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var landmarkTableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedPaintName = ""
    var selectedID : UUID?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButton))
        
        landmarkTableView.delegate = self
        landmarkTableView.dataSource = self
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("updateData"), object: nil)
    }

    @objc func addButton()
    {
        selectedPaintName = ""
        performSegue(withIdentifier: "detailVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPaintName = nameArray[indexPath.row]
        selectedID = idArray[indexPath.row]
        performSegue(withIdentifier: "detailVC", sender: nil)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if(editingStyle == .delete)
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PaintDB")
            
            let id = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", id)
            fetchRequest.returnsObjectsAsFaults = false
            
            do
            {
                let results = try context.fetch(fetchRequest)
                
                if(results.count > 0)
                {
                    for result in results as! [NSManagedObject]
                    {
                        if let id = result.value(forKey: "id") as? UUID
                        {
                            if id == idArray[indexPath.row]
                            {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.landmarkTableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print("Error Delete!")
                                }
                                break
                            }
                        }
                    }
                }
            }catch
            {
                
            }
            
           }
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "detailVC")
        {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.chosenPaintName = selectedPaintName
            destinationVC.chosenID = selectedID
        }
    }
    
    @objc func getData()
    {
        //Dizilerde sadece bir tane olması için...
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        //
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PaintDB")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            
            if(results.count > 0)
            {
                for result in results as! [NSManagedObject]
                {
                    if let name = result.value(forKey: "name") as? String
                    {
                        self.nameArray.append(name)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID
                    {
                        self.idArray.append(id)
                    }
                    self.landmarkTableView.reloadData()
                 }
                }
            }
            catch
            {
            print("Fetch Error!")
            }
    }
}

