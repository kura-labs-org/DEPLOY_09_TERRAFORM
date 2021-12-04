variable "user" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "pass" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}