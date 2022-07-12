param(
    [Parameter(mandatory=$true)] [String] $Domain
)

Try {

Import-Module dbatools
#Sample -Domain 'ges.ferlan.it'

$instance = 'GSVSQL54'
$database = 'DataHub_Staging'
$schema = 'active_directory'
$table = 'Domains_stg'

# Relevant Domains
#'ges.ferlan.it'
#'pista.ges.ferlan.it'
#'gt.ferlan.it'

$properties = @(
     'DistinguishedName'
    ,'DNSRoot'
    ,'Name'
    ,'NetBIOSName' 
    ,'ObjectGUID'
)

$recordDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

$data = Get-ADDomain -Server $Domain | 
Select-Object $properties | 
Select-Object *,@{Name = '_SourceDomain';Expression = {$Domain}},@{Name = '_RecordDate';Expression = {$recordDate}} |
Write-DbaDataTable -SqlInstance $instance -Database $database -Schema $schema -Table $table

Exit 0

} Catch {
    Write-Error $Error[0].Exception
    Exit 1
}
# 1. Get-ADUser returns requested attribute + object related attributes
# 2. the first Select-Object filters out all the non required attributes
# 3. the second Select-Object adds two fixed columns (_SourceDomain and _RecordDate), needed for tracking
# 4. Write to DB using dbatools