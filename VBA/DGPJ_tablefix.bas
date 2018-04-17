Attribute VB_Name = "Module1"
Sub AllWorkbooks()

Dim MyFolder As String 'Path collected from the folder picker dialog
Dim MyFile As String 'Filename obtained by DIR function
Dim wbk As Workbook 'Used to loop through each workbook

On Error Resume Next

'Turn off screen updates and alerts while saving output files
Application.DisplayAlerts = False
Application.ScreenUpdating = False

'Opens the folder picker dialog to allow user selection
With Application.FileDialog(msoFileDialogFolderPicker)
    .Title = "Please select a folder"
    .Show
    .AllowMultiSelect = False
    
    'Error handling: if no folder is selected, abort
    If .SelectedItems.Count = 0 Then
        MsgBox "Task aborted. You did not select a folder."
        Exit Sub
    End If
    
    'Assign selected folder to MyFolder
    MyFolder = .SelectedItems(1) & "\"

End With

'DIR gets the first file of the folder
MyFile = Dir(MyFolder)

'Loop through all files in a folder until DIR cannot find anymore
Do While MyFile <> ""

   'Opens the file and assigns to the wbk variable for future use
   Set wbk = Workbooks.Open(Filename:=MyFolder & MyFile)

   'Scripts to be executed
    Call FixTable
    Call Unpivot

    wbk.SaveAs Filename:=MyFolder & MyFile, FileFormat:=xlExcel8
    wbk.Close
    
    'DIR gets the next file in the folder
    MyFile = Dir

Loop

Application.DisplayAlerts = True
MsgBox "Data is retrieved and unpivoted"

End Sub

Sub FixTable()
'
' CREATE TABULAR STRUCTURE AND FORMAT DATA FROM DGPJ
'

    Dim lCol As Integer
    Dim lRow As Integer
    Dim rowIndex As Integer
    Dim mergedCell As Range, unmergedCell As Range
    
' Clear clipboard, selections, omit updates, remove pictures
    Application.CutCopyMode = False
    Application.ScreenUpdating = False
    ActiveSheet.Pictures.Delete
           
' Unmerge all cells and replicate values
For Each mergedCell In ActiveSheet.UsedRange
    If mergedCell.MergeCells Then
        Set unmergedCell = mergedCell.MergeArea
        mergedCell.MergeCells = False
        unmergedCell.Value = mergedCell.Value
    End If
Next
    
' Remove blank columns
    Columns("B:B").Select
    Selection.Delete Shift:=xlToLeft
    Columns("C:C").Select
    Selection.Delete Shift:=xlToLeft

' Remove useless headers
    Cells.Find(What:="Nº Crimes", After:=ActiveCell, LookIn:=xlFormulas, LookAt:= _
        xlPart, SearchOrder:=xlByRows, SearchDirection:=xlNext, MatchCase:=True _
        , SearchFormat:=False).Activate
    ActiveCell.Offset(-1, 0).Select
    Range(Selection, Selection.End(xlToRight)).Select
    Selection.Cut
    ActiveCell.Offset(1, 0).Select
    ActiveSheet.Paste
    
' Find new headers and drag table to first row
    Cells(1, 1).Select
    Cells.Find(What:="NUT", After:=ActiveCell, LookIn:=xlFormulas, LookAt:= _
        xlPart, SearchOrder:=xlByRows, SearchDirection:=xlNext, MatchCase:=False _
        , SearchFormat:=False).Activate

    lCol = Cells(ActiveCell.Row, Columns.Count).End(xlToLeft).Column
    lRow = Cells(Rows.Count, 3).End(xlUp).Row
    Range(Selection, Cells(lRow, lCol)).Select
    Selection.Cut
    Range("A1").Select
    ActiveSheet.Paste
    lRow = Cells(1, 1).End(xlDown).Row
    Rows(lRow & ":" & Rows.Count).Delete
    
' Change header names and replace nulls for zeros
    Cells.Replace What:=" (Infracção)", Replacement:="", LookAt:=xlPart, _
        SearchOrder:=xlByRows, MatchCase:=False, SearchFormat:=False, _
        ReplaceFormat:=False
    
    Cells.Replace What:="..", Replacement:="0", LookAt:=xlPart, _
        SearchOrder:=xlByRows, MatchCase:=False, SearchFormat:=False, _
        ReplaceFormat:=False
    
    Range("A1").Select
    ActiveCell.FormulaR1C1 = "Território"
    
    
' Auto-adjust cells width and height
    Cells.Select
    Cells.EntireRow.AutoFit
    Cells.EntireColumn.AutoFit
    
    
End Sub


Sub Unpivot()
'
' UNPIVOT DATA
'

Dim LC As Long, NR As Long, HowMany As Long, a As Long, b As Long
Dim c As Range, rng As Range
Dim sheetName As String

' Clear clipboard, selections, omit updates
Application.CutCopyMode = False
Application.ScreenUpdating = False

' Create output sheet and headers
Range("A1:F1").Copy
Sheets.Add.Name = "Output"
Range("A1").Activate
ActiveSheet.Paste
Range("D1").FormulaR1C1 = "Ano"
Range("E1").FormulaR1C1 = "Eventos"
Range("F1").FormulaR1C1 = "Índice"

' Retrieve data and unpivot
ActiveSheet.Next.Activate
sheetName = ActiveSheet.Name

NR = 2
With ActiveSheet
  LC = .Cells(1, Columns.Count).End(xlToLeft).Column
  For Each c In .Range("A2", .Range("A" & Rows.Count).End(xlUp))
    Set rng = .Range(.Cells(c.Row, 3), .Cells(c.Row, LC))
    HowMany = Application.WorksheetFunction.Count(rng)
    .Range("A" & c.Row & ":C" & c.Row).Copy Sheets("Output").Range("A" & NR & ":A" & NR + HowMany - 1)
    b = NR
    For a = 4 To LC Step 1
        Sheets("Output").Range("D" & b) = .Cells(1, a)
        Sheets("Output").Range("E" & b) = .Cells(c.Row, a)
        Sheets("Output").Range("F" & b) = sheetName
        b = b + 1
    Next a
    NR = NR + HowMany
  Next c
End With

Sheets("Output").Select

' Auto-adjust cells width and height
    Cells.Select
    Cells.EntireRow.AutoFit
    Cells.EntireColumn.AutoFit

End Sub






