$webhookurl = 'https://s1events.azure-automation.net/webhooks?token=5grRyU9%2b6%2bkOnQRZpnfHDwn5UmxSwt%2bMzVrL9rmJbdI%3d'

$params = @{
    ContentType = 'application/json'
    Method = 'Post'
    URI = $webhookurl
}

Invoke-RestMethod @params -Verbose