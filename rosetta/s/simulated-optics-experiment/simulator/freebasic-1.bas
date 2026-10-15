' Reference:
'
'   A. F. Kracklauer, ‘EPR-B correlations: non-locality or geometry?’,
'   J. Nonlinear Math. Phys. 11 (Supp.) 104–109 (2004).
'   https://doi.org/10.2991/jnmp.2004.11.s1.13 (Open access, CC BY-NC)
'

#Define MAX_ROWS 1000000

Const angleL1 As Double = 0.0
Const angleL2 As Double = 45.0
Const angleR1 As Double = 22.5
Const angleR2 As Double = 67.5

Static Shared seed48(0 To 3) As Integer = {1,1,1,1}

Function Random48() As Double
    Const m1 = 494, m2 = 322, m3 = 2508, m4 = 2549
    Const ipw2 = 4096
    Const r As Double = 1.0 / ipw2
    
    Dim As Integer it1, it2, it3, it4
    Dim As Double rndout
    
    Do
        it4 = seed48(4) * m4
        it3 = it4 \ ipw2
        it4 -= ipw2 * it3
        
        it3 += seed48(3) * m4 + seed48(4) * m3
        it2 = it3 \ ipw2
        it3 -= ipw2 * it2
        
        it2 += seed48(2) * m4 + seed48(3) * m3 + seed48(4) * m2
        it1 = it2 \ ipw2
        it2 -= ipw2 * it1
        
        it1 += seed48(1) * m4 + seed48(2) * m3 + seed48(3) * m2 + seed48(4) * m1
        it1 = it1 Mod ipw2
        
        seed48(1) = it1
        seed48(2) = it2
        seed48(3) = it3
        seed48(4) = it4
        
        rndout = r * (Cdbl(it1) + r * (Cdbl(it2) + r * (Cdbl(it3) + r * Cdbl(it4))))
    Loop Until rndout <> 1.0
    
    Return rndout
End Function

Sub LightSource(Byref logS As Integer, Byref thetaL As Double, Byref thetaR As Double)
    If Random48() < 0.5 Then
        logS = 0 : thetaL = 0.0 : thetaR = 90.0
    Else
        logS = 1 : thetaL = 90.0 : thetaR = 0.0
    End If
End Sub

Sub PolarizingBeamSplitter(Byref logP As Integer, Byval theta As Double, _
    Byval phi1 As Double, Byval phi2 As Double, Byref outC As Double, Byref outS As Double)
    Dim k As Double = Atn(1.0) / 45.0   ' PI/180
    
    If Random48() < 0.5 Then
        logP = 0
        outC = Cos(k * (theta - phi1))
        outS = Sin(k * (theta - phi1))
    Else
        logP = 1
        outC = Cos(k * (theta - phi2))
        outS = Sin(k * (theta - phi2))
    End If
End Sub

Function LightDetector( Byval amplitude As Double ) As Integer
    Return Iif(Random48() <= amplitude * amplitude, 1, 0)
End Function

Sub SimulationEvent(Byref f As Integer)
    Dim As Integer logS, logL, logR
    Dim As Integer pingL1, pingL2, pingR1, pingR2
    Dim As Double thetaL, thetaR
    Dim As Double valL1, valL2, valR1, valR2
    
    LightSource(logS, thetaL, thetaR)
    PolarizingBeamSplitter(logL, thetaL, angleL1, angleL2, valL1, valL2)
    PolarizingBeamSplitter(logR, thetaR, angleR1, angleR2, valR1, valR2)
    
    pingL1 = LightDetector(valL1)
    pingL2 = LightDetector(valL2)
    pingR1 = LightDetector(valR1)
    pingR2 = LightDetector(valR2)
    
    Print #f, logS; " "; logL; " "; logR; " "; pingL1; " "; pingL2; " "; pingR1; " "; pingR2
End Sub

' Main program
Dim As Integer ff = Freefile()
Open "datalog.log" For Output As #ff

Print #ff, MAX_ROWS

For i As Integer = 0 To MAX_ROWS - 1
    SimulationEvent(ff)
Next i
Close #ff
