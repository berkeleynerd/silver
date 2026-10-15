Const PI As Double = 4 * Atn(1)
Const TWO_PI As Double = 2.0 * PI

Type Punto
    x As Double
    y As Double
    cluster As Integer
End Type

Type Centroid
    x As Double
    y As Double
End Type

Function DistanceSquared(Byref a As Punto, Byref b As Punto) As Double
    Dim dx As Double = a.x - b.x
    Dim dy As Double = a.y - b.y
    
    Return dx * dx + dy * dy
End Function

Function DistanceSquaredPointCentroid(Byref p As Punto, Byref c As Centroid) As Double
    Dim dx As Double = p.x - c.x
    Dim dy As Double = p.y - c.y
    
    Return dx * dx + dy * dy
End Function

Function NearestCentroid(Byref p As Punto, centroids() As Centroid, Byval numberOfClusters As Integer) As Integer    
    Dim bestCluster As Integer = 0
    Dim bestDistance As Double = 1.0e+308
    
    For clusterIdx As Integer = 0 To numberOfClusters - 1
        Dim d As Double = DistanceSquaredPointCentroid(p, centroids(clusterIdx))
        
        If d < bestDistance Then
            bestDistance = d
            bestCluster = clusterIdx
        End If
    Next
    
    Return bestCluster
End Function

Sub KMeansPlusPlus(points() As Punto, Byval numberOfPoints As Integer, centroids() As Centroid, Byval numberOfClusters As Integer)
    Dim shortestDistance() As Double
    Redim shortestDistance(0 To numberOfPoints - 1)
    
    Dim firstIdx As Integer = Int(Rnd * numberOfPoints)
    
    centroids(0).x = points(firstIdx).x
    centroids(0).y = points(firstIdx).y
    
    For i As Integer = 0 To numberOfPoints - 1
        shortestDistance(i) = 1.0e+308
    Next
    
    For clusterIdx As Integer = 1 To numberOfClusters - 1
        Dim totalDistance As Double = 0.0
        For pointIdx As Integer = 0 To numberOfPoints - 1
            Dim d As Double = DistanceSquaredPointCentroid(points(pointIdx), centroids(clusterIdx - 1))
            
            If d < shortestDistance(pointIdx) Then shortestDistance(pointIdx) = d
            
            totalDistance += shortestDistance(pointIdx)
        Next
        
        Dim selectedIdx As Integer = 0
        If totalDistance <= 0.0 Then
            selectedIdx = Int(Rnd * numberOfPoints)
        Else
            Dim randomDistance As Double = Rnd * totalDistance
            Dim cumulativeDistance As Double = 0.0
            
            For pointIdx As Integer = 0 To numberOfPoints - 1
                cumulativeDistance += shortestDistance(pointIdx)
                If cumulativeDistance >= randomDistance Then
                    selectedIdx = pointIdx
                    Exit For
                End If
            Next
        End If
        
        centroids(clusterIdx).x = points(selectedIdx).x
        centroids(clusterIdx).y = points(selectedIdx).y
    Next
End Sub

