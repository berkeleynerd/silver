Type DivisoreUtile
    p     As Uinteger
    idx_w As Uinteger
End Type

Const SEGMENTO As Uinteger = 262144
Dim Shared RESTI(0 To 15) As Uinteger = {1, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 49, 53, 59}
Dim Shared INV_60(0 To 59) As Integer

' Bootstrap primes (bts_init)
Dim Shared bts_init(0 To 50) As Uinteger = { _
7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, _
97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, _
211, 223, 227, 229, 281, 283, 293, 307, 311, 313, 317 }

' --------- Formatting and parsing ---------
Function to_string_128(Byval n As Ulongint) As String
    If n = 0 Then Return "0"
    Dim s As String = ""
    
    While n > 0
        s = Chr(Asc("0") + (n Mod 10)) & s
        n \= 10
    Wend
    
    Return s
End Function

Function formatta_numero(Byval n As Ulongint) As String
    Dim s   As String = to_string_128(n)
    Dim tam As Integer = Len(s)
    Dim res As String = ""
    
    For i As Integer = 0 To tam - 1
        res &= Mid(s, i + 1, 1)
        If (tam - i - 1) > 0 Andalso ((tam - i - 1) Mod 3 = 0) Then res &= "."
    Next
    
    Return res
End Function

Function formatta_tempo(Byval total_sec As Double) As String
    Dim min  As Integer = Cint(total_sec / 60.0)
    Dim rest As Double  = total_sec - min * 60.0
    Dim sec  As Integer = Cint(rest)
    Dim ms   As Integer = Cint((rest - sec) * 1000.0)
    
    Return Str(min) & " min. " & Str(sec) & " sec. " & Right("0000" & Str(ms), 3) & " ms"
End Function

Function parse_u128(Byval s As String) As Ulongint
    Dim pos_caret As Integer = Instr(s, "^")
    Dim bbase As Ulongint, expo As Ulongint, res As Ulongint
    
    If pos_caret > 0 Then
        bbase = Valulng(Left(s, pos_caret - 1))
        expo = Valulng(Mid(s, pos_caret + 1))
        res = 1
        For i As Ulongint = 0 To expo - 1
            res *= bbase
        Next
        Return res
    End If
    res = 0
    For i As Integer = 1 To Len(s)
        Dim c As Integer = Asc(Mid(s, i, 1))
        If c >= Asc("0") Andalso c <= Asc("9") Then res = res * 10 + (c - Asc("0"))
    Next
    
    Return res
End Function

Sub inizializza_inv60()
    For i As Integer = 1 To 59
        For j As Integer = 1 To 59
            If (i * j) Mod 60 = 1 Then
                INV_60(i) = j
                Exit For
            End If
        Next
    Next
End Sub

Function calcola_pos_colonna(Byval p As Uinteger, Byval n_cicli As Uinteger, Byval col_idx As Uinteger) As Ulongint
    ' Avoid overflow of p^2
    If p = 0U Then Return 0U
    
    Dim bbase As Uinteger = n_cicli * SEGMENTO * 60U
    Dim p2 As Uinteger = p * p
    Dim target As Uinteger = Iif(bbase > p2, bbase, p2)
    
    Dim q_min As Uinteger = (target + p - 1U) \ p
    Dim q0 As Uinteger = (RESTI(col_idx) * Culng(INV_60(p Mod 60))) Mod 60U
    Dim q_start As Uinteger
    If q_min <= q0 Then
        q_start = q0
    Else
        q_start = q0 + ((q_min - q0 + 59U) \ 60U) * 60U
    End If
    
    Dim m As Uinteger = p * q_start
    Return (m \ 60U) - (n_cicli * SEGMENTO)
End Function

' --------- Main program ---------
Dim MAGNITUDO As Ulongint = parse_u128("10^19")
Dim W As Ulongint = 100000000UL

If Command(1) <> "" Then MAGNITUDO = parse_u128(Command(1))
If Command(2) <> "" Then W = parse_u128(Command(2))

Dim W_DISPARI   As Ulongint = W \ 2
Dim M_SUPERIORE As Ulongint = MAGNITUDO + W

