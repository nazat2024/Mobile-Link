Set WshShell = CreateObject("WScript.Shell")
strDesktop = WshShell.SpecialFolders("Desktop")
Set oLink = WshShell.CreateShortcut(strDesktop & "\Mobile Link.lnk")

' এখানে আমরা টার্গেট এবং আইকন অটোমেটিক সেট করে দিচ্ছি
oLink.TargetPath = "wscript.exe"
oLink.Arguments = Chr(34) & "C:\NAZAT_Andriod_Connector\Nazat_Run.vbs" & Chr(34)
oLink.IconLocation = "C:\NAZAT_Andriod_Connector\NZT.ico"
oLink.WorkingDirectory = "C:\NAZAT_Andriod_Connector"
oLink.Save