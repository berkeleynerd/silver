#include once "gmp.bi"

Type mpz_t As __mpz_struct
Type mpf_t As __mpf_struct

Const A1 As Long = 13591409
Const A2 As Long = 545140134
Const C  As Long = 640320

Dim Shared C3_OVER_24 As mpz_t

' binary splitting: [a,b) -> P,Q,T
Sub BinarySplit(a As Long, b As Long, P As mpz_t Ptr, Q As mpz_t Ptr, T As mpz_t Ptr)
    If b - a = 1 Then
        If a = 0 Then
            mpz_set_ui(P, 1)
            mpz_set_ui(Q, 1)
        Else
            mpz_set_si(P, (6*a-5)*(2*a-1)*(6*a-1))
            
            mpz_set_si(Q, a*a*a)
            mpz_mul(Q, Q, @C3_OVER_24)
        End If
        
        mpz_set_si(T, A1 + A2 * a)
        mpz_mul(T, T, P)
        If (a And 1) <> 0 Then mpz_neg(T, T)
        Exit Sub
    End If
    
    Dim middle As Long = (a + b) \ 2
    
    Dim P1 As mpz_t  : mpz_init(@P1)
    Dim Q1 As mpz_t  : mpz_init(@Q1)
    Dim T1 As mpz_t  : mpz_init(@T1)
    Dim P2 As mpz_t  : mpz_init(@P2)
    Dim Q2 As mpz_t  : mpz_init(@Q2)
    Dim T2 As mpz_t  : mpz_init(@T2)
    Dim tmp1 As mpz_t: mpz_init(@tmp1)
    Dim tmp2 As mpz_t: mpz_init(@tmp2)
    
    BinarySplit(a, middle, @P1, @Q1, @T1)
    BinarySplit(middle, b, @P2, @Q2, @T2)
    
    ' P = P1 * P2
    mpz_mul(P, @P1, @P2)
    ' Q = Q1 * Q2
    mpz_mul(Q, @Q1, @Q2)
    
    ' T = Q2 * T1 + P1 * T2
    mpz_mul(@tmp1, @Q2, @T1)
    mpz_mul(@tmp2, @P1, @T2)
    mpz_add(T, @tmp1, @tmp2)
    
    mpz_clear(@P1)  : mpz_clear(@Q1)  : mpz_clear(@T1)
    mpz_clear(@P2)  : mpz_clear(@Q2)  : mpz_clear(@T2)
    mpz_clear(@tmp1): mpz_clear(@tmp2)
End Sub

Sub computePi(pi As mpf_t Ptr, digits As Long)
    Dim n As Long = digits \ 14 + 10
    
    Dim P As mpz_t: mpz_init(@P)
    Dim Q As mpz_t: mpz_init(@Q)
    Dim T As mpz_t: mpz_init(@T)
    
    BinarySplit(0, n, @P, @Q, @T)
    
    Dim sum As mpf_t  : mpf_init(@sum)
    Dim Cmp As mpf_t  : mpf_init(@Cmp)
    Dim sqrtC As mpf_t: mpf_init(@sqrtC)
    
    ' sum = T / Q
    mpf_set_z(@sum, @T)
    mpf_set_z(@Cmp, @Q)
    mpf_div(@sum, @sum, @Cmp)
    
    ' sqrtC = 426880 * sqrt(10005)
    mpf_set_ui(@Cmp, 10005)
    mpf_sqrt(@sqrtC, @Cmp)
    mpf_mul_ui(@sqrtC, @sqrtC, 426880)
    
    ' pi = 426880 * sqrt(10005) * Q / T = sqrtC / sum
    mpf_div(pi, @sqrtC, @sum)
    
    mpz_clear(@P)  : mpz_clear(@Q)  : mpz_clear(@T)
    mpf_clear(@sum): mpf_clear(@Cmp): mpf_clear(@sqrtC)
End Sub


' --- Main program ---
mpf_set_default_prec( Clng(1000000 * 3.5) )

mpz_init(@C3_OVER_24)
mpz_set_ui(@C3_OVER_24, C)
mpz_mul_ui(@C3_OVER_24, @C3_OVER_24, C)
mpz_mul_ui(@C3_OVER_24, @C3_OVER_24, C)
mpz_div_ui(@C3_OVER_24, @C3_OVER_24, 24)

Dim pi As mpf_t: mpf_init(@pi)

Dim t0 As Double = Timer
computePi(@pi, 1000000)
Dim t1 As Double = Timer

Dim expo As mp_exp_t
Dim s As Zstring Ptr = mpf_get_str(0, @expo, 10, 1000001, @pi)

Dim full As String = *s
Dim piStr As String = Left(full, 1) & "." & Mid(full, 2)

Print Mid(piStr, 1, 52) & " ... " & Right(piStr, 50)
Print Using !"\nTook ##.###### seconds on i5 @3.20 GHz"; (t1 - t0)

mpf_clear(@pi)
mpz_clear(@C3_OVER_24)

Sleep
