# govtech_assess

# tech_project

# Required Items For Carrying out the Assessment
1. Amazon VPC 
2. EC2 instance
3. putty (if on windows os)
4. nginx
5. set up rules for the github repo such that requires approval for commits , to protect the main branch
6. chocolatey as a package handler for terraform
7. terraform
9. dockler

# VPC Creation
VPC of size /22 was created ,to account for the 4 subnets of size /24 created
VPC subnets are spread accross 2 availbility zones to help ensure availiblity of the VPC
nat gateways are attached to the vpc to allowed resources to access the net
