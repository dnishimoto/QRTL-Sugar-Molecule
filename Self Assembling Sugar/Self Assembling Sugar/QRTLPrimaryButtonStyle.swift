//
//  File4.swift
//  Self Assembling Sugar
//
//  Created by David Nishimoto on 9/9/26.
//

import Foundation

import SwiftUI

// ============================================================
// MARK: - PRIMARY BUTTON
// ============================================================

struct QRTLPrimaryButtonStyle:
    ButtonStyle {

    func makeBody(
        configuration:
            Configuration
    ) -> some View {

        configuration.label
            .font(
                .system(
                    size: 12,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundColor(
                .black
            )
            .padding(
                .vertical,
                11
            )
            .padding(
                .horizontal,
                10
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 10
                )
                .fill(
                    Color.cyan
                )
            )
            .opacity(
                configuration.isPressed
                ? 0.7
                : 1.0
            )
    }
}

// ============================================================
// MARK: - CONTROL BUTTON
// ============================================================

struct QRTLControlButtonStyle:
    ButtonStyle {

    func makeBody(
        configuration:
            Configuration
    ) -> some View {

        configuration.label
            .font(
                .system(
                    size: 12,
                    weight: .semibold,
                    design: .rounded
                )
            )
            .foregroundColor(
                .white
            )
            .padding(
                .vertical,
                10
            )
            .padding(
                .horizontal,
                10
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 10
                )
                .fill(
                    Color.white.opacity(
                        0.10
                    )
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 10
                )
                .stroke(
                    Color.white.opacity(
                        0.18
                    ),
                    lineWidth: 1
                )
            )
            .opacity(
                configuration.isPressed
                ? 0.65
                : 1.0
            )
    }
}

