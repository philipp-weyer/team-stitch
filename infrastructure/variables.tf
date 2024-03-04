variable "aws_region" {
  description = "AWS Region the infrastructure will be deployed in"
}

variable "aws_profile" {
  description = "AWS Profile"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to be created"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
}

variable "availability_zone" {
  description = "The az that the resources will be launched"
}

variable "atlas_public_key" {
  description = "Atlas Public Key"
}

variable "atlas_private_key" {
  description = "Atlas Private Key"
}

variable "atlas_project_id" {
  description = "Atlas Project ID Key"
}

variable "atlas_user_name" {
  description = "Atlas Username"
}

variable "atlas_password" {
  description = "Atlas Password"
}

variable "atlas_region" {
  description = "Atlas Region the cluster is going to he deployed in"
}

variable "atlas_cluster_name" {
  description = "Name of the Atlas Cluster"
}

variable "owner" {
  description = "Name of resource owner"
}

variable "expire" {
  description = "Date of expiry"
}

variable "purpose" {
  description = "Purpose of deployment (opportunity, training)"
}

# variable "key_name" {
  # description = "SSH key name to store"
# }
#
# variable "key_path" {
  # description = "Path where to find the public key"
# }

variable "project" {
  description = "Project name that will be used"
}

variable "db_name" {
  description = "DB name"
}

variable "coll_name" {
  description = "Collection name"
}

variable "embedding_path" {
  description = "Path where the vector embeddings are stored within the documents"
}

variable "embedding_dim" {
  description = "Number of dimensions of the embedding model that is used"
}

variable "embedding_sim" {
  description = "Similarity function used for vector comparisons"
}
