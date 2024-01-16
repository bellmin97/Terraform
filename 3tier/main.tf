provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "tier3_vpc" {# 리소스명에는 숫자가 먼저 오면 안된다 3tier X  tire3 OK
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "3tier_VPC"
  }
}

resource "aws_internet_gateway" "tier3_igw" {
  vpc_id = aws_vpc.tier3_vpc.id
  tags = {
    Name = "3tier_IGW"
  }
}

resource "aws_nat_gateway" "tier3_nat" {
  allocation_id = aws_eip.tier3_eip.id
  subnet_id = aws_subnet.tier3_sub_pub1.id
  tags = {
    Name = "3tier_NAT"
  }
}

resource "aws_eip" "tier3_eip" {
  domain = "vpc" # vpc = ture 와 기능적 차이는 없지만 terraform에서는 domain = "vpc" 를 추천함
  tags = {
    Name = "3tier_EIP"
  }
}

resource "aws_subnet" "tier3_sub_pub1" {
  vpc_id = aws_vpc.tier3_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true # bastion을 실행하기 위한 퍼블릭 ip 자동 할당 옵션
  tags = {
    Name = "3tier_SUB_PUB1"
  }
}

resource "aws_subnet" "tier3_sub_pub2" {
  vpc_id = aws_vpc.tier3_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "3tier_SUB_PUB2" 
  }
}

resource "aws_subnet" "tier3_sub_pri1_web" {
  vpc_id = aws_vpc.tier3_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "3tier_SUB_PRI1_WEB"
  }
}

resource "aws_subnet" "tier3_sub_pri2_web" {
  vpc_id = aws_vpc.tier3_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "3tier_SUB_PRI2_WEB"
  }
}

resource "aws_subnet" "tier3_sub_pri1_was" {
  vpc_id = aws_vpc.tier3_vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "3tier_SUB_PRI1_WAS"
  }
}

resource "aws_subnet" "tier3_sub_pri2_was" {
  vpc_id = aws_vpc.tier3_vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "3tier_SUB_PRI2_WAS"
  }
}

resource "aws_subnet" "tier3_sub_pri1_db" {
  vpc_id = aws_vpc.tier3_vpc.id
  cidr_block = "10.0.7.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "3tier_SUB_PRI1_DB"
  }
}

resource "aws_subnet" "tier3_sub_pri2_db" {
  vpc_id = aws_vpc.tier3_vpc.id
  cidr_block = "10.0.8.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "3tier_SUB_PRI2_DB"
  }
}

# public에서 igw를 통해 나갈수 있게 라우팅 테이블 설정
resource "aws_route_table" "tier3_rt_pub" {
  vpc_id = aws_vpc.tier3_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tier3_igw.id
  }
  tags = {
    Name = "3tier_RT_PUB"
  }
}

resource "aws_route_table_association" "tier3_rtass_pub-1" {
    subnet_id = aws_subnet.tier3_sub_pub1.id
    route_table_id = aws_route_table.tier3_rt_pub.id
}

resource "aws_route_table_association" "tier3_rtass_pub-2" {
    subnet_id = aws_subnet.tier3_sub_pub2.id
    route_table_id = aws_route_table.tier3_rt_pub.id
}

#private 영역을 nat에 연결시킬 라우팅 테이블 생성
resource "aws_route_table" "tier3_rt_pri-web" {
  vpc_id = aws_vpc.tier3_vpc.id
  tags = {
    Name = "3tier_RT_PRI-WEB"
  }
}

#생성 시킨 라우팅 테이블을 nat에 연결
resource "aws_route" "tier3_rtnat" {
  route_table_id = aws_route_table.tier3_rt_pri-web.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.tier3_nat.id
}

#위에서 라우팅 테이블을 생성시키고 라우팅 규칙으로 nat에 연결을 해줬다. 다음은 여기에 프라이빗 서브넷들을 연결 시켜준다.
resource "aws_route_table_association" "tier3_rtass_pri_web1" {
  subnet_id = aws_subnet.tier3_sub_pri1_web.id
  route_table_id = aws_route_table.tier3_rt_pri-web.id
}

resource "aws_route_table_association" "tier3_reass_pri_web2" {
  subnet_id = aws_subnet.tier3_sub_pri2_web.id
  route_table_id = aws_route_table.tier3_rt_pri-web.id
}

#sg pri web용
resource "aws_security_group" "tier3_sg_pri_web" {
  name = "tier3_sg_pri_web"
  description = "tier3_sg_pri_web"
  vpc_id = aws_vpc.tier3_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.tier3_sg_pub_bastion.id]
   }
   ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }
   tags = {
     Name = "3tier_SG_PRI_WEB"
   }
}

