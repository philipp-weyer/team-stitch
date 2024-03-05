resource "mongodbatlas_project_ip_access_list" "access_eu" {
  project_id = var.atlas_project_id
  cidr_block = "${aws_eip.nat_eip.public_ip}/32"
}

resource "mongodbatlas_database_user" "test" {
  username           = var.atlas_user_name
  password           = var.atlas_password
  project_id         = var.atlas_project_id
  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }

  scopes {
    name = mongodbatlas_cluster.cluster.name
    type = "CLUSTER"
  }
}

resource "mongodbatlas_cluster" "cluster" {
  project_id   = var.atlas_project_id
  name         = var.atlas_cluster_name
  cloud_backup = false
  cluster_type = "REPLICASET"

  provider_name = "AWS"
  provider_instance_size_name = "M10"

  mongo_db_major_version = "7.0"

  replication_specs {
    num_shards = 1
    regions_config {
      region_name = var.atlas_region
      electable_nodes = 3
      priority = 7
      read_only_nodes = 0
    }
  }
}

# resource "mongodbatlas_search_index" "searchIndex" {
  # name = "searchIndex"
  # project_id = var.atlas_project_id
  # cluster_name = mongodbatlas_cluster.cluster.name
#
  # analyzer = "lucene.standard"
  # database = var.db_name
  # collection_name = var.coll_name
  # mappings_dynamic = true
#
  # search_analyzer = "lucene.standard"
#
  # wait_for_index_build_completion = true
# }
#
# output "rendered" {
  # value = templatefile("${path.module}/vectorIndex.tftpl", {
    # embedding_path = var.embedding_path,
    # embedding_dim = var.embedding_dim,
    # embedding_sim = var.embedding_sim
  # })
# }

# resource "mongodbatlas_search_index" "vectorIndex" {
  # name = "vectorIndex"
  # project_id = var.atlas_project_id
  # cluster_name = mongodbatlas_cluster.cluster.name
#
  # analyzer = "lucene.standard"
  # database = var.db_name
  # collection_name = var.coll_name
  # type = "vectorSearch"
#
#   wait_for_index_build_completion = true
#
  # fields = templatefile("${path.module}/vectorIndex.tftpl", {
    # embedding_path = var.embedding_path,
    # embedding_dim = var.embedding_dim,
    # embedding_sim = var.embedding_sim
  # })
# }
