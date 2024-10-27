from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import UserSerializer
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.hashers import make_password
from django.utils.decorators import method_decorator
from django.views import View
import json


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
            return json_response(False, "Username is already taken.")

        # Create and save new user
        user = User.objects.create(username=username, password=make_password(password))
        return json_response(True, "User created successfully.")


class DRFSignupView(APIView):
    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            # Hash the password before saving
            serializer.validated_data["password"] = make_password(
                serializer.validated_data["password"]
            )
            serializer.save()
            return Response(
                {"message": "User created successfully"}, status=status.HTTP_201_CREATED
            )
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
            return json_response(True, "User logged in successfully.")
        else:
            return json_response(False, "Invalid credentials.")


@method_decorator(csrf_exempt, name="dispatch")
class LogoutView(View):
    def post(self, request):
        logout(request)
        return json_response(True, "User logged out successfully.")


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
