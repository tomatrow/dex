const path = require('path');
const fs = require('fs');

const oldTestament = [
    'genesis', 'exodus', 'leviticus', 'numbers', 'deuteronomy',
    'joshua', 'judges', 'ruth', 'samuel', 'kings', 'chronicles',
    'ezra', 'nehemiah', 'esther',
     'job', 'psalm', 'proverbs',
     'ecclesiastes', 'song-of-solomon',
     'isaiah', 'jeremiah',
     'lamentations', 'ezekiel', 'daniel', 'hosea', 'joel', 'amos',
     'obadiah', 'jonah', 'micah', 'nahum', 'habakkuk', 'zephaniah',
     'haggai', 'zechariah', 'malachi'
]
const newTestament = [
    'matthew', 'mark', 'luke', 'john', 'acts', 'romans', 'corinthians',
    'galatians', 'ephesians', 'philippians', 'colossians',
    'thessalonians', 'timothy', 'titus', 'philemon', 'hebrews',
    'james', 'peter', 'john', 'jude', 'revelation'
]
const books = [...oldTestament, ...newTestament]


// generates indexes. Only the cannononical one at the moment.
// planned: hieracrchical, categorical
function createIndexes(extractionDir, indexDir) {

    // read data
    const readExtractionData = () => {
        const jsonFiles = fs.readdirSync(extractionDir)
            .filter(fileName => path.extname(fileName) === '.json')

        const result = jsonFiles.map(jsonFileName => {
            const fullPath = path.join(extractionDir, jsonFileName)
            const text = fs.readFileSync(fullPath)
            const object = JSON.parse(text)
            console.log(JSON.stringify(object.info))
            return object.info
        })

        return result
    }

    // converts extracted data into a cannononical index
    const createOrderedInfoList = infoList => {
        // define an order on the info objects

        const compareInfo = (left, right) => {
            if (left.book !== right.book) {
                const leftIndex = books.indexOf(left.book)
                const rightIndex = books.indexOf(right.book)
                if (leftIndex === -1 || rightIndex === -1) {
                    console.error(`Book not found comparing: ${left} and ${right}`)
                    process.exit(1)
                }

                return leftIndex - rightIndex
            } else if (left.volume !== right.volume) {
                // they are the same book => they have a volume number
                const isNumerical = number => !isNaN(number)
                if (!isNumerical(left.volume) || !isNumerical(right.volume)) {
                    console.error(`bad volume while comparing: ${left} and ${right}`)
                    process.exit(1)
                }
                return left.volume - right.volume
            } else if (left.chapters !== right.chapters) {
                // same book and same volume
                return left.chapters[left.chapters.length - 1] - right.chapters[0]
            } else {
                return 0
            }
        }

        infoList.sort(compareInfo)
        return infoList
    }

    const createCategoricalInfoList = orderedInfoList => {
        return orderedInfoList
    }

    // writes index to disk
    const saveIndex = (index, name) => {
        const fullPath = path.join(indexDir, name + '.json')
        const json = JSON.stringify(index)
        fs.writeFileSync(fullPath, json)
    }

    /// MARK: read data, crate indexes, save them
    if (fs.existsSync(indexDir)) {
        console.error(`index directory exists: ${indexDir}`)
        process.exit(1)
    }
    fs.mkdirSync(indexDir)

    // indexes are trees at all times
    // node:

    const infoList = readExtractionData()
    const orderedInfoList = createOrderedInfoList(infoList)
    const categoricalInfoList = createCategoricalInfoList(orderedInfoList)
    // const hierarchicalIndex = createHierarchicalIndex(categoricalInfoList)
    // saveIndex(hierarchicalIndex, 'hierarchical')
}

// create index if needed
const indexDir = 'index'
if (!fs.existsSync(indexDir)) {
    console.log(`Constructing index at ${indexDir}`)
    createIndexes(extractionDir, indexDir)
} else
    console.log(`index already exists at ${indexDir}`)

// Currently writting this tree parser
const rawTree = `
old
    law
        genesis
        exodus
        leviticus
        numbers
        deuteronomy
    history
        joshua
        judges
        ruth
        samuel
        kings
        chronicles
        ezra
        nehemiah
        esther
    wisdom
        job
        psalm
        proverbs
        ecclesiastes
        song-of-solomon
    prophets
        major
            isaiah
            jeremiah
            lamentations
            ezekiel
            daniel
        minor
            hosea
            joel
            amos
            obadiah
            jonah
            micah
            nahum
            habakkuk
            zephaniah
            haggai
            zechariah
            malachi
new
    gospel
        matthew
        mark
        luke
        john
    acts
        acts
    epistles
        pauline
            churches
                romans
                1-corinthians
                2-corinthians
                galatians
                ephesians
                philippians
                colossians
                1-thessalonians
                2-thessalonians
            people
                1-timothy
                2-timothy
                titus
                philemon
    hebrews
        hebrews
    catholic
        james
        1-peter
        2-peter
        1-john
        2-john
        3-john
        jude
    apocalypse
        revelation
`

/* Transforms a raw string into a tree.
 * A node's level is represented by its indentation and place in the list.
 * @text The raw tree string. Tree items have no spaces in them.
 * @indent The size of the indentation in spaces
 */
const parseTree = (text, indent) => {
    // Set the indentation units
    const lines = text.split('\n')
    const indentUnit = ' '.repeat(indent)
    return lines
        .filter(line => line.length > 0) // remove blank lines
        .map(line => line.split(indentUnit)) // collapse indentUnit -> ''
        .map(parts => {
            // check its like ['',..., 'someStringDataWithoutSpaces']
            return parts
        })
        .map(parts => ({
            level: parts.length, // Always > 0
            data: parts[parts.length - 1]
        }))
}


const recurse = (parent, possibleChildren) => {
    parent.children = []
    const nextLevel = parent.level + 1

    const pairs = possibleChildren
        .map((node, index) => ({
            node,
            index
        })) // lift to node with its index in possibleChildren
        .filter(pair => pair.node.level === nextLevel) // keep direct children
    const atEnd = index => index === pairs.length - 1

    for (let i = 0; i < pairs.length; i++) {

        const cur = pairs[i]
        const next = pairs[i + 1]

        // half open range, e.g. [a,b) of
        const range = {
            start: cur.index + 1,
            end: atEnd(i) ? possibleChildren.length : next.index
        }
        const possibleDirectChildren = possibleChildren.slice(range.start, range.end)

        const directChild = cur.node
        const child = recurse(directChild, possibleDirectChildren)
        parent.children.push(child)
    }

    return parent
}

const buildTree = list => {

    const result = recurse({
        level: 0,
        data: 'bible'
    }, list)

    return result
}

const levelList = parseTree(rawTree, 4)
const tree = buildTree(levelList)
console.log(tree)

/*
  const createTreeRecursive = levelBookList => {}
  console.log('Parseing the tree')
  const result = parseTree(rawTree, 4)
  console.log(result)
*/