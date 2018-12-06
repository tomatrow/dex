const cheerio = require('cheerio')
const fs = require('fs')
const path = require('path')

const siteRootFolder = 'cache/enduringword.com/'
const commentaryFolder = path.join(siteRootFolder, 'bible-commentary')

// Extract the markup we want from the commentary pages
const extractMarkup = (id, html) => {
    // selects the main content
    const $ = cheerio.load(html)

    // gets the main content
    let content = $('body #main div[itemprop=text]')

    // Make sure we got something
    if (content.length === 0)
        throw new Error(`Content not found for '${id}'`)

    // We found *too many* items.
    if (content.length === 2) {
        switch (id) {
            case 'john-15': // Their page content erroneously is duplicated.
            case 'matthew-2': // A blank element that matches our selector.
                content = content.last()
                break;
            default:
                debugger
        }
    }

    // remove the copyright info
    let copyright = content.find('p:last-of-type')
    switch (id) {
        case 'malachi-1': // last element is a 's'
        case 'psalm-63': // last elements is a 'w'
            copyright = copyright.prev() // Weird
            break;
        default:
    }
    if (copyright.length === 0)
        throw new Error('Unexpected structure')
    else if (!copyright.text().includes('distribution beyond personal use'))
        throw new Error(`Unexpected last paragraph`)

    // get the markup
    let markup = content.html()
    if (markup.length < 100)
        throw new Error(`The commentary is too short, probably a failure.`)

    return markup
}

const isSequential = integerArray => {
    // check for a valid argument
    if (!Array.isArray(integerArray)) {
        console.error(`Not an array: ${integerArray}`)
        return false
    }

    // trivial case
    if (integerArray.length === 0)
        return true

    // check the array is ordered
    let currentIndex = integerArray[0]
    return integerArray
        .map(index => index === currentIndex++)
        .reduce((prev, current) => prev && current)
}

/* Extract info from folder names. For example:
 * '1-chronicles-4-5-6-7-8' --> {
 *     "volume": 1,
 *     "book": "chronicles",
 *     "chapters": [4, 5, 6, 7, 8]
 *  }
 */
const extractInfo = name => {

    /// MARK: split the array into three based on the book name

    // Split by `-`
    const parts = name.split('-')

    // get  the center portion of non numeric values
    const nonNumericParts = parts
        .map((part, index) => {
            return {
                part,
                index
            }
        })
        .filter(item => isNaN(item.part))

    // check the sequence of non-numeric-parts are contiguous
    if (!isSequential(nonNumericParts.map(item => item.index))) {
        console.error(`Non contiguous sequence of words ${name}`)
        process.exit(1)
    }

    // split the array into three portions
    const preName = parts
        .slice(0, nonNumericParts[0].index)
    const midName = nonNumericParts.map(item => item.part)
    const postName = parts
        .slice(nonNumericParts[nonNumericParts.length - 1].index + 1)


    /// MARK: book name

    // Assumption: No volume or exactly one number
    if (!(0 <= preName.length && preName.length <= 1)) {
        console.error(`Unexpected numbers found before book name: ${name}`)
        process.exit(2)
    }

    // Assumption: The volume is between 1 and 3
    let volume = null;
    if (preName.length !== 0) {
        volume = parseInt(preName[0])
        if (![1, 2, 3].includes(volume)) {
            console.error(`volume must be between 1 and 3: ${name}`)
            process.exit(3)
        }
    }

    /// MARK: book name

    // remove redundent `chapter` word from the midName when present
    if (midName[midName.length - 1] === 'chapter')
        midName.pop()
    const book = midName.join('-') // only matters for song of soloman

    // MARK: Chapters

    // convert the chapter strings into actual numbers
    const chapters = postName.map(chapter => parseInt(chapter, 10))

    // Some of the filenames have a `2` at the end.
    // I suspect its just a versioning thing.
    switch (name) {
        case '1-kings-3-2':
        case 'judges-5-2':
        case 'psalm-143-2':
        case 'romans-13-2':
            // Assumption. pops off 2.
            if (chapters.pop() !== 2) {
                console.error(`Expected a 2 at the end of ${name}`)
                process.exit(4)
            }
            break
        default:
    }

    // check the chapters are sequential
    if (!isSequential(chapters)) {
        console.error(`Found non-sequential chapters: ${name}`)
        process.exit(5)
    }

    /// MARK: return the data

    return {
        volume,
        book,
        chapters
    }
}

const readChapter = folderName => {
    const file = path.join(commentaryFolder, folderName, 'index.html')
    return fs.readFileSync(file, {
        encoding: 'utf8'
    })
}


/* Travel the cache file to extract the main content. */
function extract(outDir) {

    // Ensure folder does not exist.
    if (fs.existsSync(outDir)) {
        console.error(`The folder: ${outDir} already exists.`)
        return 1
    }

    // Create folder
    fs.mkdirSync(outDir)

    /* loop though the site and extract the main content. The end result is a
     * bunch of files in the form of: `{volume}-{book}-{chapters}.html` where
     * *book* is a is a bible book and `chapters` is an ordered sequence of
     * integers sepearated by commas. e.g. `15,16,17,18`. This is needed because
     * some of Guziks notes cover multiple chapters. */
    let count = 0
    const chapterFolders = fs.readdirSync(commentaryFolder, {
            withFileTypes: true
        })
        .filter(file => file.isDirectory())

    // extract from the markup
    const extractions = chapterFolders.map(f => f.name).map(name => {
        console.log(`Converting #${++count}: ${name}`)

        // extract the volume, book, and chapters from the file name
        const info = extractInfo(name)
        const id = (info.volume ? `${info.volume}-` : '') +
            `${info.book}-${info.chapters.join(',')}`

        // extract the markup from the file contents
        const chapterText = readChapter(name)
        const markup = extractMarkup(id, chapterText)

        return {
            info,
            markup
        }
    })

    // save extractions
    extractions.forEach(object => {
        // construct the filename
        const fileNameArray = []
        if (object.info.volume)
            fileNameArray.push(object.info.volume)
        fileNameArray.push(object.info.book, object.info.chapters)
        const fileName = fileNameArray.join('-') + '.json'

        // write the file
        const fullPath = path.join(outDir, fileName)
        const json = JSON.stringify(object)
        fs.writeFileSync(fullPath, json)
    })
}

// extract the data if needed
const extractionDir = 'extraction'
if (!fs.existsSync(extractionDir)) {
    console.log(`starting extraction at ${extractionDir}`)
    extract(extractionDir)
} else
    console.log(`extraction already exists at ${extractionDir}`)