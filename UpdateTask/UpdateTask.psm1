function Add-UpdateTask {
    <#
            .SYNOPSIS
            This module is designed to schedule Windows Update tasks on our enviroment. 
You will be asked for the administration IP and for the date to schedule the patching Task. 
Please make sure to use the same date format as on the example  
            .Example
            Add-UpdateTasK -IP 172.0.0.0
            .PARAMETER IPAddress
            Enter IP Address.
            .PARAMETER Date
            Enter Date for patching (Example: 11/28/2016 3:30PM).
        
            #>
 
        [cmdletBinding()]  
        param(
            [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
            [string]$IPAddress,
            [string]$Date
            )
    
    
    Invoke-Command -cn $IPAddress   -Credential "" -ScriptBlock {
    Unregister-ScheduledTask -TaskName "Windows Update" -Confirm:$false -ErrorAction Ignore
    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-command "Import-Module -Name PSWindowsUpdate ; Get-WUInstall  –AcceptAll –AutoReboot"'

    $Date=  Read-Host -Prompt 'Enter Date for patching (Example: 11/28/2016 3:30PM).'
    $question1=  Read-Host -Prompt 'Boss, Do you want to set the task to run 2 times in case than an update fails? Plase type Yes or No.'
    
    #$trigger =  New-ScheduledTaskTrigger -Once -At "11/28/2016 3PM"
   if ($question1 -eq "Yes") {
    $Date2=  Read-Host -Prompt 'Enter Date for the Secondadry Patching Task (Example: 11/28/2016 3:30PM).'
    $trigger =  New-ScheduledTaskTrigger -Once -At $Date
    $trigger2 =  New-ScheduledTaskTrigger -Once -At $Date2
    
    Register-ScheduledTask -Action $action -Trigger $trigger,$trigger2 -TaskName "Windows Update" -Description "Run updates from WSUS and reboot once completed" -RunLevel Highest -User "NT AUTHORITY\SYSTEM"
    Write-Output "Scheduling 2 tasks on $IPAddress"
    }
    else {
    $trigger =  New-ScheduledTaskTrigger -Once -At $Date
    
    
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Windows Update" -Description "Run updates from WSUS and reboot once completed" -RunLevel Highest -User "NT AUTHORITY\SYSTEM"
    Write-Output "Scheduling 1 task on $IPAddress"
    }
    Write-Output "Success!!"
    }
}
