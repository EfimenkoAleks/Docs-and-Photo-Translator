//
//  Date+Extension.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.06.2024.
//

import Foundation

extension Date {
    
    static func sm_convertDateToString(date: Date, formatter: String) -> String {
        
        let dateFormatterRezult = DateFormatter()
        dateFormatterRezult.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterRezult.dateFormat = formatter
        
        return dateFormatterRezult.string(from: date)
    }
    
    // yyyy-MM-dd HH:mm:ss Z
    static func sm_convertStringToDate(isoDate: String) -> Date {
          let dateFormatter = DateFormatter()
          dateFormatter.locale = Locale(identifier: "en_US_POSIX")
          dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        if let date = dateFormatter.date(from: isoDate) {
            return date
        } else { return Date() }
    }
}

extension Date {

    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {

        let currentCalendar = Calendar.current

        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }

        return end - start
    }
}
