# ACI-Workshop

ACI workshop for experimenting with open source configuration management tools

## Rough Guide to Git

Download git [here](https://git-scm.com/downloads)

Clone this repository:

```shell
git clone https://github.com/niksheridan/ACI-Workshop.git
```

When someone else makes a change

```shell
git pull
```

Its a topic in it's own right.

## Get Terraform

Download terraform [here](https://www.terraform.io/downloads.html).

Note it is a single binary, so you may need to declare the path where
you run it e.g.

```powershell
.\terraform.exe init
.\terraform.exe plan
```

## Text Editor

VS code gets the job done find it [here](https://code.visualstudio.com/Download), entirely your choice.

## Try it and Assess the outcome

Note the syntax may depend on your operating system

```shell
git clone https://github.com/niksheridan/ACI-Workshop.git
cd aci
terraform init
terraform apply --auto-approve
```
