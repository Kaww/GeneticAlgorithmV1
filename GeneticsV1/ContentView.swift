import SwiftUI

struct BestIndividual: Equatable {
    let genes: String
    let fitness: Double
    let generation: Int
}

struct ContentView: View {
    @State private var showNewCommand = false
    @State private var isRunning = false

    @State private var currentConfig: Config? = nil

    @State private var bestIndividuals: [BestIndividual] = []

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                ForEach(bestIndividuals.prefix(100), id: \.generation) { individual in
                    HStack {
                        Text("\(individual.genes) - \(individual.fitness)")
                        Spacer()
                        Text("(\(individual.generation))")
                    }
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showNewCommand) {
            NewCommandView(lastConfig: currentConfig) { config in
                startAlgoritm(config: config)
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Algo V1")
                Spacer()

                Button {
                    if let currentConfig = currentConfig {
                        startAlgoritm(config: currentConfig)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .tint(.green)
                .font(.system(size: 30, weight: .semibold, design: .monospaced))
                .disabled(isRunning || currentConfig == nil)

                Button {
                    isRunning = false
                } label: {
                    Image(systemName: "multiply")
                }
                .tint(.red)
                .font(.system(size: 35, weight: .semibold, design: .monospaced))
                .disabled(isRunning == false)

                Button {
                    showNewCommand = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(isRunning)
            }
            .font(.system(size: 38, weight: .semibold, design: .monospaced))

            divider

            if let config = currentConfig {
                HStack {
                    Text("\"\(config.target)\"")
                        .fixedSize(horizontal: true, vertical: false)
                    verticalDivider
                    Text("Pop. size: \(config.populationSize)")
                        .fixedSize(horizontal: true, vertical: false)
                    verticalDivider
                    Text("Mut. rate: \(config.mutationRate, specifier: "%.2f")")
                        .fixedSize(horizontal: true, vertical: false)
                }
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .frame(height: 10)

                divider
            }
        }
    }

    private var divider: some View {
        Color.black.opacity(0.1)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }

    private var verticalDivider: some View {
        HStack {
            Color.black.opacity(0.1)
                .frame(width: 1)
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    private func startAlgoritm(config: Config) {
        Task {
            currentConfig = config
            DNA.allExistingGenes = config.genes

            let initialPopulation = Population(
                target: config.target,
                size: config.populationSize,
                mutationRate: config.mutationRate
            )
            let algorithm = Evolution(population: initialPopulation)
            var currentPopulation = initialPopulation
            var currentGeneration = 1
            bestIndividuals = []

            let best = currentPopulation.bestIndividual()
            bestIndividuals.insert(BestIndividual(genes: best.0.genes, fitness: best.1, generation: currentGeneration), at: 0)

            isRunning = true

            while currentPopulation.bestIndividual().1 < 1, isRunning == true {
                let fitnessMap = currentPopulation.fitnessMap()

                // Generate next generation
                var newIndividualsSet: Set<DNA> = []

                while newIndividualsSet.count < currentPopulation.individuals.count {
                    let parentA = algorithm.selection(in: fitnessMap)
                    let parentB = algorithm.selection(in: fitnessMap.filter({ elem in elem.key != parentA }))

                    let child = algorithm.reproduction(of: parentA, with: parentB)

                    let mutatedChild = algorithm.mutation(of: child)

                    newIndividualsSet.insert(mutatedChild)
                }

                let newPopulation = Population(From: currentPopulation, with: Array(newIndividualsSet))
                currentPopulation = newPopulation
                currentGeneration += 1

                let best = newPopulation.bestIndividual()
                bestIndividuals.insert(BestIndividual(genes: best.0.genes, fitness: best.1, generation: currentGeneration), at: 0)
            }

            isRunning = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
