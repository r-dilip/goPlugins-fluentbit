<#
.SYNOPSIS
	AI-ICM Connector Script facilitates creation of ICM incidents from Application Insights alerts.
.DESCRIPTION
	The script receives the incoming alert context data from Application Insights. 
	Using the configuration available in the automation account, it forwards it to the appropriate ICM environment to create an equivalent ICM incident. 
	This rubook is dependent on tghe AI-ICM-Connector automation Module which needs to be imported seperately. 
.EXAMPLE
	Create-AIToICMIncident.ps1 -Webhookdata =$object
.NOTES
    AUTHOR: Arun Jolly
    LASTEDIT: Apr 27, 2016
#>
param(
		[object] $WebhookData
	)
	# Getting the configuration from the automation variables
	$icmUrl = Get-AutomationVariable -Name "icmurlProd"
	$tenantId = Get-AutomationVariable -Name "connectorID"
	$certtificateThumbprint = Get-AutomationVariable -Name "certificateThumbprint"
	$certPassword = Get-AutomationVariable -Name "certPassword"
	$severity = Get-AutomationVariable -Name "severity"	
	$correlationID = Get-AutomationVariable -Name "correlationID"
	$routingID = Get-AutomationVariable -Name "routingID"
	$environment = Get-AutomationVariable -Name "environment"
					
	# Exporting the cert to local drive
	$cert = Get-AutomationCertificate -Name 'icmprod'
	$pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2($cert)
	$pfxContentType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx
	[byte[]]$pfxBytes = $pfx.Export($pfxContentType,$certPassword)
	[io.file]::WriteAllBytes('C:\Temp\icmprod.pfx',$pfxBytes)
	cd C:\Temp
	$list = dir
	Write-Output "Exporting Certificate $certtificateThumbprint complete"
	
	# Importing the cert to 'My' certificate store under current user
	[String]$certPath = "C:\Temp\icmprod.pfx"
	[String]$certRootStore = “CurrentUser”
	[String]$certStore = “My”
	$pfxPass = $certPassword
	$pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2
	$pfx.import($certPath,$pfxPass,“Exportable,PersistKeySet”)
	$store = new-object System.Security.Cryptography.X509Certificates.X509Store($certStore,$certRootStore)
	$store.open(“MaxAllowed”)
	$store.add($pfx)
	$store.close()
	
	# Parsing the input data starts here
	Write-Output "WebHook Data received from Application Insights : $WebhookData"
	Import-Module ICMIncidentCreation.dll
	
	# Calling the createICMIncident method on the custom module
	$webHookBody = $WebhookData.RequestBody
	$webHookBody = $webHookBody | Out-String
	Write-Output "Body : $webHookBody"		
	$icmIncident = [ICMIncidentCreation.ICMConnector]::createICMIncident($icmUrl,$tenantId,$certtificateThumbprint,$webHookBody,$severity,$correlationID,$routingID,$environment)	
	Write-Output "ICM Incident : $icmIncident"