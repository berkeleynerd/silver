Const MAXP = 16000000   ' Enough for first 1,000,000 primes

Dim Shared primes() As Integer
Dim Shared pfactors() As Integer
Dim Shared cat() As Integer
Dim Shared sieve(0 To MAXP) As Ubyte

' Build sieve of primes up to MAXP
Sub buildSieve()
    Dim i As Integer, j As Integer, k As Integer
    
    For i = 2 To Sqr(MAXP)
        If sieve(i) = 0 Then
            For j = i*i To MAXP Step i
                sieve(j) = 1
            Next
        End If
    Next
    
    Dim count As Integer = 0
    For i = 2 To MAXP
        If sieve(i) = 0 Then count += 1
    Next
    
    Redim primes(1 To count)
    k = 1
    For i = 2 To MAXP
        If sieve(i) = 0 Then
            primes(k) = i
            k += 1
        End If
    Next
End Sub

' Build prime-factor table for all numbers up to MAXP
' pfactors(n) = largest prime factor of n
Sub buildPfactors()
    Redim pfactors(0 To MAXP)
    Dim i As Integer, j As Integer
    
    For i = 2 To MAXP
        If pfactors(i) = 0 Then
            For j = i To MAXP Step i
                pfactors(j) = i
            Next
        End If
    Next
End Sub

' Compute category of prime p using memoization
Function getcat(p As Integer) As Integer
    If cat(p) <> 0 Then Return cat(p)
    
    Dim n As Integer = p + 1
    Dim maxc As Integer = 0
    
    While n > 1
        Dim f As Integer = pfactors(n)
        If f > 3 Then
            Dim c As Integer = getcat(f)
            If c > maxc Then maxc = c
        End If
        n \= f
    Wend
    
    cat(p) = maxc + 1
    Return cat(p)
End Function

' Categorize first N primes
Sub categorise(N As Integer)
    Dim categories(1 To 12) As Integer
    Dim firstp(1 To 12) As Integer
    Dim lastp(1 To 12) As Integer
    
    For i As Integer = 1 To N
        Dim p As Integer = primes(i)
        Dim c As Integer = getcat(p)
        
        If categories(c) = 0 Then firstp(c) = p
        lastp(c) = p
        categories(c) += 1
    Next
    
    Print "First "; Str(N); " primes:"
    For c As Integer = 1 To 12
        If categories(c) > 0 Then
            Print Using "Category ##: first = #######  last = ########  count = ######"; _
            c; firstp(c); lastp(c); categories(c)
        End If
    Next
    Print
End Sub

' Main program
Dim t0 As Double = Timer

buildSieve()
buildPfactors()
Redim cat(0 To MAXP)

categorise(200)
categorise(1000000)

Print "Took"; Timer - t0; " seconds on N95 @1.70 GHz"

Sleep