Function KMeans(points() As Punto, Byval numberOfPoints As Integer, Byval numberOfClusters As Integer, Byval maximumIterations As Integer, centroids() As Centroid, Byref iterationsUsed As Integer) As Integer
    If numberOfPoints <= 0 Then Return 1
    If numberOfClusters <= 0 Then Return 1
    If numberOfClusters > numberOfPoints Then Return 1
    
    If maximumIterations < 1 Then maximumIterations = 1
    
    Redim centroids(0 To numberOfClusters - 1)
    
    KMeansPlusPlus(points(), numberOfPoints, centroids(), numberOfClusters)
    
    Dim clusterSizes() As Integer
    Redim clusterSizes(0 To numberOfClusters - 1)
    
    iterationsUsed = 0
   
    For iteration As Integer = 1 To maximumIterations
        Dim changed As Integer = 0
        For pointIdx As Integer = 0 To numberOfPoints - 1
            Dim newCluster As Integer = NearestCentroid(points(pointIdx), centroids(), numberOfClusters)           
            If newCluster <> points(pointIdx).cluster Then
                points(pointIdx).cluster = newCluster
                changed += 1
            End If
        Next
        
        For clusterIdx As Integer = 0 To numberOfClusters - 1
            clusterSizes(clusterIdx) = 0
            centroids(clusterIdx).x = 0.0
            centroids(clusterIdx).y = 0.0
        Next
        
        For pointIdx As Integer = 0 To numberOfPoints - 1
            Dim clusterIdx As Integer = points(pointIdx).cluster
            
            clusterSizes(clusterIdx) += 1
            centroids(clusterIdx).x += points(pointIdx).x
            centroids(clusterIdx).y += points(pointIdx).y
        Next
        
        For clusterIdx As Integer = 0 To numberOfClusters - 1
            If clusterSizes(clusterIdx) > 0 Then
                centroids(clusterIdx).x /= clusterSizes(clusterIdx)
                centroids(clusterIdx).y /= clusterSizes(clusterIdx)
            Else
                Dim randomPoint As Integer = Int(Rnd * numberOfPoints)
                
                centroids(clusterIdx).x = points(randomPoint).x
                centroids(clusterIdx).y = points(randomPoint).y
            End If
        Next
        
        iterationsUsed = iteration
        
        If changed = 0 Then Return 0
    Next
    
    Return 2
End Function

Sub GenerateUniformCircle(points() As Punto, Byval numberOfPoints As Integer, Byval radius As Double)  
    Redim points(0 To numberOfPoints - 1)
    
    For i As Integer = 0 To numberOfPoints - 1
        Dim angle As Double = TWO_PI * Rnd
        Dim distance As Double = radius * Sqr(Rnd)
        points(i).x = distance * Cos(angle)
        points(i).y = distance * Sin(angle)
        points(i).cluster = -1
    Next
End Sub

Function GaussianValue() As Double
    Dim total As Double = 0.0
    
    For i As Integer = 1 To 12
        total += Rnd
    Next
    
    Return total - 6.0
End Function

Sub GenerateGaussianCluster(points() As Punto, Byval firstIdx As Integer, Byval numberOfPoints As Integer, Byval centerX As Double, Byval centerY As Double, Byval standardDeviation As Double)
    For i As Integer = 0 To numberOfPoints - 1
        Dim index As Integer = firstIdx + i
        
        points(index).x = centerX + GaussianValue() * standardDeviation
        points(index).y = centerY + GaussianValue() * standardDeviation
        points(index).cluster = -1
    Next
End Sub

Function ClusterColor(Byval clusterIdx As Integer, Byval numberOfClusters As Integer) As String
    Dim hue As Double
    
    If numberOfClusters <= 0 Then
        hue = 0.0
    Else
        hue = 360.0 * clusterIdx / numberOfClusters
    End If
    
    Return "hsl(" & Trim(Str(hue)) & ", 70%, 50%)"
End Function

