#Include Once "GLFW/glfw3.bi"
#Include Once "GL/gl.bi"
#Include Once "GL/glu.bi"

Const NULL As Any Ptr = 0
Const SrcW As Integer = 500
Const SrcH As Integer = 900
Const PI As Single = 4 * Atn(1.0)

' Rotation angles (in radians)
Dim Shared angleX As Double = 0.35
Dim Shared angleY As Double = 0.6

Dim Shared lastTime As Double = 0.0

Sub Draw3DLine(x1 As Double, y1 As Double, z1 As Double, _
    x2 As Double, y2 As Double, z2 As Double)
    glBegin GL_LINES
    glVertex3D x1, y1, z1
    glVertex3D x2, y2, z2
    glEnd
End Sub

Sub Draw3DBlock(cx As Double, cy As Double, cz As Double, _
    w As Double, h As Double, d As Double, detailLevel As Integer)
    Dim dx As Double = w / 2.0
    Dim dy As Double = h / 2.0
    Dim dz As Double = d / 2.0
    
    ' Colors
    Dim rEdge As Single = 140.0f / 255.0f
    Dim gEdge As Single = 145.0f / 255.0f
    Dim bEdge As Single = 160.0f / 255.0f
    
    Dim rWin As Single = 255.0f / 255.0f
    Dim gWin As Single = 245.0f / 255.0f
    Dim bWin As Single = 180.0f / 255.0f
    
    Dim rPil As Single = 70.0f / 255.0f
    Dim gPil As Single = 75.0f / 255.0f
    Dim bPil As Single = 90.0f / 255.0f
    
    Dim offset As Double, yStep As Double, xStep As Double
    If detailLevel = 3 Then
        glColor3f rPil, gPil, bPil
        For offset = -dx + 6 To dx - 6 Step 8
            Draw3DLine cx + offset, cy - dy, cz - dz, cx + offset, cy + dy, cz - dz
            Draw3DLine cx + offset, cy - dy, cz + dz, cx + offset, cy + dy, cz + dz
            Draw3DLine cx - dx, cy - dy, cz + offset, cx - dx, cy + dy, cz + offset
            Draw3DLine cx + dx, cy - dy, cz + offset, cx + dx, cy + dy, cz + offset
        Next
        
        glColor3f rWin, gWin, bWin
        For yStep = -dy + 10 To dy - 10 Step 12
            For xStep = -dx + 6 To dx - 6 Step 8
                Draw3DLine cx + xStep, cy + yStep, cz - dz, cx + xStep, cy + yStep + 3, cz - dz
                Draw3DLine cx + xStep, cy + yStep, cz + dz, cx + xStep, cy + yStep + 3, cz + dz
                Draw3DLine cx - dx, cy + yStep, cz + xStep, cx - dx, cy + yStep + 3, cz + xStep
                Draw3DLine cx + dx, cy + yStep, cz + xStep, cx + dx, cy + yStep + 3, cz + xStep
            Next
        Next
    End If
    
    If detailLevel = 2 Then
        glColor3f rPil, gPil, bPil
        For offset = -dx + 10 To dx - 10 Step 15
            Draw3DLine cx + offset, cy - dy, cz - dz, cx + offset, cy + dy, cz - dz
            Draw3DLine cx + offset, cy - dy, cz + dz, cx + offset, cy + dy, cz + dz
        Next
        
        glColor3f rWin, gWin, bWin
        For yStep = -dy + 15 To dy - 15 Step 18
            For xStep = -dx + 12 To dx - 12 Step 15
                Draw3DLine cx + xStep, cy + yStep, cz - dz, cx + xStep, cy + yStep + 4, cz - dz
                Draw3DLine cx + xStep, cy + yStep, cz + dz, cx + xStep, cy + yStep + 4, cz + dz
                Draw3DLine cx - dx, cy + yStep, cz + xStep, cx - dx, cy + yStep + 4, cz + xStep
                Draw3DLine cx + dx, cy + yStep, cz + xStep, cx + dx, cy + yStep + 4, cz + xStep
            Next
        Next
    End If
    
    If detailLevel = 4 Then
        glColor3f rPil, gPil, bPil
        For offset = -dx + 4 To dx - 4 Step 6
            Draw3DLine cx + offset, cy - dy, cz - dz, cx + offset, cy + dy, cz - dz
            Draw3DLine cx - dx, cy - dy, cz + offset, cx - dx, cy + dy, cz + offset
        Next
        
        glColor3f rWin, gWin, bWin
        Draw3DLine cx - dx + 5, cy, cz - dz + 5, cx + dx - 5, cy, cz - dz + 5
    End If
    
    glColor3f rEdge, gEdge, bEdge
    glLineWidth 2.0f
    
    Draw3DLine cx - dx, cy - dy, cz - dz, cx + dx, cy - dy, cz - dz
    Draw3DLine cx + dx, cy - dy, cz - dz, cx + dx, cy + dy, cz - dz
    Draw3DLine cx + dx, cy + dy, cz - dz, cx - dx, cy + dy, cz - dz
    Draw3DLine cx - dx, cy + dy, cz - dz, cx - dx, cy - dy, cz - dz
    
    Draw3DLine cx - dx, cy - dy, cz + dz, cx + dx, cy - dy, cz + dz
    Draw3DLine cx + dx, cy - dy, cz + dz, cx + dx, cy + dy, cz + dz
    Draw3DLine cx + dx, cy + dy, cz + dz, cx - dx, cy + dy, cz + dz
    Draw3DLine cx - dx, cy + dy, cz + dz, cx - dx, cy - dy, cz + dz
    
    Draw3DLine cx - dx, cy - dy, cz - dz, cx - dx, cy - dy, cz + dz
    Draw3DLine cx + dx, cy - dy, cz - dz, cx + dx, cy - dy, cz + dz
    Draw3DLine cx + dx, cy + dy, cz - dz, cx + dx, cy + dy, cz + dz
    Draw3DLine cx - dx, cy + dy, cz - dz, cx - dx, cy + dy, cz + dz
    
    glLineWidth 1.0f
