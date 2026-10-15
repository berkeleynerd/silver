Type Vector3D
    x As Short
    y As Short
    z As Short
End Type

Type Direction
    nom As String
    vec As Vector3D
End Type

Type Room
    passages(5) As Byte  ' north, east, south, west, up, down
    items(99) As String
    itemCnt As Byte
    
    Declare Function describe(location As Vector3D) As String
    Declare Function take(target As String, results() As String) As Byte
End Type

Type World
    currentPos As Vector3D
    rooms(Any) As Room
    roomCnt As Byte
    roomPos(Any) As Vector3D
    inventory(99) As String
    invCnt As Byte
    equipped As String
    
    Declare Sub init()
    Declare Function look() As String
    Declare Sub move(direction As String)
    Declare Sub showInventory()
    Declare Sub takeItem(target As String)
    Declare Sub dropItem(target As String)
    Declare Sub equipItem(itemName As String)
    Declare Sub unequipItem()
    Declare Sub nameRoom(newName As String)
    Declare Sub dig(direction As String)
    Declare Function getRoomIdx(Pos As Vector3D) As Byte
End Type

' Global variables and constants
Dim Shared directions(5) As Direction
directions(0).nom = "north": directions(0).vec.x =  0: directions(0).vec.y = -1: directions(0).vec.z =  0
directions(1).nom = "east" : directions(1).vec.x =  1: directions(1).vec.y =  0: directions(1).vec.z =  0
directions(2).nom = "south": directions(2).vec.x =  0: directions(2).vec.y =  1: directions(2).vec.z =  0
directions(3).nom = "west" : directions(3).vec.x = -1: directions(3).vec.y =  0: directions(3).vec.z =  0
directions(4).nom = "up"   : directions(4).vec.x =  0: directions(4).vec.y =  0: directions(4).vec.z =  1
directions(5).nom = "down" : directions(5).vec.x =  0: directions(5).vec.y =  0: directions(5).vec.z = -1

Dim Shared roomNames(99) As String
Dim Shared roomNamePos(99) As Vector3D
Dim Shared roomNameCnt As Byte = 0

Function getDirectionIdx(direction As String) As Byte
    Static As Byte i
    For i = 0 To 5
        If directions(i).nom = direction Then Return i
    Next
    Return -1
End Function

Function oppositeDirection(direction As String) As String
    Select Case direction
    Case "north": Return "south"
    Case "south": Return "north"
    Case "east" : Return "west"
    Case "west" : Return "east"
    Case "up"   : Return "down"
    Case "down" : Return "up"
    End Select
    Return ""
End Function

Function makeRandomItems() As String
    Randomize Timer
    Select Case Int(Rnd * 4)
    Case 0   : Return ""
    Case 1   : Return "sledge"
    Case 2   : Return "ladder"
    Case Else: Return "gold"
    End Select
End Function

Function Room.describe(location As Vector3D) As String
    Static As Byte i, exitCnt
    Static As String result
    result = "You are at "
    
    ' Check if room has a nom
    Static As Boolean hasName
    hasName = False
    For i = 0 To roomNameCnt - 1
        If roomNamePos(i).x = location.x Andalso _
        roomNamePos(i).y = location.y Andalso _
        roomNamePos(i).z = location.z Then
            result &= roomNames(i)
            hasName = True
            Exit For
        End If
    Next
    
    If Not hasName Then
        result &= location.x & "," & location.y & "," & location.z
    End If
    
    ' List items
    If itemCnt > 0 Then
        result &= !"\nOn the ground you can see: "
        For i = 0 To itemCnt - 1
            If i > 0 Then result &= ", "
            result &= items(i)
        Next
    End If
    
    ' List exits
    result &= !"\nExits are: "
    exitCnt = 0
    For i = 0 To 5
        If passages(i) Then
            If exitCnt > 0 Then result &= ", "
            result &= Ucase(Left(directions(i).nom, 1)) & Lcase(Mid(directions(i).nom, 2))
            exitCnt += 1
        End If
    Next
    If exitCnt = 0 Then result &= "None"
    
    Return result
