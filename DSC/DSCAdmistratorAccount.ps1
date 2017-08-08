Configuration AdministratorAccount
{
    #Import Modules!
    #Import-DscResource -Module xPSDesiredStateConfiguration


    Node AdministratorAccount-1.0
    {
        User Administrator
        {
            Ensure = "Present"  # To ensure the user account does not exist, set Ensure to "Absent"
            UserName = "Administrator"
            Description = "This is the local admin account"
            Disabled = $True
            PasswordNeverExpires = $True
        }
    }
}