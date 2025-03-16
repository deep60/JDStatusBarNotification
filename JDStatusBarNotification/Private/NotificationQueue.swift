//
//  NotificationQueue.swift
//  JDStatusBarNotification
//
//  Created by P Deepanshu on 16/03/25.
//  Copyright © 2025 Markus. All rights reserved.
//

import Foundation
import JDStatusBarNotification

/// A notification item that represent a pending notification
struct QueuedNotification {
    let id: UUID
    let title: String?
    let subtitle: String?
    let style: StatusBarNotificationStyle
    let duration: Double?
    let completion: NotificationPresenter.Completion?
}

// Manage a queue of notification
class NotificationQueue {
    private var queue: [QueuedNotification] = []
    private var isPresenting = false
    private weak var presenter: NotificationPresenter?
    
    init(presenter: NotificationPresenter) {
        self.presenter = presenter
    }
    
    // Adds a notification in the queue
    func enqueue(_ notification: QueuedNotification) {
        queue.append(notification)
        processNextNotification()
    }
    
    private func processNextNotification() {
        guard !isPresenting, let notification = queue.first, let presenter = presenter else { return }
        isPresenting = true
        
        // Register a custom style for this notification
        let styleName = "queue-notification-\(notification.id)"
        presenter.addStyle(named: styleName, usingStyle: .defaultStyle) { _ in
            return notification.style
        }
        
        // Present the notification
        let view = presenter.present(notification.title ?? "",
                                   subtitle: notification.subtitle,
                                   styleName: styleName,
                                   duration: notification.duration) { [weak self] (presenter: NotificationPresenter) in
            notification.completion?(presenter)
            self?.notificationDismissed()
        }
    }
    
    // Called when a notification is dismissed
    func notificationDismissed() {
        guard !queue.isEmpty else { return }
        queue.removeFirst()
        isPresenting = false
        if !queue.isEmpty {
            processNextNotification()
        }
    }
    
    func clear() {
        queue.removeAll()
    }
}
