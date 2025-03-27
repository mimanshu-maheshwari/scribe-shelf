terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  # only required in windows not for linux and mac
  host = "npipe:////.//pipe//docker_engine"
}

resource "docker_image" "nginx" {
  name         = "nginx"
  keep_locally = false
}

resource "docker_container" "nginx" {
  # these are arguments
  image = docker_image.nginx.image_id
  name  = "tutorial"

  # these are blocks
  ports {
    internal = 80
    external = 8000
  }

}
