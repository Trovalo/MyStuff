param(
    [Parameter(mandatory=$true)] [String] $Domain
)

Try {

Import-Module dbatools

$instance = 'GSVSQL54'
$database = 'DataHub_Staging'
$schema = 'active_directory'
$table = 'Computers_stg'

#Sample -Domain 'ges.ferlan.it'

# Relevant Domains
#'ges.ferlan.it'
#'pista.ges.ferlan.it'
#'gt.ferlan.it'

$properties = @(
     'CanonicalName'
    ,'CN'
    ,'Created'
    ,'Description'
    ,'DistinguishedName'
    ,'DNSHostName'
    ,'Enabled'
    ,'LastLogonDate'
    ,'Name'
    ,'OperatingSystem'
    ,'ObjectGUID'
)

$recordDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

Get-ADComputer -Filter * -server $Domain -Properties $properties |
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