terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "AQAAAAAHCRUAAATuwRcT-tncgUbugmnxQNJEU8o"
  cloud_id  = "b1gg82n3pv24j3d9qihs"
  folder_id = "b1g8p0oqeo4nim4ua3js"
  zone      = "ru-central1-a"
}