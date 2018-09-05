//
//  SampleWatermark.swift
//  Project4
//
//  Created by Charles Martin Reed on 9/5/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import PDFKit

class SampleWatermark: PDFPage {
    //if you draw your content before calling super.draw, your content will appear BEHIND the page content.
    //Save the graphics context you're given and its state BEFORE making any changes, restore afterwards.
    //PDFs have a variety of drawing boxes. All are find, but ask for the bounds.
    //UIKit and PDF draw in different directions; compensate by moving the height of document down and flipping the Y axis.
    
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        
        //draw existing page first
        super.draw(with: box, to: context)
        
        //create our string of attributes
        let string: NSString = "SAMPLE CHAPTER"
        let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.red, .font: UIFont.boldSystemFont(ofSize: 32)]
        let stringSize = string.size(withAttributes: attributes)
        
        //save the state before we start moving and rotating
        UIGraphicsPushContext(context)
        context.saveGState()
        
        //figure out how much space we have for drawing
        let pageBounds = bounds(for: box)
        
        //move and flip the context, making it render the right way up
        context.translateBy(x: (pageBounds.size.width - stringSize.width) / 2, y: pageBounds.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)
        
        //draw our string slightly down from the top
        string.draw(at: CGPoint(x: 0, y: 55), withAttributes: attributes)
        
        //put everything back where it was
        context.restoreGState()
        UIGraphicsPopContext()
    }
}
