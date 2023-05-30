class Power {
    [String] $Port
    [String] $HTMLBlob
    [System.Net.HttpListener] $HttpListener
    [System.Collections.ArrayList] $Routes
    
    Power() {
        $this.Routes = [System.Collections.ArrayList]::new()
        $this.HttpListener = [System.Net.HttpListener]::new()    
    }
    
    [Void] Run([String]$port) {
        $this.Port = $port
        $this.HttpListener.Prefixes.Add("http://localhost:$port/")
        $this.HttpListener.Start()
        
        write-host "HTTP Server Ready!" -f 'black' -b 'green'
        write-host "Now try going to $($this.HttpListener.Prefixes)" -f 'yellow'
        write-host "Then try going to $($this.HttpListener.Prefixes)other/path" -f 'yellow'
        
        while ($this.HttpListener.IsListening) {
            $context = $this.HttpListener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            $matchedRoute = $this.Routes | Where-Object { $_.Method -eq $request.HttpMethod -and $_.Route -eq $request.RawUrl }
            
            if ($matchedRoute) {
                $action = $matchedRoute.Action
                $action.Invoke($context)
            }
            
            $response.Close()
        }
    }

    [Void] GET([String]$route, [ScriptBlock]$action) {
        $this.Routes.Add(@{
            "Method" = "GET"
            "Route" = $route
            "Action" = $action
        })
    }

    [Void] POST([String]$route, [ScriptBlock]$action) {
        $this.Routes.Add(@{
            "Method" = "POST"
            "Route" = $route
            "Action" = $action
        })
    }

    [Hashtable] PostForm($context){
        $FormContent = [System.IO.StreamReader]::new($context.Request.InputStream).ReadToEnd()

        $formData = @{}

        $formFields = $FormContent -split '&'
        foreach ($field in $formFields) {
            $keyValue = $field -split '='
            $key = [System.Uri]::UnescapeDataString($keyValue[0])
            $value = [System.Uri]::UnescapeDataString($keyValue[1])
            $formData[$key] = $value
        }

        return $formData
    }

    [String] HTML([String]$filePath) {
        $htmlContent = Get-Content -Path $filePath -Raw
        return $htmlContent
    }

    [String] GetCookie([String]$cookieName, [System.Net.HttpListenerRequest]$request) {
        $cookieValue = $null
        $cookies = $request.Cookies
        
        foreach ($cookie in $cookies) {
            if ($cookie.Name -eq $cookieName) {
                $cookieValue = $cookie.Value
                break
            }
        }
        
        return $cookieValue
    }

    [Void] SetCookie([String]$cookieName, [String]$cookieValue, [String]$cookiePath, [DateTime]$cookieExpiration, [System.Net.HttpListenerResponse]$response) {
        $cookieExpirationFormatted = $cookieExpiration.ToUniversalTime().ToString("R")
        $response.Headers.Add("Set-Cookie", "$cookieName=$cookieValue; Expires=$cookieExpirationFormatted; Path=$cookiePath")
    }
}
