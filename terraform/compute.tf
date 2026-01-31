resource "aws_instance" "nginx_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  subnet_id              = aws_subnet.public.id

  tags = {
    Name    = "${var.project_name}-server"
    Project = var.project_name
  }
}
