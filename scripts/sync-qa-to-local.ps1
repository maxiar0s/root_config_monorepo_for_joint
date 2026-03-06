param(
  [string]$EnvFilePath = '.env.dev'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Load-DotEnv {
  param([string]$FilePath)

  if (-not (Test-Path -Path $FilePath)) {
    throw "No se encontro el archivo de entorno: $FilePath"
  }

  $values = @{}
  foreach ($line in Get-Content -Path $FilePath) {
    $trimmed = $line.Trim()
    if ($trimmed.Length -eq 0 -or $trimmed.StartsWith('#')) {
      continue
    }

    $parts = $trimmed.Split('=', 2)
    if ($parts.Count -ne 2) {
      continue
    }

    $key = $parts[0].Trim()
    $value = $parts[1].Trim().Trim('"').Trim("'")
    $values[$key] = $value
  }

  return $values
}

function Get-ConfigValue {
  param(
    [hashtable]$EnvValues,
    [string]$Primary,
    [string]$Fallback = ''
  )

  if ($EnvValues.ContainsKey($Primary) -and $EnvValues[$Primary]) {
    return $EnvValues[$Primary]
  }

  if ($Fallback -and $EnvValues.ContainsKey($Fallback) -and $EnvValues[$Fallback]) {
    return $EnvValues[$Fallback]
  }

  return ''
}

function Assert-Command {
  param([string]$CommandName)

  if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
    throw "No se encontro '$CommandName' en PATH. Instala MySQL Client y vuelve a intentar."
  }
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$envFileAbsolute = Resolve-Path (Join-Path $repoRoot $EnvFilePath)
$envValues = Load-DotEnv -FilePath $envFileAbsolute

$qaHost = Get-ConfigValue -EnvValues $envValues -Primary 'QA_DB_HOST'
$qaPort = Get-ConfigValue -EnvValues $envValues -Primary 'QA_DB_PORT'
$qaName = Get-ConfigValue -EnvValues $envValues -Primary 'QA_DB_NAME'
$qaUser = Get-ConfigValue -EnvValues $envValues -Primary 'QA_DB_USERNAME'
$qaPassword = Get-ConfigValue -EnvValues $envValues -Primary 'QA_DB_PASSWORD'

$localHost = Get-ConfigValue -EnvValues $envValues -Primary 'LOCAL_DB_HOST' -Fallback 'DB_HOST'
$localPort = Get-ConfigValue -EnvValues $envValues -Primary 'LOCAL_DB_PORT' -Fallback 'DB_PORT'
$localName = Get-ConfigValue -EnvValues $envValues -Primary 'LOCAL_DB_NAME' -Fallback 'DB_NAME'
$localUser = Get-ConfigValue -EnvValues $envValues -Primary 'LOCAL_DB_USERNAME' -Fallback 'DB_USERNAME'
$localPassword = Get-ConfigValue -EnvValues $envValues -Primary 'LOCAL_DB_PASSWORD' -Fallback 'DB_PASSWORD'

$missing = @()
if (-not $qaHost) { $missing += 'QA_DB_HOST' }
if (-not $qaPort) { $missing += 'QA_DB_PORT' }
if (-not $qaName) { $missing += 'QA_DB_NAME' }
if (-not $qaUser) { $missing += 'QA_DB_USERNAME' }
if (-not $qaPassword) { $missing += 'QA_DB_PASSWORD' }
if (-not $localHost) { $missing += 'LOCAL_DB_HOST/DB_HOST' }
if (-not $localPort) { $missing += 'LOCAL_DB_PORT/DB_PORT' }
if (-not $localName) { $missing += 'LOCAL_DB_NAME/DB_NAME' }
if (-not $localUser) { $missing += 'LOCAL_DB_USERNAME/DB_USERNAME' }
if (-not $localPassword) { $missing += 'LOCAL_DB_PASSWORD/DB_PASSWORD' }

if ($missing.Count -gt 0) {
  throw "Faltan variables requeridas en ${envFileAbsolute}: $($missing -join ', ')"
}

Assert-Command -CommandName 'mysqldump'
Assert-Command -CommandName 'mysql'

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$dumpFile = Join-Path $env:TEMP "qa_dump_$timestamp.sql"

Write-Host "Exportando QA (${qaHost}:${qaPort}/${qaName})..."
$previousMysqlPwd = $env:MYSQL_PWD

try {
  $env:MYSQL_PWD = $qaPassword
  & mysqldump -h $qaHost -P $qaPort -u $qaUser --single-transaction --routines --triggers --set-gtid-purged=OFF $qaName > $dumpFile
  if ($LASTEXITCODE -ne 0) {
    throw "mysqldump fallo con codigo $LASTEXITCODE"
  }

  Write-Host "Recreando base local (${localHost}:${localPort}/${localName})..."
  $env:MYSQL_PWD = $localPassword
  & mysql -h $localHost -P $localPort -u $localUser -e "DROP DATABASE IF EXISTS \`$localName\`; CREATE DATABASE \`$localName\`;"
  if ($LASTEXITCODE -ne 0) {
    throw "No se pudo recrear la base local. Codigo $LASTEXITCODE"
  }

  Write-Host 'Importando dump en base local...'
  $importCommand = "mysql -h $localHost -P $localPort -u $localUser $localName < `"$dumpFile`""
  cmd.exe /c $importCommand
  if ($LASTEXITCODE -ne 0) {
    throw "Importacion fallo con codigo $LASTEXITCODE"
  }

  Write-Host 'Listo. Migracion QA -> local completada.'
}
finally {
  if ($null -eq $previousMysqlPwd) {
    Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue
  }
  else {
    $env:MYSQL_PWD = $previousMysqlPwd
  }

  if (Test-Path -Path $dumpFile) {
    Remove-Item -Path $dumpFile -Force
  }
}
