
#>
function Get-IMSPorts{
    Begin{
        
        try{
            Get-Module -Name Posh-Shodan >> $null
        }
        catch{
            Write-Output "Posh-Shodan Module Required"
            return
        }    
        $pass = ConvertTo-SecureString -String 'jXxlPPekKHr2ib@'
        Set-ShodanAPIKey -APIKey uFBgPY1LlzCVGZUqIYnH8mEay1wcV0n1 -MasterPassword $pass
        $ip = '50.204.64.233','50.204.64.234','50.204.64.235','50.204.64.236','50.204.64.237','50.204.64.238'
    }
    Process{
       $ip | ForEach-Object {Get-ShodanHostService -IPAddress $_  | select IP_str, ports} 
    }
}