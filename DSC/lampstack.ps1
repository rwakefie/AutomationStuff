Configuration lampstack
{
Import-DscResource -ModuleName  nx -ModuleVersion 1.0
Import-DscResource -ModuleName nxNetworking -ModuleVersion 1.1

Node "NixWeb1.0" {

nxScript checkapt {
GetScript = @'
#!/bin/bash
apt-get check
'@

SetScript = @'
#!/bin/bash
apt-get update
'@

TestScript = @'
#!/bin/bash
exit 0
'@
}

nxPackage mysql {
    PackageManager = 'apt'
    Ensure = 'Present'
    Name = 'mysql-server'
}

nxPackage php {
    PackageManager = 'apt'
    Ensure = 'Present'
    Name = 'php5-mysql'    
}

nxPackage Apache {
    PackageManager = 'apt'
    Ensure = 'Present'
    Name = 'apache2'
}

nxFile ExampleFile {
    DestinationPath = "/tmp/example"
    Contents = "hello world"
    Ensure = "Present"
    Type = "File"
}

}
}