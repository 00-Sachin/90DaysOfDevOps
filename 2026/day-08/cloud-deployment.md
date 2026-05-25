Commands used : 
(Before starting whith commands you must have to do these things create a ec2 instance and find the link of ssh 
that is located insde the connect section of the aws page)

My-key-pair : is created when you are launching the instance

comaand 1 : Used to check where the private key was installed or located and change the 
directiry as per that using cd command 

command 2 : ssh -i <My-key-pair> ubuntu@<your public dns> 

command 3 : sudo apt-get update && sudo apt upgrade

command 4 : sudo apt install nginx

command 5 : systemctl status nginx 

command 6 : journalctl -u nginx >> nginx-logs.txt

comaand 7 : scp -i <key pair.pem> ubuntu@<public dns> : ~/nginx-logs.txt . 



Challange that i faced is during scp when i forget to use "." in the end then i realized that it
tell the system to paste it where the user is currently located 



WHat I Learn 

scp command : that is how to store file form server to local

. : tells the system to use the current location as a destination location .