inizializza_inv60()

Dim t_start_totale As Double = Timer

Print String(50, "=")
Print " GC60 + SETACCIO INVERSO CON STRUCT (FreeBASIC)"
Print " Thread attivi hardware in uso: 1 (single-thread)"
Print String(50, "=")
Print "Magnitudo (A)     : "; formatta_numero(MAGNITUDO)
Print "Margine Sup. (M)  : "; formatta_numero(M_SUPERIORE)
Print "Finestra (W)      : "; formatta_numero(W)
Print "Dim. Compressa W/2: "; formatta_numero(W_DISPARI); !" celle\n"

Dim radice_max   As Ulongint = Culng(Sqr(Cdbl(M_SUPERIORE)))
Dim radice_boot  As Ulongint = Culng(Sqr(Cdbl(radice_max))) + 1UL
Dim cicli_totali As Ulongint = radice_max \ (SEGMENTO * 60UL) + 1

' 1. DYNAMIC BOOTSTRAP
Dim t_boot As Double = Timer

Redim sieves_boot(0 To 15, 0 To SEGMENTO - 1) As Ubyte
Redim bts(0 To 0) As Ulongint

Dim bts_cnt As Uinteger = 0
Dim col As Uinteger, posic As Uinteger
Dim k As Uinteger, i As Uinteger, p As Uinteger

For col = 0 To 15
    For k = 0 To SEGMENTO - 1
        sieves_boot(col, k) = 1
    Next
Next
sieves_boot(0, 0) = 0

For col = 0 To 15
    For i = 0 To Ubound(bts_init)
        p = bts_init(i)
        If p = 0 Orelse p > radice_boot Then Continue For
        
        posic = calcola_pos_colonna(p, 0UL, col)
        While posic < SEGMENTO
            sieves_boot(col, posic) = 0
            posic += p
        Wend
    Next
Next

For k = 0 To SEGMENTO - 1
    For col = 0 To 15
        Dim valor As Ulongint = 60UL * k + RESTI(col)
        If valor > radice_boot Then Continue For
        If sieves_boot(col, k) <> 0 Andalso valor >= 7 Then
            bts_cnt += 1
            Redim Preserve bts(0 To bts_cnt - 1)
            bts(bts_cnt - 1) = valor
        End If
    Next
Next

' Sort and unique
Dim swapped As Integer
Do
    swapped = 0
    For i = 0 To bts_cnt - 2
        If bts(i) > bts(i + 1) Then
            Dim tmp As Ulongint = bts(i)
            bts(i) = bts(i + 1)
            bts(i + 1) = tmp
            swapped = 1
        End If
    Next
Loop While swapped = 1

Dim j As Integer = 0
For i = 1 To bts_cnt - 1
    If bts(i) <> bts(j) Then
        j += 1
        bts(j) = bts(i)
    End If
Next
bts_cnt = j + 1
Redim Preserve bts(0 To bts_cnt - 1)

Dim n_primi_div As Uinteger = bts_cnt

Dim t_boot_end As Double = Timer
Print "Divisori di bbase pronti: "; formatta_numero(n_primi_div); " primi"
Print "[Tempo bootstrap: "; formatta_tempo(t_boot_end - t_boot); !"]\n"

' 2. FASE B: SETACCIO INVERSO
Print "Avvio Fase B: Setaccio + Isolamento divisori..."
Dim t_sieve As Double = Timer

' Buffer with increasing capacity for divisori_utili
Dim div_cap      As Uinteger = 2000000      ' initial capacity
Dim divisori_cnt As Uinteger = 0
Redim divisori_utili(0 To div_cap - 1) As DivisoreUtile

Redim sieve(0 To SEGMENTO - 1) As Ubyte
Redim pos_array(0 To n_primi_div - 1) As Uinteger

