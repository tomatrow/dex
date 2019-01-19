//
//  TopicResult.swift
//  dex
//
//  Created by AJ Caldwell on 1/18/19.
//  Copyright © 2019 optional(default). All rights reserved.
//

import Foundation

struct TopicResult {
    var bibleSection = ""
    var qualityScore: Int

    init?(section: String, score: String) {
        bibleSection = section
        guard let qualityScore = Int(score) else { return nil }
        self.qualityScore = qualityScore
    }
}
