import Foundation

struct Evolution {
    let population: Population

    init(population: Population) {
        self.population = population
    }

    /// Picks a individual uning it's fitness as probability
    func selection(in fitnessMap: [DNA: Double]) -> DNA {
        fitnessMap
            .map { dna, fitness -> [DNA] in Array(repeating: dna, count: Int(fitness * 100) + 1) }
            .joined()
            .shuffled()
            .first!
    }

    func reproduction(of parentA: DNA, with parentB: DNA) -> DNA {
        DNA(genes: firstHalf(of: parentA) + secondHalf(of: parentB))
    }

    private func firstHalf(of individual: DNA) -> String {
        "\(individual.genes.prefix(Int((Double(individual.genes.count) / Double(2)).rounded(.down))))"
    }

    private func secondHalf(of individual: DNA) -> String {
        "\(individual.genes.suffix(Int((Double(individual.genes.count) / Double(2)).rounded(.up))))"
    }

    func mutation(of individual: DNA) -> DNA {
        var mutated: [String.Element] = []

        for gene in individual.genesArray {
            if Double.random(in: 0..<1) < population.mutationRate {
                mutated.append(DNA.randomGene())
            } else {
                mutated.append(gene)
            }
        }

        return DNA(
            genes: mutated
                .map { "\($0)" }
                .reduce("", +)
        )
    }
}
