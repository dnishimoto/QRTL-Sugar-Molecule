
//  ContentView.swift
//
//  QRTL 3D Energy-Shell Molecular Assembly
//
//  Conceptual visualization of:
//
//      CURRENT
//         ↓
//      QRTL ENERGY
//         ↓
//      QRTL ENERGY SHELL
//         ↓
//      QRTL LATTICE
//         ↓
//      NUCLEAR STABILIZATION MODEL
//         ↓
//      ATOMIC STRUCTURE
//         ↓
//      MOLECULAR ALIGNMENT
//         ↓
//      BOND STABILIZATION
//         ↓
//      GLUCOSE
//         ↓
//      GLUCOSE STRAND
//
//  IMPORTANT:
//
//  QRTL, the QRTL energy shell, and the proposed QRTL nuclear
//  stabilization interaction are hypothetical model constructs.
//  This program does NOT establish that QRTL replaces the strong
//  nuclear interaction in nature.
//
//  "Replace Strong Force" in this application means:
//
//      The conventional nuclear-force term is omitted from the
//      SIMULATION MODEL and replaced by the proposed QRTL effective
//      stabilization potential.
//
//  The visualization is intended to make the hypothesis explicit
//  and testable.
//
//  Frameworks:
//      SwiftUI
//      SceneKit
//      UIKit
//

import SwiftUI
import SceneKit
import UIKit
import Combine


// MARK: - QRTL Assembly Phase

enum QRTLPhase: Int, CaseIterable {

    case initialization = 0
    case lattice
    case proton
    case neutron
    case nucleus
    case energyShell
    case current
    case atom
    case alignment
    case bond
    case carbonSkeleton
    case glucose
    case glucoseStabilization
    case glucosePair
    case strandBond
    case strandGrowth
    case finalLock

    var title: String {

        switch self {

        case .initialization:
            return "QRTL FIELD INITIALIZATION"

        case .lattice:
            return "QRTL LATTICE FORMATION"

        case .proton:
            return "PROTON FORMATION"

        case .neutron:
            return "NEUTRON FORMATION"

        case .nucleus:
            return "NUCLEAR ASSEMBLY"

        case .energyShell:
            return "ENERGY SHELL FORMATION"

        case .current:
            return "CURRENT → QRTL ENERGY"

        case .atom:
            return "ATOM ASSEMBLY"

        case .alignment:
            return "MOLECULAR ALIGNMENT"

        case .bond:
            return "BOND STABILIZATION"

        case .carbonSkeleton:
            return "CARBON SKELETON"

        case .glucose:
            return "GLUCOSE FORMATION"

        case .glucoseStabilization:
            return "GLUCOSE ENERGY STABILIZATION"

        case .glucosePair:
            return "GLUCOSE–GLUCOSE ALIGNMENT"

        case .strandBond:
            return "GLUCOSE BOND"

        case .strandGrowth:
            return "STRAND GROWTH"

        case .finalLock:
            return "FINAL QRTL ENERGY LOCK"
        }
    }

    var explanation: String {

        switch self {

        case .initialization:
            return "The simulation establishes the QRTL field surrounding the assembly volume."

        case .lattice:
            return "QRTL lattice cells form a three-dimensional energetic framework."

        case .proton:
            return "The model visualizes a proton as a localized QRTL-stabilized nuclear state."

        case .neutron:
            return "The model visualizes a neutron as another localized QRTL-stabilized nuclear state."

        case .nucleus:
            return "Protons and neutrons are brought into a compact nuclear configuration."

        case .energyShell:
            return "The proposed QRTL energy shell creates an additional modeled stabilizing potential."

        case .current:
            return "External current is represented as energy input into the QRTL field."

        case .atom:
            return "The nucleus and electron cloud are combined into an atomic structure."

        case .alignment:
            return "External, kinetic, bond, and proposed QRTL forces act on molecular components."

        case .bond:
            return "The simulation places a proposed QRTL stabilization field around the forming bond."

        case .carbonSkeleton:
            return "Carbon units are progressively arranged into the six-carbon molecular framework."

        case .glucose:
            return "Hydrogen and oxygen are added to the six-carbon framework to visualize the glucose target."

        case .glucoseStabilization:
            return "The QRTL shell is reduced toward a stabilization state around the completed molecule."

        case .glucosePair:
            return "Two stabilized glucose structures are brought into a controlled orientation."

        case .strandBond:
            return "A proposed QRTL-stabilized interaction is visualized between adjacent glucose units."

        case .strandGrowth:
            return "Additional glucose units are added to the growing molecular strand."

        case .finalLock:
            return "The completed strand is surrounded by the final modeled QRTL energy shell."
        }
    }
}

// MARK: - QRTL Parameters

struct QRTLParameters {

    // MARK: Energy

    var shellEnergy: Double = 0.75

    var shellRadius: Double = 1.65

    var shellWidth: Double = 0.42

    var shellCoupling: Double = 0.80

    var shellCoherence: Double = 0.90

    var energyLoss: Double = 0.08

    // MARK: Current

    var current: Double = 0.50

    var currentEfficiency: Double = 0.70

    // MARK: External force

    var externalForce: Double = 0.40

    // MARK: Kinetic force

    var kineticForce: Double = 0.35

    // MARK: QRTL force

    var qrtlForceStrength: Double = 1.00

    // MARK: Bond stabilization

    var bondStrength: Double = 0.70

    // MARK: Nuclear model

    var replaceStrongForce: Bool = true

    // MARK: Animation

    var animationSpeed: Double = 1.0
}

// MARK: - QRTL Physics Model

struct QRTLPhysicsModel {

    var parameters: QRTLParameters

    // ------------------------------------------------------------
    // QRTL ENERGY SHELL
    //
    // V_QRTL(r) =
    //
    // -E_s exp[-(r-r_s)^2 / (2 sigma_s^2)]
    //
    // This is a phenomenological potential used only by this
    // visualization.
    // ------------------------------------------------------------

    func qrtlPotential(distance r: Double) -> Double {

        let rs = parameters.shellRadius
        let sigma = max(parameters.shellWidth, 0.001)

        let exponent =
            -pow(r - rs, 2.0) /
            (2.0 * sigma * sigma)

        return -parameters.shellEnergy *
               exp(exponent) *
               parameters.shellCoupling
    }

