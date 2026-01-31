data "aws_ami" "ubuntu" {
  most_recent = false

  filter {
    name   = "image-id"
    values = ["ami-0c398cb65a93047f2"]
  }
}
