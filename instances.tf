#### Deploy EC2 Instances ####

resource "aws_instance" "ec2_az_2a" {
  ami                         = var.ami-id
  instance_type               = var.instance-type
  key_name                    = var.pem-key
  subnet_id                   = aws_subnet.public_subnet_2a.id
  security_groups             = [aws_security_group.petclinic_app_sg.id]
  associate_public_ip_address = "true"
  # root disk
  root_block_device {
    volume_size           = var.vm_root_volume_size
    volume_type           = var.vm_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.vm_data_volume_size
    volume_type           = var.vm_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }

  # provisioner "file" {
  #   source      = "scripts/deployment-script"
  #   destination = "/tmp/deployment-script"
  # }
  # # Change permissions on bash script and execute from ec2-user.
  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/deployment-script",
  #     "sudo /tmp/deployment-script",
  #     "exit"
  #   ]
  # }

  # # Login to the ec2-user with the aws key.
  # connection {
  #   type        = "ssh"
  #   user        = "ec2-user"
  #   password    = ""
  #   private_key = file("secrets/IaC-key.pem")
  #   host        = self.public_ip
  # }

  tags = {
    name = "petclinic-az-2a"
    Environment = "staging"
  }
}

# EC2 for Second AZ for resilience 
resource "aws_instance" "ec2_az_2b" {
  ami                         = var.ami-id
  instance_type               = var.instance-type
  key_name                    = var.pem-key
  subnet_id                   = aws_subnet.public_subnet_2a.id
  security_groups             = [aws_security_group.petclinic_app_sg.id]
  associate_public_ip_address = "true"

    # root disk
  root_block_device {
    volume_size           = var.vm_root_volume_size
    volume_type           = var.vm_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.vm_data_volume_size
    volume_type           = var.vm_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  # provisioner "file" {
  #   source      = "scripts/deployment-script"
  #   destination = "/tmp/deployment-script"
  # }
  # # Change permissions on bash script and execute from ec2-user.
  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/deployment-script",
  #     "sudo /tmp/deployment-script",
  #     "exit"
  #   ]
  # }

  # # Login to the ec2-user with the aws key.
  # connection {
  #   type        = "ssh"
  #   user        = "ec2-user"
  #   password    = ""
  #   private_key = file("secrets/IaC-key.pem")
  #   host        = self.public_ip
    
  # }

  tags = {
    name = "petclinic-az-2b"
    Environment = "staging"
  }
}

#### Network Load Balancer ####
resource "aws_lb" "petclinic_ld" {
  name               = "petclinicLB"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_subnet_2a.id, aws_subnet.public_subnet_2b.id]
  tags = {
    name = "loadBalancer"
    Environment = "staging"
  }
}
## LB Target Group
resource "aws_lb_target_group" "petclinic_app_tgp" {
  name     = "petclinic-app-tgp"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.staging_vpc.id
  tags = {
    name = "loadBalancer-tg"
    Environment = "staging"
  }
}
## LB Targets Registration
resource "aws_lb_target_group_attachment" "petclinic_app_tgpa" {
  count            = 1
  target_group_arn = aws_lb_target_group.petclinic_app_tgp.arn
  target_id        = aws_instance.ec2_az_2a.id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "petclinic_app_tgpa2" {
  count            = 2
  target_group_arn = aws_lb_target_group.petclinic_app_tgp.arn
  target_id        = aws_instance.ec2_az_2b.id
  port             = 8080
}
## LB Listener
resource "aws_lb_listener" "petclinic_lb_listener" {
  load_balancer_arn = aws_lb.petclinic_ld.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.petclinic_app_tgp.arn
  }
}