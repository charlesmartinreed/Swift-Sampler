//
//  FilesViewController.swift
//  Project4
//
//  Created by Charles Martin Reed on 9/4/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit

class FilesViewController: UITableViewController {
    
    //MARK:- Properties
    //hold the titles of all of our books/pdfs
    let books = ["Beyond Code",
                 "Hacking with MacOS",
                 "Hacking with Swift",
                 "Hacking with tvOS",
                 "Objective-C for Swift Developers",
                 "Practical iOS 10",
                 "Practical iOS 11",
                 "Pro Swift",
                 "Server-Side Swift",
                 "Swift Coding Challenges"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Books"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Table view delegate methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = books[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //find the other view controller and tell it to load a pdf
        //this requires making our way up to split view controller, over to navigation controller and down to the view controller it contains
        guard let navController = splitViewController?.viewControllers[1] as? UINavigationController else { return }
        guard let viewController = navController.viewControllers[0] as? ViewController else { return }
        
        viewController.load(books[indexPath.row])
    }

}
