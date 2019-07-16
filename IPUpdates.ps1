Param(
   [parameter(Mandatory=$true, HelpMessage="Enter ResourceGroupName")]
   [string]$ResourceGroupName,
   [parameter(Mandatory=$true, HelpMessage="Enter AppServiceName")]
   [string]$AppServiceName,
   [parameter(Mandatory=$true, HelpMessage="Enter starting priority number")]
   [int]$priority)
   
# priority is no longer set here!
[PSCustomObject]$MicrosoftAvailabilityTestIPWhitelist = @{ipAddress = "20.40.124.176/28"; action = "Allow" ; tag = "Default" ; priority = "351"; name = "MicrosoftAvailabilityTest-AE-1"; description = "AvailabilityTest Server"},`
	@{ipAddress = "20.40.124.240/28"; action = "Allow" ; tag = "Default" ; priority = "352"; name = "MicrosoftAvailabilityTest-AE-2"; description = "AvailabilityTest Server"},`
	@{ipAddress = "20.40.125.80/28"; action = "Allow" ; tag = "Default" ; priority = "353"; name = "MicrosoftAvailabilityTest-AE-3"; description = "AvailabilityTest Server"},`
	@{ipAddress = "52.229.216.48/28"; action = "Allow" ; tag = "Default" ; priority = "354"; name = "MicrosoftAvailabilityTest-EA-1"; description = "AvailabilityTest Server"},`
	@{ipAddress = "52.229.216.64/28"; action = "Allow" ; tag = "Default" ; priority = "355"; name = "MicrosoftAvailabilityTest-EA-2"; description = "AvailabilityTest Server"},`
	@{ipAddress = "52.229.216.80/28"; action = "Allow" ; tag = "Default" ; priority = "356"; name = "MicrosoftAvailabilityTest-EA-3"; description = "AvailabilityTest Server"},`
	@{ipAddress = "20.42.35.32/28"; action = "Allow" ; tag = "Default" ; priority = "357"; name = "MicrosoftAvailabilityTest-EUS-1"; description = "AvailabilityTest Server"},`
	@{ipAddress = "20.42.35.64/28"; action = "Allow" ; tag = "Default" ; priority = "358"; name = "MicrosoftAvailabilityTest-EUS-2"; description = "AvailabilityTest Server"},`
	@{ipAddress = "20.42.35.80/28"; action = "Allow" ; tag = "Default" ; priority = "359"; name = "MicrosoftAvailabilityTest-EUS-3"; description = "AvailabilityTest Server"},`
	@{ipAddress = "20.42.35.96/28"; action = "Allow" ; tag = "Default" ; priority = "360"; name = "MicrosoftAvailabilityTest-EUS-4"; description = "AvailabilityTest Server"},`
	@{ipAddress = "20.42.35.112/28"; action = "Allow" ; tag = "Default" ; priority = "361"; name = "MicrosoftAvailabilityTest-EUS-5"; description = "AvailabilityTest Server"},`
	@{ipAddress = "20.42.35.128/28"; action = "Allow" ; tag = "Default" ; priority = "362"; name = "MicrosoftAvailabilityTest-EUS-6"; description = "AvailabilityTest Server"},`
	@{ipAddress = "40.91.82.48/28"; action = "Allow" ; tag = "Default" ; priority = "363"; name = "MicrosoftAvailabilityTest-WUS-1"; description = "AvailabilityTest Server"},`
	@{ipAddress = "40.91.82.64/28"; action = "Allow" ; tag = "Default" ; priority = "364"; name = "MicrosoftAvailabilityTest-WUS-2"; description = "AvailabilityTest Server"},`
	@{ipAddress = "40.91.82.80/28"; action = "Allow" ; tag = "Default" ; priority = "365"; name = "MicrosoftAvailabilityTest-WUS-3"; description = "AvailabilityTest Server"},`
	@{ipAddress = "40.91.82.96/28"; action = "Allow" ; tag = "Default" ; priority = "366"; name = "MicrosoftAvailabilityTest-WUS-4"; description = "AvailabilityTest Server"},`
	@{ipAddress = "40.91.82.112/28"; action = "Allow" ; tag = "Default" ; priority = "367"; name = "MicrosoftAvailabilityTest-WUS-5"; description = "AvailabilityTest Server"},`
	@{ipAddress = "40.91.82.128/28"; action = "Allow" ; tag = "Default" ; priority = "368"; name = "MicrosoftAvailabilityTest-WUS-6"; description = "AvailabilityTest Server"},`
	@{ipAddress = "52.139.250.96/28"; action = "Allow" ; tag = "Default" ; priority = "369"; name = "MicrosoftAvailabilityTest-SEA-1"; description = "AvailabilityTest Server"},`
	@{ipAddress = "52.139.250.112/28"; action = "Allow" ; tag = "Default" ; priority = "370"; name = "MicrosoftAvailabilityTest-SEA-2"; description = "AvailabilityTest Server"},`
	@{ipAddress = "52.139.250.128/28"; action = "Allow" ; tag = "Default" ; priority = "371"; name = "MicrosoftAvailabilityTest-SEA-3"; description = "AvailabilityTest Server"},`
	@{ipAddress = "52.139.250.144/28"; action = "Allow" ; tag = "Default" ; priority = "372"; name = "MicrosoftAvailabilityTest-SEA-4"; description = "AvailabilityTest Server"}

function Add-AzureIpRestrictionRule
{ 
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        $ResourceGroupName, 

        [Parameter(Mandatory=$true, Position=1)]
        $AppServiceName, 

        [Parameter(Mandatory=$true, Position=2)]
        [PSCustomObject]$rule 
    )

    $ApiVersions = Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Web | 
        Select-Object -ExpandProperty ResourceTypes |
        Where-Object ResourceTypeName -eq 'sites' |
        Select-Object -ExpandProperty ApiVersions

    $LatestApiVersion = $ApiVersions[0]

    $WebAppConfig = Get-AzureRmResource -ResourceType 'Microsoft.Web/sites/config' -ResourceName $AppServiceName -ResourceGroupName $ResourceGroupName -ApiVersion $LatestApiVersion

    $WebAppConfig.Properties.ipSecurityRestrictions =  $WebAppConfig.Properties.ipSecurityRestrictions + @($rule) | 
        Group-Object name | 
        ForEach-Object { $_.Group | Select-Object -Last 1 }

    Set-AzureRmResource -ResourceId $WebAppConfig.ResourceId -Properties $WebAppConfig.Properties -ApiVersion $LatestApiVersion -Force    
}

# Main
write-output 'Adding Rule:'
foreach ($item in $MicrosoftAvailabilityTestIPWhitelist) {
	$rule = [PSCustomObject]@{ipAddress = $item.ipAddress ; action = $item.action ; tag = $item.tag ; priority = $priority.ToString() ; name = $item.name ; description = $item.description } 
	Add-AzureIpRestrictionRule -ResourceGroupName $ResourceGroupName -AppServiceName $AppServiceName -rule $rule
	$priority++
	write-output $item.name.ToString()
} 