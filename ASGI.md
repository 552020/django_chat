# ASGI - Asynchronous Server Gateway Interface

https://asgi.readthedocs.io/en/latest/introduction.html

## What is ASGI?

ASGI, or Asynchronous Server Gateway Interface, is described as _"a spiritual successor to WSGI, the long-standing Python standard for compatibility between web servers, frameworks, and applications."_ ASGI aims to extend the flexibility that WSGI introduced by adapting Python web development to support asynchronous operations.

### The Lineage of CGI, WSGI, and ASGI

The journey of Python's web interface standards began with CGI (Common Gateway Interface), which served as the first protocol to bridge web servers with dynamic applications. WSGI (Web Server Gateway Interface) followed, simplifying how Python frameworks and applications communicated with web servers by introducing a single-callable synchronous interface.

However, WSGI's limitations became apparent with the rise of asynchronous networking and real-time features like WebSockets. ASGI was developed to address these shortcomings, expanding the protocol to support asynchronous communication while maintaining backward compatibility with WSGI applications.

### Frameworks and Applications in ASGI

In the context of ASGI, **frameworks** refer to the middleware or higher-level components that help developers build applications by abstracting the lower-level HTTP or WebSocket handling. **Applications**, on the other hand, represent the Python code that responds to requests or incoming events from clients, such as rendering HTML, processing data, or sending WebSocket messages.

ASGI facilitates the interaction between web servers and Python applications, allowing them to handle asynchronous events more efficiently than WSGI, enabling features like real-time communication and long-polling connections.

---

What do you think so far?
