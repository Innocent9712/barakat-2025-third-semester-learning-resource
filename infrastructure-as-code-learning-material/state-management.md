IaC Script state
{
    instance = {
        name = "example-instance"
        ami = "ami-0c94855ba95c574c8"
        instance_type = "t2.small"
        key_name = "example-key"
        subnet_id = "subnet-0e9c6a9e"
        vpc_security_group_ids = ["sg-0e9c6a9e"]
    }

    s3_bucket = {
        bucket_name = "example-bucket-12345"
        acl = "private"
        versioning = true
    }
}

IaC tool state
{
    instance = {
        name = "example-instance"
        ami = "ami-0c94855ba95c574c8"
        instance_type = "t2.small"
        key_name = "example-key"
        subnet_id = "subnet-0e9c6a9e"
        vpc_security_group_ids = ["sg-0e9c6a9e"]
    }

    s3_bucket = {
        bucket_name = "example-bucket-12345"
        acl = "private"
        versioning = true
    }
}


AWS state
{
    instance = {
        name = "example-instance"
        ami = "ami-0c94855ba95c574c8"
        instance_type = "t2.small"
        key_name = "example-key"
        subnet_id = "subnet-0e9c6a9e"
        vpc_security_group_ids = ["sg-0e9c6a9e"]
    }

    s3_bucket = {
        bucket_name = "example-bucket-12345"
        acl = "private"
        versioning = true
    }
}