For col = 0 To 15
    For i = 0 To n_primi_div - 1
        pos_array(i) = calcola_pos_colonna(bts(i), 0U, col)
    Next
    
    For idx As Uinteger = 0 To Cuint(cicli_totali - 1)
        ' segment reset
        For k = 0 To SEGMENTO - 1
            sieve(k) = 1
        Next
        If idx = 0 Andalso col = 0 Then sieve(0) = 0
        
        ' marked with the base divisors
        For i = 0 To n_primi_div - 1
            p = bts(i)
            posic = pos_array(i)
            
            While posic < SEGMENTO
                sieve(posic) = 0
                posic += p
            Wend
            
            pos_array(i) = posic - SEGMENTO
        Next
        
        Dim seg_base As Uinteger = idx * SEGMENTO * 60U
        For k = 0 To SEGMENTO - 1
            If sieve(k) <> 0 Then
                p = seg_base + 60U * k + RESTI(col)
                If p < 7U Orelse p > radice_max Then Continue For
                
                Dim k0   As Uinteger = Cuint(M_SUPERIORE Mod p)
                Dim kmod As Uinteger = Iif((k0 And 1U) <> 0U, k0, k0 + p)
                Dim idx_ingresso As Ulongint = kmod
                If idx_ingresso <= W Then
                    Dim idx_w As Uinteger = (idx_ingresso - 1U) \ 2U
                    
                    ' grow only when the buffer is full
                    If divisori_cnt = div_cap Then
                        div_cap *= 2
                        Redim Preserve divisori_utili(0 To div_cap - 1)
                    End If
                    
                    divisori_utili(divisori_cnt).p     = p
                    divisori_utili(divisori_cnt).idx_w = idx_w
                    divisori_cnt += 1
                End If
            End If
        Next
    Next
Next

Dim t_sieve_end As Double = Timer
Print " Divisori utili isolati: "; formatta_numero(divisori_cnt)
Print " [Tempo Fase B: "; formatta_tempo(t_sieve_end - t_sieve); !"]\n"

' 3. FASE C: SPOGLIATURA ISTANTANEA
Print "Fase C: Spogliatura diretta inversa della finestra..."
Dim t_start_C As Double = Timer

Redim W_vec(0 To W_DISPARI - 1) As Ubyte
For k = 0 To W_DISPARI - 1
    W_vec(k) = 1
Next

For i = 0 To divisori_cnt - 1
    Dim d     As Uinteger = divisori_utili(i).p
    Dim idx_w As Uinteger = divisori_utili(i).idx_w
    While idx_w < W_DISPARI
        W_vec(idx_w) = 0
        idx_w += p
    Wend
Next

' Buffer with increasing capacity for primi_offset
Dim primi_cap As Uinteger = 100000
Dim primi_cnt As Uinteger = 0
Redim primi_offset(0 To primi_cap - 1) As Ulongint

For ii As Integer = W_DISPARI - 1 To 0 Step -1
    If W_vec(ii) = 1 Then
        Dim idx_ingresso As Ulongint = 2UL * Culng(ii) + 1UL
        Dim offset_reale As Ulongint = W - idx_ingresso
        Dim n As Ulongint = MAGNITUDO + offset_reale
        
        If (n Mod 3 <> 0) Andalso (n Mod 5 <> 0) Then
            If primi_cnt = primi_cap Then
                primi_cap *= 2
                Redim Preserve primi_offset(0 To primi_cap - 1)
            End If
            primi_offset(primi_cnt) = offset_reale
            primi_cnt += 1
        End If
    End If
Next

Dim t_end_C As Double = Timer
Print " Primi reali trovati nella finestra: "; formatta_numero(primi_cnt)
Print " [Tempo Fase C: "; formatta_tempo(t_end_C - t_start_C); !"]\n"

Dim t_end_totale As Double = Timer
Print " TEMPO REALE TOTALE DI ESECUZIONE ( N95 @1.70 GHz ): "; formatta_tempo(t_end_totale - t_start_totale)
Print String(74, "=")

' Writing file
Dim ff As Integer = Freefile
Open "finestra_1.txt" For Output As #ff
Print #ff, "# A=" & to_string_128(MAGNITUDO) & " W=" & Str(W)
For i = 0 To primi_cnt - 1
    Print #ff, primi_offset(i)
Next
Close #ff
Print " Lista degli offset salvata nel file: finestra_1.txt"

Sleep
