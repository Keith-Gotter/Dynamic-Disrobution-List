$Datamaster = ".\TestData.CSV"
$GetDataMaster = Import-Csv -path $Datamaster
$GetDataEmployee = $GetDataMaster | Where-object {$_.CurrentEmployee -EQ "Y"}
$GetDataTemp = $GetDataMaster | Where-Object {$_.CurrentEmployee -EQ "Temp"}
$UniqueDepartments = ".\UniqueDepartments.CSV"
$PremExchangeConnectionURL = "Connect Info"
$NewListOU = "Add The Ou you want to New Distrubution lists to go to"


$CheckValue = @() 
$CheckDLValue = @()


#Connect to On Prem Exchange.
$ExOnPremPSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $PremExchangeConnectionURL -Authentication Kerberos
$TestConnection = Import-PSSession $ExOnPremPSession -AllowClobber

#Getting All Unique Cest Centers in a CSV

$NewData = $GetDataMaster | Where-Object {$_.Department -Ne $null} | Select-Object Department
ForEach ($item in $NewData)
    {
        If($CheckValue -like $Item)
            {
                continue
            }
        else 
            {
                $CheckValue += $Item
            }
    }

    #Exporting Unique Costcenters to a CSV 

    $CheckValue | Export-CSV $UniqueDepartments

    #Converting EachObject in $CheckValue to Strings and Getting rid of the Spaces.


#This isnt working. May have to create an Array.
foreach($item in $CheckValue)
    {
        $OutputToString = Out-String -InputObject $Item.Department
        $OutputToString = $OutputToString.Replace(" ","")
        $DLFormatting = "DL-$OutputToString"
        #$GetNewName = $DLFormatting | ConvertFrom-String -PropertyNames Name
        #$GetNewNameObject = $GetNewName.P1 
        $CheckDLValue += $DLFormatting
        
    }

    foreach($item in $CheckDLValue)
    {   
        $TrimmedItem = $item.trim()
        $DLCheck = Get-DistributionGroup -Identity $item

        If($null -eq $DLCheck)
        {
            New-DistributionGroup -Name $TrimmedItem -Type "Security" -OrganizationalUnit $NewListOU -WhatIf
            $CountDLCreation = "True"
        }

    }

If($CountDLCreation -EQ "True")
    {
        start-Sleep -seconds 1200
    }
