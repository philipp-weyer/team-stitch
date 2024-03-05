import React, { useState } from "react";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import './S3Uploader.css';

const S3Uploader = () => {
  const [selectedFile, setSelectedFile] = useState(null);
  const [message, setMessage] = useState("");

  const handleFileChange = (event) => {
    setSelectedFile(event.target.files[0]);
  };

  const handleUpload = async () => {
    if (!selectedFile) {
      setMessage("Please select a file.");
      return;
    }

    const s3Client = new S3Client({
      region: "eu-central-1", // Replace with your region
      credentials: {
        accessKeyId: "AKIA6IESFAOZ2GEF34V3", // Replace with access key
        secretAccessKey: "s6TU/JPrPDqz025Mvfuqa2jWJFl2pNJQCyOL7TUn", // Replace with secret key
      },
    });

    const params = {
      Bucket: "public-bucket-team-stitch", // Replace with your bucket name
      Key: selectedFile.name,
      Body: selectedFile,
      ACL: "public-read", // Makes the uploaded file public (optional)
    };

    try {
      await s3Client.send(new PutObjectCommand(params));
      setMessage("File uploaded successfully!");
      setSelectedFile(null); // Clear file selection after successful upload
    } catch (error) {
      console.error(error);
      setMessage("Error uploading file: " + error.message);
    }
  };

  return (
    <div className="s3-uploader-container">
      {/* ... your UI (header, instructions, etc.) */}

      <div className="s3-uploader-form">
        <input
          type="file"
          multiple="multiple"
          onChange={handleFileChange}
          className="s3-uploader-file-input"
        />
        <button onClick={handleUpload} className="s3-uploader-button">
          Upload File
        </button>
        <p className="s3-uploader-message">{message}</p>
      </div>
    </div>
  );
};

export default S3Uploader;
