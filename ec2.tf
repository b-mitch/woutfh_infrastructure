# create key pair
resource "aws_key_pair" "key_pair" {
    key_name   = "id_rsa"
    public_key = file(var.public_key_path)
}

# create production ec2 instance
resource "aws_instance" "prod_instance" {
    ami           = "ami-0005e0cfe09cc9050"
    instance_type = "t2.micro"

    root_block_device {
        volume_size = 8
    }

    vpc_security_group_ids      = [aws_security_group.prod_webserver_security_group.id]
    subnet_id                   = aws_subnet.public_prod_subnet.id
    associate_public_ip_address = true
    key_name                    = aws_key_pair.key_pair.key_name
    
    tags = {
        Name        = "prod-instance"
        Environment = "production"
        Project     = "woutfh"
    }
}

# create dev ec2 instance
resource "aws_instance" "dev_instance" {
    ami           = "ami-0005e0cfe09cc9050"
    instance_type = "t2.micro"

    root_block_device {
        volume_size = 8
    }

    vpc_security_group_ids      = [aws_security_group.dev_webserver_security_group.id]
    subnet_id                   = aws_subnet.public_dev_subnet.id
    associate_public_ip_address = true
    key_name                    = aws_key_pair.key_pair.key_name

    tags = {
        Name        = "dev-instance"
        Environment = "development"
        Project     = "woutfh"
    }
}
