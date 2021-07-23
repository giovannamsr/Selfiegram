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


}

