# Data-Driven Infrastructure

## VPC Module - Advanced for_each Pattern
## This demonstrates data-driven infrastructure where resources are created based on input maps


## 🔍 Key Advanced Concepts:

## 1. for_each with Maps vs. count:
```
count = 2 → Creates [0], [1] - fragile to changes
for_each = map → Creates {"name" = resource} - stable references
```


## 2. Cross-Resource Referencing:

```
hclvpc_id = aws_vpc.this[each.value.vpc_name].id
```

This is how resources find each other in a for_each world!

## 3. Dynamic Blocks:

```
hcldynamic "route" {
  for_each = each.value.routes
  content { ... }
}
```
Creates nested blocks programmatically!

## 4. Complex Variable Types:
```
map(object({...})) - Structured data
optional() - Optional fields with defaults
list(object({...})) - Lists of complex objects
```


## 5. Data-Driven Infrastructure:

Infrastructure defined by data structures
No hardcoded resource counts
Infinitely flexible and reusable


```
🏗️ Project Structure:
vpc-module/
├── main.tf           # Resource definitions
├── variables.tf      # Input variable schemas
├── outputs.tf        # Output definitions
└── terraform.tfvars  # Example configuration
```

## 🚀 Why This Approach is Superior:

#### Scalable: Add more VPCs/subnets by just adding map entries
#### Maintainable: Clear separation between logic and data
#### Reusable: Same module works for dev, staging, prod
#### Type-Safe: Terraform validates your input structure

---