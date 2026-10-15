Const ScrW = 800, ScrH = 600
Const As Single PI = 4 * Atn(1.0)

Dim Shared angleX As Double = 0.0
Dim Shared angleY As Double = 0.0

Screenres ScrW, ScrH, 32
Windowtitle ("Exciting 3D GUI Graphic in FreeBASIC Language")

Do
    angleX += 0.02
    angleY += 0.03
    
    Screenlock
    Cls
    
    Dim As Double r = 180
    Dim As Double prevX, prevY
    Dim As Integer pointsCnt
    
    For u As Integer = 0 To 20
        Dim lat As Double = (u * PI) / 20
        pointsCount = 0
        
        For v As Integer = 0 To 20
            Dim lon As Double = (v * 2 * PI) / 20
            
            ' 1. Base coordinates on a sphere
            Dim x0 As Double = r * Sin(lat) * Cos(lon)
            Dim y0 As Double = r * Sin(lat) * Sin(lon)
            Dim z0 As Double = r * Cos(lat)
            
            ' 2. X Rotation
            Dim y1 As Double = y0 * Cos(angleX) - z0 * Sin(angleX)
            Dim z1 As Double = y0 * Sin(angleX) + z0 * Cos(angleX)
            
            ' 3. Y Rotation
            Dim x2 As Double = x0 * Cos(angleY) + z1 * Sin(angleY)
            Dim z2 As Double = -x0 * Sin(angleY) + z1 * Cos(angleY)
            
            ' 4. Perspective projection
            Dim dist As Double = 400
            Dim persp As Double = dist / (dist - z2)
            
            Dim sx As Integer = ScrW \ 2 + Cint(x2 * persp)
            Dim sy As Integer = ScrH \ 2 + Cint(y1 * persp)
            
            ' 5. Draw lines between consecutive points
            If v > 0 And pointsCount > 0 Then
                Line (prevX, prevY)-(sx, sy), Rgb(0, 255, 200)
            End If
            
            prevX = sx
            prevY = sy
            pointsCount += 1
        Next
    Next
    
    Screenunlock
    Sleep 16
Loop Until Inkey$ <> ""

Sleep
