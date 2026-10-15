Function stripLeadingZeros(s As String) As String
    s = Ltrim(s, "0")
    If s = "" Then Return "0"
    Return s
End Function

Function StrCmpNum(a As String, b As String) As Integer
    a = stripLeadingZeros(a)
    b = stripLeadingZeros(b)
    
    If Len(a) < Len(b) Then Return -1
    If Len(a) > Len(b) Then Return 1
    
    For i As Integer = 1 To Len(a)
        Dim As Integer da = Asc(Mid(a,i,1))
        Dim As Integer db = Asc(Mid(b,i,1))
        If da < db Then Return -1
        If da > db Then Return 1
    Next
    
    Return 0
End Function

Function StrModInt(a As String, d As Ulong) As Ulong
    Dim As Ulong r = 0
    For i As Integer = 1 To Len(a)
        r = (r * 10 + (Asc(Mid(a,i,1)) - Asc("0"))) Mod d
    Next
    Return r
End Function

Function StrDivInt(a As String, d As Ulong) As String
    Dim As String r = ""
    Dim As Ulong carry = 0
    
    For i As Integer = 1 To Len(a)
        carry = carry * 10 + (Asc(Mid(a,i,1)) - Asc("0"))
        r &= Chr((carry \ d) + Asc("0"))
        carry Mod= d
    Next
    r = Ltrim(r, "0")
    If r = "" Then r = "0"
    
    Return r
End Function

Function StrAdd(a As String, b As String) As String
    Dim As String r = ""
    Dim As Integer carry = 0
    Dim As Integer ia = Len(a), ib = Len(b)
    
    While ia > 0 Or ib > 0 Or carry > 0
        Dim As Integer da = 0
        Dim As Integer db = 0
        If ia > 0 Then da = Asc(Mid(a, ia, 1)) - Asc("0")
        If ib > 0 Then db = Asc(Mid(b, ib, 1)) - Asc("0")
        
        Dim As Integer x = da + db + carry
        carry = x \ 10
        r = Chr((x Mod 10) + Asc("0")) & r
        
        ia -= 1
        ib -= 1
    Wend
    
    Return stripLeadingZeros(r)
End Function

Function StrSub(a As String, b As String) As String
    Dim As String r = ""
    Dim As Integer carry = 0
    Dim As Integer ia = Len(a), ib = Len(b)
    
    While ia > 0 Or ib > 0
        Dim As Integer da = 0, db = 0
        If ia > 0 Then da = Asc(Mid(a, ia, 1)) - Asc("0")
        If ib > 0 Then db = Asc(Mid(b, ib, 1)) - Asc("0")
        
        Dim As Integer x = da - db - carry
        If x < 0 Then
            x += 10
            carry = 1
        Else
            carry = 0
        End If
        
        r = Chr(x + Asc("0")) & r
        ia -= 1
        ib -= 1
    Wend
    
    Return stripLeadingZeros(r)
End Function

Function StrMul(a As String, b As String) As String
    a = stripLeadingZeros(a)
    b = stripLeadingZeros(b)
    
    Dim As Integer la = Len(a), lb = Len(b)
    Dim As Integer prod(0 To la+lb-1)
    Dim As Integer i, j, da, db
    
    For i = la-1 To 0 Step -1
        da = Asc(Mid(a,i+1,1)) - Asc("0")
        For j = lb-1 To 0 Step -1
            db = Asc(Mid(b,j+1,1)) - Asc("0")
            prod((la-1-i)+(lb-1-j)) += da * db
        Next
    Next
    
    Dim As Integer carry = 0
    For i = 0 To la+lb-1
        j = prod(i) + carry
        prod(i) = j Mod 10
        carry = j \ 10
    Next
    
    Dim As String r = ""
    While carry > 0
        r = Chr((carry Mod 10) + Asc("0")) & r
        carry \= 10
    Wend
    
    For i = la+lb-1 To 0 Step -1
        r &= Chr(prod(i) + Asc("0"))
    Next
    
    Return stripLeadingZeros(r)
