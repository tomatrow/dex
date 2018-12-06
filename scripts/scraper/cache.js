const scrape = require('website-scraper')

// Caches the Enduring Word site
function cache(baseUrl, cacheDir) {
    const url = baseUrl
    const prefix = url
    const logResource = res => console.log(res)

    return scrape({
        urls: [url],
        directory: cacheDir,
        recursive: true,
        filenameGenerator: 'bySiteStructure',
        urlFilter: nextUrl => {
            // I need to be really specific, else we geta bunch of twitter links.
            return nextUrl.startsWith(prefix)
        },
        onResourceSaved: logResource,
        onResourceError: (resource, err) => {
            console.error(`     ${err}`)
            logResource(resource)
        }
    })
}

const fs = require('fs');

// cache if needed
const cacheDir = 'cache'
if (!fs.existsSync(cacheDir)) {
    console.log(`starting cacheing at ${cacheDir}`)
    cache('https://enduringword.com/bible-commentary/', cacheDir)
        .then(result => console.log('done caching'))
} else
    console.log(`cache already exists at ${cacheDir}`)