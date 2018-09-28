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
	$severity = Get-AutomationVariable -Name "severity"	
	$correlationID = Get-AutomationVariable -Name "correlationID"
	$routingID = Get-AutomationVariable -Name "routingID"
	$environment = Get-AutomationVariable -Name "environment"
	
	$connectionName = "AzureRunAsConnection"
	
	try 
	{
		# Get the connection "AzureRunAsConnection "
		$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName
		
		"Logging in to Azure..."
		Login-AzureRmAccount `
			-ServicePrincipal `
			-TenantId $servicePrincipalConnection.TenantId `
			-ApplicationId $servicePrincipalConnection.ApplicationId `
			-CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
	}
	catch 
	{
		if (!$servicePrincipalConnection)
		{
			$ErrorMessage = "Connection $connectionName not found."
			throw $ErrorMessage
		} else{
			Write-Error -Message $_.Exception
			throw $_.Exception
		}
	}

	# Exporting the cert to local drive
	$vaultName = 'ininprodmonitoring' 
	$secretName = "ai-icm-connector" 
    "Getting keyvault secret..."
	$kvSecret =  Get-AzureKeyVaultSecret -VaultName $vaultName -SecretName $secretName
    
	$kvSecretBytes = [System.Convert]::FromBase64String($kvSecret.SecretValueText)
	$x509Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($kvSecretBytes, "", "Exportable")
	$certificateThumbprint = $x509Cert.Thumbprint
	$certificateThumbprint

	$fileName = "C:\Temp\icmprod.pfx"
	[System.IO.File]::WriteAllBytes($fileName, $kvSecretBytes)
	Push-Location -Path Cert:\CurrentUser\My
	Import-PfxCertificate -Password (ConvertTo-SecureString "MyPassword" -AsPlainText -Force) -FilePath $fileName
	Pop-Location
	
	# # Parsing the input data starts here
	Write-Output "WebHook Data received from Application Insights : $WebhookData"
	Import-Module ICMIncidentCreation.dll
	
	# Calling the createICMIncident method on the custom module
	$webHookBody = $WebhookData.RequestBody
	$webHookBody = $webHookBody | Out-String
	Write-Output "Body : $webHookBody"		
	$icmIncident = [ICMIncidentCreation.ICMConnector]::createICMIncident($icmUrl,$tenantId,$certificateThumbprint,$webHookBody,$severity,$correlationID,$routingID,$environment)	
	Write-Output "ICM Incident : $icmIncident"