# resource "local_file" "hello" {
#   content  = "hello,world!"
#   filename = "hello.txt"
# }

//what if i want to say hello to someone else? 
//we can use variables for that

# variable "name" {
#   type    = string
#   default = "world"
# }
# resource "local_file" "hello" {
#   content  = "hello,${var.name}!"
#   filename = "hello.txt"
# }

//now try running the apply command again but this time using the variable 
// terraform apply -var="name=seenu"

//what if i want to use numbers along with names? 
//lets use the number type in vars 

# variable "age" {
#   type    = number
#   default = 23
# }

# resource "local_file" "numbers" {
#   content  = "I am ${var.name} and I am ${var.age} years old"
#   filename = "age.txt"
# }

//now try running the apply command again but this time using both the variables
// terraform apply -var="name=seenu" -var="age=24"


//what if i want to user true or false values?
//we can user boolean type in vars for that 

# variable "is_weekend" {
#   type    = bool
#   default = false

# }

# resource "local_file" "trueOrFalse" {
#   content  = "Is it weekend? ${var.is_weekend}"
#   filename = "weekend.txt"

# }


//what if i want to use mutliple lines with mutliple variables?
//we use EOF for that 

variable "name" {
  type        = string
  description = "this variable is used to store name"
  default     = "bunny"
}

variable "job" {
  type        = string
  description = "this variable is used to store job profile"
  default     = "engineer"

}

resource "local_file" "multiLine" {
  filename = "multiLine.txt"
  content  = <<EOF
  Hello, I am ${var.name}.
  I am an ${var.job}.
  EOF
}


//you can also use locals for combining multiple variables 

locals {
  intro = "Hello, I am ${var.name}. I am an ${var.job}."
}
resource "local_file" "usingLocals" {
  filename = "usingLocals.txt"
  content  = local.intro
}

//you can also override the default values in vars using a tfvars file

//you can add simple logics using conditionals like ternary operators

variable "environment" {
  type    = string
  default = "dev"
}

locals {
  instance_type = var.environment == "prod" ? "true" : "false"
}

resource "local_file" "usingConditionals" {
  filename = "usingConditionals.txt"
  content  = "Is this a production environment? ${local.instance_type}"
}

//what if you want to see the values of the variables or locals?
//we you can use output for that

output "name" {
  value       = var.name
  description = "this will output the name variable"
}