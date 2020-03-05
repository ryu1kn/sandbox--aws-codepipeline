exports.handler = () => Promise.resolve({
  statusCode: '200',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({message: 'Hello World!'})
})
