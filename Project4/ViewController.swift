//
//  ViewController.swift
//  Project4
//
//  Created by Charles Martin Reed on 9/4/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import PDFKit
import SafariServices

class ViewController: UIViewController, PDFViewDelegate, PDFDocumentDelegate {

    //MARK:- Properties
    let pdfView = PDFView()
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK:- Creating our segmented control
        let viewMode = UISegmentedControl(items: ["PDF", "Text"])
        viewMode.addTarget(self, action: #selector(changeViewMode), for: .valueChanged)
        viewMode.selectedSegmentIndex = 0
        
        //add the seg control to the the nav bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: viewMode)
        navigationItem.rightBarButtonItem?.width = 150
        
        //set self to delegate so that we can handle loading up Safari
        pdfView.delegate = self
        
        //setting up our PDFView and making it fill the enclosing space
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        //give textView same autolayout constraints as pdfView
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        //disable, hide and modify text container inset property for textView
        textView.isEditable = false
        textView.isHidden = true
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        
        
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
        
        //start with Practical iOS 11 preloaded
        load("Practical iOS 11")
        
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
            document.delegate = self //document asks view what class should be used to render pages
            pdfView.document = document
            
            //force the PDF back to the cover page - generally PDF's open on the last page you were on. This is probably something you'd want in a production app though.
            pdfView.goToFirstPage(nil)
            
            //this won't be initially visible, but the user can toggle the view on and off as desired
            //loadText()
            
            //display the documents title if there's space - i.e, if it's the iPad
            if UIDevice.current.userInterfaceIdiom == .pad {
                title = name
            }
        }
    }
    
    func loadText() {
        // read the page count
        guard let pageCount = pdfView.document?.pageCount else { return }
        let documentContent = NSMutableAttributedString()
        
        for i in 1 ..< pageCount {
            
            //find a page and the attributed strings within
            guard let page = pdfView.document?.page(at: i) else { continue }
            guard let pageContent = page.attributedString else { continue }
            
            //add line breaks between each page
            let spacer = NSAttributedString(string: "\n\n")
            
            //add the page contents and the spacer to the attributed string
            documentContent.append(spacer)
            documentContent.append(pageContent)
        }
        
        //removing the footer tex, for example: "www.hackingwithswift.com 24".
        let pattern = "www.hackingwithswift.com [0-9]{1,2}"
        let regex = try? NSRegularExpression(pattern: pattern)
        
        //range of the entire document word count
        let range = NSMakeRange(0, documentContent.string.utf16.count)
        
        if let matches = regex?.matches(in: documentContent.string, options: [], range: range) {
            //reverse, otherwise replacing one string will move the position of other, unchecked, strings
            for match in matches.reversed() {
                documentContent.replaceCharacters(in: match.range, with: "")
            }
        }
        
        
        
        //put the attributed text string in the textView for viewing
        textView.attributedText = documentContent
        
    }
    
    //MARK:- PDFView or TextView method
    @objc func changeViewMode(segmentedControl: UISegmentedControl) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            //show the pdfView
            pdfView.isHidden = false
            textView.isHidden = true
        } else {
            //show the textView
            pdfView.isHidden = true
            textView.isHidden = false
            loadText()
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
    
    //MARK:- Safari Services protocol method
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        
        //create the Safari view and load up the specified web page
        let vc = SFSafariViewController(url: url)
        
        //this will cause Safari to open a smaller window, centered in the middle of the screen, over our current view
        vc.modalPresentationStyle = .formSheet
        
        present(vc, animated: true, completion: nil)
    }
    
    //MARK:- Sample watermark class method
    func classForPage() -> AnyClass {
        return SampleWatermark.self
    }

}

