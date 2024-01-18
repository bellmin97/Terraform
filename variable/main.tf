variable "name" {
  type    = list(string)
  default = ["abc", "bcd", "cde"]
}

resource "local_file" "hello" {
  for_each = toset(var.name)
  filename = "${path.module}/${each.value}.txt"
  content  = each.key
}

variable "map" {
  type = map(string)
  default = {
    "map1" = "map11111111111",
    "map2" = "map222222222222",
    "map3" = "map333333333333"
  }
}

resource "local_file" "mapmap" {
  for_each = var.map
  filename = "${path.module}/${each.key}.txt"
  content  = each.value
}

variable "path" {
  default = "path.module"
}

resource "local_file" "pathpath" {
  filename = "${var.path}/hello/path.txt"
  content  = var.path
}

variable "jojo" {
  type    = list(string)
  default = ["aa", "bbb", "cccc", "dddd"]
}

resource "local_file" "jojojo" {
  for_each = toset(var.jojo)
  filename = length(each.key) == 2 ? "${path.module}/${each.key}.txt" : "${path.module}/hello/${each.key}.txt"
  content  = each.key
}