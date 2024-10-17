# WebSocket Demo with Django Channels

https://channels.readthedocs.io/en/stable/tutorial/part_1.html

## 1. Setting up a Virtual Environment

### What is a Virtual Environment?

A virtual environment in Python is a self-contained directory that contains its own installation of Python and its own collection of packages. This allows projects to have isolated dependencies, meaning different projects can use different versions of the same package without causing conflicts.

The Python `venv` module creates this isolated environment. This isolation is achieved by creating a specific directory that mimics a full Python environment.

### Creating the Virtual Environment

To create a virtual environment, we use the following command:

```bash
python3 -m venv venv
```

Here’s what happens when this command is run:

- **`python3 -m venv venv`**: This tells Python to use the `venv` module to create a new virtual environment in a directory named `venv`. This directory will contain its own Python interpreter, along with empty directories for libraries and executables. It sets up the structure necessary for installing packages locally, isolated from the system Python.

### Activating the Virtual Environment

Once the virtual environment is created, it needs to be activated. This is done by running:

```bash
source venv/bin/activate
```

#### What does Activation Do?

When you "activate" a virtual environment, several things happen:

1. **Environment Variables**: The `activate` script modifies your shell’s environment variables so that the Python interpreter and package manager (`pip`) point to the virtual environment’s directories instead of the system-wide Python installation.

2. **Modifying the PATH**: The `PATH` environment variable is modified to prioritize the virtual environment’s `bin/` directory, where the Python interpreter and executables (like `pip`) for that environment are located.

3. **Shell Prompt**: The shell prompt is also updated to show the name of the virtual environment, as a visual reminder that you're working in an isolated environment.

#### Why Do We `source` Instead of Executing the Script?

- **Sourcing (`source venv/bin/activate`)** means that the commands within the `activate` script are run in the current shell, modifying the shell’s environment variables directly. If you were to run the script as an executable (e.g., `./venv/bin/activate`), it would spawn a new subprocess that would modify its own environment variables, which would not affect the current shell. By sourcing, the changes to the environment persist in your current session.

#### Is `venv` a Virtual Machine or Docker-like Environment?

No, a Python virtual environment is **not** a virtual machine or container like Docker. Here’s the difference:

- **`venv`**: This is simply an isolated Python environment, achieved by creating a specific directory structure and modifying environment variables. It doesn't emulate a full operating system or containerize processes. It only isolates Python and its packages for a particular project.

- **Virtual Machines/Containers**: A virtual machine emulates a full operating system, and a container like Docker encapsulates an application and its dependencies into a standalone unit that can run independently of the host system. Both VMs and containers offer process isolation and resource allocation, which are much broader in scope than `venv`.

### Deactivating the Virtual Environment

To deactivate the virtual environment and return to using the system-wide Python, simply run:

```bash
deactivate
```

This command resets the environment variables modified by the `activate` script, returning you to your default Python environment.

---

## 2. Installing Django and Channels

Once the virtual environment is activated, you can install the required packages for your project:

```bash
pip install django channels
```

### What are Django and Channels?

- **Django**: A high-level Python web framework that promotes rapid development and clean, pragmatic design for building web applications.
- **Channels**: Django Channels is a separate Python package (not part of Django by default) that extends Django's capabilities to handle asynchronous protocols such as WebSockets. It allows Django to manage real-time communication, enabling features like live chat, notifications, or real-time data updates.

Channels adds support for asynchronous processing in Django, which is normally synchronous. This is important for handling protocols that require long-lived connections like WebSockets, where data is continuously exchanged between the client and server.

## Creating a chat app (inside Django)

> $ python3 manage.py startapp chat

We remove all files besides `chat/views.py` and `chat/__init__.py` in the /chat/ folder.
# django_chat
