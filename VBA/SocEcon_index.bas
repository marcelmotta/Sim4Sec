Attribute VB_Name = "Module1"
Sub IndexPivot()
'
' UNPIVOT INDICES AND THE CORRESPONDING VALUES
'

Dim LC As Long, NR As Long, HowMany As Long, a As Long, b As Long
Dim c As Range, rng As Range


' Clear clipboard, selections, omit updates
Application.CutCopyMode = False
Application.ScreenUpdating = False


' Create output sheet and headers
Range("A1:G1").Copy
Sheets.Add.Name = "socecon_index"
Range("A1").Activate
ActiveSheet.Paste

Range("F1").FormulaR1C1 = "Índice"
Range("G1").FormulaR1C1 = "Valor"


' Retrieve data and unpivot
ActiveSheet.Next.Activate

NR = 2
With ActiveSheet
  LC = .Cells(1, Columns.Count).End(xlToLeft).Column
  For Each c In .Range("A2", .Range("A" & Rows.Count).End(xlUp))
    Set rng = .Range(.Cells(c.Row, 5), .Cells(c.Row, LC))
    HowMany = Application.WorksheetFunction.Count(rng)
    .Range("A" & c.Row & ":E" & c.Row).Copy Sheets("socecon_index").Range("A" & NR & ":A" & NR + HowMany - 1)
    b = NR
    For a = 6 To LC Step 1
        Sheets("socecon_index").Range("F" & b) = .Cells(1, a)
        Sheets("socecon_index").Range("G" & b) = .Cells(c.Row, a)
        b = b + 1
    Next a
    NR = NR + HowMany
  Next c
End With
Sheets("socecon_index").Select


'Fix index name case
    Cells.Replace What:="CENTROIDX", Replacement:="centroidx", LookAt:=xlPart, _
        SearchOrder:=xlByRows, MatchCase:=False, SearchFormat:=False, _
        ReplaceFormat:=False
    Cells.Replace What:="CENTROIDY", Replacement:="centroidy", LookAt:=xlPart, _
        SearchOrder:=xlByRows, MatchCase:=False, SearchFormat:=False, _
        ReplaceFormat:=False


'Remove useless columns
    Columns("A:A").Select
    Selection.Delete Shift:=xlToLeft
    Columns("B:B").Select
    Selection.Delete Shift:=xlToLeft
    Columns("C:C").Select
    Selection.Delete Shift:=xlToLeft


' Auto-adjust cells width and height
    Cells.Select
    Cells.EntireRow.AutoFit
    Cells.EntireColumn.AutoFit

End Sub
