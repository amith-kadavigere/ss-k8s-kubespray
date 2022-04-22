terraform {
  backend "s3" {
    bucket = "ss-tf-k8s-state"
    key    = "dev/kubespray"
    region = "us-east-1"
  }
}