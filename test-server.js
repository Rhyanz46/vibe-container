const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>Test Host Network Mode</title>
      <style>
        body { font-family: Arial; max-width: 800px; margin: 50px auto; padding: 20px; }
        .success { background: #d4edda; color: #155724; padding: 20px; border-radius: 5px; }
        h1 { color: #28a745; }
      </style>
    </head>
    <body>
      <div class="success">
        <h1>✅ HOST NETWORK MODE BERHASIL!</h1>
        <p>Server ini berjalan di dalam container claude-code-container</p>
        <p>Tapi port 5678 langsung accessible di host tanpa port mapping!</p>
        <p>Timestamp: ${new Date().toISOString()}</p>
        <p>Hostname: ${require('os').hostname()}</p>
      </div>
    </body>
    </html>
  `);
});

server.listen(9999, () => {
  console.log('✅ Server running on port 9999');
});
