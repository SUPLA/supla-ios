/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */
    
import SwiftUI

struct SVGPathParser {
    private let input: String
    private var index: String.Index
    private var currentPoint: CGPoint = .zero
    private var startPoint: CGPoint = .zero

    init(_ input: String) {
        self.input = input
        self.index = input.startIndex
    }

    mutating func parse() -> Path {
        var path = Path()
        var command: Character?

        while skipSeparators(), !isAtEnd {
            if let char = peek(), char.isLetter {
                command = read()
            }

            guard let command else { break }

            switch command {
            case "M":
                let point = readPoint()
                currentPoint = point
                startPoint = point
                path.move(to: point)

            case "L":
                let point = readPoint()
                currentPoint = point
                path.addLine(to: point)

            case "H":
                let x = readNumber()
                currentPoint = CGPoint(x: x, y: currentPoint.y)
                path.addLine(to: currentPoint)

            case "V":
                let y = readNumber()
                currentPoint = CGPoint(x: currentPoint.x, y: y)
                path.addLine(to: currentPoint)

            case "C":
                let c1 = readPoint()
                let c2 = readPoint()
                let end = readPoint()
                path.addCurve(to: end, control1: c1, control2: c2)
                currentPoint = end

            case "Z", "z":
                path.closeSubpath()
                currentPoint = startPoint

            default:
                break
            }
        }

        return path
    }

    private var isAtEnd: Bool {
        index >= input.endIndex
    }

    private func peek() -> Character? {
        isAtEnd ? nil : input[index]
    }

    @discardableResult
    private mutating func read() -> Character {
        let char = input[index]
        index = input.index(after: index)
        return char
    }

    @discardableResult
    private mutating func skipSeparators() -> Bool {
        while !isAtEnd {
            let char = input[index]
            if char == " " || char == "\n" || char == "\t" || char == "," {
                index = input.index(after: index)
            } else {
                break
            }
        }
        return true
    }

    private mutating func readPoint() -> CGPoint {
        let x = readNumber()
        let y = readNumber()
        return CGPoint(x: x, y: y)
    }

    private mutating func readNumber() -> CGFloat {
        skipSeparators()

        let start = index

        if !isAtEnd, input[index] == "-" || input[index] == "+" {
            index = input.index(after: index)
        }

        while !isAtEnd, input[index].isNumber {
            index = input.index(after: index)
        }

        if !isAtEnd, input[index] == "." {
            index = input.index(after: index)

            while !isAtEnd, input[index].isNumber {
                index = input.index(after: index)
            }
        }

        let value = String(input[start..<index])
        skipSeparators()

        return CGFloat(Double(value) ?? 0)
    }
}
