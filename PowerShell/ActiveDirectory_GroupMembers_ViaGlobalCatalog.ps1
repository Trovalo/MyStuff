## This script works even if there are orpahn users inside the group (which will be excluded).
## Orpahn users make Get-AdGroupMember throw an exception and no user is fetched at all, 
## error ref: While trying to resolve a cross-store reference, the SID of the target principal could not be resolved.  The error code is 1332.
param(
    [Parameter(mandatory=$true)] [String] $Domain
)

Try {

Import-Module dbatools

$instance = 'GSVSQL54'
$database = 'DataHub_Staging'
$schema = 'active_directory'
$table = 'GroupMembers_stg'

#Sample -Domain 'ges.ferlan.it'

# Relevant Domains
#'ges.ferlan.it'
#'pista.ges.ferlan.it'
#'gt.ferlan.it'

$result = @()
$recordDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
##Objects inside groups can be from any domain,l therefore the global catalog must be used. Port 3268 must be specified to use the GC service
#$GlobalCatalog = Get-ADDomainController -Discover -ForceDiscover -Service GlobalCatalog ## Get automatically
$GlobalCatalog = "GDCNET13:3268" ## GlobalCatalogPort
$groupList = Get-ADGroup -Properties Members -Filter * -Server $Domain | Where-Object {$_.Members.count -gt 0}
   
foreach($group in $groupList) {

	$result += Get-ADObject -LDAPFilter "(memberOf=$($group.DistinguishedName))" -Server $GlobalCatalog | ForEach-Object {
	    New-Object psobject -property @{
			GroupObjectGUID = $group.ObjectGUID
			MemberObjectGUID = $_.ObjectGUID
			MemberObjectClass = $_.ObjectClass
			_SourceDomain = $Domain
			_RecordDate = $recordDate
	    }
	}
}

Write-DbaDataTable -SqlInstance $instance -Database $database -Schema $schema -Table $table -InputObject $result

Exit 0

} Catch {
    Write-Error $Error[0].Exception
    Exit 1
}
