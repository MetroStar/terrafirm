provider "aws" {}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_pair_name}"
  public_key = "${var.public_key}"
}

# Security group to access the instances over WinRM
resource "aws_security_group" "terrafirm" {
  name        = "terrafirm_sg"
  description = "Used in terrafirm"

  # SSH access from anywhere
  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "centos6" {
  most_recent = true
  
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name = "name"
    values = ["spel-minimal-centos-6*"]
  }
  
  owners = ["701759196663","self"]
}

data "aws_ami" "centos7" {
  most_recent = true
  
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name = "name"
    values = ["spel-minimal-centos-7*"]
  }
  
  owners = ["701759196663","self"]
}

data "aws_ami" "rhel6" {
  most_recent = true
  
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name = "name"
    values = ["spel-minimal-rhel-6*"]
  }
  
  owners = ["701759196663","self"]
}

data "aws_ami" "rhel7" {
  most_recent = true
  
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name = "name"
    values = ["spel-minimal-rhel-7*"]
  }
  
  owners = ["701759196663","self"]
}

data "aws_ami" "windows2016" {
  most_recent = true
  
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name = "name"
    values = ["Windows_Server-2016-English-Full-Base*"]
  }
  
  owners = ["099720109477","801119661308","amazon"]
}

data "aws_ami" "windows2012" {
  most_recent = true
  
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "name"
    values = ["Windows_Server-2012-R2_RTM-English-64Bit-Base*"]
  }

  owners = ["099720109477","801119661308","amazon"]
}

data "aws_ami" "windows2008" {
  most_recent = true
  
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "name"
    values = ["Windows_Server-2008-R2_SP1-English-64Bit-Base*"]
  }
  
  owners = ["099720109477","801119661308","amazon"]
}

resource "aws_instance" "windows2016" {
  #ami = "${var.ami}"
  ami = "${data.aws_ami.windows2016.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.terrafirm.id}"]
  user_data = "${file("windows/userdata2.ps1")}"
  #user_data = "${template_file.userdata.rendered}"
  
  timeouts {
    create = "40m"
    delete = "40m"
  }
  
  connection {
    #winrm connection to tier-2 instance
    type     = "winrm"
    user     = "${var.term_user}"
    password = "${var.term_passwd}"
    timeout   = "30m"
    #https    = true
  }
  
  provisioner "file" {
    source = "windows/watchmaker_test.ps1"
    destination = "C:\\scripts\\watchmaker_test.ps1"
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
  
  provisioner "remote-exec" {
    inline = [
      "hostname",
      "powershell.exe -File C:\\scripts\\watchmaker_test.ps1",
    ]
  }
  
}

resource "aws_instance" "windows2012" {
  #ami = "${var.ami}"
  ami = "${data.aws_ami.windows2012.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.terrafirm.id}"]
  user_data = "${file("windows/userdata2.ps1")}"
  #user_data = "${template_file.userdata.rendered}"
  
  timeouts {
    create = "40m"
    delete = "40m"
  }
  
  connection {
    #winrm connection to tier-2 instance
    type     = "winrm"
    user     = "${var.term_user}"
    password = "${var.term_passwd}"
    timeout   = "30m"
    #https    = true
  }
  
  provisioner "file" {
    source = "windows/watchmaker_test.ps1"
    destination = "C:\\scripts\\watchmaker_test.ps1"
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
  
  provisioner "remote-exec" {
    inline = [
      "hostname",
      "powershell.exe -File C:\\scripts\\watchmaker_test.ps1",
    ]
  }
  
}

resource "aws_instance" "windows2008" {
  #ami = "${var.ami}"
  ami = "${data.aws_ami.windows2008.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.terrafirm.id}"]
  user_data = "${file("windows/userdata2.ps1")}"
  #user_data = "${template_file.userdata.rendered}"
  
  timeouts {
    create = "40m"
    delete = "40m"
  }
  
  connection {
    #winrm connection to tier-2 instance
    type     = "winrm"
    user     = "${var.term_user}"
    password = "${var.term_passwd}"
    timeout   = "30m"
    #https    = true
  }
  
  provisioner "file" {
    source = "windows/watchmaker_test.ps1"
    destination = "C:\\scripts\\watchmaker_test.ps1"
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
  
  provisioner "remote-exec" {
    inline = [
      "hostname",
      "powershell.exe -File C:\\scripts\\watchmaker_test.ps1",
    ]
  }
  
}
