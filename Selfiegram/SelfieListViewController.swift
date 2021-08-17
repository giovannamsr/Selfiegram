//
//  ViewController.swift
//  Selfiegram
//
//  Created by Giovanna Rodrigues on 20/07/21.
//

import UIKit
import CoreLocation

class SelfieListViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    
    var selfies : [Selfie] = []
    
    let timeIntervalFormatter : DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .spellOut
            formatter.maximumUnitCount = 1
            return formatter
        }()
    
    @objc func createNewSelfie()
    {
        let imagePicker = UIImagePickerController()
        //checks if camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            imagePicker.sourceType = .camera
            //checks if front camera is available
            if UIImagePickerController.isCameraDeviceAvailable(.front)
            {
                imagePicker.cameraDevice = .front
            }
        }
        else
        {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func newSelfieTaken(image: UIImage)
    {
        let newSelfie = Selfie(title: "New Selfie")
        newSelfie.image = image
        do
        {
            try SelfieStore.shared.save(selfie: newSelfie)
        }
        catch let error
        {
            showError(message: "Can't save photo: \(error)")
            return
        }
        selfies.insert(newSelfie, at: 0)
        
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        guard let image =
                info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage
                ?? info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage else
        {
            let message = "Couldn't get a picture from the image picker!"
            showError(message: message)
            return
        }
        self.newSelfieTaken(image: image)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // loading the list of selfies from the selfie store
        
        let button = UIButton(frame: CGRect(x:0,y:0,width: 300, height: 70))
        
        button.setTitle("present", for:.normal)
        button.setTitleColor(.white, for:.normal)
        button.backgroundColor = .systemBlue
        button.center = view.center
        
        
        do
        {
            // Get the list of photos, sorted by date (newer first)
            selfies = try SelfieStore.shared.listSelfies().sorted(by: { $0.created > $1.created })
        }
        catch let error
        {
            showError(message: "Failed to load selfies: \(error.localizedDescription)")
        }
            
        if let split = splitViewController
        {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as? UINavigationController)?.topViewController as? DetailViewController
        }
        let addSelfieButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewSelfie))
        navigationItem.rightBarButtonItem = addSelfieButton
            
    }
    
       
    
    func showError(message : String) {
        // Create an alert controller, with the message we received
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        // Add an action to it
        let action = UIAlertAction(title: "OK",
                                   style: .default, handler: nil)
        alert.addAction(action)
        // Show the alert and its message
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return selfies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //get cell from table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //get a selfie and use it to configure the cell
        let selfie = selfies[indexPath.row]
        //set up main label
        cell.textLabel?.text = selfie.title
        //set up its time ago sublabel
        if let interval = timeIntervalFormatter.string(from: selfie.created, to: Date())
        {
            cell.detailTextLabel?.text = "\(interval) ago"
        }
        else
        {
            cell.detailTextLabel?.text = nil
        }
        //show selfie image on the cell
        cell.imageView?.image = selfie.image
        
        return cell
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let selfieToRemove = selfies[indexPath.row]
            do
            {
                try SelfieStore.shared.delete(selfie: selfieToRemove)
                selfies.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch
            {
                let title = selfieToRemove.title
                showError(message: "Failed to delete \(title).")
            }
        }
    }
    
}
extension SelfieListViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{ }

