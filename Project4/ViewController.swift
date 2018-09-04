//
//  ViewController.swift
//  Project4
//
//  Created by Charles Martin Reed on 9/4/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    //MARK:- Properties
    let pdfView = PDFView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting up our PDFView and making it fill the enclosing space
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        //create our bar button items
        //previous and next can go straight to the PDFView
        let previous = UIBarButtonItem(barButtonSystemItem: .rewind, target: pdfView, action: #selector(PDFView.goToPreviousPage(_:)))
        let next = UIBarButtonItem(barButtonSystemItem: .fastForward, target: pdfView, action: #selector(PDFView.goToNextPage(_:)))
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(promptForSearch))
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSelection))
        
        //assign all four to be our left bar button items
        navigationItem.leftBarButtonItems = [previous, next, search, share]
        
        //set the pdf to scale to size automatically
        pdfView.autoScales = true
        
    }

    //MARK: - Book loading methods
    func load(_ name: String) {
        
        //convert the user-visible name to the filename by lowercasing and replacing empty spaces with -
        let filename = name.replacingOccurrences(of: " ", with: "-").lowercased()
        
        //find its path to the PDF in our bundle
        guard let path = Bundle.main.url(forResource: filename, withExtension: "pdf") else { return }
        
        //load that path into a PDFDocument object
        if let document = PDFDocument(url: path) {
            
            //assign it to our PDF view
            pdfView.document = document
            
            //force the PDF back to the cover page - generally PDF's open on the last page you were on. This is probably something you'd want in a production app though.
            pdfView.goToFirstPage(nil)
            
            //display the documents title if there's space - i.e, if it's the iPad
            if UIDevice.current.userInterfaceIdiom == .pad {
                title = name
            }
        }
    }
    
    //MARK: - Search through books method
    @objc func promptForSearch() {
        //prepare an alert box
        let alert = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
        
        //give the user somewhere to type their search string by adding a text field
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { (action) in
            
            //pull out whatever text they entered
            guard let searchText = alert.textFields?[0].text else { return }
            
            //find the first match, starting from whatever we highlighted previously when search has been previously completed
            guard let match = self.pdfView.document?.findString(searchText, fromSelection: self.pdfView.highlightedSelections?.first, withOptions: .caseInsensitive) else { return }
            
            // tell the PDF to jump to the match
            self.pdfView.go(to: match)
            
            // mark the match as being highlighted
            self.pdfView.highlightedSelections = [match]
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true , completion: nil)
    }
    
    //MARK:- Social media sharing method
    @objc func shareSelection(_ sender: UIBarButtonItem) {
        
        //we can see what was selected by using the pdfview's current selection attribute's attributestring method
        guard let selection = pdfView.currentSelection?.attributedString else {
            
            //not text selection - show an error and exit
            let alert = UIAlertController(title: "Please select some text to share.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        //snd the selection off to be shared
        let vc = UIActivityViewController(activityItems: [selection], applicationActivities: nil)
        //present the view controller FROM a bar button item
        vc.popoverPresentationController?.barButtonItem = sender
        
        present(vc, animated: true, completion: nil)
        
    }

}

