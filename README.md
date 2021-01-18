# computercraft-scripts
 
This is a collection of scripts I am writing to allow for more robust computercraft utilization. Only the scripts listed below are good for use.

### Scripts
`ftp`: A file transfer protocol script that either hosts a file server or interacts with a file server.

`wget`: Sends a get request to the provided url and saves the response's contents to the filename provided.


##### ftp
A file transfer protocol script that either hosts a file server or interacts with a file server.

`ftp <host/fetch/send> <file> <modem side>`


Host usage:

`ftp host . top`


Fetching a file from the ftp server with a computer that has a modem on the top face:

`ftp fetch my_file top`


Sending a file to the ftp server with a computer that has a modem on the left face:

`ftp send my_file left`


##### wget
Sends a get request to the provided url and saves the response's contents to the filename provided.

`wget <url> <file>`

Example: 

`wget https://raw.githubusercontent.com/MaxTheMooshroom/computercraft-scripts/master/ftp.lua ftp`
