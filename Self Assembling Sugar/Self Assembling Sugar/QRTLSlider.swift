//
//  File3.swift
//  Self Assembling Sugar
//
//  Created by David Nishimoto on 9/9/26.
//

import Foundation
import SwiftUI

struct QRTLSlider: View {

    let title: String

    @Binding var value: Double

    let range: ClosedRange<Double>

    let description: String

    let analogy: String

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            HStack {

                Text(
                    title
                )
                .font(
                    .system(
                        size: 13,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundColor(
                    .white
                )

                Spacer()

                Text(
                    String(
                        format:
                            "%.3f",
                        value
                    )
                )
                .font(
                    .system(
                        size: 12,
                        weight: .bold,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    .cyan
                )
            }

            Slider(
                value:
                    $value,
                in:
                    range
            )
            .tint(
                .cyan
            )

            Text(
                description
            )
            .font(
                .caption
            )
            .foregroundColor(
                .white.opacity(0.72)
            )

            Text(
                "Analogy: " +
                analogy
            )
            .font(
                .caption2
            )
            .italic()
            .foregroundColor(
                .yellow.opacity(0.9)
            )
        }
        .padding(
            11
        )
        .background(
            RoundedRectangle(
                cornerRadius: 11
            )
            .fill(
                Color.white.opacity(
                    0.045
                )
            )
        )
    }
}

