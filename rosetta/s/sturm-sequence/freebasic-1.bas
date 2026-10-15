Type Poly
    c(Any) As Double
End Type

Function PolyCnt(Byref p As Poly) As Integer
    If Ubound(p.c) < Lbound(p.c) Then Return 0
    Return Ubound(p.c) - Lbound(p.c) + 1
End Function

Function MakePoly(values() As Double) As Poly
    Dim p As Poly
    Dim n As Integer = Ubound(values) - Lbound(values) + 1
    
    Redim p.c(0 To n - 1)
    For i As Integer = 0 To n - 1
        p.c(i) = values(Lbound(values) + i)
    Next
    
    Return p
End Function

Function TrimPoly(Byref p As Poly) As Poly
    Dim n As Integer = PolyCnt(p)
    Dim first As Integer = 0
    While first < n Andalso p.c(first) = 0.0
        first += 1
    Wend
    If first = n Then
        Dim z As Poly: Redim z.c(0)
        z.c(0) = 0.0
        Return z
    End If
    
    Dim r As Poly: Redim r.c(0 To n - first - 1)
    For i As Integer = 0 To n - first - 1
        r.c(i) = p.c(first + i)
    Next
    
    Return r
End Function

Function isZeroPoly(Byref p As Poly) As Integer
    Dim q As Poly = TrimPoly(p)
    Return PolyCnt(q) = 1 Andalso q.c(0) = 0.0
End Function

Function EvalPoly(Byref p As Poly, Byval x As Double) As Double
    Dim n As Integer = PolyCnt(p)
    If n = 0 Then Return 0.0
    
    Dim result As Double = p.c(0)
    For i As Integer = 1 To n - 1
        result = result * x + p.c(i)
    Next
    
    Return result
End Function

Function Derivative(Byref p As Poly) As Poly
    Dim n As Integer = PolyCnt(p)
    Dim result As Poly
    If n <= 1 Then
        Redim result.c(0)
        result.c(0) = 0.0
        Return result
    End If
    
    Redim result.c(0 To n - 2)
    For i As Integer = 0 To n - 2
        result.c(i) = p.c(i) * (n - i - 1)
    Next
    
    Return result
End Function

Function MakeMonic(Byref p As Poly) As Poly
    Dim q As Poly = TrimPoly(p)
    Dim n As Integer = PolyCnt(q)
    Dim prinpl As Double = q.c(0)
    Dim result As Poly: Redim result.c(0 To n - 1)
    For i As Integer = 0 To n - 1
        result.c(i) = q.c(i) / prinpl
    Next
    
    Return result
End Function

Sub DividePolynomial(Byref dividndSource As Poly, Byref divisorSource As Poly, quotient As Poly, remainder As Poly)
    Dim dividnd As Poly = TrimPoly(dividndSource)
    Dim divisor As Poly = TrimPoly(divisorSource)
    Dim dividndCnt As Integer = PolyCnt(dividnd)
    Dim divisorCnt As Integer = PolyCnt(divisor)
    
    If isZeroPoly(divisor) Then
        Print "Error: division by zero polynomial."
        Sleep: End
    End If
    
    If dividndCnt < divisorCnt Then
        Redim quotient.c(0)
        quotient.c(0) = 0.0
        remainder = dividnd
        Exit Sub
    End If
    
    Dim quotientCnt As Integer = dividndCnt - divisorCnt + 1
    Redim quotient.c(0 To quotientCnt - 1)
    
    Dim work() As Double: Redim work(0 To dividndCnt - 1)
    For i As Integer = 0 To dividndCnt - 1
        work(i) = dividnd.c(i)
    Next
    
    For i As Integer = 0 To quotientCnt - 1
        Dim factor As Double = work(i) / divisor.c(0)
        quotient.c(i) = factor
        If factor <> 0.0 Then
            For j As Integer = 0 To divisorCnt - 1
                work(i + j) -= factor * divisor.c(j)
            Next
        End If
    Next
    
    Dim remainderCnt As Integer = dividndCnt - quotientCnt
    If remainderCnt <= 0 Then
        Redim remainder.c(0)
        remainder.c(0) = 0.0
    Else
        Redim remainder.c(0 To remainderCnt - 1)
        For i As Integer = 0 To remainderCnt - 1
            remainder.c(i) = work(quotientCnt + i)
        Next
        remainder = TrimPoly(remainder)
    End If
