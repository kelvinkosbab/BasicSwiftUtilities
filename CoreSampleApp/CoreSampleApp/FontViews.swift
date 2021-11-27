//
//  FontViews.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI
import CoreUI

// MARK: - FontViews

struct FontViews : View {
    
    let text = "Hello World!"
    
    var body: some View {
        List {
            self.reguarFontStyles
            self.boldFontStyles
            self.italicFontStyles
            self.monospaceFontStyles
        }
    }
    
    private var reguarFontStyles: some View {
        VStack {
            /*@START_MENU_TOKEN@*/Text(self.text)/*@END_MENU_TOKEN@*/
                .bodyStyle()
            /*@START_MENU_TOKEN@*/Text(self.text)/*@END_MENU_TOKEN@*/
                .footnoteStyle()
            Text(self.text)
                .headingStyle()
            Text(self.text)
                .titleStyle()
            Text(self.text)
                .xlTitleStyle()
        }
    }
    
    private var boldFontStyles: some View {
        VStack {
            Text(self.text)
                .bodyBoldStyle()
            Text(self.text)
                .footnoteBoldStyle()
            Text(self.text)
                .headingBoldStyle()
            Text(self.text)
                .titleBoldStyle()
            Text(self.text)
                .xlTitleBoldStyle()
        }
    }
    
    private var italicFontStyles: some View {
        VStack {
            Text(self.text)
                .bodyItalicStyle()
            Text(self.text)
                .footnoteItalicStyle()
            Text(self.text)
                .headingItalicStyle()
            Text(self.text)
                .titleItalicStyle()
            Text(self.text)
                .xlTitleItalicStyle()
        }
    }
    
    private var monospaceFontStyles: some View {
        VStack {
            Text(self.text)
                .bodyMonospaceStyle()
            Text(self.text)
                .footnoteMonospaceStyle()
            Text(self.text)
                .headingMonospaceStyle()
            Text(self.text)
                .titleMonospaceStyle()
            Text(self.text)
                .xlTitleMonospaceStyle()
        }
    }
}
