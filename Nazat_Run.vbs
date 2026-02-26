Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' ফাইলটি যেখানে আছে, অটোমেটিক সেই ফোল্ডারের নাম বের করে নেবে
strFolder = objFSO.GetParentFolderName(WScript.ScriptFullName)
objShell.CurrentDirectory = strFolder

' কোনো কালো স্ক্রিন ছাড়াই মূল .bat ফাইলটি রান করবে
objShell.Run Chr(34) & strFolder & "\wireless_scrcpy.bat" & Chr(34), 0, False