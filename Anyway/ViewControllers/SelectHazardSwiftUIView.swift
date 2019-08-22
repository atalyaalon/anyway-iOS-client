//
//  SelectHazardSwiftUIView.swift
//  Anyway
//
//  Created by Yigal Omer on 22/08/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)


struct SelectHazardSwiftUIView: View {
@State var columns: CGFloat = 3.0
@State var vSpacing: CGFloat = 10.0
@State var hSpacing: CGFloat = 10.0
@State var vPadding: CGFloat = 0.0
@State var hPadding: CGFloat = 10.0

var body: some View {
  GeometryReader { geometry in
    ZStack {
      self.backgroundGradient.edgesIgnoringSafeArea(.all)
      VStack {
        //if (QConstants.showDesigner) { self.designerView(geometry) }
        self.gridView(geometry)
        }
        }
    }
    }

    private func gridView(_ geometry: GeometryProxy) -> some View {
        // NavigationView {
        VStack() {
            Text("בחר סוג מפגע/בעיה")
                .lineLimit(1)
                .padding([.vertical], 10)
            QGrid(Storage.hazards,
                  columns: Int(self.columns),
                  columnsInLandscape: Int(self.columns),
                  vSpacing: self.vSpacing,
                  hSpacing: self.hSpacing,
                  vPadding: self.vPadding,
                  hPadding: self.hPadding) {
                    HazardGridCell(hazard: $0)
                }
        }
      //  }
    }


    private var backgroundGradient: LinearGradient {
      let gradient = Gradient(colors: [
        Color(red: 192/255.0, green: 192/255.0, blue: 192/255.0),
        Color(red: 50/255.0, green: 50/255.0, blue: 50/255.0)
      ])
      return LinearGradient(gradient: gradient,
                            startPoint: .top,
                            endPoint: .bottom)
    }
}


@available(iOS 13.0.0, *)
struct SelectHazardSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SelectHazardSwiftUIView()
    }
}
