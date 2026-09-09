//
//  QRTLSceneController.swift
//  Self Assembling Sugar
//
//  Stage-by-stage QRTL Frequency Cascade visualization
//

import Foundation
import SwiftUI
import SceneKit
import Combine

final class QRTLSceneController:
    NSObject,
    ObservableObject,
    SCNSceneRendererDelegate
{
    private var carbonTargetPositions: [SCNVector3] = []
    private var hydrogenTargetPositions: [SCNVector3] = []
    private var oxygenTargetPositions: [SCNVector3] = []

    private var glucoseCreated = false

    @Published var phase: QRTLPhase = .spaceEnvironment
    @Published var phaseProgress: Int = 0

    @Published var current: Double = 0.05
    @Published var currentEfficiency: Double = 0.25
    @Published var effectiveInput: Double = 0

    @Published var shellEnergy: Double = 0.10
    @Published var shellRadius: Double = 1.65
    @Published var shellWidth: Double = 0.42
    @Published var shellCoupling: Double = 0.20
    @Published var shellCoherence: Double = 0.20

    @Published var qrtlPressure: Double = 0

    @Published var energyLoss: Double = 0.10
    @Published var reactionEnergy: Double = 0

    @Published var qrtlForce: Double = 0
    @Published var externalForce: Double = 0.05
    @Published var kineticForce: Double = 0.05
    @Published var bondForce: Double = 0.10

    @Published var isPlaying = false
    @Published var replaceStrongForce = true

    // ============================================================
    // MARK: - MODEL
    // ============================================================

    private var modelParameters = QRTLParameters()
    private let physics = QRTLPhysicsModel()

    private weak var sceneView: SCNView?
    private var scene: SCNScene!

    // ============================================================
    // MARK: - WORLD NODES
    // ============================================================

    private let worldNode = SCNNode()

    private let latticeNode = SCNNode()
    private let shellNode = SCNNode()
    private let forceNode = SCNNode()
    private let currentNode = SCNNode()

    private let nucleusNode = SCNNode()
    private let electronNode = SCNNode()

    // ============================================================
    // MARK: - MOLECULAR NODES
    //
    // These are intentionally separated so the molecule is built
    // progressively instead of appearing all at once.
    // ============================================================

    private let moleculeNode = SCNNode()

    private let sourceNode = SCNNode()
    private let waterNode = SCNNode()

    private let carbonNode = SCNNode()
    private let hydrogenNode = SCNNode()
    private let oxygenNode = SCNNode()

    private let bondNode = SCNNode()
    private let ringNode = SCNNode()

    private let stabilizationNode = SCNNode()

    // ============================================================
    // MARK: - MOLECULAR STATE
    // ============================================================

    private var carbonAtoms: [SCNNode] = []
    private var hydrogenAtoms: [SCNNode] = []
    private var oxygenAtoms: [SCNNode] = []

    private var molecularBonds: [SCNNode] = []

    // ============================================================
    // MARK: - ANIMATION
    // ============================================================

    private var elapsedTime: TimeInterval = 0
    private var lastTime: TimeInterval = 0

    private let animationSpeed: Double = 1.0

    // ============================================================
    // MARK: - INITIALIZATION
    // ============================================================

    override init() {
        super.init()

        phase = .spaceEnvironment
        phaseProgress = QRTLPhase.spaceEnvironment.rawValue

        configurePhase(.spaceEnvironment)
    }

    // ============================================================
    // MARK: - SCENE SETUP
    // ============================================================

    func setupScene(sceneView: SCNView) {

        self.sceneView = sceneView

        scene = SCNScene()

        scene.background.contents = UIColor(
            red: 0.015,
            green: 0.020,
            blue: 0.040,
            alpha: 1.0
        )

        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = false
        sceneView.isPlaying = true
        sceneView.backgroundColor = .black

        // --------------------------------------------------------
        // WORLD
        // --------------------------------------------------------

        scene.rootNode.addChildNode(worldNode)

        worldNode.addChildNode(latticeNode)
        worldNode.addChildNode(shellNode)
        worldNode.addChildNode(forceNode)
        worldNode.addChildNode(currentNode)

        worldNode.addChildNode(nucleusNode)
        worldNode.addChildNode(electronNode)

        worldNode.addChildNode(moleculeNode)

        moleculeNode.addChildNode(sourceNode)
        moleculeNode.addChildNode(waterNode)
        moleculeNode.addChildNode(carbonNode)
        moleculeNode.addChildNode(hydrogenNode)
        moleculeNode.addChildNode(oxygenNode)
        moleculeNode.addChildNode(bondNode)
        moleculeNode.addChildNode(ringNode)
        moleculeNode.addChildNode(stabilizationNode)

        // --------------------------------------------------------
        // FLOOR
        // --------------------------------------------------------

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

        // --------------------------------------------------------
        // CAMERA
        // --------------------------------------------------------

        let camera = SCNCamera()
        camera.fieldOfView = 48
        camera.zNear = 0.01
        camera.zFar = 200.0

        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 3, 11)
        cameraNode.look(at: SCNVector3(0, 0, 0))

        worldNode.addChildNode(cameraNode)

        // --------------------------------------------------------
        // KEY LIGHT
        // --------------------------------------------------------

        let keyLight = SCNLight()
        keyLight.type = .omni
        keyLight.intensity = 1100

        let keyNode = SCNNode()
        keyNode.light = keyLight
        keyNode.position = SCNVector3(4, 6, 6)

        worldNode.addChildNode(keyNode)

        // --------------------------------------------------------
        // FILL LIGHT
        // --------------------------------------------------------

        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLight.intensity = 600

        let fillNode = SCNNode()
        fillNode.light = fillLight
        fillNode.position = SCNVector3(-5, 2, 4)

        worldNode.addChildNode(fillNode)

        // --------------------------------------------------------
        // BUILD STATIC VISUALIZATION COMPONENTS
        //
        // NOTE:
        // There is intentionally NO buildGlucoseMolecule() here.
        //
        // The molecular structure is constructed progressively by
        // updateMolecularAssembly().
        // --------------------------------------------------------

        buildLattice()
        buildEnergyShell()
        buildNucleus()
        buildElectrons()
        buildForceVisualization()
        buildCurrentVisualization()

        buildSourceMaterial()
        buildWaterMolecules()

        // Start with all molecular components hidden.
        resetMolecularAssembly()

        updateForces()
        updateSceneForCurrentPhase()
    }

    // ============================================================
    // MARK: - 17-STAGE PHASE MODEL
    // ============================================================

    private func configurePhase(_ newPhase: QRTLPhase) {

        phase = newPhase

        switch newPhase {

        // ========================================================
        // 1. SPACE ENVIRONMENT
        // ========================================================

        case .spaceEnvironment:

            current = 0.05
            currentEfficiency = 0.25

            shellEnergy = 0.10
            shellRadius = 1.65
            shellWidth = 0.42
            shellCoupling = 0.20
            shellCoherence = 0.20

            energyLoss = 0.10

            externalForce = 0.05
            kineticForce = 0.05
            bondForce = 0.10

        // ========================================================
        // 2. SOURCE-MATERIAL COLLECTION
        // ========================================================

        case .sourceCollection:

            current = 0.15
            currentEfficiency = 0.35

            shellEnergy = 0.20
            shellCoupling = 0.30
            shellCoherence = 0.30

            externalForce = 0.10
            kineticForce = 0.10
            bondForce = 0.15

        // ========================================================
        // 3. MOLECULAR SOURCE
        // ========================================================

        case .molecularSource:

            current = 0.20
            currentEfficiency = 0.40

            shellEnergy = 0.30
            shellCoupling = 0.35
            shellCoherence = 0.40

            externalForce = 0.12
            kineticForce = 0.12
            bondForce = 0.20

        // ========================================================
        // 4. HYDROGEN-OXYGEN EXCITATION
        // ========================================================

        case .hydrogenOxygenExcitation:

            current = 0.25
            currentEfficiency = 0.45

            shellEnergy = 0.40
            shellCoupling = 0.45
            shellCoherence = 0.50

            externalForce = 0.15
            kineticForce = 0.15
            bondForce = 0.25

        // ========================================================
        // 5. ANTISYMMETRIC EXCITATION
        // ========================================================

        case .antisymmetricExcitation:

            current = 0.28
            currentEfficiency = 0.48

            shellEnergy = 0.45
            shellCoupling = 0.50
            shellCoherence = 0.55

            externalForce = 0.18
            kineticForce = 0.18
            bondForce = 0.30

        // ========================================================
        // 6. ENERGY INJECTION
        // ========================================================

        case .energyInjection:

            current = 0.40
            currentEfficiency = 0.55

            shellEnergy = 0.60
            shellCoupling = 0.65
            shellCoherence = 0.65

            externalForce = 0.25
            kineticForce = 0.20
            bondForce = 0.35

        // ========================================================
        // 7. QRTL LATTICE
        // ========================================================

        case .qrtlLattice:

            current = 0.45
            currentEfficiency = 0.60

            shellEnergy = 0.70
            shellCoupling = 0.75
            shellCoherence = 0.75

            externalForce = 0.25
            kineticForce = 0.22
            bondForce = 0.40

        // ========================================================
        // 8. RESONANCE LOCK
        // ========================================================

        case .resonanceLock:

            current = 0.50
            currentEfficiency = 0.65

            shellEnergy = 0.78
            shellCoupling = 0.82
            shellCoherence = 0.85

            externalForce = 0.30
            kineticForce = 0.20
            bondForce = 0.45

        // ========================================================
        // 9. ATOMIC CAPTURE
        // ========================================================

        case .atomicCapture:

            current = 0.45
            currentEfficiency = 0.65

            shellEnergy = 0.80
            shellCoupling = 0.84
            shellCoherence = 0.86

            externalForce = 0.35
            kineticForce = 0.25
            bondForce = 0.50

        // ========================================================
        // 10. CARBON POSITIONING
        // ========================================================

        case .carbonPositioning:

            current = 0.42
            currentEfficiency = 0.66

            shellEnergy = 0.82
            shellCoupling = 0.85
            shellCoherence = 0.88

            externalForce = 0.30
            kineticForce = 0.25
            bondForce = 0.60

        // ========================================================
        // 11. HYDROGEN POSITIONING
        // ========================================================

        case .hydrogenPositioning:

            current = 0.38
            currentEfficiency = 0.67

            shellEnergy = 0.83
            shellCoupling = 0.86
            shellCoherence = 0.89

            externalForce = 0.25
            kineticForce = 0.25
            bondForce = 0.65

        // ========================================================
        // 12. OXYGEN POSITIONING
        // ========================================================

        case .oxygenPositioning:

            current = 0.35
            currentEfficiency = 0.68

            shellEnergy = 0.84
            shellCoupling = 0.87
            shellCoherence = 0.90

            externalForce = 0.25
            kineticForce = 0.22
            bondForce = 0.70

        // ========================================================
        // 13. BOND ALIGNMENT
        // ========================================================

        case .bondAlignment:

            current = 0.40
            currentEfficiency = 0.70

            shellEnergy = 0.87
            shellCoupling = 0.90
            shellCoherence = 0.92

            externalForce = 0.20
            kineticForce = 0.20
            bondForce = 0.82

        // ========================================================
        // 14. RING CLOSURE
        // ========================================================

        case .ringClosure:

            current = 0.35
            currentEfficiency = 0.70

            shellEnergy = 0.88
            shellCoupling = 0.91
            shellCoherence = 0.93

            externalForce = 0.18
            kineticForce = 0.18
            bondForce = 0.90

        // ========================================================
        // 15. GLUCOSE ASSEMBLY
        // ========================================================

        case .glucoseAssembly:

            current = 0.30
            currentEfficiency = 0.70

            shellEnergy = 0.90
            shellCoupling = 0.92
            shellCoherence = 0.94

            externalForce = 0.15
            kineticForce = 0.15
            bondForce = 0.95

        // ========================================================
        // 16. MOLECULAR STABILIZATION
        // ========================================================

        case .molecularStabilization:

            current = 0.08
            currentEfficiency = 0.72

            shellEnergy = 0.94
            shellCoupling = 0.94
            shellCoherence = 0.97

            energyLoss = 0.04

            externalForce = 0.08
            kineticForce = 0.08
            bondForce = 0.98

        // ========================================================
        // 17. FINAL SUGAR
        // ========================================================

        case .finalSugar:

            current = 0.02
            currentEfficiency = 0.75

            shellEnergy = 1.00
            shellCoupling = 0.98
            shellCoherence = 0.99

            energyLoss = 0.02

            externalForce = 0.03
            kineticForce = 0.03
            bondForce = 1.00
        }

        updateForces()
        syncPublishedValues()
        updateSceneForCurrentPhase()
    }
    
    func setExternalForce(_ value: Double) {

        externalForce = max(
            0.0,
            min(1.0, value)
        )

        updateForces()
        syncPublishedValues()
        updateSceneForCurrentPhase()
    }

    // ============================================================
    // MARK: - SET KINETIC FORCE
    // ============================================================

    func setKineticForce(_ value: Double) {

        kineticForce = max(
            0.0,
            min(1.0, value)
        )

        updateForces()
        syncPublishedValues()
        updateSceneForCurrentPhase()
    }
    func setShellCoherence(_ value: Double) {

        shellCoherence = max(
            0.0,
            min(1.0, value)
        )

        buildEnergyShell()

        updateForces()
        syncPublishedValues()
        updateSceneForCurrentPhase()
    }

    // ============================================================
    // MARK: - SET ENERGY LOSS
    // ============================================================

    func setEnergyLoss(_ value: Double) {

        energyLoss = max(
            0.0,
            min(1.0, value)
        )

        updateForces()
        syncPublishedValues()
        updateSceneForCurrentPhase()
    }
    func setShellCoupling(_ value: Double) {

        shellCoupling = max(
            0.0,
            min(1.0, value)
        )

        buildEnergyShell()

        updateForces()
        syncPublishedValues()
        updateSceneForCurrentPhase()
    }
    func setShellWidth(_ value: Double) {

        shellWidth = max(
            0.01,
            value
        )

        buildEnergyShell()

        updateForces()
        syncPublishedValues()
        updateSceneForCurrentPhase()
    }
    func setShellRadius(_ value: Double) {

        shellRadius = max(
            0.01,
            value
        )

        buildEnergyShell()

        updateForces()
        syncPublishedValues()
        updateSceneForCurrentPhase()
    }
    func setCurrentEfficiency(_ value: Double) {

        currentEfficiency = max(
            0.0,
            min(1.0, value)
        )

        updateForces()
        syncPublishedValues()
        updateSceneForCurrentPhase()
    }
    func setShellEnergy(_ value: Double) {

        shellEnergy = max(
            0.0,
            min(1.0, value)
        )

        updateForces()
        syncPublishedValues()
        updateSceneForCurrentPhase()
    }
    func pauseSequence() {
        isPlaying = false
    }
    func setCurrent(_ value: Double) {

        current = max(0.0, min(1.0, value))

        updateForces()
        syncPublishedValues()
        updateSceneForCurrentPhase()
    }
    func resetToFirstStep() {

        isPlaying = false

        elapsedTime = 0
        lastTime = 0

        goToStep(0)
    }
    func playSequence() {

        // If the sequence is already at the final stage,
        // start again from the beginning.
        if phaseProgress >= QRTLPhase.allCases.count - 1 {
            goToStep(0)
        }

        isPlaying = true
        elapsedTime = 0
        lastTime = 0
    }

   func goToStep(_ step: Int) {

        let clampedStep = max(
            0,
            min(
                step,
                QRTLPhase.allCases.count - 1
            )
        )

        phaseProgress = clampedStep

        guard let newPhase = QRTLPhase(rawValue: clampedStep) else {
            return
        }

        configurePhase(newPhase)
    }
    // ============================================================
    // MARK: - SCENE PHASE UPDATE
    // ============================================================

    private func updateSceneForCurrentPhase() {

        let currentStage = phaseProgress

        // --------------------------------------------------------
        // ENVIRONMENT
        // --------------------------------------------------------

        latticeNode.opacity =
            currentStage >= QRTLPhase.qrtlLattice.rawValue
            ? 1.0
            : 0.20

        shellNode.opacity =
            currentStage >= QRTLPhase.energyInjection.rawValue
            ? 1.0
            : 0.20

        currentNode.opacity =
            currentStage >= QRTLPhase.spaceEnvironment.rawValue
            ? 1.0
            : 0.05

        forceNode.opacity =
            currentStage >= QRTLPhase.resonanceLock.rawValue
            ? 1.0
            : 0.15

        // --------------------------------------------------------
        // NUCLEAR / ATOMIC VISUALIZATION
        // --------------------------------------------------------

        nucleusNode.opacity =
            currentStage >= QRTLPhase.atomicCapture.rawValue
            ? 1.0
            : 0.10

        electronNode.opacity =
            currentStage >= QRTLPhase.atomicCapture.rawValue
            ? 1.0
            : 0.10

        // --------------------------------------------------------
        // PROGRESSIVE MOLECULAR ASSEMBLY
        // --------------------------------------------------------

        updateMolecularAssembly()

        // --------------------------------------------------------
        // STABILIZATION
        // --------------------------------------------------------

        stabilizationNode.opacity =
            currentStage >= QRTLPhase.molecularStabilization.rawValue
            ? 1.0
            : 0.0
    }

    // ============================================================
    // MARK: - PROGRESSIVE MOLECULAR ASSEMBLY
    // ============================================================

    private func updateMolecularAssembly() {

        let stage = phaseProgress

        // ========================================================
        // 1–3. SOURCE MATERIAL
        // ========================================================

        sourceNode.opacity =
            stage >= QRTLPhase.sourceCollection.rawValue
            ? 1.0
            : 0.0

        waterNode.opacity =
            stage >= QRTLPhase.molecularSource.rawValue
            ? 1.0
            : 0.0

        // ========================================================
        // 4–8. EXCITATION / QRTL FIELD
        // ========================================================

        // Nothing molecular is assembled yet.
        // The energy field is preparing the environment.

        // ========================================================
        // 9. ATOMIC CAPTURE
        // ========================================================

        moleculeNode.opacity =
            stage >= QRTLPhase.atomicCapture.rawValue
            ? 1.0
            : 0.0

        // ========================================================
        // 10. CARBON POSITIONING
        // ========================================================

        if stage >= QRTLPhase.carbonPositioning.rawValue {

            let carbonProgress =
                min(
                    1.0,
                    max(
                        0.0,
                        Double(
                            stage -
                            QRTLPhase.carbonPositioning.rawValue
                        ) + 1.0
                    ) / 2.0
                )

            carbonNode.opacity = 1.0

            for (index, atom) in carbonAtoms.enumerated() {

                let threshold =
                    Double(index + 1) /
                    Double(max(carbonAtoms.count, 1))

                atom.opacity =
                    carbonProgress >= threshold
                    ? 1.0
                    : 0.0
            }

        } else {

            carbonNode.opacity = 0.0
        }

        // ========================================================
        // 11. HYDROGEN POSITIONING
        // ========================================================

        if stage >= QRTLPhase.hydrogenPositioning.rawValue {

            hydrogenNode.opacity = 1.0

            let hydrogenProgress =
                min(
                    1.0,
                    max(
                        0.0,
                        Double(
                            stage -
                            QRTLPhase.hydrogenPositioning.rawValue
                        ) + 1.0
                    ) / 2.0
                )

            for (index, atom) in hydrogenAtoms.enumerated() {

                let threshold =
                    Double(index + 1) /
                    Double(max(hydrogenAtoms.count, 1))

                atom.opacity =
                    hydrogenProgress >= threshold
                    ? 1.0
                    : 0.0
            }

        } else {

            hydrogenNode.opacity = 0.0
        }

        // ========================================================
        // 12. OXYGEN POSITIONING
        // ========================================================

        if stage >= QRTLPhase.oxygenPositioning.rawValue {

            oxygenNode.opacity = 1.0

            let oxygenProgress =
                min(
                    1.0,
                    max(
                        0.0,
                        Double(
                            stage -
                            QRTLPhase.oxygenPositioning.rawValue
                        ) + 1.0
                    ) / 2.0
                )

            for (index, atom) in oxygenAtoms.enumerated() {

                let threshold =
                    Double(index + 1) /
                    Double(max(oxygenAtoms.count, 1))

                atom.opacity =
                    oxygenProgress >= threshold
                    ? 1.0
                    : 0.0
            }

        } else {

            oxygenNode.opacity = 0.0
        }

        // ========================================================
        // 13. BOND ALIGNMENT
        // ========================================================

        if stage >= QRTLPhase.bondAlignment.rawValue {

            bondNode.opacity = 1.0

            let bondProgress =
                min(
                    1.0,
                    max(
                        0.0,
                        Double(
                            stage -
                            QRTLPhase.bondAlignment.rawValue
                        ) + 1.0
                    ) / 2.0
                )

            for (index, bond) in molecularBonds.enumerated() {

                let threshold =
                    Double(index + 1) /
                    Double(max(molecularBonds.count, 1))

                bond.opacity =
                    bondProgress >= threshold
                    ? 1.0
                    : 0.0
            }

        } else {

            bondNode.opacity = 0.0
        }

        // ========================================================
        // 14. RING CLOSURE
        // ========================================================

        ringNode.opacity =
            stage >= QRTLPhase.ringClosure.rawValue
            ? 1.0
            : 0.0

        // ========================================================
        // 15. GLUCOSE ASSEMBLY
        // ========================================================

        glucoseCreated =
            stage >= QRTLPhase.glucoseAssembly.rawValue

        // ========================================================
        // 16. MOLECULAR STABILIZATION
        // ========================================================

        stabilizationNode.opacity =
            stage >= QRTLPhase.molecularStabilization.rawValue
            ? 1.0
            : 0.0

        // ========================================================
        // 17. FINAL SUGAR
        // ========================================================

        if stage >= QRTLPhase.finalSugar.rawValue {

            moleculeNode.opacity = 1.0
            carbonNode.opacity = 1.0
            hydrogenNode.opacity = 1.0
            oxygenNode.opacity = 1.0
            bondNode.opacity = 1.0
            ringNode.opacity = 1.0
            stabilizationNode.opacity = 1.0

            carbonAtoms.forEach {
                $0.opacity = 1.0
            }

            hydrogenAtoms.forEach {
                $0.opacity = 1.0
            }

            oxygenAtoms.forEach {
                $0.opacity = 1.0
            }

            molecularBonds.forEach {
                $0.opacity = 1.0
            }
        }
    }

    // ============================================================
    // MARK: - MOLECULAR SOURCE
    // ============================================================

    private func buildSourceMaterial() {

        sourceNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let positions: [SCNVector3] = [
            SCNVector3(-2.8, 1.0, 0.0),
            SCNVector3(-3.2, 0.4, 0.2),
            SCNVector3(-2.7, 0.0, -0.2),
            SCNVector3(2.8, 1.0, 0.0),
            SCNVector3(3.1, 0.3, 0.2),
            SCNVector3(2.7, -0.3, -0.2)
        ]

        for position in positions {

            let sphere = SCNSphere(radius: 0.10)

            let material = SCNMaterial()
            material.diffuse.contents = UIColor.white
            material.emission.contents = UIColor.white

            sphere.materials = [material]

            let node = SCNNode(geometry: sphere)
            node.position = position

            sourceNode.addChildNode(node)
        }
    }

    // ============================================================
    // MARK: - WATER MOLECULES
    // ============================================================

    private func buildWaterMolecules() {

        waterNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let centers: [SCNVector3] = [
            SCNVector3(-1.8, 1.2, 0.0),
            SCNVector3(1.8, 1.0, 0.2),
            SCNVector3(-1.6, -1.0, -0.2),
            SCNVector3(1.6, -1.1, 0.1)
        ]

        for center in centers {

            let oxygen = makeAtom(
                radius: 0.18,
                color: UIColor.red
            )

            oxygen.position = center

            waterNode.addChildNode(oxygen)

            let h1 = makeAtom(
                radius: 0.10,
                color: UIColor.white
            )

            let h2 = makeAtom(
                radius: 0.10,
                color: UIColor.white
            )

            h1.position = SCNVector3(
                center.x - 0.24,
                center.y + 0.16,
                center.z
            )

            h2.position = SCNVector3(
                center.x + 0.24,
                center.y + 0.16,
                center.z
            )

            waterNode.addChildNode(h1)
            waterNode.addChildNode(h2)

            waterNode.addChildNode(
                makeBond(
                    from: h1.position,
                    to: oxygen.position,
                    radius: 0.025,
                    color: UIColor.white
                )
            )

            waterNode.addChildNode(
                makeBond(
                    from: h2.position,
                    to: oxygen.position,
                    radius: 0.025,
                    color: UIColor.white
                )
            )
        }
    }

  
    private func buildProgressiveGlucose() {

        // ============================================================
        // CLEAR PREVIOUS MOLECULAR GEOMETRY
        // ============================================================

        carbonNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        hydrogenNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        oxygenNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        bondNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        ringNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        stabilizationNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        // ============================================================
        // CLEAR ARRAYS
        // ============================================================

        carbonAtoms.removeAll()
        hydrogenAtoms.removeAll()
        oxygenAtoms.removeAll()
        molecularBonds.removeAll()

        carbonTargetPositions.removeAll()
        hydrogenTargetPositions.removeAll()
        oxygenTargetPositions.removeAll()

        glucoseCreated = false

        // ============================================================
        // CARBON TARGET POSITIONS
        // ============================================================

        let carbonPositions: [SCNVector3] = [

            SCNVector3(
                -0.90,
                 0.00,
                 0.00
            ),

            SCNVector3(
                -0.45,
                 0.62,
                 0.00
            ),

            SCNVector3(
                 0.35,
                 0.62,
                 0.00
            ),

            SCNVector3(
                 0.85,
                 0.05,
                 0.00
            ),

            SCNVector3(
                 0.35,
                -0.60,
                 0.00
            ),

            SCNVector3(
                -0.45,
                -0.50,
                 0.00
            )
        ]

        // ============================================================
        // HYDROGEN TARGET POSITIONS
        // ============================================================

        let hydrogenPositions: [SCNVector3] = [

            SCNVector3(
                -1.18,
                 0.05,
                 0.10
            ),

            SCNVector3(
                -0.72,
                 0.88,
                 0.10
            ),

            SCNVector3(
                -0.30,
                 0.88,
                -0.10
            ),

            SCNVector3(
                 0.45,
                 0.90,
                 0.10
            ),

            SCNVector3(
                 1.12,
                 0.12,
                 0.10
            ),

            SCNVector3(
                 0.62,
                -0.86,
                 0.10
            ),

            SCNVector3(
                 0.05,
                -0.86,
                -0.10
            ),

            SCNVector3(
                -0.72,
                -0.78,
                 0.10
            ),

            SCNVector3(
                -1.10,
                -0.20,
                -0.10
            ),

            SCNVector3(
                -0.30,
                 0.30,
                 0.18
            ),

            SCNVector3(
                 0.72,
                 0.38,
                -0.18
            ),

            SCNVector3(
                 0.02,
                -0.20,
                 0.18
            )
        ]

        // ============================================================
        // OXYGEN TARGET POSITIONS
        // ============================================================

        let oxygenPositions: [SCNVector3] = [

            SCNVector3(
                -1.28,
                 0.55,
                 0.00
            ),

            SCNVector3(
                -0.05,
                 1.10,
                 0.00
            ),

            SCNVector3(
                 1.20,
                 0.48,
                 0.00
            ),

            SCNVector3(
                 0.82,
                -0.72,
                 0.00
            ),

            SCNVector3(
                -0.05,
                -1.12,
                 0.00
            ),

            SCNVector3(
                -1.28,
                -0.45,
                 0.00
            )
        ]

        // ============================================================
        // STORE TARGET POSITIONS
        // ============================================================

        carbonTargetPositions = carbonPositions
        hydrogenTargetPositions = hydrogenPositions
        oxygenTargetPositions = oxygenPositions

        // ============================================================
        // INITIAL ASSEMBLY POSITION
        // ============================================================

        let assemblyHeight: Float = 2.0

        // ============================================================
        // CARBON ATOMS
        // ============================================================

        for position in carbonPositions {

            let atom = makeAtom(
                radius: 0.18,
                color: UIColor.black
            )

            atom.position = SCNVector3(
                position.x,
                position.y,
                assemblyHeight
            )

            atom.opacity = 0.0

            carbonNode.addChildNode(atom)
            carbonAtoms.append(atom)
        }

        // ============================================================
        // HYDROGEN ATOMS
        // ============================================================

        for position in hydrogenPositions {

            let atom = makeAtom(
                radius: 0.09,
                color: UIColor.white
            )

            atom.position = SCNVector3(
                position.x,
                position.y,
                assemblyHeight
            )

            atom.opacity = 0.0

            hydrogenNode.addChildNode(atom)
            hydrogenAtoms.append(atom)
        }

        // ============================================================
        // OXYGEN ATOMS
        // ============================================================

        for position in oxygenPositions {

            let atom = makeAtom(
                radius: 0.15,
                color: UIColor.red
            )

            atom.position = SCNVector3(
                position.x,
                position.y,
                assemblyHeight
            )

            atom.opacity = 0.0

            oxygenNode.addChildNode(atom)
            oxygenAtoms.append(atom)
        }

        // ============================================================
        // CARBON-CARBON BONDS
        // ============================================================

        let carbonBondPairs: [(Int, Int)] = [

            (0, 1),
            (1, 2),
            (2, 3),
            (3, 4),
            (4, 5),
            (5, 0)
        ]

        for (first, second) in carbonBondPairs {

            let bond = makeBond(
                from: carbonPositions[first],
                to: carbonPositions[second],
                radius: 0.035,
                color: UIColor.white
            )

            bond.opacity = 0.0

            bondNode.addChildNode(bond)
            molecularBonds.append(bond)
        }

        // ============================================================
        // CARBON-OXYGEN BONDS
        // ============================================================

        let oxygenBondCount = min(
            carbonPositions.count,
            oxygenPositions.count
        )

        if oxygenBondCount > 0 {

            for index in 0..<oxygenBondCount {

                let bond = makeBond(
                    from: carbonPositions[index],
                    to: oxygenPositions[index],
                    radius: 0.030,
                    color: UIColor.white
                )

                bond.opacity = 0.0

                bondNode.addChildNode(bond)
                molecularBonds.append(bond)
            }
        }

        // ============================================================
        // MOLECULAR RING
        // ============================================================

        let ringGeometry = SCNTorus(
            ringRadius: 0.78,
            pipeRadius: 0.025
        )

        let ringMaterial = SCNMaterial()

        ringMaterial.diffuse.contents = UIColor.cyan
        ringMaterial.emission.contents = UIColor.cyan

        ringGeometry.materials = [
            ringMaterial
        ]

        let ring = SCNNode(
            geometry: ringGeometry
        )

        ring.position = SCNVector3(
            -0.02,
             0.02,
            -0.08
        )

        ring.opacity = 0.0

        ring.scale = SCNVector3(
            0.01,
            0.01,
            0.01
        )

        ringNode.addChildNode(ring)

        // ============================================================
        // STABILIZATION HALO
        // ============================================================

        let stabilizationGeometry = SCNTorus(
            ringRadius: 1.05,
            pipeRadius: 0.018
        )

        let stabilizationMaterial = SCNMaterial()

        stabilizationMaterial.diffuse.contents = UIColor.cyan
        stabilizationMaterial.emission.contents = UIColor.cyan
        stabilizationMaterial.transparency = 0.55

        stabilizationGeometry.materials = [
            stabilizationMaterial
        ]

        let stabilizationRing = SCNNode(
            geometry: stabilizationGeometry
        )

        stabilizationRing.position = SCNVector3(
            -0.02,
             0.02,
            -0.10
        )

        stabilizationRing.opacity = 0.0

        stabilizationNode.addChildNode(
            stabilizationRing
        )

        // ============================================================
        // RESET NODE OPACITIES
        // ============================================================

        carbonNode.opacity = 0.0
        hydrogenNode.opacity = 0.0
        oxygenNode.opacity = 0.0
        bondNode.opacity = 0.0
        ringNode.opacity = 0.0
        stabilizationNode.opacity = 0.0
        moleculeNode.opacity = 0.0

        // ============================================================
        // RESET NODE TRANSFORMS
        // ============================================================

        carbonNode.scale = SCNVector3(
            1.0,
            1.0,
            1.0
        )

        hydrogenNode.scale = SCNVector3(
            1.0,
            1.0,
            1.0
        )

        oxygenNode.scale = SCNVector3(
            1.0,
            1.0,
            1.0
        )

        bondNode.scale = SCNVector3(
            1.0,
            1.0,
            1.0
        )

        ringNode.scale = SCNVector3(
            0.01,
            0.01,
            0.01
        )

        stabilizationNode.scale = SCNVector3(
            1.0,
            1.0,
            1.0
        )

        // ============================================================
        // FINAL INITIALIZATION STATE
        // ============================================================

        glucoseCreated = false
    }
    // ============================================================
    // MARK: - RESET MOLECULAR ASSEMBLY
    // ============================================================

    private func resetMolecularAssembly() {

        sourceNode.opacity = 0.0
        waterNode.opacity = 0.0

        carbonNode.opacity = 0.0
        hydrogenNode.opacity = 0.0
        oxygenNode.opacity = 0.0

        bondNode.opacity = 0.0
        ringNode.opacity = 0.0
        stabilizationNode.opacity = 0.0

        moleculeNode.opacity = 0.0

        glucoseCreated = false

        // Build the molecular components but do NOT display them.
        buildProgressiveGlucose()
    }

    // ============================================================
    // MARK: - ATOM CREATION
    // ============================================================

    private func makeAtom(
        radius: CGFloat,
        color: UIColor
    ) -> SCNNode {

        let geometry = SCNSphere(radius: radius)

        let material = SCNMaterial()
        material.diffuse.contents = color
        material.specular.contents = UIColor.white

        if color == UIColor.red {
            material.emission.contents = UIColor.red
        }

        geometry.materials = [material]

        return SCNNode(geometry: geometry)
    }

    // ============================================================
    // MARK: - BOND CREATION
    // ============================================================

    private func makeBond(
        from: SCNVector3,
        to: SCNVector3,
        radius: CGFloat,
        color: UIColor
    ) -> SCNNode {

        let direction = to - from
        let length = CGFloat(
            sqrt(
                direction.x * direction.x +
                direction.y * direction.y +
                direction.z * direction.z
            )
        )

        let cylinder = SCNCylinder(
            radius: radius,
            height: length
        )

        let material = SCNMaterial()
        material.diffuse.contents = color
        material.specular.contents = UIColor.white

        cylinder.materials = [material]

        let node = SCNNode(geometry: cylinder)

        node.position = SCNVector3(
            (from.x + to.x) * 0.5,
            (from.y + to.y) * 0.5,
            (from.z + to.z) * 0.5
        )

        let up = SCNVector3(0, 1, 0)

        let normalized = SCNVector3(
            direction.x / Float(length),
            direction.y / Float(length),
            direction.z / Float(length)
        )

        let dot = up.x * normalized.x +
                  up.y * normalized.y +
                  up.z * normalized.z

        let axis = SCNVector3(
            up.y * normalized.z - up.z * normalized.y,
            up.z * normalized.x - up.x * normalized.z,
            up.x * normalized.y - up.y * normalized.x
        )

        let axisLength = sqrt(
            axis.x * axis.x +
            axis.y * axis.y +
            axis.z * axis.z
        )

        if axisLength > 0.0001 {

            let normalizedAxis = SCNVector3(
                axis.x / axisLength,
                axis.y / axisLength,
                axis.z / axisLength
            )

            node.rotation = SCNVector4(
                normalizedAxis.x,
                normalizedAxis.y,
                normalizedAxis.z,
                acos(max(-1.0, min(1.0, dot)))
            )

        } else if dot < 0 {

            node.rotation = SCNVector4(
                1,
                0,
                0,
                Float.pi
            )
        }

        return node
    }

    // ============================================================
    // MARK: - LATTICE
    // ============================================================

    private func buildLattice() {

        latticeNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let spacing: Float = 0.65

        for x in -2...2 {
            for y in -2...2 {
                for z in -2...2 {

                    let sphere = SCNSphere(radius: 0.045)

                    let material = SCNMaterial()
                    material.diffuse.contents = UIColor.cyan
                    material.emission.contents = UIColor.cyan

                    sphere.materials = [material]

                    let node = SCNNode(geometry: sphere)

                    node.position = SCNVector3(
                        Float(x) * spacing,
                        Float(y) * spacing,
                        Float(z) * spacing
                    )

                    latticeNode.addChildNode(node)
                }
            }
        }
    }

    // ============================================================
    // MARK: - ENERGY SHELL
    // ============================================================

    private func buildEnergyShell() {

        shellNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let sphere = SCNSphere(
            radius: CGFloat(shellRadius)
        )

        let material = SCNMaterial()

        material.diffuse.contents = UIColor.cyan
        material.emission.contents = UIColor.cyan
        material.transparency = 0.08
        material.isDoubleSided = true

        sphere.materials = [material]

        let shell = SCNNode(
            geometry: sphere
        )

        shellNode.addChildNode(shell)

        // ...
    }

    // ============================================================
    // MARK: - NUCLEUS
    // ============================================================

    private func buildNucleus() {

        nucleusNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let positions: [SCNVector3] = [

            SCNVector3(0.18, 0, 0),
            SCNVector3(-0.18, 0, 0),
            SCNVector3(0, 0.18, 0),
            SCNVector3(0, -0.18, 0),
            SCNVector3(0, 0, 0.18),
            SCNVector3(0, 0, -0.18)
        ]

        for index in 0..<positions.count {

            let sphere = SCNSphere(radius: 0.13)

            let material = SCNMaterial()

            material.diffuse.contents =
                index < 3
                ? UIColor.red
                : UIColor(
                    red: 0.65,
                    green: 0.75,
                    blue: 1.0,
                    alpha: 1.0
                )

            sphere.materials = [material]

            let node = SCNNode(geometry: sphere)
            node.position = positions[index]

            nucleusNode.addChildNode(node)
        }
    }

    // ============================================================
    // MARK: - ELECTRONS
    // ============================================================

    private func buildElectrons() {

        electronNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        for index in 0..<8 {

            let angle =
                Float(index) *
                Float.pi * 2.0 / 8.0

            let sphere = SCNSphere(radius: 0.045)

            let material = SCNMaterial()
            material.diffuse.contents = UIColor.yellow
            material.emission.contents = UIColor.yellow

            sphere.materials = [material]

            let node = SCNNode(geometry: sphere)

            node.position = SCNVector3(
                cos(angle) * 0.48,
                sin(angle) * 0.48,
                0
            )

            electronNode.addChildNode(node)
        }
    }

    // ============================================================
    // MARK: - CURRENT
    // ============================================================

    private func buildCurrentVisualization() {

        currentNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        for index in 0..<7 {

            let sphere = SCNSphere(radius: 0.045)

            let material = SCNMaterial()
            material.diffuse.contents = UIColor.yellow
            material.emission.contents = UIColor.yellow

            sphere.materials = [material]

            let node = SCNNode(geometry: sphere)

            node.position = SCNVector3(
                Float(index) * 0.55 - 1.65,
                1.15,
                0
            )

            currentNode.addChildNode(node)
        }
    }

    // ============================================================
    // MARK: - FORCE VISUALIZATION
    // ============================================================

    private func buildForceVisualization() {

        forceNode.childNodes.forEach {
            $0.removeFromParentNode()
        }

        let arrows: [
            (SCNVector3, SCNVector3)
        ] = [

            (
                SCNVector3(0, 0, 0),
                SCNVector3(0, 1.0, 0)
            ),

            (
                SCNVector3(0, 0, 0),
                SCNVector3(1.0, 0.2, 0)
            ),

            (
                SCNVector3(0, 0, 0),
                SCNVector3(-0.8, 0.3, 0)
            ),

            (
                SCNVector3(0, 0, 0),
                SCNVector3(0, -0.8, 0)
            )
        ]

        for (from, to) in arrows {

            forceNode.addChildNode(
                addArrow(
                    from: from,
                    to: to
                )
            )
        }
    }

    // ============================================================
    // MARK: - ARROW
    // ============================================================

    private func addArrow(
        from: SCNVector3,
        to: SCNVector3
    ) -> SCNNode {

        let direction = to - from

        let length = sqrt(
            direction.x * direction.x +
            direction.y * direction.y +
            direction.z * direction.z
        )

        let shaft = SCNCylinder(
            radius: 0.025,
            height: CGFloat(length * 0.75)
        )

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.cyan
        material.emission.contents = UIColor.cyan

        shaft.materials = [material]

        let node = SCNNode(geometry: shaft)

        node.position = SCNVector3(
            (from.x + to.x) * 0.5,
            (from.y + to.y) * 0.5,
            (from.z + to.z) * 0.5
        )

        return node
    }

    // ============================================================
    // MARK: - PHYSICS
    // ============================================================

    private func updateForces() {

        let input = current * currentEfficiency

        effectiveInput = input

        qrtlPressure =
            shellEnergy *
            shellCoupling *
            shellCoherence

        qrtlForce =
            qrtlPressure *
            max(bondForce, 0.001)

        reactionEnergy =
            effectiveInput *
            (1.0 - energyLoss)

        syncPublishedValues()
    }

    // ============================================================
    // MARK: - SYNCHRONIZE
    // ============================================================

    private func syncPublishedValues() {

        effectiveInput =
            current *
            currentEfficiency

        qrtlPressure =
            shellEnergy *
            shellCoupling *
            shellCoherence

        reactionEnergy =
            effectiveInput *
            (1.0 - energyLoss)

        qrtlForce =
            qrtlPressure *
            max(bondForce, 0.001)

        buildEnergyShell()
    }

    // ============================================================
    // MARK: - NEXT STEP
    // ============================================================

    func nextStep() {

        let nextRawValue =
            min(
                phaseProgress + 1,
                QRTLPhase.allCases.count - 1
            )

        phaseProgress = nextRawValue

        guard let nextPhase =
                QRTLPhase(rawValue: nextRawValue)
        else {
            return
        }

        configurePhase(nextPhase)
    }

    // ============================================================
    // MARK: - PREVIOUS STEP
    // ============================================================

    func previousStep() {

        let previousRawValue =
            max(
                phaseProgress - 1,
                0
            )

        phaseProgress = previousRawValue

        guard let previousPhase =
                QRTLPhase(rawValue: previousRawValue)
        else {
            return
        }

        configurePhase(previousPhase)
    }

    // ============================================================
    // MARK: - RESET
    // ============================================================

    func resetScene() {

        phaseProgress =
            QRTLPhase.spaceEnvironment.rawValue

        phase = .spaceEnvironment

        isPlaying = false

        elapsedTime = 0
        lastTime = 0

        modelParameters = QRTLParameters()

        carbonAtoms.removeAll()
        hydrogenAtoms.removeAll()
        oxygenAtoms.removeAll()
        molecularBonds.removeAll()

        glucoseCreated = false

        buildLattice()
        buildEnergyShell()
        buildNucleus()
        buildElectrons()
        buildForceVisualization()
        buildCurrentVisualization()

        buildSourceMaterial()
        buildWaterMolecules()
        resetMolecularAssembly()

        latticeNode.opacity = 1.0
        shellNode.opacity = 1.0
        nucleusNode.opacity = 1.0
        electronNode.opacity = 1.0
        currentNode.opacity = 1.0
        forceNode.opacity = 1.0

        updateForces()
        updateSceneForCurrentPhase()
    }

    // ============================================================
    // MARK: - PLAY / PAUSE
    // ============================================================

    func togglePlayback() {

        isPlaying.toggle()

        if isPlaying {
            lastTime = 0
        }
    }

    // ============================================================
    // MARK: - SCENE RENDERER
    // ============================================================

    func renderer(
        _ renderer: SCNSceneRenderer,
        updateAtTime time: TimeInterval
    ) {

        if lastTime == 0 {
            lastTime = time
        }

        let deltaTime =
            min(
                time - lastTime,
                0.1
            )

        lastTime = time

        elapsedTime += deltaTime

        // --------------------------------------------------------
        // Continuous molecular animation
        // --------------------------------------------------------

        animateMolecularState(
            time: elapsedTime
        )

        // --------------------------------------------------------
        // Continuous energy/current animation
        // --------------------------------------------------------

        animateEnergyState(
            time: elapsedTime
        )

        // --------------------------------------------------------
        // Advance through stages
        // --------------------------------------------------------

        guard isPlaying else {
            return
        }

        let stageDuration =
            2.5 /
            max(animationSpeed, 0.01)

        if elapsedTime >= stageDuration {

            elapsedTime = 0

            if phaseProgress <
                QRTLPhase.allCases.count - 1 {

                nextStep()

            } else {

                isPlaying = false
            }
        }
    }

    // ============================================================
    // MARK: - MOLECULAR ANIMATION
    // ============================================================

    private func animateMolecularState(
        time: TimeInterval
    ) {

        let stage = phaseProgress

        // --------------------------------------------------------
        // Water excitation
        // --------------------------------------------------------

        if stage >= QRTLPhase.hydrogenOxygenExcitation.rawValue {

            let amount =
                Float(
                    1.0 +
                    sin(time * 6.0) * 0.10
                )

            waterNode.scale = SCNVector3(
                amount,
                amount,
                amount
            )
        }

        // --------------------------------------------------------
        // Antisymmetric excitation
        // --------------------------------------------------------

        if stage >=
            QRTLPhase.antisymmetricExcitation.rawValue {

            for (index, node)
                in waterNode.childNodes.enumerated() {

                let direction: Float =
                    index % 2 == 0
                    ? 1.0
                    : -1.0

                node.position.x +=
                    sin(Float(time * 8.0)) *
                    0.012 *
                    direction
            }
        }

        // --------------------------------------------------------
        // Carbon positioning
        // --------------------------------------------------------

        if stage >=
            QRTLPhase.carbonPositioning.rawValue {

            let pulse =
                1.0 +
                Float(
                    sin(time * 3.0) * 0.025
                )

            carbonNode.scale = SCNVector3(
                pulse,
                pulse,
                pulse
            )
        }

        // --------------------------------------------------------
        // Hydrogen positioning
        // --------------------------------------------------------

        if stage >=
            QRTLPhase.hydrogenPositioning.rawValue {

            hydrogenNode.rotation = SCNVector4(
                0,
                1,
                0,
                Float(
                    sin(time * 0.8) * 0.025
                )
            )
        }

        // --------------------------------------------------------
        // Oxygen positioning
        // --------------------------------------------------------

        if stage >=
            QRTLPhase.oxygenPositioning.rawValue {

            oxygenNode.scale = SCNVector3(
                1.0 +
                    Float(sin(time * 4.0) * 0.035),
                1.0 +
                    Float(sin(time * 4.0) * 0.035),
                1.0 +
                    Float(sin(time * 4.0) * 0.035)
            )
        }

        // --------------------------------------------------------
        // Bond alignment
        // --------------------------------------------------------

        if stage >=
            QRTLPhase.bondAlignment.rawValue {

            let pulse =
                1.0 +
                Float(
                    sin(time * 5.0) * 0.04
                )

            bondNode.scale = SCNVector3(
                pulse,
                pulse,
                pulse
            )
        }

        // --------------------------------------------------------
        // Ring closure
        // --------------------------------------------------------

        if stage >=
            QRTLPhase.ringClosure.rawValue {

            ringNode.rotation = SCNVector4(
                0,
                1,
                0,
                Float(time * 0.5)
            )
        }

        // --------------------------------------------------------
        // Final stabilization
        // --------------------------------------------------------

        if stage >=
            QRTLPhase.molecularStabilization.rawValue {

            let pulse =
                1.0 +
                Float(
                    sin(time * 2.0) * 0.015
                )

            moleculeNode.scale = SCNVector3(
                pulse,
                pulse,
                pulse
            )
        }
    }

    // ============================================================
    // MARK: - ENERGY ANIMATION
    // ============================================================

    private func animateEnergyState(
        time: TimeInterval
    ) {

        let pulse =
            1.0 +
            Float(
                sin(time * 2.0) * 0.05
            )

        shellNode.scale = SCNVector3(
            pulse,
            pulse,
            pulse
        )

        currentNode.position.x =
            sin(Float(time * 2.0)) * 0.05
    }
}
