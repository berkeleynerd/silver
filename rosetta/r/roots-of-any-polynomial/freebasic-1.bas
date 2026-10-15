Const As Single PI = 4 * Atn(1.0)

Type Complex
    re As Double
    im As Double
End Type

Function CAdd(a As Complex, b As Complex) As Complex
    Dim As Complex result
    result.re = a.re + b.re
    result.im = a.im + b.im
    Return result
End Function

Function CSub(a As Complex, b As Complex) As Complex
    Dim As Complex result
    result.re = a.re - b.re
    result.im = a.im - b.im
    Return result
End Function

Function CMul(a As Complex, b As Complex) As Complex
    Dim As Complex result
    result.re = a.re * b.re - a.im * b.im
    result.im = a.re * b.im + a.im * b.re
    Return result
End Function

Function CDiv(a As Complex, b As Complex) As Complex
    Dim As Complex result
    Dim As Double denom = b.re * b.re + b.im * b.im
    If denom = 0 Then
        result.re = 1e308
        result.im = 0
    Else
        result.re = (a.re * b.re + a.im * b.im) / denom
        result.im = (a.im * b.re - a.re * b.im) / denom
    End If
    Return result
End Function

Function CMag(a As Complex) As Double
    Return Sqr(a.re * a.re + a.im * a.im)
End Function

Function CStr(a As Complex) As String
    Dim As String s
    If a.im = 0 Then
        s = Str(a.re)
    Elseif a.im > 0 Then
        s = Str(a.re) & " + " & Str(a.im) & "i"
    Else
        s = Str(a.re) & " - " & Str(-a.im) & "i"
    End If
    Return s
End Function

Function EvalPoly(coeffs() As Double, degree As Integer, x As Complex) As Complex
    Dim As Complex result
    result.re = coeffs(0)
    result.im = 0
    
    For i As Integer = 1 To degree
        Dim As Double new_re = result.re * x.re - result.im * x.im + coeffs(i)
        Dim As Double new_im = result.re * x.im + result.im * x.re
        result.re = new_re
        result.im = new_im
    Next
    
    Return result
End Function

Sub FindRoots(coeffs() As Double, degree As Integer, roots() As Complex)
    Dim As Integer i, j, n = degree
    
    If n <= 0 Then
        Redim roots(0 To -1)
        Exit Sub
    End If
    
    Redim roots(0 To n - 1)
    
    If n = 1 Then
        If coeffs(0) <> 0 Then
            roots(0).re = -coeffs(1) / coeffs(0)
            roots(0).im = 0
        Else
            roots(0).re = 0
            roots(0).im = 0
        End If
        Exit Sub
    End If
    
    Dim As Double lead = coeffs(0)
    Dim As Double norm(0 To n)
    For i = 0 To n
        norm(i) = coeffs(i) / lead
    Next
    
    Dim As Double radius = 1.0
    
    For i = 0 To n - 1
        Dim As Double angle = 2 * PI * (i + 0.1) / n
        roots(i).re = radius * Cos(angle)
        roots(i).im = radius * Sin(angle)
    Next
    
    Dim As Integer max_iter = 1000
    Dim As Double tolerance = 1e-12
    
    For iter As Integer = 1 To max_iter
        Dim As Double max_change = 0
        
        Dim As Complex old_roots(0 To n - 1)
        For i = 0 To n - 1
            old_roots(i) = roots(i)
        Next
        
        For i = 0 To n - 1
            Dim As Complex p_val = EvalPoly(norm(), n, old_roots(i))
            
            Dim As Complex denom
            denom.re = 1
            denom.im = 0
            
            For j = 0 To n - 1
                If i <> j Then
                    Dim As Complex diff = CSub(old_roots(i), roots(j))
                    denom = CMul(denom, diff)
                End If
            Next
            
            Dim As Double denom_mag = CMag(denom)
            If denom_mag > 1e-200 Then
                Dim As Complex correction = CDiv(p_val, denom)
                Dim As Complex new_root = CSub(old_roots(i), correction)
                
                Dim As Double change = CMag(CSub(new_root, old_roots(i)))
                If change > max_change Then max_change = change
                
                roots(i) = new_root
            End If
        Next
        
        If max_change < tolerance Then Exit For
    Next
End Sub

Function PolyStr(coeffs() As Double, degree As Integer) As String
    Dim As String result = ""
    Dim As Integer first = 1
    
    For i As Integer = 0 To degree
        If coeffs(i) = 0 Then Continue For
        
        Dim As Double abs_coeff = Abs(coeffs(i))
        Dim As String sign
        If first Then
            If coeffs(i) < 0 Then sign = "-"
        Else
            sign = Iif(coeffs(i) >= 0, " + ", " - ")
        End If
        
        result &= sign
        
        If abs_coeff <> 1 Or degree - i = 0 Then result &= Str(abs_coeff)
        
        If degree - i > 0 Then
            result &= "x"
            If degree - i > 1 Then result &= "^" & Str(degree - i)
        End If
        
        first = 0
    Next
    
    If result = "" Then result = "0"
    
    Return result
