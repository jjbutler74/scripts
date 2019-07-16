# scripts
Miscellaneous scripts and code

# IPUpdates.ps1
Changes to MS Availability Testing
https://azure.microsoft.com/en-us/blog/march-2019-changes-to-azure-monitor-availability-testing/
Means that new IPs may need to be white listed
https://docs.microsoft.com/en-us/azure/azure-monitor/app/ip-addresses#availability-tests
Modfiy script with IPs needed and run, example:
.\IPUpdates.ps1 -ResourceGroupName RG-ACME-Prod -AppServiceName ldp-prod-acmeewebhookapi -priority 310
