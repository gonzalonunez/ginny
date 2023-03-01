//
//  String+Parameter.swift
//  
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation

extension String {

  func transformingParametersIfNeeded() throws -> String {
    let range = NSRange(startIndex..<endIndex, in: self)
    let regex = try NSRegularExpression(pattern: #"(?<=\[).*(?=\])"#)
    let firstMatchRange = regex.rangeOfFirstMatch(in: self, range: range)
    guard firstMatchRange.location != NSNotFound, let matchRange = Range(firstMatchRange, in: self) else {
      return self
    }
    return ":" + String(self[matchRange])
  }
}
