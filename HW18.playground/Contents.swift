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

var array = [Chip]()


final class Generate: Thread {

}

final class Worker: Thread {

}
