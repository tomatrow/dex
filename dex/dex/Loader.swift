//
//  Loader.swift
//  dex
//
//  Created by AJ Caldwell on 1/18/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import Foundation

typealias TopicTable = [String: [TopicResult]]

struct Loader {
    func loadTopics() -> TopicTable { return TopicTable() }
    func loadCommentaries() -> [Commentary] { return [Commentary]() }
    func loadBible() -> [Book] { return [Book]() }
}