Sub SaveSVG(points() As Punto, Byval numberOfPoints As Integer, centroids() As Centroid, Byval numberOfClusters As Integer, Byval fileName As String, Byval ancho As Integer, Byval alto As Integer)
    Dim minX As Double = 1.0e+308
    Dim maxX As Double = -1.0e+308
    Dim minY As Double = 1.0e+308
    Dim maxY As Double = -1.0e+308
    
    For i As Integer = 0 To numberOfPoints - 1
        If points(i).x < minX Then minX = points(i).x
        If points(i).x > maxX Then maxX = points(i).x
        If points(i).y < minY Then minY = points(i).y
        If points(i).y > maxY Then maxY = points(i).y
    Next
    
    For i As Integer = 0 To numberOfClusters - 1
        If centroids(i).x < minX Then minX = centroids(i).x
        If centroids(i).x > maxX Then maxX = centroids(i).x
        If centroids(i).y < minY Then minY = centroids(i).y
        If centroids(i).y > maxY Then maxY = centroids(i).y
    Next
    
    Dim spanX As Double = maxX - minX
    Dim spanY As Double = maxY - minY
    
    If spanX <= 0.0 Then spanX = 1.0
    If spanY <= 0.0 Then spanY = 1.0
    
    Dim margin As Double = 20.0
    Dim scaleX As Double = (ancho - 2.0 * margin) / spanX
    Dim scaleY As Double = (alto - 2.0 * margin) / spanY
    Dim scale As Double = scaleX
    
    If scaleY < scale Then scale = scaleY
    
    Dim centerX As Double = (minX + maxX) / 2.0
    Dim centerY As Double = (minY + maxY) / 2.0
    
    Open fileName For Output As #1
    
    Print #1, "<?xml version=""1.0"" encoding=""UTF-8""?>"
    Print #1, "<svg xmlns=""http://www.w3.org/2000/svg"" "
    Print #1, "ancho=""" & ancho & """ alto=""" & alto & """ "
    Print #1, "viewBox=""0 0 " & ancho & " " & alto & """>"
    
    Print #1, "<rect ancho=""100%"" alto=""100%"" fill=""white""/>"
    
    For i As Integer = 0 To numberOfPoints - 1
        Dim px As Double = (points(i).x - centerX) * scale + ancho / 2.0
        Dim py As Double = alto / 2.0 - (points(i).y - centerY) * scale
        
        Print #1, "<circle cx=""" & px & """ cy=""" & py & """ r=""1.5"" fill=""" & ClusterColor(points(i).cluster, numberOfClusters) & """/>"
    Next
    
    For i As Integer = 0 To numberOfClusters - 1
        Dim cx As Double = (centroids(i).x - centerX) * scale + ancho / 2.0
        Dim cy As Double = alto / 2.0 - (centroids(i).y - centerY) * scale
        
        Print #1, "<circle cx=""" & cx & """ cy=""" & cy & """ r=""7"" fill=""white"" stroke=""black"" "
        Print #1, "stroke-ancho=""2""/>"
        
        Print #1, "<text x=""" & cx + 9.0 & """ y=""" & cy - 9.0 & """ font-family=""Arial"" font-size=""12"">" & i & "</text>"
    Next
    
    Print #1, "</svg>"
    
    Close #1
End Sub

Sub PrintResults(points() As Punto, Byval numberOfPoints As Integer, centroids() As Centroid, Byval numberOfClusters As Integer)
    Dim clusterSizes() As Integer
    Redim clusterSizes(0 To numberOfClusters - 1)
    
    For i As Integer = 0 To numberOfPoints - 1
        clusterSizes(points(i).cluster) += 1
    Next
    
    Print !"\nCentroids and cluster sizes:"
    For clusterIdx As Integer = 0 To numberOfClusters - 1
        Print Using " Cluster ##: X=####.##########  Y=####.##########  Points=#####"; _
        clusterIdx; centroids(clusterIdx).x; centroids(clusterIdx).y; clusterSizes(clusterIdx)
    Next
End Sub

' Main program
Const NUM_OF_POINTS As Integer = 30000
Const NUM_OF_CLUSTERS As Integer = 6
Const MAXIMUM_ITERATIONS As Integer = 100

Dim points() As Punto
Dim centroids() As Centroid
Dim iterationsUsed As Integer

Randomize Timer
GenerateUniformCircle(points(), NUM_OF_POINTS, 10.0)

Dim result As Integer = KMeans(points(), NUM_OF_POINTS, NUM_OF_CLUSTERS, MAXIMUM_ITERATIONS, centroids(), iterationsUsed)

If result = 1 Then
    Print "Error: Invalid parameters."
    Sleep: End
End If
If result = 2 Then Print "Warning: Maximum number of iterations reached."

PrintResults(points(), NUM_OF_POINTS, centroids(), NUM_OF_CLUSTERS)

SaveSVG(points(), NUM_OF_POINTS, centroids(), NUM_OF_CLUSTERS, "kmeans_output.svg", 800, 800)

Print !"\nVisualization saved in kmeans_output.svg"

Sleep
