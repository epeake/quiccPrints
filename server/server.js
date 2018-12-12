var express     = require('express')
var server      = express()
var multer      = require('multer')
var bodyParser  =  require("body-parser")

server.use(bodyParser.json())
server.use(bodyParser.urlencoded({ extended: false }))

server.post('/images', function(req, res) {
    var storage = multer.diskStorage({
        destination: function (req, file, cb) {
            cb(null, './images')
        },
        filename: function (req, file, cb) {
            cb(null, file.fieldname + "_" + Date.now() + '.jpg')
      }
    })
    var upload = multer({ dest: './images', storage: storage}).single('file')
    upload(req, res, function(err) {
        if (err) {
            console.log("Error uploading file: " + err)
            return
        }
    })
    
    var spawn = require("child_process").spawn 
    console.log('spawning new process')
    var process = spawn('python',["./algorithm.py"])

    process.stdout.on('data', function(data) { 
        res.json(data.toString()) 
    })
})

server.listen(process.env.PORT, process.env.IP , function(){
  console.log("Server listening")
})
