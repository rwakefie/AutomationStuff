Configuration AdministratorAccount
{
    #Import Modules!
    #Import-DscResource -Module xPSDesiredStateConfiguration


    Node localhost
    {
        User Administrator
        {
            Ensure = "Present"  # To ensure the user account does not exist, set Ensure to "Absent"
            UserName = "Administrator"
            Description = "This is the local admin account"
            Disabled = $False
            PasswordNeverExpires = $True
        }
        User Guest
        {
            Ensure = "Present"  # To ensure the user account does not exist, set Ensure to "Absent"
            UserName = "Guest"
            Description = "This is the local guest account"
            Disabled = $True
            PasswordNeverExpires = $True
        }

    }
}