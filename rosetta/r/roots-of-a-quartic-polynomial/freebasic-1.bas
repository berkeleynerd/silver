#include "vbcompat.bi"

Const EPS = 1e-12

Type Complex
    real As Double
    imag As Double
End Type

Function CAdd(a As Complex, b As Complex) As Complex
    Return Type(a.real + b.real, a.imag + b.imag)
End Function

Function CSub(a As Complex, b As Complex) As Complex
    Return Type(a.real - b.real, a.imag - b.imag)
End Function

Function CMul(a As Complex, b As Complex) As Complex
    Return Type(a.real*b.real - a.imag*b.imag, a.real*b.imag + a.imag*b.real)
End Function

Function CDiv(a As Complex, b As Complex) As Complex
    Dim d As Double = b.real*b.real + b.imag*b.imag
    Return Type((a.real*b.real + a.imag*b.imag)/d, (a.imag*b.real - a.real*b.imag)/d)
End Function

Function CSqrt(a As Complex) As Complex
    Dim r As Double = Sqr(a.real*a.real + a.imag*a.imag)
    Dim t As Double = Sqr((r + a.real)/2)
    Dim u As Double = Sqr((r - a.real)/2)
    If a.imag < 0 Then u = -u
    Return Type(t, u)
End Function

Function CCbrt(a As Complex) As Complex
    Dim r As Double = Sqr(a.real*a.real + a.imag*a.imag)
    Dim th As Double = Atan2(a.imag, a.real)
    Return Type(r^(1/3) * Cos(th/3), r^(1/3) * Sin(th/3))
End Function

Function CEqual(a As Complex, b As Complex) As Integer
    Return (Abs(a.real - b.real) < EPS And Abs(a.imag - b.imag) < EPS)
End Function

Dim Shared CZERO As Complex = Type(0,0)
Dim Shared CONE  As Complex = Type(1,0)

Type QuadRoots
    r(1) As Complex
End Type

Type BiquadRoots
    r(3) As Complex
End Type

Type QuarticRoots
    r(3) As Complex
End Type

' Quadratic solver
Function quadratic(a0 As Complex, b0 As Complex, c0 As Complex) As QuadRoots
    Dim a1 As Complex = CDiv(b0, a0)
    Dim b As Complex = CDiv(c0, a0)
    Dim a2 As Complex = Type(-a1.real*0.5, -a1.imag*0.5)
    Dim d As Complex = CSub(CMul(a2,a2), b)
    Dim sqd As Complex = CSqrt(d)
    
    Dim q As QuadRoots
    q.r(0) = CSub(a2, sqd)
    q.r(1) = CAdd(a2, sqd)
    Return q
End Function

' Biquadratic solver
Function biquadratic(a0 As Double, c0 As Double, e0 As Double) As BiquadRoots
    Dim q As QuadRoots = quadratic(Type(a0,0), Type(c0,0), Type(e0,0))
    Dim r1 As Complex = CSqrt(q.r(0))
    Dim r2 As Complex = CSqrt(q.r(1))
    
    Dim bq As BiquadRoots
    bq.r(0) = Type(-r1.real, -r1.imag)
    bq.r(1) = r1
    bq.r(2) = Type(-r2.real, -r2.imag)
    bq.r(3) = r2
    Return bq
End Function

' CubicOne – Cardano
Function cubicOne(a0 As Double, b0 As Double, c0 As Double, d0 As Double) As Double
    Dim a As Double = b0 / a0
    Dim b As Double = c0 / a0
    Dim c As Double = d0 / a0
    
    Dim third As Double = 1/3
    Dim a13 As Double = a * third
    Dim a2 As Double = a13 * a13
    Dim f As Double = third*b - a2
    Dim g As Double = a13*(2*a2 - b) + c
    Dim h As Double = 0.25*g*g + f*f*f
    
    If f = 0 And g = 0 And h = 0 Then
        Return -Sgn(c) * Abs(c)^(1/3)
    Elseif h <= 0 Then
        Dim j As Double = Sqr(-f)
        Dim x As Double = -0.5*g / (j*j*j)
        If x > 1 Then x = 1
        If x < -1 Then x = -1
        Dim k As Double = Acos(x)
        Return 2*j*Cos(third*k) - a13
    Else
        Dim sqh As Double = Sqr(h)
        Dim A As Double = -0.5*g + sqh
        Dim B As Double = -0.5*g - sqh
        Dim s As Double = Sgn(A) * Abs(A)^(1/3)
        Dim u As Double = Sgn(B) * Abs(B)^(1/3)
        Return s + u - a13
    End If
End Function

