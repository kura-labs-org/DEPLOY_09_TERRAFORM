#Username Variable Declaration
variable "admin_username" {
  description = "Admin Username to log into the RDS Database"
  type        = string
  sensitive   = true
}

#Password Variable Declaration
variable "admin_password" {
  description = "Admin Password to log into the RDS Database"
  type        = string
  sensitive   = true
}