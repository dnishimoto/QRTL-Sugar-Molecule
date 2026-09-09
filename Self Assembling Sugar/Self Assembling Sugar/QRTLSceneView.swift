//
//  File.swift
//  Self Assembling Sugar
//
//  Created by David Nishimoto on 9/9/26.
//

import Foundation

import SwiftUI
import SceneKit

struct QRTLSceneView: UIViewRepresentable {

    // ============================================================
    // MARK: - CONTROLLER
    // ============================================================

    @ObservedObject var controller: QRTLSceneController


    // ============================================================
    // MARK: - MAKE UI VIEW
    // ============================================================

    func makeUIView(context: Context) -> SCNView {

        print("========================================")
        print("QRTLSceneView.makeUIView CALLED")
        print("========================================")

        // --------------------------------------------------------
        // CREATE SCENEKIT VIEW
        // --------------------------------------------------------

        let sceneView = SCNView(frame: .zero)

        // --------------------------------------------------------
        // BASIC VIEW CONFIGURATION
        // --------------------------------------------------------

        sceneView.backgroundColor = UIColor.black

        sceneView.isPlaying = true

        sceneView.rendersContinuously = true

        sceneView.allowsCameraControl = true

        sceneView.autoenablesDefaultLighting = false

        sceneView.antialiasingMode = .multisampling4X

        // --------------------------------------------------------
        // DEBUG INFORMATION
        // --------------------------------------------------------

        print("SCNView CREATED")
        print("isPlaying: \(sceneView.isPlaying)")
        print("rendersContinuously: \(sceneView.rendersContinuously)")
        print("allowsCameraControl: \(sceneView.allowsCameraControl)")

        // --------------------------------------------------------
        // CONNECT CONTROLLER TO SCENEKIT
        // --------------------------------------------------------

        print("----------------------------------------")
        print("CALLING controller.setupScene")
        print("----------------------------------------")

        controller.setupScene(sceneView: sceneView)

        print("----------------------------------------")
        print("controller.setupScene RETURNED")
        print("----------------------------------------")

        // --------------------------------------------------------
        // VERIFY SCENE
        // --------------------------------------------------------

        if sceneView.scene != nil {
            print("SUCCESS: SCNView contains a scene")
        } else {
            print("WARNING: SCNView scene is NIL")
        }

        // --------------------------------------------------------
        // RETURN SCENEKIT VIEW TO SWIFTUI
        // --------------------------------------------------------

        print("Returning SCNView to SwiftUI")

        return sceneView
    }


    // ============================================================
    // MARK: - UPDATE UI VIEW
    // ============================================================

    func updateUIView(
        _ uiView: SCNView,
        context: Context
    ) {

        // --------------------------------------------------------
        // SWIFTUI MAY CALL THIS MANY TIMES.
        //
        // DO NOT RECREATE THE SCENE HERE.
        // setupScene() belongs in makeUIView().
        // --------------------------------------------------------

        if !uiView.isPlaying {
            uiView.isPlaying = true
        }

        if !uiView.rendersContinuously {
            uiView.rendersContinuously = true
        }
    }


    // ============================================================
    // MARK: - COORDINATOR
    // ============================================================

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }


    // ============================================================
    // MARK: - COORDINATOR
    // ============================================================

    final class Coordinator {

        init() {

            print("QRTLSceneView.Coordinator CREATED")

        }
    }
}
