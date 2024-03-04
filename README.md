# Deploying Panel App in AWS
As both Streamlit and Bokeh use Tornado (see [this discussion](https://discourse.holoviz.org/t/does-anyone-have-advice-know-of-resources-or-documentation-for-deploying-panel-with-amazon-web-services-aws/1074)), I adapted @upendrak's [Guide to Streamlit in AWS](https://github.com/upendrak/streamlit-aws-tutorial) on an EC2 instance, and was able to get something functioning. 

### Configuring instance
- Set up an EC2 instance with your selected AMI. I selected Ubuntu t2.micro for their free tier.
- Under "Configure Security Group", add a rule with Type: "Custom TCP Rule", Port Range: 5006, Source: MyIP. This is the port that panel will serve the app on. Two notes:
    - *I am unsure if there is a better port to use than 5006.*
    - *To my understanding, the SSH Source decides which IP addresses can ssh into your instance, and the Port Source decides which IP addresses can send requests to the specified port. On final deployment, I would imagine setting SSH Source to MyIP and Port Source to Anywhere would be the set-up for a publicly available site, though there are other security considerations here.*
- Launch image and start instance.
- Connect to your instance: Create a keypair if you don't have one, and download it to your local machine. You may have to change permissions with chmod. `cd` into the directory with the keypair and copy the ssh command under the "Connect" button. This command consists of your keypair file and your instance's Public DNS. This is the domain name associated with the Public IPv4 address assigned to your instance. Note that this Public IP & DNS changes every time you stop/start your instance. 
    - Public IP address format: `x.x.x.x`, where x represents 128 bit numbers.
    - Public DNS format: `ec2-x-x-x-x.us-east-2.compute.amazonaws.com`.

```bash
$ chmod 400 <filename>.pem
$ ssh -i "<filename>.pem" ubuntu@<Public DNS>

# As an example: 
$ chmod 400 CustomName.pem
$ ssh -i "CustomName.pem" ubuntu@ec2-3-143-221-24.us-east-2.compute.amazonaws.com
```

### Dependencies & requirements
Once connected, run the following to manage Python package dependencies and requirements. Depending on your app, you may have to install other applications and dependencies.
```bash
$ sudo apt-get update
$ sudo apt-get install python3-pip
```


### Transfer code to instance
In the terminal you just ssh'd into, find a way to transfer the code to your instance. This can either be via cloning a git repo or scp'ing files/directories from your local drive.

```bash
$ git clone <repo-link>


# Alternatively, scp files/directories from your local machine:
$ scp -i <keypair-name>.pem <file> <Public DNS>:</path-to-destination/>
$ scp -i <keypair-name>.pem -r <directory> <Public DNS>:</path-to-destination/>
```

### Serve app
The code in app.py returns a `xyz.servable()` panel object. This command serves your panel application on the specified port. You can then view your app in your browser by typing in \<Public IPv4\>:5006.

```bash
$ python3 -m panel serve app.py --address 0.0.0.0 --port 5006 --allow-websocket-origin=<Public IPv4>:5006
```
I currently have this command in `start-app.sh`, which I then run `$ sh start-app.sh` which grabs the AWS Public IP address and port, as stopping/starting your instance changes the Public IP address. 

### Miscellaneous Notes
- Using `nohup` for final deploy: This keeps your session running even when you disconnect from your session. I currently run `start-app.sh` to test, but for the final deploy I run `start-app-nohup.sh`, which has the command `nohup sh start-app-nohup.sh & `.
- You can register for a SSL certificate & set up a reverse proxy using [NGINX](https://docs.bokeh.org/en/latest/docs/user_guide/server/deploy.html#ug-server-deploy) or Apache, though I have not gotten this far yet. This would require installing nginx, editing config files, restarting server, then running your app.
    - `$ sudo apt install nginx`
    - ... edit conf files ...
    - `$ sudo systemctl restart nginx`
    - `$ python3 -m panel serve app.py --address 0.0.0.0 --port 5006 --allow-websocket-origin=<Public IPv4>:5006`
    - There may be further specifications to AWS security groups to set up the reverse proxy.

Hope this was helpful, please let me know if there are ways to improve upon this method!

### Other Links
Here are also some links that I found helpful in this process. 
  - [Bokeh server deployment guide](https://docs.bokeh.org/en/latest/docs/user_guide/server/deploy.html#ug-server-deploy)
  - [AWS Nginx installs](https://gist.github.com/dKvale/d64b28d2c0ba9ad42e702f0b2c6ea56f)
  - [Another Streamlit AWS example](https://towardsdatascience.com/how-to-deploy-a-streamlit-app-using-an-amazon-free-ec2-instance-416a41f69dc3)
  - [AWS Security Group Rules examples](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/security-group-rules-reference.html)
  - [AWS Monitoring Costs & Setting up Budgets](https://aws.amazon.com/getting-started/hands-on/control-your-costs-free-tier-budgets/)
