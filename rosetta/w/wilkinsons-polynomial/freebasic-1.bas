#define max(a, b) iif((a) > (b),(a),(b))

Const As Integer DEG = 20

Type Poly
    c(Any) As Double
    n As Integer   ' number of coefficients
End Type

Function PolyCnt(Byref p As Poly) As Integer
    If Ubound(p.c) < Lbound(p.c) Then Return 0
    Return Ubound(p.c) - Lbound(p.c) + 1
End Function

Sub InitPoly(Byref p As Poly, Byval size As Integer)
    p.n = size
    Redim p.c(0 To size - 1)
End Sub

Function MakePoly(values() As Double) As Poly
    Dim p As Poly
    Dim n As Integer = Ubound(values) - Lbound(values) + 1
    
    InitPoly(p, n)
    For i As Integer = 0 To n - 1
        p.c(i) = values(Lbound(values) + i)
    Next
    
    Return p
End Function

Function TrimPoly(Byref p As Poly) As Poly
    Dim first As Integer = 0
    While first < p.n And p.c(first) = 0.0
        first += 1
    Wend
    
    If first = p.n Then
        Dim z As Poly
        InitPoly(z, 1)
        z.c(0) = 0.0
        Return z
    End If
    
    Dim r As Poly
    InitPoly(r, p.n - first)
    For i As Integer = 0 To r.n - 1
        r.c(i) = p.c(first + i)
    Next
    Return r
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
    If p.n <= 1 Then
        Dim z As Poly
        InitPoly(z, 1)
        z.c(0) = 0.0
        Return z
    End If
    
    Dim r As Poly
    InitPoly(r, p.n - 1)
    Dim degr As Integer = p.n - 1
    For i As Integer = 0 To degr - 1
        r.c(i) = p.c(i) * (degr - i)
    Next
    Return r
End Function

Function MakeMonic(Byref p As Poly) As Poly
    Dim q As Poly = TrimPoly(p)
    Dim lead As Double = q.c(0)
    
    Dim r As Poly
    InitPoly(r, q.n)
    For i As Integer = 0 To q.n - 1
        r.c(i) = q.c(i) / lead
    Next
    Return r
End Function

Sub DividePolynomial(Byref a As Poly, Byref b As Poly, Byref q As Poly, Byref r As Poly)
    Dim nA As Integer = a.n
    Dim nB As Integer = b.n
    Dim As Integer i, j
    
    If nA < nB Then
        InitPoly(q, 1)
        q.c(0) = 0.0
        r = a
        Exit Sub
    End If
    
    Dim qn As Integer = nA - nB + 1
    InitPoly(q, qn)
    
    Dim work() As Double: Redim work(0 To nA - 1)
    For i = 0 To nA - 1
        work(i) = a.c(i)
    Next
    
    Dim lead As Double = b.c(0)
    
    For i = 0 To qn - 1
        Dim factor As Double = work(i) / lead
        q.c(i) = factor
        
        If factor <> 0.0 Then
            For j = 0 To nB - 1
                work(i + j) -= factor * b.c(j)
            Next
        End If
    Next
    
    Dim rn As Integer = nA - qn
    If rn <= 0 Then
        InitPoly(r, 1)
        r.c(0) = 0.0
    Else
        InitPoly(r, rn)
        For i = 0 To rn - 1
            r.c(i) = work(qn + i)
        Next
        r = TrimPoly(r)
    End If
End Sub

Sub SturmSequence(Byref polynomial As Poly, sequence() As Poly, Byref cnt As Integer)
    Dim first As Poly = TrimPoly(polynomial)
    Dim secon As Poly = Derivative(first)
    
    Redim sequence(0 To 1)
    sequence(0) = first
    sequence(1) = TrimPoly(secon)
    cnt = 2
    
    Do
        Dim a As Poly = sequence(cnt - 2)
        Dim b As Poly = sequence(cnt - 1)
        If b.n = 1 And b.c(0) = 0.0 Then Exit Do
        
        Dim q As Poly, r As Poly
        DividePolynomial(a, b, q, r)
        r = TrimPoly(r)
        
        If r.n = 1 And r.c(0) = 0.0 Then Exit Do
        
        For i As Integer = 0 To r.n - 1
            r.c(i) = -r.c(i)
        Next
        
        Redim Preserve sequence(0 To cnt)
        sequence(cnt) = r
        cnt += 1
        
        If r.n = 1 Then Exit Do
    Loop
End Sub

Function Variations(sequence() As Poly, Byval cnt As Integer, Byval x As Double) As Integer
    Dim changes As Integer = 0
    Dim lastSign As Integer = 0
    
    For i As Integer = 0 To cnt - 1
        Dim v As Double = EvalPoly(sequence(i), x)
        If v <> 0.0 Then
            Dim currentSign As Integer = Iif(v > 0.0, 1, -1)
            If lastSign <> 0 Andalso currentSign <> lastSign Then changes += 1
            lastSign = currentSign
        End If
    Next
    
    Return changes
End Function

