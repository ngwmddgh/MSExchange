<#

DistGrpExpd.ps1 / ngwmddgh / 2018-05-13

Expands all the different types of Exchange distribution groups to get a fully recursed list.
Useful if you nest a lot of groups within groups for robust RBAC.

Credit to AdamJ for writing most of this, I just ElseIf'd two more group types he omitted:
https://community.spiceworks.com/scripts/show/2702-distribution-group-expander

#>
$saveto = "C:\\Temp\\Distribution Groups.txt"
filter get_member_recurse {
    if($_.RecipientType -eq "MailUniversalDistributionGroup") {
        Get-DistributionGroupMember -ResultSize "Unlimited" $_.Name | get_member_recurse
    } 
	elseif($_.RecipientType -eq "MailUniversalSecurityGroup") {
        Get-DistributionGroupMember -ResultSize "Unlimited" $_.Name | get_member_recurse
    }
	elseif($_.RecipientType -eq "MailNonUniversalGroup") {
        Get-DistributionGroupMember -ResultSize "Unlimited" $_.Name | get_member_recurse
    }
	else {
	$output = $_.Name + " (" + $_.PrimarySMTPAddress + ")"
	Write-Output $output
    }
} 
$DistributionGroup = Get-DistributionGroup | Sort-Object Name | ForEach-Object {
    "`r`n$($_.DisplayName) ($($_.PrimarySMTPAddress))`r`n=============" | Add-Content $saveto
    $distout = Get-DistributionGroupMember -ResultSize "Unlimited" $_.Name | get_member_recurse
    Write-Output $distout | Sort-Object | Get-Unique  | Add-Content $saveto
}