provider "google" {
  credentials = file("credentials.json")
  project     = "wso2-final-poject"
  region      = "us-central1"
}