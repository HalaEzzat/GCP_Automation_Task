# Forescout Task: GCP Automation

### Introduction
In this challenge you will automate a set of tasks on Google Cloud Platform and a Linux (Ubuntu 20.04)
target. You have complete freedom in the technologies you use for the automation. What’s important is
that you justify your choices.

### Terminology
- Google Cloud Platform (GCP): `using the infrastructure as code principals, build an automation capable
to deploy the two instances that will be used later as a controller and target machines.`
- Target: `An ubuntu 20.04 machine that is the ‘target’ of your automation logic. The target machine is not
allowed to reach any resource on the Internet.`
- Controller: `An ubuntu 20.04 machine where your automation is executed from. It connects to the target
to perform the requested actions. `

### Challenge description
- This challenge consists of two step automation:
1. Bring up infrastructure (two machines) on GCP.
2. Automate a simple tcpreplay between the two machines.

### IaC
- The IaC that deploys the instances on GCP must have:
1. Virtual Private Network (VPC);
2. Private and Public IPs;
3. Firewall rules to control the instance access;
4. The instances must be deployed using Ubuntu 20.04 version.
5. Only the controller must have access to the outside world using an SSH keypair.

### Automation
- Given a target machine, the controller should:
1. Disable automatic updates.
2. Configure a ‘dummy’ network interface named ‘replay’ that
- Is not attached to any physical network adapter
- Has no IP address
- Has Promiscuous mode enabled
3. Add a ‘forescout’ user to the system
- An SSH keypair should be generated and configured for this user and used in your
automation if required
- Password-based login should be disabled
- The user should have a minimum set of privileges
4. Copy a small PCAP file to forescout’s user’s home folder, through the controller
- Since our target cannot reach the Internet, the file should first be downloaded to the
controller and then copied to the target.
- The URL of the PCAP file to download should be configurable. The linked PCAP file is an
example you can use

5. Start a long-running ‘tcpreplay’ process that replays the PCAP file on the ‘replay’ interface.
- The PCAP file should be replayed in a loop
- tcpreplay should be running as ‘forescout’ user
6. Start a long-running ‘tcpdump’ process that captures packets from the ‘replay’ interface and
dumps it to a file called ‘capture.pcap’ in the Forescout user’s home folder
- tcpdump should be running as ‘forescout’ user
### As a separate set of commands, it should be possible to
- Retrieve the current size of ‘capture.pcap’
- Remove the ‘capture.pcap’
- Start/stop/restart the tcpdump and tcpreplay processes at any time

## Solution

1. For the infrastructure part ->
- I created 2 terraform resources for the target and controller instances using the image "ubuntu 20.04" .
- I created the necessary vpc networc and subnet and the ingress and egress firwall roles
- added the public key for both machines in the metadata section
- I provisioned the necessary files and prepared the controller environment using remote exec and provesioner 'file' resources to transfer the keys for the 'forescout' user and the playbook and the inventory 
2. For the Automation part
- I created an ansible playbook to do the following on the target machine(host) via the controller(control node):
- Disable automatic updates
- Configure dummy interface
- Add forescout user
- Add forescout user SSH key
- Copy PCAP file to /home/forescout
- using ssh connect to 'forescout' user to:
- tcpreplay the pcap file on the 'replay' interface
- tcpdump oon the 'replay' interface
- get the size of 'capture.pcap'
- remove 'capture.pcap'
- stop/start/restart the tcpdump and tcpreplay processes at any time

Other solutions I though about: Using Packer instead of ansible since I'm already using terraform
Using docker for the tcp replay and tcpdump processes to be able to stop/start/restart any time

## Prerequisite:

### what you need for this to work:

- Terraform
- create gcp project with the right permessions and in terraform.tfvars define values for: `"projectID"`,`"region"`,`"zone"`
- replace the `"credentials.json"` file with yours in 'main.tf'
- generate ssh keys for the instances and add the path to the `variables.tf` file `"ssh_public_key_path"` ,`"ssh_private_key_path"`,`"ssh_user"`
- generate ssh keys for the new user 'forescout' and add them in the `startup/ssh/` folder
- add the privatekey to the `startup` folder too

## Steps:

- after providing the values for the variables
- on the same path of your project run : ```terraform plan ```
- then run : ```terraform apply --auto-approve```
- to destroy run: ```terraform destroy --auto-approve```

## Result:

