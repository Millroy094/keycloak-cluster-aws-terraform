resource "aws_security_group" "keycloak_alb_sg" {
  name   = "keycloak-alb-sg"
  vpc_id = aws_vpc.auth.id

  # Default rule to allow inbound traffic from anywhere on port 8080
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  # Default rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "keycloak_service_sg" {
  name        = "keycloak-service-sg"
  description = "Security group for Keycloak ECS service"
  vpc_id      = aws_vpc.auth.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.keycloak_alb_sg.id]
  }

  # Default rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "keycloak_db_sg" {
  name        = "keycloak-db-sg"
  vpc_id      = aws_vpc.auth.id
  description = "Security group for RDS instance"

  tags = {
    Name = "rds-security-group"
  }
}

resource "aws_security_group_rule" "ecs_to_postgres" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.keycloak_service_sg.id
  security_group_id        = aws_security_group.keycloak_db_sg.id
}