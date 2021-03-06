<#
.Synopsis
   
   Scans a host or network for the MS17-010 vulnerability

.DESCRIPTION
   This script will use a custom NMap NSE script to scan a destination host on
   port 445 for the MS17-010 vulnerability. If the host is not online or is blocking
   SMB, this script will report no vulnerabilities.
   
   Requirements:
    You must have Nmap installed with the MS17-010 NSE script in the scripts folder.
    Both can be downloaded below:

    NSE: https://github.com/cldrn/nmap-nse-scripts/blob/master/scripts/smb-vuln-ms17-010.nse
    Invoke-WebRequest https://github.com/cldrn/nmap-nse-scripts/blob/master/scripts/smb-vuln-ms17-010.nse | Out-File "C:\Program Files (x86)\Nmap\scripts\smb-vuln-ms17-010.nse"
    NMap: https://nmap.org/download.html

.EXAMPLE
   Get-MS17010 10.1.1.1

    System      Vulnerable
   ------      ----------
   10.1.1.1    VULNERABLE

.EXAMPLE
   Get-MS17010 10.1.1.0/24

    System      Vulnerable
   ------      ----------
   10.1.1.1    VULNERABLE
   10.1.1.2    VULNERABLE
   10.1.1.3    VULNERABLE
#>
[CmdletBinding()]
[Alias()]
Param
(
    # Destination host or network
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    $Destination
)    
Begin{
    
    $ErrorActionPreference='Stop'

    # Check to see if NMap is installed before continuing
    try { 
        nmap --help | out-null
    } catch {
        Write-Error "Nmap not installed"
    }
}
Process{
    $var = nmap -d -sC -p445 --open --max-hostgroup 3 --script smb-vuln-ms17-010.nse $Destination
    
    $i=0
    $indexed=@()
    foreach($line in ($var -split "`r`n")){ 
    
        if($line -match "Nmap scan report for|State:"){
            if($line -match "Nmap scan report for") { 
                $i++
            }
            $indexed += "$i-$line`r"
        }
    }

    # Create a table object
    $table = New-Object system.Data.DataTable "Results"

    # Create table
    $cols = @("System","Vulnerable")
    
    # Schema (columns)
    foreach ($col in $cols) {
        $table.Columns.Add($col) | Out-Null
    }
    if($indexed.count -gt 1){
        for ($i = 1; $i -lt $indexed.Length; $i++){ 
            if($indexed[$i] -match "State:"){ 
                $row = $table.NewRow()
                $row.System = "$($indexed[$i-1] -replace '^[0-9]+-Nmap scan report for ', '')"
                $row.Vulnerable = "$($indexed[$i] -replace '[0-9]+-\|     State: ','')"
                $table.Rows.Add($row)
            }
        }
    } else {
        Write-Output "No vulnerabilities found on this host or network."
    }
}
End{
    # return the table of results from the function
    $table
}