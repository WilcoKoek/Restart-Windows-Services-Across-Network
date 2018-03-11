cls

IF (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Throw 'PowerShell not started with Administrator priviledges!'
}

# Set-ExecutionPolicy -ExecutionPolicy Unrestricted

# 2016-12-23 WK     : Initial version
# 2018-03-11 WK     : Code added to GitHub

# REMARKS
#  - If Windows Service already has the state set with $SetStatus than the output ACTION will be 'Nothing'.
#  - If $SkipDisabledDelay = 'True' en $StartType = 'Disabled' then the output ACTION wil be 'Skipped'.
#  - If the Windows Service can't be stopped PowerShell will raise an error. Check if Windows Service can be manually stopped.

# USAGE
#  1. Set parameter $filterservicenames, multiple filters posible.
#  2. Set parameter $NavServers, multiple filters posible.
#  3. Set parameter $SetStartupType, posible options: Automatic, Manual, Disabled). Use '' if no changes/actions have to be made.
#  4. Set parameter $SetStatus, posible options: Start, Stop. Use '' if no changes/ations have to be made.
#  5. Set parameter $SetServiceStartDelay in (seconden). Put a delay between starting of services.
#  6. Set parameter $SkipDisabledServices, posible options: True, False. Use '' if no changes/actions have to be made.

# PARAMETERS
$filterservicenames   = ,('MicrosoftDynamicsNavServer$<replacewithservicename>*')
#$filterservicenames += ,('MicrosoftDynamicsNavServer$<replacewithservicename>*')

$NavServers   = ,('<replacewithservername>')
#$NavServers += ,('<replacewithservername>')


$SetStartupType       = ''
$SetStatus            = 'start'
$SetServiceStartDelay = ''
$SkipDisabledServices = 'true'

# CODE
$Output  = ,('SERVER ,WINDOWS SERVICE ,STARTUP TYPE ,STATUS ,ACTION ')

foreach ($NavServer in $NavServers)
{ #10-
    foreach ($filterservicename in $filterservicenames)
    { #20-
        $services = Get-service -Name $filterservicename -ComputerName $NavServer -ErrorAction SilentlyContinue

        foreach ($service in $services)
        { #30-
            If ($SkipDisabledServices -eq 'True' -and $service.StartType -eq 'Disabled')
            { #40-
                cls
                $Output += ,($NavServer + ',' + $Service.Name + ',' + $service.StartType + ',' + $service.Status + ',Skipped')
                convertfrom-csv -InputObject $Output | Format-Table -AutoSize -Wrap                    
            }
            ELSE
            {            
                # SET SERVICE STARTUP TYPE TO AUTOMATIC
                If ($SetStartupType -eq 'Automatic')
                {
                    Set-Service $service.Name -startuptype 'Automatic' -ComputerName $NavServer

                    cls
                    $Output += ,($NavServer + ',' + $Service.Name + ',' + $service.StartType + ',' + $service.Status + ',To Automatic')
                    convertfrom-csv -InputObject $Output | Format-Table -AutoSize -Wrap
                }

                # SET SERVICE STARTUP TYPE TO MANUAL
                If ($SetStartupType -eq 'Manual')
                {
                    Set-Service $service.Name -startuptype 'Manual' -ComputerName $NavServer

                    cls
                    $Output += ,($NavServer + ',' + $Service.Name + ',' + $service.StartType + ',' + $service.Status + ',To Manual')
                    convertfrom-csv -InputObject $Output | Format-Table -AutoSize -Wrap
                }

                # SET SERVICE STARTUP TYPE TO DISABLED
                If ($SetStartupType -eq 'Disabled')
                {
                    Set-Service $service.Name -startuptype 'Disabled' -ComputerName $NavServer

                    cls
                    $Output += ,($NavServer + ',' + $Service.Name + ',' + $service.StartType + ',' + $service.Status + ',To Disabled')
                    convertfrom-csv -InputObject $Output | Format-Table -AutoSize -Wrap
                }

                # START THE SERVICE            
                If ($SetStatus -eq 'Start')
                {
                    If ($service.Status -eq 'Stopped' -and $service.StartType -ne 'Disabled') # Disabled Services can not be started!
                    {
                        ($service).Start()

                        Do
                        {
                            Timeout 1 | Out-Null
                            $service = Get-service -Name $service.Name -ComputerName $NavServer
                        } While ($service.Status -ne 'Running')
                
                        cls
                        $Output += ,($NavServer + ',' + $Service.Name + ',' + $service.StartType + ',' + $service.Status + ',Service started')
                        convertfrom-csv -InputObject $Output | Format-Table -AutoSize -Wrap

                        If ($SetServiceStartDelay -ne '')
                        {
                            'Services wil be started with a Delay of ' + $SetServiceStartDelay + ' Seconds...'
                            Timeout $SetServiceStartDelay | Out-Null
                        }
                    }
                    Else
                    {
                        cls
                        $Output += ,($NavServer + ',' + $Service.Name + ',' + $service.StartType + ',' + $service.Status + ',Nothing')
                        convertfrom-csv -InputObject $Output | Format-Table -AutoSize -Wrap
                    }
                }
            } #40+
            # STOP THE SERVICE (ALWAYS!)
            If ($SetStatus -eq 'Stop' -or $SetStartupType -eq 'Disabled')
            {
                If ($service.Status -eq 'Running') # Disabled Services can be stopped, if not already!
                {
                    ($service).Stop()
                    
                    Do
                    {
                        Timeout 1 | Out-Null
                        $service = Get-service -Name $service.Name -ComputerName $NavServer
                    } While ($service.Status -ne 'Stopped')
                    
                    cls
                    $Output += ,($NavServer + ',' + $Service.Name + ',' + $service.StartType + ',' + $service.Status + ',Service stopped')
                    convertfrom-csv -InputObject $Output | Format-Table -AutoSize -Wrap
                }
                Else
                {
                    cls
                    $Output += ,($NavServer + ',' + $Service.Name + ',' + $service.StartType + ',' + $service.Status + ',Nothing')
                    convertfrom-csv -InputObject $Output | Format-Table -AutoSize -Wrap
                }
            }
        } #30+
    } #20+
    # GIVE NICE OUTPUT
    If ($services.Count -ne 0)
    {
        cls
        $Output += ,(',,,,')
        convertfrom-csv -InputObject $Output | Format-Table -AutoSize -Wrap
    }
} #10+

# SHOW CHOOSEN PARAMETERS
'PARAMETERS'
'==============================================='
'$filterservicenames:'
$filterservicenames
'==============================================='
'$NavServers:'
$NavServers
'==============================================='
'SetStartupType       :' + $SetStartupType
'SetStatus            :' + $SetStatus
'SetServiceStartDelay :' + $SetServiceStartDelay 
'SkipDisabledServices :' + $SkipDisabledServices

Write-Host