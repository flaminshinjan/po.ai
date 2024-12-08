//
//  Message.swift
//  po.ai
//
//  Created by Shinjan Patra on 08/12/24.
//

import Foundation

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}
