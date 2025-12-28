resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "adeife_key" {
  key_name   = "adeife-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_instance" "web" {
  ami           = var.web_instance_ami
  instance_type = "t3.micro"
  key_name      = aws_key_pair.adeife_key.key_name
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "adeife-server"
  }
}