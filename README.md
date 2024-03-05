# team-stitch


# MongoDB Atlas Vector Search Demo App

## Overview

This application is designed to empower MongoDB solutions architects in demonstrating the capabilities of MongoDB Atlas Vector Search for enhancing Q&A sections on customer websites. By crawling customer websites, storing documents on AWS S3, and leveraging serverless architecture, this app showcases how MongoDB Atlas can seamlessly integrate its Vector Search capabilities on top of the customers data in order to improve search functionalities.

## Features

- **Web Crawling:** The app allows solutions architects to crawl customer websites, extracting relevant data for Q&A sections.

- **AWS S3 Integration:** Documents obtained from web crawling are stored on AWS S3 and moved to MongoDB Atlas via a Lambda Function triggered by S3 Event Notification.

- **Serverless Architecture:** The application utilizes AWS Lambda functions to automate the process of triggering events based on S3 updates as well as MongoDB Atlas App services to invoke Azure AI services through AI GAteway, to retrieve embeddings from crawled content and user queries. Once done it is possible to leverage Vector search and provide context to LLM to package a simple response summarizing results.

- **Ways of inputs:** Raw JSON documents, either extracted from the web crawler or manually inputted by users, are written into a MongoDB Atlas Cluster. Add it

Feel free to customize this README file according to your project's specific details and requirements.