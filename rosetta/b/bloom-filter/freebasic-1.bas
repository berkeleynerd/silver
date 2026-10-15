#define ceil(x) (-((-x*2.0-0.5) Shr 1))

' CRC32
Dim Shared crcTable(255) As Uinteger

Sub CRC32_Init()
    Dim word As Uinteger
    For i As Integer = 0 To 255
        word = i
        For j As Integer = 0 To 7
            If (word And 1) = 1 Then
                word = (word Shr 1) Xor &HEDB88320
            Else
                word Shr= 1
            End If
        Next
        crcTable(i) = word
    Next
End Sub

Function CRC32_Compute(s As String) As Uinteger
    Dim crc As Uinteger = Not 0
    Dim le As Integer = Len(s)
    For i As Integer = 1 To le
        Dim crb As Uinteger = crc And &HFF
        Dim b As Uinteger = Asc(Mid(s, i, 1))
        crc = crcTable(crb Xor b) Xor (crc Shr 8)
    Next
    Return Not crc
End Function

' Bloom Filter
Type BloomFilter
    m As Integer
    k As Integer
    a(Any) As Uinteger
End Type

Function NextPowerOfTwo(n As Integer) As Integer
    Dim p As Integer = 1
    While p < n
        p Shl= 1
    Wend
    Return p
End Function

Sub BloomFilter_Init(bf As BloomFilter Ptr, capacity As Integer, falsePosRate As Double)
    If capacity <= 0 Then Print "Capacity must be positive": Sleep: End
    If falsePosRate <= 0 Or falsePosRate >= 1 Then
        Print "False positive rate must be between 0 and 1": Sleep: End
    End If
    
    ' Optimal m and k for the given capacity and false positive rate.
    Dim log2 As Double = Log(2.0)
    Dim mCalc As Double = -capacity * Log(falsePosRate) / (log2 * log2)
    Dim kCalc As Double = (mCalc / capacity) * log2
    
    bf->m = Ceil(mCalc)
    bf->k = Iif(Int(kCalc) < 1, 1, Int(kCalc))
    
    Dim recordCount As Integer = bf->m Shr 5
    If (bf->m And 31) <> 0 Then recordCount += 1 
    Redim bf->a(recordCount)
    CRC32_Init()
End Sub

Sub BloomFilter_BitNums(bf As BloomFilter Ptr, obj As String, res() As Integer)
    Dim crc As Uinteger = CRC32_Compute(obj)
    Dim c1 As Integer = crc \ 65536
    Dim c2 As Integer = crc And 65535
    
    Redim res(bf->k - 1)
    For i As Integer = 0 To bf->k - 1
        res(i) = (c1 + c2 * i) Mod bf->m
    Next
End Sub

' setBit_ y testBit_
Sub BloomFilter_SetBit(bf As BloomFilter Ptr, bitNum As Integer)
    Dim record As Integer = bitNum Shr 5
    Dim offset As Integer = bitNum And 31
    Dim mask As Uinteger = 1 Shl offset
    bf->a(record) Or= mask
End Sub

Function BloomFilter_TestBit(bf As BloomFilter Ptr, bitNum As Integer) As Integer
    Dim record As Integer = bitNum Shr 5
    Dim offset As Integer = bitNum And 31
    Dim mask As Uinteger = 1 Shl offset
    Return (bf->a(record) And mask) <> 0
End Function

' add(item)
Sub BloomFilter_Add(bf As BloomFilter Ptr, item As String)
    Dim bits() As Integer
    BloomFilter_BitNums(bf, item, bits())
    For i As Integer = 0 To Ubound(bits)
        BloomFilter_SetBit(bf, bits(i))
    Next
End Sub

' contains(item)
Function BloomFilter_Contains(bf As BloomFilter Ptr, item As String) As Boolean
    Dim bits() As Integer
    BloomFilter_BitNums(bf, item, bits())
    For i As Integer = 0 To Ubound(bits)
        If BloomFilter_TestBit(bf, bits(i)) = 0 Then Return False
    Next
    Return True
End Function

' size
Function BloomFilter_Size(bf As BloomFilter Ptr) As Integer
    Dim np As Integer = NextPowerOfTwo(Ubound(bf->a) + 1)
    Return np * 8 + 32
End Function

' Tamaño del Set
Function GetSetSize(count As Integer) As Integer
    Dim np As Integer = NextPowerOfTwo(count)
    If 0.75 * np < count Then np *= 2
    Return np * 16 + 32
End Function

' Main program
Dim words() As String
Dim ff As Integer = Freefile()

If Open("unixdict.txt" For Input As #ff) <> 0 Then Print "Could not open unixdict.txt": Sleep: End

Dim linea As String
Dim wc As Integer = 0

While Not Eof(ff)
    Line Input #ff, linea
    If Len(linea) > 0 Then
        Redim Preserve words(wc)
        words(wc) = linea
        wc += 1
    End If
Wend
Close #ff

Dim bf As BloomFilter
BloomFilter_Init(@bf, wc, 0.01)

For i As Integer = 0 To wc - 1
    BloomFilter_Add(@bf, words(i))
Next

Dim s1 As String = "code"
Dim s2 As String = "nosuchthing"

Print "bloom filter contains """; s1; """ = "; BloomFilter_Contains(@bf, s1)
Print "bloom filter contains """; s2; """ = "; BloomFilter_Contains(@bf, s2)

Dim setSize As Integer = GetSetSize(wc)

Print
Print Using "bloom filter: ##.## MiB"; BloomFilter_Size(@bf) / (1024.0 * 1024.0)
Print Using "set:          ##.## MiB"; setSize / (1024.0 * 1024.0)
Print

' Check the Bloom filter contains all words in the dictionary
Dim missing As Integer = 0
For i As Integer = 0 To wc - 1
    If BloomFilter_Contains(@bf, words(i)) = 0 Then missing += 1
Next

If missing = 0 Then
    Print "All"; wc; " words in the dictionary are included in the Bloom filter."
Else
    Print missing; " words were not included in the bloom filter."
End If

Sleep
