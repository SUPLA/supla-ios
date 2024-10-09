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

import Foundation

public class Node<Value> {
    
    public var value: Value
    public var next: Node?
    
    init(value: Value, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

extension Node: CustomStringConvertible {

  public var description: String {
    guard let next = next else {
      return "\(value)"
    }
    return "\(value) -> " + String(describing: next) + " "
  }
}

public class LinkedList<Value> {
    
    var head: Node<Value>?
    var tail: Node<Value>?
    
    init() {}
    
    var isEmpty: Bool {
        head == nil
    }
    
    func append(_ value: Value) {
        guard !isEmpty else {
            push(value)
            return
        }
        
        tail!.next = Node(value: value)
        tail = tail!.next
    }
    
    func push(_ value: Value) {
        head = Node(value: value, next: head)
        if (tail == nil) {
            tail = head
        }
    }
    
    func avg(extractor: (Value) -> Double?) -> Double {
        if (isEmpty) { return 0 }
        
        var sum: Double = 0
        var count: Double = 0
        
        var item = head
        while (item != nil) {
            count += 1
            sum += extractor(item!.value)!
            item = item!.next
        }
        
        return sum / count
    }
    
    func sum(extractor: (Value) -> Double?) -> Double {
        if (isEmpty) { return 0 }
        
        var sum: Double = 0
        
        var item = head
        while (item != nil) {
            sum += extractor(item!.value)!
            item = item!.next
        }
        
        return sum
    }
    
    func min(extractor: (Value) -> Double?) -> Double? {
        if (isEmpty) { return nil }
        
        var item = head
        var min = extractor(item!.value)!
        while (item != nil) {
            let value = extractor(item!.value)!
            if (value < min) {
                min = value
            }
            item = item!.next
        }
        
        return min
    }
    
    func max(extractor: (Value) -> Double?) -> Double? {
        if (isEmpty) { return nil }
        
        var item = head
        var max = extractor(item!.value)!
        while (item != nil) {
            let value = extractor(item!.value)!
            if (value > max) {
                max = value
            }
            item = item!.next
        }
        
        return max
    }
    
    func map<T>(_ transform: (Value) -> T) -> LinkedList<T> {
        var result = LinkedList<T>()
        
        var item = head
        while (item != nil) {
            result.append(transform(item!.value))
            item = item!.next
        }
        
        return result
    }
}

extension LinkedList: CustomStringConvertible {

  public var description: String {
    guard let head = head else {
      return "Empty list"
    }
    return String(describing: head)
  }
}
