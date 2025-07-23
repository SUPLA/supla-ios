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

fileprivate let STATE_PATTERN = "\\<h1\\>(.*)\\<\\/h1\\>\\<span\\>LAST\\ STATE:\\ (.*)\\<br\\>Firmware:\\ (.*)\\<br\\>GUID:\\ (.*)\\<br\\>MAC:\\ ([A-Za-z0-9\\:]*)"

@objc
class EspHtmlParser: NSObject {
    
    @objc func findInputs(document: TFHpple) -> [String: String] {
        var map: [String: String] = [:]
        
        if let inputs = document.search(withXPathQuery: "//input") {
            for next in inputs {
                guard let element = next as? TFHppleElement,
                      let attributes = element.attributes,
                      let name = (attributes["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                else { continue }
                
                let value = attributes["value"] as? String
                
                if let type = attributes["type"] as? String,
                   type.caseInsensitiveCompare("checkbox") == .orderedSame {
                    if let checked = attributes["checked"] as? String,
                       checked.caseInsensitiveCompare("checked") == .orderedSame {
                        map[name] = value ?? ""
                    }
                } else if (!name.isEmpty) {
                    map[name] = value ?? ""
                }
                
            }
        }
        
        if let selects = document.search(withXPathQuery: "//select") {
            for next in selects {
                guard let element = next as? TFHppleElement,
                      let name = (element.attributes["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
                      let options = element.search(withXPathQuery: "//option[@selected=\"selected\"]"),
                      let option = options.first as? TFHppleElement,
                      let value = option.attributes["value"] as? String
                else { continue }
                
                map[name] = value
            }
        }
        
        return map
    }
    
    func findInputs(document: SwiftSoup.Document) -> [String: String] {
        var map: [String: String] = [:]

        if let inputs = try? document.select("input") {
            for input in inputs {
                guard let name = try? input.attr("name").trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { continue }
                let value = try? input.attr("value")

                if (input.attribute("type", is: "checkbox")) {
                    if (input.hasAttr("checked")) {
                        map[name] = value ?? ""
                    }
                } else {
                    map[name] = value ?? ""
                }
            }
        }

        if let selects = try? document.select("select") {
            for select in selects {
                guard let name = try? select.attr("name").trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { continue }
                if let option = try? select.select("option[selected]").first(),
                   let value = try? option.val()
                {
                    map[name] = value
                }
            }
        }

        return map
    }
    
    @objc func prepareResult(document: String?) -> EspConfigResult {
        let result = EspConfigResult()
        
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
    
    @objc func needsCloudConfig(fieldMap: [String: String]) -> Bool {
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
