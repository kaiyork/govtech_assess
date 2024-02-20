# govtech_assess

# Required Items For Carrying out the Assessment
1. Amazon VPC 
2. EC2 instance
3. nginx
4. chocolatey as a package handler for terraform
5. terraform used for creation of all aws resources 

# CIDR retrieve
1. python code was written to showcase the logic of doing CIDR retrive from the REST API provided.

# VPC Creation
1. VPC of size /16s created accounting for the 5 subnets of size /24 (3 public 2 private)created.
2. VPC subnets are spread accross 3 availbility zones to help ensure availiblity of the VPC.
3. Nat and internet gateways are attached to the vpc to allowed resources to access the net.
4. SSH authentication was set up , ssh key required to connect into ec2 instance.
5. AN elastic load balancer was set up to evenly forward traffic between the 3 public subnets.
6. Cloudwatch alarms were added to monitor cpu utilisation of EC2.
7. template file created to auto configure nginx server on ec2 instance.
8. Security group rules was added for ingress and egress traffic



