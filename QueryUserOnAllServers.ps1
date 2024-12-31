# Prompt for domain and username
$domain = Read-Host -Prompt "Enter the domain"
$username = Read-Host -Prompt "Enter the username"

# Combine domain and username
$fullUsername = "$domain\\$username"

# Get the list of all enabled servers in the domain
$servers = Get-ADComputer -Filter {OperatingSystem -Like "*Server*" -and Enabled -eq $true} | Select-Object -ExpandProperty Name

foreach ($server in $servers) {
    try {
        # Use Invoke-Command to run the query on each server
        $result = Invoke-Command -ComputerName $server -ScriptBlock {
            param ($fullUsername)
            $user = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName
            if ($user -eq $fullUsername) {
                return $true
            } else {
                return $false
            }
        } -ArgumentList $fullUsername

        if ($result) {
            Write-Output "$fullUsername is logged in on ${server}"
        } else {
            Write-Output "$fullUsername is not logged in on ${server}"
        }
    } catch {
        Write-Output "Failed to query ${server}: $_"
    }
}