---
# 😃

`terraform fmt` 스타일을 맞춰준다.(띄어쓰기나 괄호위치)











***

<details>
  <summary><strong>locals, data, variable<strong></summary>
    
```
resource "local_file" "hi" {
  filename = "${local.path}/hellss"
  content  = local.dken
}

locals {
  name = "terraform"
  dken = "kdsfknk"
  path = path.module
}
```
`locals` 은 밑에 반복될만한 내용을 내가 원하는 이름으로 정의한다.

`data` 는 외부에서 데이터를 가져오는 느낌.
***
```
locals {
  ami = "ami-0123456789abcdef0"
}

resource "aws_instance" "web" {
  ami = local.ami
  instance_type = "t2.micro"
  region = var.region
}
```
`locals` 를 이용한 예
***
```
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners = ["099720109477"]
}

resource "aws_instance" "web" {
  ami = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"
  region = var.region
}
```
`data` 를 이용한 예
***
```
variable "ami" {
  default = "ami-0123456789abcdef0"
}

resource "aws_instance" "web" {
  ami = var.ami
  instance_type = "t2.micro"
  region = var.region
}
```
`variable` 를 이용한 예
***
| 특징     | 범위           | 값 할당                                      | 사용                                          |
|:--------:|:-------------:|:--------------------------------------------:|:---------------------------------------------:|
| locals   | 모듈 내부      | `locals { 변수명 = "값" }`                    | 모듈 내부에서만 사용 가능                      |
| data     | 전역           | `data.<TYPE>.<NAME>.<PROPERTY>`               | 리소스 속성, 모듈 입력, 계획 옵션 등에서 사용 가능 |
| variable | 전역           | `variable "변수명" = "값"`                    | 리소스 속성, 모듈 입력, 계획 옵션 등에서 사용 가능 |
***
</details>


