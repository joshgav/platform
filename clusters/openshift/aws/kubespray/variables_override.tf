data "aws_ami" "distro" {
  most_recent = true

  filter {
    name   = "name"
    values = ["AlmaLinux OS 8.6.*"]
  }

  owners = ["679593333241"]
}