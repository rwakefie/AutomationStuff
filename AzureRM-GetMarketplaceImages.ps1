$loc = 'EastUS2' #first set a location
#View the templates available
Get-AzureRmVMImagePublisher -Location $loc #check all the publishers available
Get-AzureRmVMImageOffer -Location $loc -PublisherName "MicrosoftWindowsdesktop" #look for offers for a publisher
Get-AzureRmVMImageSku -Location $loc -PublisherName "MicrosoftWindowsdesktop" -Offer "Windows-10" #view SKUs for an offer
Get-AzureRmVMImage -Location $loc -PublisherName "MicrosoftWindowsdesktop" -Offer "Windows-10" -Skus "RS2-Pro" #pick one!