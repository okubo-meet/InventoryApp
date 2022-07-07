//
//  NotificationDate.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/06/29.
//

import Foundation
// 通知が期限の何日前かの列挙型
enum NotificationDate: String, CaseIterable {
    case onTheDay = "期限当日"
    case oneDay = "1日前"
    case twoDays = "2日前"
    case threeDays = "3日前"
    case fourDays = "4日前"
    case fiveDays = "5日前"
    case sixDays = "6日前"
    case sevenDays = "１週間前"
    case noNotification = "通知無し"
    // 通知の日付を計算して返す関数
    func toDate(deadLine: Date) -> Date? {
        switch self {
        case .onTheDay:
            return deadLine
        case .oneDay:
            return Calendar.current.date(byAdding: .day, value: -1, to: deadLine)
        case .twoDays:
            return Calendar.current.date(byAdding: .day, value: -2, to: deadLine)
        case .threeDays:
            return Calendar.current.date(byAdding: .day, value: -3, to: deadLine)
        case .fourDays:
            return Calendar.current.date(byAdding: .day, value: -4, to: deadLine)
        case .fiveDays:
            return Calendar.current.date(byAdding: .day, value: -5, to: deadLine)
        case .sixDays:
            return Calendar.current.date(byAdding: .day, value: -6, to: deadLine)
        case .sevenDays:
            return Calendar.current.date(byAdding: .day, value: -7, to: deadLine)
        case .noNotification:
            return nil
        }
    }
}