End Function

Function AddMod(a As String, b As String, m As String) As String
    Dim As String r = StrAdd(a, b)
    While StrCmpNum(r, m) >= 0
        r = StrSub(r, m)
    Wend
    Return r
End Function

Function MulMod(a As String, b As String, m As String) As String
    Dim As String r = "0", x = a, y = b
    
    While StrCmpNum(y, "0") > 0
        If StrModInt(y, 2) = 1 Then r = AddMod(r, x, m)
        x = AddMod(x, x, m)
        y = StrDivInt(y, 2)
    Wend
    
    Return r
End Function

Function PowMod(a As String, e As String, m As String) As String
    Dim As String r = "1", base_ = a, exp_ = e
    
    While StrCmpNum(exp_, "0") > 0
        If StrModInt(exp_, 2) = 1 Then r = MulMod(r, base_, m)
        base_ = MulMod(base_, base_, m)
        exp_ = StrDivInt(exp_, 2)
    Wend
    
    Return r
End Function

Function isPrimeStr(n As String) As Boolean
    n = stripLeadingZeros(n)
    If n = "0" Or n = "1" Then Return False
    If n = "2" Then Return True
    If StrModInt(n, 2) = 0 Then Return False
    
    Dim As String d = StrSub(n, "1")
    Dim As Integer s = 0
    
    While StrModInt(d, 2) = 0
        d = StrDivInt(d, 2)
        s += 1
    Wend
    
    Dim As Ulong bases(1 To 7) = {2,3,5,7,11,13,17}
    
    For i As Integer = 1 To 7
        Dim As String a = Str(bases(i))
        If StrCmpNum(a, n) >= 0 Then Continue For  ' This base is no good; move on to the next one.
        
        Dim As String x = PowMod(a, d, n)
        If x = "1" Then Continue For
        If x = StrSub(n, "1") Then Continue For
        
        Dim As Boolean composite = True
        For r As Integer = 1 To s-1
            x = MulMod(x, x, n)
            If x = StrSub(n, "1") Then
                composite = False
                Exit For
            End If
        Next
        
        If composite Then Return False       
    Next
    
    Return True
End Function

Function FactorConcat(n As String) As String
    Dim As String tmp = n
    Dim As String s = ""
    
    Dim As Ulong p = 2
    While StrModInt(tmp, p) = 0
        s &= Str(p)
        tmp = StrDivInt(tmp, p)
    Wend
    
    p = 3
    While StrCmpNum(StrMul(Str(p), Str(p)), tmp) <= 0
        While StrModInt(tmp, p) = 0
            s &= Str(p)
            tmp = StrDivInt(tmp, p)
        Wend
        p += 2
    Wend
    
    If StrCmpNum(tmp, "1") > 0 Then s &= tmp
    Return s
End Function

Sub printHomePrimeChain(n As Integer)
    Dim As Integer cnt = 0
    Dim As String current = Str(n)
    Dim As String cadena()
    Redim cadena(0)
    cadena(0) = current
    
    While Not isPrimeStr(current)
        Dim As String cat = FactorConcat(current)
        current = cat
        cnt += 1
        Redim Preserve cadena(cnt)
        cadena(cnt) = current
    Wend
    
    If cnt = 0 Then
        Print "HP" & n & " = " & n
    Else
        For i As Integer = 0 To cnt - 1
            Dim As Integer iter = cnt - i
            Print "HP" & cadena(i) & "(" & iter & ") = ";
        Next i
        Print cadena(cnt)
    End If
End Sub

Function HomePrimeFinal(n As Integer) As String
    Dim As String current = Str(n)
    
    While Not isPrimeStr(current)
        current = FactorConcat(current)
    Wend
    
    Return current
End Function

' Main program
Dim As Double t0 = Timer
For k As Integer = 2 To 20
    printHomePrimeChain(k)
Next k
Print !"\nTook"; Timer - t0; " seconds on N95 @1.70 GHz"

Sleep
