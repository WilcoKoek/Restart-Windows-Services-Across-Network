# Restart-Windows-Services-Across-Network
With this Powershell script you can restart Windows Services Across the network.
I use this PowerShell script for restarting Dynamics NAV Windows services but you can use it for other Windows services to.
Use of this PowerShell script is at your own risk!


REMARKS
 - If Windows Service already has the state set with $SetStatus than the output ACTION will be 'Nothing'.
 - If $SkipDisabledDelay = 'True' en $StartType = 'Disabled' then the output ACTION wil be 'Skipped'.
 - If the Windows Service can't be stopped PowerShell will raise an error. Check if Windows Service can be manually stopped.

USAGE
 1. Set parameter $filterservicenames, multiple filters posible.
 2. Set parameter $NavServers, multiple filters posible.
 3. Set parameter $SetStartupType, posible options: Automatic, Manual, Disabled). Use '' if no changes/actions have to be made.
 4. Set parameter $SetStatus, posible options: Start, Stop. Use '' if no changes/ations have to be made.
 5. Set parameter $SetServiceStartDelay in (seconden). Put a delay between starting of services.
 6. Set parameter $SkipDisabledServices, posible options: True, False. Use '' if no changes/actions have to be made.


TODO
[ ] $service.StartType -eq 'Disabled' doesn't work to all remote servers.
[ ] Only execute $SetStartupType if startup type is not equal to parameter.
[ ] Make code more readable by: creating functions, split in to multiple files, etc.