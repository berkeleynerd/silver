#include once "SDL2/SDL.bi"
#include once "GL/gl.bi"
#include once "GL/glu.bi"

#Inclib "SDL2"

Const As Single PI = 4 * Atn(1.0)
Const ScrW = 800
Const ScrH = 600

' Hyperbolic cosine
Function my_cosh(x As Double) As Double
    Dim As Double e = 2.718281828
    Return (e^x + e^(-x)) / 2
End Function

Sub drawCatenoid()
    glClear(GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT)
    glLoadIdentity()
    
    ' Move the camera back and rotate it
    glTranslatef(0.0, 0.0, -5.0)
    glRotatef(60, 1.0, 0.5, 0.0)
    glScalef(0.5, 0.5, 0.5)
    
    Dim As Double a = 1.0
    Dim As Integer u_steps = 40
    Dim As Integer v_steps = 40
    
    glBegin(GL_LINES)
    
    For i As Integer = 0 To u_steps
        ' Scale u between -2.0 and +2.0
        Dim As Double u  = -2.0 + (i * (4.0 / u_steps))
        Dim As Double u2 = -2.0 + ((i + 1) * (4.0 / u_steps))
        
        For j As Integer = 0 To v_steps
            ' Scale v between 0 and 2*PI
            Dim As Double v = j * (2 * PI / v_steps)
            
            ' Parametric catenoid
            Dim As Double x = a * my_cosh(u) * Cos(v)
            Dim As Double y = a * my_cosh(u) * Sin(v)
            Dim As Double z = a * u
            
            ' Color gradient based on height
            glColor3f((z + 2)/4, 0.4, 1.0 - (z + 2)/4)
            glVertex3f(x, y, z)
            
            ' Next point for the grid line
            Dim As Double x2 = a * my_cosh(u2) * Cos(v)
            Dim As Double y2 = a * my_cosh(u2) * Sin(v)
            Dim As Double z2 = a * u2
            
            glVertex3f(x2, y2, z2)
        Next
    Next
    
    glEnd()
End Sub

' Main program
If SDL_Init(SDL_INIT_VIDEO Or SDL_INIT_TIMER) <> 0 Then
    Print "SDL_Init error: "; *SDL_GetError()
    End
End If

' Request OpenGL 2.1 context
SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2)
SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1)
SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)

Dim ventana As SDL_Window Ptr
ventana = SDL_CreateWindow("Catenoid 3D - FreeBASIC", _
SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, _
ScrW, ScrH, SDL_WINDOW_OPENGL Or SDL_WINDOW_SHOWN)

If ventana = 0 Then
    Print "SDL_CreateWindow error: "; *SDL_GetError()
    SDL_Quit()
    End
End If

Dim glcontext As SDL_GLContext
glcontext = SDL_GL_CreateContext(ventana)

If glcontext = 0 Then
    Print "SDL_GL_CreateContext error: "; *SDL_GetError()
    SDL_DestroyWindow(ventana)
    SDL_Quit()
    End
End If

SDL_GL_SetSwapInterval(1)  ' VSync

' OpenGL setup
glEnable(GL_DEPTH_TEST)
glClearColor(0.1, 0.1, 0.1, 1.0)

glMatrixMode(GL_PROJECTION)
glLoadIdentity()
gluPerspective(45.0, ScrW/ScrH, 1.0, 10.0)
glMatrixMode(GL_MODELVIEW)

' Main loop
Dim evt As SDL_Event
Dim running As Boolean = True

While running
    While SDL_PollEvent(@evt) <> 0
        If evt.type = SDL_QUIT_ Then running = False
        If evt.type = SDL_KEYDOWN Then
            If evt.key.keysym.sym = SDLK_ESCAPE Then running = False
        End If
    Wend
    
    drawCatenoid()
    SDL_GL_SwapWindow(ventana)
Wend

SDL_GL_DeleteContext(glcontext)
SDL_DestroyWindow(ventana)
SDL_Quit()
