#include "big_int/big_integer.bi"

Const SCALE = 80    ' decimal places of internal precision

Type BigFix
    s As Bigint     ' valor * 10^SCALE
End Type

' --- Helpers ---
' Bigint to decimal string (strip leading "+")
Function BigStr(b As Bigint) As String
    Dim As String s = b
    If Left(s, 1) = "+" Then s = Mid(s, 2)
    If s = "" Then s = "0"
    Return s
End Function

' 10^n as Bigint
Function TenPow(n As Integer) As Bigint
    Return ValBigint("1" & String(n, "0"))
End Function

' Integer square root via Newton's method
Function IntSqrt(n As Bigint) As Bigint
    If n <= 1 Then Return n
    Dim As String s = BigStr(n)
    Dim As Bigint x = ValBigint("1" & String((Len(s) + 1) \ 2, "0"))
    Dim As Bigint xnew
    Do
        xnew = (x + n \ x) \ 2
        If xnew >= x Then Exit Do
        x = xnew
    Loop
    Return x
End Function

' Right-align string
Function RAlign(s As String, w As Integer) As String
    Dim As String r = s
    While Len(r) < w
        r = " " & r
    Wend
    Return r
End Function

' --- BigFix functions ---
Function BF_FromString(txt As String) As BigFix
    Dim As Integer p = Instr(txt, ".")
    Dim As String ip, fp
    If p = 0 Then
        ip = txt
        fp = ""
    Else
        ip = Left(txt, p - 1)
        fp = Mid(txt, p + 1)
    End If
    While Len(fp) < SCALE
        fp &= "0"
    Wend
    If Len(fp) > SCALE Then fp = Left(fp, SCALE)
    Dim As BigFix bf
    bf.s = ValBigint(ip & fp)
    Return bf
End Function

Function BF_Add(a As BigFix, b As BigFix) As BigFix
    Dim As BigFix r
    r.s = a.s + b.s
    Return r
End Function

Function BF_Mul(a As BigFix, b As BigFix) As BigFix
    Dim As BigFix r
    r.s = a.s * b.s \ TenPow(SCALE)
    Return r
End Function

Function BF_DivInt(a As BigFix, k As Integer) As BigFix
    Dim As BigFix r
    r.s = a.s \ Bigint(k)
    Return r
End Function

' exp(x) via Taylor series: e^x = sum(x^k / k!)
Function BF_Exp(x As BigFix, terms As Integer) As BigFix
    Dim As BigFix sumv, termv
    termv.s = TenPow(SCALE)        ' 1.0
    sumv = termv
    For k As Integer = 1 To terms
        termv = BF_Mul(termv, x)
        termv = BF_DivInt(termv, k)
        sumv = BF_Add(sumv, termv)
    Next
    Return sumv
End Function

Function BFSqrt(n As Integer) As BigFix
    Dim As BigFix bf
    bf.s = IntSqrt(ValBigint(Str(n) & String(2 * SCALE, "0")))
    Return bf
End Function

' Format BigFix to exactly 'decimals' places (with rounding)
Function BF_Format(bf As BigFix, decimals As Integer) As String
    Dim As Integer trimDigits = SCALE - decimals
    Dim As Bigint rounded
    
    If trimDigits > 0 Then
        Dim As Bigint roundFactor = ValBigint("5" & String(trimDigits - 1, "0"))
        rounded = (bf.s + roundFactor) \ TenPow(trimDigits)
    Else
        rounded = bf.s
    End If
    
    Dim As String raw = BigStr(rounded)
    While Len(raw) <= decimals
        raw = "0" & raw
    Wend
    
    Dim As String intPart = Left(raw, Len(raw) - decimals)
    Dim As String fracPart = Mid(raw, Len(raw) - decimals + 1)
    
    While Len(intPart) > 1 And Left(intPart, 1) = "0"
        intPart = Mid(intPart, 2)
    Wend
    
    Return intPart & "." & fracPart
End Function

' Pi to 100 decimal places
Function PI_String() As String
    Return "3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798"
End Function

' Ramanujan: e^(pi*sqrt(n))
Function RamanujanBF(n As Integer) As BigFix
    Dim As BigFix piBF = BF_FromString(PI_String())
    Dim As BigFix sqrtBF = BFSqrt(n)
    Dim As BigFix xBF = BF_Mul(piBF, sqrtBF)
    Dim As Double x_approx = 4.0 * Atn(1.0) * Sqr(Cdbl(n))
    Dim As Integer nterms = Cint(x_approx * 4 + 60)
    Return BF_Exp(xBF, nterms)
End Function

' Show result for Heegner number n
Sub showRamanujan(n As Integer)
    Dim As BigFix valBF = RamanujanBF(n)
    Dim As String formattedVal = BF_Format(valBF, 32)
    
    ' Nearest integer
    Dim As Bigint tps = TenPow(SCALE)
    Dim As Bigint intPart = valBF.s \ tps
    Dim As Bigint fracPart = valBF.s Mod tps
    Dim As Bigint nearest = intPart
    If fracPart >= ValBigint("5" & String(SCALE - 1, "0")) Then nearest += 1
    
    ' diff = |val - nearest|
    Dim As Bigint nearestScaled = nearest * tps
    Dim As BigFix diffBF
    If valBF.s >= nearestScaled Then
        diffBF.s = valBF.s - nearestScaled
    Else
        diffBF.s = nearestScaled - valBF.s
    End If
    Dim As String diffTxt = BF_Format(diffBF, 32)
    
    Print RAlign(Str(n), 3); ": "; RAlign(formattedVal, 51); 
    Print " "; Chr(126); " "; RAlign(BigStr(nearest), 18);
    Print " (diff: "; diffTxt; ")"
End Sub

' --- Main program ---
Print "Ramanujan's constant to 32 decimal places is:"
Dim As BigFix ramanujan = RamanujanBF(163)
Print BF_Format(ramanujan, 32)
Print
Print "Heegner numbers yielding almost integers:"

Dim As Integer heegner(3) = {19, 43, 67, 163}
For i As Integer = 0 To 3
    showRamanujan(heegner(i))
Next i

Sleep
