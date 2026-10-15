#include "windows.bi"
#include "GL/gl.bi"
#include "GL/glu.bi"

Const SCR_W = 600, SCR_H = 600
Const As Single PI = 4 * Atn(1.0)

Dim Shared As Double radius = 11.0
Dim Shared As Double rotY = 0.0
Dim Shared As Double rotX = 0.0
Dim Shared As Double velY = 0.7   ' frequency in Y
Dim Shared As Double velX = 0.5   ' frequency in X
Dim Shared As Double lastTime = 0
Dim Shared As Double delta = 0
Dim Shared As Double t = 0.0

Sub SetupProjection()
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    
    Dim fov As Double = 45.0
    Dim aspect As Double = SCR_W / SCR_H
    Dim nearZ As Double = 0.1
    Dim farZ  As Double = 100.0
    
    Dim top As Double = nearZ * Tan(fov * 0.5 * PI / 180.0)
    Dim bottom As Double = -top
    Dim dcha As Double = top * aspect
    Dim izda As Double = -dcha
    
    glFrustum(izda, dcha, bottom, top, nearZ, farZ)
    glMatrixMode(GL_MODELVIEW)
End Sub

Sub DrawCubie(Byval x As Double, Byval y As Double, Byval z As Double)
    Dim As Double cubieSize = 1.0
    Dim As Double stickerThickness = 0.05
    Dim As Double stickerSize = 0.85
    
    glPushMatrix()
    glTranslated(x, y, z)
    
    ' Black base
    glColor3d(0.0, 0.0, 0.0)
    glScaled(cubieSize, cubieSize, cubieSize)
    glBegin(GL_QUADS)
    ' Front
    glVertex3d(-0.5, -0.5,  0.5)
    glVertex3d(0.5, -0.5,  0.5)
    glVertex3d(0.5,  0.5,  0.5)
    glVertex3d(-0.5,  0.5,  0.5)
    ' Back
    glVertex3d(-0.5, -0.5, -0.5)
    glVertex3d(-0.5,  0.5, -0.5)
    glVertex3d(0.5,  0.5, -0.5)
    glVertex3d(0.5, -0.5, -0.5)
    ' Left
    glVertex3d(-0.5, -0.5, -0.5)
    glVertex3d(-0.5, -0.5,  0.5)
    glVertex3d(-0.5,  0.5,  0.5)
    glVertex3d(-0.5,  0.5, -0.5)
    ' Right
    glVertex3d(0.5, -0.5, -0.5)
    glVertex3d(0.5,  0.5, -0.5)
    glVertex3d(0.5,  0.5,  0.5)
    glVertex3d(0.5, -0.5,  0.5)
    ' Top
    glVertex3d(-0.5,  0.5, -0.5)
    glVertex3d(-0.5,  0.5,  0.5)
    glVertex3d(0.5,  0.5,  0.5)
    glVertex3d(0.5,  0.5, -0.5)
    ' Bottom
    glVertex3d(-0.5, -0.5, -0.5)
    glVertex3d(0.5, -0.5, -0.5)
    glVertex3d(0.5, -0.5,  0.5)
    glVertex3d(-0.5, -0.5,  0.5)
    glEnd()
    
    ' Right (x=1) -> red
    If x > 0.9 Then
        glColor3d(1.0, 0.0, 0.0)
        glBegin(GL_QUADS)
        glVertex3d(0.5 + stickerThickness, -0.5*stickerSize, -0.5*stickerSize)
        glVertex3d(0.5 + stickerThickness,  0.5*stickerSize, -0.5*stickerSize)
        glVertex3d(0.5 + stickerThickness,  0.5*stickerSize,  0.5*stickerSize)
        glVertex3d(0.5 + stickerThickness, -0.5*stickerSize,  0.5*stickerSize)
        glEnd()
    End If
    
    ' Left (x=-1) -> blue
    If x < -0.9 Then
        glColor3d(0.0, 0.0, 1.0)
        glBegin(GL_QUADS)
        glVertex3d(-0.5 - stickerThickness, -0.5*stickerSize, -0.5*stickerSize)
        glVertex3d(-0.5 - stickerThickness, -0.5*stickerSize,  0.5*stickerSize)
        glVertex3d(-0.5 - stickerThickness,  0.5*stickerSize,  0.5*stickerSize)
        glVertex3d(-0.5 - stickerThickness,  0.5*stickerSize, -0.5*stickerSize)
        glEnd()
    End If
    
    ' Top (y=1) -> yellow
    If y > 0.9 Then
        glColor3d(1.0, 1.0, 0.0)
        glBegin(GL_QUADS)
        glVertex3d(-0.5*stickerSize,  0.5 + stickerThickness, -0.5*stickerSize)
        glVertex3d(-0.5*stickerSize,  0.5 + stickerThickness,  0.5*stickerSize)
        glVertex3d(0.5*stickerSize,  0.5 + stickerThickness,  0.5*stickerSize)
        glVertex3d(0.5*stickerSize,  0.5 + stickerThickness, -0.5*stickerSize)
        glEnd()
    End If
    
    ' Bottom (y=-1) -> green
    If y < -0.9 Then
        glColor3d(0.0, 1.0, 0.0)
        glBegin(GL_QUADS)
        glVertex3d(-0.5*stickerSize, -0.5 - stickerThickness, -0.5*stickerSize)
        glVertex3d(0.5*stickerSize, -0.5 - stickerThickness, -0.5*stickerSize)
        glVertex3d(0.5*stickerSize, -0.5 - stickerThickness,  0.5*stickerSize)
        glVertex3d(-0.5*stickerSize, -0.5 - stickerThickness,  0.5*stickerSize)
        glEnd()
    End If
    
    ' Front (z=1) -> orange
    If z > 0.9 Then
        glColor3d(1.0, 0.5, 0.0)
        glBegin(GL_QUADS)
        glVertex3d(-0.5*stickerSize, -0.5*stickerSize,  0.5 + stickerThickness)
        glVertex3d(0.5*stickerSize, -0.5*stickerSize,  0.5 + stickerThickness)
        glVertex3d(0.5*stickerSize,  0.5*stickerSize,  0.5 + stickerThickness)
        glVertex3d(-0.5*stickerSize,  0.5*stickerSize,  0.5 + stickerThickness)
        glEnd()
    End If
    
    ' Back (z=-1) -> white
    If z < -0.9 Then
        glColor3d(1.0, 1.0, 1.0)
        glBegin(GL_QUADS)
        glVertex3d(-0.5*stickerSize, -0.5*stickerSize, -0.5 - stickerThickness)
        glVertex3d(-0.5*stickerSize,  0.5*stickerSize, -0.5 - stickerThickness)
        glVertex3d(0.5*stickerSize,  0.5*stickerSize, -0.5 - stickerThickness)
        glVertex3d(0.5*stickerSize, -0.5*stickerSize, -0.5 - stickerThickness)
        glEnd()
    End If
    
    ' Wireframe
    glColor3d(0.3, 0.3, 0.3)
    glBegin(GL_LINES)
    ' edges
    glVertex3d(-0.5, -0.5,  0.5) : glVertex3d(0.5, -0.5,  0.5)
    glVertex3d(0.5, -0.5,  0.5) : glVertex3d(0.5,  0.5,  0.5)
    glVertex3d(0.5,  0.5,  0.5) : glVertex3d(-0.5,  0.5,  0.5)
    glVertex3d(-0.5,  0.5,  0.5) : glVertex3d(-0.5, -0.5,  0.5)
    
    glVertex3d(-0.5, -0.5, -0.5) : glVertex3d(0.5, -0.5, -0.5)
    glVertex3d(0.5, -0.5, -0.5) : glVertex3d(0.5,  0.5, -0.5)
    glVertex3d(0.5,  0.5, -0.5) : glVertex3d(-0.5,  0.5, -0.5)
    glVertex3d(-0.5,  0.5, -0.5) : glVertex3d(-0.5, -0.5, -0.5)
    
    glVertex3d(-0.5, -0.5, -0.5) : glVertex3d(-0.5, -0.5,  0.5)
    glVertex3d(0.5, -0.5, -0.5) : glVertex3d(0.5, -0.5,  0.5)
    glVertex3d(0.5,  0.5, -0.5) : glVertex3d(0.5,  0.5,  0.5)
    glVertex3d(-0.5,  0.5, -0.5) : glVertex3d(-0.5,  0.5,  0.5)
    glEnd()
    
    glPopMatrix()
