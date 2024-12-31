# Prompt for domain and username
$domain = Read-Host -Prompt "Enter the domain"
$username = Read-Host -Prompt "Enter the username"

# Combine domain and username
$fullUsername = "$domain\\$username"

# Get the list of all enabled servers in the domain
$servers = Get-ADComputer -Filter {OperatingSystem -Like "*Server*" -and Enabled -eq $true} | Select-Object -ExpandProperty Name

foreach ($server in $servers) {
    try {
        # Use Invoke-Command to run the cmdkey command on each server
        $result = Invoke-Command -ComputerName $server -ScriptBlock {
            cmdkey /list
        }

        Write-Output "Cached credentials on ${server}:"
        Write-Output $result

        # Check if the specified username is in the cached credentials
        if ($result -match $fullUsername) {
            Write-Output "$fullUsername found in cached credentials on ${server}"
        } else {
            Write-Output "$fullUsername not found in cached credentials on ${server}"
        }
    } catch {
        Write-Output "Failed to query ${server}: $_"
    }
}