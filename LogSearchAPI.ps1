armclient login
armclient get /subscriptions/1b121d32-fb57-4edb-b0d0-70968c9228c5/resourcegroups/mms-eus/providers/microsoft.operationalinsights/workspaces?api-version=2015-03-20
$mySearch = "{ 'top':150, 'query':'Error'}";
armclient post /subscriptions/1b121d32-fb57-4edb-b0d0-70968c9228c5/resourcegroups/mms-eus/providers/microsoft.operationalinsights/workspaces/09249256-99e5-4c6e-9d7a-3b73e3a90281/search?api-version=2015-03-20 $mySearch


#Search REST API Example
$savedSearchParametersJson =
    {
      '"top":150,"highlight":{"pre":"{[hl]}","post":"{[/hl]}"}',
      '"query":"*","start":"2017-02-04T21:03:29.231Z","end":"2017-02-11T21:03:29.231Z"'
    }
    armclient post /subscriptions/1b121d32-fb57-4edb-b0d0-70968c9228c5/resourcegroups/mms-eus/providers/microsoft.operationalinsights/workspaces/09249256-99e5-4c6e-9d7a-3b73e3a90281/search?api-version=2015-03-20 $searchParametersJson