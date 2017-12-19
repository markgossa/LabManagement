$cred = Get-Credential root 
Connect-VIServer -Server 192.168.0.3 -Credential $cred -Force -WarningAction SilentlyContinue | Out-Null
$TestLabVMs = 'litdc01','litex01','litex02','litex03'

function WaitforVMShutdown
{
    param ($VM)
    while ((Get-VM -Name $VM).PowerState -ne 'PoweredOff')
    {
        Start-Sleep 1
    }
}

function WaitforVMTaskCompletion
{
    param ($VM)
    while (Get-Task -Status Running | Where-Object {$_.ObjectId -eq (Get-VM -Name $VM).Id})
    {
        Start-Sleep 1
    }
}

function New-LabSnapshot
{
    Stop-VMGuest -VM $TestLabVMs -Confirm:$false
    $TestLabVMs | ForEach-Object {WaitforVMShutdown -VM $_}
    $TestLabVMs | ForEach-Object {New-Snapshot -VM $_ -Name 'Before Exchange install'}
    $TestLabVMs | ForEach-Object {WaitforVMTaskCompletion -VM $_}
    Start-VM -VM $TestLabVMs
}

# Prepare lab by taking a new snapshot
New-LabSnapshot

# Work on lab 

# Roll back if needed
