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

}

