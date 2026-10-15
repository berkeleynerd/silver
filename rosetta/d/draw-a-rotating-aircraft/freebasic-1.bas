Const SKYBLUE = Rgb(135,206,235)

Dim Shared angle As Double = 0.0

' Rotate a point around (cx,cy)
Sub RotatePoint(x As Double, y As Double, cx As Double, cy As Double, _
    Byref rx As Double, Byref ry As Double)
    
    Dim dx As Double = x - cx
    Dim dy As Double = y - cy
    
    rx = cx + dx * Cos(angle) - dy * Sin(angle)
    ry = cy + dx * Sin(angle) + dy * Cos(angle)
End Sub

' Draw rotated triangle
Sub DrawRotTriangle(cx As Double, cy As Double, _
    x1 As Double, y1 As Double, _
    x2 As Double, y2 As Double, _
    x3 As Double, y3 As Double, clr As Uinteger)
    
    Dim As Double rx1, ry1, rx2, ry2, rx3, ry3
    
    RotatePoint(x1, y1, cx, cy, rx1, ry1)
    RotatePoint(x2, y2, cx, cy, rx2, ry2)
    RotatePoint(x3, y3, cx, cy, rx3, ry3)
    
    Line (rx1, ry1)-(rx2, ry2), clr
    Line (rx2, ry2)-(rx3, ry3), clr
    Line (rx3, ry3)-(rx1, ry1), clr
    
    ' Fill triangle
    Paint ((rx1+rx2+rx3)/3, (ry1+ry2+ry3)/3), clr, clr
End Sub

' Draw rotated rectangle (two triangles)
Sub DrawRotRect(cx As Double, cy As Double, _
    x As Double, y As Double, w As Double, h As Double, clr As Uinteger)
    
    Dim As Double x1 = x,     y1 = y
    Dim As Double x2 = x + w, y2 = y
    Dim As Double x3 = x + w, y3 = y + h
    Dim As Double x4 = x,     y4 = y + h
    
    DrawRotTriangle(cx, cy, x1, y1, x2, y2, x3, y3, clr)
    DrawRotTriangle(cx, cy, x1, y1, x3, y3, x4, y4, clr)
End Sub

' Draw airplane
Sub DrawPlane()
    Dim cx As Double = 270
    Dim cy As Double = 240
    
    ' Tail fin
    DrawRotTriangle(cx, cy, 120,240, 100,160, 150,240, Rgb(80,80,80))
    
    ' Fuselage
    DrawRotRect(cx, cy, 120,220, 300,40, Rgb(80,80,80))
    
    ' Engine exhaust
    DrawRotRect(cx, cy, 100,230, 20,20, Rgb(0,0,0))
    
    ' Nose cone
    DrawRotTriangle(cx, cy, 420,220, 480,240, 420,260, Rgb(80,80,80))
    
    ' Cockpit canopy
    DrawRotTriangle(cx, cy, 380,220, 410,220, 410,235, Rgb(255,200,150))
    
    ' Main wing
    DrawRotTriangle(cx, cy, 220,240, 180,290, 280,240, Rgb(0,0,120))
    
    ' Afterburner flame
    DrawRotTriangle(cx, cy, 100,235, 70,240, 100,245, Rgb(255,0,0))
End Sub

Screenres 640, 480, 32
Windowtitle("Rotating Aircraft in FreeBASIC")
Cls

' Main loop
Do
    Screenlock
    Line (0,0)-(640,480), SKYBLUE, BF
    DrawPlane()
    Screenunlock
    
    angle += 0.015
    
    Sleep 10
Loop Until Inkey$ = Chr(27)
