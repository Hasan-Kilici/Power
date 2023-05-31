$power = [Power]::new()

$power.PublicFile("/deneme.js","C:\fastPrinter\deneme.js")
$power.PublicFile("/deneme.css","C:\fastPrinter\deneme.css")

$power.GET("/", {
    $context = $args[0]
    
    $response = $context.Response
    $response.ContentType = "text/html"
    $response.ContentEncoding = [System.Text.Encoding]::UTF8
    
    $html = $power.HTML("C:\fastPrinter\deneme.html")

    $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
})

$power.Run("8080")
