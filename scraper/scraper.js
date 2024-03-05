const axios = require('axios');
const cheerio = require('cheerio');
const fs = require('fs');
const AWS = require('aws-sdk');
const { MongoClient } = require('mongodb');

//old
// const faqQuestionClass = '.button_title';
// const faqAnswerClass = '.mod_accordion_item_content_wrapper';
// const url = 'https://www.sbb.ch/en/help-and-contact.html';

//TODO: things you have to modify
const faqQuestionClass = '.contains-headerlink';
const faqAnswerClass = '.leafygreen-ui-kkpb6g';
const url = 'https://www.mongodb.com/docs/manual/faq/';

// const faqQuestionClass = '#faq-what';
// const faqAnswerClass = 'dd';
// const url = 'https://www.elastic.co/guide/en/cloud/current/ec-faq-getting-started.html';

AWS.config.update({
    region: 'eu-central-1',
    accessKeyId: "AKIA6IESFAOZ2GEF34V3",
    secretAccessKey: "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"
});

const s3 = new AWS.S3();


function splitUrl(url) {
    // Use URL object for robust parsing
    const parsedUrl = new URL(url);
  
    // Extract protocol, hostname, and port (if present)
    const domain = `${parsedUrl.protocol}//${parsedUrl.hostname}${parsedUrl.port ? ':' + parsedUrl.port : ''}`;
  
    // Extract the remaining path and search parameters (optional)
    const remainingPart = parsedUrl.pathname + parsedUrl.search;
  
    return { domain, remainingPart };
  }
  

async function fetchPage(url) {
    try {
        const { data } = await axios.get(url);
        // console.log(data);
        return cheerio.load(data);
    } catch (error) {
        console.error(`Error fetching page: ${error}`);
        return null;
    }
}

function parseQA($page, url) {
    const qaPairs = [];
    $page(faqQuestionClass).each((i, element) => {
        const title = $page(element).text().replace(/\n/g, ' ').trim();
        // Find the corresponding answer and remove newlines
        const body = $page($page(faqAnswerClass)[i]).text().replace(/\n/g, ' ').trim();
        // console.log("all", { title, body, url });
        qaPairs.push({ title, body, url });
    });
    return qaPairs;
}

function parseLinks($page) {
    const links = [];
    $page('a').each((i, element) => {
        const linkText = $page(element).text().trim();
        const parts = splitUrl(url);
        const href = $page(element).attr('href');
        // console.log("href", href)
        if (href && href.includes(parts.remainingPart)) {
            // Prepend the base URL if the href is a relative path
            const fullUrl = href.startsWith('http') ? href : `${parts.domain}${href}`;

            links.push({ linkText, fullUrl });
        }

        // console.log(linkText);
    });
    return links;
}

async function fetchAndParseLinks(url) {
    const $page = await fetchPage(url);
    return parseLinks($page);
}

async function processLinks(links) {
    let allSecondLevelLinks = [];

    for (let link of links) {
        const firstLevelLinks = await fetchAndParseLinks(link.fullUrl);
        // console.log("firstLevelLinks", firstLevelLinks);
        // allSecondLevelLinks = allSecondLevelLinks.concat(firstLevelLinks);
        for (let innerLink of firstLevelLinks) {
            const secondLevelLinks = await fetchAndParseLinks(innerLink.fullUrl);
            console.log("allSecondLevelLinks", allSecondLevelLinks);
            allSecondLevelLinks = allSecondLevelLinks.concat(secondLevelLinks);
        }
    }

    // console.log("allSecondLevelLinks", allSecondLevelLinks);
    return allSecondLevelLinks;
}

function generateRandomFilename() {
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    let filename = 'myFile-';
    for (let i = 0; i < 10; i++) {
      filename += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    filename += '.json';
    return filename;
  }

async function processAndSaveQA(links) {
    for (let link of links) {
        const $page = await fetchPage(link.fullUrl);
        // console.log("link.fullUrl", link.fullUrl);
        const qaPairs = parseQA($page, link.fullUrl);
        const jsonData = JSON.stringify(qaPairs, null, 2);

        const params = {
            Bucket: 'public-bucket-team-stitch',
            Key: generateRandomFilename(),
            Body: jsonData
        };
        
        // Upload the file to S3
        s3.upload(params, (err, data) => {
            if (err) {
                console.log('Error uploading file:', err);
            } else {
                console.log('File uploaded successfully. File location:', data.Location);
            }
        });


        fs.writeFile('mydata.json', jsonData, 'utf8', (err) => {
            if (err) {
                console.error('Error writing file:', err);
            } else {
                console.log('Data saved successfully to mydata.json');
            }
        });
        
        // await saveToMongoDB(qaPairs);
    }
}

async function saveToMongoDB(qaPairs) {
    const uri = 'mongodb+srv://main_user:Passw0rd@mybank2.aagmh.mongodb.net/?retryWrites=true&w=majority';
    const client = new MongoClient(uri);

    try {
        const database = client.db('SBB');
        const collection = database.collection('qa');
        const result = await collection.insertMany(qaPairs);
        console.log(`${result.insertedCount} documents were inserted`);
    } catch (e) {
        console.error(e);
    } finally {
        await client.close();
    }
}

// Usage
const initialLinks = [{ fullUrl: url }];
processLinks(initialLinks).then(allSecondLevelLinks => {
    processAndSaveQA(allSecondLevelLinks);
});

