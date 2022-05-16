variable "petronio_coelho_domains" {
  description = "Domains to create aliased _acme_challenge records for"
  type        = list(string)
  default     = ["", "ebino", "furano", "toba"]
}
