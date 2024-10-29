"""Views for user authentication and management."""

import json
import logging
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate, login, logout, get_user
from django.contrib.auth.models import User
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.hashers import make_password
from django.utils.decorators import method_decorator
from django.views import View
from .serializers import UserSerializer

logger = logging.getLogger(__name__)


# Helper function to return JSON responses with errors or success messages
def json_response(success, message):
    return JsonResponse({"success": success, "message": message})


@method_decorator(csrf_exempt, name="dispatch")
class SignupView(View):
    """
    A view to handle user sign-up.
    """

    def post(self, request):
        """
        Handle POST request to create a new user.
        """
        data = json.loads(request.body)
        username = data.get("username")
        password = data.get("password")

        # Check if username is taken
        if User.objects.filter(username=username).exists():
            return JsonResponse(
                {
                    "success": False,
                    "error": "Username is already taken.",
                    "action": "signup",
                },
                status=400,
            )
        # Create and save new user
        user = User.objects.create(username=username, password=make_password(password))

        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)  # This creates the session for the new user
            # Return success response with username
            return JsonResponse(
                {
                    "success": True,
                    "message": "User created and logged in successfully.",
                    "username": username,
                    "action": "signup",
                }
            )
        # In case authentication fails for some reason, which is rare
        return JsonResponse(
            {
                "success": False,
                "error": "User created, but login failed.",
                "action": "signup",
            },
            status=500,
        )


class DRFSignupView(APIView):
    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            # Create a new user instance
            serializer.save(password=make_password(request.data["password"]))
            return Response({"message": "User created successfully"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@method_decorator(csrf_exempt, name="dispatch")
class LoginView(View):
    def post(self, request):
        data = json.loads(request.body)
        username = data.get("username")
        password = data.get("password")

        # Authenticate user
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)  # Login and create session
            return JsonResponse(
                {
                    "success": True,
                    "message": "User logged in successfully.",
                    "username": username,
                    "action": "login",
                }
            )
        return JsonResponse(
            {
                "success": False,
                "error": "Invalid credentials.",
                "action": "login",
            },
            status=400,
        )


class DRFLoginView(APIView):
    """
    DRF view to handle user login.
    """

    def post(self, request):
        username = request.data.get("username")
        password = request.data.get("password")
        user = authenticate(request, username=username, password=password)

        if user is not None:
            login(request, user)
            return Response({"success": True, "message": "Login successful."}, status=status.HTTP_200_OK)
        else:
            return Response({"success": False, "message": "Invalid credentials."}, status=status.HTTP_401_UNAUTHORIZED)


@method_decorator(csrf_exempt, name="dispatch")
class LogoutView(View):
    """
    View to handle user logout.
    https://docs.djangoproject.com/en/5.1/topics/auth/default/#how-to-log-a-user-out
    """

    def post(self, request):
        user = get_user(request)
        if user.is_authenticated:
            try:
                logout(request)
                logger.info("User '%s' logged out successfully.", user.username)
                return JsonResponse({"success": True, "message": "User logged out successfully."})
            except Exception as e:
                logger.error("Logout failed for user '%s': %s", user.username, e)
                return JsonResponse({"success": False, "error": f"Logout failed: {str(e)}"}, status=500)
        else:
            logger.warning("Unauthorized logout attempt detected.")
            return JsonResponse({"success": False, "error": "User is not logged in."}, status=401)


class DRFLogoutView(APIView):
    """
    DRF view to handle user logout.
    """

    def post(self, request):
        logout(request)
        return Response({"success": True, "message": "Logout successful."}, status=status.HTTP_200_OK)


@method_decorator(csrf_exempt, name="dispatch")
class DeleteUserView(View):
    def post(self, request):
        if not request.user.is_authenticated:
            return json_response(False, "User not authenticated.")

        # Set user's account as inactive
        request.user.is_active = False
        request.user.save()
        logout(request)  # End session after deactivation

        # Optionally, you could anonymize data here instead of setting is_active
        return json_response(True, "User account deactivated.")
