param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Revision,

    [Parameter(Mandatory=$false, Position=1)]
    [string]$Version
)

$Arguments = @(
  "--filename-max-length=999"
  "--signoff"
  "$Revision^1..$Revision"
)

if ($Version) {
    $Arguments += "-v$Version"
}

git format-patch $Arguments
