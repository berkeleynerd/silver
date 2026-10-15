Const ScrW = 800, ScrH = 600
Const cx = ScrW \ 2, cy = ScrH \ 2   ' Center of the stage
Const As Single PI = 4 * Atn(1.0)

Dim Shared As Double angle = 0

Screenres ScrW, ScrH, 32
Windowtitle ("Rotating Stadium in FreeBASIC")

' Rotation functions
Sub RotLine(x1 As Double, y1 As Double, x2 As Double, y2 As Double, col As Uinteger)
    
    Dim As Double c = Cos(angle)
    Dim As Double s = Sin(angle)
    
    Dim As Double rx1 = cx + (x1 * c - y1 * s)
    Dim As Double ry1 = cy + (x1 * s + y1 * c)
    Dim As Double rx2 = cx + (x2 * c - y2 * s)
    Dim As Double ry2 = cy + (x2 * s + y2 * c)
    
    Line (rx1, ry1)-(rx2, ry2), col
End Sub

Sub RotEllipse(rx As Double, ry As Double, col As Uinteger)   
    Dim As Double c = Cos(angle)
    Dim As Double s = Sin(angle)
    
    Dim As Double lastx = 0
    Dim As Double lasty = 0
    
    For i As Integer = 0 To 200
        Dim As Double t = (i / 200) * 2 * PI
        Dim As Double lx = Cos(t) * rx
        Dim As Double ly = Sin(t) * ry
        
        Dim As Double wx = cx + (lx * c - ly * s)
        Dim As Double wy = cy + (lx * s + ly * c)
        
        If i > 0 Then Line (lastx, lasty)-(wx, wy), col
        
        lastx = wx
        lasty = wy
    Next
End Sub

Sub RotRect(w As Double, h As Double, col As Uinteger, offx As Double, offy As Double)
    Dim As Double hw = w / 2
    Dim As Double hh = h / 2
    
    Dim As Double x1 = offx - hw, y1 = offy - hh
    Dim As Double x2 = offx + hw, y2 = offy - hh
    Dim As Double x3 = offx + hw, y3 = offy + hh
    Dim As Double x4 = offx - hw, y4 = offy + hh
    
    RotLine(x1, y1, x2, y2, col)
    RotLine(x2, y2, x3, y3, col)
    RotLine(x3, y3, x4, y4, col)
    RotLine(x4, y4, x1, y1, col)
End Sub

' Main loop
Do
    Screenlock
    Cls
    
    ' Stadium layout:
	' Stands (large ellipses)
    For r As Integer = 150 To 210 Step 20
        RotEllipse(r + 40, r, Rgb(180,180,180))
    Next
    
    ' Athletics track
    For r As Integer = 110 To 120 Step 5
        RotEllipse(r + 50, r, Rgb(200,0,0))
    Next
    
    ' Football field
    RotRect(160, 100, Rgb(0,150,0), 0, 0)
    RotRect(160, 100, Rgb(255,255,255), 0, 0)
    
    ' Midfield line
    RotLine(0, -50, 0, 50, Rgb(255,255,255))
    ' Central circle
    RotEllipse(15, 15, Rgb(255,255,255))
    ' Central point
    RotEllipse(2, 2, Rgb(255,255,255))
    
    ' Penalty areas
    RotRect(20, 50, Rgb(255,255,255), -80, 0)
    RotRect(8, 24, Rgb(255,255,255), -76, 0)
    
    RotRect(20, 50, Rgb(255,255,255), 80, 0)
    RotRect(8, 24, Rgb(255,255,255), 76, 0)
    
    Screenunlock
    
    angle += 0.01
    Sleep 10
Loop Until Inkey = Chr(27)  ' ESC
