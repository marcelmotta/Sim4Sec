Attribute VB_Name = "Module1"

'Count number of rows for a given column
Function rowCount(index As Integer)
    rowCount = Cells(Rows.Count, index).End(xlUp).Row
End Function

'Count number of columns
Function colCount()
    colCount = Cells(1, Columns.Count).End(xlToLeft).Column
End Function

'Convert a column index from letter to number or from number to letter
Function colIndexFinder(index)
    On Error GoTo ErrHandler
    Select Case IsNumeric(index)
        Case True
            colIndexFinder = Split(Cells(, index).Address, "$")(1)
        Case Else
            colIndexFinder = Range(index & 1).Column
    End Select

ErrHandler:    
    Select Case Err.Number
        Case 1004
            colIndexFinder = 0
        Case Else
            Resume Next
    End Select
End Function

'Public wsf As WorksheetFunction
Sub IterateSheets()
    
'Set wsf = Application.WorksheetFunction

Dim ws As Worksheet
Dim wsCount As Integer
Dim wsList As Variant

Application.ScreenUpdating = False
Application.CutCopyMode = False
Application.DisplayStatusBar = True

Application.ActiveWorkbook.Worksheets(1).Activate

wsCount = Worksheets.Count
wsList = Array("Procedures", "Log", "Data2", "Data", "Sheet1")

For Each ws In Worksheets
    Application.StatusBar = "Checking sheet (" & ws.Index & "/" & wsCount & "): " & ws.Name
    If IsError(Application.Match(ws.Name, wsList, 0)) Then
        'Insert tasks here for sheets not found in array wsList
        MsgBox ws.Name & " updated"
    Else
        MsgBox ws.Name & " ignored"
    End If
Next

Application.StatusBar = False
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
