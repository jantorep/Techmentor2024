
##Parameters

##Comon Parameters

$subscription="1797e81c-6f4a-489f-af93-fa405ff34713"
$resource_group="rg-lab-weeu-fahci-ias-cl01"
$customLocationName = "fahciiascl01customlocation"
$location="westeurope"


#StoragePath Parameters

$storagepathname="fahci-ias-01a"
$path="c:\ClusterStorage\fahci-ias-01a"

##Image Parameters
$osType = "Windows"
$VMimagename = "Windows 11, version 22H2 Enterprise multi-session + Microsoft 365 Apps (Preview) - Gen2"
$Publishername = "microsoftwindowsdesktop"
$Offer = "office-365"
$SKU = "win11-22h2-avd-m365"
$Versionnumber = "22621.382.220810"

##Logical Network Parameters

$lnetName = "ProdAVD"
$vmSwitchName = '"ConvergedSwitch(compute_management)"'
$addressPrefixes = "10.0.83.0/24"
$gateway = "10.0.83.1"
$dnsServers = "10.0.80.10 10.0.80.11"

#Network Interface Parameters

$lnetName = "myhci-lnet-static"
$gateway ="10.0.83.1" 
$ipAddress ="10.0.83.31" 
$nicName ="myhci-nic-static"

#Login and Set Subscription
az login --use-device-code

az account set --subscription $subscription

$customLocationID=(az customlocation show --resource-group $resource_group --name $customLocationName --query id -o tsv)

#List Image and find the one you want, and fill in the information under the Image Parameters
az vm image list --publisher "microsoftwindowsdesktop" --all --output table

az vm image list --publisher "microsoftwindowsdesktop"  --offer $Offer --all --output table

az vm image list --publisher "microsoftwindowsdesktop"  --sku "win11-24h2-entn" --all --output table


## 1. Create StoragePath

az stack-hci-vm storagepath create --resource-group $resource_group --custom-location $customLocationID --name $storagepathname --path $path

az stack-hci-vm storagepath List --resource-group $resource_group

##1. Create Image from Marketplace


az stack-hci-vm image create --subscription $subscription --resource-group $resource_group --custom-location $customLocationID --location $location --name $VMimagename --os-type $ostype --offer $Offer --publisher $Publishername --sku $SKU --version $Versionnumber --storage-path-id $storagepathid

### List VM Images

az stack-hci-vm image list --subscription $subscription --resource-group $resource_group


## 3. Create Logical Network

##Set Static IP Address for Logical Network
az stack-hci-vm network lnet create --subscription $subscription --resource-group $resource_group --custom-location $customLocationID --location $location --name $lnetName --vm-switch-name $vmSwitchName --ip-allocation-method "Static" --address-prefixes $addressPrefixes --gateway $gateway --dns-servers 10.0.80.10 10.0.80.11


## Set DHCP IP Address for Logical Network
az stack-hci-vm network lnet create --subscription $subscription --resource-group $resourceGroup --custom-location $customLocationID --location $location --name $lnetName --vm-switch-name $vSwitchName --ip-allocation-method "Dynamic"

##4. Create Network Interface
