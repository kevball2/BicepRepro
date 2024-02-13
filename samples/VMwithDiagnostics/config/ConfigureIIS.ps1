Configuration ConfigureIIS {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $FilePath = 'c:\inetpub\wwwroot',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $FileContent = @"
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
    )
    # Import the module that contains the resources we're using.
    Import-DscResource -ModuleName PSDscResources

    # The Node statement specifies which targets this configuration will be applied to.
    Node 'localhost' {

        # The first resource block ensures that the Web-Server (IIS) feature is enabled.
        WindowsFeature WebServer {
            Ensure = "Present"
            Name   = "Web-Server"
        }



        Script WebsiteContent {
            SetScript = {
                $streamWriter = New-Object -TypeName 'System.IO.StreamWriter' -ArgumentList @( $using:FilePath )
                $streamWriter.WriteLine($using:FileContent)
                $streamWriter.Close()
            }
            TestScript = {
                if (Test-Path -Path $using:FilePath)
                {
                    $fileContent = Get-Content -Path $using:filePath -Raw
                    return $fileContent -eq $using:FileContent
                }
                else
                {
                    return $false
                }
            }
            GetScript = {
                $fileContent = $null

                if (Test-Path -Path $using:FilePath)
                {
                    $fileContent = Get-Content -Path $using:filePath -Raw
                }

                return @{
                    Result = Get-Content -Path $fileContent
                }
            }
        }
        # The second resource block ensures that the website content copied to the website root folder.
        File WebsiteContent {
            Ensure = 'Present'
            SourcePath = 'c:\site\index.htm'
            DestinationPath = 'c:\inetpub\wwwroot'
        }
    }
}