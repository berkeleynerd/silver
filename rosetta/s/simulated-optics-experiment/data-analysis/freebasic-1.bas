#Define MAX_ROWS 1000000

Type ZeroOrOne As Byte  ' 0 o 1

Const angleL1 As Double = 0.0
Const angleL2 As Double = 45.0
Const angleR1 As Double = 22.5
Const angleR2 As Double = 67.5

Dim Shared dato() As ZeroOrOne
Dim Shared nRows As Integer = 0

Sub ReadRawDataFromFile(filename As String)
    Dim value As Integer
    Dim ff As Integer = Freefile
    Open filename For Input As #ff
    
    Input #ff, nRows
    If nRows = 0 Or nRows > MAX_ROWS Then
        Print "Error: Invalid nRows: "; nRows
        Close #ff
        Sleep: End 1
    End If
    
    Redim dato(nRows * 7 - 1) As ZeroOrOne
    
    For i As Integer = 0 To nRows - 1
        For j As Integer = 0 To 6
            Input #ff, value
            If value < 0 Or value > 1 Then
                Print "bad data in row "; i; " column "; j
                Close #ff
                Sleep: End 1
            End If
            dato(i * 7 + j) = Cbyte(value)
        Next
    Next
    
    Close #ff
    Print "Data read: "; nRows; " rows from "; filename
End Sub

Sub adjustForGeometry()
    For i As Integer = 0 To nRows - 1
        If dato(i * 7 + 0) = 1 Then
            Swap dato(i * 7 + 3), dato(i * 7 + 4)
            Swap dato(i * 7 + 5), dato(i * 7 + 6)
        End If
    Next
End Sub

Function groupSize(group0 As ZeroOrOne, group1 As ZeroOrOne) As Integer
    Dim cnt As Integer = 0
    
    For i As Integer = 0 To nRows - 1
        If dato(i * 7 + 1) = group0 And dato(i * 7 + 2) = group1 Then cnt += 1
    Next
    
    Return cnt
End Function

Function countDetections(group0 As ZeroOrOne, group1 As ZeroOrOne, column As Integer) As Integer
    Dim cnt As Integer = 0
    
    For i As Integer = 0 To nRows - 1
        If dato(i * 7 + 1) = group0 And dato(i * 7 + 2) = group1 Then cnt += dato(i * 7 + column)
    Next
    
    Return cnt
End Function

Function correlationCoefficient(group0 As ZeroOrOne, group1 As ZeroOrOne) As Double
    Dim N As Integer = groupSize(group0, group1)
    ' Avoid division by zero
    If N = 0 Then Return 0.0

    Dim NL1 As Integer = countDetections(group0, group1, 3)
    Dim NL2 As Integer = countDetections(group0, group1, 4)
    Dim NR1 As Integer = countDetections(group0, group1, 5)
    Dim NR2 As Integer = countDetections(group0, group1, 6)
    
    ' Equation (2.4) in the reference
    Dim sinL As Double = Sqr(Cdbl(NL1) / Cdbl(N))
    Dim cosL As Double = Sqr(Cdbl(NL2) / Cdbl(N))
    Dim sinR As Double = Sqr(Cdbl(NR1) / Cdbl(N))
    Dim cosR As Double = Sqr(Cdbl(NR2) / Cdbl(N))
    
    ' Equation (2.3)
    Dim cosLR As Double = (cosR * cosL) + (sinR * sinL)
    Dim sinLR As Double = (sinR * cosL) - (cosR * sinL)
    
    ' Equation (2.5)
    Dim kappa As Double = (cosLR * cosLR) - (sinLR * sinLR)
    
    Return kappa
End Function

Sub analyzeData()
    Dim kappa00 As Double = correlationCoefficient(0, 0)
    Dim kappa01 As Double = correlationCoefficient(0, 1)
    Dim kappa10 As Double = correlationCoefficient(1, 0)
    Dim kappa11 As Double = correlationCoefficient(1, 1)
    
    Dim chshContrast As Double = -kappa00 + kappa01 + kappa10 + kappa11
    Dim chshContrastNominal As Double = 2.0 * Sqr(2.0)
    
    Print !"\n   light pulse events    "; nRows
    Print !"\n    correlation coefs"
    Print Using "          ##.#" & Chr(167) & " ##.#" & Chr(167) & "   +#.######"; angleL1; angleR1; kappa00
    Print Using "          ##.#" & Chr(167) & " ##.#" & Chr(167) & "   +#.######"; angleL1; angleR2; kappa01
    Print Using "          ##.#" & Chr(167) & " ##.#" & Chr(167) & "   +#.######"; angleL2; angleR1; kappa10
    Print Using "          ##.#" & Chr(167) & " ##.#" & Chr(167) & "   +#.######"; angleL2; angleR2; kappa11
    Print Using !"\n        CHSH contrast   +#.######"; chshContrast
    Print Using "  2*sqrt(2) = nominal   +#.######"; chshContrastNominal
    Print Using "           difference   +#.######"; chshContrast - chshContrastNominal
    Print Using !"\n       CHSH violation   +#.######\n"; chshContrast - 2.0
End Sub

Sub runTest()
    ' Test data (small example)
    Dim testData(22) As ZeroOrOne = { _
    3, _                    ' nRows = 3
    0, 0, 0, 1, 0, 1, 0, _  ' fila 0
    0, 0, 1, 1, 0, 1, 0, _  ' fila 1
    1, 1, 0, 0, 1, 0, 1 }   ' fila 2
    
    nRows = testData(0)
    
    Redim dato(nRows * 7 - 1) As ZeroOrOne
    For i As Integer = 0 To nRows * 7 - 1
        dato(i) = Cbyte(testData(i + 1))
    Next
    
    Print !"\n=== TEST WITH EXAMPLE DATA ==="
    Print "Data: "; nRows; " rows"
    
    adjustForGeometry()
    analyzeData()
End Sub

' Main program
Dim filename As String

If Command() <> "" Then
    filename = Command()
    If Dir(filename) = "" Then
        Print "Error: File not found: "; filename
        Print !"Using test data...\n"
        RunTest()
    Else
        ReadRawDataFromFile(filename)
        adjustForGeometry()
        analyzeData()
    End If
Else
    Print "No file specified."
    Print "Usage: eprb_analyzer.exe [data_file]"
    RunTest()
End If

Sleep
