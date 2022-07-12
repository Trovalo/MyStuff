param(
    [Parameter(mandatory=$true)] [String] $Domain
)

Try {

Import-Module dbatools

$instance = 'GSVSQL54'
$database = 'DataHub_Staging'
$schema = 'active_directory'
$table = 'Groups_stg'

#Sample -Domain 'ges.ferlan.it'

# Relevant Domains
#'ges.ferlan.it'
#'pista.ges.ferlan.it'
#'gt.ferlan.it'

$properties = @(
     'SamAccountName'
    ,'CanonicalName'
    ,'DistinguishedName'
    ,'Description'
    ,'mail'
    ,'ManagedBy'
    ,'Created'
    ,'GroupCategory'
    ,'GroupScope'
    ,'ObjectGUID'
)

$recordDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

Get-ADGroup -Filter * -server $Domain -Properties $properties |
Select-Object $properties | 
Select-Object *,@{Name = '_SourceDomain';Expression = {$Domain}},@{Name = '_RecordDate';Expression = {$recordDate}} |
Write-DbaDataTable -SqlInstance $instance -Database $database -Schema $schema -Table $table

Exit 0

} Catch {
    Write-Error $Error[0].Exception
    Exit 1
}