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

    $ADMVersion = '9.0.3'
    $ADMRemotSetupExeURI = 'https://go.microsoft.com/fwlink/?LinkId=698625'
    $ADMSetupExe = 'ADM-Agent-Windows.exe'
    $ADMCommandLineArguments = '/S'


 Node MemberServer1.0
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
        xRemoteFile DownloadAppDependencyMonitor
        {
            Uri = $ADMRemotSetupExeURI
            DestinationPath = "$($SourceDir)\$($ADMSetupExe)"
            MatchSource = $False
        }
        xPackage InstallAppDependencyMonitor
        {
             Name = "Application Dependency Monitor"
             Path = "$($SourceDir)\$($ADMSetupExE)" 
             Arguments = $ADMCommandLineArguments 
             Ensure = 'Present'
             InstalledCheckRegKey = 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\DependencyAgent'
             InstalledCheckRegValueName = 'DisplayVersion'
             InstalledCheckRegValueData = $ADMVersion
             ProductID = ''
             DependsOn = "[xRemoteFile]DownloadMicrosoftManagementAgent"
        }
        xPendingReboot Reboot2
        { 
            Name = "RebootServer2"
            DependsOn = "[xPackage]InstallAppDependencyMonitor"
        }
        xDSCDomainjoin JoinDomain
        {
            Domain = $GlobalVars.DomainName
            Credential = $DomainJoinCredential
        }
        cAzureNetworkPerformanceMonitoring EnableAzureNPM
        {
            Name = 'EnableNPM'
            Ensure = 'Present'
        }
    }
}



