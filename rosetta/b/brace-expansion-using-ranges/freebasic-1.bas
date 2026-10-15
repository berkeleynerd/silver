#define MAX(a, b) iif((a) > (b), (a), (b))

Type StringArray
    elements(Any) As String
    length As Integer
End Type

Function PadZeros(txt As String) As Integer
    If Len(txt) > 1 Andalso Left(txt, 1) = "0" Then Return Len(txt)
    Return 0
End Function

Function isNumeric(txt As String) As Boolean
    If Len(txt) = 0 Then Return False
    
    Dim As Integer i = 1
    If Mid(txt, 1, 1) = "-" Then
        If Len(txt) = 1 Then Return False
        i = 2
    End If
    
    For j As Integer = i To Len(txt)
        Dim As String ch = Mid(txt, j, 1)
        If ch < "0" Or ch > "9" Then Return False
    Next
    
    Return True
End Function

Function isRange(txt As String) As Boolean
    Return Instr(txt, "..") > 0
End Function

Function SplitRange(txt As String) As StringArray
    Dim As StringArray result
    Redim result.elements(2)
    
    Dim As Integer start = Instr(txt, "{") + 1
    Dim As Integer endPos = Instr(txt, "}")
    Dim As String range = Mid(txt, start, endPos - start)
    
    Dim As Integer dotPos = Instr(range, "..")
    If dotPos = 0 Then
        result.elements(0) = range
        result.length = 1
        Return result
    End If
    
    result.elements(0) = Left(range, dotPos - 1)
    Dim As String rest = Mid(range, dotPos + 2)
    
    dotPos = Instr(rest, "..")
    If dotPos = 0 Then
        result.elements(1) = rest
        result.length = 2
    Else
        result.elements(1) = Left(rest, dotPos - 1)
        result.elements(2) = Mid(rest, dotPos + 2)
        result.length = 3
    End If
    
    Return result
End Function

Function RangeExpand(txt As String) As StringArray
    Dim As StringArray parts = SplitRange(txt)
    Dim As StringArray result
    
    ' If SplitRange detected an invalid range -> return literal
    If parts.length = 1 Andalso parts.elements(0) = txt Then
        Dim As StringArray result
        Redim result.elements(0)
        result.elements(0) = txt
        result.length = 1
        Return result
    End If
    
    Dim As Integer delta, x, y, pad, idx, cnt
    
    ' Handle non-range patterns
    If Not isRange(txt) Then
        Redim result.elements(0)
        result.elements(0) = txt
        result.length = 1
        Return result
    End If
    
    delta = Iif(parts.length > 2, Val(parts.elements(2)), 1)
    
    ' Numerial only if both ends are
    If isNumeric(parts.elements(0)) Andalso isNumeric(parts.elements(1)) Then
        x = Val(parts.elements(0))
        y = Val(parts.elements(1))
        
        pad = Max(PadZeros(parts.elements(0)), PadZeros(parts.elements(1)))
        
        Dim As Integer origDelta = delta
        Dim As Integer startX = x, endY = y
        
        delta = Abs(delta)
        
        cnt = (Abs(y - x) \ delta) + 1
        Redim result.elements(cnt - 1)
        result.length = cnt
        
        idx = 0
        If x <= y Then
            While x <= y
                If pad > 0 Then
                    result.elements(idx) = Right(String(pad, "0") & Trim(Str(x)), pad)
                Else
                    result.elements(idx) = Trim(Str(x))
                End If
                idx += 1
                x += delta
            Wend
        Else
            While x >= y
                If pad > 0 Then
                    result.elements(idx) = Right(String(pad, "0") & Trim(Str(x)), pad)
                Else
                    result.elements(idx) = Trim(Str(x))
                End If
                idx += 1
                x -= delta
            Wend
        End If
        
        ' We only reverse if the original range was ascending and the step was negative
        If origDelta < 0 AndAlso startX < endY Then
            For i As Integer = 0 To (result.length \ 2) - 1
                Swap result.elements(i), result.elements(result.length - 1 - i)
            Next
        End If
        
        ' ALFA only if both are not numeric
    Elseif (Not isNumeric(parts.elements(0))) Andalso (Not isNumeric(parts.elements(1))) Then
        ' Handle alpha ranges
        x = Asc(Right(parts.elements(0), 1))
        y = Asc(Right(parts.elements(1), 1))
        
        cnt = (Abs(y - x) \ Abs(delta)) + 1
        Redim result.elements(cnt - 1)
        result.length = cnt
        
        idx = 0
        If x <= y Then
            While x <= y
                result.elements(idx) = Chr(x)
                idx += 1
                x += delta
            Wend
        Else
            While x >= y
                result.elements(idx) = Chr(x)
                idx += 1
                x -= Abs(delta)
            Wend
        End If       
        
        ' Mixed types: treat literally
    Else
        Redim result.elements(0)
        result.elements(0) = txt
        result.length = 1
    End If
    
    Return result
