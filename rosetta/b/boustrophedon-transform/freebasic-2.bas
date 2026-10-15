#include once "big_int/big_integer.bi"

Function T(Byval k As Integer, Byval n As Integer, a() As BigInt, cache() As BigInt) As BigInt
    If n = 0 Then Return a(k)
    If cache(k * Ubound(a) + n) > BigInt(0) Then Return cache(k * Ubound(a) + n)
    
    Dim As BigInt v = T(k, n-1, a(), cache()) + T(k-1, k-n, a(), cache())
    cache(k * Ubound(a) + n) = v
    Return v
End Function

Function Boustrophedon(a() As BigInt, Byval k As Integer) As BigInt
    Dim As Integer n = k
    Dim As BigInt cache(k * k + k)
    
    For i As Integer = 0 To k*k+k
        cache(i) = BigInt(0)
    Next
    
    Return T(k, k, a(), cache())
End Function

' Utilidad: imprimir BigInt con número de dígitos
Sub printResult(title As String, value As BigInt)
    Dim As String s = value   
    ' Stephan Brunker's BigInt library always prints a sign, even for positive values.
    If Left(s, 1) = "+" Then s = Mid(s, 2)
   
    Print title
    Print Using "1000th term: &...& (& digits)"; Left(s, 20); Right(s, 20); Len(s)
    Print
End Sub

' Main program
Const N = 1000
Dim As Integer i

' 1) 1 seguido de ceros
Dim As BigInt a0(N-1)
a0(0) = BigInt(1)
For i = 1 To N-1
    a0(i) = BigInt(0)
Next
printResult("1 followed by 0's:", Boustrophedon(a0(), N-1))

' 2) Todos 1
Dim As BigInt a1(N-1)
For i = 0 To N-1
    a1(i) = BigInt(1)
Next
printResult("All 1's:", Boustrophedon(a1(), N-1))

' 3) Alternando 1, -1
Dim As BigInt a2(N-1)
For i = 0 To N-1
    a2(i) = Iif(i Mod 2 = 0, BigInt(1), BigInt(-1))
Next
printResult("Alternating 1, -1:", Boustrophedon(a2(), N-1))

' 4) Primos
Dim As BigInt a3(N-1)
Dim As Integer primes(8000)
' Sieve simple
Dim As Integer j, p = 2, count = 0
While count < N
    j = 2
    While j <= p \ 2
        If p Mod j = 0 Then Exit While
        j += 1
    Wend
    If j > i \ 2 Then
        a3(count) = BigInt(p)
        count += 1
    End If
    p += 1
Wend
printResult("Primes:", Boustrophedon(a3(), N-1))

' 5) Fibonacci
Dim As BigInt a4(N-1)
a4(0) = BigInt(1) ' start from fib(1)
a4(1) = BigInt(1)
For i = 2 To N-1
    a4(i) = a4(i-1) + a4(i-2)
Next
printResult("Fibonacci numbers:", Boustrophedon(a4(), N-1))

' 6) Factoriales
Dim As BigInt a5(N-1)
a5(0) = BigInt(1)
For i = 1 To N-1
    a5(i) = a5(i-1) * BigInt(i)
Next
printResult("Factorials:", Boustrophedon(a5(), N-1))

Sleep
