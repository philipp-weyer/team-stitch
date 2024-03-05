# team-stitch


# StitchAI Search Enhancer

## Overview

This application is designed to empower MongoDB solutions architects in demonstrating the capabilities of MongoDB Atlas Vector Search for enhancing Q&A sections on customer websites. By crawling customer websites, storing documents on AWS S3, and leveraging serverless architecture, this app showcases how MongoDB Atlas can seamlessly integrate its Vector Search capabilities on top of the customers data in order to improve search functionalities.

![flow](https://github.com/philipp-weyer/team-stitch/assets/3890291/43a9ecb6-9a1a-4fcb-b402-2e91ce3a8e29)

## Features

- **Web Crawling:** The app allows solutions architects to crawl customer websites, extracting relevant data for Q&A sections.

- **AWS S3 Integration:** Documents obtained from web crawling are stored on AWS S3 and moved to MongoDB Atlas via a Lambda Function triggered by S3 Event Notification.

- **Serverless Architecture:** The application utilizes AWS Lambda functions to automate the process of triggering events based on S3 updates as well as MongoDB Atlas App services to invoke Azure AI services through AI GAteway, to retrieve embeddings from crawled content and user queries. Once done it is possible to leverage Vector search and provide context to LLM to package a simple response summarizing results.

- **Ways of inputs:** Raw JSON documents, either extracted from the web crawler or manually inputted by users, are written into a MongoDB Atlas Cluster. Add it

Feel free to customize this README file according to your project's specific details and requirements.


## How It Works

1. **Uploading or Web Crawling:**
   - User can use the sample webpage to upload knowledge base json documents OR sopecify a website URL for crawling content in order to extract relevant information

2. **AWS S3 Storage:**
   - Extracted documents are stored on AWS S3 and processed via a Lambda function that stores them into Atlas 

3. **App Services Function 1:**
   - Once documents are written into the Atlas Cluster in the 'content' collection, an appservices function gets invoked via an Atlas Trigger. This function calls the OpenAI embedding model (Ai Services Computyer Vision which is multi-modal for future enhancements) to retrieve vector embeddings and updates the Documents within the collection with all document related vector information.

4. **Lambda transferFunction:**
   - The Lambda function processes raw JSON documents obtained from the web crawler or inputted by users and writes them on MongoDB for further processing.


## Using the scraper functionatlity
1. **configuring the crawler:**
open the scraper/scraper.js file with a text editor and modify the top 3 parameters as so:

// insert here the class of the question
const faqQuestionClass = '.contains-headerlink';
// insert here the class of the answer
const faqAnswerClass = '.leafygreen-ui-kkpb6g';
// insert here the faq site

1. **run the scraper script:**

```node
node ./scraper/scraper.js
```
![image](https://github.com/philipp-weyer/team-stitch/assets/3890291/48b87b5c-cf28-4b85-8da0-1a2d054b4b59)

## Uploading the knowledge base manually
1. **setting up WebApp:**
navigate to the webapp project folder
```bash
cd /frontend
```
2. **running the WebApp:**

```node
npm run dev
```
3. **Upload any type of file:**
Initially only JSON files are supported but the embedding model used, allows multi modal behaviour and images will be handled too.



## Setup Instructions

1. **Terraform and Stuff:**


## Dependencies
1. **Dep 1:**
2. **Dep 2:**
3. **Dep 3:**