Function SturmRootCnt(sequence() As Poly, Byval cnt As Integer, Byval a As Double, Byval b As Double) As Integer
    Return Variations(sequence(), cnt, a) - Variations(sequence(), cnt, b)
End Function

Sub AddRoot(roots() As Double, Byref n As Integer, Byval x As Double)
    If Abs(x) < 1e-10 Then x = 0.0
    
    If n > 0 Then
        If Abs(x - roots(n - 1)) <= 1e-10 * (1.0 + Abs(x)) Then Exit Sub
    End If
    
    Redim Preserve roots(0 To n)
    roots(n) = x
    n += 1
End Sub

Sub IsolateRoots(sequence() As Poly, Byval cnt As Integer, Byref polynomial As Poly, _
    Byval lo As Double, Byval hi As Double, Byval tol As Double, Byval maxSteps As Integer, _
    roots() As Double, Byref n As Integer)
    
    Dim k As Integer = SturmRootCnt(sequence(), cnt, lo, hi)
    If k <= 0 Then Exit Sub
    
    If k = 1 Then
        Dim As Double izda = lo, dcha = hi, middle
        
        For paso As Integer = 1 To maxSteps
            middle = (izda + dcha) / 2.0
            If dcha - izda <= tol * (1.0 + Abs(izda) + Abs(dcha)) Then Exit For
            
            If SturmRootCnt(sequence(), cnt, izda, middle) > 0 Then
                dcha = middle
            Else
                izda = middle
            End If
        Next
        
        middle = (izda + dcha) / 2.0
        
        Dim dp As Poly = Derivative(polynomial)
        Dim dv As Double = EvalPoly(dp, middle)
        
        If Abs(dv) > 1e-30 Then
            Dim cand As Double = middle - EvalPoly(polynomial, middle) / dv
            If cand >= izda Andalso cand <= dcha Then middle = cand
        End If
        
        AddRoot(roots(), n, middle)
        Exit Sub
    End If
    
    Dim middle As Double = (lo + hi) / 2.0
    If middle <= lo Or middle >= hi Then Exit Sub
    
    IsolateRoots(sequence(), cnt, polynomial, lo, middle, tol, maxSteps, roots(), n)
    IsolateRoots(sequence(), cnt, polynomial, middle, hi, tol, maxSteps, roots(), n)
End Sub

Function RealRoots(Byref polynomial As Poly, Byval tol As Double, Byval maxSteps As Integer, roots() As Double) As Integer
    Dim poly As Poly = TrimPoly(polynomial)
    Erase roots
    
    If poly.n = 0 Then Return 0
    If poly.n = 1 And poly.c(0) = 0.0 Then Return 0
    
    Dim monic As Poly = MakeMonic(poly)
    
    Dim bound As Double = 1.0
    For i As Integer = 1 To monic.n - 1
        bound = Max(bound, 1.0 + Abs(monic.c(i)))
    Next
    
    Dim sequence() As Poly
    Dim cnt As Integer
    SturmSequence(monic, sequence(), cnt)
    
    Dim n As Integer = 0
    IsolateRoots(sequence(), cnt, monic, -bound, bound, tol, maxSteps, roots(), n)
    
    Return n
End Function

Function NumberText(Byval value As Double) As String
    If Abs(value) < 0.5e-12 Then value = 0.0
    Return Trim(Str(value))
End Function

Function PolynomialText(Byref polynomial As Poly) As String
    Dim result As String = ""
    Dim degree As Integer = PolyCnt(polynomial) - 1
    
    For i As Integer = 0 To degree
        Dim coeff As Double = polynomial.c(i)
        Dim power As Integer = degree - i
        If coeff = 0.0 Then Continue For
        
        Dim negative As Integer = coeff < 0.0
        Dim magnitude As Double = Abs(coeff)
        
        If result <> "" Then
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
Dim wpCoeffs(0 To DEG) As Double = { _
1, _
-210, _
20615, _
-1256850, _
53327946, _
-1672280820, _
40171771630, _
-756111184500, _
11310276995381.0, _
-135585182899530.0, _
1307535010540395.0, _
-10142299865511450.0, _
63030812099294896.0, _
-311333643161390640.0, _
1206647803780373360.0, _
-3599979517947607200.0, _
8037811822645051776.0, _
-12870931245150988800.0, _
13803759753640704000.0, _
-8752948036761600000.0, _
2432902008176640000.0 }

' --- REAL ROOTS (Sturm) ---
Dim wp As Poly = MakePoly(wpCoeffs())

Print " --- WILKINSON'S POLYNOMIAL --- "
Print
Print "P(x) = "; PolynomialText(wp)
Print

Dim realRoot() As Double
Dim nReal As Integer = RealRoots(wp, 1e-12, 80, realRoot())

If nReal = 0 Then
    Print "No real roots found."
Else
    For i As Integer = 0 To nReal - 1
        Dim r As Double = realRoot(i)
        Dim v As Double = EvalPoly(wp, r)
        Print Using "  Root ##: "; i + 1;
        Print NumberText(r) & "  (evaluates to " & NumberText(v) & ")"
    Next
End If

Sleep
