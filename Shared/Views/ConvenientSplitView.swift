//
//  ConvenientSplitView.swift
//  lido
//
//  Created by Everett Wilber on 7/14/22.
//

import SwiftUI

struct AutomaticSplitView<Content> where Content: View {
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geom in
            if (geom.size.height <= geom.size.width) {
                HSplitView(content: content)
            } else {
                VSplitView(content: content)
            }
        }
    }
}

struct AutomaticSplitView_Previews: PreviewProvider {
    static var previews: some View {
        AutomaticSplitView {
            Text("left/top")
            Text("right/bottom")
        }
    }
}
