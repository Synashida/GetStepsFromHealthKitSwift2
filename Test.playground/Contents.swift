//: Playground - noun: a place where people can play

import Foundation

extension NSDate {
    
    func yesterday() -> NSDate {
        return NSDate(timeIntervalSince1970: trunc(.day).timeIntervalSince1970 - 86400)
    }
    
    func tomorrow() -> NSDate {
        return NSDate(timeIntervalSince1970: trunc(.day).timeIntervalSince1970 + 86400)
    }
    
    func addDays(days: Int) -> NSDate {
        return NSDate(timeIntervalSince1970: trunc(.day).timeIntervalSince1970 + (86400 * Double(days)))
    }
    
    enum TruncType {
        case day
        case month
        case year
    }
    
    func trunc(type: TruncType) -> NSDate {
        var result = self
        switch type {
        case TruncType.day:
            result = dayTrunc(self)
        case TruncType.month:
            result = monthTrunc(dayTrunc(self))
        default: break
        }
        return result
    }
    
    private func dayTrunc(target: NSDate) -> NSDate {
        let dateFormatter = NSDateFormatter()
        var result:NSDate = target
        let now = target.timeIntervalSince1970
        dateFormatter.dateFormat = "HH"
        result = NSDate(timeIntervalSince1970: now - (now % 86400))
        let hour = Double(dateFormatter.stringFromDate(result))
        result = NSDate(timeIntervalSince1970: result.timeIntervalSince1970 - (hour! * 3600))
        return result
    }

    private func monthTrunc(target: NSDate) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd"
        var result = target
        
        let day = Double(dateFormatter.stringFromDate(result))
        result = NSDate(timeIntervalSince1970: result.timeIntervalSince1970 - ((day! - 1) * 86400))
        return result
    }
}

var today = NSDate()

today.trunc(.day)

let now = NSDate() // 現在日時の取得
let dateFormatter = NSDateFormatter()
dateFormatter.timeStyle = .MediumStyle
dateFormatter.dateStyle = .MediumStyle
dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
dateFormatter.stringFromDate(today)
dateFormatter.stringFromDate(today.trunc(.day))
dateFormatter.stringFromDate(today.trunc(.month))

dateFormatter.stringFromDate(today.addDays(-1))
dateFormatter.stringFromDate(today.addDays(1))


