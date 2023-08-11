variable "dev_email" {
    description = "Owner's work email address"
    type = string
}

variable "vpc_cidr" {
    description = "vpc cidr block"
    type = string
}

variable "pub_sub_az1_cidr" {
    description = "public subnet az1 cidr block"
    type = string
}

variable "ssh_cidr" {
    description = "range of allowed ip's that can ssh into the sonarqube instance"
    type = string
}

variable "port_9000_cidr" {
    description = "range of allowed ip's that are allowed through port 9000 into  the sonarqube instance"
    type = string
}

variable "ec2_ami" {
    description = "ec2 instance ami"
    type = string
}


