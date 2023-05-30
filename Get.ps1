power = [Power]::new()

$power.GET("/", {
    $context = $args[0]
    
    $response = $context.Response
    $response.ContentType = "text/html"
    $response.ContentEncoding = [System.Text.Encoding]::UTF8
    
    $html = @"
<html>
<head>
<title>Sample Page</title>
</head>
<body>
<h1>Hello, World!</h1>
<form action="/" method="post">
  <label for="username">Username:</label>
  <input type="text" id="username" name="username" value="JohnDoe"><br><br>
  <input type="submit" value="Submit">
</form>
</body>
</html>
"@

    $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
    $power.SetCookie("deneme", "31", "http://localhost:8080",$response)
    Write-Host $power.GetCookie("deneme", $context.Request)
})

$power.Run("8080")
