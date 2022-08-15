import SwiftUI

struct Config {
    let target: String
    let mutationRate: Double
    let populationSize: Int
    let genes: String
}

struct NewCommandView: View {

    @Environment(\.presentationMode) private var presentationMode

    @State private var targetText: String = "KAWRANTIN"
    @State private var mutationRate: Double = 0.1
    @State private var populationSize: Int = 20

    @State private var usesDefaultGenes = true
    private let defaultGenes: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ "
    @State private var genes: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ "

    let lastConfig: Config?
    let onStart: (Config) -> Void

    init(lastConfig: Config?, onStart: @escaping (Config) -> Void) {
        self.lastConfig = lastConfig
        self.onStart = onStart
    }

    var body: some View {
        NavigationView {
            List {
                Section("Target") {
                    TextField("Ex: Hello", text: $targetText)
                }

                Section("Mutation rate") {
                    TextField("Ex: 0.1", value: $mutationRate, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section("Population size") {
                    TextField("Ex: 20", value: $populationSize, format: .number)
                        .keyboardType(.numberPad)
                }

                Section("Existing genes") {
                    Toggle("Default genes", isOn: $usesDefaultGenes)
                        .tint(.blue)

                    if usesDefaultGenes {
                        TextField("", text: .constant("\"\(defaultGenes)\""))
                            .disabled(true)
                            .foregroundColor(.gray)
                    } else {
                        TextField("", text: $genes)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New command")
                        .font(.system(size: 20, weight: .medium))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                        let config = Config(
                            target: targetText,
                            mutationRate: mutationRate,
                            populationSize: populationSize,
                            genes: usesDefaultGenes ? defaultGenes : genes
                        )
                        onStart(config)
                    } label: {
                        Text("Start")
                            .font(.system(size: 20, weight: .medium))
                    }
                    .disabled(targetText.isEmpty || mutationRate < 0 || populationSize < 2 || (usesDefaultGenes == false && genes.isEmpty))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.insetGrouped)
            .task {
                await doSomeStuff()
            }
        }
    }

    private func doSomeStuff() async {
        guard let lastConfig = lastConfig else { return }
        self.targetText = lastConfig.target
        self.mutationRate = lastConfig.mutationRate
        self.populationSize = lastConfig.populationSize
        if DNA.allExistingGenes != defaultGenes {
            usesDefaultGenes = false
            genes = DNA.allExistingGenes
        }
    }
}

struct NewCommandView_Previews: PreviewProvider {
    static var previews: some View {
        NewCommandView(lastConfig: nil, onStart: { _ in })
    }
}