' Quartic solver (Ferrari)
Function quartic(a0 As Double, b0 As Double, c0 As Double, d0 As Double, e0 As Double) As QuarticRoots
    If b0 = 0 And d0 = 0 Then
        Dim bi As BiquadRoots = biquadratic(a0, c0, e0)
        Dim qr As QuarticRoots
        qr.r(0) = bi.r(0)
        qr.r(1) = bi.r(1)
        qr.r(2) = bi.r(2)
        qr.r(3) = bi.r(3)
        Return qr
    End If
    
    Dim a As Double = b0 / a0
    Dim b As Double = c0 / a0
    Dim c As Double = d0 / a0
    Dim d As Double = e0 / a0
    
    Dim shift As Double = 0.25 * a
    Dim shift2 As Double = shift * shift
    
    Dim p As Double = 3*shift2 - 0.5*b
    Dim q As Double = a*shift2 - b*shift + 0.5*c
    Dim r As Double = 3*shift2*shift2 - b*shift2 + c*shift - d
    
    Dim z0 As Double = cubicOne(1, p, r, p*r - 0.5*q*q)
    
    Dim s As Complex = CSqrt(Type(2*p + 2*z0, 0))
    Dim t As Complex
    
    If CEqual(s, CZERO) Then
        t = Type(z0*z0 + r, 0)
    Else
        t = CDiv(Type(-q,0), s)
    End If
    
    Dim q1 As QuadRoots = quadratic(CONE, s, CAdd(t, Type(z0,0)))
    Dim q2 As QuadRoots = quadratic(CONE, Type(-s.real,-s.imag), CAdd(Type(-t.real,-t.imag), Type(z0,0)))
    
    Dim qr As QuarticRoots
    qr.r(0) = CSub(q1.r(0), Type(shift,0))
    qr.r(1) = CSub(q1.r(1), Type(shift,0))
    qr.r(2) = CSub(q2.r(0), Type(shift,0))
    qr.r(3) = CSub(q2.r(1), Type(shift,0))
    
    Return qr
End Function

' Formatting helpers
Function FormatReal(x As Double) As String
    If Abs(x) < EPS Then x = 0
    Dim s As String = Trim(Str(x))
    Return s
End Function

Function FormatComplex(c As Complex) As String
    Dim re As Double = c.real
    Dim im As Double = c.imag
    
    If Abs(re) < EPS Then re = 0
    If Abs(im) < EPS Then im = 0
    
    Dim sRe As String = FormatReal(re)
    
    If im = 0 Then Return sRe
    
    Dim signo As String = Iif(im < 0, "-", "+")
    Dim absIm As Double = Abs(im)
    
    Dim sIm As String
    If absIm = 1 Then sIm = "i" Else sIm = FormatReal(absIm) & "i"
    
    If re = 0 Then Return Iif(im < 0, "-", "") & sIm
    
    Return sRe & " " & signo & " " & sIm
End Function

Sub PrintEquation(p() As Double)
    Dim firstPrinted As Boolean = False
    Dim term As String
    
    For n As Integer = 0 To 4
        Dim coef As Double = p(n)
        Dim pow As Integer = 4 - n
        
        If Abs(coef) < EPS Then Continue For
        
        If pow = 0 Then
            term = FormatReal(coef)
        Else
            If pow = 1 Then
                If coef = 1 Then
                    term = "x"
                Elseif coef = -1 Then
                    term = "-x"
                Else
                    term = FormatReal(coef) & "x"
                End If
            Else
                If coef = 1 Then
                    term = "x^" & pow
                Elseif coef = -1 Then
                    term = "-x^" & pow
                Else
                    term = FormatReal(coef) & "x^" & pow
                End If
            End If
        End If
        
        If Not firstPrinted Then
            Print term;
            firstPrinted = True
        Else
            If coef > 0 Then
                Print " + " & term;
            Else
                Print " - " & Mid(term, 2);
            End If
        End If
    Next
    
    Print " = 0"
End Sub

' Main program
Dim As Double tmp(4)
Dim As Double polys(11, 4) = { _
{3, 6, -123, -126, 1080}, _
{-20, 5, 17, -29, 87}, _
{2, 4, 6, 8, 10}, _
{1, -10, 35, -50, 24}, _
{1, 0, 0, 0, -1}, _
{1, 0, 0, 0, 1}, _
{1, 0, 5, 0, 4}, _
{1, -8, 24, -32, 16}, _
{1, -2, 2, -2, 1}, _
{3, -7, 2, 5, -1}, _
{1.2345, 12.345, 123.45, 1234.5, 12345}, _
{1, -6, 15, -18, 10} }

Print "ROOTS OF A QUARTIC POLYNOMIAL"
Print "FreeBASIC numeric implementation - ";
Print Format(Now, "dd/mm/yyyy") 

For i As Integer = 0 To 11
    Print : Print "Equation ";
    For j As Integer = 0 To 4
        tmp(j) = polys(i, j)
    Next
    PrintEquation(tmp())
    
    Dim r As QuarticRoots = quartic(polys(i, 0), polys(i, 1), polys(i, 2), polys(i, 3), polys(i, 4))
    
    For k As Integer = 0 To 3
        Print "  Root " & k+1 & ": " & FormatComplex(r.r(k))
    Next
Next


Sleep
