#include once "raylib.bi"
#inclib "raylib"
#inclib "gdi32"
#inclib "winmm"
#inclib "shell32"

Const ScrW = 1024, ScrH = 768

Const radius As Single = 21.63
' Goals
Const goalW As Single = 7.5
Const goalH As Single = 2.4
Const netDepth As Single = 2.0
Const netCols = 24
Const netRows = 72

InitWindow(ScrW, ScrH, "Rotating Stadium - FreeBASIC + Raylib")
SetTargetFPS(60)

' 3D Camera
Dim camera As Camera3D
camera.position   = Vector3(0.0, 12.0, 18.0)
camera.target     = Vector3(0.0, 2.0, -2.0)
camera.up         = Vector3(0.0, 1.0, 0.0)
camera.fovy       = 45.0
camera.projection = CAMERA_PERSPECTIVE

' Stadium colors
Dim Shared LINE_WHITE  As RLColor = RLColor(245, 245, 245, 255)
Dim FIELD_GREEN As RLColor = RLColor(34, 94, 20, 255)
Dim SEAT_RED    As RLColor = RLColor(210, 30, 30, 255)
Dim SEAT_BLUE   As RLColor = RLColor(30, 80, 200, 255)
Dim CONCRETE    As RLColor = RLColor(160, 165, 175, 255)

Dim Shared angle As Single = 0.0

Sub DrawGoalNetTriangular(px As Single, direcc As Single)
    ' direcc = network direction: -1 for west, +1 for east   
    Dim backX As Single = px + direcc * netDepth   ' backward
    
    For i As Integer = 0 To netCols
        Dim z As Single = -goalW/2 + (goalW/netCols)*i
        
        DrawLine3D(Vector3(px, 0, z), Vector3(backX, goalH/2, z * 0.6), LINE_WHITE)
        DrawLine3D(Vector3(px, goalH, z), Vector3(backX, goalH/2, z * 0.6), LINE_WHITE)
    Next
    
    For j As Integer = 0 To netRows
        Dim y As Single = (goalH/netRows)*j
        
        DrawLine3D(Vector3(px, y, -goalW/2), Vector3(backX, goalH/2, -goalW/3), LINE_WHITE)
        DrawLine3D(Vector3(px, y,  goalW/2), Vector3(backX, goalH/2,  goalW/3), LINE_WHITE)
    Next
End Sub

' Main loop
While Not WindowShouldClose()
    ' Automatic camera rotation
    angle += 0.01
    camera.position.x = Sin(angle) * radius
    camera.position.z = Cos(angle) * radius
    
    BeginDrawing()
    ClearBackground(RLColor(110, 180, 225, 255))   ' sky
    
    BeginMode3D(camera)
    
    ' 1. Grass
    DrawPlane(Vector3(0,0,0), Vector2(60,60), FIELD_GREEN)
    
    ' 2. Single steps (10 levels)
    Const startZ As Single = -10.0
    Const stepWidth As Single = 16.0
    
    For row As Integer = 1 To 10
        Dim rowHeight As Single = row * 0.5
        Dim rowDepth As Single = startZ - (row * 0.8)
        
        ' Concrete base
        DrawCube(Vector3(0.0, rowHeight/2.0, rowDepth), stepWidth, rowHeight, 0.8, CONCRETE)
        DrawCubeWires(Vector3(0.0, rowHeight/2.0, rowDepth), stepWidth, rowHeight, 0.8, DARKGRAY)
        
        ' Seating
        For seatX As Integer = -7 To 7
            Dim posX As Single = seatX * 1.0
            Dim posY As Single = rowHeight + 0.15
            
            Dim seatColor As RLColor = Iif(Abs(seatX) < 3, SEAT_BLUE, SEAT_RED)
            
            DrawCube(Vector3(posX, posY, rowDepth), 0.5, 0.1, 0.4, seatColor)
            DrawCube(Vector3(posX, posY + 0.2, rowDepth - 0.18), 0.5, 0.3, 0.08, seatColor)
        Next
    Next
    
    ' 3. Field lines
    DrawCubeWires(Vector3(0,0.01,0), 30, 0.02, 20, LINE_WHITE)
    
    ' Midfield line
    DrawLine3D(Vector3(0,0.02,-10), Vector3(0,0.02,10), LINE_WHITE)
    
    ' Center circle
    For i As Integer = 0 To 36
        Dim a1 As Single = (i     / 36.0) * 2 * PI
        Dim a2 As Single = ((i+1) / 36.0) * 2 * PI
        Dim r As Single = 3.0
        
        Dim p1 As Vector3 = Vector3(r*Cos(a1), 0.02, r*Sin(a1))
        Dim p2 As Vector3 = Vector3(r*Cos(a2), 0.02, r*Sin(a2))
        DrawLine3D(p1, p2, LINE_WHITE)
    Next
    
    ' 4. Side goals
    Dim px As Single = -15        ' position X of the west goal
    ' Left post
    DrawCylinder(Vector3(px, 0, -goalW/2), 0.06, 0.06, goalH, 16, LINE_WHITE)
    ' Right post
    DrawCylinder(Vector3(px, 0,  goalW/2), 0.06, 0.06, goalH, 16, LINE_WHITE)
    ' Crossbar
    DrawCylinderEx(Vector3(px, goalH, -goalW/2), Vector3(px, goalH, goalW/2), 0.06, 0.06, 16, LINE_WHITE)
    ' Goal net
    DrawGoalNetTriangular(px, -1)   ' network backwards (negative X)
    
    px = 15   ' position X of the east goal
    DrawCylinder(Vector3(px, 0, -goalW/2), 0.06, 0.06, goalH, 16, LINE_WHITE)
    DrawCylinder(Vector3(px, 0,  goalW/2), 0.06, 0.06, goalH, 16, LINE_WHITE)
    DrawCylinderEx(Vector3(px, goalH, -goalW/2), Vector3(px, goalH, goalW/2), 0.06, 0.06, 16, LINE_WHITE)
    DrawGoalNetTriangular(px, +1)   ' network backwards (X positive)
    
    EndMode3D()
    
    DrawText("Rotating Stadium - FreeBASIC + Raylib", 20, 20, 20, WHITE)
    DrawFPS(ScrW - 100, 20)
    
    EndDrawing()
Wend

CloseWindow()
