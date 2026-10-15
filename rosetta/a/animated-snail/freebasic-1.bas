#Include Once "GLFW/glfw3.bi"
#Include Once "GL/gl.bi"
#Include Once "GL/glu.bi"

Const SCR_WIDTH = 800
Const SCR_HEIGHT = 600

Dim Shared RotateY As Single = 0.0
Dim Shared lastTime As Double

Sub drawScene()
    glClear(GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT)
    glLoadIdentity()
    
    glTranslatef(0.0, 0.0, -25.0)
    glRotatef(RotateY, 0.5, 1.0, 0.0)
    
    glBegin(GL_LINE_STRIP)
    Dim As Single a = 0.1, b = 0.2, h = 0.15
    Dim As Single theta, r
    
    For theta = 0 To 60 Step 0.1
        r = a + b * theta
        glColor3f( Sin(theta * 0.1), Cos(theta * 0.1), 0.7 )
        glVertex3f( r * Cos(theta), r * Sin(theta), (theta * h) - 5.0 )
    Next
    glEnd()
End Sub

Sub framebufferSizeCallback(ventana As GLFWwindow Ptr, w As Integer, h As Integer)
    If h = 0 Then h = 1
    glViewport(0, 0, w, h)
    
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluPerspective(45.0, w / h, 1.0, 100.0)
    glMatrixMode(GL_MODELVIEW)
End Sub

' --- Main program ---
If glfwInit() = 0 Then Print "Error initializing GLFW": Sleep: End

glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1)

Dim ventana As GLFWwindow Ptr
ventana = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "Animated snail - FreeBASIC", 0, 0)

If ventana = 0 Then
    Print "The window could not be created"
    glfwTerminate()
    Sleep: End
End If

glfwMakeContextCurrent(ventana)
glfwSetFramebufferSizeCallback(ventana, @framebufferSizeCallback)

glEnable(GL_DEPTH_TEST)
glClearColor(0.0, 0.0, 0.0, 1.0)

framebufferSizeCallback(ventana, SCR_WIDTH, SCR_HEIGHT)

lastTime = glfwGetTime()

' --- Main loop ---
While glfwWindowShouldClose(ventana) = 0
    Dim currentTime As Double = glfwGetTime()
    Dim delta As Double = currentTime - lastTime
    lastTime = currentTime
    
    ' Smooth rotation: 20 degrees per second
    RotateY += delta * 20
    If RotateY > 360 Then RotateY -= 360
    
    drawScene()
    
    glfwSwapBuffers(ventana)
    glfwPollEvents()
Wend

glfwTerminate()
