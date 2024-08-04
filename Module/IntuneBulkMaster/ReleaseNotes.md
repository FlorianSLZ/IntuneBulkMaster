# Release notes for the IntuneBulkMaster Module

## 24.08.04.00
Added functions:
- Remove-AutopilotDeviceByIntuneID
- Remove-IBMprimaryUser
- Set-IBMCorporateOwned
- Set-IBMIntuneDeviceName
- Set-IBMPersonalOwned

Improved functions: 
- Get-IntuneDeviceIDs / Get-IBMIntuneDeviceInfos: 
  - Renamed to Get-IBMIntuneDeviceInfos
  - Added support for nested group memberships
  - Added support for Intune device IDs or all Info output
- In various functions: Added filtering for only supported OS types

## 24.08.01.00
*Initial release* with the following features:
- Connect-IntuneBulkMaster
- Get-IntuneDeviceIDs
- Invoke-IBMcollectDiagnostics
- Invoke-IBMPagingRequest
- Invoke-IBMpauseConfigurationRefresh
- Invoke-IBMReboot
- Invoke-IBMRemediations
- Invoke-IBMremoteLock
- Invoke-IBMrotateBitLockerKeys
- Invoke-IBMrotateFileVaultKey
- Invoke-IBMrotateLAPS
- Invoke-IBMshutDown
- Invoke-IBMSync