End Function

Function ProcessPattern(pattern As String) As StringArray
    Dim As Integer i, j
    Dim As StringArray result
    
    Dim As Integer braceStart = Instr(pattern, "{")
    If braceStart = 0 Then
        Redim result.elements(0)
        result.elements(0) = pattern
        result.length = 1
        Return result
    End If
    
    Dim As Integer braceEnd = Instr(braceStart, pattern, "}")
    If braceEnd = 0 Then
        Redim result.elements(0)
        result.elements(0) = pattern
        result.length = 1
        Return result
    End If
    
    Dim As String prefix = Left(pattern, braceStart - 1)
    Dim As String range = Mid(pattern, braceStart, braceEnd - braceStart + 1)
    Dim As String suffix = Mid(pattern, braceEnd + 1)
    
    If Not isRange(range) Then
        Redim result.elements(0)
        result.elements(0) = pattern
        result.length = 1
        Return result
    End If
    
    Dim rangeExp As StringArray = RangeExpand(range)
    
    ' Process next range if exists
    If Instr(suffix, "{") > 0 Then
        Dim As StringArray nextExp = ProcessPattern(suffix)
        Dim As Integer totalResults = rangeExp.length * nextExp.length
        Redim result.elements(totalResults - 1)
        result.length = totalResults
        
        Dim As Integer idx = 0
        For i = 0 To rangeExp.length - 1
            For j = 0 To nextExp.length - 1
                result.elements(idx) = prefix & rangeExp.elements(i) & nextExp.elements(j)
                idx += 1
            Next
        Next
    Else
        Redim result.elements(rangeExp.length - 1)
        result.length = rangeExp.length
        For i = 0 To rangeExp.length - 1
            result.elements(i) = prefix & rangeExp.elements(i) & suffix
        Next
    End If
    
    Return result
End Function


' Main program
Dim As String tests(0 To ...) = { _
"simpleNumberRising{1..3}.txt", _
"simpleAlphaDescending-{Z..X}.txt", _
"steppedDownAndPadded-{10..00..5}.txt", _
"minusSignFlipsSequence {030..20..-5}.txt", _
"reverseSteppedNumberRising{1..6..-2}.txt", _
"combined-{Q..P}{2..1}.txt", _
"li{teral", _
"rangeless{}empty", _
"rangeless{random}string", _
"mixedNumberAlpha{5..k}", _
"steppedAlphaRising{P..Z..2}.txt", _
"stops after endpoint-{02..10..3}.txt" }

For i As Integer = Lbound(tests) To Ubound(tests)
    Print tests(i); " ->"
    Dim expanded As StringArray = ProcessPattern(tests(i))
    For j As Integer = 0 To expanded.length - 1
        Print "    "; expanded.elements(j)
    Next
    Print
    Sleep
Next

Sleep