End Sub

' Antenna
Sub Draw3DSpire(x1 As Double, y1 As Double, z1 As Double, _
    x2 As Double, y2 As Double, z2 As Double)
    glColor3f 240.0f/255.0f, 240.0f/255.0f, 250.0f/255.0f
    glLineWidth 3.0f
    Draw3DLine x1, y1, z1, x2, y2, z2
    glLineWidth 1.0f
End Sub

' Rendering of the frame
Sub RenderFrame(deltaTime As Double)
    glClearColor 8.0f/255.0f, 12.0f/255.0f, 22.0f/255.0f, 1.0f
    glClear GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT
    
    glMatrixMode GL_MODELVIEW
    glLoadIdentity
    
    ' Translation
    glTranslated 0.0, -50.0, -750.0
    
    ' Time-based rotation: ~0.4 rad/s in Y
    angleY += 0.4 * deltaTime
    
    glRotated angleX * 180.0 / PI, 1.0, 0.0, 0.0
    glRotated angleY * 180.0 / PI, 0.0, 1.0, 0.0
    
    Draw3DBlock 0, -180, 0, 150, 70, 150, 1
    Draw3DBlock 0, -90, 0, 110, 110, 110, 2
    Draw3DBlock 0, 80, 0, 66, 230, 66, 3
    Draw3DBlock 0, 210, 0, 42, 30, 42, 4
    Draw3DBlock 0, 235, 0, 20, 20, 20, 5
    
    Draw3DSpire 0, 245, 0, 0, 325, 0
End Sub

' resizing callback
Sub FramebufferSizeCallback(Byval ventana As GLFWwindow Ptr, Byval ancho As Long, Byval alto As Long)
    glViewport 0, 0, ancho, alto
    
    glMatrixMode GL_PROJECTION
    glLoadIdentity
    
    Dim aspect As Double = Iif(alto = 0, 1.0, ancho / alto)
    gluPerspective 45.0, aspect, 1.0, 2000.0
    
    glMatrixMode GL_MODELVIEW
    glLoadIdentity
End Sub

' Key callback: close with ESC
Sub KeyCallback(Byval ventana As GLFWwindow Ptr, Byval key As Long, _
    Byval scancode As Long, Byval action As Long, Byval mods As Long)
    If key = GLFW_KEY_ESCAPE And action = GLFW_PRESS Then
        glfwSetWindowShouldClose(ventana, GL_TRUE)
    End If
End Sub

Sub main()
    If glfwInit() = GL_FALSE Then End 1
    
    glfwWindowHint GLFW_SAMPLES, 4
    
    Dim ventana As GLFWwindow Ptr
    ventana = glfwCreateWindow(SrcW, SrcH, "Empire State Building 3D - FreeBASIC + OpenGL", NULL, NULL)
    If ventana = NULL Then glfwTerminate(): End 1
    
    glfwMakeContextCurrent ventana
    
    ' Callbacks
    glfwSetFramebufferSizeCallback(ventana, @FramebufferSizeCallback)
    glfwSetKeyCallback(ventana, @KeyCallback)
    
    ' Initial projection
    FramebufferSizeCallback(ventana, SrcW, SrcH)
    
    glEnable GL_DEPTH_TEST
    glEnable GL_LINE_SMOOTH
    glHint GL_LINE_SMOOTH_HINT, GL_NICEST
    
    lastTime = glfwGetTime()
    
    While glfwWindowShouldClose(ventana) = GL_FALSE
        Dim currentTime As Double = glfwGetTime()
        Dim deltaTime As Double = currentTime - lastTime
        lastTime = currentTime
        
        RenderFrame(deltaTime)
        
        glfwSwapBuffers ventana
        glfwPollEvents()
    Wend
    
    glfwDestroyWindow ventana
    glfwTerminate()
End Sub

main()
