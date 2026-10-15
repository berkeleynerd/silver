#include once "gmp.bi"

Type BigZ As __mpz_struct Ptr

Const MAX_PRIMES = 12000
Dim Shared primes(MAX_PRIMES) As Integer

Sub SieveOfEratosthenes()
    Dim As Integer i, p
    
    Dim isPrime(MAX_PRIMES) As Boolean
    For i = 0 To MAX_PRIMES
        isPrime(i) = True
    Next
    
    p = 2
    While p * p <= MAX_PRIMES
        If isPrime(p) Then
            For i = p * p To MAX_PRIMES Step p
                isPrime(i) = False
            Next
        End If
        p += 1
    Wend
    
    Dim idx As Integer = 0
    For i = 2 To MAX_PRIMES
        If isPrime(i) Then
            primes(idx) = i
            idx += 1
        End If
    Next
End Sub

Function isProbablePrime(s As String) As Integer
    Dim n As BigZ = Allocate(SizeOf(__mpz_struct))
    mpz_init(n)
    mpz_set_str(n, s, 10)
    Dim r As Integer = mpz_probab_prime_p(n, 15)
    mpz_clear(n)
    Deallocate(n)
    Return r
End Function

Sub printMpz(s As String)
    Dim n As BigZ = Allocate(SizeOf(__mpz_struct))
    mpz_init(n)
    mpz_set_str(n, s, 10)
    mpz_out_str(0, 10, n)
    Print
    mpz_clear(n)
    Deallocate(n)
End Sub

Function preview30(s As String) As String
    If Len(s) <= 50 Then Return s
    Return Left(s, 20) & "..." & Right(s, 20)
End Function

' --- Main program ---
SieveOfEratosthenes()

Dim As String sw = "", p, dsw = ""
Dim As Integer cnt, i, j

Print "The known Smarandache-Wellin primes are:"

cnt = 0
i = 0
While cnt < 8 AndAlso primes(i) <> 0
    sw &= Str(primes(i))
    
    If isProbablePrime(Trim(sw)) > 0 Then
        cnt += 1
        Print Using "##: index ####  digits ####  last prime ##### -> "; _
        cnt; i+1; Len(sw); primes(i);
        Print preview30(sw)
    End If
    
    i += 1
Wend

Print !"\nThe first 20 Derived Smarandache-Wellin primes are:"

Dim freqs(9) As Integer
For j = 0 To 9
    freqs(j) = 0
Next
    
cnt = 0
i = 0
While cnt < 20 AndAlso primes(i) <> 0  
    p = Str(primes(i))
    
    For j = 1 To Len(p)
        freqs(Val(Mid(p, j, 1))) += 1
    Next
    
    dsw = ""
    For j = 0 To 9
        dsw &= Str(freqs(j))
    Next
    dsw = LTrim(dsw, "0")
    
    If isProbablePrime(dsw) > 0 Then
        cnt += 1
        Print Using "##: index ####   prime "; cnt; i+1; 
        printMpz(dsw)
    End If
    
    i += 1
Wend

Sleep
