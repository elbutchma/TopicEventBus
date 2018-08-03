//
//  TopicEventBus.swift
//  TopicEventBus
//
//  Created by Matan Cohen on 8/2/18.
//  Copyright © 2018 Matan. All rights reserved.
//

import Foundation

public protocol TopicEventBusType {
    func fire(event: TopicEvnet)
    func subscribe<T: TopicEvnet>(classType: T, topic: String) -> Listener
    func subscribe<T: TopicEvnet>(classType: T) -> Listener
    func terminate()
}

public protocol Listener {
    func stop()
}

class EventSubscribtions {
    var value: [Subscription]
    init(value: [Subscription]) {
        self.value = value
    }
}

typealias ClassName = NSString

class TopicEventBus {
    private var subscribers = NSMapTable<ClassName, EventSubscribtions>.init(keyOptions: NSPointerFunctions.Options.strongMemory,
                                                                        valueOptions: NSPointerFunctions.Options.strongMemory )
    
    func fire(event: TopicEvnet) {
        let className = String(describing: event)
        guard let subscribtions = self.subscribers.object(forKey: className as ClassName) else {
            return
        }
        subscribtions.value.forEach { (subscribtion: Subscription) in
            if (subscribtion.key == nil) {
                //Subscribed for all events
                subscribtion.subscriber?(event)
                return
            }
            if (subscribtion.key == event.key) {
                // Subscrbied to fired topic
                subscribtion.subscriber?(event)
                return
            }
        }
    }
    
    func subscribe<T: TopicEvnet>(callback: @escaping (T) -> Void) -> Listener {
        return self.subscribe(topic: nil, callback: callback)
    }
    
    func subscribe<T: TopicEvnet>(topic: String?, callback: @escaping (T) -> Void) -> Listener {
        let className = NSStringFromClass(T.self)
        if (self.subscribers.object(forKey: className as ClassName) == nil) {
            self.subscribers.setObject(EventSubscribtions(value: []), forKey: className as ClassName)
        }
        let subscribtions = self.subscribers.object(forKey: className as ClassName)
        let subscribtion = Subscription.init(key: topic, subscriber: { value in
            callback(value as! T)
        })
        subscribtions?.value.append(subscribtion)
        return subscribtion
    }
    
    func terminate() {
        print("Terminating topic event bus")
        self.subscribers.removeAllObjects()
    }
    
}
