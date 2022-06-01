# Deploy a Production Ready self hosted, highly available Kubernetes Cluster with Kubespray

This purpose of this article is to automate the process of setting up a Kubernetes cluster.

We chose to use Kubespray to deploy our Kubernetes cluster. Kubespray is a composition of [Ansible](https://docs.ansible.com/) playbooks, [inventory](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ansible.md), provisioning tools, and domain knowledge for generic OS/Kubernetes clusters configuration management tasks. Kubespray provides:

* a highly available cluster
* composable attributes
* support for most popular Linux distributions
  * Ubuntu 16.04, 18.04, 20.04
  * CentOS/RHEL/Oracle Linux 7, 8
  * Debian Buster, Jessie, Stretch, Wheezy
  * Fedora 31, 32
  * Fedora CoreOS
  * openSUSE Leap 15
  * Flatcar Container Linux by Kinvolk
* continuous integration tests

To choose a tool which best fits your use case, read [this comparison](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/comparisons.md) to
[kubeadm](/docs/reference/setup-tools/kubeadm/) and [kops](/docs/setup/production-environment/tools/kops/).

## Installing Kubernetes with Kubespray on AWS

In this guide we will show how to deploy Kubernetes with Kubespray on AWS.

### Installing dependencies

Before deploying, we will need a virtual machine (hereinafter Jumpbox) with all the software dependencies installed. Check the list of distributions supported by Kubespray and deploy the Jumpbox with one of these distributions. Make sure to have the latest version of Python installed. Next, the dependencies from requirements.text in Kubespray’s GitHub repo must be installed.

```console
sudo pip install -r requirements.txt
```

Lastly, install Terraform by HashiCorp. Simply download the latest version of Terraform according to your distribution and install it to your /usr/local/bin folder. For example:

```console
wget https://releases.hashicorp.com/terraform/0.12.23/terraform_0.12.23_linux_amd64.zip

unzip terraform_0.12.23_linux_amd64.zip

sudo mv terraform /usr/local/bin/
```

### Building a cloud infrastructure with Terraform

Since Kubespray does not automatically create virtual machines, we need to use Terraform to help provision our infrastructure. 

To start, we create an SSH key pair for Ansible on AWS.

![Generate AWS Keypair](https://www.altoros.com/blog/wp-content/uploads/2020/03/Creating-SSH-key-pairs.png)

The next step is to clone the Kubespray repository into our jumpbox. 

```console
git clone https://github.com/sdb-cloud-ops/ss-k8s-kubespray.git
```

The Terraform scripts have been modified not to expose sensitive data such as credentials. We are instead using AWS profiles.

We then enter the cloned directory and copy the credentials.

```console
cd kubespray/contrib/terraform/aws/
cp credentials.tfvars.example credentials.tfvars
```

After copying, fill out credentials.tfvars with our AWS credentials.

```console
vim credentials.tfvars
```

In this case, the AWS credentials were as follows.

```markdown
> **Note:** We are only specifying the region and key name in this case.
```

```console
# #AWS Access Key
# AWS_ACCESS_KEY_ID = ""
# #AWS Secret Key
# AWS_SECRET_ACCESS_KEY = ""
#EC2 SSH Key Name
AWS_SSH_KEY_NAME = "kube-ansible"
#AWS Region
AWS_DEFAULT_REGION = "us-east-1"
```

Below is an example AWS Profile. If you would like to learn more about working with multiple named AWS profiles, check [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html).

```console
cd ~/.aws
cat config
```
```markdown
[default]
region = us-east-1
output = json

[admin]
region = us-east-1
output = json
```

```console
cd ~/.aws
cat config
```

```markdown
[default]
aws_access_key_id = accesskeyidfordefaultprofile
aws_secret_access_key = secretkeyfordefaultprofile
aws_session_token =  tokenfordefaultprofileifexists

[admin]
aws_access_key_id = accesskeyidforadminprofile
aws_secret_access_key = secretkeyforadminprofile
aws_session_token = tokenforadminprofileifexists
```
Once AWS profile is setup we need to set the profile that we want to Terraform to work with.

```console
export AWS_PROFILE=admin
echo $AWS_PROFILE
```
````markdown
admin
````
