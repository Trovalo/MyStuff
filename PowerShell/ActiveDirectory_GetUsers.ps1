param(
    [Parameter(mandatory=$true)] [String] $Domain
)

Try {

Import-Module dbatools

$instance = 'GSVSQL54'
$database = 'DataHub_Staging'
$schema = 'active_directory'
$table = 'Users_stg'

#Sample -Domain 'ges.ferlan.it'

# Relevant Domains
#'ges.ferlan.it'
#'pista.ges.ferlan.it'
#'gt.ferlan.it'

$properties = @(
     'Company'
    ,'SamAccountName'
    ,'Name'
    ,'GivenName'
    ,'Surname'
    ,'DistinguishedName'
    ,'UserPrincipalName'
    ,'Department'
    ,'Description'
    ,'Manager'
    ,'ExtensionAttribute11'
    ,'Mail'
    ,'Created'
    ,'Enabled'
    ,'AccountExpirationDate'
    ,'LastLogonDate'
    ,'Office'
    ,'ObjectGUID'
    ,'Title'
)

# Date format required for converison to SSIS datatype DT_DBTIMESTAMP
$RecordDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

Get-ADUser -Filter * -server $Domain -Properties $properties | 
Select-Object $properties | 
Select-Object *,@{Name = '_SourceDomain';Expression = {$Domain}},@{Name = '_RecordDate';Expression = {$RecordDate}} |
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
