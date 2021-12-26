//
//  FontPreviews.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

#if !os(macOS)
import UIKit
#endif

// MARK: - Previews

#if DEBUG

@available(iOS 13.0, macOS 12, tvOS 13.0, watchOS 6.0, *)
struct Font_Previews: PreviewProvider {
    
    private static let text = "Hello World!"
    
    static var previews: some View {
        List {
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
        List {
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
        List {
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
        List {
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

#endif
