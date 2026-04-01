# 🚀 Linux Pro System Health Monitor

A production-ready, automated infrastructure for real-time Linux server monitoring. This project demonstrates advanced DevOps practices including Infrastructure as Code (IaC), Automated Configuration Management, and secure CI/CD pipelines.

## 🏗️ Architecture Overview

The system follows a 3-tier monitoring architecture:  
1.  **Monitoring Agent (Bash):** A lightweight script running on target servers via `cron`, collecting CPU, Memory, Disk, and I/O metrics.
2.  **Backend API (FastAPI):** A secure REST API that receives metrics and stores them in a database.
3.  **Database (MySQL 8.0):** Relational storage for time-series system metrics.

## 🛠️ Tech Stack & Tools

*   **Infrastructure:** AWS (EC2, VPC, Security Groups) managed by **Terraform**.
*   **Provisioning:** **Ansible** (Automated Docker installation, security hardening, and app deployment).
*   **Containerization:** **Docker & Docker Compose** (Multi-stage builds, non-root users, resource optimization).
*   **Backend:** **Python (FastAPI)** with SQLAlchemy ORM.
*   **CI/CD:** **GitHub Actions** (Automated linting and remote deployment).
*   **OS:** Ubuntu 22.04 LTS.

## 🔐 Key Security Features (DevSecOps Mindset)

*   **Zero Trust Networking:** MySQL is isolated within the internal Docker network; only the API port is exposed to the world.
*   **Least Privilege:** Application runs under a non-privileged `appuser` inside the container.
*   **Secret Management:** Sensitive data (.env, SSH keys) is never committed to Git, handled securely via GitHub Secrets.
*   **Multi-Stage Builds:** Optimized Docker images with zero build-time dependencies in the final runner stage.

## 🚀 How to Deploy

### 1. Prerequisites
*   AWS Account & IAM User with Admin Access.
*   Terraform & AWS CLI installed locally.
*   GitHub Repository to host the code.

### 2. Infrastructure (Terraform)
```bash
cd terraform
# Initialize and create AWS resources
terraform init
terraform apply -auto-approve
```
### 3. Configuration & App (CI/CD)
Deployment is fully automated via GitHub Actions on every git push.  
Ensure the following GitHub Secrets are set in your repository:  
SERVER_IP: Your AWS Instance Public IP.  
SSH_PRIVATE_KEY: Your generated RSA private key (monitor_key).  
ENV_FILE: Full content of your .env file.
### 4. Agent & Cleanup Setup
Deploy agent/monitor.sh to the target server and add the following to crontab -e:
```bash
# Collect metrics every minute
* * * * * /home/ubuntu/monitor.sh > /tmp/monitor.log 2>&1

# Secure daily cleanup: Delete data older than 3 days (runs at midnight)
0 0 * * * sudo docker exec metrics_db sh -c 'mysql -u root -p"$MYSQL_ROOT_PASSWORD" system_monitor -e "DELETE FROM metrics WHERE recorded_at < NOW() - INTERVAL 3 DAY;"'
```
## 📊 Verification
To see your collected data, log into the server and run:
```bash
sudo docker exec -it metrics_db mysql -u root -p system_monitor -e "SELECT * FROM metrics;"
```
## 📊 Monitoring Metrics Collected  
*    CPU Usage (%)  
*    Load Average (1m)  
*    Free Memory (MB)  
*    Free Disk Space (GB)  
*    I/O Wait (%)  
  
Developed as a DevOps Portfolio Project by [relationm/GitHub Profile]