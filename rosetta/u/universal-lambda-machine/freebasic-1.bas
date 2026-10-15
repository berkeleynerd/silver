Const M = 50000

Enum TermKind
    TK_I = 0  ' Input
    TK_O = 1  ' Output
    TK_V = 2  ' Variable
    TK_A = 3  ' Application
    TK_L = 4  ' Lambda
End Enum

Type Cell
    t As Long
    r As Long
    e As Cell Ptr
    n As Cell Ptr
End Type

Dim Shared As Long TT(0 To M-1)
Dim Shared As Long n = 44, i = 0, c = 0
Dim Shared As Long b = 0, s = 0 ' b = 0 pure bitstream (bits), b = 7 input/output in ASCII bytes
Dim Shared As Cell Ptr e, f, l
Dim Shared As Cell Ptr stackCells(0 To M-1)

Dim Shared As String userInput
Dim Shared As Long inputPos = 0
Dim Shared As Long inputLen = 0

Function g() As Long
    Dim As Long prev_i = i
    
	i -= 1
    If prev_i = 0 Then
        i = b
        If inputPos >= inputLen Then
            c = -1
        Else
            c = Asc(Mid(userInput, inputPos + 1, 1))
            inputPos += 1
        End If
    End If
	
    If c < 0 Then Return 0
    Return (c Shr i) And 1
End Function

Sub x(lo As Long, hi As Long)
    While lo <= hi
        TT(n) = TT(lo)
        n += 1
        lo += 1
    Wend
End Sub

Sub d(lp As Cell Ptr)
    If lp = 0 Then Exit Sub
    lp->r -= 1
    If lp->r = 0 Then
        d(lp->e)
        d(lp->n)
        lp->n = f
        f = lp
    End If
End Sub

Function p(idx As Long) As Long
    If g() <> 0 Then
        TT(n) = TK_V
        n += 1
        
        ' Initialize the De Bruijn index
        TT(n) = 0
        While g() <> 0
            TT(n) += 1
        Wend
        n += 1
        
    Else
        Dim As Long cond_n = n
        n += 1
        Dim As Long cond_g = g()
        
        If cond_n <> 0 And cond_g <> 0 Then
            n += 1
            TT(idx + 1) = p(n)
            TT(idx) = TK_A
        Else
            TT(idx) = TK_L
        End If
        
        p(n)
    End If
    
    Return n - idx
End Function

' Initialization of the term space
Dim As Long initT(0 To 42) = { _
TK_L, TK_A, 8, TK_A, 2, TK_V, 0, TK_L, TK_L, TK_V, _
TK_A, 30, TK_L, TK_A, 2, TK_V, 0, TK_L, TK_A, 5, TK_A, 7, TK_L, TK_V, 0, TK_O, _
TK_A, 14, TK_L, TK_A, 2, TK_V, 0, TK_L, TK_A, 5, TK_A, 2, TK_V, 0, TK_O, TK_O, TK_A }

For idx As Long = 0 To 42
    TT(idx) = initT(idx)
Next

Input "Input: ", userInput
userInput = Trim(userInput)
inputLen = Len(userInput)
inputPos = 0

TT(43) = p(n)
i = 0

' Initialization of the execution pointer t
Dim As Long t = Iif(b <> 0, 10, 26)
Dim As Byte o = 0
Dim As String salida = ""

Print !"\nOutput:"

' Main execution loop of the Universal Lambda Machine
Do
    Select Case TT(t)
    
    Case TK_I
        g()
        i += 1
        
        If n >= (M - 99) Then Exit Do
        
        If c <> -1 And b <> 0 Then
            x(0, 6)
            TT(n - 5) = 96
            Do While i <> 0
                x(0, 9)
                TT(n) = Iif(g() = 0, 1, 0)
                n += 1
            Loop
        End If
        
        x(Iif(c < 0, 7, b), 9)
        TT(n) = Iif(b = 0 And g() = 0, 1, 0)
        n += 1
        
    Case TK_O
        If (b + t) > 42 Then
            o = (o Shl 1) Or (t And 1)
            t = 28
        Else
            Dim As Long charOut = Iif(b <> 0, o, t + 8)
            Print Chr(charOut);
            t = Iif(b <> 0, 12, 28)
        End If
        
    Case TK_V
        l = e
        Dim As Long idx = TT(t + 1)
        Do While idx > 0
            e = e->n
            idx -= 1
        Loop
        t = e->t
        e = e->e
        If e <> 0 Then e->r += 1
        d(l)
        
    Case TK_A
        t += 2
        
        If f = 0 Then
            f = Cptr(Cell Ptr, Callocate(Sizeof(Cell)))
            f->n = 0
            f->e = 0
            f->r = 0
            f->t = 0
        End If
        
        If f = 0 Or s >= M Then Exit Do
        
        stackCells(s) = f
        s += 1
        
        l = f
        f = l->n
        
        l->r = 1
        l->t = t + TT(t - 1)
        l->e = e
        
        If e <> 0 Then e->r += 1
        
    Case TK_L
        s -= 1
        If s < 0 Then Exit Do
        stackCells(s)->n = e
        e = stackCells(s)
        t += 1
        
    End Select
Loop

Print !"\n\nMachine finished or halted."
Sleep
