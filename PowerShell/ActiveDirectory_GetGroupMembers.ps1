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
#IsCriticalSystemObject helps to identify builtin/default groups. (which will be excluded)
$groupList = Get-ADGroup -Properties Members,IsCriticalSystemObject -Filter * -Server $Domain | Where-Object {$_.Members.count -gt 0 -and !($_.IsCriticalSystemObject)}

foreach($group in $groupList) {
    try {
        $result += Get-ADGroupMember -Identity $group.DistinguishedName -Server $Domain | ForEach-Object {
        New-Object psobject -property @{
            GroupObjectGUID = $group.ObjectGUID
            MemberObjectGUID = $_.ObjectGUID
            MemberObjectClass = $_.ObjectClass
            _SourceDomain = $Domain
            _RecordDate = $recordDate
        }}
    } catch {
        Write-Warning "Error While processing Group: $($group.SamAccountName), Error: $($_.Exception.ServerErrorMessage)"
        Continue
    }
}

Write-DbaDataTable -SqlInstance $instance -Database $database -Schema $schema -Table $table -InputObject $result

Exit 0

} Catch {
    Write-Error $Error[0].Exception
    Exit 1
}