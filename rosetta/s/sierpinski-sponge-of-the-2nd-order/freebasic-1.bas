#include once "SDL2/SDL.bi"
#include once "GL/gl.bi"
#include once "GL/glu.bi"

Const ScrW = 800, ScrH = 600

Sub InitGL()
    glViewport(0, 0, ScrW, ScrH)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluPerspective(45.0, ScrW / ScrH, 0.1, 100.0)
    
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_CULL_FACE)
    glCullFace(GL_BACK)
    
    glClearColor(245.0/255.0, 247.0/255.0, 250.0/255.0, 1.0)
End Sub

Sub DrawCube(size As Single)
    Dim s As Single = size / 2
    
    glBegin(GL_QUADS)
    glColor3f(1.0, 1.0, 1.0)
    
    ' Frente
    glVertex3f(-s,-s, s) : glVertex3f( s,-s, s)
    glVertex3f( s, s, s) : glVertex3f(-s, s, s)
    
    ' Atrás
    glVertex3f( s,-s,-s) : glVertex3f(-s,-s,-s)
    glVertex3f(-s, s,-s) : glVertex3f( s, s,-s)
    
    ' Izquierda
    glVertex3f(-s,-s,-s) : glVertex3f(-s,-s, s)
    glVertex3f(-s, s, s) : glVertex3f(-s, s,-s)
    
    ' Derecha
    glVertex3f( s,-s, s) : glVertex3f( s,-s,-s)
    glVertex3f( s, s,-s) : glVertex3f( s, s, s)
    
    ' Abajo
    glVertex3f(-s,-s,-s) : glVertex3f( s,-s,-s)
    glVertex3f( s,-s, s) : glVertex3f(-s,-s, s)
    
    ' Arriba
    glVertex3f(-s, s, s) : glVertex3f( s, s, s)
    glVertex3f( s, s,-s) : glVertex3f(-s, s,-s)
    
    glEnd()
End Sub

Sub DrawCubeWire(size As Single)
    Dim s As Single = size / 2
    
    glColor3f(160/255, 170/255, 185/255)
    glLineWidth(1.5)
    
    glBegin(GL_LINES)
    
    ' 12 edges
    Dim v(7,2) As Single = { _
    {-s,-s,-s}, {s,-s,-s}, {s,s,-s}, {-s,s,-s}, _
    {-s,-s, s}, {s,-s, s}, {s,s, s}, {-s,s, s} }
    
    Dim edges(11,1) As Integer = { _
    {0,1},{1,2},{2,3},{3,0}, _
    {4,5},{5,6},{6,7},{7,4}, _
    {0,4},{1,5},{2,6},{3,7} }
    
    For i As Integer = 0 To 11
        glVertex3f(v(edges(i,0),0), v(edges(i,0),1), v(edges(i,0),2))
        glVertex3f(v(edges(i,1),0), v(edges(i,1),1), v(edges(i,1),2))
    Next
    
    glEnd()
End Sub

Sub DrawHoleySponge(x As Single, y As Single, z As Single, size As Single, level As Integer)
    If level = 0 Then
        glPushMatrix()
        glTranslatef(x, y, z)
        DrawCube(size)
        DrawCubeWire(size)
        glPopMatrix()
        Exit Sub
    End If
    
    Dim newSize As Single = size / 3
    
    For dx As Integer = -1 To 1
        For dy As Integer = -1 To 1
            For dz As Integer = -1 To 1
                
                ' Cantor Dust: only corners
                Dim cx As Integer = Iif(dx = 0, 1, 0)
                Dim cy As Integer = Iif(dy = 0, 1, 0)
                Dim cz As Integer = Iif(dz = 0, 1, 0)
                
                If (cx + cy + cz) < 1 Then 
                    DrawHoleySponge(x + dx * newSize, y + dy * newSize, z + dz * newSize, newSize, level - 1)
                End If
            Next dz
        Next dy
    Next dx
End Sub


' Main program
If SDL_Init(SDL_INIT_VIDEO Or SDL_INIT_TIMER) <> 0 Then
    Print "SDL_Init error: "; *SDL_GetError()
    Sleep: End
End If

Dim ventana As SDL_Window Ptr = SDL_CreateWindow( _
"Super-holey Menger Sponge (Cantor Dust) - FreeBASIC + SDL2 + OpenGL", _
SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, _
ScrW, ScrH, SDL_WINDOW_OPENGL Or SDL_WINDOW_SHOWN)

Dim glContext As SDL_GLContext = SDL_GL_CreateContext(ventana)
SDL_GL_SetSwapInterval(1)

InitGL()

' Main loop
Dim running As Boolean = True
Dim event As SDL_Event
Dim angle As Single = 0

While running
    While SDL_PollEvent(@event) <> 0
        If event.type = SDL_QUIT_ Then running = False
        If event.type = SDL_KEYDOWN Then
            If event.key.keysym.sym = SDLK_ESCAPE Then running = False
        End If
    Wend
    
    angle += 0.01
    
    glClear(GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT)
    
    glLoadIdentity()
    
    ' Camera orbiting
    Dim camX As Single = 6.5 * Cos(angle)
    Dim camZ As Single = 6.5 * Sin(angle)
    gluLookAt(camX, 6.5, camZ, 0,0,0, 0,1,0)
    
    DrawHoleySponge(0, 0, 0, 4.2, 2)
    
    SDL_GL_SwapWindow(ventana)
Wend

SDL_GL_DeleteContext(glContext)
SDL_DestroyWindow(ventana)
SDL_Quit()
