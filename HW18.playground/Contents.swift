import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Chip.swift
public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }

    public let chipType: ChipType

    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        return Chip(chipType: chipType)
    }

    public func sodering() {
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}

// MARK: - Realization

final class SaveChip<T> {

    private var array = [T]()
    private var nsCondition = NSCondition()

    var isEmpty: Bool {
        nsCondition.lock()
        let empty = array.isEmpty
        nsCondition.unlock()
        return empty
    }

    func push(_ chip: T) {
        nsCondition.lock()
        array.append(chip)
        nsCondition.unlock()
    }

    func pop() -> T? {
        nsCondition.lock()
        let pop = array.removeLast()
        nsCondition.unlock()
        return pop
    }
}

class Generate: Thread {
    private var timer = Timer()
    static var nsAvailable = false
    static var isGenerateNow = true
    static var nsCondition = NSCondition()
    private var saveChip: SaveChip<Chip>
    private var runCount = 0

    init(saveChip: SaveChip<Chip>){
        self.saveChip = saveChip
    }


    override func main() {
        print("Generate thread started work")
        makeChip()
        print("Generate thread finish work")
    }

    private func makeChip() {

        timer = Timer(timeInterval: 2, repeats: true) { [self] _ in
            Generate.nsCondition.lock()
            let chip = Chip.make()
            saveChip.push(chip)
            print("Push: \(chip)")

            Generate.nsAvailable = true
            Generate.nsCondition.signal()
            Generate.nsCondition.unlock()

            runCount += 1

            if runCount >= 10 {
                Generate.isGenerateNow = false
                timer.invalidate()
            }
        }

        RunLoop.current.add(timer, forMode: .common)
        RunLoop.current.run()

    }
}

final class Worker: Thread {
    static var nsAvailable = false
    static var nsCondition = NSCondition()
    private var saveChip: SaveChip<Chip>

    init(saveChip: SaveChip<Chip>){
        self.saveChip = saveChip
    }

    override func main() {
        print("Worker thread started work")
        while Generate.isGenerateNow {
            while !Generate.nsAvailable {
                Generate.nsCondition.wait()
            }
            while !saveChip.isEmpty {
                if let chip = saveChip.pop() {
                    chip.sodering()
                    print("Remove \(chip)")
                }
            }
            Generate.nsAvailable = false
        }
        print("Worker thread finish work")
    }
}

// MARK: - Instances and Startup

let chip = SaveChip<Chip>()
let generateThread = Generate(saveChip: chip)
let workerThread = Worker(saveChip: chip)

generateThread.start()
workerThread.start()

