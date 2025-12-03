<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SportLife API</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0;
        }
        .container {
            background: white;
            padding: 40px 60px;
            border-radius: 20px;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,.25);
            text-align: center;
        }
        h1 {
            color: #1a202c;
            font-size: 2.5rem;
            margin-bottom: 10px;
        }
        p {
            color: #718096;
            font-size: 1.1rem;
        }
        .badge {
            display: inline-block;
            background: #48bb78;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9rem;
            margin-top: 15px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚽ SportLife API</h1>
        <p>Sports Prediction Platform Backend</p>
        <span class="badge">Laravel {{ app()->version() }}</span>
    </div>
</body>
</html>