End Sub

Sub RenderScene()
    glClear(GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT)
    glLoadIdentity()   
    gluLookAt(0, 0, radius, 0, 0, 0, 0, 1, 0)
    
    t += delta
    rotY = 25 * Sin(t * velY)
    rotX = 15 * Sin(t * velX)
    
    glPushMatrix()
    glRotated(rotY, 0, 1, 0)
    glRotated(rotX, 1, 0, 0)
    
    ' Cube 3x3x3
    For x As Integer = -1 To 1
        For y As Integer = -1 To 1
            For z As Integer = -1 To 1
                If x = 0 And y = 0 And z = 0 Then Continue For
                DrawCubie(x*1.15, y*1.15, z*1.15)
            Next
        Next
    Next
    glPopMatrix()
End Sub

Function WndProc(Byval hWnd As HWND, Byval uMsg As UINT, _
    Byval wParam As WPARAM, Byval lParam As LPARAM) As LRESULT
    
    Select Case uMsg
    Case WM_DESTROY
        PostQuitMessage(0)
        Return 0
    End Select
    
    Return DefWindowProc(hWnd, uMsg, wParam, lParam)
End Function

Sub InitOpenGL(Byval hWnd As HWND)
    Dim pfd As PIXELFORMATDESCRIPTOR
    With pfd
        .nSize = Sizeof(PIXELFORMATDESCRIPTOR)
        .nVersion = 1
        .dwFlags = PFD_DRAW_TO_WINDOW Or PFD_SUPPORT_OPENGL Or PFD_DOUBLEBUFFER
        .iPixelType = PFD_TYPE_RGBA
        .cColorBits = 32
        .cDepthBits = 24
        .cStencilBits = 8
        .iLayerType = PFD_MAIN_PLANE
    End With
    
    Dim hDC As HDC = GetDC(hWnd)
    Dim pf As Integer = ChoosePixelFormat(hDC, @pfd)
    SetPixelFormat(hDC, pf, @pfd)
    
    Dim hRC As HGLRC = wglCreateContext(hDC)
    wglMakeCurrent(hDC, hRC)
    
    glEnable(GL_DEPTH_TEST)
    glClearColor(0.96, 0.96, 0.96, 1.0)
    
    SetupProjection()
