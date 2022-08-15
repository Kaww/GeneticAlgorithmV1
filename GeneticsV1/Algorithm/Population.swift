import Foundation

struct Population {
    let target: String
    let individuals: [DNA]
    let mutationRate: Double

    init(
        target: String,
        size: Int,
        mutationRate: Double
    ) {
        self.target = target
        var individualsSet: Set<DNA> = []
        while individualsSet.count < size {
            individualsSet.insert(DNA(size: target.count))
        }
        self.individuals = Array(individualsSet)
        self.mutationRate = mutationRate
    }

    init(
        From oldGeneration: Population,
        with newIndiduals: [DNA]
    ) {
        self.target = oldGeneration.target
        self.individuals = newIndiduals
        self.mutationRate = oldGeneration.mutationRate
    }

    func fitnessMap() -> [DNA: Double] {
        var map: [DNA: Double] = [:]

        for individual in individuals {
            map[individual] = calculateFitness(of: individual, basedOn: target)
        }

        return map
    }

    func bestIndividual() -> (DNA, Double) {
        fitnessMap()
            .map { dna, fitness in (dna, fitness) }
            .sorted { $0.1 > $1.1 }
            .first ?? (DNA(size: 0), 0)
    }

    private func calculateFitness(of individual: DNA, basedOn target: String) -> Double {
        var score = 0
        let individualArray = individual.genesArray
        let targetArray = Array(target)
        let minSize = individualArray.count <= targetArray.count ? individualArray.count : targetArray.count

        for index in 0..<minSize {
            score += individualArray[index] == targetArray[index] ? 1 : 0
        }

        return Double(score) / Double(individualArray.count)
    }
}