    // ------------------------------------------------------------
    // QRTL FORCE
    //
    // F_QRTL = -∇V_QRTL
    //
    // For the radial potential above:
    //
    // dV/dr =
    //
    // E_s * (r-r_s)/sigma^2 * exp(...)
    //
    // and therefore:
    //
    // F_r = -dV/dr
    // ------------------------------------------------------------

    func qrtlForce(distance r: Double) -> Double {

        let rs = parameters.shellRadius

        let sigma =
            max(parameters.shellWidth, 0.001)

        let exponential =
            exp(
                -pow(r - rs, 2.0) /
                (2.0 * sigma * sigma)
            )

        let derivative =
            parameters.shellEnergy *
            (r - rs) /
            (sigma * sigma) *
            exponential *
            parameters.shellCoupling

        return -derivative *
               parameters.qrtlForceStrength
    }

    // ------------------------------------------------------------
    // CURRENT → QRTL ENERGY
    //
    // P_QRTL = η I
    //
    // Current is normalized in this visualization.
    // ------------------------------------------------------------

    func currentPower() -> Double {

        return parameters.current *
               parameters.currentEfficiency
    }

    // ------------------------------------------------------------
    // ENERGY-SHELL EVOLUTION
    //
    // dE_s/dt =
    //
    // η_I P_I
    // - P_loss
    // - P_coupling
    // ------------------------------------------------------------

    func shellEnergyDerivative() -> Double {

        let input =
            currentPower()

        let loss =
            parameters.energyLoss *
            parameters.shellEnergy

        let coupling =
            parameters.shellCoupling *
            parameters.shellEnergy *
            0.05

        return input -
               loss -
               coupling
    }

    // ------------------------------------------------------------
    // EXTERNAL FORCE
    // ------------------------------------------------------------

    func externalForceVector() -> SCNVector3 {

        return SCNVector3(
            Float(parameters.externalForce),
            0,
            0
        )
    }

    // ------------------------------------------------------------
    // KINETIC FORCE
    //
    // Represented visually as the tendency of moving matter to
    // continue along its current trajectory.
    // ------------------------------------------------------------

    func kineticForceVector() -> SCNVector3 {

        return SCNVector3(
            0,
            Float(parameters.kineticForce),
            0
        )
    }

    // ------------------------------------------------------------
    // NET CONCEPTUAL FORCE
    // ------------------------------------------------------------

    func netForceMagnitude(
        distance: Double
    ) -> Double {

        let qrtl =
            abs(
                qrtlForce(
                    distance: distance
                )
            )

        let external =
            parameters.externalForce

        let kinetic =
            parameters.kineticForce

        let bond =
            parameters.bondStrength

        return qrtl +
               external +
               kinetic +
               bond
    }
}

// MARK: - SCNVector3 Math

extension SCNVector3 {

    static func + (
        lhs: SCNVector3,
        rhs: SCNVector3
    ) -> SCNVector3 {

        return SCNVector3(
            lhs.x + rhs.x,
            lhs.y + rhs.y,
            lhs.z + rhs.z
        )
    }

    static func - (
        lhs: SCNVector3,
        rhs: SCNVector3
    ) -> SCNVector3 {

        return SCNVector3(
            lhs.x - rhs.x,
            lhs.y - rhs.y,
            lhs.z - rhs.z
        )
    }

    static func * (
        lhs: SCNVector3,
        rhs: Float
    ) -> SCNVector3 {

        return SCNVector3(
            lhs.x * rhs,
            lhs.y * rhs,
            lhs.z * rhs
        )
    }

    func length() -> Float {

        return sqrt(
            x * x +
            y * y +
            z * z
        )
    }

    func normalized() -> SCNVector3 {

        let l = length()

        guard l > 0.0001 else {
            return SCNVector3Zero
        }

        return SCNVector3(
            x / l,
            y / l,
            z / l
        )
    }
}

// MARK: - QRTL Scene

