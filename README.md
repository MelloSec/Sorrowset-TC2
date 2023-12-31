# Sorrowset-TC2

Powershell reads in values, copies template files and replaces what's required to deploy a new C2 teamserver on EC2 and handle post-config with ansible playbooks.

With and Without S3 Backend for Terraform

### Requirements
Need terraform, the azure CLI, the aws CLI. WSL is recommended.

```powershell
choco install terraform -y
choco install awscli -y
choco install az -y
```

Run Deploy.ps1 to generate a keyvault, lock it down, store secrets, handle templating and deploy the server

```powershell
# Define your parameters in a hashtable, pass it to the deploy script. Values will be passed to the sub-scripts by pipeline property name.

# Generate a new Keyvault, read in the DNS secrets and use a local backend to deploy (no $s3enabled, broken right now)
$params = @{
    # BUCKET = "mrbucket"
    # BUCKETKEY = "sorrowsettc2"
    # BUCKETREGION = "us-east-1"
    # BUCKETENDPOINT = "nyc3"
    EC2NAME = "sorrowsettc2"
    EC2SIZE = "t2.micro"
    USERNAME = "bosshog"
    AZREGION = "east-us"
    VAULTNAME = "sorrowsettc2"
    VAULTGROUP = "sorrowsettc2"
    genKeyVault = $true
    DOMAINNAME = "phishery"
    DOMAINSUFFIX = "org"
    SSH_PUBLIC_KEY_LOCATION = "~\.ssh\id_rsa.pub"
    s3enabled = $false   
}
.\Deploy.ps1 @params
```

### Ansible, copy the key you used to the root directory of WSL (working on it sorry)
### From .\Deploy
```powershell
$WINDOWSUSER = "Administrator"
wsl sudo cp /mnt/c/Users/$WINDOWSUSER/.ssh/id_rsa /root/.ssh/id_rsa
wsl sudo chmod 600 /root/.ssh/id_rsa
wsl sudo ansible-galaxy install --roles-path ~/roles -r requirements.yml
wsl export ANSIBLE_CONFIG=ansible.cfg
wsl sudo ansible-playbook -i ./inventory.yml deploy.yml
```

## Features

- Spin up Operator VM on AWS
  
- Terraform to create server, networking and users
  
- Ansible to further configure, install Docker/Compose, containers , tools, configure services



#### [ _Terraform Overview_ ]


###### 1. Terraform reaches out to AWS APIs and provisions a VPC, subnets, project tags.
- Parameters:  `EC2NAME` `SSH_PUBLIC_KEY_LOCATION`


###### 2. Terraform calls the AMI search module to turn our specs into the correct AMI ID
- Parameters: `EC2SIZE`


###### 3. Terraform calls the SSH keypair module to create an AWS keypair from yout public key
- `public_key = file("${var.SSH_PUBLIC_KEY_LOCATION}")`


###### 4. Terraform configures Security Group module and opens up the firewall
- Current public IP addres is passed to `ingress_with_cidr_blocks`


###### 5. Terraform calls sorrowset_EC2 Module and builds our server
- wooo!


###### 5. Terraform runs shell code, updates VM, creates ansible user, adds keys, passwordless sudo
- Change it if you want a different `ansible` user


#### [ _Ansible Overview_ ]


###### 1. Ansible kicks off with `deploy.yml` 

- `deploy.yml` Gathers facts and installs the role `requirements.yml` (or optionally installs them to the local path of the project) for the project. It sets variables for the Kasm installation, and kicks off installing those roles in that order.


###### 2. Ansible works the `inventory.yml` 

- Sets the python interpreter, SSH/authorized keys, user/permissions and groups, pip/docker options and timezone to be used as the roles deploy


###### 3. Ansible installs roles

- Ansible starts doing the work installing the roles using the variables set in the inventory.
- weareinteractive.users = Users/Groups/Keys
- geerlingguy.pip, geerlingguy.ntp = Handles pip and NTP
- geerlingguy.security = Mostly SSH security. Auto-updates, fail2ban, etc
- viasite-ansible.zsh = installs zsh
- docker = Checks for Docker, Installs clean with Compose
- os = upgrade, locale, swap partition, etc


 
<!-- ###### Update, install ansible, terraform, aws



```sh
# Install ansible
sudo apt install -y ansible

# Install terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Install AWS cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
``` -->

<!-- ###### 2. Make your mods to `main.tf`, `inventory.yml`, `providers.tf`, `variables.tf`

 See above '_What Terraform's Doing_'

###### 3. Configure AWS cli with your Access Key and Secret Access Key from the AWS management console
`
aws configure
`

###### 4. Initialize Terraform project, Plan and Apply Changes
See how your plan looks, then tell terraform to spin it up.

```
terraform init
terraform plan
terraform apply --auto-approve
```

###### 5. Take the output IP address and put it into the host name under `inventory.yml`

```
terraform output
```

###### 6. Customize first run deployment by comment/uncomment roles under `deploy.yml`  -->

###### Run the terraform / deploy.yml playbook manually
```bash
ansible-galaxy install -r requirements.yml
ansible-playbook deploy.yml

export DO_PAT=""

terraform apply -auto-approve -var "do_token=${DO_PAT}"
terraform destroy -auto-approve -var "do_token=${DO_PAT}"

terraform apply 2>&1 | tee apply.txt


$Env:TF_LOG = "TRACE"
terraform apply 2>&1 | Tee-Object -FilePath apply.txt

terraform apply -auto-approve -var "do_token=${DO_PAT}" -var "zt_token=${ZEROTIER_CENTRAL_TOKEN}"


ansible-galaxy install --roles-path ~/roles -r requirements.yml

export ANSIBLE_CONFIG=ansible.cfg
ansible-playbook -i inventory deploy.yml
```
