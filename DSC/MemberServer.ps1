Configuration MemberServer
{
    #Import Modules!
    Import-DscResource -Module xPSDesiredStateConfiguration
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module cWindowscomputer
    Import-DscResource -Module cAzureAutomation
    Import-DscResource -Module xPendingReboot
    Import-DscResource -Module xDSCDomainjoin -ModuleVersion 1.1
    Import-DscResource -Module xWebAdministration
    Import-DscResource -Module cNetworkAdapter
    Import-DscResource -Module cDisk
    Import-DscResource -Module xDisk
    Import-DscResource -Module xWindowsUpdate
#    Import-DscResource -Module xStorage
#    Import-DscResource -Module xNetworking
#    Import-DscResource -Module xActiveDirectory
#    Import-DscResource -Module xComputerManagement


    $SourceDir = 'D:\Source'

    $WorkspaceID = Get-AutomationVariable -Name "_Global-WorkspaceID"
    $DomainJoinCredentialName = Get-AutomationVariable -Name "_Global-DomainJoinCredentialName"
    $DomainName = Get-AutomationVariable -Name "_Global-DomainName"

    $DomainJoinCredential = Get-AutomationPSCredential -Name $DomainJoinCredentialName
    $WorkspaceCredential = Get-AutomationPSCredential -Name $WorkspaceID
    $WorkspaceKey = $WorkspaceCredential.GetNetworkCredential().Password

    $MMARemotSetupExeURI = 'https://go.microsoft.com/fwlink/?LinkID=517476'
    $MMASetupExe = 'MMASetup-AMD64.exe'
    
    $MMACommandLineArguments = 
        '/Q /C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 AcceptEndUserLicenseAgreement=1 ' +
        "OPINSIGHTS_WORKSPACE_ID=$($GlobalVars.WorkspaceID) " +
        "OPINSIGHTS_WORKSPACE_KEY=$($WorkspaceKey)`""


 Node MemberServerDev
    {
            xRemoteFile DownloadMicrosoftManagementAgent
        {
            Uri = $MMARemotSetupExeURI
            DestinationPath = "$($SourceDir)\$($MMASetupExe)"
            MatchSource = $False
        }
        xPackage InstallMicrosoftManagementAgent
        {
             Name = "Microsoft Monitoring Agent"
             Path = "$($SourceDir)\$($MMASetupExE)" 
             Arguments = $MMACommandLineArguments 
             Ensure = 'Present'
             InstalledCheckRegKey = 'SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup'
             InstalledCheckRegValueName = 'Product'
             InstalledCheckRegValueData = 'Microsoft Monitoring Agent'
             ProductID = ''
             DependsOn = "[xRemoteFile]DownloadMicrosoftManagementAgent"
        }
    }
}