End Sub

Sub SturmSequence(Byref polynomial As Poly, sequence() As Poly, Byref sequenceCnt As Integer)
    Dim first As Poly = TrimPoly(polynomial)
    Dim secon As Poly = Derivative(first)
    
    Erase sequence
    Redim sequence(0 To 1)
    sequence(0) = first
    sequence(1) = TrimPoly(secon)
    sequenceCnt = 2
    
    Do
        Dim a As Poly = sequence(sequenceCnt - 2)
        Dim b As Poly = sequence(sequenceCnt - 1)
        If isZeroPoly(b) Then Exit Do
        
        Dim As Poly quotient, remainder
        DividePolynomial(a, b, quotient, remainder)
        remainder = TrimPoly(remainder)
        If isZeroPoly(remainder) Then Exit Do
        
        For i As Integer = 0 To PolyCnt(remainder) - 1
            remainder.c(i) = -remainder.c(i)
        Next
        
        Redim Preserve sequence(0 To sequenceCnt)
        sequence(sequenceCnt) = remainder
        sequenceCnt += 1
        
        If PolyCnt(remainder) = 1 Then Exit Do
    Loop
End Sub

Function Variations(sequence() As Poly, Byval sequenceCnt As Integer, Byval x As Double) As Integer
    Dim As Integer changes = 0, lastSign = 0
    
    For i As Integer = 0 To sequenceCnt - 1
        Dim value As Double = EvalPoly(sequence(i), x)
        If value <> 0.0 Then
            Dim currentSign As Integer = Iif(value > 0.0, 1, -1)
            If lastSign <> 0 Andalso currentSign <> lastSign Then changes += 1
            lastSign = currentSign
        End If
    Next
    
    Return changes
End Function

Function SturmRootCnt(sequence() As Poly, Byval sequenceCnt As Integer, Byval a As Double, Byval b As Double) As Integer
    Return Variations(sequence(), sequenceCnt, a) - Variations(sequence(), sequenceCnt, b)
End Function

Sub AddRoot(roots() As Double, Byref rootCnt As Integer, Byval rootValue As Double)
    Dim value As Double = rootValue
    If Abs(value) < 1.0e-10 Then value = 0.0
    
    If rootCnt > 0 Then
        If Abs(value - roots(rootCnt - 1)) <= 1.0e-10 * (1.0 + Abs(value)) Then Exit Sub
    End If
    
    Redim Preserve roots(0 To rootCnt)
    roots(rootCnt) = value
    rootCnt += 1
End Sub

Sub IsolateRoots(sequence() As Poly, Byval sequenceCnt As Integer, Byref monic As Poly, Byval lo As Double, Byval hi As Double, Byval tolerance As Double, Byval maxBisections As Integer, roots() As Double, Byref rootCnt As Integer)
    Dim intervalCnt As Integer = SturmRootCnt(sequence(), sequenceCnt, lo, hi)
    If intervalCnt <= 0 Then Exit Sub
    
    If intervalCnt = 1 Then
        Dim As Double izda = lo, dcha = hi, middle
        
        For stepNumber As Integer = 1 To maxBisections
            middle = (izda + dcha) / 2.0
            If dcha - izda <= tolerance * (1.0 + Abs(izda) + Abs(dcha)) Then Exit For
            
            If SturmRootCnt(sequence(), sequenceCnt, izda, middle) > 0 Then
                dcha = middle
            Else
                izda = middle
            End If
        Next
        
        middle = (izda + dcha) / 2.0
        
        Dim derivativePolynomial As Poly = Derivative(monic)
        Dim derivativeValue As Double = EvalPoly(derivativePolynomial, middle)
        
        If Abs(derivativeValue) > 1.0e-30 Then
            Dim candidate As Double = middle - EvalPoly(monic, middle) / derivativeValue
            If candidate >= izda Andalso candidate <= dcha Then middle = candidate
        End If
        
        AddRoot(roots(), rootCnt, middle)
        Exit Sub
    End If
    
    Dim middle As Double = (lo + hi) / 2.0
    If middle <= lo Orelse middle >= hi Then Exit Sub
    
    IsolateRoots(sequence(), sequenceCnt, monic, lo, middle, tolerance, maxBisections, roots(), rootCnt)
    IsolateRoots(sequence(), sequenceCnt, monic, middle, hi, tolerance, maxBisections, roots(), rootCnt)
