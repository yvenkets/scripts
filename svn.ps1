<#
This Sample Code is provided for the purpose of illustration only
and is not intended to be used in a production environment.  THIS
SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT
WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS
FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, royalty-free
right to use and modify the Sample Code and to reproduce and distribute
the object code form of the Sample Code, provided that You agree:
(i) to not use Our name, logo, or trademarks to market Your software
product in which the Sample Code is embedded; (ii) to include a valid
copyright notice on Your software product in which the Sample Code is
embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including
attorneys' fees, that arise or result from the use or distribution
of the Sample Code.
#>
#region Function definitions
Function Get-ScreenShot
{ 
	<#
			.SYNOPSIS
			Take screenshots from the screen(s) during a duration and interval when specified 

			.DESCRIPTION
			Take screenshots from the screen(s) during a duration and interval when specified

			.PARAMETER FullName
			The destination file when taking only one screenshoot (no duration and interval specified)

			.PARAMETER Directory
			The destination directory when taking mutliple screenshoots (duration and interval specified)

			.PARAMETER Format
			The image format (pick a format in the list : 'bmp','gif','jpg','png','wmf')

			.PARAMETER DurationInSeconds
			The duration in seconds during which we will take a screenshot

			.PARAMETER IntervalInSeconds
			The interval in seconds between two screenshots (when DurationInSeconds is specified)

			.PARAMETER Area
			The are of the screenshot : 'WorkingArea' is for the current screen and 'VirtualScreen' is for all connected screens

			.PARAMETER Beep
			Play a beep everytime a screenshot is taken if specified

			.EXAMPLE
			Get-ScreenShot
			Take a screenshot of the current screen. The file will be generated in the Pictures folder of the current user and will use the PNG format by default. The filename will use the YYYYMMDDTHHmmSS format

			.EXAMPLE
            Get-ScreenShot -FullName 'c:\temp\screenshot.wmf' -Area VirtualScreen
			Take a screenshot of all connected screens. The generated file will be 'c:\temp\screenshot.wmf'

			.EXAMPLE
            Get-ScreenShot -Directory 'C:\temp' -Format jpg -DurationInSeconds 30 -IntervalInSeconds 10 -Area WorkingArea -Format JPG -Verbose
			Take multiple screenshots (of the current screen) during a 30 seconds period by waiting 10 second between two shots. The file will be generated in the C:\temp folder and will use the JPG format by default. The filename will use the YYYYMMDDTHHmmSS format

	#>	
    [CmdletBinding(DefaultParameterSetName='Directory', PositionalBinding=$false)]
	Param(
		[Parameter(ParameterSetName='File')]
		[Parameter(Mandatory=$false, ValueFromPipeline=$False, ValueFromPipelineByPropertyName=$False)]
		[ValidateScript({$_  -match "\.(bmp|gif|jpg|png|wmf)$"})]
		[string]$FullName,

		[Parameter(ParameterSetName='Directory')]
		[Parameter(Mandatory=$false, ValueFromPipeline=$False, ValueFromPipelineByPropertyName=$False)]
		[string]$Directory,

		[Parameter(ParameterSetName='Directory')]
		[parameter(Mandatory=$false)]
		[ValidateSet('bmp','gif','jpg','png','wmf')]
		[String]$Format='png',

		[Parameter(ParameterSetName='Directory')]
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -ge 0})]
		[int]$DurationInSeconds=0,

		[Parameter(ParameterSetName='Directory')]
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -ge 0})]
		[int]$IntervalInSeconds=0,

		[parameter(Mandatory=$false)]
		[ValidateSet('VirtualScreen','WorkingArea')]
		[String]$Area='WorkingArea',

		[parameter(Mandatory=$false)]
		[Switch]$Beep
	)

	
	Add-Type -AssemblyName System.Windows.Forms
	Add-type -AssemblyName System.Drawing
	# Gather Screen resolution information
	#$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
	#$Screen = [System.Windows.Forms.SystemInformation]::WorkingArea
    $Screen = [System.Windows.Forms.SystemInformation]::$Area
	$Width = $Screen.Width
	$Height = $Screen.Height
	$Left = $Screen.Left
	$Top = $Screen.Top
    $TimeElapsed = 0
    $IsTimeStampedFileName = $false
	if ($FullName)
	{
		$Directory = Split-Path -Path $FullName -Parent
		$HasExtension = $FullName -match "\.(?<Extension>\w+)$"
		if ($HasExtension)
		{
			$Format = $Matches['Extension']
		}
		New-Item -Path $Directory -ItemType Directory -Force | Out-Null
	}
	elseif ($Directory)
	{
		New-Item -Path $Directory -ItemType Directory -Force | Out-Null
		$FullName = Join-Path -Path $Directory -ChildPath $((get-date -f yyyyMMddTHHmmss)+".$Format")
        $IsTimeStampedFileName = $true
	}
	else
	{
		$Directory = [Environment]::GetFolderPath('MyPictures')
        Write-Verbose "Target directory not specified we use [$Directory]"
		$FullName = Join-Path -Path $Directory -ChildPath $((get-date -f yyyyMMddTHHmmss)+".$Format")
        $IsTimeStampedFileName = $true
	}

	switch ($Format)
	{
		'bmp' { $Imageformat= [System.Drawing.Imaging.ImageFormat]::Bmp; }
		'gif' { $Imageformat= [System.Drawing.Imaging.ImageFormat]::Gif; }
		'jpg' { $Imageformat= [System.Drawing.Imaging.ImageFormat]::Jpeg; }
		'png' { $Imageformat= [System.Drawing.Imaging.ImageFormat]::Png; }
		'wmf' { $Imageformat= [System.Drawing.Imaging.ImageFormat]::Wmf; }
	}

	do 
    {
        # Create bitmap using the top-left and bottom-right bounds
	    $Bitmap = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Width, $Height

	    # Create Graphics object
	    $Graphic = [System.Drawing.Graphics]::FromImage($Bitmap)

	    # Capture screen
	    $Graphic.CopyFromScreen($Left, $Top, 0, 0, $Bitmap.Size)

	    # Save to file
	    $Bitmap.Save($FullName, $Imageformat) 
        Write-Verbose -Message "[$(get-date -Format T)] Screenshot saved to $FullName"
        if ($Beep)
        {
            [console]::beep()
        }
	    
        if (($DurationInSeconds -gt 0) -and ($IntervalInSeconds -gt 0))
        {
            Write-Verbose "[$(get-date -Format T)] Sleeping $IntervalInSeconds seconds ..."
            Start-Sleep -Seconds $IntervalInSeconds
            $TimeElapsed += $IntervalInSeconds
        }
        if ($IsTimeStampedFileName)
        {
    		$FullName = Join-Path -Path $Directory -ChildPath $((get-date -f yyyyMMddTHHmmss)+".$Format")
        }
    } While ($TimeElapsed -lt $DurationInSeconds) 
}    
#endregion

Clear-Host
New-Alias -Name New-ScreenShoot -Value Get-ScreenShot -ErrorAction SilentlyContinue
#Get-ScreenShot -Verbose
Get-ScreenShot -Directory 'C:\Users\Public\Documents\svn\v1\' -Format jpg -DurationInSeconds 36000 -IntervalInSeconds 6 -Area WorkingArea  -Verbose
#Get-ScreenShot -FullName 'c:\temp\screenshot.wmf' -Verbose
