REM ASCII mode
Const MAP_WIDTH = 86
Const MAP_HEIGHT = 16

Type Punto
    As Integer x
    As Integer y
End Type

Type Boid
    As Punto posic
End Type

Type Environment
    As Ubyte buffer(MAP_HEIGHT-1, MAP_WIDTH-1)
    As Boid boids(17)
    As Integer boidCnt
End Type

Dim Shared As Environment env

' Initialize map with walls and spaces
Sub initMap()
    Dim As Integer x, y
    
    ' Add cave obstacles (hardcoded pattern)
    Dim cave(0 To MAP_HEIGHT-1) As String = { _
    "       ###############                                                               ", _
    "       ###############                                                               ", _
    "      #################                                                              ", _
    "O      ###############                                                               ", _
    "OO     ###############                                                               ", _
    "OO     ###############                    #                         #                ", _
    "OO      #############                   #####                   #########            ", _
    "OO      #############                   #####                  ###########           ", _
    "OO       ###########                   #######                #############          ", _
    "OO         #######                      #####                ###############         ", _
    "OO            #                         #####               #################        ", _
    "OO                                        #                 #################        ", _
    "O                                                           #################        ", _
    "                                                            #################        ", _
    "                                                           ###################       ", _
    "                                                            #################        " }
    
    env.boidCnt = 0
    
    ' Process the map line by line
    For y = 0 To MAP_HEIGHT-1
        For x = 0 To MAP_WIDTH-1
            'Select Case Mid(cave, posic, 1)
            Select Case Mid(cave(y), x+1, 1)
            Case "#"
                env.buffer(y, x) = Asc("#")
            Case "O"
                env.boids(env.boidCnt).posic.x = x
                env.boids(env.boidCnt).posic.y = y
                env.boidCnt += 1
                env.buffer(y, x) = Asc(" ")
            Case Else
                env.buffer(y, x) = Asc(" ")
            End Select
        Next x
    Next y
    
    ' Add frame
    For x = 0 To MAP_WIDTH-1
        env.buffer(0, x) = Asc("#")
        env.buffer(MAP_HEIGHT-1, x) = Asc("#")
    Next x
    For y = 0 To MAP_HEIGHT-1
        env.buffer(y, 0) = Asc("#")
        env.buffer(y, MAP_WIDTH-1) = Asc("#")
    Next y
    '
End Sub

' Check if position is free
Function isFree(x As Integer, y As Integer) As Boolean
    If env.buffer(y,x) = Asc(" ") Then
        For i As Integer = 0 To env.boidCnt-1
            If env.boids(i).posic.x = x Andalso env.boids(i).posic.y = y Then Return False
        Next
        Return True
    End If
    Return False
End Function

Sub moveBoids()
    For i As Integer = 0 To env.boidCnt-1
        Dim As Integer nx = env.boids(i).posic.x + 1
        Dim As Integer ny = env.boids(i).posic.y
        
        ' Try to move right
        If isFree(nx, ny) Then
            env.boids(i).posic.x = nx
            ' If blocked, try up or down
        Elseif isFree(env.boids(i).posic.x, ny-1) Then
            env.boids(i).posic.y -= 1
        Elseif isFree(env.boids(i).posic.x, ny+1) Then
            env.boids(i).posic.y += 1
        End If
    Next
End Sub

Sub drawState()
    Dim As Integer x, y, i
    Cls
    ' Draw environment (walls in white)
    Color RGB(255,255,255)
    For y = 0 To MAP_HEIGHT-1
        For x = 0 To MAP_WIDTH-1
            Draw String (x*8, y*16), Chr(env.buffer(y,x))
        Next x
    Next y
    
    ' Draw boids (green)
    For i = 0 To env.boidCnt-1
        Color RGB(0,255,0)
        Draw String (env.boids(i).posic.x*8, env.boids(i).posic.y*16), Chr(7)
    Next
End Sub

' Main program
Screenres MAP_WIDTH*8, MAP_HEIGHT*16, 32
Windowtitle "Boids in FreeBASIC"

initMap()

Do
    moveBoids()
    drawState()
    Sleep 100
Loop Until Multikey(&h01)
