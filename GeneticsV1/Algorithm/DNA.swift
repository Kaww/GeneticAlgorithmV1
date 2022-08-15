import Foundation

struct DNA: Hashable {
    static var allExistingGenes = "ABCDEFGHIJKLMNOPQRSTUVWXYZ "

    let genes: String
    var genesArray: [String.Element] {
        Array(genes)
    }

    init(size: Int) {
        var newIndividualGenes: [String] = []
        for _ in 0..<size {
            newIndividualGenes.append("\(Self.randomGene())")
        }
        genes = newIndividualGenes.reduce("", +)
    }

    init(genes: String) {
        self.genes = genes
    }

    static func randomGene() -> String.Element {
        Array(allExistingGenes)[Int.random(in: 0..<(Self.allExistingGenes.count))]
    }
}
