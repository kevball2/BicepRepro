Install-WindowsFeature -name Web-Server -IncludeManagementTools
$htmlpage = @"
 <!DOCTYPE html>
 <html>
   <head>
     <title>Azure Test - kevin</title>
   </head>
   <body>
     <h1>Welcome to the Azure Test Web Server!</h1>
     <p>Created by: kevin</p>
   </body>
   </html>
"@
Add-Content -Path "C:\\inetpub\\wwwroot\\index.html" -Value $htmlpage