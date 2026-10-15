Const As Single PI = 4 * Atn(1.0)
Const ScrW = 900
Const ScrH = 700

Screenres ScrW, ScrH, 32
Windowtitle "True Classic Klein Bottle GUI - FreeBASIC"

' Resolution parameters for the true shape
Dim As Integer steps_u = 50
Dim As Integer steps_v = 40

' 2D arrays to store screen coordinates for drawing grid lines
Dim As Single points_x(0 To steps_u, 0 To steps_v)
Dim As Single points_y(0 To steps_u, 0 To steps_v)

' Fill background with dark navy/black
Line (0, 0)-(ScrW, ScrH), Rgb(10,10,15), BF

' Set pen for the 3D mesh (Neon cyan)
Dim As Uinteger meshColor = Rgb(0, 229, 255)

' --- STEP 1: Calculate mathematical points and project them ---
Dim As Integer u, v
For u = 0 To steps_u
    Dim As Double u_val = (u / steps_u) * 2.0 * PI   ' 0..2p
    For v = 0 To steps_v
        Dim As Double v_val = (v / steps_v) * 2.0 * PI
        
        Dim As Double x, y, z
        
        ' Classical "bottle" Klein bottle equations (Stewart Dickson / Mathworld formula)
        If u_val < PI Then
            x = 6 * Cos(u_val) * (1 + Sin(u_val)) + _
            (4 * (1 - Cos(u_val) / 2)) * Cos(u_val) * Cos(v_val)
            z = 16 * Sin(u_val) + _
            (4 * (1 - Cos(u_val) / 2)) * Sin(u_val) * Cos(v_val)
        Else
            x = 6 * Cos(u_val) * (1 + Sin(u_val)) + _
            (4 * (1 - Cos(u_val) / 2)) * Cos(v_val + PI)
            z = 16 * Sin(u_val)
        End If
        
        y = (4 * (1 - Cos(u_val) / 2)) * Sin(v_val)
        
        ' 3D -> 2D Projection (with 30-degree rotation around Y and Z axes for better depth)
        Dim As Double cos_a = 0.866   ' cos(30°)
        Dim As Double sin_a = 0.500   ' sin(30°)
        
        ' Rotated coordinates
        Dim As Double x_rot = x * cos_a - y * sin_a
        Dim As Double y_rot = x * sin_a + y * cos_a
        Dim As Double z_rot = z
        
        ' Scale and translate to the center of the 900x700 window
        Dim As Double scale = 17
        Dim As Integer screen_x = 450 + (x_rot - y_rot * 0.3) * scale
        Dim As Integer screen_y = 400 - (z_rot - y_rot * 0.2) * scale
        
        ' Save for wireframe drawing
        points_x(u, v) = screen_x
        points_y(u, v) = screen_y
    Next
Next

' --- STEP 2: Connect the 3D wireframe mesh ---
For u = 0 To steps_u - 1
    For v = 0 To steps_v - 1
        ' Line to adjacent V point (U lines)
        Line (points_x(u, v), points_y(u, v)) - _
        (points_x(u, v + 1), points_y(u, v + 1)), meshColor
        ' Line to adjacent U point (V lines)
        Line (points_x(u, v), points_y(u, v)) - _
        (points_x(u + 1, v), points_y(u + 1, v)), meshColor
    Next
Next

Sleep
