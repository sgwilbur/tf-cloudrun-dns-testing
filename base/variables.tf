
variable region {
  type = string
  description = "Region to deploy these services"
  default = null
}

variable credfile {
  type = string
  description = "file path with filename to the credentials json file."
  default = null
}

variable project_id {
  type = string
  description = "Name of the project"
  default = null
}

variable zonename {
  type = string
  default = null
}

variable domain {
  type = string
  description = "Base domain name to work with."
  default = null
}
