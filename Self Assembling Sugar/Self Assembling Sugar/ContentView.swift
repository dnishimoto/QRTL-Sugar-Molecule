//
//  ContentView.swift
//  Space Sugar
//
//  QRTL 3D Energy-Shell Molecular Assembly
//

import SwiftUI
import SceneKit
import UIKit
import Combine

// ============================================================
// MARK: - CONTENT VIEW
// ============================================================

struct ContentView: View {
    @State
    var showingAbout : Bool = false
    // ========================================================
    // MARK: - QRTL CONTROLLER
    // ========================================================

    @StateObject private var controller = QRTLSceneController()

    // ========================================================
    // MARK: - BODY
    // ========================================================

    var body: some View {
        NavigationStack{
            ZStack {
                
                Color.black
                    .ignoresSafeArea()
                
                VStack(
                    spacing: 0
                ) {
                    
                    header
                    
                    Divider()
                        .background(
                            Color.white.opacity(0.15)
                        )
                    
                    GeometryReader { geometry in
                        
                        ScrollView {
                            
                            VStack(
                                spacing: 16
                            ) {
                                
                                sceneSection(
                                    height: max(
                                        380,
                                        geometry.size.width * 0.58
                                    )
                                )
                                
                                sequencePanel
                                
                                reactionConditionsCard
                                
                                modelControls
                                
                                howToReadCard
                                
                                Spacer(
                                    minLength: 30
                                )
                            }
                            .padding(
                                .horizontal,
                                14
                            )
                            .padding(
                                .top,
                                14
                            )
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAbout = true
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            
        }
        
        .preferredColorScheme(.dark)

        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
 

    }


    // ========================================================
    // MARK: - HEADER
    // ========================================================

    private var header: some View {

        VStack(
            alignment: .leading,
            spacing: 4
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {

                    Text("SPACE SUGAR")
                        .font(
                            .system(
                                size: 22,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.white)

                    Text(
                        "QRTL 3D ENERGY-SHELL MOLECULAR ASSEMBLY"
                    )
                    .font(
                        .system(
                            size: 10,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.cyan)
                }

                Spacer()

                VStack(
                    alignment: .trailing,
                    spacing: 2
                ) {

                    Text(
                        "STEP \(controller.phaseProgress + 1)"
                    )
                    .font(
                        .system(
                            size: 14,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.yellow)

                    Text(
                        "OF \(QRTLPhase.allCases.count)"
                    )
                    .font(
                        .system(
                            size: 9,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundColor(
                        .white.opacity(0.55)
                    )
                }
            }
        }
        .padding(
            .horizontal,
            16
        )
        .padding(
            .vertical,
            12
        )
    }


    // ========================================================
    // MARK: - SCENE
    // ========================================================

    private func sceneSection(
        height: CGFloat
    ) -> some View {

        ZStack {

            // =================================================
            // IMPORTANT:
            //
            // DO NOT USE:
            //
            // SceneView(scene: makeScene())
            //
            // That creates a completely separate SCNScene and
            // prevents QRTLSceneController.setupScene() from
            // being used.
            //
            // QRTLSceneView owns the SCNView and calls:
            //
            // controller.setupScene(sceneView:)
            //
            // =================================================

            QRTLSceneView(
                controller: controller
            )
            .frame(
                height: height
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )

            // =================================================
            // TOP PHASE LABEL
            // =================================================

            VStack {

                HStack {

                    Text(
                        controller.phase.title
                    )
                    .font(
                        .system(
                            size: 12,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.white)
                    .padding(
                        .horizontal,
                        10
                    )
                    .padding(
                        .vertical,
                        7
                    )
                    .background(
                        Capsule()
                            .fill(
                                Color.black.opacity(0.65)
                            )
                    )

                    Spacer()
                }

                Spacer()

                // =================================================
                // BOTTOM ANALOGY
                // =================================================

                HStack {

                    Text(
                        controller.phase.analogy
                    )
                    .font(
                        .system(
                            size: 11,
                            weight: .medium,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.yellow)
                    .padding(
                        .horizontal,
                        12
                    )
                    .padding(
                        .vertical,
                        9
                    )
                    .background(
                        RoundedRectangle(
                            cornerRadius: 10
                        )
                        .fill(
                            Color.black.opacity(0.72)
                        )
                    )

                    Spacer()
                }
            }
            .padding(14)
        }
    }


    // ========================================================
    // MARK: - SEQUENCE PANEL
    // ========================================================

    private var sequencePanel: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            sectionTitle(
                "QRTL ASSEMBLY SEQUENCE"
            )

            Text(
                "Control the molecular assembly one stage at a time."
            )
            .font(.caption)
            .foregroundColor(
                .white.opacity(0.7)
            )

            // ------------------------------------------------
            // STEP INDICATOR
            // ------------------------------------------------

            HStack {

                Text(
                    "STEP \(controller.phaseProgress + 1)"
                )
                .font(
                    .system(
                        size: 16,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundColor(.cyan)

                Spacer()

                Text(
                    controller.phase.title
                )
                .font(
                    .system(
                        size: 11,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .multilineTextAlignment(.trailing)
                .foregroundColor(
                    .white.opacity(0.75)
                )
            }

            // ------------------------------------------------
            // STEP SLIDER
            // ------------------------------------------------

            Slider(
                value: Binding(
                    get: {
                        Double(
                            controller.phaseProgress
                        )
                    },
                    set: { value in
                        controller.goToStep(
                            Int(value.rounded())
                        )
                    }
                ),
                in:
                    0...Double(
                        QRTLPhase.allCases.count - 1
                    ),
                step: 1
            )
            .tint(.cyan)

            // ------------------------------------------------
            // PREVIOUS / NEXT
            // ------------------------------------------------

            HStack(
                spacing: 10
            ) {

                Button {

                    controller.previousStep()

                } label: {

                    Label(
                        "Previous",
                        systemImage: "backward.fill"
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                }
                .buttonStyle(
                    QRTLControlButtonStyle()
                )
                .disabled(
                    controller.phaseProgress == 0
                )

                Button {

                    controller.nextStep()

                } label: {

                    Label(
                        "Next",
                        systemImage: "forward.fill"
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                }
                .buttonStyle(
                    QRTLControlButtonStyle()
                )
                .disabled(
                    controller.phaseProgress ==
                    QRTLPhase.allCases.count - 1
                )
            }

            // ------------------------------------------------
            // PLAY / PAUSE / RESET
            // ------------------------------------------------

            HStack(
                spacing: 10
            ) {

                Button {

                    controller.playSequence()

                } label: {

                    Label(
                        "Play Sequence",
                        systemImage: "play.fill"
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                }
                .buttonStyle(
                    QRTLPrimaryButtonStyle()
                )

                Button {

                    controller.pauseSequence()

                } label: {

                    Label(
                        "Pause",
                        systemImage: "pause.fill"
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                }
                .buttonStyle(
                    QRTLControlButtonStyle()
                )

                Button {

                    controller.resetToFirstStep()

                } label: {

                    Image(
                        systemName:
                            "arrow.counterclockwise"
                    )
                }
                .buttonStyle(
                    QRTLControlButtonStyle()
                )
            }

            // ------------------------------------------------
            // PHASE EXPLANATION
            // ------------------------------------------------

            VStack(
                alignment: .leading,
                spacing: 7
            ) {

                Text(
                    "WHAT IS HAPPENING?"
                )
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.cyan)

                Text(
                    controller.phase.explanation
                )
                .font(.caption)
                .foregroundColor(.white)

                Text(
                    "Analogy: " +
                    controller.phase.analogy
                )
                .font(.caption)
                .italic()
                .foregroundColor(.yellow)
            }
            .padding(12)
            .background(
                RoundedRectangle(
                    cornerRadius: 12
                )
                .fill(
                    Color.white.opacity(0.06)
                )
            )
        }
    }


    // ========================================================
    // MARK: - REACTION CONDITIONS
    // ========================================================

    private var reactionConditionsCard: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Image(
                    systemName:
                        "waveform.path.ecg"
                )
                .foregroundColor(.cyan)

                Text(
                    "QRTL REACTION CONDITIONS"
                )
                .font(.headline)
                .foregroundColor(.white)

                Spacer()

                Text("LIVE")
                    .font(
                        .system(
                            size: 9,
                            weight: .bold
                        )
                    )
                    .foregroundColor(.yellow)
            }

            Text(
                "The values below change with the selected step and with the simulation controls."
            )
            .font(.caption)
            .foregroundColor(
                .white.opacity(0.65)
            )

            conditionSection(
                title: "ENERGY INPUT",
                subtitle:
                    "How much modeled electrical input enters the system.",
                analogy:
                    "Like the fuel flowing into an engine.",
                rows: [
                    (
                        "Current",
                        controller.current,
                        "input level"
                    ),
                    (
                        "Current Efficiency",
                        controller.currentEfficiency,
                        "usable fraction"
                    ),
                    (
                        "Effective Input",
                        controller.effectiveInput,
                        "current × efficiency"
                    )
                ]
            )

            conditionSection(
                title: "QRTL PRESSURE",
                subtitle:
                    "A normalized energy-density-like index for the shell.",
                analogy:
                    "Like how tightly energy is packed inside a chamber.",
                rows: [
                    (
                        "Pressure Index",
                        controller.qrtlPressure,
                        "normalized"
                    )
                ]
            )

            conditionSection(
                title: "ENERGY SHELL",
                subtitle:
                    "The modeled region where QRTL energy is concentrated.",
                analogy:
                    "Like an invisible bubble surrounding the nucleus.",
                rows: [
                    (
                        "Shell Energy",
                        controller.shellEnergy,
                        "energy index"
                    ),
                    (
                        "Shell Size",
                        controller.shellRadius,
                        "radius"
                    ),
                    (
                        "Shell Thickness",
                        controller.shellWidth,
                        "width"
                    ),
                    (
                        "Shell Coupling",
                        controller.shellCoupling,
                        "interaction"
                    ),
                    (
                        "Shell Coherence",
                        controller.shellCoherence,
                        "organization"
                    )
                ]
            )

            conditionSection(
                title: "FORCES",
                subtitle:
                    "The modeled influences acting on the assembly.",
                analogy:
                    "Like several hands pushing, pulling, and holding pieces together.",
                rows: [
                    (
                        "QRTL Force",
                        controller.qrtlForce,
                        "model force"
                    ),
                    (
                        "External Force",
                        controller.externalForce,
                        "outside influence"
                    ),
                    (
                        "Motion",
                        controller.kineticForce,
                        "movement"
                    ),
                    (
                        "Bond Strength",
                        controller.bondForce,
                        "connection"
                    )
                ]
            )

            conditionSection(
                title: "ENERGY BALANCE",
                subtitle:
                    "Shows the modeled energy state of the reaction.",
                analogy:
                    "Like filling a tank while some energy leaks out.",
                rows: [
                    (
                        "Reaction Energy",
                        controller.reactionEnergy,
                        "combined index"
                    ),
                    (
                        "Energy Loss",
                        controller.energyLoss,
                        "loss fraction"
                    )
                ]
            )

            Text(
                "MODEL UNITS: These displayed quantities are normalized simulation indices unless a physical unit is explicitly identified. QRTL Pressure is not Pascals and Reaction Energy is not joules."
            )
            .font(
                .system(
                    size: 9,
                    weight: .medium,
                    design: .rounded
                )
            )
            .foregroundColor(
                .white.opacity(0.45)
            )
        }
    }


    // ========================================================
    // MARK: - CONDITION SECTION
    // ========================================================

    private func conditionSection(
        title: String,
        subtitle: String,
        analogy: String,
        rows: [
            (
                String,
                Double,
                String
            )
        ]
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 7
        ) {

            Text(title)
                .font(
                    .system(
                        size: 12,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundColor(.cyan)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(
                    .white.opacity(0.65)
                )

            Text(
                "Analogy: " +
                analogy
            )
            .font(.caption2)
            .italic()
            .foregroundColor(
                .yellow.opacity(0.9)
            )

            ForEach(
                rows,
                id: \.0
            ) { row in

                HStack {

                    Text(row.0)
                        .font(.caption)
                        .foregroundColor(.white)

                    Spacer()

                    Text(
                        String(
                            format: "%.3f",
                            row.1
                        )
                    )
                    .font(
                        .system(
                            size: 12,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(.white)

                    Text(row.2)
                        .font(.caption2)
                        .foregroundColor(
                            .white.opacity(0.45)
                        )
                        .frame(
                            width: 90,
                            alignment: .leading
                        )
                }
                .padding(
                    .vertical,
                    3
                )
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(
                cornerRadius: 10
            )
            .fill(
                Color.white.opacity(0.045)
            )
        )
    }


    // ========================================================
    // MARK: - MODEL CONTROLS
    // ========================================================

    private var modelControls: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            sectionTitle(
                "MODEL CONTROLS"
            )

            QRTLSlider(
                title: "Current",
                value: Binding(
                    get: {
                        controller.current
                    },
                    set: {
                        controller.setCurrent($0)
                    }
                ),
                range: 0...1,
                description:
                    "Electrical input entering the modeled system.",
                analogy:
                    "Think of current as the fuel flowing into the reaction chamber."
            )

            QRTLSlider(
                title: "Current Efficiency",
                value: Binding(
                    get: {
                        controller.currentEfficiency
                    },
                    set: {
                        controller.setCurrentEfficiency($0)
                    }
                ),
                range: 0...1,
                description:
                    "The fraction of incoming current treated as useful modeled QRTL input.",
                analogy:
                    "Like an engine's efficiency: not all fuel becomes useful motion."
            )

            QRTLSlider(
                title: "Energy Shell",
                value: Binding(
                    get: {
                        controller.shellEnergy
                    },
                    set: {
                        controller.setShellEnergy($0)
                    }
                ),
                range: 0...1.5,
                description:
                    "Strength of the modeled energy shell.",
                analogy:
                    "Like the amount of energy stored inside an invisible bubble."
            )

            QRTLSlider(
                title: "Shell Size",
                value: Binding(
                    get: {
                        controller.shellRadius
                    },
                    set: {
                        controller.setShellRadius($0)
                    }
                ),
                range: 0.5...3.0,
                description:
                    "Radial location of the modeled energy shell.",
                analogy:
                    "Like changing the size of a protective energy bubble."
            )

            QRTLSlider(
                title: "Shell Thickness",
                value: Binding(
                    get: {
                        controller.shellWidth
                    },
                    set: {
                        controller.setShellWidth($0)
                    }
                ),
                range: 0.05...1.0,
                description:
                    "Width of the active shell region.",
                analogy:
                    "Like changing a thin wall into a thicker energy band."
            )

            QRTLSlider(
                title: "Shell Coupling",
                value: Binding(
                    get: {
                        controller.shellCoupling
                    },
                    set: {
                        controller.setShellCoupling($0)
                    }
                ),
                range: 0...1,
                description:
                    "Strength of the modeled interaction between the shell and matter.",
                analogy:
                    "Like turning up the grip between the energy field and the material."
            )

            QRTLSlider(
                title: "Shell Coherence",
                value: Binding(
                    get: {
                        controller.shellCoherence
                    },
                    set: {
                        controller.setShellCoherence($0)
                    }
                ),
                range: 0...1,
                description:
                    "Degree of organization of the modeled shell.",
                analogy:
                    "Like an orchestra: coherence means the players are staying in rhythm."
            )

            QRTLSlider(
                title: "Energy Loss",
                value: Binding(
                    get: {
                        controller.energyLoss
                    },
                    set: {
                        controller.setEnergyLoss($0)
                    }
                ),
                range: 0...0.5,
                description:
                    "Fraction of modeled shell energy treated as lost.",
                analogy:
                    "Like heat escaping from an insulated tank."
            )

            QRTLSlider(
                title: "External Force",
                value: Binding(
                    get: {
                        controller.externalForce
                    },
                    set: {
                        controller.setExternalForce($0)
                    }
                ),
                range: 0...1,
                description:
                    "Modeled influence coming from outside the QRTL system.",
                analogy:
                    "Like someone pushing the structure from outside."
            )

            QRTLSlider(
                title: "Motion / Kinetic",
                value: Binding(
                    get: {
                        controller.kineticForce
                    },
                    set: {
                        controller.setKineticForce($0)
                    }
                ),
                range: 0...1,
                description:
                    "Modeled contribution associated with movement.",
                analogy:
                    "Like shaking a box: motion helps determine how the pieces move."
            )

            Toggle(
                isOn: Binding(
                    get: {
                        controller.replaceStrongForce
                    },
                    set: {
                        controller.replaceStrongForce = $0
                    }
                )
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {

                    Text(
                        "Use QRTL interaction in the model"
                    )
                    .foregroundColor(.white)

                    Text(
                        "This control determines whether the QRTL interaction is treated as the modeled replacement interaction."
                    )
                    .font(.caption2)
                    .foregroundColor(
                        .white.opacity(0.55)
                    )
                }
            }
            .tint(.cyan)
        }
    }


    // ========================================================
    // MARK: - HOW TO READ
    // ========================================================

    private var howToReadCard: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            sectionTitle(
                "HOW TO READ THE MODEL"
            )

            explanationRow(
                title: "1. Current",
                text:
                    "Current represents the incoming electrical input."
            )

            explanationRow(
                title: "2. Efficiency",
                text:
                    "Efficiency determines how much of that input becomes useful modeled QRTL energy."
            )

            explanationRow(
                title: "3. Pressure",
                text:
                    "The pressure index describes how concentrated the modeled shell energy is within its shell volume."
            )

            explanationRow(
                title: "4. Energy Shell",
                text:
                    "The shell represents the modeled region where QRTL energy is concentrated."
            )

            explanationRow(
                title: "5. Coherence",
                text:
                    "Coherence describes how organized the modeled energy pattern is."
            )

            explanationRow(
                title: "6. Coupling",
                text:
                    "Coupling describes how strongly the modeled shell interacts with matter."
            )

            explanationRow(
                title: "7. Forces",
                text:
                    "QRTL, external, motion, and bond values describe the modeled influences affecting assembly."
            )

            explanationRow(
                title: "8. Reaction Energy",
                text:
                    "Reaction Energy is a normalized combined index derived from shell energy, coupling, and coherence."
            )

            Text(
                "The sequence is a computational model and visualization. The displayed normalized indices should not be interpreted as experimentally validated physical measurements without an independently calibrated physical model."
            )
            .font(
                .system(
                    size: 10,
                    weight: .medium,
                    design: .rounded
                )
            )
            .foregroundColor(
                .yellow.opacity(0.8)
            )
        }
    }


    // ========================================================
    // MARK: - EXPLANATION ROW
    // ========================================================

    private func explanationRow(
        title: String,
        text: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 3
        ) {

            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.cyan)

            Text(text)
                .font(.caption)
                .foregroundColor(
                    .white.opacity(0.75)
                )
        }
    }


    // ========================================================
    // MARK: - SECTION TITLE
    // ========================================================

    private func sectionTitle(
        _ title: String
    ) -> some View {

        Text(title)
            .font(
                .system(
                    size: 14,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundColor(.white)
    }
}


// ============================================================
// MARK: - PREVIEW
// ============================================================

#Preview {
    ContentView()
}
