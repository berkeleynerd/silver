#include once "SHA-256.bas"

Const BLOCK_SIZE = 1024

Sub HexToBytes(hexStr As String, bytes() As Ubyte)
    Redim bytes(31)
    For i As Integer = 0 To 31
        bytes(i) = Val("&H" & Mid(hexStr, 2*i + 1, 2))
    Next
End Sub

Function BytesToBin(bytes() As Ubyte) As String
    Dim As String s = ""
    For i As Integer = 0 To Ubound(bytes)
        s &= Chr(bytes(i))
    Next
    Return s
End Function

Function BytesToHex(bytes() As Ubyte) As String
    Dim As String s = ""
    For i As Integer = 0 To Ubound(bytes)
        s &= Right("0" & Hex(bytes(i)), 2)
    Next
    Return s
End Function

Sub MerkleRoot(filename As String)
    Dim As Integer ff = Freefile
    Open filename For Binary Access Read As #ff
    If Err Then
        Print "Error abriendo archivo"
        Exit Sub
    End If
    
    Dim As String hashes()
    Dim As String * BLOCK_SIZE buffer
    Dim As Integer bytesRead
    Dim As Integer fileSize = Lof(ff)
    Dim As Integer posic = 1
    
    Do While posic <= fileSize
        If fileSize - posic + 1 >= BLOCK_SIZE Then
            Get #ff, posic, buffer
            bytesRead = BLOCK_SIZE
        Else
            Dim As String smallbuf = Space(fileSize - posic + 1)
            Get #ff, posic, smallbuf
            bytesRead = Len(smallbuf)
            buffer = Left(smallbuf, bytesRead)
        End If
        Dim As Integer n
        If Not (Lbound(hashes) <= Ubound(hashes)) Then
            Redim hashes(0)
            n = 0
        Else
            n = Ubound(hashes) + 1
            Redim Preserve hashes(n)
        End If
        hashes(n) = SHA_256(buffer)
        posic += BLOCK_SIZE
    Loop
    Close #ff
    
    ' Merkle tree
    Dim As String hashes2()
    Dim As Integer i, n2
    Dim As Ubyte b1(), b2(), concat()
    Dim As String binConcat
    
    While Ubound(hashes) > 0
        Redim hashes2(-1)
        i = 0
        Do While i <= Ubound(hashes)
            If i < Ubound(hashes) Then
                HexToBytes(hashes(i), b1())
                HexToBytes(hashes(i+1), b2())
                binConcat = BytesToBin(b1()) & BytesToBin(b2())                
                If Not (Lbound(hashes2) <= Ubound(hashes2)) Then
                    Redim hashes2(0)
                    n2 = 0
                Else
                    n2 = Ubound(hashes2) + 1
                    Redim Preserve hashes2(n2)
                End If
                hashes2(n2) = SHA_256(binConcat)
            Else
                If Not (Lbound(hashes2) <= Ubound(hashes2)) Then
                    Redim hashes2(0)
                    n2 = 0
                Else
                    n2 = Ubound(hashes2) + 1
                    Redim Preserve hashes2(n2)
                End If
                hashes2(n2) = hashes(i)
            End If
            i += 2
        Loop
        Redim hashes(Lbound(hashes2) To Ubound(hashes2))
        For i = Lbound(hashes2) To Ubound(hashes2)
            hashes(i) = hashes2(i)
        Next
    Wend
    
    Print hashes(0)
End Sub

' Test program
MerkleRoot("title.png")

Sleep
