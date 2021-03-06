<#
Gets and Runs Super Nintendo ROMS
PowerShell -ExecutionPolicy Bypass .\play_snes.ps1
#>
function Main(){
    Add-Type -AssemblyName presentationCore 
    $mediaPlayer = New-Object system.windows.media.mediaplayer
    $music = "http://www.florian-rappl.de/html5/projects/SuperMario/audio/menu.mp3"
    $mediaPlayer.open($music) 
    $mediaPlayer.Play() 
    
    $folder = "snes"
    $storageDir = "$pwd"
    $file = "snes.zip"
    $url = "https://dl.dropbox.com/s/cxsa8h7qdh26yo9/snes.zip"
    #$roms_url = "https://dl.dropbox.com/s/cxsa8h7qdh26yo9/snes.zip"
    $roms_url = "https://dl.dropbox.com/s/4r2c86chb1yc8ja/snes_roms.zip"
    $roms_zip = "snes_roms.zip"
 
    cls
    Write-Output "Welcome!!!"
    Start-Sleep -seconds 2
    
    function DownloadFile($url, $targetFile)
    
    {
    
       $uri = New-Object "System.Uri" "$url"
    
       $request = [System.Net.HttpWebRequest]::Create($uri)
    
       $request.set_Timeout(15000) #15 second timeout
    
       $response = $request.GetResponse()
    
       $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
    
       $responseStream = $response.GetResponseStream()
    
       $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
    
       $buffer = new-object byte[] 10KB
    
       $count = $responseStream.Read($buffer,0,$buffer.length)
    
       $downloadedBytes = $count
    
       while ($count -gt 0)
    
       {
    
           $targetStream.Write($buffer, 0, $count)
    
           $count = $responseStream.Read($buffer,0,$buffer.length)
    
           $downloadedBytes = $downloadedBytes + $count
    
           Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
    
       }
    
       #Write-Progress -activity "Finished downloading file '$($url.split('/') | Select -Last 1)'"
    
       $targetStream.Flush()
    
       $targetStream.Close()
    
       $targetStream.Dispose()
    
       $responseStream.Dispose()
    
    }
    
    
    if(!(Test-Path -Path $folder )){
        Write-Output "Downloading Emulator for Windows..."
        Start-Sleep -seconds 2
    
        DownloadFile $url $file 
    
        Write-Output "Unzipping Emulator for Windows"
        Start-Sleep -seconds 2
        
        $shell = new-object -com shell.application
        $zip = $shell.NameSpace("$file")
    
        foreach($item in $zip.items())
        {
            $shell.Namespace("$storageDir\").copyhere($item)
        }
        Remove-Item $file -Force -Recurse
    }else{
        Write-Output "Emulator Already Installed";
        Start-Sleep -seconds 2
    }
    
    


    $rom = "roms\Super Mario World (U) [!].smc"
    
    $mediaPlayer.Stop()
    
    $get_roms = Read-Host 'Emulator is ready. Would you like to get roms? (y/N)'
    
    if(($get_roms -eq "Y" )){
        cls
        Write-Output "Player some Mario World While I download a bunch of ROMS"
        Write-Output "By 'a bunch', I mean all of them."
        Start-Sleep -seconds 2
    
        #cd $pwd\$folder
        cmd /c start $pwd\$folder\zsnesw.exe $pwd\$folder\$rom

        DownloadFile $roms_url $roms_zip 
        $zip = $shell.NameSpace("$roms_zip")
        
        
        foreach($item in $zip.items())
        {
                $shell.Namespace("$pwd\$folder\").copyhere($item)
        }
        write-output "Removing $roms_zip"
        Remove-Item $roms_zip -Force -Recurse
     
    }else{
        #cd $pwd\$folder
        cmd /c start $pwd\$folder\zsnesw.exe $rom        
    }
    
    
    $del = Read-Host 'Do you want to remove the emulator and roms? (y/N)'
    
    if(($del -eq "Y" )){
        Write-Output "Removing Emulator and ROMS"
        Remove-Item $folder -Force -Recurse
    }
    
    write-output "Thank you for playing"
}

Main