End Function


' Main program
' Each row: [degree, coefficients...]
Dim Shared polys(1 To 38, 1 To 72) As Double
Dim Shared poly_degrees(1 To 38) As Integer

' Linear
poly_degrees(1) = 1: polys(1,1) = 1: polys(1,2) = 0
poly_degrees(2) = 1: polys(2,1) = 1: polys(2,2) = -1
poly_degrees(3) = 1: polys(3,1) = 1: polys(3,2) = PI

' Quadratic
poly_degrees(4) = 2: polys(4,1) = 1: polys(4,2) = -1E9: polys(4,3) = 1
poly_degrees(5) = 2: polys(5,1) = 1: polys(5,2) = 0: polys(5,3) = 1
poly_degrees(6) = 2: polys(6,1) = 1: polys(6,2) = 2: polys(6,3) = 1
poly_degrees(7) = 2: polys(7,1) = 2: polys(7,2) = -1: polys(7,3) = -6
poly_degrees(8) = 2: polys(8,1) = 1: polys(8,2) = 2: polys(8,3) = -2
poly_degrees(9) = 2: polys(9,1) = 1: polys(9,2) = 3: polys(9,3) = 2
poly_degrees(10) = 2: polys(10,1) = 3: polys(10,2) = 4: polys(10,3) = 5
poly_degrees(11) = 2: polys(11,1) = 2: polys(11,2) = -1.00000001: polys(11,3) = 1E9
poly_degrees(12) = 2: polys(12,1) = 1E9: polys(12,2) = 1.23456789: polys(12,3) = -1E9

' Cubic
poly_degrees(13) = 3: polys(13,1) = 1: polys(13,2) = -3: polys(13,3) = 3: polys(13,4) = -1
poly_degrees(14) = 3: polys(14,1) = 1: polys(14,2) = -4: polys(14,3) = -27: polys(14,4) = 90
poly_degrees(15) = 3: polys(15,1) = 1: polys(15,2) = 0: polys(15,3) = -3: polys(15,4) = -2
poly_degrees(16) = 3: polys(16,1) = 1: polys(16,2) = -14: polys(16,3) = 35: polys(16,4) = -22
poly_degrees(17) = 3: polys(17,1) = 1: polys(17,2) = -2.41421356: polys(17,3) = 2.41421356: polys(17,4) = -1

' Quartic
poly_degrees(18) = 4: polys(18,1) = 3: polys(18,2) = 6: polys(18,3) = -123: polys(18,4) = -126: polys(18,5) = 1080
poly_degrees(19) = 4: polys(19,1) = -20: polys(19,2) = 5: polys(19,3) = 17: polys(19,4) = -29: polys(19,5) = 87
poly_degrees(20) = 4: polys(20,1) = 2: polys(20,2) = 4: polys(20,3) = 6: polys(20,4) = 8: polys(20,5) = 10
poly_degrees(21) = 4: polys(21,1) = 1: polys(21,2) = 0: polys(21,3) = 0: polys(21,4) = 0: polys(21,5) = 0
poly_degrees(22) = 4: polys(22,1) = 1: polys(22,2) = 0: polys(22,3) = 0: polys(22,4) = 0: polys(22,5) = -1
poly_degrees(23) = 4: polys(23,1) = 1: polys(23,2) = 0: polys(23,3) = 0: polys(23,4) = 0: polys(23,5) = 1
poly_degrees(24) = 4: polys(24,1) = 1: polys(24,2) = 0: polys(24,3) = 5: polys(24,4) = 0: polys(24,5) = 4
poly_degrees(25) = 4: polys(25,1) = 1: polys(25,2) = -10: polys(25,3) = 35: polys(25,4) = -50: polys(25,5) = 24
poly_degrees(26) = 4: polys(26,1) = 1: polys(26,2) = -8: polys(26,3) = 24: polys(26,4) = -32: polys(26,5) = 16
poly_degrees(27) = 4: polys(27,1) = 1: polys(27,2) = -2: polys(27,3) = 2: polys(27,4) = -2: polys(27,5) = 1
poly_degrees(28) = 4: polys(28,1) = 3: polys(28,2) = -7: polys(28,3) = 2: polys(28,4) = 5: polys(28,5) = -1
poly_degrees(29) = 4: polys(29,1) = 1: polys(29,2) = -6: polys(29,3) = 15: polys(29,4) = -18: polys(29,5) = 10
poly_degrees(30) = 4: polys(30,1) = 1.2345: polys(30,2) = 12.345: polys(30,3) = 123.45: polys(30,4) = 1234.5: polys(30,5) = 12345
poly_degrees(31) = 4: polys(31,1) = 1: polys(31,2) = -3E8: polys(31,3) = 2E16: polys(31,4) = -6E7: polys(31,5) = 4E-2

