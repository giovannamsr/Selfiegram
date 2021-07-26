//
//  ViewController.swift
//  Selfiegram
//
//  Created by Giovanna Rodrigues on 20/07/21.
//

import UIKit

class SelfieListViewController: UIViewController {
    
    var selfies : [Selfie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        do
        {
            //get the list of photos ordered by date
            selfies = try SelfieStore.shared.listSelfies().sorted(by: {$0.created > $1.created})
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
    
    func showError(message : String)
    {
        //crate alert controller with message
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        //add an action to it so we have a button to dismiss it
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        
        //show alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return selfies.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let selfie = selfies[indexPath.row]
        cell.textLabel?.text = selfie.title
        
        return cell
    }


}

