resource "aws_db_instance" "vector" {
  identifier             = "vector"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "15.2"
  username               = local.db_user_name
  password               = local.db_password
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.vector.id] 
}

resource "aws_security_group" "vector" {
  name        = "vector-sg"
  description = "vector security group allowing all traffic"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "database_and_extension" {
  depends_on = [aws_db_instance.vector]

  provisioner "local-exec" {
    command = <<EOT
      DB_HOST="${aws_db_instance.vector.address}"
      DB_PORT="${aws_db_instance.vector.port}"
      DB_USER="${local.db_user_name}"
      export PGPASSWORD="${local.db_password}"
      NEW_DATABASE="vectordb"
      
      psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "CREATE DATABASE $NEW_DATABASE;"
      psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$NEW_DATABASE" -c "CREATE EXTENSION vector;"
      psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$NEW_DATABASE" -c "CREATE TABLE document_vectors (id SERIAL PRIMARY KEY, title VARCHAR(32), text TEXT, embedding vector(3));"

      echo "Database and table creation complete."
    EOT
  }
}