# bastion용 sg
resource "aws_security_group" "tier3_sg_pub_bastion" {
  name = "tier3_sg_pub_bastion"
  description = "tier3_sg_pub_bastion"
  vpc_id = aws_vpc.tier3_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0 # 포트를 0에서 0까지 허용한다. 모든포트를 허용
    to_port = 0
    protocol = "-1" # protocol -1은 모든 프로토콜 허용
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "3tier_SG_PUB_BASTION"
  }
}
 
 #베스천 인스턴스 퍼블릭1에다가
resource "aws_instance" "tier3_ec2_pub_1_bastion" {
  ami = "ami-09eb4311cbaecf89d"
  instance_type = "t2.micro"
  availability_zone = "ap-northeast-2a"
  subnet_id = aws_subnet.tier3_sub_pub1.id
  key_name = aws_key_pair.jmshin_keypair.id
  vpc_security_group_ids = [
    aws_security_group.tier3_sg_pub_bastion.id
  ]
  tags = {
    Name = "3tier_EC2_PUB1_BASTION"
  }
}

# web ec2 생성 및 bastion에서 접속 후 web 설치
resource "aws_instance" "tier3_ec2_pri_1_web" {
  ami = "ami-09eb4311cbaecf89d"
  instance_type = "t2.micro"
  availability_zone = "ap-northeast-2a"
  subnet_id = aws_subnet.tier3_sub_pri1_web.id
  key_name = aws_key_pair.jmshin_keypair.id
  vpc_security_group_ids = [
    aws_security_group.tier3_sg_pri_web.id
  ]
  tags = {
    Name = "3tier_EC2_PRI_1_WEB"
  }
  }
  
resource "aws_instance" "tier3_ec2_pri_2_web" {
  ami = "ami-09eb4311cbaecf89d"
  instance_type = "t2.micro"
  availability_zone = "ap-northeast-2c"
  subnet_id = aws_subnet.tier3_sub_pri2_web.id
  key_name = aws_key_pair.jmshin_keypair.id
  vpc_security_group_ids = [
    aws_security_group.tier3_sg_pri_web.id
  ]
  tags = {
    Name = "3tier_EC2_PRI_2_WEB"
  }
}

# was sg
resource "aws_security_group" "tier3_sg_pri_was" {
  name = "tier3_sg_pri_was"
  description = "tier3_sg_pri_was"
  vpc_id = aws_vpc.tier3_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [
      aws_security_group.tier3_sg_pub_bastion.id
    ]
  }
}

#db sg /3306은 MySQL DB 포트
resource "aws_security_group" "tier3_sg_pri_db" {
  name = "tier3_sg_pri_db"
  description = "tier3_sg_pri_db"
  vpc_id = aws_vpc.tier3_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.tier3_sg_pub_bastion.id] 
  }
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "3tier_SG_PRI_DB"
    }
  }

# was ec2
resource "aws_instance" "tier3_ec2_pri_1_was" {
  ami = "ami-09eb4311cbaecf89d"
  instance_type = "t2.micro"
  availability_zone = "ap-northeast-2a"
  subnet_id = aws_subnet.tier3_sub_pri1_was.id
  key_name = aws_key_pair.jmshin_keypair.id
  ebs_block_device {
    device_name = "/dev/sdv"
    volume_size = "8"
  }
  vpc_security_group_ids = [
    aws_security_group.tier3_sg_pri_was.id
  ]
  tags = {
    Name = "3tier_EC2_PRI_1_WAS"
  }
}

resource "aws_instance" "tier3_ec2_pri_2_was" {
  ami = "ami-09eb4311cbaecf89d"
  instance_type = "t2.micro"
  ebs_block_device {
    device_name = "/dev/sdv"
    volume_size = "8"
  }
  availability_zone = "ap-northeast-2c"
  subnet_id = aws_subnet.tier3_sub_pri2_web.id
  key_name = aws_key_pair.jmshin_keypair.id
  vpc_security_group_ids = [
    aws_security_group.tier3_sg_pri_was.id
  ]
  tags = {
    Name = "3tier_EC2_PRI_2_WAS"
  }
}

# db ec2
resource "aws_instance" "tier3_ec2_pri_1_db" {
  ami = "ami-09eb4311cbaecf89d"
  instance_type = "t2.micro"
  availability_zone = "ap-northeast-2a"
  subnet_id = aws_subnet.tier3_sub_pri1_db.id
  key_name = aws_key_pair.jmshin_keypair.id
  vpc_security_group_ids = [ 
    aws_security_group.tier3_sg_pri_db.id
  ]
  tags = {
    Name = "3tier_EC2_PRI_1_DB"
  }
}

resource "aws_instance" "tier3_ec2_pri_2_db" {
  ami = "ami-09eb4311cbaecf89d"
  instance_type = "t2.micro"
  availability_zone = "ap-northeast-2c"
  subnet_id = aws_subnet.tier3_sub_pri2_db.id
  key_name = aws_key_pair.jmshin_keypair.id
  vpc_security_group_ids = [
    aws_security_group.tier3_sg_pri_db.id
  ]
  tags = {
    Name = "3tier_EC2_PRI_2_DB"
  }
}