```
null_resource.configure_target (remote-exec): PLAY [Configure target machine] ************************************************

null_resource.configure_target (remote-exec): TASK [Gathering Facts] *********************************************************
null_resource.configure_target (remote-exec): ok: [target]

null_resource.configure_target (remote-exec): TASK [Disable automatic updates] ***********************************************
null_resource.configure_target: Still creating... [40s elapsed]
null_resource.configure_target: Still creating... [50s elapsed]
null_resource.configure_target: Still creating... [1m0s elapsed]
null_resource.configure_target: Still creating... [1m10s elapsed]
null_resource.configure_target: Still creating... [1m20s elapsed]
null_resource.configure_target: Still creating... [1m30s elapsed]
null_resource.configure_target: Still creating... [1m40s elapsed]
null_resource.configure_target: Still creating... [1m50s elapsed]
null_resource.configure_target: Still creating... [2m0s elapsed]
null_resource.configure_target: Still creating... [2m10s elapsed]
null_resource.configure_target: Still creating... [2m20s elapsed]
null_resource.configure_target: Still creating... [2m30s elapsed]
null_resource.configure_target: Still creating... [2m40s elapsed]
null_resource.configure_target: Still creating... [2m50s elapsed]
null_resource.configure_target: Still creating... [3m0s elapsed]
null_resource.configure_target: Still creating... [3m10s elapsed]
null_resource.configure_target: Still creating... [3m20s elapsed]
null_resource.configure_target: Still creating... [3m30s elapsed]
null_resource.configure_target: Still creating... [3m40s elapsed]
null_resource.configure_target: Still creating... [3m50s elapsed]
null_resource.configure_target: Still creating... [4m0s elapsed]
null_resource.configure_target: Still creating... [4m10s elapsed]
null_resource.configure_target: Still creating... [4m20s elapsed]
null_resource.configure_target: Still creating... [4m30s elapsed]
null_resource.configure_target: Still creating... [4m40s elapsed]
null_resource.configure_target: Still creating... [4m50s elapsed]
null_resource.configure_target: Still creating... [5m0s elapsed]
null_resource.configure_target: Still creating... [5m10s elapsed]
null_resource.configure_target: Still creating... [5m20s elapsed]
null_resource.configure_target (remote-exec): changed: [target]

null_resource.configure_target (remote-exec): TASK [Configure dummy interface] ***********************************************
null_resource.configure_target (remote-exec): changed: [target]

null_resource.configure_target (remote-exec): TASK [Add forescout user] ******************************************************
null_resource.configure_target: Still creating... [5m30s elapsed]
null_resource.configure_target (remote-exec): changed: [target]

null_resource.configure_target (remote-exec): TASK [Add forescout user SSH key] **********************************************
null_resource.configure_target (remote-exec): changed: [target]

null_resource.configure_target (remote-exec): TASK [Add forescout user to the sudoers] ***************************************
null_resource.configure_target (remote-exec): changed: [target]

null_resource.configure_target (remote-exec): TASK [Copy PCAP file to target machine] ****************************************
null_resource.configure_target: Still creating... [5m40s elapsed]
null_resource.configure_target (remote-exec): changed: [target]

null_resource.configure_target (remote-exec): PLAY [replay task] *************************************************************

null_resource.configure_target (remote-exec): TASK [Gathering Facts] *********************************************************
null_resource.configure_target: Still creating... [5m50s elapsed]
null_resource.configure_target (remote-exec): ok: [target]

null_resource.configure_target (remote-exec): TASK [Replay PCAP file] ********************************************************
null_resource.configure_target: Still creating... [6m0s elapsed]
null_resource.configure_target (remote-exec): changed: [target]

null_resource.configure_target (remote-exec): TASK [Start tcpdump on replay interface] ***************************************
null_resource.configure_target (remote-exec): changed: [target]

null_resource.configure_target (remote-exec): TASK [Get size of capture.pcap] ************************************************
null_resource.configure_target (remote-exec): changed: [target]

null_resource.configure_target (remote-exec): TASK [Print capture.pcap size] *************************************************
null_resource.configure_target (remote-exec): ok: [target] => {
null_resource.configure_target (remote-exec):     "capture_size.stdout": "70k\t/home/forescout/capture.pcap"
null_resource.configure_target (remote-exec): }

null_resource.configure_target (remote-exec): PLAY RECAP *********************************************************************
null_resource.configure_target (remote-exec): target                     : ok=12   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


