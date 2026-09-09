//
//  File4.swift
//  Self Assembling Sugar
//
//  Created by David Nishimoto on 9/9/26.
//

import Foundation
import SwiftUI

struct QRTLCardModifier:
    ViewModifier {

    func body(
        content: Content
    ) -> some View {

        content
            .padding(
                14
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 16
                )
                .fill(
                    Color.white.opacity(
                        0.055
                    )
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 16
                )
                .stroke(
                    Color.white.opacity(
                        0.12
                    ),
                    lineWidth: 1
                )
            )
    }
}




