$webhookurl = 'https://s2events.azure-automation.net/webhooks?token=[secrettoken]'

$body = @{"LastName" = "Stranger"; "FirstName" = "Stefan"}

$params = @{
    ContentType = 'application/json'
    Headers = @{'from' = 'Stefan Stranger'; 'Date' = "$(Get-Date)"}
    Body = ($body | convertto-json)
    Method = 'Post'
    URI = $webhookurl
}

Invoke-RestMethod @params -Verbose
