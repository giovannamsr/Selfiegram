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
}

