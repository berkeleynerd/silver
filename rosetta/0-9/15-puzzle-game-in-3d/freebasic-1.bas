#include once "raylib.bi"
#inclib "raylib"
#inclib "gdi32"
#inclib "winmm"
#inclib "shell32"

Const As Integer ScrW = 1024, ScrH = 768

Dim Shared As Integer board(1 To 9)
Dim Shared As Integer emptyPos, moveCount, solved
Dim Shared As Double startTime

Function TileX(idx As Integer) As Single
    Select Case ((idx - 1) Mod 3)
    Case 0 : Return -5.0
    Case 1 : Return 0.0
    Case 2 : Return 5.0
    End Select
    
    Return 0
End Function

Function TileY(idx As Integer) As Single
    Select Case ((idx - 1) \ 3)
    Case 0 : Return 5.0
    Case 1 : Return 1.0
    Case 2 : Return -3.0
    End Select
    
    Return 0
End Function

Function isSolved() As Integer
    Dim objetivo(1 To 9) As Integer => {1, 2, 3, 4, 5, 6, 7, 8, 9}
    
    For i As Integer = 1 To 9
        If board(i) <> objetivo(i) Then Return False
    Next
    
    Return True
End Function

Function isSolvable() As Integer
    Dim As Integer inv = 0
    For i As Integer = 1 To 9
        For j As Integer = i + 1 To 9
            If board(i) <> 9 And board(j) <> 9 And board(i) > board(j) Then
                inv += 1
            End If
        Next
    Next
    
    Return ((inv Mod 2) = 0)
End Function

Sub NewGame()
    Dim As Integer r
    Dim As Integer used(1 To 9)
    
    moveCount = 0
    solved = False
    startTime = GetTime()
    
    Do
        For i As Integer = 1 To 9
            Do
                r = Int(Rnd * 9) + 1
            Loop While used(r)
            
            used(r) = True
            board(i) = r
            If r = 9 Then emptyPos = i
        Next
    Loop Until isSolvable() And Not isSolved()
End Sub

Sub SwapTiles(a As Integer, b As Integer)
    Dim As Integer t = board(a)
    board(a) = board(b)
    board(b) = t
End Sub

Function TryMove(tile As Integer) As Integer
    Dim upMove   As Integer = (emptyPos = tile - 3)
    Dim downMove As Integer = (emptyPos = tile + 3)
    
    Dim leftMove  As Integer = ((emptyPos = tile - 1) And ((tile Mod 3) <> 1))
    Dim rightMove As Integer = ((emptyPos = tile + 1) And ((tile Mod 3) <> 0))
    
    If upMove Or downMove Or leftMove Or rightMove Then
        SwapTiles(emptyPos, tile)
        emptyPos = tile
        moveCount += 1
        solved = isSolved()
        Return True
    End If
    
    Return False
End Function

' Main program
Randomize Timer

InitWindow(ScrW, ScrH, "8 Puzzle 3D - FreeBASIC + Raylib")

Dim As Camera3D camera = Camera3D(Vector3(0, 4, 20), Vector3(0, 0, 0), Vector3(0, 1, 0), 45.0, CAMERA_PERSPECTIVE)

SetTargetFPS(60)
NewGame()

While Not WindowShouldClose()
    If isKeyPressed(KEY_R) Then NewGame()
    
    If Not solved Then
        If isMouseButtonPressed(MOUSE_BUTTON_LEFT) Then
            Dim As Integer mx = GetMouseX()
            Dim As Integer my = GetMouseY()
            
            Dim As Integer bestTile = 0
            Dim As Single bestDist = 1.0E+30
            
            For i As Integer = 1 To 9
                If board(i) <> 9 Then
                    Dim cubePos   As Vector3 = Vector3(TileX(i), TileY(i), -5.0)
                    Dim screenPos As Vector2 = GetWorldToScreen(cubePos, camera)
                    
                    Dim As Single dx = mx - screenPos.x
                    Dim As Single dy = my - screenPos.y
                    Dim As Single dist = dx * dx + dy * dy
                    
                    If dist < bestDist Then bestDist = dist: bestTile = i
                End If
            Next
            
            If bestTile <> 0 And bestDist < 5000 Then TryMove(bestTile)
        End If
    End If
    
    Dim As Integer elapsed = Cint(GetTime() - startTime)
    
    BeginDrawing()
    ClearBackground(BLACK)
    
    BeginMode3D(camera)
    DrawGrid(20, 1.0)
    
    For i As Integer = 1 To 9
        If board(i) <> 9 Then
            Dim cubePos As Vector3 = Vector3(TileX(i), TileY(i), -5.0)
            
            Dim As RLColor cubeColor
            Select Case board(i)
            Case 1 To 3: cubeColor = RED
            Case 4 To 6: cubeColor = GREEN
            Case Else  : cubeColor = BLUE
            End Select
            
            DrawCube(cubePos, 2, 2, 2, cubeColor)
            DrawCubeWires(cubePos, 2, 2, 2, WHITE)
        End If
    Next
    
    EndMode3D()
    
    For i As Integer = 1 To 9
        If board(i) <> 9 Then
            Dim As Vector3 cubePos = Vector3(TileX(i), TileY(i), -5.0)
            Dim As Vector2 screenPos = GetWorldToScreen(cubePos, camera)
            Dim As String txt = Trim(Str(board(i)))
            
            DrawText(Strptr(txt), Cint(screenPos.x) - 8, Cint(screenPos.y) - 12, 28, WHITE)
        End If
    Next
    
    DrawText("8 PUZZLE 3D", 20, 20, 30, YELLOW)
    DrawText("Click a tile adjacent to empty space", 20, 60, 20, WHITE)
    
    Dim As String txt = "Moves: " & Trim(Str(moveCount))
    DrawText(Strptr(txt), 20, 100, 24, GOLD)
    
    txt = "Time: " & Trim(Str(elapsed)) & " sec"
    DrawText(Strptr(txt), 20, 130, 24, GOLD)
    
    DrawText("R = New Game", 20, 170, 20, LIGHTGRAY)
    
    If solved Then
        DrawRectangle(180, 260, 660, 180, GOLD)
        DrawText("PUZZLE SOLVED!", 290, 290, 50, DARKGREEN)
        
        txt = "Completed in " & Trim(Str(moveCount)) & " moves"
        DrawText(Strptr(txt), 330, 360, 30, BLACK)
        DrawText("Press R to start a new game", 330, 400, 24, MAROON)
    End If
    
    EndDrawing()
Wend

CloseWindow()
