
variable BACKEND_URL{
  type        = string
  default  = "http://localhost:8000"
  sensitive   = false

}

variable STORAGE_CONTAINER{
  type        = string
  sensitive   = false
    default  = "test-container"
}
