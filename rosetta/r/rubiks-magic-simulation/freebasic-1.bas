#include once "raylib.bi"
#inclib "raylib"
#inclib "gdi32"
#inclib "winmm"
#inclib "shell32"

' Window dimensions and initialization
Const ScrW = 1024, ScrH = 768

InitWindow(ScrW, ScrH, "Rubik's Magic 3D GUI Simulation")
SetTargetFPS(60)

' Proper 3D Camera initialization directly via Camera3D function
' Parameters: pos_x, pos_y, pos_z, target_x, target_y, target_z, up_x, up_y, up_z, fovy, projection
Dim camera As Camera3D = Camera3D( _
Vector3(0.0, 10.0, 15.0), _
Vector3(0.0, 0.0, 0.0), _
Vector3(0.0, 1.0, 0.0), _
45.0, _
CAMERA_PERSPECTIVE)

' Description of steps and states
Dim estados(1 To 5) As String = { _
"1/5 Starting State: 2x4 flat rectangle (3 separate rings)", _
"2/5 First Fold: Side panels folded to the center (Thick 2x2 square)", _
"3/5 Loop Shape: Top row folded onto the bottom row (Closed loop)", _
"4/5 Shifted Loop: Panels shifted to the right", _
"5/5 Completed State: 3x3 shape with a missing corner (3 Linked rings)" }

Dim pasoActual As Integer = 1

' Main loop running until the window is closed
While Not WindowShouldClose()
    ' Interaction: Press SPACE key to cycle through folding states
    If IsKeyPressed(KEY_SPACE) Then
        pasoActual += 1
        If pasoActual > 5 Then pasoActual = 1
    End If
    
    ' Rendering
    BeginDrawing()
    ClearBackground(RAYWHITE)
    
    ' Start 3D Mode with the camera
    BeginMode3D(camera)
    
    ' Draw grid for orientation
    DrawGrid(10, 1.0)
    
    ' Calculate and draw positions for the 8 panels
    For i As Integer = 1 To 8
        
        ' Default 2x4 layout coordinates
        Dim As Single x = (i - 4.5) * 1.5
        Dim As Single y = 0.0
        Dim As Single z = 0.0
        
        If i > 4 Then
            x = (i - 8.5) * 1.5
            z = 1.5
        End If
        
        ' State-dependent position modifications
        Select Case pasoActual
        Case 2  ' 2x2 thick square
            If i = 1 Or i = 2 Or i = 7 Or i = 8 Then y = 0.3
            If i <= 2 Then
                x += 2.0
            Else
                x -= 2.0
            End If
            
        Case 3  ' Loop
            If i > 4 Then
                z = 0.0
                y = 0.4
            End If
            
        Case 4  ' Shifted loop
            If i > 4 Then
                z = 0.0
                y = 0.4
                x += 1.5
            End If
            
        Case 5  ' 3x3 completed state
            Select Case i
            Case 1 : x = -1.5 : z = -1.5
            Case 2 : x = 0.0 : z = -1.5
            Case 3 : x = 1.5 : z = -1.5
            Case 4 : x = -1.5 : z = 0.0
            Case 5 : x = 1.5 : z = 0.0
            Case 6 : x = -1.5 : z = 1.5
            Case 7 : x = 0.0 : z = 1.5
            Case 8 : x = 1.5 : z = 1.5
            End Select
        End Select
        
        ' Color the panels alternately for better visibility
        Dim cubeColor As RLColor = Iif((i Mod 2) = 0, BLUE, RED)
        
        ' Create the Vector3 object correctly using Vector3()
        Dim cubePos As Vector3 = Vector3(x, y, z)
        
        ' Draw the 3D panel (position, width, height, length, color)
        DrawCube(cubePos, 1.2, 0.1, 1.2, cubeColor)
        DrawCubeWires(cubePos, 1.2, 0.1, 1.2, BLACK)
    Next
    
    EndMode3D()
    
    ' 2D GUI Overlay text and instructions
    DrawRectangle(10, 10, 680, 90, SKYBLUE)
    DrawText("RUBIK'S MAGIC 3D SIMULATOR", 20, 20, 20, DARKGRAY)
    DrawText(estados(pasoActual), 20, 50, 18, MAROON)
    DrawText("Press [SPACE] to perform the next fold!", 20, 75, 14, DARKGRAY)
    
    EndDrawing()
Wend

' Close window on exit
CloseWindow()
