
variable "jenkins_instance_count" {
  description = "Number of Jenkins instances to create"
  type        = number
  default     = 2
}

variable "web_instance_count" {
  description = "Number of web instances to create"
  type        = number
  default     = 2
}

variable "home_path" {
  description = "Home path of the user"
  type        = string  
}