End Function

Function Room.take(target As String, results() As String) As Byte
    Dim As Integer resultCnt = 0
    Static As Byte i, j
    
    If target = "all" Then
        For i = 0 To itemCnt - 1
            results(resultCnt) = items(i)
            resultCnt += 1
        Next
        itemCnt = 0
        Print "You now have everything in the room."
    Else
        For i = 0 To itemCnt - 1
            If items(i) = target Then
                results(0) = target
                For j = i To itemCnt - 2
                    items(j) = items(j + 1)
                Next
                itemCnt -= 1
                Print "Taken."
                Return 1
            End If
        Next
        Print "Item not found."
    End If
    
    Return resultCnt
End Function

Function addVectors(a As Vector3D, b As Vector3D) As Vector3D
    Return Type<Vector3D>(a.x + b.x, a.y + b.y, a.z + b.z)
End Function

Sub World.init()
    Static As Vector3D startPos = Type<Vector3D>(0, 0, 0)
    Static As Vector3D prizePos = Type<Vector3D>(1, 1, 5)
    
    currentPos = startPos
    roomCnt = 1
    Redim rooms(0)
    Redim roomPos(0)
    roomPos(0) = currentPos
    
    ' Initialize starting room
    rooms(0).itemCnt = 1
    rooms(0).items(0) = "sledge"
    
    ' Initialize room names
    roomNameCnt = 2
    roomNames(0) = "the starting room"
    roomNamePos(0) = startPos
    roomNames(1) = "the prize room"
    roomNamePos(1) = prizePos
End Sub

Function World.getRoomIdx(Pos As Vector3D) As Byte
    Static As Byte i
    For i = 0 To roomCnt - 1
        If roomPos(i).x = pos.x Andalso _
        roomPos(i).y = pos.y Andalso _
        roomPos(i).z = pos.z Then
            Return i
        End If
    Next
    Return -1
End Function

Function World.look() As String
    Return rooms(getRoomIdx(currentPos)).describe(currentPos)
End Function

Sub World.move(direction As String)
    Static As Byte i, dirIdx
    
    dirIdx = getDirectionIdx(direction)
    If dirIdx = -1 Then
        Print "That's not a direction."
        Return
    End If
    
    If direction = "up" Then
        Dim As Boolean hasLadder = False
        With rooms(getRoomIdx(currentPos))
            For i = 0 To .itemCnt - 1
                If .items(i) = "ladder" Then
                    hasLadder = True
                    Exit For
                End If
            Next
        End With
        If Not hasLadder Then
            Print "You'll need a ladder in this room to go up."
            Return
        End If
    End If
    
    If rooms(getRoomIdx(currentPos)).passages(dirIdx) Then
        currentPos = addVectors(currentPos, directions(dirIdx).vec)
    Else
        Print "Can't go that way."
    End If
End Sub

Sub World.showInventory()
    Static As Byte i
    
    If invCnt > 0 Then
        Print "Carrying: ";
        For i = 0 To invCnt - 1
            If i > 0 Then Print ", ";
            Print inventory(i);
        Next
        Print
    Else
        Print "You aren't carrying anything."
    End If
    
    If equipped <> "" Then Print "Holding: " & equipped
End Sub

Sub World.takeItem(target As String)
    Static As String results(99)
    Static As Byte i, cant
    
    cant = rooms(getRoomIdx(currentPos)).take(target, results())
    For i = 0 To cant - 1
        inventory(invCnt) = results(i)
        invCnt += 1
    Next
End Sub

Sub World.dropItem(target As String)
    Static As Byte i, j, roomIdx
    roomIdx = getRoomIdx(currentPos)
    
    If target = "all" Then
        For i = 0 To invCnt - 1
            rooms(roomIdx).items(rooms(roomIdx).itemCnt) = inventory(i)
            rooms(roomIdx).itemCnt += 1
        Next
        invCnt = 0
        Print "Everything dropped."
    Else
        For i = 0 To invCnt - 1
            If inventory(i) = target Then
                rooms(roomIdx).items(rooms(roomIdx).itemCnt) = target
                rooms(roomIdx).itemCnt += 1
                For j = i To invCnt - 2
                    inventory(j) = inventory(j + 1)
                Next
                invCnt -= 1
                Print "Dropped."
                Return
            End If
        Next
        Print "Could not find item in inventory."
    End If
