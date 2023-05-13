//
//  LocalNotificationsService.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import UserNotifications
import UIKit

class LocalNotificationsService {
    
    func registeForLatestUpdatesIfPossible() {
        registerUpdatesCategory()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { success, error in
            if let error = error {
                print(error)
            }
            if success {
                DispatchQueue.main.async {
                    self.sendNotification()
                }
                
            }
        }
       
    }
    func sendNotification() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Посмотрите последние обновления"
        content.body = "Проверьте обновления"
        content.sound = .default
        content.badge = (UIApplication.shared.applicationIconBadgeNumber) + 1 as NSNumber
        content.categoryIdentifier = "update"
        var dateComponents = DateComponents()
        dateComponents.hour = 19
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
   private func registerUpdatesCategory() {
       let center = UNUserNotificationCenter.current()
       let action = UNNotificationAction(identifier: "updating", title: "Обновить")
       let category = UNNotificationCategory(identifier: "update", actions:[action], intentIdentifiers: [])
       let categories: Set<UNNotificationCategory> = [category]
       center.setNotificationCategories(categories)
    }
    
}



