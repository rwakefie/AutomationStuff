Configuration OMSAgent
{
#Install-Module xPSDesiredStateConfiguration -MinimumVersion 3.13.0.0
Import-DscResource -ModuleName xPSDesiredStateConfiguration
$OIPackageLocalPath = "C:\MMASetup-AMD64.exe"
$WorkspaceID = Get-AutomationVariable -Name "_Global-WorkspaceID"
$WorkspaceCredential = Get-AutomationPSCredential -Name $WorkspaceID
$WorkspaceKey = $WorkspaceCredential.GetNetworkCredential().Password

Node "MonitoringAgent1.0" {
xRemoteFile OIPackage {
    Uri = "http://download.microsoft.com/download/3/1/7/317DCEEb-5E48-47B0-A849-D8A2B1D7795C/MMASetup-AMD64.exe"
    DestinationPath = $OIPackageLocalPath
    }

Service OIService {
    Name = "HealthService"
    State = "Running"
    DependsOn = "[Package]OI"
    }

PackageOI {
    Ensure= "Present"
    Path = $OIPackageLocalPath
    Name = "Microsoft Monitoring Agent"
    ProductID = "742D699D-56EB-49CC-A04A-317DE01F31CD"
    Arguments = '/Q /C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 AcceptEndUserLicenseAgreement=1 ' +
        "OPINSIGHTS_WORKSPACE_ID=$($WorkspaceID) " +
        "OPINSIGHTS_WORKSPACE_KEY=$($WorkspaceKey)`""
    DependsOn = "[xRemoteFile]OIPackage"
    }
}
}