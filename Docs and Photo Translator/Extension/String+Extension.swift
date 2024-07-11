//
//  String+Extension.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 11.07.2024.
//

import Foundation

extension String {
  func removingCharacters(inCharacterSet forbiddenCharacters:CharacterSet) -> String
{
    var filteredString = self
    while true {
      if let forbiddenCharRange = filteredString.rangeOfCharacter(from: forbiddenCharacters)  {
        filteredString.removeSubrange(forbiddenCharRange)
      }
      else {
        break
      }
    }

    return filteredString
  }
}