final class QRTLSceneController:
    NSObject,
    ObservableObject,
    SCNSceneRendererDelegate {

    // MARK: Published state

    @Published var phase: QRTLPhase = .initialization

    @Published var phaseProgress: Double = 0

    @Published var current: Double = 0.50

    @Published var shellEnergy: Double = 0.75

    @Published var shellCoherence: Double = 0.90

    @Published var qrtlForce: Double = 0

    @Published var externalForce: Double = 0.40

    @Published var kineticForce: Double = 0.35

    @Published var bondForce: Double = 0.70

    @Published var isPlaying = false

    @Published var replaceStrongForce = true

    // MARK: Scene

    let scene = SCNScene()

    private var cameraNode =
        SCNNode()

    private var rootNode =
        SCNNode()

    private var latticeNode =
        SCNNode()

    private var shellNode =
        SCNNode()

    private var moleculeNode =
        SCNNode()

    private var forceNode =
        SCNNode()

    private var currentNode =
        SCNNode()

    private var nucleusNode =
        SCNNode()

    private var electronNode =
        SCNNode()

    private var strandNode =
        SCNNode()

    // MARK: Time

    private var lastTime: TimeInterval = 0

    private var elapsed: Double = 0

    // MARK: Parameters

    var parameters =
        QRTLParameters()

    // MARK: Initialization

    override init() {

        super.init()

        scene.rootNode.addChildNode(rootNode)

        configureScene()

        buildEnvironment()

        buildCamera()

        buildLighting()

        buildLattice()

        buildEnergyShell()

        buildForceVisualization()

        buildCurrentSystem()

        buildMolecule()

        resetScene()
    }

    // MARK: Configure Scene

    private func configureScene() {

        scene.background.contents =
            UIColor(
                red: 0.008,
                green: 0.012,
                blue: 0.025,
                alpha: 1
            )

        scene.rootNode.camera = nil

        scene.isPaused = false
    }

    // MARK: Environment

    private func buildEnvironment() {

        let floor =
            SCNFloor()

        floor.reflectivity = 0.15

        floor.firstMaterial =
            SCNMaterial()

        floor.firstMaterial?.diffuse.contents =
            UIColor(
                white: 0.035,
                alpha: 1
            )

        let floorNode =
            SCNNode(
                geometry: floor
            )

        floorNode.position =
            SCNVector3(
                0,
                -2.6,
                0
            )

        rootNode.addChildNode(
            floorNode
        )
    }

    // MARK: Camera

    private func buildCamera() {

        let camera =
            SCNCamera()

        camera.fieldOfView = 48

        camera.zNear = 0.01

        camera.zFar = 200

        cameraNode.camera = camera

        cameraNode.position =
            SCNVector3(
                0,
                3.0,
                11.0
            )

        rootNode.addChildNode(
            cameraNode
        )

        lookAt(
            node: cameraNode,
            target: SCNVector3(
                0,
                0,
                0
            )
        )
    }

    private func lookAt(
        node: SCNNode,
        target: SCNVector3
    ) {

        let direction =
            target -
            node.worldPosition

        let length =
            direction.length()

        guard length > 0.001 else {
            return
        }

        let normalized =
            direction.normalized()

        let yaw =
            atan2(
                normalized.x,
                normalized.z
            )

        let horizontal =
            sqrt(
                normalized.x *
                normalized.x +
                normalized.z *
                normalized.z
            )

        let pitch =
            atan2(
                normalized.y,
                horizontal
            )

        node.eulerAngles =
            SCNVector3(
                -pitch,
                yaw,
                0
            )
    }

    // MARK: Lighting

    private func buildLighting() {

        let key =
            SCNNode()

        let keyLight =
            SCNLight()

        keyLight.type =
            .omni

        keyLight.intensity =
            1100

        keyLight.color =
            UIColor.white

        key.light =
            keyLight

        key.position =
            SCNVector3(
                4,
                6,
                6
            )

        rootNode.addChildNode(
            key
        )

        let fill =
            SCNNode()

        let fillLight =
            SCNLight()

        fillLight.type =
            .omni

        fillLight.intensity =
            600

        fill.light =
            fillLight

        fill.position =
            SCNVector3(
                -5,
                2,
                4
            )

        rootNode.addChildNode(
            fill
        )
    }

    // MARK: QRTL Lattice

    private func buildLattice() {

        latticeNode =
            SCNNode()

        let spacing: Float =
            0.65

        let count =
            5

        for x in -count...count {

            for y in -count...count {

                for z in -count...count {

                    let distance =
                        sqrt(
                            Float(
                                x * x +
                                y * y +
                                z * z
                            )
                        )

                    if distance >
                        Float(count) {

                        continue
                    }

                    let sphere =
                        SCNSphere(
                            radius: 0.025
                        )

                    sphere.firstMaterial =
                        SCNMaterial()

                    sphere.firstMaterial?
                        .diffuse.contents =
                        UIColor(
                            red: 0.12,
                            green: 0.55,
                            blue: 1.0,
                            alpha: 0.85
                        )

                    let node =
                        SCNNode(
                            geometry: sphere
                        )

                    node.position =
                        SCNVector3(
                            Float(x) * spacing,
                            Float(y) * spacing,
                            Float(z) * spacing
                        )

                    latticeNode
                        .addChildNode(node)
                }
            }
        }

        rootNode.addChildNode(
            latticeNode
        )
    }

    // MARK: Energy Shell

    private func buildEnergyShell() {

        shellNode =
            SCNNode()

        let sphere =
            SCNSphere(
                radius:
                    CGFloat(
                        parameters.shellRadius
                    )
            )

        sphere.segmentCount = 64

        sphere.firstMaterial =
            SCNMaterial()

        sphere.firstMaterial?
            .diffuse.contents =
            UIColor(
                red: 0.2,
                green: 0.5,
                blue: 1.0,
                alpha: 0.055
            )

        sphere.firstMaterial?
            .emission.contents =
            UIColor(
                red: 0.1,
                green: 0.4,
                blue: 1.0,
                alpha: 0.10
            )

        sphere.firstMaterial?
            .isDoubleSided = true

        shellNode.geometry =
            sphere

        rootNode.addChildNode(
            shellNode
        )

        createShellRings()
    }

    private func createShellRings() {

        for radius in [
            1.25,
            1.65,
            2.05
        ] {

            let ring =
                SCNTorus(
                    ringRadius:
                        CGFloat(radius),
                    pipeRadius:
                        0.008
                )

            ring.firstMaterial =
                SCNMaterial()

            ring.firstMaterial?
                .emission.contents =
                UIColor(
                    red: 0.15,
                    green: 0.55,
                    blue: 1.0,
                    alpha: 0.85
                )

            let node =
                SCNNode(
                    geometry: ring
                )

            node.eulerAngles =
                SCNVector3(
                    Float.pi / 2,
                    0,
                    0
                )

            shellNode.addChildNode(
                node
            )
        }
    }

    // MARK: Force Visualization

    private func buildForceVisualization() {

        forceNode =
            SCNNode()

        rootNode.addChildNode(
            forceNode
        )
    }

    // MARK: Force Arrow

    private func makeArrow(
        from start: SCNVector3,
        direction: SCNVector3,
        length: Float,
        radius: CGFloat,
        label: String
    ) -> SCNNode {

        let group =
            SCNNode()

        let normalized =
            direction.normalized()

        let end =
            start +
            normalized * length

        let vector =
            end -
            start

        let distance =
            vector.length()

        let cylinder =
            SCNCylinder(
                radius: radius,
                height: CGFloat(distance)
            )

        cylinder.firstMaterial =
            SCNMaterial()

        cylinder.firstMaterial?
            .diffuse.contents =
            UIColor.white

        let shaft =
            SCNNode(
                geometry: cylinder
            )

        shaft.position =
            SCNVector3(
                (start.x + end.x) / 2,
                (start.y + end.y) / 2,
                (start.z + end.z) / 2
            )

        orientCylinder(
            shaft,
            direction: vector
        )

        group.addChildNode(
            shaft
        )

        let cone =
            SCNCone(
                topRadius: 0,
                bottomRadius:
                    radius * 3,
                height:
                    radius * 8
            )

        cone.firstMaterial =
            SCNMaterial()

        cone.firstMaterial?
            .diffuse.contents =
            UIColor.white

        let head =
            SCNNode(
                geometry: cone
            )

        head.position =
            end

        orientCone(
            head,
            direction: normalized
        )

        group.addChildNode(
            head
        )

        let text =
            SCNText(
                string: label,
                extrusionDepth: 0.002
            )

        text.font =
            UIFont.systemFont(
                ofSize: 0.12,
                weight: .bold
            )

        text.firstMaterial =
            SCNMaterial()

        text.firstMaterial?
            .diffuse.contents =
            UIColor.white

        let textNode =
            SCNNode(
                geometry: text
            )

        textNode.scale =
            SCNVector3(
                0.45,
                0.45,
                0.45
            )

        textNode.position =
            end +
            SCNVector3(
                0.08,
                0.08,
                0
            )

        group.addChildNode(
            textNode
        )

        return group
    }

    private func orientCylinder(
        _ node: SCNNode,
        direction: SCNVector3
    ) {

        let normalized =
            direction.normalized()

        let y =
            SCNVector3(
                0,
                1,
                0
            )

        let dot =
            y.x * normalized.x +
            y.y * normalized.y +
            y.z * normalized.z

        if dot > 0.999 {

            node.eulerAngles =
                SCNVector3Zero

            return
        }

        if dot < -0.999 {

            node.eulerAngles =
                SCNVector3(
                    Float.pi,
                    0,
                    0
                )

            return
        }

        let axis =
            SCNVector3(
                y.y * normalized.z -
                y.z * normalized.y,

                y.z * normalized.x -
                y.x * normalized.z,

                y.x * normalized.y -
                y.y * normalized.x
            )

        let angle =
            acos(
                max(
                    -1,
                    min(
                        1,
                        dot
                    )
                )
            )

        node.rotation =
            SCNVector4(
                axis.x,
                axis.y,
                axis.z,
                angle
            )
    }

    private func orientCone(
        _ node: SCNNode,
        direction: SCNVector3
    ) {

        orientCylinder(
            node,
            direction: direction
        )
    }

    // MARK: Current Visualization

    private func buildCurrentSystem() {

        currentNode =
            SCNNode()

        rootNode.addChildNode(
            currentNode
        )

        for i in 0..<7 {

            let particle =
                SCNSphere(
                    radius: 0.045
                )

            particle.firstMaterial =
                SCNMaterial()

            particle.firstMaterial?
                .emission.contents =
                UIColor(
                    red: 1.0,
                    green: 0.75,
                    blue: 0.1,
                    alpha: 1
                )

            let node =
                SCNNode(
                    geometry: particle
                )

            node.position =
                SCNVector3(
                    -5.0,
                    0,
                    Float(i - 3) * 0.30
                )

            currentNode
                .addChildNode(node)

            animateCurrentParticle(
                node,
                delay:
                    Double(i) * 0.16
            )
        }
    }

    private func animateCurrentParticle(
        _ node: SCNNode,
        delay: Double
    ) {

        let move =
            SCNAction.move(
                to: SCNVector3(
                    0,
                    0,
                    node.position.z
                ),
                duration: 1.5
            )

        let reset =
            SCNAction.move(
                to: SCNVector3(
                    -5.0,
                    0,
                    node.position.z
                ),
                duration: 0
            )

        let sequence =
            SCNAction.sequence([
                SCNAction.wait(
                    duration: delay
                ),
                move,
                reset
            ])

        node.runAction(
            SCNAction.repeatForever(
                sequence
            )
        )
    }

    // MARK: Molecule

    private func buildMolecule() {

        moleculeNode =
            SCNNode()

        rootNode.addChildNode(
            moleculeNode
        )
    }

    // MARK: Proton

    private func createProton(
        position: SCNVector3
    ) -> SCNNode {

        let geometry =
            SCNSphere(
                radius: 0.18
            )

        geometry.firstMaterial =
            SCNMaterial()

        geometry.firstMaterial?
            .diffuse.contents =
            UIColor(
                red: 0.95,
                green: 0.20,
                blue: 0.20,
                alpha: 1
            )

        geometry.firstMaterial?
            .emission.contents =
            UIColor(
                red: 0.30,
                green: 0.02,
                blue: 0.02,
                alpha: 0.5
            )

        let node =
            SCNNode(
                geometry: geometry
            )

        node.position =
            position

        addParticleLabel(
            node,
            text: "p+"
        )

        return node
    }

    // MARK: Neutron

    private func createNeutron(
        position: SCNVector3
    ) -> SCNNode {

        let geometry =
            SCNSphere(
                radius: 0.18
            )

        geometry.firstMaterial =
            SCNMaterial()

        geometry.firstMaterial?
            .diffuse.contents =
            UIColor(
                red: 0.65,
                green: 0.65,
                blue: 0.70,
                alpha: 1
            )

        geometry.firstMaterial?
            .emission.contents =
            UIColor(
                white: 0.20,
                alpha: 0.5
            )

        let node =
            SCNNode(
                geometry: geometry
            )

        node.position =
            position

        addParticleLabel(
            node,
            text: "n"
        )

        return node
    }

    // MARK: Electron

    private func createElectron(
        position: SCNVector3
    ) -> SCNNode {

        let geometry =
            SCNSphere(
                radius: 0.065
            )

        geometry.firstMaterial =
            SCNMaterial()

        geometry.firstMaterial?
            .emission.contents =
            UIColor(
                red: 0.25,
                green: 0.80,
                blue: 1.0,
                alpha: 1
            )

        let node =
            SCNNode(
                geometry: geometry
            )

        node.position =
            position

        return node
    }

    // MARK: Particle Label

    private func addParticleLabel(
        _ node: SCNNode,
        text: String
    ) {

        let label =
            SCNText(
                string: text,
                extrusionDepth: 0.01
            )

        label.font =
            UIFont.boldSystemFont(
                ofSize: 0.14
            )

        label.firstMaterial =
            SCNMaterial()

        label.firstMaterial?
            .diffuse.contents =
            UIColor.white

        let labelNode =
            SCNNode(
                geometry: label
            )

        labelNode.scale =
            SCNVector3(
                0.35,
                0.35,
                0.35
            )

        labelNode.position =
            SCNVector3(
                -0.06,
                0.20,
                0
            )

        node.addChildNode(
            labelNode
        )
    }

    // MARK: Create Nucleus

    private func createNucleus() {

        nucleusNode =
            SCNNode()

        let protonPositions = [
            SCNVector3(-0.25, 0.05, 0),
            SCNVector3(0.25, -0.05, 0),
            SCNVector3(0, 0.0, 0.25)
        ]

        let neutronPositions = [
            SCNVector3(0, 0.22, -0.12),
            SCNVector3(-0.20, -0.18, 0.10),
            SCNVector3(0.20, -0.20, -0.10)
        ]

        for position in protonPositions {

            nucleusNode.addChildNode(
                createProton(
                    position: position
                )
            )
        }

        for position in neutronPositions {

            nucleusNode.addChildNode(
                createNeutron(
                    position: position
                )
            )
        }

        moleculeNode.addChildNode(
            nucleusNode
        )
    }

    // MARK: Electrons

    private func createElectronCloud() {

        electronNode =
            SCNNode()

        let radius =
            Float(1.05)

        for i in 0..<8 {

            let angle =
                Float(i) *
                Float.pi *
                2 /
                8

            let position =
                SCNVector3(
                    cos(angle) * radius,
                    sin(angle) * radius * 0.55,
                    sin(angle) * radius
                )

            electronNode.addChildNode(
                createElectron(
                    position: position
                )
            )
        }

        moleculeNode.addChildNode(
            electronNode
        )

        animateElectronCloud()
    }

    private func animateElectronCloud() {

        let rotation =
            SCNAction.rotateBy(
                x: 0,
                y: CGFloat.pi * 2,
                z: 0,
                duration: 4
            )

        electronNode.runAction(
            SCNAction.repeatForever(
                rotation
            )
        )
    }

    // MARK: Carbon Units

    private func createCarbon(
        position: SCNVector3,
        scale: Float = 1
    ) -> SCNNode {

        let sphere =
            SCNSphere(
                radius:
                    CGFloat(0.22 * scale)
            )

        sphere.firstMaterial =
            SCNMaterial()

        sphere.firstMaterial?
            .diffuse.contents =
            UIColor(
                white: 0.12,
                alpha: 1
            )

        sphere.firstMaterial?
            .emission.contents =
            UIColor(
                white: 0.12,
                alpha: 0.4
            )

        let node =
            SCNNode(
                geometry: sphere
            )

        node.position =
            position

        addParticleLabel(
            node,
            text: "C"
        )

        return node
    }

    // MARK: Oxygen

    private func createOxygen(
        position: SCNVector3
    ) -> SCNNode {

        let sphere =
            SCNSphere(
                radius: 0.18
            )

        sphere.firstMaterial =
            SCNMaterial()

        sphere.firstMaterial?
            .diffuse.contents =
            UIColor(
                red: 0.95,
                green: 0.30,
                blue: 0.30,
                alpha: 1
            )

        let node =
            SCNNode(
                geometry: sphere
            )

        node.position =
            position

        addParticleLabel(
            node,
            text: "O"
        )

        return node
    }

    // MARK: Hydrogen

    private func createHydrogen(
        position: SCNVector3
    ) -> SCNNode {

        let sphere =
            SCNSphere(
                radius: 0.10
            )

        sphere.firstMaterial =
            SCNMaterial()

        sphere.firstMaterial?
            .diffuse.contents =
            UIColor.white

        let node =
            SCNNode(
                geometry: sphere
            )

        node.position =
            position

        addParticleLabel(
            node,
            text: "H"
        )

        return node
    }

    // MARK: Bond

    private func createBond(
        from a: SCNVector3,
        to b: SCNVector3
    ) -> SCNNode {

        let vector =
            b - a

        let distance =
            vector.length()

        let cylinder =
            SCNCylinder(
                radius: 0.035,
                height: CGFloat(distance)
            )

        cylinder.firstMaterial =
            SCNMaterial()

        cylinder.firstMaterial?
            .diffuse.contents =
            UIColor(
                white: 0.65,
                alpha: 0.85
            )

        let node =
            SCNNode(
                geometry: cylinder
            )

        node.position =
            SCNVector3(
                (a.x + b.x) / 2,
                (a.y + b.y) / 2,
                (a.z + b.z) / 2
            )

        orientCylinder(
            node,
            direction: vector
        )

        return node
    }

    // MARK: Glucose

    private func createGlucose(
        offset: SCNVector3
    ) -> SCNNode {

        let group =
            SCNNode()

        // Six-carbon backbone.

        let carbonPositions = [
            SCNVector3(-1.15, 0.0, 0.0),
            SCNVector3(-0.70, 0.35, 0.0),
            SCNVector3(-0.15, 0.20, 0.0),
            SCNVector3(0.35, -0.15, 0.0),
            SCNVector3(0.85, 0.10, 0.0),
            SCNVector3(1.25, -0.25, 0.0)
        ]

        for position in carbonPositions {

            group.addChildNode(
                createCarbon(
                    position:
                        position +
                        offset,
                    scale: 0.82
                )
            )
        }

        for i in 0..<carbonPositions.count - 1 {

            group.addChildNode(
                createBond(
                    from:
                        carbonPositions[i] +
                        offset,
                    to:
                        carbonPositions[i + 1] +
                        offset
                )
            )
        }

        // Oxygen atoms.

        let oxygenPositions = [
            SCNVector3(-0.95, 0.70, 0.0),
            SCNVector3(-0.35, -0.35, 0.0),
            SCNVector3(0.20, 0.65, 0.0),
            SCNVector3(0.70, -0.70, 0.0),
            SCNVector3(1.05, 0.65, 0.0),
            SCNVector3(1.50, -0.65, 0.0)
        ]

        for position in oxygenPositions {

            group.addChildNode(
                createOxygen(
                    position:
                        position +
                        offset
                )
            )
        }

        // Hydrogen atoms.

        let hydrogenPositions = [
            SCNVector3(-1.35, 0.50, 0.0),
            SCNVector3(-0.55, 0.75, 0.0),
            SCNVector3(-0.05, -0.70, 0.0),
            SCNVector3(0.50, 0.80, 0.0),
            SCNVector3(0.90, -0.95, 0.0),
            SCNVector3(1.40, 0.95, 0.0)
        ]

        for position in hydrogenPositions {

            group.addChildNode(
                createHydrogen(
                    position:
                        position +
                        offset
                )
            )
        }

        return group
    }

    // MARK: Glucose Strand

    private func createStrand(
        count: Int
    ) {

        strandNode.removeFromParentNode()

        strandNode =
            SCNNode()

        for i in 0..<count {

            let offset =
                SCNVector3(
                    Float(i) * 2.35 -
                    Float(count - 1) * 1.175,
                    0,
                    0
                )

            let glucose =
                createGlucose(
                    offset: offset
                )

            strandNode.addChildNode(
                glucose
            )
        }

        // Inter-unit conceptual stabilizing links.

        if count > 1 {

            for i in 0..<count - 1 {

                let x1 =
                    Float(i) * 2.35 -
                    Float(count - 1) * 1.175 +
                    1.25

                let x2 =
                    Float(i + 1) * 2.35 -
                    Float(count - 1) * 1.175 -
                    1.15

                let bond =
                    createBond(
                        from:
                            SCNVector3(
                                x1,
                                -0.05,
                                0
                            ),
                        to:
                            SCNVector3(
                                x2,
                                0.05,
                                0
                            )
                    )

                strandNode.addChildNode(
                    bond
                )
            }
        }

        moleculeNode.addChildNode(
            strandNode
        )
    }

    // MARK: Force Arrows

    func updateForces() {

        forceNode.childNodes
            .forEach {
                $0.removeFromParentNode()
            }

        let model =
            QRTLPhysicsModel(
                parameters:
                    parameters
            )

        let qrtl =
            model.qrtlForce(
                distance:
                    parameters.shellRadius
            )

        qrtlForce =
            abs(qrtl)

        externalForce =
            parameters.externalForce

        kineticForce =
            parameters.kineticForce

        bondForce =
            parameters.bondStrength

        let center =
            SCNVector3(
                0,
                0,
                0
            )

        // QRTL force

        let qrtlArrow =
            makeArrow(
                from:
                    center,
                direction:
                    SCNVector3(
                        Float(
                            qrtl >= 0
                            ? 1
                            : -1
                        ),
                        0,
                        0
                    ),
                length:
                    Float(
                        max(
                            0.25,
                            min(
                                1.4,
                                abs(qrtl) *
                                1.2
                            )
                        )
                    ),
                radius: 0.025,
                label: "QRTL"
            )

        qrtlArrow.position =
            SCNVector3(
                0,
                -0.65,
                0
            )

        forceNode.addChildNode(
            qrtlArrow
        )

        // External force

        let externalArrow =
            makeArrow(
                from:
                    center,
                direction:
                    SCNVector3(
                        0,
                        1,
                        0
                    ),
                length:
                    Float(
                        max(
                            0.25,
                            parameters.externalForce
                        )
                    ),
                radius: 0.022,
                label: "EXTERNAL"
            )

        externalArrow.position =
            SCNVector3(
                -0.65,
                0,
                0
            )

        forceNode.addChildNode(
            externalArrow
        )

        // Kinetic force

        let kineticArrow =
            makeArrow(
                from:
                    center,
                direction:
                    SCNVector3(
                        0,
                        0,
                        1
                    ),
                length:
                    Float(
                        max(
                            0.25,
                            parameters.kineticForce
                        )
                    ),
                radius: 0.022,
                label: "KINETIC"
            )

        kineticArrow.position =
            SCNVector3(
                0.65,
                0,
                0
            )

        forceNode.addChildNode(
            kineticArrow
        )

        // Bond stabilization

        let bondArrow =
            makeArrow(
                from:
                    center,
                direction:
                    SCNVector3(
                        -1,
                        -1,
                        0
                    ),
                length:
                    Float(
                        max(
                            0.25,
                            parameters.bondStrength
                        )
                    ),
                radius: 0.022,
                label: "BOND"
            )

        bondArrow.position =
            SCNVector3(
                0,
                0.65,
                0
            )

        forceNode.addChildNode(
            bondArrow
        )
    }

    // MARK: Reset

    func resetScene() {

        elapsed = 0

        phaseProgress = 0

        phase =
            .initialization

        parameters =
            QRTLParameters()

        current =
            parameters.current

        shellEnergy =
            parameters.shellEnergy

        shellCoherence =
            parameters.shellCoherence

        replaceStrongForce =
            parameters.replaceStrongForce

        nucleusNode
            .removeFromParentNode()

        electronNode
            .removeFromParentNode()

        strandNode
            .removeFromParentNode()

        moleculeNode
            .childNodes
            .forEach {
                $0.removeFromParentNode()
            }

        createNucleus()

        createElectronCloud()

        buildCarbonPreview()

        updateForces()
    }

    // MARK: Carbon Preview

    private func buildCarbonPreview() {

        let positions = [
            SCNVector3(
                -0.9,
                0,
                0
            ),
            SCNVector3(
                0,
                0.35,
                0
            ),
            SCNVector3(
                0.9,
                0,
                0
            )
        ]

        for position in positions {

            moleculeNode.addChildNode(
                createCarbon(
                    position:
                        position
                )
            )
        }
    }

    // MARK: Play

    func play() {

        isPlaying = true

        elapsed = 0

        phase =
            .initialization
    }

    func pause() {

        isPlaying = false
    }

    func nextPhase() {

        let next =
            phase.rawValue + 1

        if next <
            QRTLPhase.allCases.count {

            phase =
                QRTLPhase(
                    rawValue:
                        next
                )!

            phaseProgress = 0

            configurePhase()
        }
    }

    // MARK: Configure Phase

    private func configurePhase() {

        switch phase {

        case .initialization:

            parameters.current = 0.05
            parameters.shellEnergy = 0.10

        case .lattice:

            parameters.current = 0.15
            parameters.shellEnergy = 0.25

        case .proton:

            parameters.current = 0.25
            parameters.shellEnergy = 0.40

        case .neutron:

            parameters.current = 0.28
            parameters.shellEnergy = 0.45

        case .nucleus:

            parameters.current = 0.35
            parameters.shellEnergy = 0.55

        case .energyShell:

            parameters.current = 0.30
            parameters.shellEnergy = 0.75

        case .current:

            parameters.current = 0.90
            parameters.shellEnergy = 1.00

        case .atom:

            parameters.current = 0.25
            parameters.shellEnergy = 0.80

        case .alignment:

            parameters.current = 0.40
            parameters.shellEnergy = 0.75

            parameters.externalForce =
                0.60

            parameters.kineticForce =
                0.45

        case .bond:

            parameters.current = 0.55
            parameters.shellEnergy = 0.90

            parameters.bondStrength =
                0.90

        case .carbonSkeleton:

            parameters.current = 0.45
            parameters.shellEnergy = 0.82

        case .glucose:

            parameters.current = 0.30
            parameters.shellEnergy = 0.85

        case .glucoseStabilization:

            parameters.current = 0.05
            parameters.shellEnergy = 0.90

        case .glucosePair:

            parameters.current = 0.20
            parameters.shellEnergy = 0.75

        case .strandBond:

            parameters.current = 0.35
            parameters.shellEnergy = 0.90

            parameters.bondStrength =
                1.00

        case .strandGrowth:

            parameters.current = 0.30
            parameters.shellEnergy = 0.92

        case .finalLock:

            parameters.current = 0.02
            parameters.shellEnergy = 1.00

            parameters.shellCoherence =
                0.98
        }

        current =
            parameters.current

        shellEnergy =
            parameters.shellEnergy

        shellCoherence =
            parameters.shellCoherence

        updateForces()
    }

    // MARK: Renderer Update

    func renderer(
        _ renderer: SCNSceneRenderer,
        updateAtTime time: TimeInterval
    ) {

        if lastTime == 0 {

            lastTime =
                time

            return
        }

        let dt =
            min(
                time -
                lastTime,
                0.05
            )

        lastTime =
            time

        guard isPlaying else {
            return
        }

        elapsed +=
            dt *
            parameters.animationSpeed

        let duration =
            3.0

        phaseProgress =
            min(
                elapsed /
                duration,
                1
            )

        animatePhase(
            progress:
                phaseProgress
        )

        if phaseProgress >= 1 {

            if phase.rawValue <
                QRTLPhase.allCases.count - 1 {

                phase =
                    QRTLPhase(
                        rawValue:
                            phase.rawValue + 1
                    )!

                elapsed = 0

                configurePhase()

            } else {

                isPlaying = false
            }
        }
    }

    // MARK: Animate Phase

    private func animatePhase(
        progress: Double
    ) {

        let p =
            Float(
                progress
            )

        // Lattice intensity.

        let latticeOpacity =
            CGFloat(
                min(
                    1,
                    max(
                        0,
                        progress * 2
                    )
                )
            )

        latticeNode.opacity =
            latticeOpacity

        // Shell intensity.

        let shellScale =
            0.45 +
            CGFloat(
                progress
            ) *
            0.55

        shellNode.scale =
            SCNVector3(
                shellScale,
                shellScale,
                shellScale
            )

        shellNode.opacity =
            CGFloat(
                0.15 +
                shellEnergy *
                0.75
            )

        // Rotate QRTL lattice.

        latticeNode.eulerAngles.y =
            p *
            Float.pi *
            0.75

        // Pulsing energy shell.

        let pulse =
            1.0 +
            sin(
                Float(elapsed) *
                4
            ) *
            0.04 *
            Float(shellCoherence)

        shellNode.scale =
            SCNVector3(
                shellScale *
                CGFloat(pulse),
                shellScale *
                CGFloat(pulse),
                shellScale *
                CGFloat(pulse)
            )

        // Nucleus stabilization.

        if phase.rawValue >=
            QRTLPhase.proton.rawValue {

            nucleusNode.opacity =
                1
        }

        // Atom.

        if phase.rawValue >=
            QRTLPhase.atom.rawValue {

            electronNode.opacity =
                1
        } else {

            electronNode.opacity =
                0.1
        }

        // Glucose progression.

        if phase.rawValue >=
            QRTLPhase.glucose.rawValue {

            buildGlucoseIfNeeded()
        }

        // Strand progression.

        if phase.rawValue >=
            QRTLPhase.strandGrowth.rawValue {

            let count =
                min(
                    5,
                    max(
                        2,
                        Int(
                            progress *
                            5
                        ) + 1
                    )
                )

            createStrand(
                count:
                    count
            )
        }
    }

    private var glucoseCreated =
        false

    private func buildGlucoseIfNeeded() {

        if glucoseCreated {
            return
        }

        glucoseCreated =
            true

        moleculeNode
            .childNodes
            .filter {
                $0 !== nucleusNode &&
                $0 !== electronNode
            }
            .forEach {
                $0.removeFromParentNode()
            }

        let glucose =
            createGlucose(
                offset:
                    SCNVector3Zero
            )

        glucose.opacity =
            0

        moleculeNode.addChildNode(
            glucose
        )

        glucose.runAction(
            SCNAction.fadeIn(
                duration: 1.2
            )
        )
    }
}

