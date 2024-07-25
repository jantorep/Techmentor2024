##Paramters

$resource_group="rg-prod-weeu-hcisecureavd"
$location="westeurope"
$hostPoolName="SecureHostPool"
$workspaceName="SecureWorkspace"
$desktopGroupName="Desktop"
$subscription = "1797e81c-6f4a-489f-af93-fa405ff34713"

## Hostpool
$PoolName = $hostPoolName
$PoolResourceGroupName = $resource_group
$PoolHostPoolType = 'Pooled'
$PoolLoadBalancerType = 'DepthFirst'
$PoolPreferredAppGroupType = 'Desktop'
$PoolMaxSessionLimit = '8'
$PoolLocation = $location


## Application Group

$DesktopName = $desktopGroupName
$DesktopResourceGroupName = $resource_group
$DesktopApplicationGroupType = 'Desktop'
$DesktopLocation = $location
$ADGroupName = "AVD Secure HCI"

##User Group Assignment to Application Group

##Login to Azure, remember to select subscription
Login-AzAccount

## Use the following command to select the subscription
Set-AzContext -Subscription $subscription

## Create Resource Group

New-AzResourceGroup -Name $resource_group -Location $location

##Create Hostpool
New-AzWvdHostPool -Name $PoolName -ResourceGroupName $PoolResourceGroupName -Location $PoolLocation -HostPoolType $PoolHostPoolType -LoadBalancerType $PoolLoadBalancerType -PreferredAppGroupType $PoolPreferredAppGroupType -MaxSessionLimit $PoolMaxSessionLimit

##Create Workspace

New-AzWvdWorkspace -Name $workspaceName -ResourceGroupName $resource_group -Location $location

## Create Application Group

$hostPoolArmPath = (Get-AzWvdHostPool -Name $hostPoolName -ResourceGroupName $resource_group).Id


## Desktop Group

New-AzWvdApplicationGroup -Name $DesktopName -ResourceGroupName $DesktopResourceGroupName -ApplicationGroupType $DesktopApplicationGroupType -Location $DesktopLocation -HostPoolArmPath $hostPoolArmPath


#Application Group

New-AzWvdApplicationGroup @parameters

##Add ApplicationGroup to Workspace

# Get the resource ID of the application group you want to add to the workspace
$appGroupPath = (Get-AzWvdApplicationGroup -Name $desktopGroupName -ResourceGroupName $resource_group).Id

# Add the application group to the workspace
Update-AzWvdWorkspace -Name $workspaceName -ResourceGroupName $resource_group -ApplicationGroupReference $appGroupPath


## Assign User to Application Group

$userGroupId = (Get-AzADGroup -DisplayName "AVD Prod HCI").Id

# Assign users to the application group
$parameters = @{
    ObjectId = $userGroupId
    ResourceName = $desktopGroupName
    ResourceGroupName = $resource_group
    RoleDefinitionName = 'Desktop Virtualization User'
    ResourceType = 'Microsoft.DesktopVirtualization/applicationGroups'
}

New-AzRoleAssignment @parameters


## AVD Deployment

##Generate a registration key

$ExpirationTime = $((Get-Date).ToUniversalTime().AddHours(24).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))


New-AzWvdRegistrationInfo -HostPoolName $hostPoolName -ResourceGroupName $resource_group -ExpirationTime $ExpirationTime

## Get the registration token
(Get-AzWvdHostPoolRegistrationToken -HostPoolName $hostPoolName -ResourceGroupName $resource_group).Token


