REM Using Vectors with Methods and Overloaded Operators
Type Vec
    x As Double
    y As Double
    
    Declare Function Sum(Byref b As Vec) As Vec
    Declare Function Res(Byref b As Vec) As Vec
    Declare Function Mul(k As Double) As Vec
    Declare Function Longt() As Double
    Declare Function Limit(low As Double, high As Double) As Vec
End Type

Function Vec.Sum(Byref b As Vec) As Vec
    Return Type<Vec>(x + b.x, y + b.y)
End Function

Function Vec.Res(Byref b As Vec) As Vec
    Return Type<Vec>(x - b.x, y - b.y)
End Function

Function Vec.Mul(k As Double) As Vec
    Return Type<Vec>(x * k, y * k)
End Function

Function Vec.Longt() As Double
    Return Sqr(x*x + y*y)
End Function

Function Vec.Limit(low As Double, high As Double) As Vec
    Dim L As Double = Longt()
    If L > high Then
        Return Mul(high / L)
    Elseif L < low Andalso L > 0 Then
        Return Mul(low / L)
    End If
    Return This
End Function

Operator +(Byref a As Vec, Byref b As Vec) As Vec
    Return Type<Vec>(a.x + b.x, a.y + b.y)
End Operator

Operator -(Byref a As Vec, Byref b As Vec) As Vec
    Return Type<Vec>(a.x - b.x, a.y - b.y)
End Operator

Operator *(Byref a As Vec, k As Double) As Vec
    Return Type<Vec>(a.x * k, a.y * k)
End Operator

Type Boid
    psc As Vec
    vel As Vec
End Type

Dim Shared cave() As String
Dim linea As String
Dim ff As Integer = Freefile
Dim n As Integer = -1

' Initialize map with walls and spaces
Open "cave.txt" For Input As #ff
While Not Eof(ff)
    Line Input #ff, linea
    n += 1
    Redim Preserve cave(n)
    cave(n) = linea
Wend
Close #ff

Dim Shared As Integer rows, columns, ancho, alto
rows = Ubound(cave) + 1
columns = Len(cave(0))
ancho = columns
alto = rows * 2.0

' Map functions
Function RowOf(y As Double) As Integer
    Return rows - 1 - Int(y / 2.0)
End Function

Function ColOf(x As Double) As Integer
    Dim c As Integer = Int(x)
    Return ((c Mod columns) + columns) Mod columns
End Function

Function isWall(p As Vec) As Boolean
    If p.y < 0 Or p.y >= alto Then Return True
    Dim r As Integer = RowOf(p.y)
    Dim c As Integer = ColOf(p.x)
    If cave(r)[c] = Asc("#") Then Return True
    Return False
End Function

Function WallPush(p As Vec) As Vec
    Dim push As Vec = Type<Vec>(0,0)
    
    For dx As Integer = -3 To 3
        For dy As Integer = -6 To 6
            Dim probe As Vec = Type<Vec>(p.x + dx, p.y + dy)
            If isWall(probe) Then
                Dim away As Vec = p - probe
                Dim d As Double = away.Longt()
                If d < 0.5 Then d = 0.5
                push += away * (d^-3)
            End If
        Next
    Next
    
    Return push
End Function

Function Steer(b As Boid, flock() As Boid) As Vec
    Dim sight As Double = 6.0
    Dim personal_space As Double = 1.5
    Dim near() As Boid
    Dim nn As Integer = -1
    
    ' close neighbors
    For i As Integer = 0 To Ubound(flock)
        Dim d As Double = (flock(i).psc - b.psc).Longt()
        If d < sight Andalso d > 0 Then
            ' if it detects a neighbor
            nn += 1
            Redim Preserve near(nn)
            near(nn) = flock(i)
        End If
    Next
    
    Dim force As Vec = Type<Vec>(0.04, 0)   ' base thrust
    force += WallPush(b.psc) * 1.5
    
    If Ubound(near) >= 0 Then
        Dim n As Double = Ubound(near) + 1
        
        Dim centre As Vec = Type<Vec>(0,0)
        Dim heading As Vec = Type<Vec>(0,0)
        Dim crowd As Vec = Type<Vec>(0,0)
        
        For i As Integer = 0 To Ubound(near)
            centre += near(i).psc
            heading += near(i).vel
            
            If (near(i).psc - b.psc).Longt() < personal_space Then
                crowd += (b.psc - near(i).psc)
            End If
        Next
        
        centre *= (1/n)
        heading *= (1/n)
        
        force += (centre - b.psc) * 0.01
        force += (heading - b.vel) * 0.05
        force += crowd * 0.1
    End If
    
    Return force
End Function

Function moveBoids(Byref b As Boid, flock() As Boid) As Integer
    b.vel = (b.vel + Steer(b, flock())).Limit(0.4, 0.8)
    
    Dim nextp As Vec = b.psc + b.vel
    
    If isWall(nextp) Then
        b.vel *= -0.5
        Return 0
    End If
    
    Dim wrapped As Integer = 0
    If nextp.x >= ancho Then
        nextp.x -= ancho
        wrapped = 1
    End If
    
    b.psc = nextp
    Return wrapped
End Function

Sub drawBoids(flock() As Boid)
    Screenlock
    Cls
    
    For r As Integer = 0 To rows-1
        For c As Integer = 0 To columns-1
            If cave(r)[c] = Asc("#") Then
                Dim x As Double = c
                Dim y As Double = alto - 2*(r+1)
                Line (x*4, y*4)-(x*4+4, y*4+8), Rgb(90,80,70), BF
            End If
        Next
    Next
    
    For i As Integer = 0 To Ubound(flock)
        Dim bx As Integer = flock(i).psc.x * 4
        Dim by As Integer = flock(i).psc.y * 4
        Circle (bx, by), 2, Rgb(200,40,40), , , , F
    Next
    
    Screenunlock
End Sub

' Main program
Randomize Timer

Dim flock() As Boid
Dim fb As Integer = -1

For r As Integer = 0 To rows-1
    For c As Integer = 0 To columns-1
        If cave(r)[c] = Asc("O") Then
            Dim b As Boid
            b.psc = Type<Vec>(c + 0.5, alto - 2*(r+1) - 1)
            b.vel = Type<Vec>(0.3, Rnd()*0.4 - 0.2)
            
            fb += 1
            Redim Preserve flock(fb)
            flock(fb) = b
        End If
    Next
Next

Dim frames As Integer = 240
Dim crossings As Integer = 0
Dim bumps As Integer = 0

Screenres 960, 480, 32
Windowtitle "Boids in FreeBASIC"

' Main loop
For j As Integer = 1 To frames
    drawBoids(flock())
    
    For i As Integer = 0 To Ubound(flock)
        If moveBoids(flock(i), flock()) Then crossings += 1
        If isWall(flock(i).psc) Then bumps += 1
    Next
    
    Sleep 40
Next

Locate rows + 5, 1
Print Ubound(flock)+1; " boids, "; frames; " frames"
Print crossings; " crossings of the cave"
Print bumps; " boids found inside a wall"

Sleep
