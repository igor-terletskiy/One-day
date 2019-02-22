//
//  GoogleNewsResponse.swift
//  InstNews
//
//  Created by Igor on 1/17/19.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation

struct TopHeadlines: Codable {
    
    let status: String?
    let totalResults: Int?
    var articles: [Article]?
}

struct Article: Codable, Equatable {
 
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.source?.id == rhs.source?.id && lhs.source?.name == rhs.source?.name && lhs.author == rhs.author && lhs.title == rhs.title && lhs.description == rhs.description && lhs.url == rhs.url && lhs.urlToImage == rhs.urlToImage && lhs.publishedAt == rhs.publishedAt && lhs.content == rhs.content
    }

    let source: Source?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    
}

struct Source: Codable, Equatable {
    let id: String?
    let name: String?
}


