Configuration DomainComputer
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

    $SourceDir = 'D:\Source'
    $GlobalVars = Get-BatchAutomationVariable -Prefix 'zzGlobal' `
                                              -Name @(
        'WorkspaceID',
        'DomainJoinCredentialName',
        'DomainName'
    )

    $DomainJoinCredential = Get-AutomationPSCredential -Name $GlobalVars.DomainJoinCredentialName
    
    $WorkspaceCredential = Get-AutomationPSCredential -Name $GlobalVars.WorkspaceID
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

    $MicrosoftAzureSiteRecoveryUnifiedSetupURI = 'http://aka.ms/unifiedinstaller'
    $ASRSetupEXE = 'MicrosoftAzureSiteRecoveryUnifiedSetup.exe'

    $RetryCount = 20
    $RetryIntervalSec = 30

    $TaniumClientDownloadCredential = Get-AutomationPSCredential -Name 'scotaniumsas'
    $TaniumClientDownloadURI = "https://scotanium.blob.core.windows.net/files/10.0.1.4.17472.6.0.314.1540.0..exe$($TaniumClientDownloadCredential.GetNetworkCredential().password)"
    $TaniumClientExe = '10.0.1.4.17472.6.0.314.1540.0..exe'

    $SysmonZipUri = 'https://download.sysinternals.com/files/Sysmon.zip'
    $SysmonZip = 'Sysmon.zip'
    $SysmonExe = 'Sysmon64.exe'
    $SysmonConfigUri = 'https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml'
    $SysmonConfigXML = 'sysmonconfig-export.xml'
    $SysmonArgs = "-accepteula -i $($SourceDir)\$($SysmonConfigXML)"
    Node MemberServer-1.0
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
        xWindowsUpdateAgent MuSecurityImportant
        {
            IsSingleInstance = 'Yes'
            UpdateNow        = $true
            Category         = @('Security','Important')
            Source           = 'MicrosoftUpdate'
            Notifications    = 'Disabled'
        }
        xRemoteFile DownloadTaniumAgent
        {
            Uri = $TaniumClientDownloadURI
            DestinationPath = "$($SourceDir)\$($TaniumClientExe)"
            MatchSource = $False
        }
        xPackage InstallTaniumClient
        {
             Name = "Tanium Client"
             Path = "$($SourceDir)\$($TaniumClientExe)" 
             Ensure = 'Present'
             InstalledCheckRegKey = 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Tanium Client'
             InstalledCheckRegValueName = 'DisplayVersion'
             InstalledCheckRegValueData = '6.0.314.1540'
             ProductID = ''
             DependsOn = "[xRemoteFile]DownloadTaniumAgent"
        }
        xRemoteFile SysmonZip
        {
            Uri = $SysmonZipUri
            DestinationPath = "$($SourceDir)\$($SysmonZip)"
            MatchSource = $False
        }
        
        # Unpack Sysmon
        Archive UnpackSysmon
        {
            Path = "$($SourceDir)\$($SysmonZip)"
            Destination = $SourceDir
            Ensure = 'Present'
            DependsOn = '[xRemoteFile]SysmonZip'
        }

        xRemoteFile SysmonConfig
        {
            Uri = $SysmonConfigUri
            DestinationPath = "$($SourceDir)\$($SysmonConfigXML)"
            MatchSource = $False
        }

        xPackage InstallSysmon
        {
             Name = "Sysmon"
             Path = "$($SourceDir)\$($SysmonExe)" 
             Arguments = $SysmonArgs
             Ensure = 'Present'
             InstalledCheckRegKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Sysmon/Operational'
             InstalledCheckRegValueName = 'Enabled'
             InstalledCheckRegValueData = 1
             ProductID = ''
             DependsOn = @(
                '[Archive]UnpackSysmon'
                '[xRemoteFile]SysmonConfig'
             )
        }
    }
    Node WebServer-1.0
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
        # Install the IIS role
        WindowsFeature IIS
        {
            Ensure          = 'Present'
            Name            = 'Web-Server'
        }

        # Install the ASP .NET 4.5 role
        WindowsFeature AspNet45
        {
            Ensure          = 'Present'
            Name            = 'Web-Asp-Net45'
        }

        # Stop the default website
        xWebsite DefaultSite 
        {
            Ensure          = 'Present'
            Name            = 'Default Web Site'
            State           = 'Started'
            PhysicalPath    = 'C:\inetpub\wwwroot'
            DependsOn       = '[WindowsFeature]IIS'
        }
        cAzureNetworkPerformanceMonitoring EnableAzureNPM
        {
            Name = 'EnableNPM'
            Ensure = 'Present'
        }
        xWindowsUpdateAgent MuSecurityImportant
        {
            IsSingleInstance = 'Yes'
            UpdateNow        = $true
            Category         = @('Security','Important')
            Source           = 'MicrosoftUpdate'
            Notifications    = 'Disabled'
        }
        xRemoteFile DownloadTaniumAgent
        {
            Uri = $TaniumClientDownloadURI
            DestinationPath = "$($SourceDir)\$($TaniumClientExe)"
            MatchSource = $False
        }
        xPackage InstallTaniumClient
        {
             Name = "Tanium Client"
             Path = "$($SourceDir)\$($TaniumClientExe)" 
             Ensure = 'Present'
             InstalledCheckRegKey = 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Tanium Client'
             InstalledCheckRegValueName = 'DisplayVersion'
             InstalledCheckRegValueData = '6.0.314.1540'
             ProductID = ''
             DependsOn = "[xRemoteFile]DownloadTaniumAgent"
        }
        xRemoteFile SysmonZip
        {
            Uri = $SysmonZipUri
            DestinationPath = "$($SourceDir)\$($SysmonZip)"
            MatchSource = $False
        }
        # Unpack Sysmon
        Archive UnpackSysmon
        {
            Path = "$($SourceDir)\$($SysmonZip)"
            Destination = $SourceDir
            Ensure = 'Present'
            DependsOn = '[xRemoteFile]SysmonZip'
        }

        xRemoteFile SysmonConfig
        {
            Uri = $SysmonConfigUri
            DestinationPath = "$($SourceDir)\$($SysmonConfigXML)"
            MatchSource = $False
        }

        xPackage InstallSysmon
        {
             Name = "Sysmon"
             Path = "$($SourceDir)\$($SysmonExe)" 
             Arguments = $SysmonArgs
             Ensure = 'Present'
             InstalledCheckRegKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Sysmon/Operational'
             InstalledCheckRegValueName = 'Enabled'
             InstalledCheckRegValueData = 1
             ProductID = ''
             DependsOn = @(
                '[Archive]UnpackSysmon'
                '[xRemoteFile]SysmonConfig'
             )
        }
    }
    Node ASR_ManagementServer-1.0
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
        xRemoteFile DownloadAzureSiteRecoveryUnifiedSetup
        {
            Uri = $MicrosoftAzureSiteRecoveryUnifiedSetupURI
            DestinationPath = "$($SourceDir)\$($ASRSetupEXE)"
            MatchSource = $False
        }
        cAzureNetworkPerformanceMonitoring EnableAzureNPM
        {
            Name = 'EnableNPM'
            Ensure = 'Present'
        }
        xWaitforDisk Disk2
        {
                DiskNumber = 2
                RetryIntervalSec =$RetryIntervalSec
                RetryCount = $RetryCount
        }
        cDiskNoRestart ADDataDisk
        {
            DiskNumber = 2
            DriveLetter = 'F'
        }
        xWindowsUpdateAgent MuSecurityImportant
        {
            IsSingleInstance = 'Yes'
            UpdateNow        = $true
            Category         = @('Security','Important')
            Source           = 'MicrosoftUpdate'
            Notifications    = 'Disabled'
        }
        xRemoteFile DownloadTaniumAgent
        {
            Uri = $TaniumClientDownloadURI
            DestinationPath = "$($SourceDir)\$($TaniumClientExe)"
            MatchSource = $False
        }
        xPackage InstallTaniumClient
        {
             Name = "Tanium Client"
             Path = "$($SourceDir)\$($TaniumClientExe)" 
             Ensure = 'Present'
             InstalledCheckRegKey = 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Tanium Client'
             InstalledCheckRegValueName = 'DisplayVersion'
             InstalledCheckRegValueData = '6.0.314.1540'
             ProductID = ''
             DependsOn = "[xRemoteFile]DownloadTaniumAgent"
        }
        xRemoteFile SysmonZip
        {
            Uri = $SysmonZipUri
            DestinationPath = "$($SourceDir)\$($SysmonZip)"
            MatchSource = $False
        }
        # Unpack Sysmon
        Archive UnpackSysmon
        {
            Path = "$($SourceDir)\$($SysmonZip)"
            Destination = $SourceDir
            Ensure = 'Present'
            DependsOn = '[xRemoteFile]SysmonZip'
        }

        xRemoteFile SysmonConfig
        {
            Uri = $SysmonConfigUri
            DestinationPath = "$($SourceDir)\$($SysmonConfigXML)"
            MatchSource = $False
        }

        xPackage InstallSysmon
        {
             Name = "Sysmon"
             Path = "$($SourceDir)\$($SysmonExe)" 
             Arguments = $SysmonArgs
             Ensure = 'Present'
             InstalledCheckRegKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Sysmon/Operational'
             InstalledCheckRegValueName = 'Enabled'
             InstalledCheckRegValueData = 1
             ProductID = ''
             DependsOn = @(
                '[Archive]UnpackSysmon'
                '[xRemoteFile]SysmonConfig'
             )
        }
    }
}
