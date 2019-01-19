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
    static let topicTable = { () -> TopicTable in
        // topic-votes.txt is raw unmoderated/unfiltered data, devoid of any votes from openbible (I think)
        // topic-scores.txt has been moderated

        // load the raw text
        let path = Bundle.main.path(forResource: "topic-scores", ofType: "txt")!
        let text = try! String(contentsOfFile: path)

        // separate columns by tabs and rows by lines
        let rows = text
            .components(separatedBy: CharacterSet.newlines)
            .map { $0.split(separator: "\t").map { col in String(col) } }
        assert(53508 == rows.count)

        // convert into a live table
        var table = TopicTable()
        // first line is header, last line is blank
        rows[1 ..< rows.endIndex - 1].forEach { row in
            assert(row.count == 3)

            // extract data from row
            let topic = row[0]
            let result = TopicResult(section: row[1], score: row[2])!

            // save in table
            if table[topic] != nil {
                table[topic]!.append(result)
            } else {
                table[topic] = [result]
            }
        }

        // sort the results
        table.keys.forEach { key in
            table[key]!.sort { $0.qualityScore > $1.qualityScore }
        }

        return table
    }()

    static let commentaries = { () -> [Commentary] in
        let decoder = JSONDecoder()
        var commentaries = [Commentary]()
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
        for path in paths {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let commentary = try decoder.decode(Commentary.self, from: data)
                commentaries.append(commentary)
            } catch {
                print(error.localizedDescription)
            }
        }
        commentaries.sort(by: <)
        return commentaries
    }()

    static let bible = { () -> [Book] in
        // load the bible
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
        let esvPath = paths.filter { $0.contains("ESV") }.first!

        // convert from data to raw nested dicts
        typealias RawBible = [String: [String: [String: String]]]
        /* {
         "bookName": {
         "chapterNumber": {
         "verseNumber": "verse",...
         },...
         },...
         }*/

        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: esvPath), options: .mappedIfSafe),
            let rawBible = try? decoder.decode(RawBible.self, from: data)
        else { assert(false) }

        var bible = [Book]()
        for bookObject in rawBible {
            let bookName = bookObject.key
            var chapters = [Chapter]()

            // read all the chapters
            for chapterObject in bookObject.value {
                let chapterNumber = chapterObject.key
                var verses = [Verse]()

                // read all the verses
                for verseObject in chapterObject.value {
                    let verseNumber = verseObject.key
                    let verseText = verseObject.value
                    let verse = Verse(number: Int(verseNumber)!, text: verseText)
                    verses.append(verse)
                }

                // sort the verses
                verses.sort { $0.number < $1.number }

                let chapter = Chapter(number: Int(chapterNumber)!, verses: verses)
                chapters.append(chapter)
            }

            // sort the chapters
            chapters.sort { $0.number < $1.number }

            let book = Book(name: bookName, chapters: chapters)
            bible.append(book)
        }

        // sort the books
        bible.sort { $0.name < $1.name }

        return bible
    }()
}
