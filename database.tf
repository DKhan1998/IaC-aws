## DB Subent Group
resource "aws_db_subnet_group" "petclinic_db_subnet_group" {
  name       = "petclinic_db_subnet_group"
  subnet_ids = [aws_subnet.public_subnet_2a.id, aws_subnet.public_subnet_2b.id]
  tags = {
    Name = "petclinic_db_subnet_group"
    Environment = "staging"
  }
}

## DB instance
resource "aws_db_instance" "petclinic_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  db_name                = "petclinic"
  identifier             = "petclinic-db"
  username               = var.db-user
  password               = var.db-password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.petclinic_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.petclinic_db_sg.id]
  skip_final_snapshot    = "true"

  tags = {
    Name = "petclinic_db"
    Environment = "staging"
  }  
}