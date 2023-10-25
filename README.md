# Using Full Flash Update (FFU) files to speed up Windows deployment
This repo contains the full FFU process that we use in US Education at Microsoft to help customers with large deployments of Windows as they prepare for the new school year. This process isn't limited to only large deployments at the start of the year, but is the most common.

This process will copy Windows in about 2-3 minutes to the target device, optionally copy drivers, provisioning packages, Autopilot, etc. School technicians have even given the USB sticks to teachers and teachers calling them their "Magic USB sticks" to quickly get student devices reimaged in the event of an issue with their Windows PC. 

While we use this in Education at Microsoft, other industries can use it as well. We esepcially see a need for something like this with partners who do re-imaging on behalf of customers. The difference in Education is that they typically have large deployments that tend to happen at the beginning of the school year and any amount of time saved is helpful. Microsoft Deployment Toolkit, Configuration Manager, and other community solutions are all great solutions, but are typically slower due to WIM deployments being file-based while FFU files are sector-based.

# Updates
**2310.1**

New Features

**MSI Auto Installer**
Automatic processing of a collection of MSI files and MST transforms

**Windows Updates Installer**
Automatic processing of Windows Updates via saved MSU packages

**2309.2**

New Features

**Multiple USB Drive Support**

You can now plug in multiple USB drives (even using a USB hub) to create multiple USB drives for deployment. This is great for partners or customers who need to provide USB drives to their employees to image a large number of devices. It will copy the content to one USB drive at a time. The most USB drives we've seen created so far is 23 via a USB hub. Open an issue if you see any problems with this. 

**Robocopy support**

Replaced Copy-Item with Robocopy when copying content to the USB drive(s). Copy-Item uses buffered IO, which can take a long time to copy large files. Robocopy with the /J switch allows for unbuffered IO support, which reduces the amount of time to copy.

**Better error handling**

Prior to 2309.2, if the script failed or you manually killed the script (ctrl+c, or closing the PowerShell window), the environment would end up in a bad state and you had to do a number of things to manually clean up the environment. Added a new function called Get-FFUEnvironment and a new text file called dirty.txt that gets created in the FFUDevelopment folder. When the script starts, it checks for the dirty.txt file and if it sees it, Get-FFUEnvironment runs and cleans out a number of things to help ensure the next run will complete successfully. Open an issue if you still see problems when the script fails and the next run of the script fails. 


Bug Fixes
- In 2309.1, added a 15 second sleep to allow for the registry to unload to fix a Critical Process Died error on deployment. In this build, increased that to 60 seconds. 
- Fixed an issue where the script was incorrectly detecting the USB drive boot and deploy drive letters which caused issues when attempting to copy the WinPE files to the boot partition.

**2309.1**
- Fixed an issue with a Critical Process Died BSOD that would happen when using -installapps $false. More detailed information in the [commit](https://github.com/rbalsleyMSFT/FFU/pull/2/commits/34efbda7ec56dc7cb43ac42b058725d56c8b8899)

**2306.1.2**
- Fixed an issue where manually entering a name wouldn't name the computer as expected

**2306.1.1**
- Included some better error handling if defining optionalfeatures that require source folders (netfx3). ESD files don't have source folders like ISO media, which means installing .net 3.5 as an optional feature would fail. Also cleaned up some formatting. 

**2306.1**
- Added support to automatically download the latest Windows 10 or 11 media via the media creation tool (thanks to [Michael](https://oofhours.com/2022/09/14/want-your-own-windows-11-21h2-arm64-isos/) for the idea). This also allows for different architecture, language, and media type support. If you omit the -ISOPath, the script will download the Windows 11 x64 English (US) consumer media.

  An example command to download Windows 11 Pro x64 English (US) consumer media with Office and install drivers (it won't download drivers, you'll put those in your c:\FFUDevelopment\Drivers folder)
  
  .\BuildFFUVM.ps1 -WindowsSKU 'Pro' -Installapps $true -InstallOffice $true -InstallDrivers $true -VMSwitchName 'Name of your VM Switch in Hyper-V' -VMHostIPAddress 'Your IP Address' -CreateCaptureMedia $true -CreateDeploymentMedia $true -BuildUSBDrive $true -verbose

  An example command to download Windows 11 Pro x64 French (CA) consumer media with Office and install drivers
  
  .\BuildFFUVM.ps1 -WindowsSKU 'Pro' -Installapps $true -InstallOffice $true -InstallDrivers $true -VMSwitchName 'Name of your VM Switch in Hyper-V' -VMHostIPAddress 'Your IP Address' -CreateCaptureMedia $true -CreateDeploymentMedia $true -BuildUSBDrive $true -WindowsRelease 11 -WindowsArch 'x64' -WindowsLang 'fr-ca' -MediaType 'consumer' -verbose


- Changed default size of System/EFI partition to 260MB from 256MB to accomodate 4Kn drives. 4Kn support needs more testing. I'm not confident yet that this can be done with VMs and FFUs. 
- Added versioning with a new version parameter. Using YYMM as the format followed by a point release.

# Getting Started
If you're not familiar with Github, you can click the Green code button above and select download zip. Extract the zip file and make sure to copy the FFUDevelopment folder to the root of your C: drive. That will make it easy to follow the guide and allow the scripts to work properly. 

If extracted correctly, your c:\FFUDevelopment folder should look like the following. If it does, go to c:\FFUDevelopment\Docs\BuildDeployFFU.docx to get started.

![image](https://github.com/rbalsleyMSFT/FFU/assets/53497092/5400a203-9c2e-42b2-b24c-ab8dfd922ba1)


