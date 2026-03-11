//
//  ScheduleDTOs.swift
//  Rimuru
//
//  Created by MACBOOK AIR on 04/03/26.
//

import Foundation

struct ScheduleDTO: Codable, Identifiable {
    let id: UUID
    let createdAt: Date
    let content: String
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id, content, date
        case createdAt = "created_at"
    }
}

struct FinanceDTO: Codable, Identifiable {
    let id: UUID
    let item: String
    let amount: Double
    let type: String // income, expense, dsb
    let categoryId: UUID?
    let isSettled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, item, amount, type
        case categoryId = "category_id"
        case isSettled = "is_settled"
    }
}
