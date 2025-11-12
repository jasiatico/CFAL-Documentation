# Accessing Vega

Traditionally, users accessed **Vega** via SSH using tools such as **MobaXterm** or **PuTTY**. However, **Visual Studio Code (VS Code)** offers a more integrated environment with powerful extensions and built-in capabilities.

---

### Step 1: Install the Remote SSH Extension

Install the **`Remote - SSH`** extension from the VS Code Marketplace.  
This extension allows you to open a remote terminal, edit files, and manage your HPC environment directly within VS Code.

![Remote SSH Extension Installation](../images/RemoteSSH_Extension.png)

---

### Step 2: Open the Remote Explorer

After installation, you’ll see a new icon on the left sidebar — a **computer symbol with `><`**.  
Click this icon to open the **Remote Explorer**.  
From here, you can add a new SSH host by entering your connection details.  
Your panel will initially be blank; the screenshot below shows an example configuration.

![Remote Explorer Panel](../images/SSH_Extension.png)

---

### Step 3: Add and Connect to Vega

1. Hover over the **"SSH"** tab — you’ll see a gear icon and a plus icon.  
   Click the **plus** icon to add a new connection.  
2. At the top of the VS Code window, enter your SSH connection string for Vega:  
`ssh username@vegaln1.erau.edu`

    Replace `username` with your actual Vega username.

3. When prompted, choose the SSH configuration file to update.  
The default is usually:
`C:\Users\yourname\.ssh\config`
4. After saving, return to the **Remote Explorer**.  
Hover over your new connection under **Remotes (Tunnels/SSH)** — an arrow icon will appear.  
Click it to connect.  
5. On first startup, VS Code may ask which platform you’re connecting to — select **Linux**.  
6. Enter your Vega password when prompted, then press **Enter**.

---

### Step 4. Adding SSH Keys (Optional)

To avoid entering your password each time, you can configure SSH keys.

Most Windows systems include OpenSSH by default. Generate SSH keys as follows:

1. Open PowerShell or Command Prompt on your local machine.  
2. Run the command:  
   ```bash
   ssh-keygen -t ed25519 -C "youremail@example.com"
   ```
   Replace with your actual email address.
3. Enter the file path to save the key (or press Enter to accept the default).
4. When prompted, enter a secure passphrase (optional but recommended).
5. Keys are generated (by default) in `C:\Users\yourname\.ssh\`.
    - The **private key** (no extension) should stay secure and never leave your machine.
    - The **public key** (`.pub` extension) is safe to share and will be copied to Vega.
    - While you *can* reuse keys on multiple machines, it's not recommended.
6. Copy the public key (`id_ed25519.pub`) to Vega's `~/.ssh` folder.
7. On Vega, append the contents of the public key to the `authorized_keys` file using:
    ```bash
    cat id_ed25519.pub >> ~/.ssh/authorized_keys
    ```
8. Set correct permissions for SSH:
    ```bash
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    ```
9. On your local machine, go to VS Code, hover over the **SSH** tab and select the gear icon. Select the SSH config file to edit. It should look like:
    ```bash
    Host vegaln1.erau.edu
        HostName vegaln1.erau.edu
        User yourusername
    ```
10. Add the identity file path:
    ```bash
    IdentityFile C:\Users\yourname\.ssh\id_ed25519
    ```
    You can also change the Host to be an alias. For example vegaln1.erau.edu -> Vega. Your hostname should look like:
    ```bash
    Host Vega
        HostName vegaln1.erau.edu
        User yourusername
        IdentityFile C:\Users\yourname\.ssh\id_ed25519
    ```
11. Save the file and close it.
12. You should now be able to connect to Vega without entering your password each time.

---

Next Topic: [Vega Basics and Job Submission](docs/02_Vega_Basics.md)