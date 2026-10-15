#include once "raylib.bi"
#inclib "raylib"
#inclib "gdi32"
#inclib "winmm"
#inclib "shell32"

' Window dimensions and initialization
Const ScrW As Integer = 1024
Const ScrH As Integer = 768

InitWindow(ScrW, ScrH, "3D Airplane - FreeBASIC + Raylib")
SetTargetFPS(60)

' Camera settings
Dim camera As Camera3D
camera.position   = Vector3(8.0, 6.0, 10.0)   ' Starting position
camera.target     = Vector3(0.0, 0.0, 0.0)    ' Center of the airplane
camera.up         = Vector3(0.0, 1.0, 0.0)    ' Up direction vector
camera.fovy       = 45.0                      ' Field of view Y
camera.projection = CAMERA_PERSPECTIVE        ' Perspective view projection

' Animation and camera rotation variables
Dim camAngle As Single = 0.0
Dim propellerAngle As Single = 0.0
Dim camRadius As Single = 12.0

' Main loop
While Not WindowShouldClose()
    ' 1. ROTATE CAMERA AROUND THE AIRPLANE
    camAngle += 0.01
    If camAngle >= 6.28318 Then camAngle = 0.0
    
    ' Force camera into a circular orbit around the Y axis using Sine and Cosine
    camera.position.x = Sin(camAngle) * camRadius
    camera.position.z = Cos(camAngle) * camRadius
    camera.position.y = 5.0   ' Fixed height for optimal view
    
    ' Propeller rotation simulation (alternating between 1 and 2 to animate blades)
    propellerAngle += 1.0
    If propellerAngle > 2.0 Then propellerAngle = 1.0
    
    ' Start drawing
    BeginDrawing()
    ClearBackground(LIGHTGRAY)
    
    ' Start 3D Mode with the camera
    BeginMode3D(camera)
        
        ' Floor grid for better spatial awareness
        DrawGrid(20, 1.0)
        
        ' --- 3D AIRPLANE ASSEMBLY FROM STABLE PRIMITIVES ---
        ' 1. MAIN FUSELAGE (Streamlined white cylinder in the center)
        DrawCylinderEx(Vector3(0, 0, -2.5), Vector3(0, 0, 1.5), 0.7, 0.8, 16, RAYWHITE)
        
        ' 2. NOSE CONE (Cone at the front)
        DrawCylinderEx(Vector3(0, 0, 1.5), Vector3(0, 0, 2.3), 0.8, 0.1, 16, RED)
        
        ' 3. COCKPIT (Dark blue sphere on top of the fuselage)
        DrawSphere(Vector3(0, 0.5, 0.2), 0.45, DARKBLUE)
        
        ' 4. MAIN WINGS (Symmetrical boxes placed on both sides)
        ' Right wing
        DrawCube(Vector3(2.2, 0.0, 0.2), 3.5, 0.12, 1.5, BLUE)
        ' Left wing
        DrawCube(Vector3(-2.2, 0.0, 0.2), 3.5, 0.12, 1.5, BLUE)
        
        ' 5. TAIL ASSEMBLY (Stabilizers and fin)
        ' Horizontal stabilizers
        DrawCube(Vector3(0, 0.1, -2.3), 3.0, 0.08, 0.8, BLUE)
        ' Vertical stabilizer / Tail fin (Red)
        DrawCube(Vector3(0, 0.8, -2.3), 0.12, 1.2, 0.7, RED)
        
        ' 6. LANDING GEAR AND WHEELS (Under the aircraft)
        ' Left landing gear strut and wheel
        DrawCylinderEx(Vector3(-0.6, 0, 0.6), Vector3(-0.6, -1.0, 0.6), 0.08, 0.08, 8, DARKGRAY)
        DrawSphere(Vector3(-0.6, -1.0, 0.6), 0.25, BLACK)
        
        ' Right landing gear strut and wheel
        DrawCylinderEx(Vector3(0.6, 0, 0.6), Vector3(0.6, -1.0, 0.6), 0.08, 0.08, 8, DARKGRAY)
        DrawSphere(Vector3(0.6, -1.0, 0.6), 0.25, BLACK)
        
        ' Rear small tail wheel
        DrawCylinderEx(Vector3(0, -0.2, -2.2), Vector3(0, -0.7, -2.2), 0.05, 0.05, 8, DARKGRAY)
        DrawSphere(Vector3(0, -0.7, -2.2), 0.12, BLACK)
        
        ' 7. PROPELLER BLADES ANIMATION
        If propellerAngle = 1 Then
            DrawCube(Vector3(0, 0, 2.4), 0.15, 2.4, 0.05, GRAY)
        Else
            DrawCube(Vector3(0, 0, 2.4), 2.4, 0.15, 0.05, GRAY)
        End If
        
    EndMode3D()
    
    ' 2D Graphical User Interface (GUI) overlay and status panel
    DrawRectangle(10, 10, 420, 110, Fade(DARKGRAY, 0.7))
    DrawRectangleLines(10, 10, 420, 110, MAROON)
    
    DrawText("3D AIRPLANE - SOLID MODE", 25, 20, 18, GOLD)
    DrawText("Using DrawCube, DrawCylinderEx, DrawSphere", 25, 45, 14, RAYWHITE)
    DrawText("Camera: Auto-Orbit (Sin/Cos)", 25, 65, 14, LIGHTGRAY)
    DrawText("Propeller: Component-swap animation", 25, 85, 14, GREEN)
    
    'FPS counter in the top right corner
    DrawText("FPS: " & Str(GetFPS()), ScrW - 100, 20, 16, GREEN)
    
    EndDrawing()
Wend

' De-initialize and close window
CloseWindow()
