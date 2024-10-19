"""
ASGI config for websocket_demo project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.1/howto/deployment/asgi/
"""

import os
import chat.routing

from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.security.websocket import AllowedHostsOriginValidator
from django.core.asgi import get_asgi_application

# Ensure the environment variable is set correctly
print(f"DJANGO_SETTINGS_MODULE: {os.environ.get('DJANGO_SETTINGS_MODULE')}")

# os.environ.setdefault("DJANGO_SETTINGS_MODULE", "websocket_demo.settings")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "websocket_demo.settings")


# Initialize Django ASGI application early to ensure the AppRegistry
# is populated before importing code that may import ORM models.
try:
    django_asgi_app = get_asgi_application()
    print("ASGI application loaded successfully")
except Exception as e:
    print(f"Error while loading ASGI application: {e}")
    raise

application = ProtocolTypeRouter(
    {
        "http": django_asgi_app,
        "websocket": AllowedHostsOriginValidator(
            AuthMiddlewareStack(URLRouter(chat.routing.websocket_urlpatterns))
        ),
        # Just HTTP for now. (We can add other protocols later.)
    }
)