End Sub

Sub World.equipItem(itemName As String)
    Static As Byte i, j
    
    For i = 0 To invCnt - 1
        If inventory(i) = itemName Then
            If equipped <> "" Then unequipItem()
            For j = i To invCnt - 2
                inventory(j) = inventory(j + 1)
            Next
            invCnt -= 1
            equipped = itemName
            Print "Equipped " & itemName & "."
            Return
        End If
    Next
    Print "You aren't carrying that."
End Sub

Sub World.unequipItem()
    If equipped = "" Then
        Print "You aren't equipped with anything."
    Else
        inventory(invCnt) = equipped
        invCnt += 1
        Print "Unequipped " & equipped & "."
        equipped = ""
    End If
End Sub

Sub World.dig(direction As String)
    If equipped <> "sledge" Then
        Print "You don't have a digging tool equipped."
        Return
    End If
    
    Static As Byte dirIdx, currentRoomIdx, newRoomIdx
    dirIdx = getDirectionIdx(direction)
    If dirIdx = -1 Then
        Print "That's not a direction."
        Return
    End If
    
    currentRoomIdx = getRoomIdx(currentPos)
    If Not rooms(currentRoomIdx).passages(dirIdx) Then
        rooms(currentRoomIdx).passages(dirIdx) = True
        
        Static As Vector3D newPos
        newPos = addVectors(currentPos, directions(dirIdx).vec)
        newRoomIdx = getRoomIdx(newPos)
        
        If newRoomIdx = -1 Then
            Redim Preserve rooms(roomCnt)
            Redim Preserve roomPos(roomCnt)
            roomPos(roomCnt) = newPos
            
            Static As String randomItem
            randomItem = makeRandomItems()
            If randomItem <> "" Then
                rooms(roomCnt).items(0) = randomItem
                rooms(roomCnt).itemCnt = 1
            End If
            
            newRoomIdx = roomCnt
            roomCnt += 1
        End If
        
        rooms(newRoomIdx).passages(getDirectionIdx(oppositeDirection(direction))) = True
        Print "You've dug a tunnel."
    Else
        Print "Already a tunnel that way."
    End If
End Sub

' Main game loop
Dim Shared As World gameWorld
gameWorld.init()

Print "Welcome to the dungeon!"
Print "Grab the sledge and make your way to room 1,1,5 for a non-existent prize!"

Do
    Print
    Print gameWorld.look()
    Print "> ";
    
    Static As String cmd
    Line Input cmd
    cmd = Lcase(cmd)
    
    Select Case cmd
    Case "quit"
        Exit Do
    Case "look"
        ' Already shown above
    Case "inventory", "inv", "i"
        gameWorld.showInventory()
    Case "north", "n"
        gameWorld.move("north")
    Case "south", "s"
        gameWorld.move("south")
    Case "east", "e"
        gameWorld.move("east")
    Case "west", "w"
        gameWorld.move("west")
    Case "up", "u"
        gameWorld.move("up")
    Case "down", "d"
        gameWorld.move("down")
    Case Else
        If Left(cmd, 5) = "take " Then
            gameWorld.takeItem(Mid(cmd, 6))
        Elseif Left(cmd, 5) = "drop " Then
            gameWorld.dropItem(Mid(cmd, 6))
        Elseif Left(cmd, 6) = "equip " Then
            gameWorld.equipItem(Mid(cmd, 7))
        Elseif cmd = "unequip" Then
            gameWorld.unequipItem()
        Elseif Left(cmd, 4) = "dig " Then
            gameWorld.dig(Mid(cmd, 5))
        Else
            Print "Unknown command."
        End If
    End Select
Loop

Print "Thanks for playing!"

Sleep
