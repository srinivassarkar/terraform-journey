# Goal: one VPC, N public + N private subnets (per AZ), IGW, 1 NAT (cost-aware), RTs wired.

```
What cooked:

VPC with DNS support
2 Public Subnets (with auto-assign public IP)
2 Private Subnets
Internet Gateway for public internet access
2 NAT Gateways (one per AZ for high availability)
Route Tables properly configured
Elastic IPs for NAT gateways
Comprehensive outputs for reuse

Key Features:

Uses cidrsubnet() function for automatic subnet calculation
Proper dependency management with depends_on
Multi-AZ setup for high availability
Comprehensive tagging strategy```