' Higher (grado 5-10)
poly_degrees(32) = 5: polys(32,1) = 3: polys(32,2) = -6: polys(32,3) = -8: polys(32,4) = 5: polys(32,5) = -8: polys(32,6) = 7
poly_degrees(33) = 6: polys(33,1) = -8: polys(33,2) = -4: polys(33,3) = 0: polys(33,4) = 8: polys(33,5) = -7: polys(33,6) = -7: polys(33,7) = 9
poly_degrees(34) = 7: polys(34,1) = -8: polys(34,2) = 8: polys(34,3) = 5: polys(34,4) = 8: polys(34,5) = 5: polys(34,6) = -1: polys(34,7) = -3: polys(34,8) = 1
poly_degrees(35) = 8: polys(35,1) = -5: polys(35,2) = 1: polys(35,3) = 4: polys(35,4) = 7: polys(35,5) = 0: polys(35,6) = -5: polys(35,7) = 1: polys(35,8) = 3: polys(35,9) = 3
poly_degrees(36) = 9: polys(36,1) = 3: polys(36,2) = 5: polys(36,3) = -1: polys(36,4) = 2: polys(36,5) = -9: polys(36,6) = -1: polys(36,7) = 4: polys(36,8) = 5: polys(36,9) = -7: polys(36,10) = -1
poly_degrees(37) = 10: polys(37,1) = 1: polys(37,2) = 55: polys(37,3) = 1320: polys(37,4) = 18150: polys(37,5) = 157773: polys(37,6) = 902055: polys(37,7) = 3416930: polys(37,8) = 8409500: polys(37,9) = 12753576: polys(37,10) = 10628640: polys(37,11) = 3628800

' Conway's constant (grado 71)
poly_degrees(38) = 71
polys(38,1) = 1: polys(38,2) = 0: polys(38,3) = -1: polys(38,4) = -2: polys(38,5) = -1
polys(38,6) = 2: polys(38,7) = 2: polys(38,8) = 1: polys(38,9) = -1: polys(38,10) = -1
polys(38,11) = -1: polys(38,12) = -1: polys(38,13) = -1: polys(38,14) = 2: polys(38,15) = 5
polys(38,16) = 3: polys(38,17) = -2: polys(38,18) = -10: polys(38,19) = -3: polys(38,20) = -2
polys(38,21) = 6: polys(38,22) = 6: polys(38,23) = 1: polys(38,24) = 9: polys(38,25) = -3
polys(38,26) = -7: polys(38,27) = -8: polys(38,28) = -8: polys(38,29) = 10: polys(38,30) = 6
polys(38,31) = 8: polys(38,32) = -5: polys(38,33) = -12: polys(38,34) = 7: polys(38,35) = -7
polys(38,36) = 7: polys(38,37) = 1: polys(38,38) = -3: polys(38,39) = 10: polys(38,40) = 1
polys(38,41) = -6: polys(38,42) = -2: polys(38,43) = -10: polys(38,44) = -3: polys(38,45) = 2
polys(38,46) = 9: polys(38,47) = -3: polys(38,48) = 14: polys(38,49) = -8: polys(38,50) = 0
polys(38,51) = -7: polys(38,52) = 9: polys(38,53) = 3: polys(38,54) = -4: polys(38,55) = -10
polys(38,56) = -7: polys(38,57) = 12: polys(38,58) = 7: polys(38,59) = 2: polys(38,60) = -12
polys(38,61) = -4: polys(38,62) = -2: polys(38,63) = 5: polys(38,64) = 0: polys(38,65) = 1
polys(38,66) = -7: polys(38,67) = 7: polys(38,68) = -4: polys(38,69) = 12: polys(38,70) = -6
polys(38,71) = 3: polys(38,72) = -6

Dim As Integer ini_poly = 1
Dim As Integer end_poly = 38

For p As Integer = ini_poly To end_poly
    Dim As Integer deg = poly_degrees(p)
    
    Dim As Double coeffs(0 To deg)
    For j As Integer = 0 To deg
        coeffs(j) = polys(p, j + 1)
    Next
    
    Print PolyStr(coeffs(), deg)
    
    Dim As Complex roots()
    FindRoots(coeffs(), deg, roots())
    
    For i As Integer = 0 To Ubound(roots)
        Dim As Complex r = roots(i)
        Dim As Complex eval = EvalPoly(coeffs(), deg, r)
        Print "  Root " & (i + 1) & ": " & CStr(r) & " (Evaluates to " & CStr(eval) & ")"
    Next
    
    Print
Next

Sleep
