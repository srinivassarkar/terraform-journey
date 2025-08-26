---

# 🌍 Terraform Variables & Locals 

## 1️⃣ Using Variables in Terraform

* **Declare variable** in `variables.tf`:

```hcl
variable "name" {
  type    = string
  default = "world"
}
```

* **Use in resource**:

```hcl
resource "local_file" "hello" {
  content  = "hello, ${var.name}!"
  filename = "hello.txt"
}
```

* **Override at apply**:

```bash
terraform apply -var="name=seenu"
```

---

## 2️⃣ Different Variable Types

### 🔹 String

```hcl
variable "name" {
  type    = string
  default = "bunny"
}
```

### 🔹 Number

```hcl
variable "age" {
  type    = number
  default = 23
}

resource "local_file" "numbers" {
  content  = "I am ${var.name} and I am ${var.age} years old"
  filename = "age.txt"
}
```

### 🔹 Boolean

```hcl
variable "is_weekend" {
  type    = bool
  default = false
}

resource "local_file" "trueOrFalse" {
  content  = "Is it weekend? ${var.is_weekend}"
  filename = "weekend.txt"
}
```

---

## 3️⃣ Multi-line Variables (HEREDOC / EOF)

```hcl
resource "local_file" "multiLine" {
  filename = "multiLine.txt"
  content  = <<EOF
  Hello, I am ${var.name}.
  I am an ${var.job}.
  EOF
}
```

---

## 4️⃣ Locals

* Combine multiple variables:

```hcl
locals {
  intro = "Hello, I am ${var.name}. I am an ${var.job}."
}

resource "local_file" "usingLocals" {
  filename = "usingLocals.txt"
  content  = local.intro
}
```

---

## 5️⃣ Using `.tfvars`

* Create `terraform.tfvars`:

```hcl
name = "seenu"
age  = 24
```

* Terraform will **auto-load** it.

---

## 6️⃣ Conditionals (Ternary)

```hcl
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
```

---

## 7️⃣ Outputs

* View values of variables/locals:

```hcl
output "name" {
  value       = var.name
  description = "this will output the name variable"
}
```

---

⚡ **Key Points to Remember**

* Variables = external input
* Locals = internal computed values
* `.tfvars` = best place for environment-specific values
* Ternary (`? :`) → simple logic handling
* Outputs = visibility of values

---