End Sub

Function RealRoots(Byref coefficients As Poly, Byval tolerance As Double, Byval maxBisections As Integer, roots() As Double) As Integer
    Dim polynomial As Poly = TrimPoly(coefficients)
    Erase roots
    
    If PolyCnt(polynomial) = 0 Then Return 0
    If isZeroPoly(polynomial) Then Return 0
    
    Dim monic As Poly = MakeMonic(polynomial)
    Dim bound As Double = 1.0
    
    For i As Integer = 1 To PolyCnt(monic) - 1
        Dim candidateBound As Double = 1.0 + Abs(monic.c(i))
        If candidateBound > bound Then bound = candidateBound
    Next
    
    Dim sequence() As Poly
    Dim sequenceCnt As Integer
    SturmSequence(monic, sequence(), sequenceCnt)
    
    Dim rootCnt As Integer = 0
    IsolateRoots(sequence(), sequenceCnt, monic, -bound, bound, tolerance, maxBisections, roots(), rootCnt)
    
    Return rootCnt
End Function

Function NumberText(Byval value As Double) As String
    If Abs(value) < 0.5e-12 Then value = 0.0
    Return Trim(Str(value))
End Function

Function PolynomialText(Byref polynomial As Poly) As String
    Dim result As String = ""
    Dim degree As Integer = PolyCnt(polynomial) - 1
    
    For i As Integer = 0 To degree
        Dim coefficient As Double = polynomial.c(i)
        Dim power As Integer = degree - i
        If coefficient = 0.0 Then Continue For
        
        Dim negative As Integer = coefficient < 0.0
        Dim magnitude As Double = Abs(coefficient)
        
        If result <> "" Then
            'If negative Then result &= " - " Else result &= " + "
            result &= Iif(negative, " - ", " + ")
        Elseif negative Then
            result = "-"
        End If
        
        If power = 0 Then
            result &= NumberText(magnitude)
        Else
            If magnitude <> 1.0 Then result &= NumberText(magnitude)
            result &= "x"
            If power > 1 Then result &= "^" & Trim(Str(power))
        End If
    Next
    
    If result = "" Orelse result = "-" Then result &= "0"
    Return result
End Function

' Programa principal
Dim polynomials(0 To 37) As Poly
' linear
Dim p0(0 To 1) As Double => {1, 0}
Dim p1(0 To 1) As Double => {1, -1}
Dim p2(0 To 1) As Double => {1, 3.14159265}
' Quadratic
Dim p3(0 To 2) As Double => {1, -1.0e9, 1}
Dim p4(0 To 2) As Double => {1, 0, 1}
Dim p5(0 To 2) As Double => {1, 2, 1}
Dim p6(0 To 2) As Double => {2, -1, -6}
Dim p7(0 To 2) As Double => {1, 2, -2}
Dim p8(0 To 2) As Double => {1, 3, 2}
Dim p9(0 To 2) As Double => {3, 4, 5}
Dim p10(0 To 2) As Double => {2, -1.00000001, 1.0e9}
Dim p11(0 To 2) As Double => {1.0e9, 1.23456789, -1.0e9}
' Cubic
Dim p12(0 To 3) As Double => {1, -3, 3, -1}
Dim p13(0 To 3) As Double => {1, -4, -27, 90}
Dim p14(0 To 3) As Double => {1, 0, -3, -2}
Dim p15(0 To 3) As Double => {1, -14, 35, -22}
Dim p16(0 To 3) As Double => {1, -2.41421356, 2.41421356, -1}
' Quartic
Dim p17(0 To 3) As Double => {3, -117, -126, 1080}
Dim p18(0 To 4) As Double => {-20, 5, 17, -29, 87}
Dim p19(0 To 4) As Double => {2, 4, 6, 8, 10}
Dim p20(0 To 4) As Double => {1, 0, 0, 0, 0}
Dim p21(0 To 4) As Double => {1, 0, 0, 0, -1}
Dim p22(0 To 4) As Double => {1, 0, 0, 0, 1}
Dim p23(0 To 4) As Double => {1, 0, 5, 0, 4}
Dim p24(0 To 4) As Double => {1, -10, 35, -50, 24}
Dim p25(0 To 4) As Double => {1, -8, 24, -32, 16}
Dim p26(0 To 4) As Double => {1, -2, 2, -2, 1}
Dim p27(0 To 4) As Double => {3, -7, 2, 5, -1}
Dim p28(0 To 4) As Double => {1, -6, 15, -18, 10}
Dim p29(0 To 4) As Double => {1.2345, 12.345, 123.45, 1234.5, 12345}
Dim p30(0 To 4) As Double => {1, -3e8, 2e16, -6e7, 4e-2}
' order 5 and up
Dim p31(0 To 5) As Double => {3, -6, -8, 5, -8, 7}
Dim p32(0 To 6) As Double => {-8, -4, 0, 8, -7, -7, 9}
Dim p33(0 To 7) As Double => {-8, 8, 5, 8, 5, -1, -3, 1}
Dim p34(0 To 8) As Double => {-5, 1, 4, 7, 0, -5, 1, 3, 3}
Dim p35(0 To 9) As Double => {3, 5, -1, 2, -9, -1, 4, 5, -7, -1}
Dim p36(0 To 10) As Double => {1,  55, 1320, 18150, 157773, 902055, 3416930, 8409500, 12753576, 10628640, 3628800}
' Conway's constant
Dim p37(0 To 71) As Double => {1, 0, -1, -2, -1, 2, 2, 1, -1, -1, -1, -1, -1, 2, 5, 3, -2, -10, -3, -2, 6, 6, 1, 9, -3, _
-7, -8, -8, 10, 6, 8, -5, -12, 7, -7, 7, 1, -3, 10, 1, -6, -2, -10, -3, 2, 9, -3, 14, -8,_
0, -7, 9, 3, -4, -10, -7, 12, 7, 2, -12, -4, -2, 5, 0, 1, -7, 7, -4, 12, -6, 3, -6}

