' ====================================================================
'  Phong_ADung - Video Story Publisher V22.99 - MO AN HOAN TOAN (khong nhap nhay cua so cmd)
'  Double-click file nay de chay. Cua so cmd khong bao gio hien ra.
'  Muon xem loi: chay CHAY_Phong_ADung.bat truc tiep.
' ====================================================================
Option Explicit
Dim sh, fso, here, bat
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

here = fso.GetParentFolderName(WScript.ScriptFullName)
bat  = here & "\CHAY_Phong_ADung.bat"

If Not fso.FileExists(bat) Then
    MsgBox "Khong tim thay CHAY_Phong_ADung.bat cung thu muc.", 16, "Phong_ADung - Video Story Publisher V22.99"
    WScript.Quit 1
End If

' 0 = cua so an, False = khong cho doi -> tool tat thi cmd tat theo
sh.Run """ & bat & """ hidden", 0, False
