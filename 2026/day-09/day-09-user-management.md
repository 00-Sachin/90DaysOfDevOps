Day 09 Challenge
Users & Groups Created
Users: tokyo, berlin, professor, nairobi

Groups: developers, admins, project-team

Group Assignments
tokyo: developers, project-team

berlin: developers, admins

professor: admins

nairobi: project-team

Directories Created
/opt/dev-project: Permissions set to 775 (rwxrwxr-x), group ownership set to developers.

/opt/team-workspace: Permissions set to 775 (rwxrwxr-x), group ownership set to project-team.

Commands Used

1. Creating Users & Verifying

sudo adduser tokyo
sudo adduser berlin
sudo adduser professor
sudo adduser nairobi
cat /etc/passwd | tail -n 4
ls -l /home

2. Creating Groups & Verifying

sudo groupadd developers
sudo groupadd admins
sudo groupadd project-team
cat /etc/group | tail -n 5

3. Assigning Users to Groups

sudo usermod -aG developers tokyo
sudo usermod -aG developers,admins berlin
sudo usermod -aG admins professor
sudo usermod -aG project-team tokyo
sudo usermod -aG project-team nairobi

4. Creating and Configuring Shared Directories

sudo mkdir /opt/dev-project
sudo chown root:developers /opt/dev-project
sudo chmod 775 /opt/dev-project

sudo mkdir /opt/team-workspace
sudo chown -R root:project-team /opt/team-workspace
sudo chmod 775 /opt/team-workspace

5. Testing Permissions

su - tokyo
cd /opt/dev-project
touch test-file.txt

What I Learned
User vs. File Modification: I learned that chmod is strictly for changing file and directory permissions, 
while modifying a user's group requires usermod -aG. Forgetting the -a (append) can accidentally remove a user from their other groups!

Changing Group Ownership: To allow a specific group to collaborate in a folder, the chown command uses a user:group syntax. 
For example, sudo chown root:project-team ensures the system admin owns it, but the project-team group has designated access.

Piping and Searching: When checking system files like /etc/group, piping the output to grep or tail -5 is much faster than reading the entire file.
I also learned that chaining search terms with operators like && or || in grep requires specific syntax/regex.
