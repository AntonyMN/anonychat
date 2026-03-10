# Server Deployment Guide - Supervisor Setup

To ensure the WebSocket (Reverb) and Queue workers are persistent and restart automatically, you need to install and configure `supervisor` on the production server.

## 1. Install Supervisor

SSH into your server (`68.183.191.161`) and run:

```bash
sudo apt update
sudo apt install supervisor -y
```

## 2. Copy Configuration Files

Copy the configuration files from the project to the Supervisor directory:

```bash
# From the project root (/var/www/anonychat/web)
sudo cp supervisor/reverb.conf /etc/supervisor/conf.d/
sudo cp supervisor/queue.conf /etc/supervisor/conf.d/
```

## 3. Initialize Supervisor

Update Supervisor to recognize the new configurations and start the processes:

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start reverb
sudo supervisorctl start "anonychat-worker:*"
```

## 4. Verification

Check the status of the processes:

```bash
sudo supervisorctl status
```

You should see both `reverb` and the `anonychat-worker` processes as `RUNNING`.

## 5. Deployment Integration

The GitHub Actions workflow (`deploy.yml`) is already configured to restart these processes on every deployment. Ensure the `SERVER_USER` has permissions to run `sudo supervisorctl` without a password, or adjust the deployment script accordingly.

To allow `www-data` or your deploy user to restart supervisor without password, you can add this to `/etc/sudoers`:

```text
# Replace 'anto' with your SERVER_USER if different
anto ALL=(ALL) NOPASSWD: /usr/bin/supervisorctl
```