End Sub

' Main program
Dim As HINSTANCE hInst = GetModuleHandle(NULL)
Dim As MSG msg

Dim As WNDCLASS wc
With wc
    .style         = CS_OWNDC
    .lpfnWndProc   = @WndProc
    .cbClsExtra    = 0
    .cbWndExtra    = 0
    .hInstance     = hInst
    .hIcon         = LoadIcon(NULL, IDI_APPLICATION)
    .hCursor       = LoadCursor(NULL, IDC_ARROW)
    .hbrBackground = Cast(HBRUSH, COLOR_WINDOW + 1)
    .lpszMenuName  = NULL
    .lpszClassName = Strptr("RubikGLOrbit")
End With

RegisterClass(@wc)

Dim As HWND hWnd = CreateWindowEx(0, wc.lpszClassName, "Rubik's Cube Orbit - FreeBASIC OpenGL", _
WS_OVERLAPPEDWINDOW Or WS_VISIBLE, _
CW_USEDEFAULT, CW_USEDEFAULT, SCR_W, SCR_H, _
NULL, NULL, hInst, NULL)

InitOpenGL(hWnd)

lastTime = Timer

Do
    While PeekMessage(@msg, NULL, 0, 0, PM_REMOVE)
        If msg.message = WM_QUIT Then Exit Do
        TranslateMessage(@msg)
        DispatchMessage(@msg)
    Wend
    
    Dim ahora As Double = Timer
    delta = ahora - lastTime
    lastTime = ahora
    
    RenderScene()
    SwapBuffers(GetDC(hWnd))
    Sleep(15)   ' 60 FPS
Loop