polynomials(0)  = MakePoly(p0()):  polynomials(1)  = MakePoly(p1())
polynomials(2)  = MakePoly(p2()):  polynomials(2)  = MakePoly(p2())
polynomials(3)  = MakePoly(p3()):  polynomials(4)  = MakePoly(p4())
polynomials(5)  = MakePoly(p5()):  polynomials(6)  = MakePoly(p6())
polynomials(7)  = MakePoly(p7()):  polynomials(8)  = MakePoly(p8())
polynomials(9)  = MakePoly(p9()):  polynomials(10) = MakePoly(p10())
polynomials(11) = MakePoly(p11()): polynomials(12) = MakePoly(p12())
polynomials(13) = MakePoly(p13()): polynomials(14) = MakePoly(p14())
polynomials(15) = MakePoly(p15()): polynomials(16) = MakePoly(p16())
polynomials(17) = MakePoly(p17()): polynomials(18) = MakePoly(p18())
polynomials(19) = MakePoly(p19()): polynomials(20) = MakePoly(p20())
polynomials(21) = MakePoly(p21()): polynomials(22) = MakePoly(p22())
polynomials(23) = MakePoly(p23()): polynomials(24) = MakePoly(p24())
polynomials(25) = MakePoly(p25()): polynomials(26) = MakePoly(p26())
polynomials(27) = MakePoly(p27()): polynomials(28) = MakePoly(p28())
polynomials(29) = MakePoly(p29()): polynomials(30) = MakePoly(p30())
polynomials(31) = MakePoly(p31()): polynomials(32) = MakePoly(p32())
polynomials(33) = MakePoly(p33()): polynomials(34) = MakePoly(p34())
polynomials(35) = MakePoly(p35()): polynomials(36) = MakePoly(p36())
polynomials(37) = MakePoly(p37())

For polynomialIndex As Integer = Lbound(polynomials) To Ubound(polynomials)
    Dim roots() As Double
    Dim rootCnt As Integer = RealRoots(polynomials(polynomialIndex), 1.0e-10, 100, roots())
    
    Print PolynomialText(polynomials(polynomialIndex))
    
    If rootCnt = 0 Then
        Print "  No real roots"
    Else
        For i As Integer = 0 To rootCnt - 1
            Print "  Root " & i + 1 & ": " & NumberText(roots(i)) & " (Evaluates to " & NumberText(EvalPoly(polynomials(polynomialIndex), roots(i))) & ")"
        Next
    End If
    
    Print
Next

Sleep
