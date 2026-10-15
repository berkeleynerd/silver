#include "file.bi"

Function Replace(Byval s As String, Byval find As String, Byval repl As String) As String
    Dim p As Integer = Instr(s, find)
    While p > 0
        s = Left(s, p - 1) & repl & Mid(s, p + Len(find))
        p = Instr(p + Len(repl), s, find)
    Wend
    Return s
End Function

Dim inFile  As String = "The_Road_Not_Taken.png"
Dim outFile As String = "poem"   ' .txt added automatically by tesseract

' Run Tesseract (Windows + Linux)
Shell("tesseract " & Chr(34) & inFile & Chr(34) & " " & Chr(34) & outFile & Chr(34) & " --psm 6")

Dim lines() As String
Dim raw As String
Dim cnt As Integer = 0

While Not Eof(ff)
    Line Input #ff, raw
    Redim Preserve lines(cnt)
    lines(cnt) = raw
    cnt += 1
Wend
Close #ff

' Remove the last line if it is empty.
If cnt > 0 And Len(lines(cnt - 1)) = 0 Then
    cnt -= 1
    If cnt > 0 Then Redim Preserve lines(cnt - 1)
End If

If cnt > 0 Then lines(0) = "      " & lines(0)  ' insert 6 blank spaces before heading

Dim i As Integer = cnt - 1
Dim c As Integer = 0

While i > 0
    ' Cleaning of special bytes without encoding errors
    If Len(lines(i)) > 0 Then
        If Len(lines(i)) >= 2 AndAlso lines(i)[0] = 194 AndAlso lines(i)[1] = 145 Then
            lines(i) = Mid(lines(i), 3)
        ElseIf lines(i)[0] = 145 Then
            lines(i) = Mid(lines(i), 2)
        End If
    End If
    
    If Instr(lines(i), "lees") > 0 Then lines(i) = Replace(lines(i), "lees", "less")
    
    ' Insert a blank line every 5 processed lines.
    c += 1
    If c Mod 5 = 0 Then
        cnt += 1
        Redim Preserve lines(cnt - 1)
        
        For j As Integer = cnt - 2 To i Step -1
            lines(j + 1) = lines(j)
        Next
        lines(i) = ""
    End If
    
    i -= 1
Wend

' Print corrected poem
For k As Integer = 0 To cnt - 1
    Print lines(k)
Next

Sleep
