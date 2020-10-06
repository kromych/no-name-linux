<#
    A helper to create a vhdx disk and embed bzImage compiled with CONFIG_EFI_STUB=y
#>

function New-EfiBootDisk
{
    param([string]$Path, $OsLoader)

    Write-Verbose "Creating $Path"

    if (Test-Path -Path $Path)
    {
        throw "Disk image at $Path already exists."
        return
    }
    
    Write-Verbose "Creating the VHDX file for $Path"
    $vhdParams=@{
        ErrorAction= "Stop"
        Path = $Path
        SizeBytes = 256MB
        Dynamic = $True
    }

    $efiPartSize = 100MB

    try
    {
        Write-Verbose ($vhdParams | Out-String)
        $disk = New-VHD @vhdParams
    }
    catch
    {
        throw "Failed to create $Path. $($_.Exception.Message)"
        return
    }

    # Mount the disk image
    Write-Verbose "Mounting disk image"
    Mount-DiskImage -ImagePath $Path

    # Get the disk number
    $diskNumber = (Get-DiskImage -ImagePath $Path | Get-Disk).Number

    # Initialize as GPT
    Write-Verbose "Initializing disk $DiskNumber as GPT"
    Initialize-Disk -Number $diskNumber -PartitionStyle GPT

    # Clear the disk
    Write-Verbose "Clearing disk partitions to start all over"
    Get-Disk -Number $diskNumber | Get-Partition | Remove-Partition -Confirm:$False

    # Create the system partition
    Write-Verbose "Creating a $efiPartSize byte System partition on disknumber $diskNumber"
    
    $sysPartition = New-Partition -DiskNumber $diskNumber -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' -Size $efiPartSize
    $sysPartition | Format-Volume -FileSystem FAT32 -NewFileSystemLabel "EFI" -confirm:$False | Out-Null
    $sysPartition | Set-Partition -NewDriveLetter S

    mkdir s:\EFI\Boot
    cp $OsLoader s:\EFI\Boot\bootx64.efi

    # Dismount
    Write-Verbose "Dismounting disk image"
    Dismount-DiskImage -ImagePath $path

    # Write the new disk object to the pipeline
    Get-Item -Path $path
}
