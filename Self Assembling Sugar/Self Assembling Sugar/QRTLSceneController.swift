//
//  File.swift
//  Self Assembling Sugar
//
//  Created by David Nishimoto on 9/9/26.
//

import Foundation
import SwiftUI
import SceneKit
import Combine


final class QRTLSceneController:
    NSObject,
    ObservableObject,
    SCNSceneRendererDelegate {

    // --------------------------------------------------------
    // Current phase
    // --------------------------------------------------------

    @Published var phase:
        QRTLPhase = .initialization

    @Published var phaseProgress: Int = 0

    // --------------------------------------------------------
    // Electrical input
    // --------------------------------------------------------

    @Published var current: Double = 0.50

    @Published var currentEfficiency: Double = 0.70

    @Published var effectiveInput: Double = 0

    // --------------------------------------------------------
    // Energy shell
    // --------------------------------------------------------

    @Published var shellEnergy: Double = 0.75

    @Published var shellRadius: Double = 1.65

    @Published var shellWidth: Double = 0.42

    @Published var shellCoupling: Double = 0.80

    @Published var shellCoherence: Double = 0.90

    // --------------------------------------------------------
    // QRTL pressure
    // --------------------------------------------------------

    @Published var qrtlPressure: Double = 0

    // --------------------------------------------------------
    // Energy loss
    // --------------------------------------------------------

    @Published var energyLoss: Double = 0.08

    @Published var reactionEnergy: Double = 0

    // --------------------------------------------------------
    // Forces
    // --------------------------------------------------------

    @Published var qrtlForce: Double = 0

    @Published var externalForce: Double = 0.40

    @Published var kineticForce: Double = 0.35

    @Published var bondForce: Double = 0.70

    // --------------------------------------------------------
    // Playback
    // --------------------------------------------------------

    @Published var isPlaying = false

    @Published var replaceStrongForce = true

    // --------------------------------------------------------
    // Model
    // --------------------------------------------------------

    private var modelParameters =
        QRTLParameters()

    private let physics =
        QRTLPhysicsModel()

    // --------------------------------------------------------
    // Scene
    // --------------------------------------------------------

    private weak var sceneView:
        SCNView?

    private var scene:
        SCNScene!

    private let worldNode =
        SCNNode()

    private let latticeNode =
        SCNNode()

    private let shellNode =
        SCNNode()

    private let forceNode =
        SCNNode()

    private let currentNode =
        SCNNode()

    private let nucleusNode =
        SCNNode()

    private let electronNode =
        SCNNode()

    private let moleculeNode =
        SCNNode()

    private let strandNode =
        SCNNode()

    // --------------------------------------------------------
    // Timing
    // --------------------------------------------------------

    private var elapsedTime:
        TimeInterval = 0

    private var lastTime:
        TimeInterval = 0

    // --------------------------------------------------------
    // State
    // --------------------------------------------------------

    private var glucoseCreated =
        false

    // ========================================================
    // MARK: - Scene Setup
    // ========================================================

    func setupScene(sceneView: SCNView) {
        self.sceneView = sceneView

        // ============================================================
        // CREATE SCENE
        // ============================================================

        scene = SCNScene()

        scene.background.contents = UIColor(
            red: 0.015,
            green: 0.02,
            blue: 0.04,
            alpha: 1.0
        )

        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = false
        sceneView.isPlaying = true
        sceneView.backgroundColor = .black

        // ============================================================
        // SCENE HIERARCHY
        // ============================================================

        scene.rootNode.addChildNode(worldNode)

        worldNode.addChildNode(latticeNode)
        worldNode.addChildNode(shellNode)
        worldNode.addChildNode(forceNode)
        worldNode.addChildNode(currentNode)
        worldNode.addChildNode(nucleusNode)
        worldNode.addChildNode(electronNode)
        worldNode.addChildNode(moleculeNode)
        worldNode.addChildNode(strandNode)

        // ============================================================
        // FLOOR
        // ============================================================

        let floor = SCNFloor()
        floor.reflectivity = 0.05

        let floorNode = SCNNode(geometry: floor)
        floorNode.position.y = -2.6

        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor(
            white: 0.025,
            alpha: 1.0
        )

        floor.materials = [floorMaterial]
        worldNode.addChildNode(floorNode)

        // ============================================================
        // CAMERA
        // ============================================================

        let camera = SCNCamera()

        camera.fieldOfView = 48
        camera.zNear = 0.01
        camera.zFar = 200.0

        let cameraNode = SCNNode()
        cameraNode.camera = camera

        cameraNode.position = SCNVector3(
            0,
            3,
            11
        )

        cameraNode.look(
            at: SCNVector3(
                0,
                0,
                0
            )
        )

        worldNode.addChildNode(cameraNode)

        // ============================================================
        // KEY LIGHT
        // ============================================================

        let keyLight = SCNLight()
        keyLight.type = .omni
        keyLight.intensity = 1100

        let keyNode = SCNNode()
        keyNode.light = keyLight

        keyNode.position = SCNVector3(
            4,
            6,
            6
        )

        worldNode.addChildNode(keyNode)

        // ============================================================
        // FILL LIGHT
        // ============================================================

        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLight.intensity = 600

        let fillNode = SCNNode()
        fillNode.light = fillLight

        fillNode.position = SCNVector3(
            -5,
            2,
            4
        )

        worldNode.addChildNode(fillNode)

        // ============================================================
        // BUILD VISUALIZATION
        // ============================================================

        buildLattice()

        buildEnergyShell()

        buildNucleus()

        buildElectrons()

        buildForceVisualization()

        buildCurrentVisualization()

        // ============================================================
        // BUILD THE ACTUAL SUGAR MOLECULE
        // ============================================================

        buildGlucoseMolecule()

        // ============================================================
        // FORCE EVERYTHING VISIBLE FOR INITIAL DIAGNOSTICS
        // ============================================================

        latticeNode.opacity = 1.0
        shellNode.opacity = 1.0
        forceNode.opacity = 1.0
        currentNode.opacity = 1.0
        nucleusNode.opacity = 1.0
        electronNode.opacity = 1.0
        moleculeNode.opacity = 1.0
        strandNode.opacity = 1.0

        // ============================================================
        // INITIAL PHYSICS STATE
        // ============================================================

        updateForces()

        // Apply the phase visibility after all geometry exists.
        updateSceneForCurrentPhase()
    }
    private func buildGlucoseMolecule() {
        // ============================================================
        // CLEAR PREVIOUS MOLECULE
        // ============================================================

        moleculeNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        // ============================================================
        // ATOM CREATION
        // ============================================================

        func addAtom(
            position: SCNVector3,
            radius: CGFloat,
            color: UIColor,
            emission: UIColor? = nil
        ) {
            let sphere = SCNSphere(radius: radius)
            sphere.segmentCount = 24

            let material = SCNMaterial()
            material.diffuse.contents = color

            if let emission {
                material.emission.contents = emission
            }

            sphere.materials = [material]

            let node = SCNNode(geometry: sphere)
            node.position = position

            moleculeNode.addChildNode(node)
        }

        // ============================================================
        // BOND CREATION
        // ============================================================

        func addBond(
            from start: SCNVector3,
            to end: SCNVector3,
            radius: CGFloat = 0.025,
            color: UIColor = .white
        ) {
            let direction = end - start
            let length = CGFloat(direction.length())

            guard length > 0.001 else {
                return
            }

            let cylinder = SCNCylinder(
                radius: radius,
                height: length
            )

            let material = SCNMaterial()
            material.diffuse.contents = color
            cylinder.materials = [material]

            let node = SCNNode(geometry: cylinder)

            node.position = (start + end) * 0.5

            let defaultAxis = SCNVector3(
                0,
                1,
                0
            )

            let targetAxis = direction.normalized()

            let rotationAxis = defaultAxis.cross(targetAxis)

            let dot = max(
                -1.0,
                min(
                    1.0,
                    defaultAxis.dot(targetAxis)
                )
            )

            if rotationAxis.length() > 0.001 {
                let angle = acos(dot)
                let axis = rotationAxis.normalized()

                node.rotation = SCNVector4(
                    axis.x,
                    axis.y,
                    axis.z,
                    angle
                )
            } else if dot < 0 {
                node.rotation = SCNVector4(
                    1,
                    0,
                    0,
                    Float.pi
                )
            }

            moleculeNode.addChildNode(node)
        }

        // ============================================================
        // GLUCOSE-LIKE RING
        //
        // Six-membered ring:
        // C1 - C2 - C3 - C4 - C5 - O - C1
        // ============================================================

        let c1 = SCNVector3(-0.90,  0.00, 0.00)
        let c2 = SCNVector3(-0.45,  0.62, 0.00)
        let c3 = SCNVector3( 0.35,  0.62, 0.00)
        let c4 = SCNVector3( 0.85,  0.05, 0.00)
        let c5 = SCNVector3( 0.35, -0.60, 0.00)
        let o5 = SCNVector3(-0.45, -0.50, 0.00)

        // ============================================================
        // RING ATOMS
        // ============================================================

        // Carbon
        addAtom(
            position: c1,
            radius: 0.13,
            color: UIColor(
                white: 0.12,
                alpha: 1
            )
        )

        addAtom(
            position: c2,
            radius: 0.13,
            color: UIColor(
                white: 0.12,
                alpha: 1
            )
        )

        addAtom(
            position: c3,
            radius: 0.13,
            color: UIColor(
                white: 0.12,
                alpha: 1
            )
        )

        addAtom(
            position: c4,
            radius: 0.13,
            color: UIColor(
                white: 0.12,
                alpha: 1
            )
        )

        addAtom(
            position: c5,
            radius: 0.13,
            color: UIColor(
                white: 0.12,
                alpha: 1
            )
        )

        // Ring oxygen
        addAtom(
            position: o5,
            radius: 0.15,
            color: UIColor(
                red: 0.85,
                green: 0.10,
                blue: 0.10,
                alpha: 1
            ),
            emission: UIColor(
                red: 0.35,
                green: 0.02,
                blue: 0.02,
                alpha: 1
            )
        )

        // ============================================================
        // RING BONDS
        // ============================================================

        let carbonColor = UIColor(
            white: 0.65,
            alpha: 1
        )

        addBond(from: c1, to: c2, color: carbonColor)
        addBond(from: c2, to: c3, color: carbonColor)
        addBond(from: c3, to: c4, color: carbonColor)
        addBond(from: c4, to: c5, color: carbonColor)
        addBond(from: c5, to: o5, color: carbonColor)
        addBond(from: o5, to: c1, color: carbonColor)

        // ============================================================
        // EXOCYCLIC CARBON
        // ============================================================

        let c6 = SCNVector3(
            1.15,
            0.70,
            0.15
        )

        addAtom(
            position: c6,
            radius: 0.13,
            color: UIColor(
                white: 0.12,
                alpha: 1
            )
        )

        addBond(
            from: c5,
            to: c6,
            color: carbonColor
        )

        // ============================================================
        // HYDROXYL OXYGENS
        // ============================================================

        let o1 = SCNVector3(-1.30,  0.45, 0.12)
        let o2 = SCNVector3(-0.65,  1.05, 0.12)
        let o3 = SCNVector3( 0.45,  1.05, 0.12)
        let o4 = SCNVector3( 1.25,  0.05, 0.12)
        let o6 = SCNVector3( 1.60,  0.95, 0.20)

        let oxygenColor = UIColor(
            red: 0.85,
            green: 0.10,
            blue: 0.10,
            alpha: 1
        )

        let oxygenEmission = UIColor(
            red: 0.35,
            green: 0.02,
            blue: 0.02,
            alpha: 1
        )

        addAtom(
            position: o1,
            radius: 0.12,
            color: oxygenColor,
            emission: oxygenEmission
        )

        addAtom(
            position: o2,
            radius: 0.12,
            color: oxygenColor,
            emission: oxygenEmission
        )

        addAtom(
            position: o3,
            radius: 0.12,
            color: oxygenColor,
            emission: oxygenEmission
        )

        addAtom(
            position: o4,
            radius: 0.12,
            color: oxygenColor,
            emission: oxygenEmission
        )

        addAtom(
            position: o6,
            radius: 0.12,
            color: oxygenColor,
            emission: oxygenEmission
        )

        // ============================================================
        // OXYGEN BONDS
        // ============================================================

        addBond(from: c1, to: o1, color: carbonColor)
        addBond(from: c2, to: o2, color: carbonColor)
        addBond(from: c3, to: o3, color: carbonColor)
        addBond(from: c4, to: o4, color: carbonColor)
        addBond(from: c6, to: o6, color: carbonColor)

        // ============================================================
        // HYDROGENS
        // ============================================================

        let hydrogenColor = UIColor(
            white: 0.92,
            alpha: 1
        )

        let hydrogenRadius: CGFloat = 0.055

        let hydrogens: [SCNVector3] = [
            SCNVector3(-1.05, -0.35,  0.12),
            SCNVector3(-0.65,  0.45,  0.18),
            SCNVector3( 0.05,  0.90,  0.18),
            SCNVector3( 0.65,  0.45,  0.18),
            SCNVector3( 0.10, -0.95,  0.18),
            SCNVector3( 0.55, -0.55,  0.18),
            SCNVector3( 1.05, -0.20,  0.18),
            SCNVector3( 1.45,  0.25,  0.25),
            SCNVector3( 1.95,  0.90,  0.25),
            SCNVector3( 1.55,  1.45,  0.25),
            SCNVector3( 1.95,  1.15, -0.25),
            SCNVector3(-1.55,  0.65,  0.20)
        ]

        for hydrogen in hydrogens {
            addAtom(
                position: hydrogen,
                radius: hydrogenRadius,
                color: hydrogenColor
            )
        }

        // ============================================================
        // MOLECULE SCALE / POSITION
        // ============================================================

        moleculeNode.position = SCNVector3(
            0,
            0,
            0
        )

        moleculeNode.scale = SCNVector3(
            1.0,
            1.0,
            1.0
        )

        moleculeNode.opacity = 1.0

        glucoseCreated = true
    }
    // ========================================================
    // MARK: - Lattice
    // ========================================================

    private func buildLattice() {
        latticeNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let spacing: Float = 0.65
        let count = 5

        for x in 0..<count {
            for y in 0..<count {
                for z in 0..<count {

                    let sphere = SCNSphere(
                        radius: 0.055
                    )

                    let material = SCNMaterial()

                    // Cyan lattice material
                    material.diffuse.contents = UIColor(
                        red: 0.0,
                        green: 1.0,
                        blue: 1.0,
                        alpha: 0.65
                    )

                    sphere.materials = [
                        material
                    ]

                    let node = SCNNode(
                        geometry: sphere
                    )

                    node.position = SCNVector3(
                        Float(x - 2) * spacing,
                        Float(y - 2) * spacing,
                        Float(z - 2) * spacing
                    )

                    latticeNode.addChildNode(
                        node
                    )
                }
            }
        }
    }

    // ========================================================
    // MARK: - Energy Shell
    // ========================================================

    private func buildEnergyShell() {

        shellNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let radius = CGFloat(
            max(
                modelParameters.shellRadius,
                0.05
            )
        )

        // ========================================================
        // ENERGY SHELL
        // ========================================================

        let sphere = SCNSphere(
            radius: radius
        )

        sphere.segmentCount = 64

        let material = SCNMaterial()

        // Cyan
        material.diffuse.contents = UIColor(
            red: 0.0,
            green: 1.0,
            blue: 1.0,
            alpha: 0.06
        )

        material.emission.contents = UIColor(
            red: 0.0,
            green: 1.0,
            blue: 1.0,
            alpha: 0.18
        )

        material.transparency = 0.18
        material.isDoubleSided = true

        sphere.materials = [
            material
        ]

        let node = SCNNode(
            geometry: sphere
        )

        shellNode.addChildNode(
            node
        )

        // ========================================================
        // SHELL RINGS
        // ========================================================

        let ringRadii: [CGFloat] = [
            radius * 0.76,
            radius,
            radius * 1.24
        ]

        for ringRadius in ringRadii {

            let torus = SCNTorus(
                ringRadius: ringRadius,
                pipeRadius: 0.012
            )

            let ringMaterial = SCNMaterial()

            // Cyan
            ringMaterial.diffuse.contents = UIColor(
                red: 0.0,
                green: 1.0,
                blue: 1.0,
                alpha: 0.42
            )

            ringMaterial.emission.contents = UIColor(
                red: 0.0,
                green: 1.0,
                blue: 1.0,
                alpha: 0.25
            )

            torus.materials = [
                ringMaterial
            ]

            let ringNode = SCNNode(
                geometry: torus
            )

            shellNode.addChildNode(
                ringNode
            )
        }

        // ========================================================
        // SHELL COHERENCE
        // ========================================================

        shellNode.opacity = CGFloat(
            0.45 +
            modelParameters.shellCoherence * 0.55
        )
    }
    // ========================================================
    // MARK: - Nucleus
    // ========================================================

    private func buildNucleus() {

        nucleusNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let positions: [
            SCNVector3
        ] = [

            SCNVector3(
                -0.18,
                0,
                0
            ),

            SCNVector3(
                0.18,
                0,
                0
            ),

            SCNVector3(
                0,
                0.18,
                0
            ),

            SCNVector3(
                0,
                -0.18,
                0
            ),

            SCNVector3(
                0,
                0,
                0.18
            ),

            SCNVector3(
                0,
                0,
                -0.18
            )
        ]

        for index in 0..<positions.count {

            let sphere = SCNSphere(
                radius: 0.13
            )

            let material = SCNMaterial()

            if index < 3 {

                material.diffuse.contents = UIColor(
                    red: 1,
                    green: 0.25,
                    blue: 0.25,
                    alpha: 1
                )

            } else {

                material.diffuse.contents = UIColor(
                    red: 0.65,
                    green: 0.75,
                    blue: 1,
                    alpha: 1
                )
            }

            sphere.materials = [
                material
            ]

            let node = SCNNode(
                geometry: sphere
            )

            node.position =
                positions[index]

            nucleusNode.addChildNode(
                node
            )
        }
    }

    // ========================================================
    // MARK: - Electrons
    // ========================================================

    private func buildElectrons() {

        electronNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let electronCount = 8

        for index in 0..<electronCount {

            let electron = SCNSphere(
                radius: 0.035
            )

            let material = SCNMaterial()

            // ====================================================
            // YELLOW ELECTRON
            // ====================================================

            material.diffuse.contents = UIColor(
                red: 1.0,
                green: 1.0,
                blue: 0.0,
                alpha: 1.0
            )

            material.emission.contents = UIColor(
                red: 1.0,
                green: 1.0,
                blue: 0.0,
                alpha: 0.35
            )

            electron.materials = [
                material
            ]

            let node = SCNNode(
                geometry: electron
            )

            // ====================================================
            // ELECTRON ORBIT POSITION
            // ====================================================

            let angle =
                Float(index) /
                Float(electronCount) *
                Float.pi *
                2.0

            let radius: Float = 0.48

            node.position = SCNVector3(
                cos(angle) * radius,
                sin(angle) * radius,
                0.0
            )

            electronNode.addChildNode(
                node
            )
        }
    }

    // ========================================================
    // MARK: - Current Visualization
    // ========================================================

    private func buildCurrentVisualization() {

        currentNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        for index in 0..<7 {

            let particle = SCNSphere(
                radius: 0.045
            )

            let material = SCNMaterial()

            // ====================================================
            // YELLOW CURRENT PARTICLE
            // ====================================================

            material.diffuse.contents = UIColor(
                red: 1.0,
                green: 1.0,
                blue: 0.0,
                alpha: 1.0
            )

            material.emission.contents = UIColor(
                red: 1.0,
                green: 1.0,
                blue: 0.0,
                alpha: 0.65
            )

            particle.materials = [
                material
            ]

            let node = SCNNode(
                geometry: particle
            )

            // ====================================================
            // CURRENT PARTICLE POSITION
            // ====================================================

            node.position = SCNVector3(
                Float(index) * 0.28 - 0.84,
                1.15,
                0.0
            )

            currentNode.addChildNode(
                node
            )
        }
    }

    // ========================================================
    // MARK: - Force Visualization
    // ========================================================

    private func buildForceVisualization() {

        forceNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        addArrow(
            name: "QRTL",
            start: SCNVector3(
                -1.8,
                0,
                0
            ),
            end: SCNVector3(
                -0.8,
                0,
                0
            )
        )

        addArrow(
            name: "EXTERNAL",
            start: SCNVector3(
                1.8,
                0,
                0
            ),
            end: SCNVector3(
                0.8,
                0,
                0
            )
        )

        addArrow(
            name: "MOTION",
            start: SCNVector3(
                0,
                -1.4,
                0
            ),
            end: SCNVector3(
                0,
                -0.6,
                0
            )
        )

        addArrow(
            name: "BOND",
            start: SCNVector3(
                0,
                1.4,
                0
            ),
            end: SCNVector3(
                0,
                0.6,
                0
            )
        )
    }

    private func addArrow(
        name: String,
        start: SCNVector3,
        end: SCNVector3
    ) {

        let direction = end - start

        let length = CGFloat(
            direction.length()
        )

        guard length > 0.001 else {
            return
        }

        // ========================================================
        // ARROW SHAFT
        // ========================================================

        let cylinder = SCNCylinder(
            radius: 0.025,
            height: length
        )

        let material = SCNMaterial()

        // ========================================================
        // FORCE COLOR
        // ========================================================

        switch name {

        case "QRTL":

            material.diffuse.contents = UIColor(
                red: 0.0,
                green: 1.0,
                blue: 1.0,
                alpha: 1.0
            )

        case "EXTERNAL":

            material.diffuse.contents = UIColor(
                red: 1.0,
                green: 0.3,
                blue: 0.3,
                alpha: 1.0
            )

        case "MOTION":

            material.diffuse.contents = UIColor(
                red: 1.0,
                green: 1.0,
                blue: 0.0,
                alpha: 1.0
            )

        default:

            material.diffuse.contents = UIColor.white
        }

        cylinder.materials = [
            material
        ]

        let node = SCNNode(
            geometry: cylinder
        )

        // ========================================================
        // CENTER ARROW BETWEEN START AND END
        // ========================================================

        node.position =
            (start + end) * 0.5

        // ========================================================
        // ROTATE CYLINDER
        // SCNCylinder'S DEFAULT AXIS IS +Y
        // ========================================================

        let defaultAxis = SCNVector3(
            0.0,
            1.0,
            0.0
        )

        let targetAxis =
            direction.normalized()

        let rotationAxis =
            defaultAxis.cross(
                targetAxis
            )

        let dot = max(
            -1.0,
            min(
                1.0,
                defaultAxis.dot(
                    targetAxis
                )
            )
        )

        if rotationAxis.length() > 0.001 {

            let angle = acos(dot)

            let axis = rotationAxis.normalized()

            node.rotation = SCNVector4(
                axis.x,
                axis.y,
                axis.z,
                angle
            )

        } else if dot < 0.0 {

            // ====================================================
            // 180-DEGREE CASE
            // DEFAULT +Y IS POINTING OPPOSITE TARGET
            // ====================================================

            node.rotation = SCNVector4(
                1.0,
                0.0,
                0.0,
                Float.pi
            )
        }

        forceNode.addChildNode(
            node
        )
    }
    // ========================================================
    // MARK: - UPDATE PHYSICS
    // ========================================================

    func updateForces() {

        physics.parameters =
            modelParameters

        effectiveInput =
            physics.currentPower()

        qrtlPressure =
            physics.qrtlPressureIndex()

        reactionEnergy =
            physics.reactionEnergyIndex()

        qrtlForce =
            abs(
                physics.qrtlForce(
                    distance:
                        modelParameters.shellRadius
                )
            )

        syncPublishedValues()
    }

    // ========================================================
    // MARK: - CONFIGURE PHASE
    // ========================================================

    private func configurePhase(
        _ newPhase: QRTLPhase
    ) {

        phase =
            newPhase

        switch newPhase {

        case .initialization:

            modelParameters.current =
                0.05

            modelParameters.currentEfficiency =
                0.25

            modelParameters.shellEnergy =
                0.10

            modelParameters.shellRadius =
                1.65

            modelParameters.shellWidth =
                0.42

            modelParameters.shellCoupling =
                0.20

            modelParameters.shellCoherence =
                0.20

            modelParameters.energyLoss =
                0.10

            modelParameters.externalForce =
                0.05

            modelParameters.kineticForce =
                0.05

            modelParameters.bondStrength =
                0.10

        case .lattice:

            modelParameters.current =
                0.15

            modelParameters.currentEfficiency =
                0.35

            modelParameters.shellEnergy =
                0.25

            modelParameters.shellCoupling =
                0.30

            modelParameters.shellCoherence =
                0.35

            modelParameters.externalForce =
                0.10

            modelParameters.kineticForce =
                0.10

            modelParameters.bondStrength =
                0.20

        case .proton:

            modelParameters.current =
                0.25

            modelParameters.currentEfficiency =
                0.45

            modelParameters.shellEnergy =
                0.40

            modelParameters.shellCoupling =
                0.40

            modelParameters.shellCoherence =
                0.45

            modelParameters.externalForce =
                0.15

            modelParameters.kineticForce =
                0.15

            modelParameters.bondStrength =
                0.30

        case .neutron:

            modelParameters.current =
                0.28

            modelParameters.currentEfficiency =
                0.45

            modelParameters.shellEnergy =
                0.45

            modelParameters.shellCoupling =
                0.45

            modelParameters.shellCoherence =
                0.50

            modelParameters.externalForce =
                0.15

            modelParameters.kineticForce =
                0.15

            modelParameters.bondStrength =
                0.35

        case .nucleus:

            modelParameters.current =
                0.35

            modelParameters.currentEfficiency =
                0.50

            modelParameters.shellEnergy =
                0.55

            modelParameters.shellCoupling =
                0.55

            modelParameters.shellCoherence =
                0.60

            modelParameters.externalForce =
                0.20

            modelParameters.kineticForce =
                0.20

            modelParameters.bondStrength =
                0.45

        case .energyShell:

            modelParameters.current =
                0.30

            modelParameters.currentEfficiency =
                0.60

            modelParameters.shellEnergy =
                0.75

            modelParameters.shellCoupling =
                0.80

            modelParameters.shellCoherence =
                0.75

            modelParameters.externalForce =
                0.20

            modelParameters.kineticForce =
                0.20

            modelParameters.bondStrength =
                0.50

        case .current:

            modelParameters.current =
                0.90

            modelParameters.currentEfficiency =
                0.70

            modelParameters.shellEnergy =
                1.00

            modelParameters.shellCoupling =
                0.85

            modelParameters.shellCoherence =
                0.85

            modelParameters.energyLoss =
                0.08

            modelParameters.externalForce =
                0.20

            modelParameters.kineticForce =
                0.25

            modelParameters.bondStrength =
                0.55

        case .atom:

            modelParameters.current =
                0.25

            modelParameters.currentEfficiency =
                0.65

            modelParameters.shellEnergy =
                0.80

            modelParameters.shellCoupling =
                0.80

            modelParameters.shellCoherence =
                0.82

            modelParameters.externalForce =
                0.25

            modelParameters.kineticForce =
                0.25

            modelParameters.bondStrength =
                0.60

        case .alignment:

            modelParameters.current =
                0.40

            modelParameters.currentEfficiency =
                0.65

            modelParameters.shellEnergy =
                0.75

            modelParameters.shellCoupling =
                0.85

            modelParameters.shellCoherence =
                0.85

            modelParameters.externalForce =
                0.60

            modelParameters.kineticForce =
                0.45

            modelParameters.bondStrength =
                0.65

        case .bond:

            modelParameters.current =
                0.55

            modelParameters.currentEfficiency =
                0.70

            modelParameters.shellEnergy =
                0.90

            modelParameters.shellCoupling =
                0.90

            modelParameters.shellCoherence =
                0.88

            modelParameters.externalForce =
                0.35

            modelParameters.kineticForce =
                0.30

            modelParameters.bondStrength =
                0.90

        case .carbonSkeleton:

            modelParameters.current =
                0.45

            modelParameters.currentEfficiency =
                0.68

            modelParameters.shellEnergy =
                0.82

            modelParameters.shellCoupling =
                0.85

            modelParameters.shellCoherence =
                0.88

            modelParameters.externalForce =
                0.30

            modelParameters.kineticForce =
                0.30

            modelParameters.bondStrength =
                0.75

        case .glucose:

            modelParameters.current =
                0.30

            modelParameters.currentEfficiency =
                0.70

            modelParameters.shellEnergy =
                0.85

            modelParameters.shellCoupling =
                0.90

            modelParameters.shellCoherence =
                0.90

            modelParameters.externalForce =
                0.25

            modelParameters.kineticForce =
                0.25

            modelParameters.bondStrength =
                0.80

        case .glucoseStabilization:

            modelParameters.current =
                0.05

            modelParameters.currentEfficiency =
                0.70

            modelParameters.shellEnergy =
                0.90

            modelParameters.shellCoupling =
                0.90

            modelParameters.shellCoherence =
                0.94

            modelParameters.energyLoss =
                0.04

            modelParameters.externalForce =
                0.15

            modelParameters.kineticForce =
                0.15

            modelParameters.bondStrength =
                0.85

        case .glucosePair:

            modelParameters.current =
                0.20

            modelParameters.currentEfficiency =
                0.68

            modelParameters.shellEnergy =
                0.75

            modelParameters.shellCoupling =
                0.88

            modelParameters.shellCoherence =
                0.90

            modelParameters.externalForce =
                0.30

            modelParameters.kineticForce =
                0.25

            modelParameters.bondStrength =
                0.85

        case .strandBond:

            modelParameters.current =
                0.35

            modelParameters.currentEfficiency =
                0.70

            modelParameters.shellEnergy =
                0.90

            modelParameters.shellCoupling =
                0.92

            modelParameters.shellCoherence =
                0.94

            modelParameters.externalForce =
                0.20

            modelParameters.kineticForce =
                0.20

            modelParameters.bondStrength =
                1.00

        case .strandGrowth:

            modelParameters.current =
                0.30

            modelParameters.currentEfficiency =
                0.72

            modelParameters.shellEnergy =
                0.92

            modelParameters.shellCoupling =
                0.94

            modelParameters.shellCoherence =
                0.95

            modelParameters.externalForce =
                0.20

            modelParameters.kineticForce =
                0.20

            modelParameters.bondStrength =
                0.95

        case .finalLock:

            modelParameters.current =
                0.02

            modelParameters.currentEfficiency =
                0.75

            modelParameters.shellEnergy =
                1.00

            modelParameters.shellCoupling =
                0.98

            modelParameters.shellCoherence =
                0.98

            modelParameters.energyLoss =
                0.02

            modelParameters.externalForce =
                0.05

            modelParameters.kineticForce =
                0.05

            modelParameters.bondStrength =
                1.00
        }

        updateForces()

        syncPublishedValues()

        updateSceneForCurrentPhase()
    }

    // ========================================================
    // MARK: - SYNCHRONIZE PUBLISHED VALUES
    // ========================================================

    private func syncPublishedValues() {

        current =
            modelParameters.current

        currentEfficiency =
            modelParameters.currentEfficiency

        shellEnergy =
            modelParameters.shellEnergy

        shellRadius =
            modelParameters.shellRadius

        shellWidth =
            modelParameters.shellWidth

        shellCoupling =
            modelParameters.shellCoupling

        shellCoherence =
            modelParameters.shellCoherence

        energyLoss =
            modelParameters.energyLoss

        externalForce =
            modelParameters.externalForce

        kineticForce =
            modelParameters.kineticForce

        bondForce =
            modelParameters.bondStrength

        effectiveInput =
            physics.currentPower()

        qrtlPressure =
            physics.qrtlPressureIndex()

        reactionEnergy =
            physics.reactionEnergyIndex()

        qrtlForce =
            abs(
                physics.qrtlForce(
                    distance:
                        modelParameters.shellRadius
                )
            )

        buildEnergyShell()
    }

    // ========================================================
    // MARK: - USER VARIABLE CONTROLS
    // ========================================================

    func setCurrent(
        _ value: Double
    ) {

        modelParameters.current =
            value

        updateForces()
    }

    func setCurrentEfficiency(
        _ value: Double
    ) {

        modelParameters.currentEfficiency =
            value

        updateForces()
    }

    func setShellEnergy(
        _ value: Double
    ) {

        modelParameters.shellEnergy =
            value

        updateForces()
    }

    func setShellRadius(
        _ value: Double
    ) {

        modelParameters.shellRadius =
            value

        updateForces()
    }

    func setShellWidth(
        _ value: Double
    ) {

        modelParameters.shellWidth =
            value

        updateForces()
    }

    func setShellCoupling(
        _ value: Double
    ) {

        modelParameters.shellCoupling =
            value

        updateForces()
    }

    func setShellCoherence(
        _ value: Double
    ) {

        modelParameters.shellCoherence =
            value

        updateForces()
    }

    func setEnergyLoss(
        _ value: Double
    ) {

        modelParameters.energyLoss =
            value

        updateForces()
    }

    func setExternalForce(
        _ value: Double
    ) {

        modelParameters.externalForce =
            value

        updateForces()
    }

    func setKineticForce(
        _ value: Double
    ) {

        modelParameters.kineticForce =
            value

        updateForces()
    }

    // ========================================================
    // MARK: - SEQUENCE CONTROL
    // ========================================================

    func goToStep(
        _ step: Int
    ) {

        let maximum =
            QRTLPhase.allCases.count - 1

        let clampedStep =
            min(
                max(
                    step,
                    0
                ),
                maximum
            )

        phaseProgress =
            clampedStep

        configurePhase(
            QRTLPhase.allCases[
                clampedStep
            ]
        )
    }

    // ========================================================
    // MARK: - NEXT
    // ========================================================

    func nextStep() {

        let next =
            min(
                phaseProgress + 1,
                QRTLPhase.allCases.count - 1
            )

        goToStep(
            next
        )
    }

    // ========================================================
    // MARK: - PREVIOUS
    // ========================================================

    func previousStep() {

        let previous =
            max(
                phaseProgress - 1,
                0
            )

        goToStep(
            previous
        )
    }

    // ========================================================
    // MARK: - RESET
    // ========================================================

    func resetToFirstStep() {

        isPlaying =
            false

        glucoseCreated =
            false

        elapsedTime =
            0

        lastTime =
            0

        goToStep(
            0
        )
    }

    // ========================================================
    // MARK: - PLAY
    // ========================================================

    func playSequence() {

        if phaseProgress >=
            QRTLPhase.allCases.count - 1 {

            phaseProgress =
                0

            configurePhase(
                .initialization
            )
        }

        isPlaying =
            true

        elapsedTime =
            0

        lastTime =
            0
    }

    // ========================================================
    // MARK: - PAUSE
    // ========================================================

    func pauseSequence() {

        isPlaying =
            false
    }

    // ========================================================
    // MARK: - LEGACY PLAY
    // ========================================================

    func play() {

        resetToFirstStep()

        playSequence()
    }

    // ========================================================
    // MARK: - LEGACY PAUSE
    // ========================================================

    func pause() {

        pauseSequence()
    }

    // ========================================================
    // MARK: - SCENE PHASE UPDATE
    // ========================================================

    private func updateSceneForCurrentPhase() {

        let progress =
            Double(
                phaseProgress
            ) /
            Double(
                max(
                    QRTLPhase.allCases.count - 1,
                    1
                )
            )

        // ----------------------------------------------------
        // Lattice
        // ----------------------------------------------------

        latticeNode.opacity =
            CGFloat(
                min(
                    1.0,
                    progress * 3.0 + 0.15
                )
            )

        // ----------------------------------------------------
        // Nucleus
        // ----------------------------------------------------

        nucleusNode.opacity =
            phaseProgress >=
            QRTLPhase.nucleus.rawValue
            ? 1.0
            : 0.15

        // ----------------------------------------------------
        // Electrons
        // ----------------------------------------------------

        electronNode.opacity =
            phaseProgress >=
            QRTLPhase.atom.rawValue
            ? 1.0
            : 0.10

        // ----------------------------------------------------
        // Current
        // ----------------------------------------------------

        currentNode.opacity =
            phaseProgress >=
            QRTLPhase.current.rawValue
            ? 1.0
            : 0.08

        // ----------------------------------------------------
        // Force visualization
        // ----------------------------------------------------

        forceNode.opacity =
            phaseProgress >=
            QRTLPhase.alignment.rawValue
            ? 1.0
            : 0.20

        // ----------------------------------------------------
        // Molecules
        // ----------------------------------------------------

        moleculeNode.opacity =
            phaseProgress >=
            QRTLPhase.carbonSkeleton.rawValue
            ? 1.0
            : 0.05

        // ----------------------------------------------------
        // Strand
        // ----------------------------------------------------

        strandNode.opacity =
            phaseProgress >=
            QRTLPhase.strandBond.rawValue
            ? 1.0
            : 0.05
    }

    // ========================================================
    // MARK: - ANIMATION
    // ========================================================

    func renderer(
        _ renderer: SCNSceneRenderer,
        updateAtTime time: TimeInterval
    ) {

        if lastTime == 0 {

            lastTime =
                time

            return
        }

        let delta =
            time -
            lastTime

        lastTime =
            time

        elapsedTime +=
            delta

        // ----------------------------------------------------
        // Continuous visual animation
        // ----------------------------------------------------

        animateCurrentPhase(
            time: time
        )

        guard isPlaying else {
            return
        }

        let stepDuration =
            2.5 /
            max(
                modelParameters.animationSpeed,
                0.1
            )

        if elapsedTime >=
            stepDuration {

            elapsedTime =
                0

            if phaseProgress <
                QRTLPhase.allCases.count - 1 {

                DispatchQueue.main.async {
                    [weak self] in

                    self?.nextStep()
                }

            } else {

                DispatchQueue.main.async {
                    [weak self] in

                    self?.isPlaying =
                        false
                }
            }
        }
    }

    // ========================================================
    // MARK: - PHASE ANIMATION
    // ========================================================

    private func animateCurrentPhase(
        time: TimeInterval
    ) {

        // ----------------------------------------------------
        // Energy shell rotation
        // ----------------------------------------------------

        shellNode.eulerAngles.y =
            Float(
                time *
                0.18
            )

        shellNode.eulerAngles.x =
            Float(
                sin(time * 0.25) *
                0.08
            )

        // ----------------------------------------------------
        // Electrons
        // ----------------------------------------------------

        let electronSpeed =
            0.75

        for (
            index,
            node
        ) in electronNode.childNodes.enumerated() {

            let angle =
                Float(
                    time *
                    electronSpeed
                ) +
                Float(index) *
                0.785

            let radius:
                Float = 0.48

            node.position =
                SCNVector3(
                    cos(angle) *
                        radius,

                    sin(angle) *
                        radius,

                    sin(
                        angle *
                        0.7
                    ) *
                    0.16
                )
        }

        // ----------------------------------------------------
        // Current particles
        // ----------------------------------------------------

        for (
            index,
            node
        ) in currentNode.childNodes.enumerated() {

            let offset =
                Float(index) *
                0.5

            let x =
                Float(
                    sin(
                        time *
                        2.0 +
                        Double(offset)
                    )
                ) *
                0.12

            node.position.x =
                Float(index) *
                0.28 -
                0.84 +
                x
        }

        // ----------------------------------------------------
        // Nucleus movement
        // ----------------------------------------------------

        let nucleusScale =
            1.0 +
            Float(
                sin(
                    time *
                    1.5
                )
            ) *
            0.025

        nucleusNode.scale =
            SCNVector3(
                nucleusScale,
                nucleusScale,
                nucleusScale
            )
    }

    // ========================================================
    // MARK: - RESET SCENE
    // ========================================================

    func resetScene() {

        phaseProgress = 0
        phase = .initialization
        isPlaying = false
        glucoseCreated = false

        elapsedTime = 0
        lastTime = 0

        modelParameters = QRTLParameters()

        // Clear CONTENT, not the container nodes.
        moleculeNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        nucleusNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        electronNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        strandNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        // Rebuild the visual elements.
        buildLattice()
        buildEnergyShell()
        buildNucleus()
        buildElectrons()
        buildForceVisualization()
        buildCurrentVisualization()

        // Make everything visible after reset.
        latticeNode.opacity = 1.0
        shellNode.opacity = 1.0
        nucleusNode.opacity = 1.0
        electronNode.opacity = 1.0
        currentNode.opacity = 1.0
        forceNode.opacity = 1.0
        moleculeNode.opacity = 1.0
        strandNode.opacity = 1.0

        updateForces()
        updateSceneForCurrentPhase()
    }


}
