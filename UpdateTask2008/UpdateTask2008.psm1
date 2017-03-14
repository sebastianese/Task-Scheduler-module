function Add-UpdateTask2008 {
    <#
            .SYNOPSIS
            Creates Windows update schedule task  
            .Example
            Get-TaskCreated -computername localhost
            .PARAMETER IPAddress
            Enter IP Address.
        
            #>
        [cmdletBinding()]
        param(
            [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
            [string]$IPAddress
            )
    



    Invoke-Command -cn $IPAddress  -Credential "" -ScriptBlock {
    # The name of the scheduled task
    $TaskName = "Windows Update"
    # The description of the task
    $TaskDescr = "Download and install WSUS updates. Automatically reboot system"
    # The Task Action command
    $TaskCommand = "Powershell.exe"
    # The PowerShell script to be executed
    $TaskScript = '-command "Import-Module -Name PSWindowsUpdate ; Get-WUInstall  –AcceptAll –AutoReboot"'
    # The Task Action command argument
    $TaskArg = "$TaskScript"

    # The time when the task starts, for demonstration purposes we run it 1 minute after we created the task
    #$TaskStartTime = $([char]34)+$Date+"T"+$Time+$([char]34)

 


    # attach the Task Scheduler com object
    $service = new-object -ComObject("Schedule.Service")
    # connect to the local machine. 
    # http://msdn.microsoft.com/en-us/library/windows/desktop/aa381833(v=vs.85).aspx
    $service.Connect()
    $rootFolder = $service.GetFolder("\")

    $TaskDefinition = $service.NewTask(0) 
    $TaskDefinition.RegistrationInfo.Description = "$TaskDescr"
    $TaskDefinition.Settings.Enabled = $true
    $TaskDefinition.Settings.AllowDemandStart = $true

    $triggers = $TaskDefinition.Triggers
    #http://msdn.microsoft.com/en-us/library/windows/desktop/aa383915(v=vs.85).aspx
    $trigger = $triggers.Create(1) # Creates a "One time" trigger
    #$trigger.StartBoundary = $TaskStartTime.ToString("yyyy-MM-dd'T'HH:mm:ss")
    #$trigger.StartBoundary = "2016-10-28T15:35:00"
    $trigger.StartBoundary =  Read-Host -Prompt 'Enter date and time for task on format yyyy-MM-ddTHH:mm:ss (Example: 2016-10-28T09:35:00 )'
    $trigger.Enabled = $true

    # http://msdn.microsoft.com/en-us/library/windows/desktop/aa381841(v=vs.85).aspx
    $Action = $TaskDefinition.Actions.Create(0)
    $action.Path = "$TaskCommand"
    $action.Arguments = "$TaskArg"

    #http://msdn.microsoft.com/en-us/library/windows/desktop/aa381365(v=vs.85).aspx
    $rootFolder.RegisterTaskDefinition("$TaskName",$TaskDefinition,6,"System",$null,5)
    }
}