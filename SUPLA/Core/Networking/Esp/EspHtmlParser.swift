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
import SwiftSoup
import Collections

fileprivate let STATE_PATTERN = "\\<h1\\>(.*)\\<\\/h1\\>\\<span\\>LAST\\ STATE:\\ (.*)\\<br\\>Firmware:\\ (.*)\\<br\\>GUID:\\ (.*)\\<br\\>MAC:\\ ([A-Za-z0-9\\:]*)"


class EspHtmlParser {
    
    func findInputs(document: SwiftSoup.Document) -> OrderedDictionary<String, String> {
        var map = OrderedDictionary<String, String>()
        
        guard let form = try? document.select("form").first(),
              let fields = try? form.select("input, select, textarea")
        else {
            SALog.warning("No fields found inside formular, returning an empty map")
            return map
        }
        
        for field in fields {
            guard let name = try? field.attr("name").trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { continue }
            let value = (try? field.attr("value")) ?? ""
            if (field.attribute("type", is: "checkbox")) {
                if (field.hasAttr("checked")) {
                    map[name] = value
                }
            } else if (field.nodeName() == "select") {
                if let option = try? field.select("option[selected]").first(),
                   let value = try? option.val() {
                    map[name] = value
                }
            } else {
                map[name] = value
            }
        }

        return map
    }
    
    func prepareResult(document: String?, fieldMap: OrderedDictionary<String, String>) -> EspConfigResult {
        let result = EspConfigResult()
        result.needsCloudConfig = needsCloudConfig(fieldMap: fieldMap)
        
        guard let html = document else { return result }
        do {
            let regex = try NSRegularExpression(pattern: STATE_PATTERN)
            let matches = regex.matches(in: html, range: NSMakeRange(0, html.count))
            
            if (matches.count < 1) {
                return result
            }
            
            if let match = matches.first,
               match.numberOfRanges == 6 {
                result.name = html.substring(range: match.range(at: 1))
                result.state = html.substring(range: match.range(at: 2))
                result.version = html.substring(range: match.range(at: 3))
                result.guid = html.substring(range: match.range(at: 4))
                result.mac = html.substring(range: match.range(at: 5))
            }
        } catch {
            SALog.error("Could not parse state pattern \(error)")
        }
        
        return result
    }
    
    private func needsCloudConfig(fieldMap: OrderedDictionary<String, String>) -> Bool {
        fieldMap.contains { $0 == "no_visible_channels" && $1 == "1" }
    }
}

private extension SwiftSoup.Element {
    func attribute(_ name: String, is value: String) -> Bool {
        if let attr = try? attr(name), attr.caseInsensitiveCompare(value) == .orderedSame {
            return true
        } else {
            return false
        }
    }
}
