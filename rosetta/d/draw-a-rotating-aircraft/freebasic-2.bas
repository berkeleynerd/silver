#include once "SDL2/SDL.bi"

Const ScrW = 640
Const ScrH = 480

Dim Shared angle As Double = 0.0

If SDL_Init(SDL_INIT_VIDEO Or SDL_INIT_TIMER) <> 0 Then
    Print "SDL error: "; *SDL_GetError()
    Sleep: End
End If

Dim ventana As SDL_Window Ptr
Dim renderer As SDL_Renderer Ptr

ventana = SDL_CreateWindow("Rotating Aircraft - FreeBASIC + SDL2", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, ScrW, ScrH, 0)
renderer = SDL_CreateRenderer(ventana, -1, SDL_RENDERER_ACCELERATED Or SDL_RENDERER_PRESENTVSYNC)

If renderer = 0 Then
    Print "Renderer error: "; *SDL_GetError()
    Sleep: End
End If

Sub RotatePoint(x As Double, y As Double, cx As Double, cy As Double, Byref rx As Double, Byref ry As Double)
    Dim dx As Double = x - cx
    Dim dy As Double = y - cy
    rx = cx + dx * Cos(angle) - dy * Sin(angle)
    ry = cy + dx * Sin(angle) + dy * Cos(angle)
End Sub

Sub DrawTriangle(renderer As SDL_Renderer Ptr, _
    x1 As Double, y1 As Double, _
    x2 As Double, y2 As Double, _
    x3 As Double, y3 As Double)
    
    ' Sort by Y
    If y1 > y2 Then Swap y1, y2: Swap x1, x2
    If y2 > y3 Then Swap y2, y3: Swap x2, x3
    If y1 > y2 Then Swap y1, y2: Swap x1, x2
    
    Dim As Double y, xa, xb, t1, t2
    
    For y = y1 To y3
        If y < y2 Then
            t1 = (y - y1) / (y2 - y1 + 0.00001)
            xa = x1 + (x2 - x1) * t1
        Else
            t1 = (y - y2) / (y3 - y2 + 0.00001)
            xa = x2 + (x3 - x2) * t1
        End If
        
        t2 = (y - y1) / (y3 - y1 + 0.00001)
        xb = x1 + (x3 - x1) * t2
        
        If xa > xb Then Swap xa, xb
        
        SDL_RenderDrawLine(renderer, xa, y, xb, y)
    Next
End Sub

Sub DrawRotTriangle(renderer As SDL_Renderer Ptr, cx As Double, cy As Double, _
    x1 As Double, y1 As Double, _
    x2 As Double, y2 As Double, _
    x3 As Double, y3 As Double)
    
    Dim As Double rx1, ry1, rx2, ry2, rx3, ry3
    
    RotatePoint(x1, y1, cx, cy, rx1, ry1)
    RotatePoint(x2, y2, cx, cy, rx2, ry2)
    RotatePoint(x3, y3, cx, cy, rx3, ry3)
    
    DrawTriangle(renderer, rx1, ry1, rx2, ry2, rx3, ry3)
End Sub

Sub DrawRotRect(renderer As SDL_Renderer Ptr, cx As Double, cy As Double, _
    x As Double, y As Double, w As Double, h As Double)
    
    DrawRotTriangle(renderer, cx, cy, x, y, x+w, y, x+w, y+h)
    DrawRotTriangle(renderer, cx, cy, x, y, x+w, y+h, x, y+h)
End Sub

Sub DrawPlane(renderer As SDL_Renderer Ptr)
    Dim cx As Double = 270
    Dim cy As Double = 240
    
    SDL_SetRenderDrawColor(renderer, 80,80,80,255)
    DrawRotTriangle(renderer, cx,cy, 120,240,100,160,150,240)
    DrawRotRect    (renderer, cx,cy, 120,220,300,40)
    
    SDL_SetRenderDrawColor(renderer, 0,0,0,255)
    DrawRotRect    (renderer, cx,cy, 100,230,20,20)
    
    SDL_SetRenderDrawColor(renderer, 80,80,80,255)
    DrawRotTriangle(renderer, cx,cy, 420,220,480,240,420,260)
    
    SDL_SetRenderDrawColor(renderer, 255,200,150,255)
    DrawRotTriangle(renderer, cx,cy, 380,220,410,220,410,235)
    
    SDL_SetRenderDrawColor(renderer, 0,0,120,255)
    DrawRotTriangle(renderer, cx,cy, 220,240,180,290,280,240)
    
    SDL_SetRenderDrawColor(renderer, 255,0,0,255)
    DrawRotTriangle(renderer, cx,cy, 100,235,70,240,100,245)
End Sub

' Main loop
Dim running As Boolean = True
Dim event As SDL_Event

While running
    While SDL_PollEvent(@event) <> 0
        If event.type = SDL_KEYDOWN And event.key.keysym.sym = SDLK_ESCAPE Then running = False
        If event.type = SDL_QUIT_ Then running = False
    Wend
    
    SDL_SetRenderDrawColor(renderer, 135,206,235,255)
    SDL_RenderClear(renderer)
    
    DrawPlane(renderer)
    
    angle += 0.015
    
    SDL_RenderPresent(renderer)
Wend

SDL_DestroyRenderer(renderer)
SDL_DestroyWindow(ventana)
SDL_Quit()
