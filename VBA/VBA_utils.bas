Attribute VB_Name = "Module1"
Sub IterateSheets()

Dim ws As Worksheet
Dim wsCount As Integer
Dim wsList As Variant

Application.ScreenUpdating = False
Application.CutCopyMode = False

Application.ActiveWorkbook.Worksheets(1).Activate

wsCount = Worksheets.Count
wsList = Array("Procedures", "Log", "Data2", "Data", "Sheet1")

For Each ws In Worksheets
    MsgBox "Checking sheet (" & ws.Index & "/" & wsCount & "): " & ws.Name
    If IsError(Application.Match(ws.Name, wsList, 0)) Then
        'Insert tasks here for sheets not found in array wsList
        MsgBox ws.Name & " updated"
    Else
        MsgBox ws.Name & " ignored"
    End If
Next

Worksheets(1).Activate

MsgBox "Processing completed"

End Sub

Sub IterateSheetsOld()

Dim ws As Worksheet
Dim wsCount As Integer
Dim wsList As Variant

Application.ScreenUpdating = False
Application.CutCopyMode = False

Application.ActiveWorkbook.Worksheets(1).Activate

wsCount = Worksheets.Count
wsList = Array("Procedures", "Log", "Data2", "Data", "Sheet1")

For i = 1 To wsCount Step 1
    MsgBox "Checking sheet (" & ActiveSheet.Index & "/" & wsCount & "): " & ActiveSheet.Name
    If IsError(Application.Match(ActiveSheet.Name, wsList, 0)) Then
        'Insert tasks here for sheets not found in array wsList
        MsgBox ActiveSheet.Name & " updated"
    Else
        MsgBox ActiveSheet.Name & " ignored"
    End If
    
    If i <> wsCount Then
        ActiveSheet.Next.Activate
    Else
        Worksheets(1).Activate
    End If
Next i

MsgBox "Processing completed"

End Sub