# pem키만들기
resource "tls_private_key" "jmshin" {
  algorithm = "RSA"
  rsa_bits =  4096
}                     

# aws에 key pair 만들기
resource "aws_key_pair" "jmshin_keypair" {
  key_name = "jmshin_keypair"
  public_key = tls_private_key.jmshin.public_key_openssh
}

# pem키 로컬에 저장
resource "local_file" "jmshin_pem" {
  filename = "/home/username/project/Terraform/3tier/keys/${aws_key_pair.jmshin_keypair.key_name}.pem"
  content = tls_private_key.jmshin.private_key_pem
  depends_on = [ aws_key_pair.jmshin_keypair ]
}

resource "null_resource" "change_key_permission" {
  provisioner "local-exec" {
    command = "chmod 400 /home/username/project/Terraform/3tier/keys/jmshin_keypair.pem" 
  }
  depends_on = [ local_file.jmshin_pem ]
}

# output 인스턴스 ip 확인
output "bastion" {
  value = aws_instance.tier3_ec2_pub_1_bastion.public_ip
}

output "web1" {
  value = aws_instance.tier3_ec2_pri_1_web.private_ip
}

output "web2" {
  value = aws_instance.tier3_ec2_pri_2_web.private_ip
}

output "was1" {
  value = aws_instance.tier3_ec2_pri_1_was.private_ip
}

output "was2" {
  value = aws_instance.tier3_ec2_pri_2_was.private_ip
}

output "db1" {
  value = aws_instance.tier3_ec2_pri_1_db.private_ip
}

output "db2" {
  value = aws_instance.tier3_ec2_pri_2_db.private_ip
}

# ALB 생성
resource "aws_alb" "tier3_alb_web" {
  name = "tier3-alb-web"
  internal = false    # false는 외부통신용 true는 내부용
  load_balancer_type = "application"
  security_groups = [aws_security_group.tier3_sg_pri_web.id]
  subnets = [aws_subnet.tier3_sub_pri1_web.id,
  aws_subnet.tier3_sub_pri2_web.id]
  tags = {
    Name = "3tier_ALB_WEB"
  }
}

# 타겟그룹 생성
resource "aws_alb_target_group" "tier3_atg_web" {
  name = "tier3-atg-web"
  port = "80"
  protocol = "HTTP"
  vpc_id = aws_vpc.tier3_vpc.id
  target_type = "instance"
  tags = {
    Name = "tier3_ATG_WEB"
  }
}

# 리스너 생성
resource "aws_alb_listener" "tier3_alt_web" {
  load_balancer_arn = aws_alb.tier3_alb_web.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.tier3_atg_web.arn
  }
}

# 2개 web ec2 타겟그룹에 연결
resource "aws_alb_target_group_attachment" "tier3_att_web1" {
  target_group_arn = aws_alb_target_group.tier3_atg_web.arn
  target_id = aws_instance.tier3_ec2_pri_1_web.id
  port = 80
}

resource "aws_alb_target_group_attachment" "tier3_att_web2" {
  target_group_arn = aws_alb_target_group.tier3_atg_web.arn
  target_id = aws_instance.tier3_ec2_pri_2_web.id
  port = 80
}

# NLB 생성
resource "aws_alb" "tier3_nlb_was" {
  name = "tier3-nlb-was"
  internal = true
  load_balancer_type = "network"
  subnets = [aws_subnet.tier3_sub_pri1_was.id, aws_subnet.tier3_sub_pri2_was.id]
  tags = {
    Name = "tier3_NLB_WAS"
  }
}

# 타겟그룹 생성 tomcat 8080포트
resource "aws_alb_target_group" "tier3_ntg_was" {
  name = "tier3-ntg-was"
  port = "8080"
  protocol = "TCP"
  vpc_id = aws_vpc.tier3_vpc.id
  target_type = "instance"
  tags = {
    Name = "3tier_NTG_WAS"
  }
}

# NLB 리스너 생성
resource "aws_alb_listener" "tier3_nlt_was" {
  load_balancer_arn = aws_alb.tier3_nlb_was.arn
  port = "8080"
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.tier3_ntg_was.arn
  }
}

# NLB에 인스턴스 연결
resource "aws_alb_target_group_attachment" "tier3_ntt_was1" {
  target_group_arn = aws_alb_target_group.tier3_ntg_was.arn
  target_id = aws_instance.tier3_ec2_pri_1_was.id
  port = 8080
}

resource "aws_alb_target_group_attachment" "tier3_ntt_was2" {
  target_group_arn = aws_alb_target_group.tier3_ntg_was.arn
  target_id = aws_instance.tier3_ec2_pri_2_was.id
  port = 8080
}