// MARK: - SceneKit View

struct QRTLSceneView:
    UIViewRepresentable {

    @ObservedObject
    var controller:
        QRTLSceneController

    func makeUIView(
        context:
            Context
    ) -> SCNView {

        let view =
            SCNView()

        view.scene =
            controller.scene

        view.delegate =
            controller

        view.allowsCameraControl =
            true

        view.autoenablesDefaultLighting =
            false

        view.preferredFramesPerSecond =
            60

        view.antialiasingMode =
            .multisampling4X

        return view
    }

    func updateUIView(
        _ uiView: SCNView,
        context:
            Context
    ) {

        uiView.scene =
            controller.scene
    }
}

// MARK: - ContentView

struct ContentView:
    View {

    @StateObject
    private var controller =
        QRTLSceneController()

    var body: some View {

        ZStack {

            QRTLSceneView(
                controller:
                    controller
            )
            .ignoresSafeArea()

            VStack(
                spacing: 12
            ) {

                header

                Spacer()

                phasePanel

                controlPanel
            }
            .padding()
        }
        .onAppear {

            controller
                .scene
                .isPaused = false
        }
    }

    // MARK: Header

    private var header:
        some View {

        VStack(
            spacing: 5
        ) {

            Text(
                "QRTL MOLECULAR ASSEMBLY"
            )
            .font(
                .system(
                    size: 20,
                    weight: .bold
                )
            )
            .foregroundStyle(
                .white
            )

            Text(
                "Energy Shell • QRTL Lattice • Nuclear Model • Molecular Stabilization"
            )
            .font(
                .system(
                    size: 11
                )
            )
            .foregroundStyle(
                .white.opacity(0.75)
            )

        }
        .padding(
            .horizontal,
            16
        )
        .padding(
            .vertical,
            10
        )
        .background(
            .ultraThinMaterial,
            in:
                RoundedRectangle(
                    cornerRadius: 16
                )
        )
    }

    // MARK: Phase Panel

    private var phasePanel:
        some View {

        VStack(
            alignment:
                .leading,
            spacing: 7
        ) {

            Text(
                "PHASE \(controller.phase.rawValue + 1) / \(QRTLPhase.allCases.count)"
            )
            .font(
                .caption
            )
            .fontWeight(
                .bold
            )

            Text(
                controller.phase.title
            )
            .font(
                .headline
            )

            Text(
                controller.phase.explanation
            )
            .font(
                .caption
            )
            .fixedSize(
                horizontal:
                    false,
                vertical:
                    true
            )

            ProgressView(
                value:
                    controller.phaseProgress
            )

            Divider()

            HStack {

                metric(
                    title:
                        "CURRENT",
                    value:
                        controller.current,
                    suffix:
                        ""
                )

                metric(
                    title:
                        "SHELL",
                    value:
                        controller.shellEnergy,
                    suffix:
                        ""
                )

                metric(
                    title:
                        "QRTL FORCE",
                    value:
                        controller.qrtlForce,
                    suffix:
                        ""
                )

                metric(
                    title:
                        "COHERENCE",
                    value:
                        controller.shellCoherence,
                    suffix:
                        ""
                )
            }

        }
        .padding()
        .background(
            .ultraThinMaterial,
            in:
                RoundedRectangle(
                    cornerRadius: 16
                )
        )
    }

    private func metric(
        title: String,
        value: Double,
        suffix: String
    ) -> some View {

        VStack(
            spacing: 2
        ) {

            Text(title)
                .font(
                    .system(
                        size: 8,
                        weight: .bold
                    )
                )

            Text(
                String(
                    format:
                        "%.2f%@",
                    value,
                    suffix
                )
            )
            .font(
                .system(
                    size: 13,
                    weight: .bold
                )
            )
        }
        .frame(
            maxWidth:
                .infinity
        )
    }

    // MARK: Controls

    private var controlPanel:
        some View {

        VStack(
            spacing: 10
        ) {

            HStack {

                Button {

                    if controller.isPlaying {

                        controller.pause()

                    } else {

                        controller.play()
                    }

                } label: {

                    Label(
                        controller.isPlaying
                        ? "Pause"
                        : "Play",
                        systemImage:
                            controller.isPlaying
                            ? "pause.fill"
                            : "play.fill"
                    )
                    .frame(
                        maxWidth:
                            .infinity
                    )
                }
                .buttonStyle(
                    .borderedProminent
                )

                Button {

                    controller
                        .nextPhase()

                } label: {

                    Label(
                        "Next",
                        systemImage:
                            "forward.fill"
                    )
                    .frame(
                        maxWidth:
                            .infinity
                    )
                }
                .buttonStyle(
                    .bordered
                )

                Button {

                    controller
                        .resetScene()

                } label: {

                    Label(
                        "Reset",
                        systemImage:
                            "arrow.counterclockwise"
                    )
                    .frame(
                        maxWidth:
                            .infinity
                    )
                }
                .buttonStyle(
                    .bordered
                )
            }

            VStack(
                alignment:
                    .leading,
                spacing: 4
            ) {

                Text(
                    "CURRENT → QRTL ENERGY"
                )
                .font(
                    .caption
                )
                .fontWeight(
                    .bold
                )

                Slider(
                    value:
                        Binding(
                            get: {
                                controller.current
                            },
                            set: {
                                controller.current =
                                    $0

                                controller.parameters.current =
                                    $0
                            }
                        ),
                    in:
                        0...1
                )
            }

            VStack(
                alignment:
                    .leading,
                spacing: 4
            ) {

                Text(
                    "EXTERNAL FORCE"
                )
                .font(
                    .caption
                )

                Slider(
                    value:
                        Binding(
                            get: {
                                controller.externalForce
                            },
                            set: {

                                controller.externalForce =
                                    $0

                                controller.parameters.externalForce =
                                    $0

                                controller.updateForces()
                            }
                        ),
                    in:
                        0...1
                )
            }

            VStack(
                alignment:
                    .leading,
                spacing: 4
            ) {

                Text(
                    "KINETIC FORCE"
                )
                .font(
                    .caption
                )

                Slider(
                    value:
                        Binding(
                            get: {
                                controller.kineticForce
                            },
                            set: {

                                controller.kineticForce =
                                    $0

                                controller.parameters.kineticForce =
                                    $0

                                controller.updateForces()
                            }
                        ),
                    in:
                        0...1
                )
            }

            Toggle(
                "Use QRTL model instead of conventional nuclear-force term",
                isOn:
                    Binding(
                        get: {
                            controller.replaceStrongForce
                        },
                        set: {

                            controller.replaceStrongForce =
                                $0

                            controller.parameters.replaceStrongForce =
                                $0
                        }
                    )
            )
            .font(
                .caption
            )

            Text(
                "Model only: the QRTL nuclear interaction is a hypothetical effective potential and is not an experimentally established replacement for the strong interaction."
            )
            .font(
                .system(
                    size: 9
                )
            )
            .foregroundStyle(
                .white.opacity(0.65)
            )
        }
        .padding()
        .background(
            .ultraThinMaterial,
            in:
                RoundedRectangle(
                    cornerRadius: 16
                )
        )
    }
}

// MARK: - Preview

#Preview {

    ContentView()
}

