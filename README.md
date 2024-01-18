---
# 😃

<details>
  <summary><strong>terraform 유용한 명령어<strong></summary>

  ***
    
`terraform fmt` 스타일을 맞춰준다.(띄어쓰기나 괄호위치)

  </details>

***

<details>
  <summary><strong>locals, data, variable<strong></summary>

  ***
    
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

***

<details>
  <summary><strong>variable 타입에 따른 반복문<strong></summary>

  ***
    
```
variable "name" {
  type    = list(string)
  default = ["abc", "bcd", "cde"]
}

resource "local_file" "hello" {
  for_each = toset(var.name)                          
  filename = "${path.module}/${each.value}.txt"
  content  = each.key
}

variable "map" {
  type    =  map(string)
  default = {
    "map1" = "map11111111111",
    "map2" = "map222222222222",
    "map3" = "map333333333333"
  }
}

resource "local_file" "mapmap" {
  for_each = var.map
  filename = "${path.module}/${each.key}.txt"
  content  = each.value
}
```
`for_each` 를 선언해야 `each.key` 와 `each.value` 를 사용할 수 있다.
</details>

***

<details>
  <summary><strong>variable로 파일 경로 지정<strong></summary>

***

```
resource "local_file" "mapmap" {
  for_each = var.map
  filename = "${path.module}/${each.key}.txt"
  content  = each.value
}

variable "path" {
  default = "path.module"
}

resource "local_file" "pathpath" {
  filename = "${var.path}/hello/path.txt"   
  content = var.path                      # path.module/hello/path.txt 파일이 생김김
}                                         # 내용은 path.module
```

***

</details>
  



