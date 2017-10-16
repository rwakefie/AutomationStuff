Configuration MemberServer
{
    #Import Modules!
    Import-DscResource -Module xPSDesiredStateConfiguration
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module xPendingReboot
    Import-DscResource -Module xDSCDomainjoin -ModuleVersion 1.1

    $SourceDir = 'D:\Source'

    $WorkspaceID = Get-AutomationVariable -Name "WorkspaceID"
    $WorkspaceKey = Get-AutomationVariable -Name "WorkspaceKey"
    $DomainJoinCredentialName = Get-AutomationVariable -Name "DomainJoinCredentialName"
    $DomainName = Get-AutomationVariable -Name "DomainName"
    $DomainJoinCredential = Get-AutomationPSCredential -Name $DomainJoinCredentialName

    $MMARemotSetupExeURI = 'https://go.microsoft.com/fwlink/?LinkID=517476'
    $MMASetupExe = 'MMASetup-AMD64.exe'
    
    $MMACommandLineArguments = 
        '/Q /C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 AcceptEndUserLicenseAgreement=1 ' +
        "OPINSIGHTS_WORKSPACE_ID=$($WorkspaceID) " +
        "OPINSIGHTS_WORKSPACE_KEY=$($WorkspaceKey)`""

 Node DesktopConfig
    {
        File SourceFolder
        {
            DestinationPath = $($SourceDir)
            Type = 'Directory'
            Ensure = 'Present'
        }
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
        xPendingReboot Reboot1
        { 
            Name = "RebootServer"
            DependsOn = "[xPackage]InstallMicrosoftManagementAgent"
        }
        xDSCDomainjoin JoinDomain
        {
            Domain = $DomainName
            Credential = $DomainJoinCredential
        }
    }
}



